package server.packets
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import server.CRC32;
    import server.auth.Crypt;

    public class PacketBasic
    {

        public static const PACKET_HEADER_SIZE: uint = 8;

        //uint16
        protected var _type: uint;

        protected var _buffer: ByteArray;

        /**
         *
         * @param type
         * @param buffer
         */
        public function PacketBasic(type: uint = 0, buffer: ByteArray = null)
        {
            _buffer = buffer ? buffer : new ByteArray();
            _buffer.endian = Endian.LITTLE_ENDIAN;
            this._type = type;
        }

        /**
         *
         */
        public function get buffer(): ByteArray
        {
            return _buffer;
        }

        /**
         *
         * @param value
         */
        public function set buffer(value: ByteArray): void
        {
            _buffer = value;
        }

        /**
         *
         */
        public function get type(): uint
        {
            return _type;
        }

        /**
         *
         */
        public function deserialize(): void
        {
            _buffer.position = 0;

            //dataSize
            _buffer.readUnsignedShort();
            //type
            _type = _buffer.readUnsignedShort();
            //crc
            _buffer.readUnsignedInt();
        }

        /**
         *
         * @param crypt
         * @param dataSize (uint16)
         * @param crc32 (uint32)
         */
        public function serializeHeader(crypt: Crypt, dataSize: uint, crc32: uint): void
        {
            _buffer.writeShort(dataSize);
            _buffer.writeShort(_type);
            _buffer.writeUnsignedInt(crc32);

            crypt.encryptSend(_buffer, PACKET_HEADER_SIZE);
        }

        /**
         *
         * @param crypt
         * @param crc
         */
        public function serialize(crypt: Crypt, crc: CRC32): void
        {
            serializeHeader(crypt, 0, 0);
        }
    }
}
