package server.packets
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import server.CRC32;
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
         * @param crc
         */
        override public function serialize(crypt: Crypt, crc: CRC32): void
        {
            var internalBuffer: ByteArray = new ByteArray();
            internalBuffer.endian = Endian.LITTLE_ENDIAN;
            internalBuffer.writeByte(_dataType);

            serializeHeader(crypt, internalBuffer.length, crc.computeCRC32(internalBuffer));

            _buffer.writeBytes(internalBuffer);
        }
    }
}
