//
//  PacketGS_MatchGame.h
//  TicTacToeOnline2
//
//  Created by Miroslav Kudrnac on 05.09.13.
//
//

#ifndef __TicTacToeOnline2__PacketGS_MatchGame__
#define __TicTacToeOnline2__PacketGS_MatchGame__

class PacketGS_MatchGame : public PacketBasic
{
private:
    typedef PacketBasic T_SUPER;
public:
    PacketGS_MatchGame() : m_opponentID(0) {}
    ~PacketGS_MatchGame() {}
    
    CREATE_BASIC_PACKET_FUNC(PacketGS_MatchGame, C_MSG_MATCH_GAME, S_MSG_MATCH_GAME, ICommunicationListener::onPacketGS_MatchGame, false)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);
    
    CC_SYNTHESIZE(uint64, m_opponentID, OpponentID)
    CC_SYNTHESIZE(uint8, m_status, Status)
};

#endif /* defined(__TicTacToeOnline2__PacketGS_MatchGame__) */
