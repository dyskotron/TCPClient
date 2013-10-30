package ui
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;

    public class BasicButton extends Sprite
    {
        public static const STATE_OUT: uint = 0;
        public static const STATE_OVER: uint = 1;

        private const MARGIN: int = 10;
        private const WIDTH: int = 140;
        private var tField: TextField;
        private var state: uint = STATE_OUT;

        public function BasicButton(text: String)
        {
            tField = new TextField();
            tField.autoSize = TextFieldAutoSize.LEFT;
            tField.text = text;
            tField.mouseEnabled = false;
            tField.x = (WIDTH - tField.width) / 2;
            tField.y = MARGIN;
            addChild(tField);

            render();
            buttonMode = true;

            this.addEventListener(MouseEvent.MOUSE_OVER, overHandler)
            this.addEventListener(MouseEvent.MOUSE_OUT, outHandler)
        }

        private function outHandler(event: MouseEvent): void
        {
            state = STATE_OUT;
            render();
        }

        private function overHandler(event: MouseEvent): void
        {
            state = STATE_OVER;
            render();
        }

        private function render(): void
        {
            if (state == STATE_OUT)
                graphics.beginFill(0x66ff66);
            else if (state == STATE_OVER)
                graphics.beginFill(0xff6666);

            graphics.lineStyle(2, 0x666666);

            graphics.drawRoundRect(0, 0, WIDTH, tField.height + 2 * MARGIN, MARGIN, MARGIN);
        }
    }
}
