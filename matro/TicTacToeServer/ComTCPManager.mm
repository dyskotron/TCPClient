//
//  ComTCPManager.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/24/13.
//
//

#include "Headers.h"

static const uint16 C_MAXIMUM_BUFFER_SIZE = 4096;

@interface StreamDelegate : NSObject <NSStreamDelegate>
{
@private
    IComTCPManagerDelegate *m_pDelegate;
    
    Crypt*                      m_pCrypt;
    CRC_32*                     m_pCRC32;
    NSInputStream*              m_pInputStream;
    NSOutputStream*             m_pOutputStream;
    CCArray*                    m_pPacketQueueOutgoing;
    
    BOOL                        m_bInputStreamOpened;
    BOOL                        m_bIsStreamReading;
    BOOL                        m_bIsStreamWriting;
    BOOL                        m_bOutputStreamOpened;
    BOOL                        m_bCurrentHeaderDecrypted;

    uint8                       m_tempBuffer[C_MAXIMUM_BUFFER_SIZE];
    uint8                       m_decompressedBuffer[C_MAXIMUM_BUFFER_SIZE];
    int16                       m_currentPositon;
}
-(id)initWithDelegate:(IComTCPManagerDelegate*)delegate;

-(void)connectWithIPAddress:(uint32)ipAddress andPort:(uint32)port;
-(void)connectWithHost:(NSString*)host andPort:(uint32)port;
-(void)disconnect;

// Helpers
-(NSString*)getStringIPFromUInt:(uint32)ipAddress;

-(void)packetSend:(PacketBasic*)packet addToQueue:(BOOL)addToQueue;
-(void)closeStream:(NSStream*)stream;
-(void)processIncommingData:(uint16)decompressedLen;
-(void)checkQueueOutgoing;

@end

