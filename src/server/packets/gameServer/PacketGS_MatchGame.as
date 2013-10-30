package server.packets.gameServer
{
    import server.packets.PacketBasic;
    import server.packets.opcodes.ClientOpcodes;

    public class PacketGS_MatchGame extends PacketBasic
    {
        //uint64
        private var _opponentID: uint = 0;

        //uint8
        private var _status: uint = 0;

        public function PacketGS_MatchGame()
        {
            super(ClientOpcodes.C_MSG_MATCH_GAME);
        }

        public function get opponentID(): uint
        {
            return _opponentID;
        }

        public function get status(): uint
        {
            return _status;
        }

        override public function deserialize(): void
        {
            super.deserialize();

            _opponentID = _buffer.readDouble();

            _status = _buffer.readUnsignedByte();
        }

    }
}
