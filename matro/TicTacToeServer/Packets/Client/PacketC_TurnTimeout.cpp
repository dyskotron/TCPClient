//
//  PacketC_TurnTimeout.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 9/8/13.
//
//

#include "Headers.h"

void PacketC_TurnTimeout::deserialize()
{
    T_SUPER::deserialize();
    
}

void PacketC_TurnTimeout::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{
    serializeHeader(pCrypt, 0, 0);
}