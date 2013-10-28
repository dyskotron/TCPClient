//
//  PacketC_Turn.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 9/8/13.
//
//

#ifndef __TicTacToeOnline2__PacketC_Turn__
#define __TicTacToeOnline2__PacketC_Turn__

class PacketC_Turn : public PacketClientData
{
private:
    typedef PacketClientData T_SUPER;
public:
    PacketC_Turn() {}
    ~PacketC_Turn() {}
    
    CREATE_CLIENT_PACKET_FUNC(PacketC_Turn, C_MSG_CLIENT_DATA_TURN, ICommunicationListener::onPacketC_Turn)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);
  
    CC_SYNTHESIZE(uint8, m_posX, PosX)
    CC_SYNTHESIZE(uint8, m_posY, PosY)

};

#endif /* defined(__TicTacToeOnline2__PacketC_Turn__) */
