//
//  PacketC_TurnStart.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 9/8/13.
//
//

#ifndef __TicTacToeOnline2__PacketC_TurnStart__
#define __TicTacToeOnline2__PacketC_TurnStart__

class PacketC_TurnStart : public PacketClientData
{
private:
    typedef PacketClientData T_SUPER;
public:
    PacketC_TurnStart() {}
    ~PacketC_TurnStart() {}
    
    CREATE_CLIENT_PACKET_FUNC(PacketC_TurnStart, C_MSG_CLIENT_DATA_TURN_START, ICommunicationListener::onPacketC_TurnStart)

    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);
    
};

#endif /* defined(__TicTacToeOnline2__PacketC_TurnStart__) */
