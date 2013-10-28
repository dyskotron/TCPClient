//
//  ComTCPManager.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/24/13.
//
//

#ifndef __TicTacToeOnline2__ComTCPManager__
#define __TicTacToeOnline2__ComTCPManager__

class IComTCPManagerDelegate
{
public:
    virtual ~IComTCPManagerDelegate() {};

    virtual void onConnected() = 0;
    virtual void onDisconnected() = 0;
    virtual void onPacketReceived(PacketBasic *pPacket, bool isFromQueue) = 0;
    virtual void onStreamError(const char *pError) = 0;
};

class ComTCPManager : public IComTCPManagerDelegate
{
public:
    ComTCPManager(IComTCPManagerDelegate *pDelegate);
    ~ComTCPManager();
    
    void connectWithIPAddress(uint32 ipAddress, uint32 port);
    void connectWithHost(const char *pHost, uint32 port);
    void disconnect();
    void sendPacket(PacketBasic* pPacket);

    
    // IComTCPManagerDelegate ObjC cross C++ bridge
    void onPacketReceived(PacketBasic *pPacket, bool isFromQueue);
    void onConnected();
    void onDisconnected();
    void onStreamError(const char *pError);
    
protected:
    IComTCPManagerDelegate *m_pComTCPManagerDelegate;
};

#endif /* defined(__TicTacToeOnline2__ComTCPManager__) */
