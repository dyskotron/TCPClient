//
//  PacketLS_GetServerList.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/30/13.
//
//

#include "Headers.h"

void PacketLS_GetServerList::deserialize()
{
    T_SUPER::deserialize();
    
    *m_pBuffer >> m_serverIP;
    *m_pBuffer >> m_serverPort;
}

void PacketLS_GetServerList::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{   
    ByteBuffer internalBuffer;
    internalBuffer << m_serverType;
    
    serializeHeader(pCrypt, internalBuffer.size(), pCRC->ComputeCRC32(internalBuffer.contents(), internalBuffer.size()));
    
    m_pBuffer->append(internalBuffer);
}
