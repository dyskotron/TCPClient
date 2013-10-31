package server.packets.client
{
    import flash.utils.ByteArray;

    import server.CRC32;
    import server.auth.Crypt;
    import server.packets.PacketClientData;

    public class PacketC_Turn extends PacketClientData
    {
        private var _posX: uint;
        private var _posY: uint;

        public function PacketC_Turn()
        {
        }

        public function get posX(): uint
        {
            return _posX;
        }

        public function set posX(value: uint): void
        {
            _posX = value;
        }

        public function get posY(): uint
        {
            return _posY;
        }

        public function set posY(value: uint): void
        {
            _posY = value;
        }

        override public function deserialize(): void
        {

            super.deserialize();

            _posX = _buffer.readUnsignedByte();
            _posY = _buffer.readUnsignedByte();
        }

        override public function serialize(crypt: Crypt, crc: CRC32): void
        {
            var internalBuffer: ByteArray = new ByteArray();
            internalBuffer.writeByte(_posX);
            internalBuffer.writeByte(_posY);

            serializeHeader(crypt, internalBuffer.length, crc.computeCRC32(internalBuffer));


        }
    }
}
