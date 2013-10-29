package
{

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import server.TCPCommManager;
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
            tcpManager.connectWithIPAddress(LOGIN_SERVER_IP, LOGIN_SERVER_PORT);
            tcpManager.packetSend(new PacketLS_GetVersion());
            tcpManager.packetSend(new PacketLS_GetServerList(GameServerTypes.E_TIC_TAC_TOE));

        }

        private function mouseClickListener(event: MouseEvent): void
        {

        }

    }
}
