//
//  CMain.h
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/24/13.
//
//

#ifndef __TicTacToeOnline2__CMain__
#define __TicTacToeOnline2__CMain__

extern const char *C_APPLICATION_NAME;
extern const char *C_DEFAULT_FONT;

enum E_SERVER_TYPE
{
    estNil = 0,
    estLogin = 1,
    estGame = 2
};

enum E_CONNECTION_STATUS
{
    ecsDisconnected = 0,
    ecsConnecting   = 1,
    ecsConnected    = 2
};

enum E_DEVICE_TYPE
{
    edtNil = 0,
    edtiPhone1G = 1,
    edtiPhone3G = 2,
    edtiPhone3GS = 3,
    edtiPhone4 = 4,
    edtVerizoniPhone4 = 5,
    edtiPhone4S = 6,
    edtiPodTouch1G = 7,
    edtiPodTouch2G = 8,
    edtiPodTouch3G = 9,
    edtiPodTouch4G = 10,
    edtiPad = 11,
    edtiPad2WiFi = 12,
    edtiPad2GSM = 13,
    edtiPad2CDMA = 14,
    edtSimulator = 15,
    edtiPad3Wifi = 16,
    edtiPad3GSM = 17,
    edtiPad3CDMA = 18,
    edtiPadMini = 19,
    edtUnknown = 20,
    edtiPhone5GSMCDMA = 21,
    edtiPhone5GSM = 22,
    edtiPodTouch5G = 23,
    edtiPad2 = 24,
    edtiPadMiniWifi = 25,
    edtiPadMiniGSM = 26,
    edtiPad4Wifi = 27,
    edtiPad4GSM = 28,
    edtiPad4GSMCDMA = 29,
    edtAndroid = 30
};

class IGeneralNotification
{
public:
    // Facebook
    virtual void onFBSessionLoggedIn() {}
    virtual void onFBSessionDidNotLogin() {}
    virtual void onFBSessionLoggedOut() {}
    virtual void onFBSessionInvalidate() {}
    virtual void onFBSessionError(const char *pErrorDesc, int errorCode) {}
    virtual void onFBUserDownloadOk() {}
    virtual void onFBUserDownloadError(const char *pErrorDesc, int errorCode) {}
    virtual void onFBCheckNotifications() {}
    virtual void onFBCredentialsReloadFailed() {}
    virtual void onFBUserListOk() {}
    virtual void onFBUserListError(const char *pErrorDesc, int errorCode) {}
    
    // Internet connection
    virtual void onGEInternetStatusChangedOnline() {}
    virtual void onGEInternetStatusChangedOffline() {}
};


class CMain : public CCObject, public IComTCPManagerDelegate, public IGeneralNotification, public ICommunicationListener
{
public:
    CMain();
    ~CMain();

    void initMain();
    
    void login();
    void sendMatchGame();
    
    void setCommunicationListener(ICommunicationListener *pListener);
    void setNotificationListener(IGeneralNotification *pListener)       { m_pNotificationListener = pListener; }
    
    static CMain                *sharedMain()                           { return m_pMain; }
    FacebookKit                 *getFacebookKit()                       { return m_pFacebookKit; }
    static bool                 getIsRunningOnIpad()                    { return CCApplication::sharedApplication()->getTargetPlatform() == kTargetIpad; }
    static float                getFontSize(float fontSize);
    static E_DEVICE_TYPE        getDeviceType();
    
    // IGeneralNotification
    void onFBSessionLoggedIn();
    void onFBSessionDidNotLogin();
    void onFBSessionLoggedOut();
    void onFBSessionInvalidate();
    void onFBSessionError(const char *pErrorDesc, int errorCode);
    void onFBUserDownloadOk();
    void onFBUserDownloadError(const char *pErrorDesc, int errorCode);
    void onFBCheckNotifications();
    void onFBCredentialsReloadFailed();
    void onFBUserListOk();
    void onFBUserListError(const char *pErrorDesc, int errorCode);
    void onGEInternetStatusChangedOnline();
    void onGEInternetStatusChangedOffline();
    
    //ICommunicationListener
    void onPacketLS_Version(PacketLS_GetVersion *pPacket);
    void onPacketLS_GetServerList(PacketLS_GetServerList *pPacket);
    void onPacketGS_Ping(PacketGS_PingPong *pPacket);
    void onPacketGS_MatchGame(PacketGS_MatchGame *pPacket);
    void onPacketGS_PlayerLogin(PacketGS_PlayerLogin *pPacket);
    void onPacketGS_SaveCustomData(PacketGS_SaveCustomData *pPacket);
    void onPacketC_TurnStart(PacketC_TurnStart *pPacket);
    void onPacketC_TurnTimeout(PacketC_TurnTimeout *pPacket);
    void onPacketC_Turn(PacketC_Turn *pPacket);
private:
    static CMain                *m_pMain;
    static E_DEVICE_TYPE        m_DeviceType;
    
    FacebookKit                 *m_pFacebookKit;
    ComTCPManager               *m_pCommunicationManager;
    
    IGeneralNotification        *m_pNotificationListener;
    
    ICommunicationListener      *m_pCommunicationListener;
    CCArray                     *m_pCommunicationQueue;

    E_CONNECTION_STATUS         m_eConnectionStatus;
    E_SERVER_TYPE               m_eCurrentServer;
    
    void initResolutionAndResource();
    void initFileSystem();
    void onPacketReceivedLogin(PacketBasic *pPacket, bool isFromQueue);
    void onPacketReceivedGame(PacketBasic *pPacket, bool isFromQueue);
    void onPacketReceivedClient(PacketBasic *pPacket, bool isFromQueue);
    bool isComListening(PacketBasic *pPacket, bool isFromQueue);
        
    template<class T>
    void proccessPacket(PacketBasic *pPacket, bool isFromQueue)
    {
        T *pPacketSpecific = T::create(eptServer);
        pPacketSpecific->setData(pPacket->getData(), pPacket->getSize());
        pPacketSpecific->deserialize();
        
        if (!isFromQueue)
            (void)(this->*(pPacketSpecific->getListener()))(pPacketSpecific);
        
        if (isComListening(pPacketSpecific, pPacketSpecific->getIsMandatoryForUI() && !isFromQueue))
            (void)(m_pCommunicationListener->*(pPacketSpecific->getListener()))(pPacketSpecific);
    }
    
protected:
    
    void onConnected();
    void onDisconnected();
    void onPacketReceived(PacketBasic *pPacket, bool isFromQueue);
    void onStreamError(const char *pError);
};

#endif /* defined(__TicTacToeOnline2__CMain__) */
