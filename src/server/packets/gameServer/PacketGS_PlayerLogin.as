package server.packets.gameServer
{
    import flash.utils.ByteArray;
    import flash.utils.Endian;

    import server.CRC32;
    import server.auth.Crypt;
    import server.packets.PacketBasic;
    import server.packets.enumAlts.AuthPacketOpcodes;

    public class PacketGS_PlayerLogin extends PacketBasic
    {
        //uint64
        private var _playerID: uint;

        //FacebookUser
        private var _user: uint;

        /**
         *
         * @param serverType
         */
        public function PacketGS_PlayerLogin()
        {
            super(AuthPacketOpcodes.C_MSG_AUTH_CHALLENGE);
        }

        /**
         *
         */
        public function set playerID(value: uint): void
        {
            _playerID = value;
        }

        public function get user(): uint
        {
            return _user;
        }

        /**
         *
         */
        override public function deserialize(): void
        {
            super.deserialize();
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
            internalBuffer.writeDouble(_playerID);

            serializeHeader(crypt, internalBuffer.length, crc.computeCRC32(internalBuffer));

            _buffer.writeBytes(internalBuffer);
        }
    }
}
