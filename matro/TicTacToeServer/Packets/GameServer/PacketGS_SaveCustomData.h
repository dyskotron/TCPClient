//
//  PacketGS_SaveCustomData.h
//  TicTacToeOnline2
//
//  Created by Miroslav Kudrnac on 05.09.13.
//
//

#ifndef __TicTacToeOnline2__PacketGS_SaveCustomData__
#define __TicTacToeOnline2__PacketGS_SaveCustomData__

class PacketGS_SaveCustomData : public PacketBasic
{
private:
    typedef PacketBasic T_SUPER;
public:
    PacketGS_SaveCustomData() : m_key(0) {}
    ~PacketGS_SaveCustomData() {}
    
    CREATE_BASIC_PACKET_FUNC(PacketGS_SaveCustomData, C_MSG_SAVE_CUSTOM_DATA, S_MSG_SAVE_CUSTOM_DATA, ICommunicationListener::onPacketGS_SaveCustomData, false)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);
    
    CC_SYNTHESIZE(uint64, m_key, Key)
    CC_SYNTHESIZE(ByteBuffer, m_rData, UserData)
};

#endif /* defined(__TicTacToeOnline2__PacketGS_SaveCustomData__) */
