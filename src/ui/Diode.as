package ui
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.filters.GlowFilter;

    public class Diode extends Sprite
    {
        private static const SIZE: uint = 4;

        private var lightIntensity: Number = 0;
        private var blinking: Boolean = false;
        private var glowFilter: GlowFilter;

        public function Diode()
        {
            graphics.beginFill(0xFF0000);
            graphics.drawCircle(0, 0, SIZE);

            glowFilter = new GlowFilter(0xFF0000, 1);
            filters = [glowFilter];
            alpha = 0;
        }

        public function blink()
        {

            lightIntensity = 1;
            if (!blinking)
                addEventListener(Event.ENTER_FRAME, enterFrameHandler);

            blinking = true;
        }

        private function enterFrameHandler(event: Event): void
        {
            lightIntensity -= 0.05;
            alpha = lightIntensity;


            if (lightIntensity <= 0)
            {
                lightIntensity = 0;
                removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
                blinking = false;
            }
        }
    }
}
