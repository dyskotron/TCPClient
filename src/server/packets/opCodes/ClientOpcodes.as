package server.packets.opCodes
{
    public class ClientOpcodes
    {
        public static const C_MSG_LOGON_PLAYER: uint = 0;
        public static const S_MSG_LOGON_PLAYER: uint = 1;

        public static const C_MSG_MATCH_GAME: uint = 2;
        public static const S_MSG_MATCH_GAME: uint = 3;

        public static const C_MSG_SAVE_CUSTOM_DATA: uint = 4;
        public static const S_MSG_SAVE_CUSTOM_DATA: uint = 5;

        public static const C_MSG_GET_CUSTOM_DATA: uint = 6;
        public static const S_MSG_GET_CUSTOM_DATA: uint = 7;

        public static const C_MSG_SEND_DATA_TO_CLIENT: uint = 8;
        public static const S_MSG_SEND_DATA_TO_CLIENT: uint = 9;

        public static const C_MSG_PONG: uint = 10;
        public static const S_MSG_PING: uint = 11;

        public static const C_MSG_UNMATCH_GAME: uint = 12;
        public static const S_MSG_UNMATCH_GAME: uint = 13;

        public static const C_MSG_GET_ALL_CACHED_DATA: uint = 14;
        public static const S_MSG_GET_ALL_CACHED_DATA: uint = 15;

        //for monitoring tool
        public static const C_MSG_GET_SERVER_STATS: uint = 16;
        public static const S_MSG_GET_SERVER_STATS: uint = 17;

        public function ClientOpcodes()
        {
        }
    }
}
