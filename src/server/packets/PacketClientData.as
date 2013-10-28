package server.packets
{
    public class PacketClientData extends PacketBasic
    {
        //uint8
        protected var dataType: uint;

        public function PacketClientData()
        {
            super();
        }

        override public function deserialize(): void
        {
            super.deserialize();

            //dataType
            _buffer.readUnsignedByte();
        }
    }
}
