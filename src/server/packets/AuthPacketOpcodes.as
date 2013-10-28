package server.packets
{
    public class AuthPacketOpcodes
    {
        public static const C_MSG_AUTH_CHALLENGE: uint = 0;
        public static const S_MSG_AUTH_CHALLENGE: uint = 1;
        public static const C_MSG_AUTH_SERVER_LIST: uint = 2;
        public static const S_MSG_AUTH_SERVER_LIST: uint = 3;
        public static const C_MSG_AUTH_RECHALLENGE: uint = 4;
        public static const S_MSG_AUTH_RECHALLENGE: uint = 5;
        public static const C_MSG_AUTH_GET_SERVER_STATS: uint = 6;		//for monitoring tool
        public static const S_MSG_AUTH_GET_SERVER_STATS: uint = 7;		//for monitoring tool

        public function AuthPacketOpcodes()
        {
        }
    }
}
