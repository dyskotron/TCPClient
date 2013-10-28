//
//  CMain.cpp
//  TicTacToeOnline2
//
//  Created by Vladislav Vesely on 8/24/13.
//
//

#include "Headers.h"

const char *C_APPLICATION_NAME                          = "Tic Tac Toe Online 2";
const char *C_DEFAULT_FONT                              = "HelveticaNeue-Light";

static const CCSize C_SCREEN_SIZE_IPHONE                = CCSize(320, 480);
static const CCSize C_SCREEN_SIZE_IPHONE_RETINA_35      = CCSize(640, 960);
static const CCSize C_SCREEN_SIZE_IPHONE_RETINA_4       = CCSize(640, 1136);
static const CCSize C_SCREEN_SIZE_IPAD                  = CCSize(768, 1024);
static const CCSize C_SCREEN_SIZE_IPAD_RETINA           = CCSize(1536, 2048);

CMain * CMain::m_pMain = new CMain();
E_DEVICE_TYPE CMain::m_DeviceType = edtNil;

// MARK: Lifecycle
CMain::CMain() :
m_eCurrentServer(estNil),
m_eConnectionStatus(ecsDisconnected),
m_pCommunicationQueue(NULL),
m_pCommunicationListener(NULL),
m_pNotificationListener(NULL)
{
    
}
CMain::~CMain()
{
    safeRelease(m_pCommunicationQueue);
    safeDelete(m_pFacebookKit);
    safeDelete(m_pCommunicationManager);
}
// MARK: Public methods
void CMain::initMain()
{    
    m_pCommunicationQueue = new CCArray();
    m_pFacebookKit = new FacebookKit();
    m_pCommunicationManager = new ComTCPManager(this);
    
    initResolutionAndResource();
    initFileSystem();
    
    // PVR opacity. We use premultiplied alpha.
    CCTexture2D::PVRImagesHavePremultipliedAlpha(true);
}

void CMain::login()
{
    m_eCurrentServer = estLogin;
    m_eConnectionStatus = ecsConnecting;
    m_pCommunicationManager->connectWithIPAddress(3919800155, 9339); // TODO: Ip address
    
    PacketLS_GetVersion *pPacketVersion = PacketLS_GetVersion::create(eptClient);
    PacketLS_GetServerList *pPacketServerList = PacketLS_GetServerList::create(eptClient);
    pPacketServerList->setServerType(E_TIC_TAC_TOE);

    m_pCommunicationManager->sendPacket(pPacketVersion);
    m_pCommunicationManager->sendPacket(pPacketServerList);
}

void CMain::sendMatchGame()
{
    PacketGS_MatchGame *pPacket = PacketGS_MatchGame::create(eptClient);
    m_pCommunicationManager->sendPacket(pPacket);
}

void CMain::setCommunicationListener(ICommunicationListener *pListener)
{
    if (pListener == m_pCommunicationListener)
        return;
    
    m_pCommunicationListener = pListener;
    
    if (!m_pCommunicationListener)
        return;
    
    if (m_pCommunicationQueue->count())
    {
        PacketBasic *pLoopPacket;
        FOREACH(m_pCommunicationQueue, pLoopPacket, PacketBasic*)
        {
            onPacketReceived(pLoopPacket, true);
        }
        m_pCommunicationQueue->removeAllObjects();
    }
}
float CMain::getFontSize(float fontSize)
{   
    return fontSize * (getIsRunningOnIpad() ? 2.0f : 1.0f);
}

