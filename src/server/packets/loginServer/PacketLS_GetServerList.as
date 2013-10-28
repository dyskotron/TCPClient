package server.packets.loginServer
{
    import flash.utils.ByteArray;

    import server.CRC32;
    import server.auth.Crypt;
    import server.packets.AuthPacketOpcodes;
    import server.packets.PacketBasic;

    public class PacketLS_GetServerList extends PacketBasic
    {
        //uint32
        private var serverType: uint;
        //uint32
        private var serverIP: uint;
        //uint32
        private var serverPort: uint;

        public function PacketLS_GetServerList(serverType: uint)
        {
            super();

            this.serverType = serverType;

            _type = AuthPacketOpcodes.C_MSG_AUTH_SERVER_LIST;
        }

        override public function deserialize(): void
        {
            super.deserialize();

            serverIP = buffer.readUnsignedInt();
            serverPort = buffer.readUnsignedInt();
        }

        override public function serialize(crypt: Crypt, crc: CRC32): void
        {
            var internalBuffer: ByteArray = new ByteArray();
            internalBuffer.writeUnsignedInt(serverType);

            serializeHeader(crypt, internalBuffer.length, crc.computeCRC32(internalBuffer));

            _buffer.writeBytes(internalBuffer);
        }
    }
}
