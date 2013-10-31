package server.packets.loginServer
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import server.CRC32;
    import server.auth.Crypt;
    import server.packets.PacketBasic;
    import server.packets.opcodes.AuthPacketOpcodes;

    public class PacketLS_GetServerList extends PacketBasic
    {
        //uint32
        private var _serverType: uint;
        //uint32
        private var _serverIP: uint;
        //uint32
        private var _serverPort: uint;

        /**
         *
         * @param serverType
         */
        public function PacketLS_GetServerList()
        {
            super(AuthPacketOpcodes.C_MSG_AUTH_SERVER_LIST);
        }

        /**
         *
         */
        public function get serverIP(): uint
        {
            return _serverIP;
        }

        /**
         *
         */
        public function get serverPort(): uint
        {
            return _serverPort;
        }


        public function set serverType(value: uint): void
        {
            _serverType = value;
        }

        /**
         *
         */
        override public function deserialize(): void
        {
            super.deserialize();

            _serverIP = buffer.readUnsignedInt();
            _serverPort = buffer.readUnsignedInt();
        }
        /**
         *
         * @param crypt
         * @param crc
         */
        override public function serialize(crypt: Crypt, crc: CRC32): void
        {
            var internalBuffer: ByteArray = new ByteArray();
            internalBuffer.endian = Endian.LITTLE_ENDIAN;
            internalBuffer.writeUnsignedInt(_serverType);

            serializeHeader(crypt, internalBuffer.length, crc.computeCRC32(internalBuffer));

            _buffer.writeBytes(internalBuffer);
        }
    }
}
