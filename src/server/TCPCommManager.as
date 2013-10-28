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
    import server.packets.GameServerTypes;
    import server.packets.PacketBasic;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;

    public class TCPCommManager
    {
        private var socket: Socket;
        private var _connected: Boolean;

        private var crc32: CRC32;
        private var crypt: Crypt;

        public function TCPCommManager()
        {
            crc32 = new CRC32();
            crypt = new Crypt();
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
            trace("_MO_", this, 'SOCKET DATA - length', socket.bytesAvailable);

            var ba: ByteArray = new ByteArray();

            while (socket.bytesAvailable)
                ba.writeByte(socket.readByte());

            crypt.decryptRecv(ba, PacketBasic.PACKET_HEADER_SIZE);
            ba.position = 0;
            ba.endian = Endian.LITTLE_ENDIAN;

            trace("_MO_", this, 'DATA SIZE:', ba.readUnsignedShort());
            trace("_MO_", this, 'PACKET TYPE:', ba.readUnsignedShort());
            trace("_MO_", this, 'CRC:', ba.readUnsignedInt());

            trace("_MO_", this, '====================== unsigned bytes:');
            ba.position = PacketBasic.PACKET_HEADER_SIZE;
            while (ba.bytesAvailable)
                trace("_MO_", this, 'pos:', ba.position, 'val:', ba.readUnsignedByte().toString(2));

        }
    }
}
