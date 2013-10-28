//
//  PacketGS_PingPong.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/30/13.
//
//

#ifndef __TicTacToeOnline2__PacketGS_PingPong__
#define __TicTacToeOnline2__PacketGS_PingPong__

class PacketGS_PingPong : public PacketBasic
{
private:
    typedef PacketBasic T_SUPER;
public:
    PacketGS_PingPong() : m_timestamp(0) {}
    ~PacketGS_PingPong() {}
    
    CREATE_BASIC_PACKET_FUNC(PacketGS_PingPong, C_MSG_PONG, S_MSG_PING, ICommunicationListener::onPacketGS_Ping, false)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);

    CC_SYNTHESIZE(uint64, m_timestamp, Timestamp)
};

#endif /* defined(__TicTacToeOnline2__PacketGS_PingPong__) */
