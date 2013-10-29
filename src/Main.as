package
{

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import server.TCPCommEvent;
    import server.TCPCommManager;
    import server.packets.enumAlts.AuthPacketOpcodes;
    import server.packets.enumAlts.GameServerTypes;
    import server.packets.loginServer.PacketLS_GetServerList;
    import server.packets.loginServer.PacketLS_GetVersion;

    public class Main extends Sprite
    {
        private static const LOGIN_SERVER_IP: uint = 3919800155;
        private static const LOGIN_SERVER_PORT: uint = 9339;

        private var tcpManager: TCPCommManager;

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

        private function packetRecievedHandler(event: TCPCommEvent): void
        {
            switch (event.packetType)
            {
                case AuthPacketOpcodes.S_MSG_AUTH_CHALLENGE:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_CHALLENGE');
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_RECHALLENGE:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_RECHALLENGE');
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_SERVER_LIST:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_SERVER_LIST');
                    var packetServerList: PacketLS_GetServerList = PacketLS_GetServerList(event.packet);
                    tcpManager.disconnect();
                    tcpManager.connectWithIPAddress(packetServerList.serverIP, packetServerList.serverPort);
                    break;

                case AuthPacketOpcodes.S_MSG_AUTH_GET_SERVER_STATS:
                    trace("_MO_", this, 'packet recieved S_MSG_AUTH_GET_SERVER_STATS');
                    break;
            }
        }

        private function mouseClickListener(event: MouseEvent): void
        {

        }

    }
}
