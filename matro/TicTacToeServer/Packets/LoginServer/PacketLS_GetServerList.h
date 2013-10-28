//
//  PacketLS_GetServerList.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/30/13.
//
//

#ifndef __TicTacToeOnline2__PacketLS_GetServerList__
#define __TicTacToeOnline2__PacketLS_GetServerList__

class PacketLS_GetServerList : public PacketBasic
{
private:
    typedef PacketBasic T_SUPER;
public:   
    PacketLS_GetServerList() : m_serverType(0), m_serverIP(0), m_serverPort(0) {}
    ~PacketLS_GetServerList() {}
    
    CREATE_BASIC_PACKET_FUNC(PacketLS_GetServerList, C_MSG_AUTH_SERVER_LIST, S_MSG_AUTH_SERVER_LIST, ICommunicationListener::onPacketLS_GetServerList, false)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);
    
    CC_SYNTHESIZE(uint32, m_serverType, ServerType)
    CC_SYNTHESIZE(uint32, m_serverIP, ServerIP)
    CC_SYNTHESIZE(uint32, m_serverPort, ServerPort)
};

#endif /* defined(__TicTacToeOnline2__PacketLS_GetServerList__) */
