package
{

    import flash.display.Sprite;

    import server.TCPCommEvent;
    import server.TCPCommManager;
    import server.packets.GameServerTypes;
    import server.packets.PacketBasic;
    import server.packets.gameServer.PacketGS_PingPong;
    import server.packets.gameServer.PacketGS_PlayerLogin;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;
    import server.packets.opcodes.AuthPacketOpcodes;
    import server.packets.opcodes.ClientOpcodes;

    public class Main extends Sprite
    {
        private static const LOGIN_SERVER_IP: uint = 3919800155;
        private static const LOGIN_SERVER_PORT: uint = 9339;

        private static const PLAYER_ID: uint = 625568080;

        private var tcpManager: TCPCommManager;


        public function Main()
        {
            trace("_MO_", this, 'START');


            tcpManager = new TCPCommManager();
            tcpManager.addEventListener(TCPCommEvent.PACKET_RECIEVED, packetLS_RecievedHandler);
            tcpManager.connectWithIPAddress(LOGIN_SERVER_IP, LOGIN_SERVER_PORT);
            tcpManager.packetSend(new PacketLS_GetVersion());
            tcpManager.packetSend(new PacketLS_GetServerList(GameServerTypes.E_TIC_TAC_TOE));


            /*
             var uint32_1: uint = 0x01234567;
             var uint32_2: uint = 0x89abcdef;

             var byteArray: ByteArray = new ByteArray();
             byteArray.endian = Endian.LITTLE_ENDIAN;
             byteArray.writeUnsignedInt(uint32_2);
             byteArray.writeUnsignedInt(uint32_1);

             byteArray.position = 0;
             var uint1: Number = byteArray.readUnsignedInt();
             var uint2: Number = byteArray.readUnsignedInt() * 0x100000000;
             var uint3: Number = uint1 + uint2;

             trace("_MO_", this, uint1.toString(16), uint2.toString(16), uint3.toString(16));
             */
        }

        //==========================================================================================================//

        /**
         *  Handles packets recieved from login server
         * @param event
         */
        private function packetLS_RecievedHandler(event: TCPCommEvent): void
        {
            switch (event.packetType)
            {
                case AuthPacketOpcodes.S_MSG_AUTH_CHALLENGE:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_CHALLENGE');
                    handleAuthChallenge(event.packet);
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_RECHALLENGE:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_RECHALLENGE');
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_SERVER_LIST:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_SERVER_LIST');
                    handleServerList(event.packet);
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_GET_SERVER_STATS:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_GET_SERVER_STATS');
                    break;
            }
        }

        /**
         * Handles list of game servers
         * @param packet
         */
        private function handleServerList(packet: PacketBasic): void
        {
            trace("_MO_", this, 'handleServerList');

            var packetServerList: PacketLS_GetServerList = PacketLS_GetServerList(packet);
            tcpManager.disconnect();
            tcpManager.removeEventListener(TCPCommEvent.PACKET_RECIEVED, packetLS_RecievedHandler);
            tcpManager.addEventListener(TCPCommEvent.PACKET_RECIEVED, packetGS_RecievedHandler);
            tcpManager.serverType = TCPCommManager.SERVER_TYPE_GAME;

            tcpManager.connectWithIPAddress(packetServerList.serverIP, packetServerList.serverPort);


            var loginPacket: PacketGS_PlayerLogin = new PacketGS_PlayerLogin();
            loginPacket.playerID = PLAYER_ID;
            tcpManager.packetSend(loginPacket);
        }

        /**
         * Handle get version
         * @param packet
         */
        private function handleAuthChallenge(packet: PacketBasic): void
        {
            trace("_MO_", this, 'handleAuthChallenge');

            var versionPacket: PacketLS_GetVersion = PacketLS_GetVersion(packet);
            trace("_MO_", this, 'get version response - version:', versionPacket.version);

        }


        //==========================================================================================================//

        /**
         * Process packets recieved from game server
         * @param event
         */
        private function packetGS_RecievedHandler(event: TCPCommEvent): void
        {
            switch (event.packetType)
            {
                case ClientOpcodes.S_MSG_LOGON_PLAYER:
                    trace("_MO_", this, 'packet recieved S_MSG_LOGON_PLAYER');
                    handleLogonPlayer(event.packet);
                    break;

                case ClientOpcodes.S_MSG_PING:
                    trace("_MO_", this, 'packet recieved S_MSG_PING');
                    handlePingPong(event.packet);
                    break;
            }
        }

        /**
         * Handle player log on
         * @param packet
         */
        private function handleLogonPlayer(packet: PacketBasic): void
        {
            trace("_MO_", this, 'handleLogonPlayer');
        }

        /**
         * Handle ping pong
         * @param packet
         */
        private function handlePingPong(packet: PacketBasic): void
        {
            trace("_MO_", this, 'handlePingPong');

            var pingPacket: PacketGS_PingPong = PacketGS_PingPong(packet);
            trace("_MO_", this, 'ping pong - timestamp:', pingPacket.timestamp);

            tcpManager.packetSend(new PacketGS_PingPong());
        }
    }
}
