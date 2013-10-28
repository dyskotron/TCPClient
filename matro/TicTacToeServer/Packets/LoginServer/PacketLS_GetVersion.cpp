//
//  PacketLS_GetVersion.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/30/13.
//
//

#include "Headers.h"

void PacketLS_GetVersion::deserialize()
{
    T_SUPER::deserialize();
    
    *m_pBuffer >> m_version;
}

void PacketLS_GetVersion::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{    
    serializeHeader(pCrypt, 0, 0);
}