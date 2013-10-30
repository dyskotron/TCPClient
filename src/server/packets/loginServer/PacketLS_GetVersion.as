package server.packets.loginServer
{
    import server.packets.PacketBasic;
    import server.packets.opcodes.AuthPacketOpcodes;

    public class PacketLS_GetVersion extends PacketBasic
    {
        //uint32
        private var _version: uint;

        public function PacketLS_GetVersion()
        {
            super(AuthPacketOpcodes.C_MSG_AUTH_CHALLENGE);
        }

        public function get version(): uint
        {
            return _version;
        }

        override public function deserialize(): void
        {
            super.deserialize();

            _version = buffer.readUnsignedInt();
        }
    }
}
