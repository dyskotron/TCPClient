package
{

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import server.TCPCommEvent;
    import server.TCPCommManager;
    import server.packets.PacketBasic;
    import server.packets.opCodes.AuthPacketOpcodes;
    import server.packets.GameServerTypes;
    import server.packets.gameServer.PacketGS_PlayerLogin;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;

    public class Main extends Sprite
    {
        private static const LOGIN_SERVER_IP: uint = 3919800155;
        private static const LOGIN_SERVER_PORT: uint = 9339;

        private static const LOGIN_SERVER: uint = 0;
        private static const GAME_SERVER: uint = 1;

        private static const SERVER_TIC_TAC_TOE: uint = 1;
        private static const PLAYER_ID: uint = 625568080;

        private var tcpManager: TCPCommManager;
        private var server: uint;

        public function Main()
        {
            trace("_MO_", this, 'START');

            graphics.beginFill(0x004488);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            addEventListener(MouseEvent.CLICK, mouseClickListener);

            tcpManager = new TCPCommManager();
            tcpManager.addEventListener(TCPCommEvent.PACKET_RECIEVED, packetRecievedHandler);
            tcpManager.connectWithIPAddress(LOGIN_SERVER_IP, LOGIN_SERVER_PORT);
            tcpManager.packetSend(new PacketLS_GetVersion());
            tcpManager.packetSend(new PacketLS_GetServerList(GameServerTypes.E_TIC_TAC_TOE));

        }

        private function mouseClickListener(event: MouseEvent): void
        {

        }

        /**
         *
         * @param event
         */
        private function packetRecievedHandler(event: TCPCommEvent): void
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
         * Handles list of game servers from server
         * @param packet
         */
        private function handleServerList(packet: PacketBasic): void
        {
            trace("_MO_", this, 'handleServerList', server);
            if (server == LOGIN_SERVER)
            {
                var packetServerList: PacketLS_GetServerList = PacketLS_GetServerList(packet);
                tcpManager.disconnect();
                tcpManager.connectWithIPAddress(packetServerList.serverIP, packetServerList.serverPort);
                server = GAME_SERVER;

                var loginPacket: PacketGS_PlayerLogin = new PacketGS_PlayerLogin();
                loginPacket.playerID = PLAYER_ID;
                tcpManager.packetSend(loginPacket);
            }
        }

        /**
         * Handle get version / login
         * @param packet
         */
        private function handleAuthChallenge(packet: PacketBasic): void
        {
            trace("_MO_", this, 'handleAuthChallenge', server);

            if (server == LOGIN_SERVER)
            {
                var versionPacket: PacketLS_GetVersion = PacketLS_GetVersion(packet);
                trace("_MO_", this, 'get version response - version:', versionPacket.version);
            }
            else if (server == GAME_SERVER)
            {
                //var versionPacket: PacketLS_GetVersion = PacketLS_GetVersion(packet);
                trace("_MO_", this, 'login response');
            }
        }


    }
}
