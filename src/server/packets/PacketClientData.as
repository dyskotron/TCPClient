package server.packets
{
    import server.auth.Crypt;
    import server.packets.opcodes.ClientOpcodes;

    public class PacketClientData extends PacketBasic
    {
        //uint8
        private var _dataType: uint;

        public function PacketClientData()
        {
            super(ClientOpcodes.C_MSG_SEND_DATA_TO_CLIENT);
        }

        public function get dataType(): uint
        {
            return _dataType;
        }

        public function set dataType(value: uint): void
        {
            _dataType = value;
        }

        override public function deserialize(): void
        {
            super.deserialize();

            //dataType
            _dataType = _buffer.readUnsignedByte();
        }

        /**
         *
         * @param crypt
         * @param dataSize (uint16)
         * @param crc32 (uint32)
         */
        override public function serializeHeader(crypt: Crypt, dataSize: uint, crc32: uint): void
        {
            super.serializeHeader(crypt, dataSize, crc32);

            _buffer.writeByte(_dataType);
        }
    }
}
