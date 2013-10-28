//
//  PacketC_Turn.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 9/8/13.
//
//

#include "Headers.h"

void PacketC_Turn::deserialize()
{
    T_SUPER::deserialize();
    
    *m_pBuffer >> m_posX;
    *m_pBuffer >> m_posY;
}

void PacketC_Turn::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{
    ByteBuffer internalBuffer;
    internalBuffer << m_posX;
    internalBuffer << m_posY;
    
    serializeHeader(pCrypt, internalBuffer.size(), pCRC->ComputeCRC32(internalBuffer.contents(), internalBuffer.size()));
    
    m_pBuffer->append(internalBuffer);
}