package server
{
    import flash.events.Event;

    import server.packets.PacketBasic;

    public class TCPCommEvent extends Event
    {
        public static const PACKET_RECIEVED: String = "packetRecieved";

        private var _packet: PacketBasic;
        private var _packetType: uint;

        public function TCPCommEvent(type: String, packet: PacketBasic, packetType: uint, bubbles: Boolean = false, cancelable: Boolean = false)
        {
            _packet = packet;
            _packetType = packetType;
            super(type, bubbles, cancelable);
        }

        override public function clone(): Event
        {
            return new TCPCommEvent(type, _packet, _packetType, bubbles, cancelable)
        }

        public function get packet(): PacketBasic
        {
            return _packet;
        }

        public function get packetType(): uint
        {
            return _packetType;
        }
    }
}