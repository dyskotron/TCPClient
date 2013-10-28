//
//  PacketGS_MatchGame.cpp
//  TicTacToeOnline2
//
//  Created by Miroslav Kudrnac on 05.09.13.
//
//

#include "Headers.h"

void PacketGS_MatchGame::deserialize()
{
    T_SUPER::deserialize();    
    
    *m_pBuffer >> m_opponentID;
    *m_pBuffer >> m_status;
}

void PacketGS_MatchGame::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{
    serializeHeader(pCrypt, 0, 0);
}