E_DEVICE_TYPE CMain::getDeviceType()
{
    if (m_DeviceType == edtNil)
    {
        std::string p = platform::C_PlatformUtils::GetPlatform();
        
        if (p.compare("iPhone1,1") == 0)
            m_DeviceType = edtiPhone1G;
        else if (p.compare("iPhone1,2") == 0)
            m_DeviceType = edtiPhone3G;
        else if (p.compare("iPhone2,1") == 0)
            m_DeviceType = edtiPhone3GS;
        else if (p.compare("iPhone3,1") == 0)
            m_DeviceType = edtiPhone4;
        else if (p.compare("iPhone3,3") == 0)
            m_DeviceType = edtVerizoniPhone4;
        else if (p.compare("iPhone4,1") == 0)
            m_DeviceType = edtiPhone4S;
        else if (p.compare("iPhone5,1") == 0)
            m_DeviceType = edtiPhone5GSM;
        else if (p.compare("iPhone5,2") == 0)
            m_DeviceType = edtiPhone5GSMCDMA;
        else if (p.compare("iPod1,1") == 0)
            m_DeviceType = edtiPodTouch1G;
        else if (p.compare("iPod2,1") == 0)
            m_DeviceType = edtiPodTouch2G;
        else if (p.compare("iPod3,1") == 0)
            m_DeviceType = edtiPodTouch3G;
        else if (p.compare("iPod4,1") == 0)
            m_DeviceType = edtiPodTouch4G;
        else if (p.compare("iPod5,1") == 0)
            m_DeviceType = edtiPodTouch5G;
        else if (p.compare("iPad1,1") == 0)
            m_DeviceType = edtiPad;
        else if (p.compare("iPad2,1") == 0)
            m_DeviceType = edtiPad2WiFi;
        else if (p.compare("iPad2,2") == 0)
            m_DeviceType = edtiPad2GSM;
        else if (p.compare("iPad2,3") == 0)
            m_DeviceType = edtiPad2CDMA;
        else if (p.compare("iPad2,4") == 0)
            m_DeviceType = edtiPad2;
        else if (p.compare("iPad2,5") == 0)
            m_DeviceType = edtiPadMini;
        else if (p.compare("iPad2,6") == 0)
            m_DeviceType = edtiPadMiniWifi;
        else if (p.compare("iPad2,7") == 0)
            m_DeviceType = edtiPadMiniGSM;
        else if (p.compare("iPad3,1") == 0)
            m_DeviceType = edtiPad3Wifi;
        else if (p.compare("iPad3,2") == 0)
            m_DeviceType = edtiPad3GSM;
        else if (p.compare("iPad3,3") == 0)
            m_DeviceType = edtiPad3CDMA;
        else if (p.compare("iPad3,4") == 0)
            m_DeviceType = edtiPad4Wifi;
        else if (p.compare("iPad3,5") == 0)
            m_DeviceType = edtiPad4GSM;
        else if (p.compare("iPad3,6") == 0)
            m_DeviceType = edtiPad4GSMCDMA;
        else if (p.compare("i386") == 0 || p.compare("x86_64") == 0)
            m_DeviceType = edtSimulator;
        else if (p.find("android") != string::npos)
            m_DeviceType = edtAndroid;
        else
        {
            assert(false); // Add unknown value to enum and "switch"
            m_DeviceType = edtUnknown;
        }
    }
    
    return m_DeviceType;
}

// MARK: Helpers
void CMain::initResolutionAndResource()
{
    CCSize  outDesignResolution;
    float   outContentScaleFactor;

    CCSize minDesignSize = getIsRunningOnIpad() ? CCSizeMake(768, 1024) : CCSizeMake(320, 480);
    CCSize cocosWinSize = CCDirector::sharedDirector()->getWinSize();
    float ratioX = cocosWinSize.width / minDesignSize.width;
    float ratioY = cocosWinSize.height / minDesignSize.height;
    
    // smaller of the two ratios
    float ratioToFit3GSScreenOntoDeviceScreen = ratioX < ratioY ? ratioX : ratioY;
    float designResolutionScaleFactor = 1.0f;
    outContentScaleFactor = int(ratioToFit3GSScreenOntoDeviceScreen);
    if(ratioToFit3GSScreenOntoDeviceScreen < 1.5f)
    {
        outContentScaleFactor = 1.0f;
    }
    else if(ratioToFit3GSScreenOntoDeviceScreen < 2.0f)
    {
        outContentScaleFactor = 1.5f;
    }
    else // ratioToFit3GSScreenOntoDeviceScreen > 2, but we need to emulate 3 and 4 through smaller designResolution
    {
        outContentScaleFactor = 2.0f;
        
        if (ratioToFit3GSScreenOntoDeviceScreen < 3.0f) {
            // do nothing, it should look good enough
        } else if (ratioToFit3GSScreenOntoDeviceScreen < 4.0f) {
            // we need assetScale = 3, but we have only 2 available, so let's make designsize smaller
            designResolutionScaleFactor = 0.66666f;
        } else { // ratioToFit3GSScreenOntoDeviceScreen >= 4 - at least Nexus 10
            // let's make this futureproof - keep it looking same as 'hd' devices, just with better dpi for fonts
            designResolutionScaleFactor = outContentScaleFactor / ratioToFit3GSScreenOntoDeviceScreen;
        }
    }
    outDesignResolution = cocos2d::CCSizeMake(cocosWinSize.width * designResolutionScaleFactor / outContentScaleFactor, cocosWinSize.height * designResolutionScaleFactor / outContentScaleFactor);
    
    CCEGLView::sharedOpenGLView()->setDesignResolutionSize(outDesignResolution.width, outDesignResolution.height, kResolutionShowAll);
    CCDirector::sharedDirector()->setContentScaleFactor(outContentScaleFactor);
}

