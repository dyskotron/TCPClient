package server.packets.gameServer
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import server.CRC32;
    import server.auth.Crypt;
    import server.packets.PacketBasic;
    import server.packets.opcodes.ClientOpcodes;

    public class PacketGS_PingPong extends PacketBasic
    {
        //uint64
        private var _timestamp: uint = 0;

        /**
         *
         * @param serverType
         */
        public function PacketGS_PingPong()
        {
            super(ClientOpcodes.C_MSG_PONG);
        }

        public function get timestamp(): uint
        {
            return _timestamp;
        }

        public function set timestamp(value: uint): void
        {
            _timestamp = value;
        }

        /**
         *
         */
        override public function deserialize(): void
        {
            super.deserialize();

            _timestamp = _buffer.readDouble();
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
            //TODO: write as uint64
            internalBuffer.writeDouble(_timestamp);

            serializeHeader(crypt, internalBuffer.length, crc.computeCRC32(internalBuffer));

            _buffer.writeBytes(internalBuffer);
        }
    }
}
