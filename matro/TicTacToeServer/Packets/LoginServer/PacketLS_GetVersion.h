//
//  PacketLS_GetVersion.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/30/13.
//
//

#ifndef __TicTacToeOnline2__PacketLS_GetVersion__
#define __TicTacToeOnline2__PacketLS_GetVersion__

class PacketLS_GetVersion : public PacketBasic
{
private:
    typedef PacketBasic T_SUPER;
public:    
    PacketLS_GetVersion() : m_version(0) {}
    ~PacketLS_GetVersion() {}
    
    CREATE_BASIC_PACKET_FUNC(PacketLS_GetVersion, C_MSG_AUTH_CHALLENGE, S_MSG_AUTH_CHALLENGE, ICommunicationListener::onPacketLS_Version, false)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);

    CC_SYNTHESIZE(uint32, m_version, Version)
};

#endif /* defined(__TicTacToeOnline2__PacketLS_GetVersion__) */
