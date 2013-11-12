package ui
{
    import flash.display.Sprite;
    import flash.text.TextField;
    import flash.text.TextFormat;

    public class LoggerView extends Sprite
    {
        private var textfield: TextField;

        public function LoggerView(width: Number, height: Number)
        {
            textfield = new TextField();
            textfield.text
            textfield.multiline = true;
            textfield.width = width;
            textfield.height = height;

            this.mouseEnabled = this.mouseChildren = false;

            addChild(textfield);
        }

        public function set align(value: String): void
        {
            var txtForm: TextFormat = textfield.getTextFormat();
            txtForm.align = value;
            textfield.setTextFormat(txtForm);
            textfield.defaultTextFormat = txtForm;
        }

        public function log(message: String): void
        {
            textfield.text = message + "\n" + textfield.text;
        }
    }
}
