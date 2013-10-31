package server
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import server.auth.Crypt;
    import server.packets.GameServerTypes;
    import server.packets.PacketBasic;
    import server.packets.gameServer.PacketGS_MatchGame;
    import server.packets.gameServer.PacketGS_PingPong;
    import server.packets.gameServer.PacketGS_PlayerLogin;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;
    import server.packets.opcodes.AuthPacketOpcodes;
    import server.packets.opcodes.ClientDataOpcodes;
    import server.packets.opcodes.ClientOpcodes;

    public class TCPCommManager extends EventDispatcher
    {
        public static const SERVER_TYPE_LOGIN: uint = 0;
        public static const SERVER_TYPE_GAME: uint = 1;

        private static const STATE_AWAITING_HEADER: uint = 0;
        private static const STATE_AWAITING_DATA: uint = 1;

        private var state: uint = STATE_AWAITING_HEADER;

        private var crc32: CRC32;
        private var crypt: Crypt;
        private var socket: Socket;
        private var socketBA: ByteArray;

        private var packetQueue: Vector.<PacketBasic>;

        private var incomingDataSize: uint;
        private var incomingPacketType: uint;
        private var _serverType: uint;
        private var clientDataType: uint;

        public function TCPCommManager()
        {
            crc32 = new CRC32();
            crypt = new Crypt();

            socketBA = new ByteArray();
            socketBA.endian = Endian.LITTLE_ENDIAN;

            packetQueue = new Vector.<PacketBasic>();

            _serverType = SERVER_TYPE_LOGIN;
        }

        public function connectWithIPAddress(ip: uint, port: uint): void
        {
            connectWithHost(getStringIpFromUint(ip), port);
        }

        public function disconnect(): void
        {
            //disconnect from server
            socket.close();

            //empty queue
            packetQueue = new Vector.<PacketBasic>();
        }

        public function packetSend(packet: PacketBasic): void
        {
            trace("_MO_", this, 'SEND PACKET', packet.type);
            if (!socket.connected)
                packetQueue.push(packet);
            else
            {
                packet.serialize(crypt, crc32);
                socket.writeBytes(packet.buffer);
            }
        }

        public function set serverType(serverType: uint): void
        {
            _serverType = serverType;
        }

        /**
         *
         * @param host
         * @param port
         */
        private function connectWithHost(host: String, port: uint): void
        {
            socket = new Socket();
            socket.addEventListener(Event.CONNECT, connectHandler);
            socket.addEventListener(Event.CLOSE, closeHandler);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            socket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);

            trace("_MO_", this, 'CONNECTING TO ' + host + ':' + port);
            socket.connect(host, port);
        }


        /**
         *
         * @param event
         */
        private function connectHandler(event: Event): void
        {
            trace("_MO_", this, 'CONNECTED');

            crypt.reset();

            while (packetQueue.length > 0)
                packetSend(packetQueue.shift());

        }

        /**
         *
         * @param event
         */
        private function closeHandler(event: Event): void
        {
            trace("_MO_", this, 'CONNECTION CLOSED');
        }

        /**
         *
         * @param value
         * @return
         */
        private function getStringIpFromUint(value: uint): String
        {
            var bytes: Array = [];
            bytes.push(value & 0xFF);
            bytes.push(value >> 8 & 0xFF);
            bytes.push(value >> 16 & 0xFF);
            bytes.push(value >> 24 & 0xFF);

            return bytes.join('.');
        }

        /**
         *
         * @param event
         */
        private function ioErrorHandler(event: IOErrorEvent): void
        {
            trace("_MO_", this, event.text);
        }

        /**
         *
         * @param event
         */
        private function securityErrorHandler(event: SecurityErrorEvent): void
        {
            trace("_MO_", this, event.text);
        }

        /**
         *
         * @param event
         */
        private function socketDataHandler(event: ProgressEvent): void
        {
            //trace("_MO_", this, '=======> INCOMING SOCKET DATA - length', socket.bytesAvailable);

            if (state == STATE_AWAITING_HEADER)
            {
                //if we don't have complete header - return and wait for rest
                if (socket.bytesAvailable < PacketBasic.PACKET_HEADER_SIZE)
                    return;

                //read, decrypt & get info from header
                socketBA.clear();
                socket.readBytes(socketBA, 0, PacketBasic.PACKET_HEADER_SIZE);
                crypt.decryptRecv(socketBA, PacketBasic.PACKET_HEADER_SIZE);
                socketBA.position = 0;
                incomingDataSize = socketBA.readUnsignedShort();
                incomingPacketType = socketBA.readUnsignedShort();

                /**only for debug*/
                var crc: uint = socketBA.readUnsignedInt();
                trace("_MO_", this, 'INCOMING PACKET TYPE:', incomingPacketType, 'DATA SIZE:', incomingDataSize, 'CRC:', crc.toString(16));
                /**/

                //clent packet data have own header - data is actually 1 byte longer then what is in header
                if (_serverType == SERVER_TYPE_GAME && incomingPacketType == ClientOpcodes.S_MSG_SEND_DATA_TO_CLIENT)
                    incomingDataSize++;

                state = STATE_AWAITING_DATA;
            }

            if (state == STATE_AWAITING_DATA)
            {
                //if we don't have complete data - return and wait for rest
                if (socket.bytesAvailable < incomingDataSize)
                    return;

                //read packet data
                socket.readBytes(socketBA, socketBA.length, incomingDataSize);

                //if client packet, get data type
                if (_serverType == SERVER_TYPE_GAME && incomingPacketType == ClientOpcodes.S_MSG_SEND_DATA_TO_CLIENT)
                {
                    socketBA.position = PacketBasic.PACKET_HEADER_SIZE;
                    clientDataType = socketBA.readUnsignedByte();
                    trace("_MO_", this, 'CLIENT DATA TYPE', clientDataType);
                }

                processPacketData(socketBA, incomingPacketType, clientDataType);

                state = STATE_AWAITING_HEADER;

                //if there are some other data in socket, process them
                if (socket.connected && socket.bytesAvailable > 0)
                    socketDataHandler(null);
            }
        }

        private function processPacketData(socketBA: ByteArray, packetType: uint, clientDataType: uint): void
        {
            socketBA.position = 0;

            var packet: PacketBasic;

            if (_serverType == SERVER_TYPE_GAME && packetType == ClientOpcodes.C_MSG_SEND_DATA_TO_CLIENT)
                packet = createPacketC(clientDataType);
            else if (_serverType == SERVER_TYPE_GAME)
                packet = createPacketGS(packetType);
            else if (_serverType == SERVER_TYPE_LOGIN)
                packet = createPacketLS(packetType);
            else
                trace("_MO_", this, 'WAT? UNKNOWN SERVER TYPE?');


            if (packet)
            {
                packet.buffer.writeBytes(socketBA);
                packet.deserialize();
            }
            dispatchEvent(new TCPCommEvent(TCPCommEvent.PACKET_RECIEVED, packet, packetType));

        }

        private static function createPacketLS(packetType: uint): PacketBasic
        {
            var packet: PacketBasic;

            switch (packetType)
            {
                case AuthPacketOpcodes.S_MSG_AUTH_CHALLENGE:
                    packet = new PacketLS_GetVersion();
                    break;
                case AuthPacketOpcodes.S_MSG_AUTH_RECHALLENGE:
                    break;
                case AuthPacketOpcodes.S_MSG_AUTH_SERVER_LIST:
                    packet = new PacketLS_GetServerList(GameServerTypes.E_TIC_TAC_TOE);
                    break;
                case AuthPacketOpcodes.S_MSG_AUTH_GET_SERVER_STATS:
                    break;
            }

            return packet;
        }

        private static function createPacketGS(packetType: uint): PacketBasic
        {
            var packet: PacketBasic;

            switch (packetType)
            {
                case ClientOpcodes.S_MSG_LOGON_PLAYER:
                    packet = new PacketGS_PlayerLogin();
                    break;

                case ClientOpcodes.S_MSG_MATCH_GAME:
                    packet = new PacketGS_MatchGame();
                    break;

                case ClientOpcodes.S_MSG_PING:
                    packet = new PacketGS_PingPong();
                    break;
            }

            return packet;
        }

        private static function createPacketC(dataType: uint): PacketBasic
        {
            var packet: PacketBasic;

            switch (dataType)
            {
                case ClientDataOpcodes.C_MSG_CLIENT_DATA_TURN_START:
                    packet = new PacketGS_PlayerLogin();
                    break;

                case ClientDataOpcodes.C_MSG_CLIENT_DATA_TURN_TIMEOUT:
                    packet = new PacketGS_MatchGame();
                    break;

                case ClientDataOpcodes.C_MSG_CLIENT_DATA_TURN:
                    packet = new PacketGS_PingPong();
                    break;
            }

            return packet;
        }
    }
}
