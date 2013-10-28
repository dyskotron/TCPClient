package server.packets.loginServer
{
    import server.packets.AuthPacketOpcodes;
    import server.packets.PacketBasic;

    public class PacketLS_GetVersion extends PacketBasic
    {
        //uint32
        private var version: uint;

        public function PacketLS_GetVersion()
        {
            super();
            _type = AuthPacketOpcodes.C_MSG_AUTH_CHALLENGE;
        }

        override public function deserialize(): void
        {
            super.deserialize();

            version = buffer.readUnsignedInt();
        }
    }
}