void CMain::initFileSystem()
{
    CCSize      winSize     = CCDirector::sharedDirector()->getWinSizeInPixels();
    CCFileUtils *fileUtils  = CCFileUtils::sharedFileUtils();

    std::vector<std::string> searchResolutionPathList;
    std::vector<std::string> searchPathList;
    
    if (winSize.equals(C_SCREEN_SIZE_IPHONE))
    {
    }
    else if (winSize.equals(C_SCREEN_SIZE_IPHONE_RETINA_35))
    {
        searchResolutionPathList.push_back("Graphics/hd");
    }
    else if (winSize.equals(C_SCREEN_SIZE_IPHONE_RETINA_4))
    {
        searchResolutionPathList.push_back("Graphics/568h");
        searchResolutionPathList.push_back("Graphics/hd");
    }
    else if (winSize.equals(C_SCREEN_SIZE_IPAD))
    {
        searchResolutionPathList.push_back("Graphics/ipad");
        searchResolutionPathList.push_back("Graphics/hd");
    }
    else if (winSize.equals(C_SCREEN_SIZE_IPAD_RETINA))
    {
        searchResolutionPathList.push_back("Graphics/ipadhd");
        searchResolutionPathList.push_back("Graphics/ipad");
        searchResolutionPathList.push_back("Graphics/hd");
    }
    else
    {
        CCAssert(false, "Unknown display size");
    }
    
    searchResolutionPathList.push_back("Graphics/sd");
    
    fileUtils->setSearchPaths(searchPathList);
    fileUtils->setSearchResolutionsOrder(searchResolutionPathList);
}

void CMain::onPacketReceivedLogin(PacketBasic *pPacket, bool isFromQueue)
{
    AuthPacketOpcodes packetType = (AuthPacketOpcodes)pPacket->getPacketType();

    switch (packetType)
    {
        case S_MSG_AUTH_CHALLENGE:
        {
            proccessPacket<PacketLS_GetVersion>(pPacket, isFromQueue);
        }break;
        case S_MSG_AUTH_SERVER_LIST:
        {
            proccessPacket<PacketLS_GetServerList>(pPacket, isFromQueue);
        }break;
        case S_MSG_AUTH_RECHALLENGE:
            break;
        case S_MSG_AUTH_GET_SERVER_STATS:
            break;
            
        default:
            CCLOG("%s, Unknown packet: %d", __PRETTY_FUNCTION__, packetType);
            break;
    }
    
}

void CMain::onPacketReceivedGame(PacketBasic *pPacket, bool isFromQueue)
{
    ClientOpcodes packetType = (ClientOpcodes)pPacket->getPacketType();
    
    switch (packetType)
    {
        case S_MSG_LOGON_PLAYER:
        {
            proccessPacket<PacketGS_PlayerLogin>(pPacket, isFromQueue);
        }break;
        case S_MSG_MATCH_GAME:
        {
            proccessPacket<PacketGS_MatchGame>(pPacket, isFromQueue);
        }break;
        case S_MSG_SAVE_CUSTOM_DATA:
        {
            proccessPacket<PacketGS_SaveCustomData>(pPacket, isFromQueue);
        }break;
        case S_MSG_GET_CUSTOM_DATA:
            break;
        case S_MSG_SEND_DATA_TO_CLIENT:
        {
            onPacketReceivedClient(pPacket, isFromQueue);
        }break;
        case S_MSG_PING:
        {
            proccessPacket<PacketGS_PingPong>(pPacket, isFromQueue);
        }break;
        case S_MSG_UNMATCH_GAME:
            break;
        case S_MSG_GET_ALL_CACHED_DATA:
            break;
        case S_MSG_GET_SERVER_STATS:
            break;
            
        default:
            CCLOG("%s, Unknown packet: %d", __PRETTY_FUNCTION__, packetType);
            break;
    }
}
void CMain::onPacketReceivedClient(PacketBasic *pPacket, bool isFromQueue)
{
    PacketClientData *pPacketData = PacketClientData::create();
    pPacketData->setData(pPacket->getData(), pPacket->getSize());
    pPacketData->deserialize();
    
    ClientDataOpcodes packetType = pPacketData->getPacketDataType();
    
    switch (packetType)
    {
        case C_MSG_CLIENT_DATA_TURN_START:
            proccessPacket<PacketC_TurnStart>(pPacket, isFromQueue);
            break;
        case C_MSG_CLIENT_DATA_TURN_TIMEOUT:
            proccessPacket<PacketC_TurnTimeout>(pPacket, isFromQueue);
            break;
        case C_MSG_CLIENT_DATA_TURN:
            proccessPacket<PacketC_Turn>(pPacket, isFromQueue);
            break;
        default:
            CCLOG("%s, Unknown packet: %d", __PRETTY_FUNCTION__, packetType);
            break;
    }
}
bool CMain::isComListening(PacketBasic *pPacket, bool addToQueue)
{
    bool retValue = true;
    
    if (!m_pCommunicationListener)
    {
        if (addToQueue)
            m_pCommunicationQueue->addObject(pPacket);
        retValue = false;
    }
    
    return retValue;
}
// MARK: IComTCPManagerDelegate
void CMain::onConnected()
{
    CCLOG("%s ServerType:%d", __FUNCTION__, m_eCurrentServer);
    
    m_eConnectionStatus = ecsConnected;
}
void CMain::onDisconnected()
{
    CCLOG("%s ServerType:%d", __FUNCTION__, m_eCurrentServer);

    m_eConnectionStatus = ecsDisconnected;
}
void CMain::onPacketReceived(PacketBasic *pPacket, bool isFromQueue)
{
    CCLOG("%s ServerType:%d PacketType:%d PacketSize:%ld", __FUNCTION__, m_eCurrentServer, pPacket->getPacketType(), pPacket->getSize());
    
    switch (m_eCurrentServer)
    {
        case estGame:
        {
            onPacketReceivedGame(pPacket, isFromQueue);
        }break;
        case estLogin:
        {
            onPacketReceivedLogin(pPacket, isFromQueue);
        }break;
        case estNil:
        {
            CCAssert(false, "OMG Packet without server? :D");
        }break;
    }

}
void CMain::onStreamError(const char *pError)
{
    CCLOG("%s, %s", __PRETTY_FUNCTION__, pError);

}

