//
//  PacketGS_PlayerLogin.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/29/13.
//
//

#ifndef __TicTacToeOnline2__PacketGS_PlayerLogin__
#define __TicTacToeOnline2__PacketGS_PlayerLogin__

class FacebookUser;

class PacketGS_PlayerLogin : public PacketBasic
{
private:
    typedef PacketBasic T_SUPER;
public:
    PacketGS_PlayerLogin() : m_playerID(0), m_pUser(NULL) {}
    ~PacketGS_PlayerLogin();
    
    CREATE_BASIC_PACKET_FUNC(PacketGS_PlayerLogin, C_MSG_AUTH_CHALLENGE, S_MSG_AUTH_CHALLENGE, ICommunicationListener::onPacketGS_PlayerLogin, false)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);

    CC_SYNTHESIZE(uint64, m_playerID, PlayerID)
    CC_SYNTHESIZE(FacebookUser*, m_pUser, User)
};

#endif /* defined(__TicTacToeOnline2__PacketGS_PlayerLogin__) */