@implementation StreamDelegate
// MARK: Lifecycle
-(id)initWithDelegate:(IComTCPManagerDelegate*)delegate
{
    if ((self = [super init]))
    {
        m_pDelegate = delegate;
        
        m_pCrypt = NULL;
        m_pCRC32 = new CRC_32();
        m_pPacketQueueOutgoing = new CCArray();
        
        m_bInputStreamOpened  = NO;
        m_bOutputStreamOpened = NO;
        m_bIsStreamWriting = NO;
        m_bIsStreamReading = NO;
        m_bCurrentHeaderDecrypted = NO;
    }
    
    return self;
}
-(void)dealloc
{
    safeDelete(m_pCRC32);
    safeDelete(m_pCrypt);
    safeRelease(m_pPacketQueueOutgoing);
    
    [super dealloc];
}
// MARK: Public methods
-(void)connectWithIPAddress:(uint32)ipAddress andPort:(uint32)port
{
    NSString *pStringIPAddress = [self getStringIPFromUInt:ipAddress];
    
    [self connectWithHost:pStringIPAddress andPort:port];
}
-(void)connectWithHost:(NSString*)host andPort:(uint32)port
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)host, port, &readStream, &writeStream);
    
    m_currentPositon = 0;
    m_pInputStream = (NSInputStream *)readStream;
    m_pOutputStream = (NSOutputStream *)writeStream;
    [m_pInputStream setDelegate:self];
    [m_pOutputStream setDelegate:self];
    [m_pInputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [m_pOutputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [m_pInputStream open];
    [m_pOutputStream open];
}
-(void)disconnect
{
    [self closeStream:m_pInputStream];
    [self closeStream:m_pOutputStream];

    m_pPacketQueueOutgoing->removeAllObjects();
    m_pDelegate->onDisconnected();
}
// MARK: Helpers
-(NSString*)getStringIPFromUInt:(uint32)ipAddress
{
    in_addr address;
    address.s_addr = ipAddress;
    
    return [NSString stringWithCString:inet_ntoa(address) encoding:NSUTF8StringEncoding];
}
-(void)closeStream:(NSStream *)stream
{
    if (stream)
    {
        [stream close];
        [stream setDelegate:nil];
        [stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        if ([stream isEqual:m_pInputStream])
            m_bInputStreamOpened = NO;
        else if ([stream isEqual:m_pOutputStream])
            m_bOutputStreamOpened = NO;
        if (stream)
        {
            [stream release];
            stream = nil;
        }
    }
}
-(void)packetSend:(PacketBasic*)packet addToQueue:(BOOL)addToQueue
{
    if (m_bInputStreamOpened && m_bOutputStreamOpened && !m_bIsStreamWriting && !m_bIsStreamReading)
    {
        m_bIsStreamWriting = YES;

        packet->serialize(m_pCrypt, m_pCRC32);
        [m_pOutputStream write:packet->getData() maxLength:packet->getSize()];
    }
    else if (addToQueue)
        m_pPacketQueueOutgoing->addObject(packet);
}
-(void)processIncommingData:(uint16)decompressedLen
{
    uint16 currentSize = decompressedLen + m_currentPositon;

    uint16 packetSize   = 0;
    
    // Some data
    if(currentSize)
    {
        if (currentSize > C_MAXIMUM_BUFFER_SIZE)
            assert(false); // overflow
        
        // If we have atleast header or more
        if (currentSize >= C_PACKET_HEADER_SIZE)
        {
            // This can be called more than once. We don't want to change original memory unless we have complete packet.
            if (!m_bCurrentHeaderDecrypted)
            {
                m_bCurrentHeaderDecrypted = YES;
                m_pCrypt->DecryptRecv(m_decompressedBuffer, C_PACKET_HEADER_SIZE);
            }
            
            packetSize = *(uint16*)(&m_decompressedBuffer[0]) + C_PACKET_HEADER_SIZE;
            
            // Unknown packet
            if (!packetSize)
            {
                m_currentPositon = 0;
                m_bIsStreamReading = NO;
                m_bCurrentHeaderDecrypted = NO;
                [self checkQueueOutgoing];
            }
            // We have complete packet or even more.
            else if (currentSize >= packetSize)
            {
                PacketBasic *pPacket = PacketBasic::create();
                pPacket->setData((const uint8*)m_decompressedBuffer, packetSize);
                pPacket->deserialize();
                
                m_currentPositon = 0;
                m_pDelegate->onPacketReceived(pPacket, false);
                m_bIsStreamReading = NO;
                
                m_bCurrentHeaderDecrypted = NO;
                if (currentSize > packetSize)
                {
                    memmove(m_decompressedBuffer, m_decompressedBuffer + packetSize, decompressedLen - packetSize);
                    m_currentPositon = 0;
                    
                    [self processIncommingData:decompressedLen - packetSize];
                }
                else
                    [self checkQueueOutgoing];
            }

        }
        // Some part is missing. Mark readed memory and wait for rest.
        else
            m_currentPositon = currentSize;
        
    }
}
-(void)checkQueueOutgoing
{
    PacketBasic *lastPacket = NULL;
    if (m_bInputStreamOpened && m_bOutputStreamOpened && !m_bIsStreamWriting && !m_bIsStreamReading && m_pPacketQueueOutgoing->count())
    {
        lastPacket = (PacketBasic*)m_pPacketQueueOutgoing->lastObject();
        lastPacket->retain();
        m_pPacketQueueOutgoing->removeLastObject();
        [self packetSend:lastPacket addToQueue:NO];
        lastPacket->release();
    }
}
// MARK: NSStreamDelegate
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch (eventCode)
    {
		case NSStreamEventOpenCompleted:
        {
            if ([aStream isEqual:m_pInputStream])
                m_bInputStreamOpened = YES;
            if ([aStream isEqual:m_pOutputStream])
                m_bOutputStreamOpened = YES;
            
            if (m_bInputStreamOpened && m_bOutputStreamOpened)
            {
                safeDelete(m_pCrypt);
                m_pCrypt = new Crypt();
                
                m_pDelegate->onConnected();
            }
            
            [self performSelectorOnMainThread:@selector(checkQueueOutgoing) withObject:nil waitUntilDone:NO];
        }break;
		case NSStreamEventHasBytesAvailable:
        {
			if (aStream == m_pInputStream)
            {
                m_bIsStreamReading = YES;
                
				int16_t decompressedLen = 0;
                
                decompressedLen = [m_pInputStream read:m_tempBuffer maxLength:C_MAXIMUM_BUFFER_SIZE];
                if (decompressedLen)
                {
                    // Fill buffer with current data
                    if (m_currentPositon + decompressedLen < C_MAXIMUM_BUFFER_SIZE)
                        memcpy(m_decompressedBuffer + m_currentPositon, m_tempBuffer, decompressedLen);
                    else
                    {
                        // Overflow
                        assert(false);
                    }
                    
                    [self processIncommingData:decompressedLen];
                }
            }
        }break;
        case NSStreamEventHasSpaceAvailable:
        {
            m_bIsStreamWriting = NO;
            [self checkQueueOutgoing];
        }break;
		case NSStreamEventErrorOccurred:
		{
            m_pDelegate->onStreamError([aStream.streamError.description cStringUsingEncoding:NSUTF8StringEncoding]);
        }break;
		case NSStreamEventEndEncountered:
        {
            [self disconnect];
		}break;
		default:
            CCLOG("Unknown event %i", eventCode);
	}
}
@end

// This is ugly as shit :D
StreamDelegate *m_pStreamDelegate = NULL;

// MARK: Lifecycle
ComTCPManager::ComTCPManager(IComTCPManagerDelegate *pDelegate) :
m_pComTCPManagerDelegate(NULL)
{
    m_pComTCPManagerDelegate = pDelegate;
    m_pStreamDelegate = [[StreamDelegate alloc] initWithDelegate:this];
}
ComTCPManager::~ComTCPManager()
{
    [m_pStreamDelegate release];
    m_pStreamDelegate = NULL;
}

// MARK: Public methods
void ComTCPManager::connectWithIPAddress(uint32 ipAddress, uint32 port)
{
    [m_pStreamDelegate connectWithIPAddress:ipAddress andPort:port];
}
void ComTCPManager::connectWithHost(const char *pHost, uint32 port)
{
    NSString *pHostNSString = [NSString stringWithUTF8String:pHost];
    
    [m_pStreamDelegate connectWithHost:pHostNSString andPort:port];
}
void ComTCPManager::disconnect()
{
    [m_pStreamDelegate disconnect];
}
void ComTCPManager::sendPacket(PacketBasic* pPacket)
{
    [m_pStreamDelegate packetSend:pPacket addToQueue:YES];
}

// MARK: IComTCPManagerDelegate
void ComTCPManager::onPacketReceived(PacketBasic *pPacket, bool isFromQueue)
{
    m_pComTCPManagerDelegate->onPacketReceived(pPacket, isFromQueue);
}
void ComTCPManager::onConnected()
{
    m_pComTCPManagerDelegate->onConnected();
}
void ComTCPManager::onDisconnected()
{
    m_pComTCPManagerDelegate->onDisconnected();
}
void ComTCPManager::onStreamError(const char *pError)
{
    m_pComTCPManagerDelegate->onStreamError(pError);
}