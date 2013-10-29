package server
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import server.auth.Crypt;
    import server.packets.PacketBasic;
    import server.packets.enumAlts.AuthPacketOpcodes;
    import server.packets.enumAlts.GameServerTypes;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;

    public class TCPCommManager
    {
        public static const STATE_AWAITING_HEADER: uint = 0;
        public static const STATE_AWAITING_DATA: uint = 1;

        private var state: uint = STATE_AWAITING_HEADER;

        private var crc32: CRC32;
        private var crypt: Crypt;
        private var socket: Socket;
        private var socketBA: ByteArray;

        private var packetQueue: Vector.<PacketBasic>;

        private var incomingDataSize: uint;
        private var incomingPacketType: uint;

        public function TCPCommManager()
        {
            crc32 = new CRC32();
            crypt = new Crypt();

            socketBA = new ByteArray();
            socketBA.endian = Endian.LITTLE_ENDIAN;

            packetQueue = new Vector.<PacketBasic>();
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
            trace("_MO_", this, 'PACKET SEND');

            if (!socket.connected)
                packetQueue.push(packet);
            else
            {
                packet.serialize(crypt, crc32);
                socket.writeBytes(packet.buffer);
            }
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

            while(packetQueue.length > 0)
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
            trace("_MO_", this, '=======> INCOMING SOCKET DATA - length', socket.bytesAvailable);

            if (state == STATE_AWAITING_HEADER)
            {
                //if we don't have complete header - return and wait for rest
                if (socket.bytesAvailable < PacketBasic.PACKET_HEADER_SIZE)
                    return;

                trace("_MO_", this, '->READING HEADER - socket.bytesAvailable', socket.bytesAvailable);

                //read, decrypt & get info from header
                socket.readBytes(socketBA, 0, PacketBasic.PACKET_HEADER_SIZE);
                crypt.decryptRecv(socketBA, PacketBasic.PACKET_HEADER_SIZE);
                socketBA.position = 0;
                incomingDataSize = socketBA.readUnsignedShort();
                incomingPacketType = socketBA.readUnsignedShort();
                var crc: uint = socketBA.readUnsignedInt();
                trace("_MO_", this, 'PACKET TYPE:', incomingPacketType, 'DATA SIZE:', incomingDataSize, 'CRC:', crc.toString(16));

                state = STATE_AWAITING_DATA;
            }

            if (state == STATE_AWAITING_DATA)
            {
                //if we don't have complete data - return and wait for rest
                if (socket.bytesAvailable < incomingDataSize)
                    return;

                trace("_MO_", this, '->READING DATA - socket.bytesAvailable', socket.bytesAvailable);

                //read packet data & handle packet
                socket.readBytes(socketBA, PacketBasic.PACKET_HEADER_SIZE, incomingDataSize);
                socketBA.position = 0;
                handlePacket(socketBA, incomingPacketType);
                //socketBA.clear();

                state = STATE_AWAITING_HEADER;


                //if there are some other data in socket, process them
                if (socket.connected && socket.bytesAvailable > 0)
                    socketDataHandler(null);
            }
        }

        private function handlePacket(socketBA: ByteArray, packetType: uint): void
        {
            trace("_MO_", this, 'handlePacket', socketBA.length);

            var packet: PacketBasic;

            switch (packetType)
            {
                case AuthPacketOpcodes.S_MSG_AUTH_CHALLENGE:
                    packet = new PacketLS_GetVersion();
                    packet.buffer.writeBytes(socketBA);
                    packet.deserialize();
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_CHALLENGE', 'version:', PacketLS_GetVersion(packet).version, 'type:', packet.type);
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_RECHALLENGE:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_RECHALLENGE');
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_SERVER_LIST:
                    packet = new PacketLS_GetServerList(GameServerTypes.E_TIC_TAC_TOE);
                    packet.buffer.writeBytes(socketBA);
                    packet.deserialize();
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_SERVER_LIST', 'serverIP:', getStringIpFromUint(PacketLS_GetServerList(packet).serverIP), 'serverPort:', PacketLS_GetServerList(packet).serverPort);
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_GET_SERVER_STATS:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_GET_SERVER_STATS');
                    break;
            }
        }
    }
}
