//
//  PacketGS_PingPong.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/30/13.
//
//

#include "Headers.h"

void PacketGS_PingPong::deserialize()
{
    T_SUPER::deserialize();
    
    *m_pBuffer >> m_timestamp;

}

void PacketGS_PingPong::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{
    ByteBuffer internalBuffer;
    internalBuffer << m_timestamp;
    
    serializeHeader(pCrypt, internalBuffer.size(), pCRC->ComputeCRC32(internalBuffer.contents(), internalBuffer.size()));
    
    m_pBuffer->append(internalBuffer);
}
