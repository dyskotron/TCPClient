package utils
{
    import flash.display.Sprite;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFieldType;

    public class BitwiseCalc extends Sprite
    {
        private static const OP_SHIFT_LEFT: uint = 1;
        private static const OP_SHIFT_RIGHT: uint = 2;

        private var inputTextField: TextField;
        private var shiftTextField: TextField;
        private var resultTextField: TextField;
        private var leftShiftButton: TextField;
        private var rightShiftButton: TextField;

        private var inputTextFieldDec: TextField;
        private var shiftTextFieldDec: TextField;
        private var resultTextFieldDec: TextField;

        private var operator: uint = OP_SHIFT_LEFT;

        function BitwiseCalc()
        {
            inputTextField = createTextField();
            leftShiftButton = createTextField(">>", TextFieldType.DYNAMIC, 40);
            rightShiftButton = createTextField("<<", TextFieldType.DYNAMIC, 40);
            shiftTextField = createTextField();
            resultTextField = createTextField("=", TextFieldType.DYNAMIC, 150);

            inputTextField.x = 10;
            leftShiftButton.x = inputTextField.x + inputTextField.width;
            rightShiftButton.x = leftShiftButton.x + leftShiftButton.width;
            shiftTextField.x = rightShiftButton.x + rightShiftButton.width;
            resultTextField.x = shiftTextField.x + shiftTextField.width;

            leftShiftButton.addEventListener(MouseEvent.CLICK, leftShiftButton_clickHandler);
            rightShiftButton.addEventListener(MouseEvent.CLICK, rightShiftButton_clickHandler);


            inputTextFieldDec = createTextField("", TextFieldType.DYNAMIC, 120);
            shiftTextFieldDec = createTextField("", TextFieldType.DYNAMIC, 120);
            resultTextFieldDec = createTextField("", TextFieldType.DYNAMIC, 150);

            inputTextFieldDec.x = inputTextField.x;
            shiftTextFieldDec.x = shiftTextField.x;
            resultTextFieldDec.x = resultTextField.x;

            inputTextFieldDec.y = inputTextField.y + 20;
            shiftTextFieldDec.y = shiftTextField.y + 20;
            resultTextFieldDec.y = resultTextField.y + 20;

            /**
             trace("_MO_", this, c, uint(c).toString(2));


             //parseInt(String(111), 2);  */
        }

        private function createTextField(text: String = '', type: String = TextFieldType.INPUT, width: int = 120, isButton: Boolean = false): TextField
        {
            var textField: TextField = new TextField();
            textField.width = width;
            textField.height = 20;
            textField.type = type;
            textField.border = true;
            textField.borderColor = 0xff0000;
            textField.text = text;

            if (type != TextFieldType.INPUT)
            {
                textField.selectable = false;
            }

            if (isButton)
            {
                var sprite: Sprite = new Sprite();
                addChild(sprite);
                sprite.addChild(textField);
                sprite.buttonMode = true;
                sprite.useHandCursor = true;
            }
            else
            {
                addChild(textField);
            }


            return textField;
        }

        private function leftShiftButton_clickHandler(event: MouseEvent): void
        {
            operator = OP_SHIFT_LEFT;
            update()
        }

        private function rightShiftButton_clickHandler(event: MouseEvent): void
        {
            operator = OP_SHIFT_RIGHT;
            update()
        }

        private function update(): void
        {
            var inputValue: uint = parseInt(inputTextField.text, 2);
            var shiftValue: uint = parseInt(shiftTextField.text, 2);

            var result: uint;

            switch (operator)
            {
                case OP_SHIFT_LEFT:
                    result = inputValue << shiftValue;
                    break;
                case OP_SHIFT_RIGHT:
                    result = inputValue >> shiftValue;
                    break;
            }

            resultTextField.text = uint(result).toString(2);

            inputTextFieldDec.text = inputValue.toString();
            shiftTextFieldDec.text = shiftValue.toString();
            resultTextFieldDec.text = result.toString();
        }
    }
}
