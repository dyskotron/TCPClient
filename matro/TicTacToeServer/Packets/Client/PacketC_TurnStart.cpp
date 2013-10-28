//
//  PacketC_TurnStart.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 9/8/13.
//
//

#include "Headers.h"

void PacketC_TurnStart::deserialize()
{
    T_SUPER::deserialize();

}

void PacketC_TurnStart::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{
    serializeHeader(pCrypt, 0, 0);
}