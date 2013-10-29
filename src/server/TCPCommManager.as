package server
{
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.TimerEvent;
    import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.utils.Endian;
    import flash.utils.Timer;

    import server.auth.Crypt;
    import server.packets.PacketBasic;
    import server.packets.enumAlts.AuthPacketOpcodes;
    import server.packets.enumAlts.GameServerTypes;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;

    public class TCPCommManager
    {
        private var socket: Socket;
        private var _connected: Boolean;

        private var crc32: CRC32;
        private var crypt: Crypt;
        private var incomingBA: ByteArray;

        public function TCPCommManager()
        {
            crc32 = new CRC32();
            crypt = new Crypt();

            incomingBA = new ByteArray();
            incomingBA.endian = Endian.LITTLE_ENDIAN;
        }

        public function connectWithIPAddress(ip: uint, port: uint): void
        {
            connectWithHost(getStringIpFromUint(ip), port);
        }

        public function packetSend(packet: PacketBasic): void
        {
            trace("_MO_", this, 'PACKET SEND');
            packet.serialize(crypt, crc32);
            socket.writeBytes(packet.buffer);
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
            _connected = true;

            packetSend(new PacketLS_GetVersion());

            var timer: Timer = new Timer(1000, 1);
            timer.addEventListener(TimerEvent.TIMER, function (e: Event)
            {
                packetSend(new PacketLS_GetServerList(GameServerTypes.E_TIC_TAC_TOE));
            });

            timer.start();
        }

        /**
         *
         * @param event
         */
        private function closeHandler(event: Event): void
        {
            trace("_MO_", this, 'CONNECTION CLOSED');
            _connected = false;
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
            _connected = false;
        }

        /**
         *
         * @param event
         */
        private function securityErrorHandler(event: SecurityErrorEvent): void
        {
            trace("_MO_", this, event.text);
            _connected = false;
        }

        /**
         *
         * @param event
         */
        private function socketDataHandler(event: ProgressEvent): void
        {
            trace("_MO_", this, '=======> INCOMING SOCKET DATA - length', socket.bytesAvailable);

            incomingBA.clear();
            socket.readBytes(incomingBA);
            crypt.decryptRecv(incomingBA, PacketBasic.PACKET_HEADER_SIZE);
            incomingBA.position = 0;

            var dataSize: uint = incomingBA.readUnsignedShort();
            var packetType: uint = incomingBA.readUnsignedShort();
            var crc: uint = incomingBA.readUnsignedInt();

            trace("_MO_", this, 'PACKET TYPE:', packetType, 'DATA SIZE:', dataSize, 'CRC:', crc.toString(16));

            //============================= HOVNA =================================//

            var packetData: ByteArray = new ByteArray();
            packetData.endian = Endian.LITTLE_ENDIAN;
            packetData.writeUnsignedInt(0x00000064);
            trace("_MO_", this, 'crc test', crc32.computeCRC32(packetData).toString(16));

            trace("_MO_", this, crc.toString(2));
            trace("_MO_", this, crc32.computeCRC32(packetData).toString(2));


            var packetData: ByteArray = new ByteArray();
            packetData.endian = Endian.LITTLE_ENDIAN;
            packetData.writeBytes(incomingBA, PacketBasic.PACKET_HEADER_SIZE);
            packetData.position = 0;

            trace("_MO_", this, 'CRC TEST - data', packetData.readUnsignedInt().toString(16), 'crc', crc32.computeCRC32(packetData).toString(16));

            packetData.position = 0;
            while (packetData.bytesAvailable)
                trace("_MO_", this, 'pos:', packetData.position, 'val:', packetData.readUnsignedByte().toString(16));


            /**
             trace("_MO_", this, '====================== unsigned bytes:');
             incomingBA.position = PacketBasic.PACKET_HEADER_SIZE;
             while (incomingBA.bytesAvailable)
             trace("_MO_", this, 'pos:', incomingBA.position, 'val:', incomingBA.readUnsignedByte().toString());
             */

            //============================= KONEC HOVEN =================================//


            var packet: PacketBasic;

            switch (packetType)
            {
                case AuthPacketOpcodes.S_MSG_AUTH_CHALLENGE:
                    packet = new PacketLS_GetVersion();
                    packet.buffer.writeBytes(incomingBA);
                    packet.deserialize();
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_CHALLENGE', 'version:', PacketLS_GetVersion(packet).version, 'type:', packet.type);
                    break;
                case AuthPacketOpcodes.S_MSG_AUTH_RECHALLENGE:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_SERVER_LIST');
                    break;
                case AuthPacketOpcodes.S_MSG_AUTH_SERVER_LIST:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_SERVER_LIST');
                    break;
                case AuthPacketOpcodes.S_MSG_AUTH_GET_SERVER_STATS:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_GET_SERVER_STATS');
                    break;
            }


        }
    }
}
