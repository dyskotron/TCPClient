//
//  PacketGS_SaveCustomData.cpp
//  TicTacToeOnline2
//
//  Created by Miroslav Kudrnac on 05.09.13.
//
//

#include "Headers.h"

void PacketGS_SaveCustomData::deserialize()
{
    T_SUPER::deserialize();
}

void PacketGS_SaveCustomData::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{
    ByteBuffer internalBuffer;
    internalBuffer << m_key;
    internalBuffer.append(m_rData);
    
    serializeHeader(pCrypt, internalBuffer.size(), pCRC->ComputeCRC32(internalBuffer.contents(), internalBuffer.size()));
    
    m_pBuffer->append(internalBuffer);
}