//MARK: ICommunicationListener
void CMain::onPacketLS_Version(PacketLS_GetVersion *pPacket)
{

}

void CMain::onPacketLS_GetServerList(PacketLS_GetServerList *pPacket)
{
    m_pCommunicationManager->disconnect();
    
    //connect to game server and send logon
    m_eCurrentServer = estGame;
    m_eConnectionStatus = ecsConnecting;
    m_pCommunicationManager->connectWithIPAddress(pPacket->getServerIP(), pPacket->getServerPort());
    
    //login
    PacketGS_PlayerLogin *pLogin = PacketGS_PlayerLogin::create(eptClient);
    pLogin->setPlayerID(m_pFacebookKit->GetUser()->getUserID());
    m_pCommunicationManager->sendPacket(pLogin);
    
    //send user profile to server
    ByteBuffer rUser;
    m_pFacebookKit->GetUser()->serialize(rUser);
    
    PacketGS_SaveCustomData *pData = PacketGS_SaveCustomData::create(eptClient);
    pData->setKey(E_PLAYER_PROFILE);
    pData->setUserData(rUser);
    m_pCommunicationManager->sendPacket(pData);
}

void CMain::onPacketGS_Ping(PacketGS_PingPong *pPacket)
{
    PacketGS_PingPong *pPacketPong = PacketGS_PingPong::create(eptClient);
    pPacketPong->setTimestamp(pPacket->getTimestamp());
    m_pCommunicationManager->sendPacket(pPacketPong);
}

void CMain::onPacketGS_MatchGame(PacketGS_MatchGame *pPacket)
{
    
}

void CMain::onPacketGS_PlayerLogin(PacketGS_PlayerLogin *pPacket)
{
    
}

void CMain::onPacketGS_SaveCustomData(PacketGS_SaveCustomData *pPacket)
{
    
}
void CMain::onPacketC_TurnStart(PacketC_TurnStart *pPacket)
{
    
}
void CMain::onPacketC_TurnTimeout(PacketC_TurnTimeout *pPacket)
{
    
}
void CMain::onPacketC_Turn(PacketC_Turn *pPacket)
{
    
}

//MARK: IGeneralNotification
void CMain::onFBSessionLoggedIn()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBSessionLoggedIn();
}
void CMain::onFBSessionDidNotLogin()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBSessionDidNotLogin();
}
void CMain::onFBSessionLoggedOut()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBSessionLoggedOut();
}
void CMain::onFBSessionInvalidate()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBSessionInvalidate();
}
void CMain::onFBSessionError(const char *pErrorDesc, int errorCode)
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBSessionError(pErrorDesc, errorCode);
}
void CMain::onFBUserDownloadOk()
{   
    if (m_pNotificationListener)
        m_pNotificationListener->onFBUserDownloadOk();
}
void CMain::onFBUserDownloadError(const char *pErrorDesc, int errorCode)
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBUserDownloadError(pErrorDesc, errorCode);
}
void CMain::onFBCheckNotifications()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBCheckNotifications();
}
void CMain::onFBCredentialsReloadFailed()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBCredentialsReloadFailed();
}
void CMain::onFBUserListOk()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBUserListOk();
}
void CMain::onFBUserListError(const char *pErrorDesc, int errorCode)
{
    if (m_pNotificationListener)
        m_pNotificationListener->onFBUserListError(pErrorDesc, errorCode);
}
void CMain::onGEInternetStatusChangedOnline()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onGEInternetStatusChangedOnline();
}
void CMain::onGEInternetStatusChangedOffline()
{
    if (m_pNotificationListener)
        m_pNotificationListener->onGEInternetStatusChangedOffline();
}