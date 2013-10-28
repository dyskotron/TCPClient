//
//  Packets.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/24/13.
//
//

#ifndef __TicTacToeOnline2__Packets__
#define __TicTacToeOnline2__Packets__

using namespace SocketEnums;

static const uint16 C_PACKET_HEADER_SIZE = 8;

enum E_PACKET_TYPE
{
    eptServer = 1,
    eptClient = 2
};

class PacketBasic;
class PacketLS_GetVersion;
class PacketLS_GetServerList;
class PacketGS_PingPong;
class PacketGS_MatchGame;
class PacketGS_PlayerLogin;
class PacketGS_SaveCustomData;
class PacketC_TurnStart;
class PacketC_TurnTimeout;
class PacketC_Turn;

class ICommunicationListener
{
public:
    virtual ~ICommunicationListener() {}
    
    virtual void onPacketLS_Version(PacketLS_GetVersion *pPacket) {}
    virtual void onPacketLS_GetServerList(PacketLS_GetServerList *pPacket) {}
    
    virtual void onPacketGS_Ping(PacketGS_PingPong *pPacket) {}
    virtual void onPacketGS_MatchGame(PacketGS_MatchGame *pPacket) {}
    virtual void onPacketGS_PlayerLogin(PacketGS_PlayerLogin *pPacket) {}
    virtual void onPacketGS_SaveCustomData(PacketGS_SaveCustomData *pPacket) {}
    
    virtual void onPacketC_TurnStart(PacketC_TurnStart *pPacket) {}
    virtual void onPacketC_TurnTimeout(PacketC_TurnTimeout *pPacket) {}
    virtual void onPacketC_Turn(PacketC_Turn *pPacket) {}
};

typedef void (ICommunicationListener::*SEL_PacketListener)(PacketBasic*);

class PacketBasic : public CCObject
{
public:
    PacketBasic();
    virtual ~PacketBasic();
    
    static PacketBasic* create();
    
    virtual void serialize(Crypt *pCrypt, CRC_32 *pCRC) {}
    virtual void deserialize();
    
    uint16 getPacketType()  { return m_type; }
    size_t getSize()        { return m_pBuffer->size(); }
    const uint8 *getData()  { return m_pBuffer->contents(); }
    void setData(const uint8 *pData, size_t size)
    {
        m_pBuffer->clear();
        m_pBuffer->append(pData, size);
    }

    CC_SYNTHESIZE(SEL_PacketListener, m_pListener, Listener)
    CC_SYNTHESIZE(bool, m_bIsMandatoryForUI, IsMandatoryForUI)
    
protected:
    uint16          m_type;
    ByteBuffer*     m_pBuffer;

    
    void serializeHeader(Crypt *pCrypt, uint16 dataSize, uint32 crc32);
};

class PacketClientData : public PacketBasic
{
public:
    PacketClientData() : m_dataType(0) {}
    ~PacketClientData() {}
    static PacketClientData* create();

    void deserialize();
    
    ClientDataOpcodes getPacketDataType() { return (ClientDataOpcodes)m_dataType; }
protected:
    uint8 m_dataType;
    
    void serializeHeader(Crypt *pCrypt, uint16 dataSize, uint32 crc32);
};

#define CREATE_BASIC_PACKET_FUNC(__CLASS__, __CLIENT_TYPE__, __SERVER_TYPE__, __HANDLING_SELECTOR__, __IS_MANDATORY_FOR_UI__) \
static __CLASS__* create(E_PACKET_TYPE type) \
{ \
__CLASS__ *pRet = new __CLASS__(); \
if (pRet) \
{ \
pRet->autorelease(); \
pRet->setListener((SEL_PacketListener)(&__HANDLING_SELECTOR__));   \
pRet->setIsMandatoryForUI(__IS_MANDATORY_FOR_UI__);    \
switch (type)   \
{   \
case eptClient: \
    pRet->m_type = __CLIENT_TYPE__;    \
    break;  \
case eptServer: \
    pRet->m_type = __SERVER_TYPE__;    \
    break;  \
}   \
return pRet; \
} \
else \
{ \
delete pRet; \
pRet = NULL; \
return NULL; \
} \
}

#define CREATE_CLIENT_PACKET_FUNC(__CLASS__, __DATA_TYPE__, __HANDLING_SELECTOR__) \
static __CLASS__* create(E_PACKET_TYPE type) \
{ \
__CLASS__ *pRet = new __CLASS__(); \
if (pRet) \
{ \
pRet->autorelease(); \
pRet->setListener((SEL_PacketListener)(&__HANDLING_SELECTOR__));   \
pRet->setIsMandatoryForUI(true);    \
switch (type)   \
{   \
case eptClient: \
pRet->m_type = C_MSG_SEND_DATA_TO_CLIENT;    \
break;  \
case eptServer: \
pRet->m_type = S_MSG_SEND_DATA_TO_CLIENT;    \
break;  \
}   \
return pRet; \
} \
else \
{ \
delete pRet; \
pRet = NULL; \
return NULL; \
} \
}

#endif /* defined(__TicTacToeOnline2__Packets__) */
