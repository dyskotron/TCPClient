//
//  Packets.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/24/13.
//
//

#include "Headers.h"

PacketBasic::PacketBasic() :
m_type(0),
m_pBuffer(NULL),
m_pListener(NULL)
{
    m_pBuffer = new ByteBuffer();
}
PacketBasic::~PacketBasic()
{
    safeDelete(m_pBuffer);
}
PacketBasic* PacketBasic::create()
{
    PacketBasic *pRet = new PacketBasic();
    pRet->autorelease();
    
    return pRet;
}

// MARK: Public methods
void PacketBasic::deserialize()
{
    uint16 size = 0;
    uint32 crc  = 0;
    
    *m_pBuffer >> size >> m_type >> crc;
}
// MARK: Helpers
void PacketBasic::serializeHeader(Crypt *pCrypt, uint16 dataSize, uint32 crc32)
{
    *m_pBuffer << dataSize;
    *m_pBuffer << m_type;
    *m_pBuffer << crc32;
    
    pCrypt->EncryptSend((uint8 *)m_pBuffer->contents(), C_PACKET_HEADER_SIZE);
}

// MARK: PacketClientData
PacketClientData* PacketClientData::create()
{
    PacketClientData *pRet = new PacketClientData();
    pRet->autorelease();
    
    return pRet;
}
void PacketClientData::deserialize()
{
    PacketBasic::deserialize();
    
    *m_pBuffer >> m_dataType;
}
void PacketClientData::serializeHeader(Crypt *pCrypt, uint16 dataSize, uint32 crc32)
{
    PacketBasic::serializeHeader(pCrypt, dataSize, crc32);
    
    *m_pBuffer << m_dataType;

}
