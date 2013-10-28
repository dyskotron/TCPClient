package
{

    import flash.display.Sprite;
    import flash.events.MouseEvent;

    import server.TCPCommManager;

    import utils.BitwiseCalc;

    public class VladoServerTest extends Sprite
    {
        private var bitwiseCalculator: BitwiseCalc;

        private static const LOGIN_SERVER_IP: uint = 3919800155;
        private static const LOGIN_SERVER_PORT: uint = 9339;

        private var tcpManager: TCPCommManager;


        private static const CRYPT_KEY: String = 'T2%o9^24C2r14}:p63zU';


        public function VladoServerTest()
        {
            trace("_MO_", this, 'START');

            tcpManager = new TCPCommManager();
            tcpManager.connectWithIPAddress(LOGIN_SERVER_IP, LOGIN_SERVER_PORT);

            //bitwiseCalculator = new BitwiseCalc();
            //addChild(bitwiseCalculator);

            graphics.beginFill(0x004488);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            addEventListener(MouseEvent.CLICK, mouseClickListener);

        }

        private function mouseClickListener(event: MouseEvent): void
        {

        }

    }
}
