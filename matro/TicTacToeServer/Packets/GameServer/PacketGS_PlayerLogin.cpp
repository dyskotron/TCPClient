//
//  PacketGS_PlayerLogin.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/29/13.
//
//

#include "Headers.h"

PacketGS_PlayerLogin::~PacketGS_PlayerLogin()
{
    safeDelete(m_pUser);
}

void PacketGS_PlayerLogin::serialize(Crypt *pCrypt, CRC_32 *pCRC)
{
    ByteBuffer internalBuffer;
    internalBuffer << m_playerID;
    
    serializeHeader(pCrypt, internalBuffer.size(), pCRC->ComputeCRC32(internalBuffer.contents(), internalBuffer.size()));
    
    m_pBuffer->append(internalBuffer);
}

void PacketGS_PlayerLogin::deserialize()
{
    T_SUPER::deserialize();    
    
    uint32 dataSize;
    uint64 key;
    uint16 recordSize;
    std::map<uint64, ByteBuffer> rDataMap;
    std::map<uint64, ByteBuffer>::iterator itr;    
    
    //get data size
    *m_pBuffer >> dataSize;
    if(dataSize == 0)
        return;
    
    //PlayerStorageKeys
    
    //server sends
    //key|recordSize|record|....Nx
    while(m_pBuffer->rpos() != m_pBuffer->size())
    {
        *m_pBuffer >> key;
        *m_pBuffer >> recordSize;
        //
        ByteBuffer rRecord;
        rRecord.resize(recordSize);
        m_pBuffer->read((uint8*)rRecord.contents(), recordSize);
        //add to map
        rDataMap.insert(std::make_pair(key, rRecord));
    }
    
    //deserialize player profile
    itr = rDataMap.find(E_PLAYER_PROFILE);
    if(itr != rDataMap.end())
    {
        m_pUser = new FacebookUser();
        m_pUser->deserialize(itr->second);
    }
}








