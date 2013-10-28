//
//  PacketC_TurnTimeout.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 9/8/13.
//
//

#ifndef __TicTacToeOnline2__PacketC_TurnTimeout__
#define __TicTacToeOnline2__PacketC_TurnTimeout__

class PacketC_TurnTimeout : public PacketClientData
{
private:
    typedef PacketClientData T_SUPER;
public:
    PacketC_TurnTimeout() {}
    ~PacketC_TurnTimeout() {}
    
    CREATE_CLIENT_PACKET_FUNC(PacketC_TurnTimeout, C_MSG_CLIENT_DATA_TURN_TIMEOUT, ICommunicationListener::onPacketC_TurnTimeout)
    
    void deserialize();
    void serialize(Crypt *pCrypt, CRC_32 *pCRC);
    
};

#endif /* defined(__TicTacToeOnline2__PacketC_TurnTimeout__) */
