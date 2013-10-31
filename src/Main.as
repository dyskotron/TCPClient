package
{

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import server.TCPCommEvent;
    import server.TCPCommManager;
    import server.packets.GameServerTypes;
    import server.packets.PacketBasic;
    import server.packets.PacketClientData;
    import server.packets.client.PacketC_Turn;
    import server.packets.client.PacketC_TurnStart;
    import server.packets.client.PacketC_TurnTimeOut;
    import server.packets.gameServer.PacketGS_MatchGame;
    import server.packets.gameServer.PacketGS_PingPong;
    import server.packets.gameServer.PacketGS_PlayerLogin;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;
    import server.packets.opcodes.AuthPacketOpcodes;
    import server.packets.opcodes.ClientDataOpcodes;
    import server.packets.opcodes.ClientOpcodes;

    import ui.BasicButton;
    import ui.Diode;

    public class Main extends Sprite
    {
        private static const LOGIN_SERVER_IP: uint = 3919800155;
        private static const LOGIN_SERVER_PORT: uint = 9339;

        private static const PLAYER_ID: uint = 625568080;

        private var tcpManager: TCPCommManager;
        private var lastButtonY: int = 30;
        private var diode: Diode;


        public function Main()
        {
            trace("_MO_", this, 'START');

            initUI();


            tcpManager = new TCPCommManager();
            tcpManager.addEventListener(TCPCommEvent.PACKET_RECIEVED, packetLS_RecievedHandler);
            tcpManager.connectWithIPAddress(LOGIN_SERVER_IP, LOGIN_SERVER_PORT);

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

        private function initUI(): void
        {
            var loginButton: BasicButton = new BasicButton('LOGIN');
            loginButton.addEventListener(MouseEvent.CLICK, login_clickHandler);
            addButton(loginButton);

            var startMatchButton: BasicButton = new BasicButton('START MATCH');
            startMatchButton.addEventListener(MouseEvent.CLICK, startMatch_clickHandler);
            addButton(startMatchButton);

            var sendMsgButton: BasicButton = new BasicButton('SEND MSG');
            sendMsgButton.addEventListener(MouseEvent.CLICK, sendMsg_clickHandler);
            addButton(sendMsgButton);

            diode = new Diode();
            addChild(diode);
            diode.x = diode.y = 15;
        }

        private function addButton(button: BasicButton): void
        {
            addChild(button);
            button.x = (stage.stageWidth - button.width) / 2;
            button.y = lastButtonY;
            lastButtonY += 50;
        }

        private function login_clickHandler(event: MouseEvent): void
        {
            tcpManager.packetSend(new PacketLS_GetVersion());
            tcpManager.packetSend(new PacketLS_GetServerList(GameServerTypes.E_TIC_TAC_TOE));
        }

        private function startMatch_clickHandler(event: MouseEvent): void
        {
            tcpManager.packetSend(new PacketGS_MatchGame());
        }

        private function sendMsg_clickHandler(event: MouseEvent): void
        {
            var clientPacket: PacketC_Turn = new PacketC_Turn();
            clientPacket.posX = 10;
            clientPacket.posY = 20;
            tcpManager.packetSend(clientPacket);
        }

        //========================================= LOGIN SERVER ===================================================//

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
                    handleAuthChallenge(PacketLS_GetVersion(event.packet));
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_RECHALLENGE:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_RECHALLENGE -  NOT HANDLED');
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_SERVER_LIST:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_SERVER_LIST');
                    handleServerList(PacketLS_GetServerList(event.packet));
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_GET_SERVER_STATS:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_GET_SERVER_STATS -  NOT HANDLED');
                    break;

                default:
                    trace("_MO_", this, 'UNKNOWN LOGIN PACKET type:', event.packetType);
            }
        }

        /**
         * Take first game server in list and connect to it
         * @param packet
         */
        private function handleServerList(packetServerList: PacketLS_GetServerList): void
        {
            trace("_MO_", this, 'get server list - serverIP:', packetServerList.serverIP, 'serverPort:', packetServerList.serverPort);

            tcpManager.disconnect();
            tcpManager.removeEventListener(TCPCommEvent.PACKET_RECIEVED, packetLS_RecievedHandler);
            tcpManager.addEventListener(TCPCommEvent.PACKET_RECIEVED, packetGS_RecievedHandler);
            tcpManager.serverType = TCPCommManager.SERVER_TYPE_GAME;

            tcpManager.connectWithIPAddress(packetServerList.serverIP, packetServerList.serverPort);

            var loginPacket: PacketGS_PlayerLogin = new PacketGS_PlayerLogin();
            //TODO:get player ID
            loginPacket.playerID = int(Math.random() * 156489);//PLAYER_ID;
            tcpManager.packetSend(loginPacket);
        }

        /**
         * Handle get version
         * @param packet
         */
        private function handleAuthChallenge(versionPacket: PacketLS_GetVersion): void
        {
            trace("_MO_", this, 'get version response - version:', versionPacket.version);
        }


        //=========================================== GAME SERVER ===================================================//

        /**
         * Process packets received from game server
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

                case ClientOpcodes.S_MSG_MATCH_GAME:
                    trace("_MO_", this, 'packet recieved S_MSG_MATCH_GAME');
                    handleMatchGame(event.packet);
                    break;

                case ClientOpcodes.S_MSG_SEND_DATA_TO_CLIENT:
                    trace("_MO_", this, 'packet recieved S_MSG_SEND_DATA_TO_CLIENT - NOT HANDLED YET');
                    handleClientPacket(PacketClientData(event.packet));
                    break;

                case ClientOpcodes.S_MSG_PING:
                    trace("_MO_", this, 'packet recieved S_MSG_PING');
                    handlePingPong(event.packet);
                    break;

                default:
                    trace("_MO_", this, 'UNKNOWN GAME PACKET type:', event.packetType);
            }
        }

        /**
         * Player is logged in
         * @param packet
         */
        private function handleLogonPlayer(packet: PacketBasic): void
        {
            trace("_MO_", this, 'login successfull');
        }

        /**
         * Player is matched with opponent
         * @param packet
         */
        private function handleMatchGame(packet: PacketBasic): void
        {
            var matchGamePacket: PacketGS_MatchGame = PacketGS_MatchGame(packet);

            trace("_MO_", this, 'match game found - opponentID:', matchGamePacket.opponentID, 'status:', matchGamePacket.status);
        }

        /**
         * Ping pong
         * @param packet
         */
        private function handlePingPong(packet: PacketBasic): void
        {
            //trace("_MO_", this, 'ping pong - timestamp:', pingPacket.timestamp);
            tcpManager.packetSend(new PacketGS_PingPong());
            diode.blink();
        }

        //=========================================== CLIENT DATA ===================================================//

        /**
         * Process client packets received from game server
         * @param event
         */
        private function handleClientPacket(packet: PacketClientData): void
        {
            switch (packet.dataType)
            {
                case ClientDataOpcodes.C_MSG_CLIENT_DATA_TURN_START:
                    trace("_MO_", this, 'packet recieved C_MSG_CLIENT_DATA_TURN_START');
                    handleTurnStart(PacketC_TurnStart(packet));
                    break;

                case ClientDataOpcodes.C_MSG_CLIENT_DATA_TURN_TIMEOUT:
                    trace("_MO_", this, 'packet recieved C_MSG_CLIENT_DATA_TURN_TIMEOUT');
                    handleTurnTimeout(PacketC_TurnTimeOut(packet));
                    break;

                case ClientDataOpcodes.C_MSG_CLIENT_DATA_TURN:
                    trace("_MO_", this, 'packet recieved C_MSG_CLIENT_DATA_TURN');
                    handleTurn(PacketC_Turn(packet));
                    break;

                default:
                    trace("_MO_", this, 'UNKNOWN CLIENT PACKET type:', packet.dataType);
            }
        }


        private function handleTurnStart(packetCTurnStart: PacketC_TurnStart): void
        {
            trace("_MO_", this, 'get packetCTurnStart');
        }

        private function handleTurnTimeout(packetCTurnTimeOut: PacketC_TurnTimeOut): void
        {
            trace("_MO_", this, 'get packetCTurnTimeOut');
        }

        private function handleTurn(packetCTurn: PacketC_Turn): void
        {
            trace("_MO_", this, 'get packetCTurn - posX:', packetCTurn.posX, 'posY:', packetCTurn.posY);
        }

    }
}
