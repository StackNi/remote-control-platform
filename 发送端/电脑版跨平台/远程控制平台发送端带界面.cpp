//==============================================================================
// 远程控制平台发送端带界面
//==============================================================================

#include <fmx.h>
#include <System.SysUtils.hpp>
#include <System.UITypes.hpp>
#include <System.Classes.hpp>
#include <FMX.Types.hpp>
#include <FMX.Controls.hpp>
#include <FMX.Controls.Presentation.hpp>
#include <FMX.Forms.hpp>
#include <FMX.Objects.hpp>
#include <FMX.Layouts.hpp>
#include <FMX.StdCtrls.hpp>
#include <IdUDPServer.hpp>
#include <IdGlobal.hpp>
#include <FMX.Edit.hpp>
#include <FMX.Effects.hpp>
#include <FMX.Filter.Effects.hpp>
#include <FMX.Platform.hpp>
#include <System.IOUtils.hpp>
#include <System.IniFiles.hpp>
#include <System.DateUtils.hpp>
#include <IdStack.hpp>
#include <FMX.Skia.hpp>
#include <System.Skia.hpp>
#include <IdBaseComponent.hpp>
#include <IdUDPBase.hpp>
#include <IdComponent.hpp>
#include <FMX.ComboEdit.hpp>
#include <System.Generics.Collections.hpp>
#include <FMX.DialogService.hpp>
#include <IdSocketHandle.hpp>
#include <System.JSON.hpp>
#include <System.Net.HttpClientComponent.hpp>
#include <System.Net.URLClient.hpp>
#include <System.Net.HttpClient.hpp>

#ifdef _WIN32
#include <FMX.Platform.Win.hpp>
#include <Winapi.Windows.hpp>
#include <Winapi.Messages.hpp>
#include <Winapi.ShellAPI.hpp>
#endif

#ifdef __APPLE__
#include <Posix.Stdlib.hpp>
#include <Macapi.CoreFoundation.hpp>
#endif

#ifdef __linux__
#include <Posix.Stdlib.hpp>
#endif

//==============================================================================
// 类型定义
//==============================================================================

enum class THomeSubPage {
    hspNone, hspLocalIP, hspDonate
};

enum class TSettingsSubPage {
    sspNone, sspChangeUsername, sspChangeIPList
};

struct TIPAliasItem {
    String Name;
    String IP;
};

using TIPAliasList = TList<TIPAliasItem>;

//==============================================================================
// 窗体类定义
//==============================================================================

class Tmainform : public TForm {
    __published:
        TSkSvg* closeimage;
        TSkSvg* minimizeimage;
        TImage* appicon;
        TSkSvg* sendbtn;
        TSkSvg* endbtn;
        TSkSvg* cmdbtn;
        TLayout* sendlayout;
        TEdit* msgtext;
        TGlowEffect* appiconGlowEffect;
        TSkSvg* pinimage;
        TSkSvg* sendclickedbtn;
        TSkSvg* endclickedbtn;
        TSkSvg* cmdclickedbtn;
        TButton* sendmsgbtn;
        TRadioButton* normal;
        TEdit* msgdurationtext;
        TSpinEditButton* msgdurationspinbtn;
        TRadioButton* typewriter;
        TRadioButton* blink;
        TRadioButton* fullscreen;
        TSwitch* manualcloseSwitch;
        TLayout* endlayout;
        TButton* endmsgbtn;
        TLayout* cmdlayout;
        TEdit* cmdtext;
        TRadioButton* user;
        TButton* sendcmdbtn;
        TLayout* homelayout;
        TLabel* guidecaption;
        TRectangle* homesendbtn;
        TRectangle* homelistbtn;
        TRectangle* homeendbtn;
        TRectangle* homecmdbtn;
        TSkSvg* homelistdown;
        TSkSvg* homelistup;
        TSkSvg* homebtn;
        TSkSvg* mobilebtn;
        TSkSvg* settingsbtn;
        TSkSvg* homeclickedbtn;
        TSkSvg* mobileclickedbtn;
        TSkSvg* settingsclickedbtn;
        TLayout* mobilelayout;
        TLayout* settingslayout;
        TLabel* homecurrentusername;
        TCircle* homelocalIPbtn;
        TCircle* homedonatebtn;
        TLayout* localIPlayout;
        TLabel* localIPcaption;
        TLabel* localIPlabel;
        TSkSvg* backfromlocalIPbtn;
        TLayout* donatelayout;
        TSkSvg* backfromdonatebtn;
        TButton* refreshlocalIPbtn;
        TButton* copylocalIPbtn;
        TButton* changeusernamebtn;
        TButton* changeIPlistbtn;
        TSwitch* skiaswitch;
        TLayout* changeusernamelayout;
        TSkSvg* backfromchangeusernamebtn;
        TLabel* currentusername;
        TEdit* newusernametext;
        TButton* newusernamebtn;
        TLayout* changeIPlistlayout;
        TSkSvg* backfromchangeIPlistbtn;
        TVertScrollBox* changeIPlistScrollBox;
        TComboEdit* sendIPtext;
        TComboEdit* endIPtext;
        TComboEdit* cmdIPtext;
        TRectangle* localIPitem;
        TLabel* localIPtip;
        TLabel* localIPtipIP;
        TButton* addIPtipbtn;
        TPopup* homelistpopup;
        TPopup* appcard;
        TCircle* homegithubbtn;
        TTimer* Timeout;
        TIdUDPServer* mainUDP;
        TRectangle* websitebtn;
        TCircle* homecheckupdatebtn;
        TCircle* updatenotify;
        TNetHTTPClient* VersionHTTPClient;

        // 事件处理函数声明
        void __fastcall backgroundMouseDown(TObject* Sender, TMouseButton Button, TShiftState Shift, float X, float Y);
        void __fastcall sidebarbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y);
        void __fastcall ctrlbtnClick(TObject* Sender);
        void __fastcall sidebarbtnMouseLeave(TObject* Sender);
        void __fastcall ctrlbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y);
        void __fastcall ctrlbtnMouseLeave(TObject* Sender);
        void __fastcall appiconMouseMove(TObject* Sender, TShiftState Shift, float X, float Y);
        void __fastcall appiconMouseLeave(TObject* Sender);
        void __fastcall sidebarbtnClick(TObject* Sender);
        void __fastcall FormCreate(TObject* Sender);
        void __fastcall FormResize(TObject* Sender);
        void __fastcall HomeButtonMouseMove(TObject* Sender, TShiftState Shift, float X, float Y);
        void __fastcall HomeButtonMouseLeave(TObject* Sender);
        void __fastcall HomeButtonMouseDown(TObject* Sender, TMouseButton Button, TShiftState Shift, float X, float Y);
        void __fastcall HomeButtonMouseUp(TObject* Sender, TMouseButton Button, TShiftState Shift, float X, float Y);
        void __fastcall HomeButtonClick(TObject* Sender);
        void __fastcall SettingsButtonClick(TObject* Sender);
        void __fastcall backbtnClick(TObject* Sender);
        void __fastcall backbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y);
        void __fastcall backbtnMouseLeave(TObject* Sender);
        void __fastcall refreshlocalIPbtnClick(TObject* Sender);
        void __fastcall copylocalIPbtnClick(TObject* Sender);
        void __fastcall newusernamebtnClick(TObject* Sender);
        void __fastcall skiaswitchSwitch(TObject* Sender);
        void __fastcall msgdurationspinbtnUpClick(TObject* Sender);
        void __fastcall msgdurationspinbtnDownClick(TObject* Sender);
        void __fastcall msgdurationspinbtnMouseWheel(TObject* Sender, TShiftState Shift, int WheelDelta, bool& Handled);
        void __fastcall ctrlIPtipbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y);
        void __fastcall ctrlIPtipbtnMouseLeave(TObject* Sender);
        void __fastcall IPitemMouseMove(TObject* Sender, TShiftState Shift, float X, float Y);
        void __fastcall IPitemMouseLeave(TObject* Sender);
        void __fastcall addIPtipbtnClick(TObject* Sender);
        void __fastcall EditIPClick(TObject* Sender);
        void __fastcall DeleteIPClick(TObject* Sender);
        void __fastcall sendmsgbtnClick(TObject* Sender);
        void __fastcall endmsgbtnClick(TObject* Sender);
        void __fastcall homelistpopupClosePopup(TObject* Sender);
        void __fastcall appiconClick(TObject* Sender);
        void __fastcall appcardClosePopup(TObject* Sender);
        void __fastcall sendcmdbtnClick(TObject* Sender);
        void __fastcall TimeoutTimer(TObject* Sender);
        void __fastcall mainUDPUDPRead(TIdUDPListenerThread* AThread, const TIdBytes AData, TIdSocketHandle* ABinding);
        void __fastcall mainUDPUDPException(TIdUDPListenerThread* AThread, TIdSocketHandle* ABinding, const String AMessage, const TClass AExceptionClass);
        void __fastcall VersionHTTPClientValidateServerCertificate(TObject* Sender, const TURLRequest* ARequest, const TCertificate* Certificate, bool& Accepted);

    private:
        // 私有成员变量
        TControl* FActiveSidebarButton;
        THomeSubPage FActiveHomeSubPage;
        TSettingsSubPage FActiveSettingsSubPage;
        String FCurrentUsername;
        TList<TRectangle*>* FIPItems;
        TIPAliasList* FIPAliases;
        TRectangle* FCurrentIPItem;
        bool FappiconEffect;
        bool FIsTopMost;
        TButton* FCurrentActionBtn;
        String FCurrentActionType;
        bool FResponseProcessed;
        bool FUpdatingInProgress;
        String FDeviceGUID;
        String FCurrentRequestID;

        // 私有方法声明
        void LoadOrCreateGUID();
        void SetActiveSidebarButton(TControl* Button);
        String GetRandomGreeting();
        String GetIPAddressInfo();
        String GetAppConfigPath();
        void UpdatePinImageState();
        void ShowCorrespondingLayout(String ButtonType);
        void HandleBackButtonClick(String BackFrom);
        void ShowHomeSubPage(THomeSubPage SubPage);
        void ShowSettingsSubPage(TSettingsSubPage SubPage);
        void SaveConfigToFile(const String Section, const String Key, const String Value);
        String LoadConfigFromFile(const String Section, const String Key, const String DefaultValue);

        void LoadUserConfig();
        void SaveUserConfig();
        void UpdateAllUsernameDisplays();
        void LoadIPAliases();
        void SaveIPAliases();
        void ClearIPItems();
        void CreateIPItem(const TIPAliasItem& Item, int Index);
        void UpdateLayout();
        void UpdateComboEditItems();
        void DisableSendButtons();
        void EnableSendButtons();

        bool ValidateIPAddress(const String IP);
        void AddIPAlias(const String Name, const String IP);
        void ShowIPitemButtons(TRectangle* IPitem);
        void HideIPitemButtons(TRectangle* IPitem);
        bool ValidateAndGetTargetIP(const String InputText, String& TargetIP);
        bool CheckLocalNetworkAvailable();
        void ResetActionButton();
        void CheckForUpdate(bool ShowDialog = false);
        void DoCheckUpdate(bool ShowDialog);
        void ParseVersionResponse(const String Content, bool ShowDialog);
        void ShowUpdateDialog(const String VersionInfo, const String UpdateNotes, const String PublishDate, const String DownloadUrl, int UpdateLevel);
        int CompareVersion(const String V1, const String V2);
        int GetVersionLevel(const String CurrentVer, const String NewVer);
        void OpenDownloadUrl(const String Url);

    public:
        __fastcall Tmainform(TComponent* Owner);
};

//==============================================================================
// 常量定义
//==============================================================================

const String APP_VERSION = "3.2.0";

//==============================================================================
// 全局变量
//==============================================================================

Tmainform* mainform;

//==============================================================================
// 辅助函数：构建JSON消息
//==============================================================================

String BuildMessageJSON(const String& DeviceGUID, const String& Username, 
    const String& Message, const String& Duration, const String& DisplayMode, 
    const String& RequestID) {
    auto JSON = std::make_unique<TJSONObject>();
    JSON->AddPair("type", "message");
    JSON->AddPair("deviceGUID", DeviceGUID);
    JSON->AddPair("username", Username);
    JSON->AddPair("content", Message);
    JSON->AddPair("duration", Duration);
    JSON->AddPair("displayMode", DisplayMode);
    JSON->AddPair("requestID", RequestID);
    return JSON->ToString();
}

String BuildCloseJSON(const String& DeviceGUID, const String& Username, 
    const String& RequestID) {
    auto JSON = std::make_unique<TJSONObject>();
    JSON->AddPair("type", "close");
    JSON->AddPair("deviceGUID", DeviceGUID);
    JSON->AddPair("username", Username);
    JSON->AddPair("requestID", RequestID);
    return JSON->ToString();
}

String BuildCmdJSON(const String& DeviceGUID, const String& Username, 
    const String& Command, const String& Permission, const String& RequestID) {
    auto JSON = std::make_unique<TJSONObject>();
    JSON->AddPair("type", "cmd");
    JSON->AddPair("deviceGUID", DeviceGUID);
    JSON->AddPair("username", Username);
    JSON->AddPair("command", Command);
    JSON->AddPair("permission", Permission);
    JSON->AddPair("requestID", RequestID);
    return JSON->ToString();
}

//==============================================================================
// 提取socket错误码
//==============================================================================

int ExtractSocketErrorCode(const String& Msg) {
    int Result = 0;
    int HashPos = Msg.Pos("#");
    if (HashPos > 0) {
        String CodeStr = "";
        for (int i = HashPos + 1; i <= Msg.Length(); i++) {
            if (IsCharInSet(Msg[i], "0123456789")) {
                CodeStr += Msg[i];
            } else if (CodeStr != "") {
                break;
            }
        }
        if (CodeStr != "") {
            Result = StrToIntDef(CodeStr, 0);
        }
    }
    return Result;
}

//==============================================================================
// Tmainform 实现
//==============================================================================

__fastcall Tmainform::Tmainform(TComponent* Owner) : TForm(Owner) {
    FIPItems = new TList<TRectangle*>();
    FIPAliases = new TIPAliasList();
    FCurrentIPItem = nullptr;
    FappiconEffect = true;
    FCurrentActionBtn = nullptr;
    FCurrentActionType = "";
    FResponseProcessed = false;
    FUpdatingInProgress = false;
    FIsTopMost = false;
}

// ================== GUID 管理 ==================
void Tmainform::LoadOrCreateGUID() {
    String GUIDStr = LoadConfigFromFile("Device", "GUID", "");
    if (GUIDStr == "") {
        GUIDStr = TGUID::NewGuid().ToString();
        SaveConfigToFile("Device", "GUID", GUIDStr);
    }
    FDeviceGUID = GUIDStr;
}

// ================== 配置文件路径 ==================
String Tmainform::GetAppConfigPath() {
    String AppDataPath;
    
    #ifdef _WIN32
    AppDataPath = GetEnvironmentVariable("APPDATA");
    if (AppDataPath == "") {
        AppDataPath = TPath::GetHomePath();
    }
    AppDataPath = TPath::Combine(AppDataPath, "远程控制平台");
    #endif

    #ifdef __APPLE__
    AppDataPath = TPath::Combine(TPath::GetHomePath(), "Library/Application Support/远程控制平台");
    #endif

    #ifdef __linux__
    AppDataPath = TPath::Combine(TPath::GetHomePath(), ".config/远程控制平台");
    #endif

    if (!TDirectory::Exists(AppDataPath)) {
        TDirectory::CreateDirectory(AppDataPath);
    }

    return TPath::Combine(AppDataPath, "config.json");
}

// ================== JSON 辅助函数 ==================
std::unique_ptr<TJSONObject> LoadJSONConfig() {
    String FilePath = mainform->GetAppConfigPath();
    if (TFile::Exists(FilePath)) {
        String Content = TFile::ReadAllText(FilePath, TEncoding::UTF8);
        TJSONObject* Result = dynamic_cast<TJSONObject*>(TJSONObject::ParseJSONValue(Content));
        if (Result == nullptr) {
            Result = new TJSONObject();
        }
        return std::unique_ptr<TJSONObject>(Result);
    } else {
        return std::make_unique<TJSONObject>();
    }
}

void SaveJSONConfig(TJSONObject* JSON) {
    String FilePath = mainform->GetAppConfigPath();
    TFile::WriteAllText(FilePath, JSON->Format(2), TEncoding::UTF8);
}

void Tmainform::SaveConfigToFile(const String Section, const String Key, const String Value) {
    auto JSON = LoadJSONConfig();
    TJSONObject* SectionObj = nullptr;
    
    if (!JSON->TryGetValue<TJSONObject>(Section, &SectionObj)) {
        SectionObj = new TJSONObject();
        JSON->AddPair(Section, SectionObj);
    }
    
    SectionObj->RemovePair(Key);
    SectionObj->AddPair(Key, Value);
    
    SaveJSONConfig(JSON.get());
}

String Tmainform::LoadConfigFromFile(const String Section, const String Key, const String DefaultValue) {
    String Result = DefaultValue;
    auto JSON = LoadJSONConfig();
    TJSONObject* SectionObj = nullptr;
    
    if (JSON->TryGetValue<TJSONObject>(Section, &SectionObj)) {
        String Value;
        if (SectionObj->TryGetValue<String>(Key, &Value)) {
            Result = Value;
        }
    }
    
    return Result;
}

// ================== 用户配置 ==================
void Tmainform::LoadUserConfig() {
    FCurrentUsername = LoadConfigFromFile("User", "Username", "").Trim();
    if (FCurrentUsername == "") {
        FCurrentUsername = "默认用户";
    }
}

void Tmainform::SaveUserConfig() {
    SaveConfigToFile("User", "Username", FCurrentUsername);
}

void Tmainform::UpdateAllUsernameDisplays() {
    if (homecurrentusername != nullptr) {
        homecurrentusername->Text = "当前用户: " + FCurrentUsername;
    }
    if (currentusername != nullptr) {
        currentusername->Text = "当前用户: " + FCurrentUsername;
    }
}

// ================== IP地址相关 ==================
String Tmainform::GetIPAddressInfo() {
    String Result = "";
    auto IPList = std::make_unique<TStringList>();
    
    for (int i = 0; i < GStack->LocalAddresses->Count; i++) {
        String IP = GStack->LocalAddresses[i];
        String IPType;
        
        if ((IP.Pos(":") == 0) && (IP != "127.0.0.1")) {
            if (IP.SubString(1, 3) == "10.") {
                IPType = "私网A类";
            } else if ((IP.SubString(1, 4) == "172.") &&
                       (StrToIntDef(IP.SubString(5, 3), 0) >= 16) &&
                       (StrToIntDef(IP.SubString(5, 3), 0) <= 31)) {
                IPType = "私网B类";
            } else if (IP.SubString(1, 8) == "192.168.") {
                IPType = "私网C类";
            } else if (IP.SubString(1, 4) == "169.") {
                IPType = "APIPA地址";
            } else {
                IPType = "公网地址";
            }
            
            IPList->Add(IP + " [" + IPType + "]");
        }
    }
    
    IPList->Sort();
    
    if (IPList->Count > 0) {
        for (int i = 0; i < IPList->Count; i++) {
            Result += IPList->Strings[i];
            if (i < IPList->Count - 1) {
                Result += "\r\n";
            }
        }
    } else {
        Result = "未找到可用IP，请检查网络设置";
    }
    
    return Result;
}

bool Tmainform::ValidateIPAddress(const String IP) {
    if (IP.Trim() == "") return false;
    
    TArray<String> Parts = IP.Split({"."});
    if (Parts.Length != 4) return false;
    
    for (int i = 0; i < 4; i++) {
        if (Parts[i] == "") return false;
        
        for (int j = 1; j <= Parts[i].Length(); j++) {
            if ((Parts[i][j] < '0') || (Parts[i][j] > '9')) return false;
        }
        
        if ((Parts[i].Length() > 1) && (Parts[i][1] == '0')) return false;
        
        int Num;
        if (!TryStrToInt(Parts[i], Num)) return false;
        
        if ((Num < 0) || (Num > 255)) return false;
    }
    
    return true;
}

// ================== 置顶设置 ==================
void Tmainform::UpdatePinImageState() {
    if (FIsTopMost) {
        pinimage->Hint = "取消置顶";
        pinimage->Opacity = 1;
        pinimage->Svg->OverrideColor = 0xFFFF4F4F;
    } else {
        pinimage->Hint = "置顶";
        pinimage->Opacity = 0.6;
        pinimage->Svg->OverrideColor = 0;
    }
}

// ================== 问候语 ==================
String Tmainform::GetRandomGreeting() {
    int CurrentHour = HourOf(Now());
    String TimeGreeting;
    TArray<String> RandomGreetings;
    
    switch (CurrentHour) {
        case 0: case 1: case 2: case 3: case 4:
            TimeGreeting = "夜深了，";
            RandomGreetings = {"还没睡呢", "有什么心事呢", "努力总有回报"};
            break;
        case 5: case 6: case 7: case 8: case 9: case 10:
            TimeGreeting = "早上好，";
            RandomGreetings = {"新的一天开始啦", "一日之计在于晨", "开始工作吧"};
            break;
        case 11: case 12: case 13:
            TimeGreeting = "中午好，";
            RandomGreetings = {"工作顺利吗", "放松一下吧"};
            break;
        case 14: case 15: case 16: case 17:
            TimeGreeting = "下午好，";
            RandomGreetings = {"继续加油", "来杯下午茶吧"};
            break;
        case 18: case 19: case 20: case 21:
            TimeGreeting = "晚上好，";
            RandomGreetings = {"注意劳逸结合", "还在忙碌呢"};
            break;
        default:
            TimeGreeting = "夜深了，";
            RandomGreetings = {"注意休息", "晚安"};
            break;
    }
    
    Randomize();
    return TimeGreeting + RandomGreetings[Random(RandomGreetings.Length)];
}

// ================== 页面管理 ==================
void Tmainform::ShowCorrespondingLayout(String ButtonType) {
    homelayout->Visible = false;
    sendlayout->Visible = false;
    endlayout->Visible = false;
    cmdlayout->Visible = false;
    mobilelayout->Visible = false;
    settingslayout->Visible = false;
    
    localIPlayout->Visible = false;
    donatelayout->Visible = false;
    changeusernamelayout->Visible = false;
    changeIPlistlayout->Visible = false;
    
    FActiveHomeSubPage = THomeSubPage::hspNone;
    FActiveSettingsSubPage = TSettingsSubPage::sspNone;
    
    if (ButtonType == "home") {
        homelayout->Visible = true;
    } else if (ButtonType == "send") {
        sendlayout->Visible = true;
    } else if (ButtonType == "end") {
        endlayout->Visible = true;
    } else if (ButtonType == "cmd") {
        cmdlayout->Visible = true;
    } else if (ButtonType == "mobile") {
        mobilelayout->Visible = true;
    } else if (ButtonType == "settings") {
        settingslayout->Visible = true;
    }
}

void Tmainform::ShowHomeSubPage(THomeSubPage SubPage) {
    homelayout->Visible = false;
    sendlayout->Visible = false;
    endlayout->Visible = false;
    cmdlayout->Visible = false;
    mobilelayout->Visible = false;
    settingslayout->Visible = false;
    
    localIPlayout->Visible = false;
    donatelayout->Visible = false;
    
    switch (SubPage) {
        case THomeSubPage::hspLocalIP:
            localIPlayout->Visible = true;
            FActiveHomeSubPage = THomeSubPage::hspLocalIP;
            break;
        case THomeSubPage::hspDonate:
            donatelayout->Visible = true;
            FActiveHomeSubPage = THomeSubPage::hspDonate;
            break;
        default:
            FActiveHomeSubPage = THomeSubPage::hspNone;
            break;
    }
}

void Tmainform::ShowSettingsSubPage(TSettingsSubPage SubPage) {
    homelayout->Visible = false;
    sendlayout->Visible = false;
    endlayout->Visible = false;
    cmdlayout->Visible = false;
    mobilelayout->Visible = false;
    settingslayout->Visible = false;
    
    localIPlayout->Visible = false;
    donatelayout->Visible = false;
    changeusernamelayout->Visible = false;
    changeIPlistlayout->Visible = false;
    
    FActiveHomeSubPage = THomeSubPage::hspNone;
    
    switch (SubPage) {
        case TSettingsSubPage::sspChangeUsername:
            changeusernamelayout->Visible = true;
            FActiveSettingsSubPage = TSettingsSubPage::sspChangeUsername;
            break;
        case TSettingsSubPage::sspChangeIPList:
            changeIPlistlayout->Visible = true;
            FActiveSettingsSubPage = TSettingsSubPage::sspChangeIPList;
            break;
        default:
            FActiveSettingsSubPage = TSettingsSubPage::sspNone;
            break;
    }
}

void Tmainform::HandleBackButtonClick(String BackFrom) {
    if ((BackFrom == "changeusername") || (BackFrom == "changeIPlist")) {
        newusernametext->Text = "";
        if (FActiveSettingsSubPage != TSettingsSubPage::sspNone) {
            SetActiveSidebarButton(settingsbtn);
            ShowCorrespondingLayout("settings");
            FActiveSettingsSubPage = TSettingsSubPage::sspNone;
        }
        return;
    }
    
    THomeSubPage SubPage;
    
    if (BackFrom == "localIP") {
        SubPage = THomeSubPage::hspLocalIP;
    } else if (BackFrom == "donate") {
        SubPage = THomeSubPage::hspDonate;
    } else {
        SubPage = THomeSubPage::hspNone;
    }
    
    if (FActiveHomeSubPage == SubPage) {
        SetActiveSidebarButton(homebtn);
        ShowCorrespondingLayout("home");
        FActiveHomeSubPage = THomeSubPage::hspNone;
    }
}

void Tmainform::SetActiveSidebarButton(TControl* Button) {
    ShowCorrespondingLayout("");
    
    sendbtn->Svg->OverrideColor = 0;
    endbtn->Svg->OverrideColor = 0;
    cmdbtn->Svg->OverrideColor = 0;
    homebtn->Svg->OverrideColor = 0;
    mobilebtn->Svg->OverrideColor = 0;
    settingsbtn->Svg->OverrideColor = 0;
    
    sendbtn->Visible = true;
    endbtn->Visible = true;
    cmdbtn->Visible = true;
    homebtn->Visible = true;
    mobilebtn->Visible = true;
    settingsbtn->Visible = true;
    
    sendclickedbtn->Visible = false;
    endclickedbtn->Visible = false;
    cmdclickedbtn->Visible = false;
    homeclickedbtn->Visible = false;
    mobileclickedbtn->Visible = false;
    settingsclickedbtn->Visible = false;
    
    FActiveSidebarButton = Button;
    
    if (Button == sendbtn) {
        sendbtn->Visible = false;
        sendclickedbtn->Visible = true;
        ShowCorrespondingLayout("send");
    } else if (Button == endbtn) {
        endbtn->Visible = false;
        endclickedbtn->Visible = true;
        ShowCorrespondingLayout("end");
    } else if (Button == cmdbtn) {
        cmdbtn->Visible = false;
        cmdclickedbtn->Visible = true;
        ShowCorrespondingLayout("cmd");
    } else if (Button == homebtn) {
        homebtn->Visible = false;
        homeclickedbtn->Visible = true;
        ShowCorrespondingLayout("home");
    } else if (Button == mobilebtn) {
        mobilebtn->Visible = false;
        mobileclickedbtn->Visible = true;
        ShowCorrespondingLayout("mobile");
    } else if (Button == settingsbtn) {
        settingsbtn->Visible = false;
        settingsclickedbtn->Visible = true;
        ShowCorrespondingLayout("settings");
    }
}

// ================== IP别名管理核心功能 ==================
void Tmainform::LoadIPAliases() {
    changeIPlistScrollBox->BeginUpdate();
    try {
        ClearIPItems();
        if (FIPAliases == nullptr) {
            FIPAliases = new TIPAliasList();
        } else {
            FIPAliases->Clear();
        }
        
        auto JSON = LoadJSONConfig();
        TJSONObject* TipsObj = nullptr;
        
        if (JSON->TryGetValue<TJSONObject>("tips", &TipsObj)) {
            for (int i = 0; i < TipsObj->Count; i++) {
                TJSONPair* Pair = TipsObj->Pairs[i];
                TIPAliasItem Item;
                Item.Name = Pair->JsonString->Value();
                Item.IP = Pair->JsonValue->Value();
                if ((Item.Name != "") && (Item.IP != "")) {
                    FIPAliases->Add(Item);
                }
            }
        }
        
        for (int i = 0; i < FIPAliases->Count; i++) {
            CreateIPItem((*FIPAliases)[i], i);
        }
        
        UpdateLayout();
        UpdateComboEditItems();
    } catch (...) {
        changeIPlistScrollBox->EndUpdate();
        throw;
    }
    changeIPlistScrollBox->EndUpdate();
}

void Tmainform::UpdateComboEditItems() {
    String OldSendText = sendIPtext->Text;
    String OldEndText = endIPtext->Text;
    String OldCmdText = cmdIPtext->Text;
    
    sendIPtext->Items->Clear();
    endIPtext->Items->Clear();
    cmdIPtext->Items->Clear();
    
    sendIPtext->Items->Add("本地回环");
    endIPtext->Items->Add("本地回环");
    cmdIPtext->Items->Add("本地回环");
    
    for (int i = 0; i < FIPAliases->Count; i++) {
        sendIPtext->Items->Add((*FIPAliases)[i].Name);
        endIPtext->Items->Add((*FIPAliases)[i].Name);
        cmdIPtext->Items->Add((*FIPAliases)[i].Name);
    }
    
    sendIPtext->ItemIndex = -1;
    if (OldSendText != "") {
        int idx = sendIPtext->Items->IndexOf(OldSendText);
        if (idx >= 0) {
            sendIPtext->ItemIndex = idx;
        } else {
            sendIPtext->Text = OldSendText;
        }
    }
    
    endIPtext->ItemIndex = -1;
    if (OldEndText != "") {
        int idx = endIPtext->Items->IndexOf(OldEndText);
        if (idx >= 0) {
            endIPtext->ItemIndex = idx;
        } else {
            endIPtext->Text = OldEndText;
        }
    }
    
    cmdIPtext->ItemIndex = -1;
    if (OldCmdText != "") {
        int idx = cmdIPtext->Items->IndexOf(OldCmdText);
        if (idx >= 0) {
            cmdIPtext->ItemIndex = idx;
        } else {
            cmdIPtext->Text = OldCmdText;
        }
    }
}

void Tmainform::SaveIPAliases() {
    auto JSON = LoadJSONConfig();
    
    if (JSON->GetValue("tips") != nullptr) {
        JSON->RemovePair("tips");
    }
    
    TJSONObject* TipsObj = new TJSONObject();
    for (int i = 0; i < FIPAliases->Count; i++) {
        TipsObj->AddPair((*FIPAliases)[i].Name, (*FIPAliases)[i].IP);
    }
    JSON->AddPair("tips", TipsObj);
    
    SaveJSONConfig(JSON.get());
}

void Tmainform::ClearIPItems() {
    FCurrentIPItem = nullptr;
    
    for (int i = FIPItems->Count - 1; i >= 0; i--) {
        TRectangle* Item = (*FIPItems)[i];
        FIPItems->Delete(i);
        delete Item;
    }
}

void Tmainform::CreateIPItem(const TIPAliasItem& Item, int Index) {
    String ExistingName = "IPitem_" + IntToStr(Index);
    TFmxObject* ExistingObj = changeIPlistScrollBox->FindComponent(ExistingName);
    if (ExistingObj != nullptr) {
        changeIPlistScrollBox->RemoveObject(ExistingObj);
        delete ExistingObj;
    }
    
    TRectangle* IPItem = new TRectangle(changeIPlistScrollBox);
    try {
        IPItem->Parent = changeIPlistScrollBox;
        IPItem->Name = ExistingName;
        IPItem->Fill->Color = 0xFF2B2B2B;
        IPItem->Stroke->Thickness = 0;
        IPItem->ClipChildren = false;
        
        IPItem->Tag = Index;
        IPItem->OnMouseMove = IPitemMouseMove;
        IPItem->OnMouseLeave = IPitemMouseLeave;
        
        FIPItems->Add(IPItem);
        
        TLine* IPItemDivideLine = new TLine(IPItem);
        IPItemDivideLine->Parent = IPItem;
        IPItemDivideLine->Name = "divide_" + IntToStr(Index);
        IPItemDivideLine->LineType = TLineType::Diagonal;
        IPItemDivideLine->Stroke->Color = 0xFF343434;
        IPItemDivideLine->Stroke->Thickness = 1;
        IPItemDivideLine->Size->Width = 717;
        IPItemDivideLine->Size->Height = 1;
        IPItemDivideLine->Position->X = 8;
        IPItemDivideLine->Position->Y = -4;
        IPItemDivideLine->HitTest = false;
        
        TRectangle* itemcolor = new TRectangle(IPItem);
        itemcolor->Parent = IPItem;
        itemcolor->Name = "itemcolor_" + IntToStr(Index);
        itemcolor->Fill->Color = 0xFF4FFFFF;
        itemcolor->HitTest = false;
        itemcolor->Stroke->Thickness = 0;
        itemcolor->Size->Width = 6;
        itemcolor->Size->Height = 94;
        itemcolor->Align = TAlignLayout::Left;
        
        TLabel* IPtip = new TLabel(IPItem);
        IPtip->Parent = IPItem;
        IPtip->Name = "IPtip_" + IntToStr(Index);
        IPtip->StyledSettings = {TStyledSetting::Style};
        IPtip->TextSettings->Font->Family = "Microsoft YaHei";
        IPtip->TextSettings->Font->Size = 20;
        IPtip->TextSettings->FontColor = TAlphaColorRec::White;
        IPtip->Text = Item.Name;
        IPtip->Position->X = 28;
        IPtip->Position->Y = 14;
        IPtip->Size->Width = 610;
        IPtip->Size->Height = 33;
        IPtip->HitTest = false;
        
        TLabel* IPtipIP = new TLabel(IPItem);
        IPtipIP->Parent = IPItem;
        IPtipIP->Name = "IPtipIP_" + IntToStr(Index);
        IPtipIP->StyledSettings = {TStyledSetting::Style};
        IPtipIP->TextSettings->Font->Family = "Microsoft YaHei";
        IPtipIP->TextSettings->Font->Size = 16;
        IPtipIP->TextSettings->FontColor = 0xFF949494;
        IPtipIP->Text = "IP: " + Item.IP;
        IPtipIP->Position->X = 28;
        IPtipIP->Position->Y = 49;
        IPtipIP->Size->Width = 610;
        IPtipIP->Size->Height = 30;
        IPtipIP->HitTest = false;
        
        TSkSvg* editIPtipbtn = new TSkSvg(IPItem);
        editIPtipbtn->Parent = IPItem;
        editIPtipbtn->Name = "editIPtipbtn_" + IntToStr(Index);
        editIPtipbtn->Cursor = crHandPoint;
        editIPtipbtn->Hint = "修改提示词";
        editIPtipbtn->HitTest = true;
        editIPtipbtn->Position->X = 652;
        editIPtipbtn->Position->Y = 31;
        editIPtipbtn->Size->Width = 32;
        editIPtipbtn->Size->Height = 32;
        editIPtipbtn->Svg->Source = 
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"-6 -6 36 36\" fill=\"none\" stroke=\"#909090\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"feather feather-edit-3\"><path d=\"M12 20h9\"></path><path d=\"M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z\"></path></svg>";
        
        editIPtipbtn->Tag = Index;
        editIPtipbtn->OnMouseMove = ctrlIPtipbtnMouseMove;
        editIPtipbtn->OnMouseLeave = ctrlIPtipbtnMouseLeave;
        editIPtipbtn->OnClick = EditIPClick;
        editIPtipbtn->Visible = false;
        
        TSkSvg* deleteIPtipbtn = new TSkSvg(IPItem);
        deleteIPtipbtn->Parent = IPItem;
        deleteIPtipbtn->Name = "deleteIPtipbtn_" + IntToStr(Index);
        deleteIPtipbtn->Cursor = crHandPoint;
        deleteIPtipbtn->Hint = "删除提示词";
        deleteIPtipbtn->HitTest = true;
        deleteIPtipbtn->Position->X = 688;
        deleteIPtipbtn->Position->Y = 31;
        deleteIPtipbtn->Size->Width = 32;
        deleteIPtipbtn->Size->Height = 32;
        deleteIPtipbtn->Svg->Source = 
            "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"-6 -6 36 36\" fill=\"none\" stroke=\"#909090\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\" class=\"feather feather-trash-2\"><polyline points=\"3 6 5 6 21 6\"></polyline><path d=\"M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2\"></path><line x1=\"10\" y1=\"11\" x2=\"10\" y2=\"17\"></line><line x1=\"14\" y1=\"11\" x2=\"14\" y2=\"17\"></line></svg>";
        
        deleteIPtipbtn->Tag = Index;
        deleteIPtipbtn->OnMouseMove = ctrlIPtipbtnMouseMove;
        deleteIPtipbtn->OnMouseLeave = ctrlIPtipbtnMouseLeave;
        deleteIPtipbtn->OnClick = DeleteIPClick;
        deleteIPtipbtn->Visible = false;
        
        IPItem->Size->Width = 733;
        IPItem->Size->Height = 94;
        IPItem->Position->X = 8;
        
    } catch (...) {
        delete IPItem;
        throw;
    }
}

void Tmainform::UpdateLayout() {
    const float ITEM_SPACING = 7;
    const float MAX_HEIGHT = 475;
    const float NORMAL_WIDTH = 733;
    const float NARROW_WIDTH = 713;
    const float NORMAL_TIP_WIDTH = 610;
    const float NARROW_TIP_WIDTH = 590;
    const float EDIT_BTN_X_NORMAL = 652;
    const float DELETE_BTN_X_NORMAL = 688;
    const float EDIT_BTN_X_NARROW = 632;
    const float DELETE_BTN_X_NARROW = 668;
    
    float TotalHeight = 0;
    
    if (localIPitem != nullptr) {
        TotalHeight += localIPitem->Height + ITEM_SPACING;
    }
    
    for (int i = 0; i < FIPItems->Count; i++) {
        if ((*FIPItems)[i] == localIPitem) continue;
        
        (*FIPItems)[i]->Position->Y = TotalHeight;
        TotalHeight += (*FIPItems)[i]->Height + ITEM_SPACING;
    }
    
    bool NeedAdjustWidth = (TotalHeight + addIPtipbtn->Height) > MAX_HEIGHT;
    
    float ItemWidth, TipWidth, EditBtnX, DeleteBtnX;
    
    if (NeedAdjustWidth) {
        ItemWidth = NARROW_WIDTH;
        TipWidth = NARROW_TIP_WIDTH;
        EditBtnX = EDIT_BTN_X_NARROW;
        DeleteBtnX = DELETE_BTN_X_NARROW;
    } else {
        ItemWidth = NORMAL_WIDTH;
        TipWidth = NORMAL_TIP_WIDTH;
        EditBtnX = EDIT_BTN_X_NORMAL;
        DeleteBtnX = DELETE_BTN_X_NORMAL;
    }
    
    localIPitem->Width = ItemWidth;
    localIPtip->Width = TipWidth;
    localIPtipIP->Width = TipWidth;
    
    for (int i = 0; i < FIPItems->Count; i++) {
        if ((*FIPItems)[i] == localIPitem) continue;
        
        (*FIPItems)[i]->Width = ItemWidth;
        
        for (int j = 0; j < (*FIPItems)[i]->ChildrenCount; j++) {
            TFmxObject* Child = (*FIPItems)[i]->Children[j];
            
            if (dynamic_cast<TLabel*>(Child) != nullptr) {
                TLabel* Lbl = dynamic_cast<TLabel*>(Child);
                if (Lbl->Name.Pos("IPtip") > 0) {
                    Lbl->Width = TipWidth;
                }
            } else if (dynamic_cast<TSkSvg*>(Child) != nullptr) {
                TSkSvg* Svg = dynamic_cast<TSkSvg*>(Child);
                if (Svg->Name.Pos("edit") > 0) {
                    Svg->Position->X = EditBtnX;
                } else if (Svg->Name.Pos("delete") > 0) {
                    Svg->Position->X = DeleteBtnX;
                }
            } else if (dynamic_cast<TLine*>(Child) != nullptr) {
                TLine* Line = dynamic_cast<TLine*>(Child);
                if (NeedAdjustWidth) {
                    Line->Width = ItemWidth - 16;
                }
            }
        }
    }
    
    addIPtipbtn->Width = ItemWidth;
    addIPtipbtn->Position->X = 8;
    addIPtipbtn->Position->Y = TotalHeight;
}

void Tmainform::AddIPAlias(const String Name, const String IP) {
    TIPAliasItem Item;
    Item.Name = Name;
    Item.IP = IP;
    FIPAliases->Add(Item);
    
    SaveIPAliases();
    LoadIPAliases();
}

// ================== 事件处理 ==================
void __fastcall Tmainform::backgroundMouseDown(TObject* Sender, TMouseButton Button, TShiftState Shift, float X, float Y) {
    if (Button == TMouseButton::mbLeft) {
        #ifdef _WIN32
        HWND FormHandle = WindowHandleToPlatform(Handle)->Wnd;
        ReleaseCapture();
        PostMessage(FormHandle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
        #else
        StartWindowDrag();
        #endif
    }
}

void __fastcall Tmainform::ctrlbtnClick(TObject* Sender) {
    if (Sender == minimizeimage) {
        WindowState = TWindowState::wsMinimized;
    } else if (Sender == closeimage) {
        Application->Terminate();
    } else if (Sender == pinimage) {
        if (FIsTopMost) {
            #ifdef _WIN32
            HWND Wnd = FormToHWND(this);
            LONG Style = GetWindowLong(Wnd, GWL_EXSTYLE);
            SetWindowLong(Wnd, GWL_EXSTYLE, Style & ~WS_EX_TOPMOST);
            SetWindowPos(Wnd, HWND_NOTOPMOST, 0, 0, 0, 0,
                SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
            #else
            FormStyle = TFormStyle::Normal;
            #endif
            
            FIsTopMost = false;
            SaveConfigToFile("Window", "TopMost", BoolToStr(false, true));
        } else {
            #ifdef _WIN32
            HWND Wnd = FormToHWND(this);
            LONG Style = GetWindowLong(Wnd, GWL_EXSTYLE);
            SetWindowLong(Wnd, GWL_EXSTYLE, Style | WS_EX_TOPMOST);
            SetWindowPos(Wnd, HWND_TOPMOST, 0, 0, 0, 0,
                SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
            #else
            FormStyle = TFormStyle::StayOnTop;
            #endif
            
            FIsTopMost = true;
            SaveConfigToFile("Window", "TopMost", BoolToStr(true, true));
        }
        
        UpdatePinImageState();
    }
}

void __fastcall Tmainform::ctrlbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        if ((Sender == pinimage) && FIsTopMost) return;
        
        dynamic_cast<TSkSvg*>(Sender)->Opacity = 1;
    }
}

void __fastcall Tmainform::ctrlbtnMouseLeave(TObject* Sender) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        if ((Sender == pinimage) && FIsTopMost) return;
        
        dynamic_cast<TSkSvg*>(Sender)->Opacity = 0.6;
    }
}

void __fastcall Tmainform::appcardClosePopup(TObject* Sender) {
    websitebtn->Fill->Color = 0xFFFF4F4F;
    FappiconEffect = true;
    
    if (appicon->IsMouseOver) {
        appicon->Opacity = 0.9;
        appiconGlowEffect->Opacity = 0.8;
        appiconGlowEffect->Enabled = true;
    } else {
        appicon->Opacity = 0.8;
        appiconGlowEffect->Opacity = 0.6;
        appiconGlowEffect->Enabled = false;
    }
}

void __fastcall Tmainform::appiconClick(TObject* Sender) {
    appcard->IsOpen = true;
    FappiconEffect = false;
    appicon->Opacity = 1;
    appiconGlowEffect->Opacity = 1;
    appiconGlowEffect->Enabled = true;
}

void __fastcall Tmainform::appiconMouseLeave(TObject* Sender) {
    if (!FappiconEffect) return;
    appicon->Opacity = 0.8;
    appiconGlowEffect->Opacity = 0.6;
    appiconGlowEffect->Enabled = false;
}

void __fastcall Tmainform::appiconMouseMove(TObject* Sender, TShiftState Shift, float X, float Y) {
    if (!FappiconEffect) return;
    appicon->Opacity = 0.9;
    appiconGlowEffect->Opacity = 0.8;
    appiconGlowEffect->Enabled = true;
}

void __fastcall Tmainform::FormCreate(TObject* Sender) {
    Constraints->MinWidth = 882;
    Constraints->MaxWidth = 882;
    Constraints->MinHeight = 600;
    Constraints->MaxHeight = 600;
    Width = 882;
    Height = 600;
    
    #ifdef _WIN32
    HWND H = WindowHandleToPlatform(Handle)->Wnd;
    TRect WA;
    SystemParametersInfo(SPI_GETWORKAREA, 0, &WA, 0);
    TRect FR;
    GetWindowRect(H, &FR);
    int NewLeft = WA.Left + (WA.Width() - (FR.Right() - FR.Left())) / 2;
    int NewTop = WA.Top + (WA.Height() - (FR.Bottom() - FR.Top())) / 2;
    if (NewTop < WA.Top) NewTop = WA.Top;
    if (NewLeft < WA.Left) NewLeft = WA.Left;
    SetWindowPos(H, 0, NewLeft, NewTop, 0, 0, SWP_NOZORDER | SWP_NOSIZE);
    #endif
    
    guidecaption->Text = GetRandomGreeting();
    
    homelistdown->Visible = true;
    homelistup->Visible = false;
    localIPlabel->Text = "正在获取本机IP地址...";
    
    TThread::CreateAnonymousThread(
        [this]() {
            String IPInfo = GetIPAddressInfo();
            TThread::Queue(nullptr,
                [this, IPInfo]() {
                    localIPlabel->Text = IPInfo;
                });
        })->Start();
    
    SetActiveSidebarButton(homebtn);
    
    // 读取置顶设置
    String TopMostStr = LoadConfigFromFile("Window", "TopMost", "");
    FIsTopMost = StrToBoolDef(TopMostStr, false);
    
    if (FIsTopMost) {
        #ifdef _WIN32
        HWND Wnd = FormToHWND(this);
        SetWindowLong(Wnd, GWL_EXSTYLE, GetWindowLong(Wnd, GWL_EXSTYLE) | WS_EX_TOPMOST);
        SetWindowPos(Wnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        #else
        FormStyle = TFormStyle::StayOnTop;
        #endif
    } else {
        #ifdef _WIN32
        HWND Wnd = FormToHWND(this);
        SetWindowLong(Wnd, GWL_EXSTYLE, GetWindowLong(Wnd, GWL_EXSTYLE) & ~WS_EX_TOPMOST);
        SetWindowPos(Wnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        #else
        FormStyle = TFormStyle::Normal;
        #endif
    }
    UpdatePinImageState();
    
    FIPAliases = new TIPAliasList();
    FIPItems = new TList<TRectangle*>();
    FCurrentIPItem = nullptr;
    FappiconEffect = true;
    FCurrentActionBtn = nullptr;
    FCurrentActionType = "";
    FResponseProcessed = false;
    
    String CountStr = LoadConfigFromFile("Update", "StartupCount", "0");
    int StartupCount = StrToIntDef(CountStr, 0);
    if (StartupCount < 10) {
        StartupCount++;
        SaveConfigToFile("Update", "StartupCount", IntToStr(StartupCount));
    }
    
    LoadIPAliases();
    LoadUserConfig();
    UpdateAllUsernameDisplays();
    
    // 读取 Skia 设置
    String SkiaStr = LoadConfigFromFile("Graphics", "SkiaEnabled", "");
    skiaswitch->IsChecked = StrToBoolDef(SkiaStr, true);
    
    LoadOrCreateGUID();
    
    FUpdatingInProgress = false;
    CheckForUpdate(false);
}

void __fastcall Tmainform::FormResize(TObject* Sender) {
    if ((Width != 882) || (Height != 600)) {
        OnResize = nullptr;
        try {
            Width = 882;
            Height = 600;
        } catch (...) {
            OnResize = FormResize;
            throw;
        }
        OnResize = FormResize;
    }
}

void __fastcall Tmainform::sidebarbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y) {
    if (dynamic_cast<TControl*>(Sender) != nullptr) {
        if (Sender == sendbtn) {
            sendbtn->Svg->OverrideColor = 0xFFFF4F4F;
        } else if (Sender == endbtn) {
            endbtn->Svg->OverrideColor = 0xFFFF4F4F;
        } else if (Sender == cmdbtn) {
            cmdbtn->Svg->OverrideColor = 0xFFFF4F4F;
        } else if (Sender == homebtn) {
            homebtn->Svg->OverrideColor = 0xFFFF4F4F;
        } else if (Sender == mobilebtn) {
            mobilebtn->Svg->OverrideColor = 0xFFFF4F4F;
        } else if (Sender == settingsbtn) {
            settingsbtn->Svg->OverrideColor = 0xFFFF4F4F;
        }
    }
}

void __fastcall Tmainform::sidebarbtnMouseLeave(TObject* Sender) {
    if ((dynamic_cast<TControl*>(Sender) != nullptr) && (Sender != FActiveSidebarButton)) {
        if (Sender == sendbtn) {
            sendbtn->Svg->OverrideColor = 0;
        } else if (Sender == endbtn) {
            endbtn->Svg->OverrideColor = 0;
        } else if (Sender == cmdbtn) {
            cmdbtn->Svg->OverrideColor = 0;
        } else if (Sender == homebtn) {
            homebtn->Svg->OverrideColor = 0;
        } else if (Sender == mobilebtn) {
            mobilebtn->Svg->OverrideColor = 0;
        } else if (Sender == settingsbtn) {
            settingsbtn->Svg->OverrideColor = 0;
        }
    }
}

void __fastcall Tmainform::skiaswitchSwitch(TObject* Sender) {
    SaveConfigToFile("Graphics", "SkiaEnabled", BoolToStr(skiaswitch->IsChecked, true));
}

void __fastcall Tmainform::sidebarbtnClick(TObject* Sender) {
    if (dynamic_cast<TControl*>(Sender) != nullptr) {
        SetActiveSidebarButton(dynamic_cast<TControl*>(Sender));
    }
}

void __fastcall Tmainform::HomeButtonMouseMove(TObject* Sender, TShiftState Shift, float X, float Y) {
    if (dynamic_cast<TRectangle*>(Sender) != nullptr) {
        if (Sender == homelistbtn) {
            dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFE04141;
            return;
        }
        
        if (Shift.Contains(ssLeft)) {
            if (dynamic_cast<TRectangle*>(Sender)->IsMouseOver) {
                dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFFF7E7E;
            } else {
                dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFFF4F4F;
            }
        } else {
            dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFE04141;
        }
    } else if (dynamic_cast<TCircle*>(Sender) != nullptr) {
        if (Shift.Contains(ssLeft)) {
            if (dynamic_cast<TCircle*>(Sender)->IsMouseOver) {
                dynamic_cast<TCircle*>(Sender)->Opacity = 0.1;
            } else {
                dynamic_cast<TCircle*>(Sender)->Opacity = 0.2;
            }
        } else {
            dynamic_cast<TCircle*>(Sender)->Opacity = 0.4;
        }
    }
}

void __fastcall Tmainform::HomeButtonMouseUp(TObject* Sender, TMouseButton Button, TShiftState Shift, float X, float Y) {
    if (Button != TMouseButton::mbLeft) return;
    
    if (dynamic_cast<TRectangle*>(Sender) != nullptr) {
        if (Sender == homelistbtn) {
            dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFE04141;
        } else {
            dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFFF4F4F;
        }
    } else if (dynamic_cast<TCircle*>(Sender) != nullptr) {
        dynamic_cast<TCircle*>(Sender)->Opacity = 0.2;
    }
}

void __fastcall Tmainform::homelistpopupClosePopup(TObject* Sender) {
    homelistup->Visible = false;
    homelistdown->Visible = true;
    homeendbtn->Fill->Color = 0xFFFF4F4F;
    homecmdbtn->Fill->Color = 0xFFFF4F4F;
    
    if (homelistbtn->IsMouseOver) {
        homelistbtn->Fill->Color = 0xFFE04141;
    } else {
        homelistbtn->Fill->Color = 0xFFFF4F4F;
    }
}

void __fastcall Tmainform::HomeButtonMouseLeave(TObject* Sender) {
    if (dynamic_cast<TRectangle*>(Sender) != nullptr) {
        if ((Sender == homelistbtn) && homelistpopup->IsOpen) {
            dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFE04141;
            return;
        }
        
        dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFFF4F4F;
    } else if (dynamic_cast<TCircle*>(Sender) != nullptr) {
        dynamic_cast<TCircle*>(Sender)->Opacity = 0.2;
    }
}

void __fastcall Tmainform::HomeButtonMouseDown(TObject* Sender, TMouseButton Button, TShiftState Shift, float X, float Y) {
    if ((dynamic_cast<TRectangle*>(Sender) != nullptr) && (Button == TMouseButton::mbLeft)) {
        if (Sender == homelistbtn) return;
        
        dynamic_cast<TRectangle*>(Sender)->Fill->Color = 0xFFFF7E7E;
    } else if ((dynamic_cast<TCircle*>(Sender) != nullptr) && (Button == TMouseButton::mbLeft)) {
        dynamic_cast<TCircle*>(Sender)->Opacity = 0.1;
    }
}

void __fastcall Tmainform::HomeButtonClick(TObject* Sender) {
    if (Sender == homelistbtn) {
        homelistup->Visible = true;
        homelistdown->Visible = false;
        homelistpopup->IsOpen = true;
        homelistbtn->Fill->Color = 0xFFE04141;
    } else if (Sender == homesendbtn) {
        sidebarbtnClick(sendbtn);
        homelistpopup->IsOpen = false;
    } else if (Sender == homeendbtn) {
        sidebarbtnClick(endbtn);
        homelistpopup->IsOpen = false;
    } else if (Sender == homecmdbtn) {
        sidebarbtnClick(cmdbtn);
        homelistpopup->IsOpen = false;
    } else if (Sender == homecheckupdatebtn) {
        CheckForUpdate(true);
    } else if (Sender == homelocalIPbtn) {
        ShowHomeSubPage(THomeSubPage::hspLocalIP);
    } else if (Sender == homegithubbtn) {
        #ifdef _WIN32
        ShellExecute(0, L"open", L"https://github.com/StackNi/remote-control-platform/", L"", L"", SW_SHOWNORMAL);
        #endif
        #ifdef __APPLE__
        _system("open https://github.com/StackNi/remote-control-platform/");
        #endif
        #ifdef __linux__
        _system("xdg-open https://github.com/StackNi/remote-control-platform/");
        #endif
    } else if (Sender == homedonatebtn) {
        ShowHomeSubPage(THomeSubPage::hspDonate);
    } else if (Sender == websitebtn) {
        #ifdef _WIN32
        ShellExecute(0, L"open", L"https://stackni.github.io/remote-control-platform/", L"", L"", SW_SHOWNORMAL);
        #endif
        #ifdef __APPLE__
        _system("open https://stackni.github.io/remote-control-platform/");
        #endif
        #ifdef __linux__
        _system("xdg-open https://stackni.github.io/remote-control-platform/");
        #endif
    }
}

void __fastcall Tmainform::SettingsButtonClick(TObject* Sender) {
    if (Sender == changeusernamebtn) {
        ShowSettingsSubPage(TSettingsSubPage::sspChangeUsername);
    } else if (Sender == changeIPlistbtn) {
        ShowSettingsSubPage(TSettingsSubPage::sspChangeIPList);
    }
}

void __fastcall Tmainform::backbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        dynamic_cast<TSkSvg*>(Sender)->Opacity = 1.0;
    }
}

void __fastcall Tmainform::backbtnMouseLeave(TObject* Sender) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        dynamic_cast<TSkSvg*>(Sender)->Opacity = 0.6;
    }
}

void __fastcall Tmainform::backbtnClick(TObject* Sender) {
    if (Sender == backfromlocalIPbtn) {
        HandleBackButtonClick("localIP");
    } else if (Sender == backfromdonatebtn) {
        HandleBackButtonClick("donate");
    } else if (Sender == backfromchangeusernamebtn) {
        HandleBackButtonClick("changeusername");
    } else if (Sender == backfromchangeIPlistbtn) {
        HandleBackButtonClick("changeIPlist");
    }
}

void __fastcall Tmainform::refreshlocalIPbtnClick(TObject* Sender) {
    localIPlabel->Text = GetIPAddressInfo();
    
    refreshlocalIPbtn->Text = "已刷新";
    refreshlocalIPbtn->Enabled = false;
    
    TThread::CreateAnonymousThread(
        []() {
            Sleep(1000);
            TThread::Queue(nullptr,
                []() {
                    refreshlocalIPbtn->Text = "刷新";
                    refreshlocalIPbtn->Enabled = true;
                });
        })->Start();
}

void __fastcall Tmainform::copylocalIPbtnClick(TObject* Sender) {
    _di_IFMXClipboardService ClipboardService;
    
    if (TPlatformServices::Current->SupportsPlatformService(
        __uuidof(IFMXClipboardService), (void**)&ClipboardService)) {
        ClipboardService->SetClipboard(localIPlabel->Text);
        
        copylocalIPbtn->Text = "已复制";
        copylocalIPbtn->Enabled = false;
        
        TThread::CreateAnonymousThread(
            []() {
                Sleep(1000);
                TThread::Queue(nullptr,
                    []() {
                        copylocalIPbtn->Text = "复制";
                        copylocalIPbtn->Enabled = true;
                    });
            })->Start();
    } else {
        TDialogService::MessageDialog("无法访问剪贴板",
            TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
    }
}

void __fastcall Tmainform::newusernamebtnClick(TObject* Sender) {
    String InputText = newusernametext->Text.Trim();
    
    if (InputText == "") {
        FCurrentUsername = "默认用户";
    } else {
        FCurrentUsername = InputText;
    }
    
    SaveUserConfig();
    UpdateAllUsernameDisplays();
    
    TDialogService::MessageDialog("用户名已更改为: " + FCurrentUsername,
        TMsgDlgType::mtInformation, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
    
    newusernametext->Text = "";
    HandleBackButtonClick("changeusername");
}

void __fastcall Tmainform::msgdurationspinbtnDownClick(TObject* Sender) {
    Int64 Value;
    if (msgdurationtext->Text == "") {
        msgdurationtext->Text = "0";
    } else if (TryStrToInt64(msgdurationtext->Text, Value)) {
        if (Value > 0) {
            msgdurationtext->Text = IntToStr(Value - 1);
        }
    }
}

void __fastcall Tmainform::msgdurationspinbtnUpClick(TObject* Sender) {
    Int64 Value;
    if (msgdurationtext->Text == "") {
        msgdurationtext->Text = "1";
    } else if (TryStrToInt64(msgdurationtext->Text, Value)) {
        if (Value < High(Int64)) {
            msgdurationtext->Text = IntToStr(Value + 1);
        }
    }
}

void __fastcall Tmainform::msgdurationspinbtnMouseWheel(TObject* Sender, TShiftState Shift, int WheelDelta, bool& Handled) {
    if (msgdurationtext->IsFocused) {
        if (WheelDelta > 0) {
            msgdurationspinbtnUpClick(msgdurationspinbtn);
        } else {
            msgdurationspinbtnDownClick(msgdurationspinbtn);
        }
        Handled = true;
    } else {
        Handled = false;
    }
}

// ================== 按钮效果事件 ==================
void __fastcall Tmainform::ctrlIPtipbtnMouseMove(TObject* Sender, TShiftState Shift, float X, float Y) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        TSkSvg* Svg = dynamic_cast<TSkSvg*>(Sender);
        
        if (Svg->Name.Pos("edit") > 0) {
            Svg->Svg->OverrideColor = 0xFF4FFF4F;
        } else if (Svg->Name.Pos("delete") > 0) {
            Svg->Svg->OverrideColor = 0xFFFF4F4F;
        }
        
        if ((Svg->Parent != nullptr) && (dynamic_cast<TRectangle*>(Svg->Parent) != nullptr)) {
            TRectangle* ParentRect = dynamic_cast<TRectangle*>(Svg->Parent);
            FCurrentIPItem = ParentRect;
            ShowIPitemButtons(ParentRect);
        }
    }
}

void __fastcall Tmainform::ctrlIPtipbtnMouseLeave(TObject* Sender) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        TSkSvg* Svg = dynamic_cast<TSkSvg*>(Sender);
        Svg->Svg->OverrideColor = 0;
    }
}

void __fastcall Tmainform::IPitemMouseMove(TObject* Sender, TShiftState Shift, float X, float Y) {
    if (dynamic_cast<TRectangle*>(Sender) != nullptr) {
        TRectangle* Rect = dynamic_cast<TRectangle*>(Sender);
        
        if (Rect == localIPitem) return;
        
        if ((FCurrentIPItem != nullptr) && (FCurrentIPItem != Rect) && (FCurrentIPItem != localIPitem)) {
            HideIPitemButtons(FCurrentIPItem);
        }
        
        FCurrentIPItem = Rect;
        ShowIPitemButtons(Rect);
    }
}

void __fastcall Tmainform::IPitemMouseLeave(TObject* Sender) {
    if (dynamic_cast<TRectangle*>(Sender) != nullptr) {
        TRectangle* Rect = dynamic_cast<TRectangle*>(Sender);
        
        if (Rect == localIPitem) return;
        
        if ((Rect != nullptr) && (Rect == FCurrentIPItem)) {
            HideIPitemButtons(Rect);
            FCurrentIPItem = nullptr;
        }
    }
}

void Tmainform::ShowIPitemButtons(TRectangle* IPitem) {
    if ((IPitem == nullptr) || (IPitem == localIPitem)) return;
    
    for (int i = 0; i < IPitem->ChildrenCount; i++) {
        if (dynamic_cast<TSkSvg*>(IPitem->Children[i]) != nullptr) {
            TSkSvg* Svg = dynamic_cast<TSkSvg*>(IPitem->Children[i]);
            if (Svg->Name.Pos("edit") > 0) {
                Svg->Visible = true;
            } else if (Svg->Name.Pos("delete") > 0) {
                Svg->Visible = true;
            }
        }
    }
}

void Tmainform::HideIPitemButtons(TRectangle* IPitem) {
    if ((IPitem == nullptr) || (IPitem == localIPitem)) return;
    
    for (int i = 0; i < IPitem->ChildrenCount; i++) {
        if (dynamic_cast<TSkSvg*>(IPitem->Children[i]) != nullptr) {
            TSkSvg* Svg = dynamic_cast<TSkSvg*>(IPitem->Children[i]);
            if (Svg->Name.Pos("edit") > 0) {
                Svg->Visible = false;
            } else if (Svg->Name.Pos("delete") > 0) {
                Svg->Visible = false;
            }
        }
    }
}

void __fastcall Tmainform::addIPtipbtnClick(TObject* Sender) {
    String Name, IP;
    
    TDialogService::InputQuery("添加提示词",
        {"输入提示词:"},
        {""},
        [this, &Name, &IP](const TModalResult AResult, const TArray<String>& AValues) {
            if (AResult == mrOk) {
                Name = AValues[0].Trim();
                
                if (Name == "") {
                    TDialogService::MessageDialog("提示词不能为空！",
                        TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                    return;
                }
                
                if (Name == "本地回环") {
                    TDialogService::MessageDialog("不能使用保留提示词！",
                        TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                    return;
                }
                
                for (const auto& Item : *FIPAliases) {
                    if (Item.Name == Name) {
                        TDialogService::MessageDialog("该提示词已存在！",
                            TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                        return;
                    }
                }
                
                TDialogService::InputQuery("添加提示词",
                    {"输入对应IP地址:"},
                    {""},
                    [this, &Name, &IP](const TModalResult AResult2, const TArray<String>& AValues2) {
                        if (AResult2 == mrOk) {
                            IP = AValues2[0].Trim();
                            
                            if (!ValidateIPAddress(IP)) {
                                TDialogService::MessageDialog("请输入有效的IPv4地址！",
                                    TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                                return;
                            }
                            
                            AddIPAlias(Name, IP);
                            
                            TDialogService::MessageDialog("添加成功！",
                                TMsgDlgType::mtInformation, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                        }
                    });
            }
        });
}

// ================== 修改提示词 ==================
void __fastcall Tmainform::EditIPClick(TObject* Sender) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        int Index = dynamic_cast<TSkSvg*>(Sender)->Tag;
        
        if ((Index < 0) || (Index >= FIPAliases->Count)) {
            LoadIPAliases();
            return;
        }
        
        String CurrentName = (*FIPAliases)[Index].Name;
        
        TDialogService::InputQuery("修改提示词",
            {"输入新的提示词:"},
            {CurrentName},
            [this, Index](const TModalResult AResult, const TArray<String>& AValues) {
                if (AResult != mrOk) return;
                
                String NewName = AValues[0].Trim();
                
                if (NewName == "") {
                    TDialogService::MessageDialog("提示词不能为空！",
                        TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                    return;
                }
                
                if (NewName == "本地回环") {
                    TDialogService::MessageDialog("不能使用保留提示词！",
                        TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                    return;
                }
                
                for (int i = 0; i < FIPAliases->Count; i++) {
                    if ((i != Index) && ((*FIPAliases)[i].Name == NewName)) {
                        TDialogService::MessageDialog("该提示词已存在！",
                            TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                        return;
                    }
                }
                
                TIPAliasItem Item = (*FIPAliases)[Index];
                Item.Name = NewName;
                (*FIPAliases)[Index] = Item;
                
                SaveIPAliases();
                LoadIPAliases();
                
                TDialogService::MessageDialog("提示词修改成功！",
                    TMsgDlgType::mtInformation, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
            });
    }
}

void __fastcall Tmainform::DeleteIPClick(TObject* Sender) {
    if (dynamic_cast<TSkSvg*>(Sender) != nullptr) {
        int Index = dynamic_cast<TSkSvg*>(Sender)->Tag;
        
        if ((Index < 0) || (Index >= FIPAliases->Count)) {
            LoadIPAliases();
            return;
        }
        
        TDialogService::MessageDialog("确定要删除该提示词吗？",
            TMsgDlgType::mtConfirmation,
            {TMsgDlgBtn::mbYes, TMsgDlgBtn::mbNo},
            TMsgDlgBtn::mbNo,
            0,
            [this, Index](const TModalResult AResult) {
                if (AResult == mrYes) {
                    FIPAliases->Delete(Index);
                    SaveIPAliases();
                    LoadIPAliases();
                }
            });
    }
}

// ================== 处理目标IP ==================
bool Tmainform::ValidateAndGetTargetIP(const String InputText, String& TargetIP) {
    TargetIP = InputText.Trim();
    
    if (TargetIP == "") {
        TDialogService::MessageDialog("请输入目标IP地址或提示词！",
            TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
        return false;
    }
    
    if (TargetIP == "本地回环") {
        TargetIP = "127.0.0.1";
        return true;
    } else {
        for (const auto& Item : *FIPAliases) {
            if (Item.Name == TargetIP) {
                TargetIP = Item.IP;
                break;
            }
        }
        
        if (!ValidateIPAddress(TargetIP)) {
            TDialogService::MessageDialog("请输入有效的IPv4地址或提示词！",
                TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
            return false;
        }
    }
    
    return true;
}

// ================== 检查本地网络 ==================
bool Tmainform::CheckLocalNetworkAvailable() {
    bool Result = GStack->LocalAddresses->Count > 0;
    if (!Result) {
        TDialogService::MessageDialog("未找到可用IP，请检查网络设置",
            TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
    }
    return Result;
}

// ================== 禁用所有发送按钮 ==================
void Tmainform::DisableSendButtons() {
    sendmsgbtn->Enabled = false;
    endmsgbtn->Enabled = false;
    sendcmdbtn->Enabled = false;
}

// ================== 启用所有发送按钮 ==================
void Tmainform::EnableSendButtons() {
    sendmsgbtn->Enabled = true;
    endmsgbtn->Enabled = true;
    sendcmdbtn->Enabled = true;
}

// ================== 延迟3秒恢复发送按钮 ==================
void Tmainform::ResetActionButton() {
    if (FCurrentActionBtn != nullptr) {
        TThread::CreateAnonymousThread(
            [this]() {
                Sleep(3000);
                TThread::Queue(nullptr,
                    [this]() {
                        if (FCurrentActionBtn != nullptr) {
                            if (FCurrentActionType == "send") {
                                FCurrentActionBtn->Text = "发送消息";
                            } else if (FCurrentActionType == "end") {
                                FCurrentActionBtn->Text = "结束消息";
                            } else if (FCurrentActionType == "cmd") {
                                FCurrentActionBtn->Text = "发送cmd命令";
                            } else {
                                FCurrentActionBtn->Text = "发送UDP";
                            }
                            
                            FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Black;
                            EnableSendButtons();
                            FCurrentActionBtn = nullptr;
                            FCurrentActionType = "";
                            FResponseProcessed = false;
                            FCurrentRequestID = "";
                        }
                    });
            })->Start();
    }
}

// ================== mainUDP接收处理 ==================
void __fastcall Tmainform::mainUDPUDPRead(TIdUDPListenerThread* AThread, const TIdBytes AData, TIdSocketHandle* ABinding) {
    String ReceivedText = IndyTextEncoding_UTF8->GetString(AData).Trim();
    
    TArray<String> Lines = ReceivedText.Split({"\n"});
    
    if (Lines.Length < 2) return;
    
    String RequestID = Trim(Lines[0]);
    
    if (RequestID != FCurrentRequestID) return;
    
    String Status = Trim(Lines[1]);
    
    Timeout->Enabled = false;
    
    // ========== 结束消息特殊处理 ==========
    if (FCurrentActionType == "end") {
        if (Status == "ERR") {
            String ErrorMsg = "";
            for (int i = 2; i < Lines.Length; i++) {
                if (ErrorMsg != "") ErrorMsg += "\n";
                ErrorMsg += Lines[i];
            }
            ErrorMsg = ErrorMsg.Trim();
            
            FResponseProcessed = true;
            
            TThread::Queue(nullptr,
                [this, ErrorMsg]() {
                    if (FCurrentActionBtn != nullptr) {
                        FCurrentActionBtn->Text = "关闭消息失败";
                        FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Red;
                        Application->ProcessMessages();
                        ResetActionButton();
                    }
                    
                    TDialogService::MessageDialog("来自接收端的错误: " + ErrorMsg,
                        TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                });
            
            FCurrentRequestID = "";
            return;
        }
        
        int Count;
        if (TryStrToInt(Status, Count)) {
            FResponseProcessed = true;
            
            TThread::Queue(nullptr,
                [this, Count]() {
                    if (FCurrentActionBtn != nullptr) {
                        if (Count > 0) {
                            FCurrentActionBtn->Text = "成功关闭 " + IntToStr(Count) + " 个消息窗口";
                            FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Green;
                        } else {
                            FCurrentActionBtn->Text = "没有正在展示的消息窗口";
                            FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Yellow;
                        }
                        Application->ProcessMessages();
                        ResetActionButton();
                    }
                });
            
            FCurrentRequestID = "";
            return;
        }
        
        FCurrentRequestID = "";
        return;
    }
    
    // ========== 通用处理（send / cmd） ==========
    if (Status == "OK") {
        FResponseProcessed = true;
        
        TThread::Queue(nullptr,
            [this]() {
                if (FCurrentActionBtn != nullptr) {
                    if (FCurrentActionType == "send") {
                        FCurrentActionBtn->Text = "对方已确认收到消息";
                    } else if (FCurrentActionType == "cmd") {
                        FCurrentActionBtn->Text = "cmd命令执行成功";
                    } else {
                        FCurrentActionBtn->Text = "操作成功";
                    }
                    
                    FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Green;
                    Application->ProcessMessages();
                    ResetActionButton();
                }
            });
        
        FCurrentRequestID = "";
        return;
    }
    
    if (Status == "ERR") {
        String ErrorMsg = "";
        for (int i = 2; i < Lines.Length; i++) {
            if (ErrorMsg != "") ErrorMsg += "\n";
            ErrorMsg += Lines[i];
        }
        ErrorMsg = ErrorMsg.Trim();
        
        FResponseProcessed = true;
        
        TThread::Queue(nullptr,
            [this, ErrorMsg]() {
                if (FCurrentActionBtn != nullptr) {
                    if (FCurrentActionType == "send") {
                        FCurrentActionBtn->Text = "消息接收失败";
                    } else if (FCurrentActionType == "cmd") {
                        FCurrentActionBtn->Text = "cmd命令执行失败";
                    } else {
                        FCurrentActionBtn->Text = "操作失败";
                    }
                    
                    FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Red;
                    Application->ProcessMessages();
                    ResetActionButton();
                }
                
                TDialogService::MessageDialog("来自接收端的错误: " + ErrorMsg,
                    TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
            });
        
        FCurrentRequestID = "";
        return;
    }
    
    FCurrentRequestID = "";
}

// ================== mainUDP异常处理 ==================
void __fastcall Tmainform::mainUDPUDPException(TIdUDPListenerThread* AThread, TIdSocketHandle* ABinding, const String AMessage, const TClass AExceptionClass) {
    int ErrorCode = ExtractSocketErrorCode(AMessage);
    
    TThread::Queue(nullptr,
        [this, AMessage, AExceptionClass, ErrorCode]() {
            String ButtonMsg, ErrorMsg, DisplayMsg;
            
            switch (ErrorCode) {
                case 10054: case 104:
                    ButtonMsg = "接收端未就绪";
                    ErrorMsg = "目标设备的接收端程序未运行，连接被重置";
                    break;
                case 10061: case 111:
                    ButtonMsg = "连接被拒";
                    ErrorMsg = "对方拒绝了连接，请检查防火墙设置";
                    break;
                case 10060: case 110:
                    ButtonMsg = "响应超时";
                    ErrorMsg = "等待对方响应超时，请检查网络连接";
                    break;
                case 10065: case 113:
                    ButtonMsg = "主机不可达";
                    ErrorMsg = "目标主机不可达，请检查IP地址是否可用";
                    break;
                case 10051: case 101:
                    ButtonMsg = "网络不可达";
                    ErrorMsg = "目标网络不可达，请检查网络设置";
                    break;
                case 10064: case 112:
                    ButtonMsg = "对方已离线";
                    ErrorMsg = "目标主机已关机或离线";
                    break;
                case 10013: case 13:
                    ButtonMsg = "权限不足";
                    ErrorMsg = "您无权访问";
                    break;
                case 10048: case 98:
                    ButtonMsg = "端口被占用";
                    ErrorMsg = "端口已被占用，请关闭占用程序";
                    break;
                case 10049: case 99:
                    ButtonMsg = "地址无效";
                    ErrorMsg = "IP地址不可用，请检查输入是否正确";
                    break;
                case 10040: case 90:
                    ButtonMsg = "数据包过大";
                    ErrorMsg = "发送的数据包超过大小限制";
                    break;
                case 10004: case 4:
                    ButtonMsg = "操作中断";
                    ErrorMsg = "网络操作被系统中断";
                    break;
                case 10014: case 14:
                    ButtonMsg = "系统错误";
                    ErrorMsg = "系统网络地址错误";
                    break;
                case 10022: case 22:
                    ButtonMsg = "参数错误";
                    ErrorMsg = "网络参数设置错误";
                    break;
                case 10024: case 24:
                    ButtonMsg = "系统资源不足";
                    ErrorMsg = "系统打开文件过多，请关闭一些程序";
                    break;
                case 10035: case 11:
                    ButtonMsg = "操作阻塞";
                    ErrorMsg = "网络操作暂时无法完成，请稍后重试";
                    break;
                case 10036: case 115:
                    ButtonMsg = "操作进行中";
                    ErrorMsg = "网络操作正在进行中";
                    break;
                case 10037: case 114:
                    ButtonMsg = "操作已开始";
                    ErrorMsg = "网络操作已在进行中";
                    break;
                case 10038: case 88:
                    ButtonMsg = "套接字错误";
                    ErrorMsg = "网络套接字无效，请重启程序";
                    break;
                case 10039: case 89:
                    ButtonMsg = "地址缺失";
                    ErrorMsg = "需要指定目标地址";
                    break;
                case 10041: case 41:
                    ButtonMsg = "协议错误";
                    ErrorMsg = "网络协议类型错误";
                    break;
                case 10042: case 42:
                    ButtonMsg = "协议选项错误";
                    ErrorMsg = "不支持的协议选项";
                    break;
                case 10043: case 43:
                    ButtonMsg = "协议不支持";
                    ErrorMsg = "不支持的网络协议";
                    break;
                case 10044: case 44:
                    ButtonMsg = "套接字不支持";
                    ErrorMsg = "不支持的套接字类型";
                    break;
                case 10045: case 95:
                    ButtonMsg = "操作不支持";
                    ErrorMsg = "不支持的网络操作";
                    break;
                case 10046: case 96:
                    ButtonMsg = "协议族不支持";
                    ErrorMsg = "不支持的协议族";
                    break;
                case 10047: case 97:
                    ButtonMsg = "地址族不支持";
                    ErrorMsg = "不支持的地址类型";
                    break;
                case 10050: case 100:
                    ButtonMsg = "网络断开";
                    ErrorMsg = "网络连接已断开";
                    break;
                case 10052: case 102:
                    ButtonMsg = "网络重置";
                    ErrorMsg = "网络连接被重置";
                    break;
                case 10053: case 103:
                    ButtonMsg = "连接中止";
                    ErrorMsg = "连接被中止";
                    break;
                case 10055: case 105:
                    ButtonMsg = "缓冲区不足";
                    ErrorMsg = "网络缓冲区不足，请稍后重试";
                    break;
                case 10056: case 106:
                    ButtonMsg = "已连接";
                    ErrorMsg = "套接字已处于连接状态";
                    break;
                case 10057: case 107:
                    ButtonMsg = "未连接";
                    ErrorMsg = "套接字未建立连接";
                    break;
                case 10058: case 108:
                    ButtonMsg = "连接已关闭";
                    ErrorMsg = "连接已被关闭";
                    break;
                case 10059: case 109:
                    ButtonMsg = "引用过多";
                    ErrorMsg = "网络连接引用过多";
                    break;
                case 10062: case 40:
                    ButtonMsg = "路由循环";
                    ErrorMsg = "检测到路由循环";
                    break;
                case 10063: case 36:
                    ButtonMsg = "名称过长";
                    ErrorMsg = "主机名或路径过长";
                    break;
                case 10091:
                    ButtonMsg = "网络未就绪";
                    ErrorMsg = "网络子系统未准备好";
                    break;
                case 10092:
                    ButtonMsg = "版本不支持";
                    ErrorMsg = "Windows Sockets版本不支持";
                    break;
                case 10093:
                    ButtonMsg = "网络未初始化";
                    ErrorMsg = "网络组件未初始化，请重启程序";
                    break;
                case 10109:
                    ButtonMsg = "服务错误";
                    ErrorMsg = "网络服务供应方初始化失败";
                    break;
                case 11001: case 2:
                    ButtonMsg = "主机未找到";
                    ErrorMsg = "无法解析主机名，请检查DNS设置";
                    break;
                case 11002:
                    ButtonMsg = "DNS错误";
                    ErrorMsg = "DNS解析失败，请稍后重试";
                    break;
                case 11003:
                    ButtonMsg = "DNS错误";
                    ErrorMsg = "DNS解析不可恢复的错误";
                    break;
                case 11004:
                    ButtonMsg = "DNS无记录";
                    ErrorMsg = "DNS请求成功但无记录";
                    break;
                default:
                    ButtonMsg = "发生未知错误";
                    ErrorMsg = "未知错误";
                    break;
            }
            
            DisplayMsg = "消息接收失败: " + ErrorMsg + "\r\n" +
                        "错误信息: " + AMessage + "\r\n" +
                        "异常类型: " + AExceptionClass->ClassName();
            
            if (FCurrentActionBtn != nullptr) {
                FCurrentActionBtn->Text = ButtonMsg;
                FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Yellow;
                Application->ProcessMessages();
                ResetActionButton();
            }
            
            TDialogService::MessageDialog(DisplayMsg,
                TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
        });
}

// ================== 10秒计时器 ==================
void __fastcall Tmainform::TimeoutTimer(TObject* Sender) {
    Timeout->Enabled = false;
    
    if ((FCurrentActionBtn == nullptr) || FCurrentActionBtn->Enabled || FResponseProcessed) return;
    
    FCurrentRequestID = "";
    
    String FinalText;
    
    if (FCurrentActionType == "send") {
        FinalText = "消息已发出，未收到对方确认";
    } else if (FCurrentActionType == "end") {
        FinalText = "结束命令已发出，未收到对方确认";
    } else if (FCurrentActionType == "cmd") {
        FinalText = "cmd命令已发出，执行状态未知";
    } else {
        FinalText = "操作已完成";
    }
    
    FResponseProcessed = true;
    
    if (FCurrentActionBtn != nullptr) {
        FCurrentActionBtn->Text = FinalText;
        FCurrentActionBtn->TextSettings->FontColor = TAlphaColorRec::Darkviolet;
    }
    
    ResetActionButton();
}

// ================== 发送消息 ==================
void __fastcall Tmainform::sendmsgbtnClick(TObject* Sender) {
    String TargetIP, MessageContent, DurationStr, DisplayModeStr;
    String JSONStr;
    
    if (!ValidateAndGetTargetIP(sendIPtext->Text.Trim(), TargetIP)) return;
    if (!CheckLocalNetworkAvailable()) return;
    
    MessageContent = msgtext->Text.Trim();
    
    if (MessageContent == "") {
        TDialogService::MessageDialog("消息不能为空！",
            TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
        return;
    }
    
    DurationStr = msgdurationtext->Text.Trim();
    if ((DurationStr == "") || (DurationStr == "0")) {
        DurationStr = "-1";
    }
    
    if (normal->IsChecked) {
        DisplayModeStr = "NORMAL";
    } else if (typewriter->IsChecked) {
        DisplayModeStr = "TYPEWRITER";
    } else if (blink->IsChecked) {
        DisplayModeStr = "BLINK";
    } else if (fullscreen->IsChecked) {
        DisplayModeStr = "FULLSCREEN";
    } else {
        DisplayModeStr = "MARQUEE";
    }
    
    if (!manualcloseSwitch->IsChecked) {
        DisplayModeStr += "_NOCLOSE";
    }
    
    try {
        FCurrentRequestID = TGUID::NewGuid().ToString();
        JSONStr = BuildMessageJSON(FDeviceGUID, FCurrentUsername, MessageContent, DurationStr, DisplayModeStr, FCurrentRequestID);
        
        Timeout->Enabled = false;
        FResponseProcessed = false;
        
        mainUDP->Send(TargetIP, 25105, JSONStr, IndyTextEncoding_UTF8);
        
        FCurrentActionBtn = sendmsgbtn;
        FCurrentActionType = "send";
        sendmsgbtn->Text = "消息已发送，等待对方接收...";
        sendmsgbtn->TextSettings->FontColor = TAlphaColorRec::Black;
        
        DisableSendButtons();
        Timeout->Enabled = true;
        
    } catch (Exception& E) {
        FCurrentActionBtn = sendmsgbtn;
        FCurrentActionType = "send";
        
        int ErrorCode = ExtractSocketErrorCode(E.Message());
        String FriendlyMsg;
        
        switch (ErrorCode) {
            case 10054: case 104: FriendlyMsg = "目标设备未响应，请检查对方是否在线"; break;
            case 10061: case 111: FriendlyMsg = "对方拒绝了连接，请检查防火墙设置"; break;
            case 10060: case 110: FriendlyMsg = "发送超时，请检查网络连接"; break;
            case 10065: case 113: FriendlyMsg = "目标主机不可达，请检查IP地址是否可用"; break;
            case 10051: case 101: FriendlyMsg = "目标网络不可达，请检查网络设置"; break;
            case 10064: case 112: FriendlyMsg = "目标主机已关机或离线"; break;
            case 10013: case 13: FriendlyMsg = "您无权访问"; break;
            case 10048: case 98: FriendlyMsg = "端口已被占用，请关闭占用程序"; break;
            case 10049: case 99: FriendlyMsg = "IP地址不可用，请检查输入是否正确"; break;
            default: FriendlyMsg = E.Message(); break;
        }
        
        sendmsgbtn->Text = "消息发送失败";
        sendmsgbtn->TextSettings->FontColor = TAlphaColorRec::Red;
        Application->ProcessMessages();
        
        FCurrentRequestID = "";
        DisableSendButtons();
        ResetActionButton();
        
        TDialogService::MessageDialog("消息发送失败: " + FriendlyMsg + "\r\n" +
                                     "错误信息: " + E.Message() + "\r\n" +
                                     "异常类型: " + E.ClassName(),
            TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
    }
}

// ================== 结束消息 ==================
void __fastcall Tmainform::endmsgbtnClick(TObject* Sender) {
    String TargetIP;
    String JSONStr;
    
    if (!ValidateAndGetTargetIP(endIPtext->Text.Trim(), TargetIP)) return;
    if (!CheckLocalNetworkAvailable()) return;
    
    try {
        FCurrentRequestID = TGUID::NewGuid().ToString();
        JSONStr = BuildCloseJSON(FDeviceGUID, FCurrentUsername, FCurrentRequestID);
        
        Timeout->Enabled = false;
        FResponseProcessed = false;
        
        mainUDP->Send(TargetIP, 25105, JSONStr, IndyTextEncoding_UTF8);
        
        FCurrentActionBtn = endmsgbtn;
        FCurrentActionType = "end";
        endmsgbtn->Text = "结束命令已发送，等待对方响应...";
        endmsgbtn->TextSettings->FontColor = TAlphaColorRec::Black;
        
        DisableSendButtons();
        Timeout->Enabled = true;
        
    } catch (Exception& E) {
        FCurrentActionBtn = endmsgbtn;
        FCurrentActionType = "end";
        
        int ErrorCode = ExtractSocketErrorCode(E.Message());
        String FriendlyMsg;
        
        switch (ErrorCode) {
            case 10054: case 104: FriendlyMsg = "目标设备未响应，请检查对方是否在线"; break;
            case 10061: case 111: FriendlyMsg = "对方拒绝了连接，请检查防火墙设置"; break;
            case 10060: case 110: FriendlyMsg = "发送超时，请检查网络连接"; break;
            case 10065: case 113: FriendlyMsg = "目标主机不可达，请检查IP地址是否可用"; break;
            case 10051: case 101: FriendlyMsg = "目标网络不可达，请检查网络设置"; break;
            case 10064: case 112: FriendlyMsg = "目标主机已关机或离线"; break;
            case 10013: case 13: FriendlyMsg = "您无权访问"; break;
            case 10048: case 98: FriendlyMsg = "端口已被占用，请关闭占用程序"; break;
            case 10049: case 99: FriendlyMsg = "IP地址不可用，请检查输入是否正确"; break;
            default: FriendlyMsg = E.Message(); break;
        }
        
        endmsgbtn->Text = "结束命令发送失败";
        endmsgbtn->TextSettings->FontColor = TAlphaColorRec::Red;
        Application->ProcessMessages();
        
        FCurrentRequestID = "";
        DisableSendButtons();
        ResetActionButton();
        
        TDialogService::MessageDialog("消息发送失败: " + FriendlyMsg + "\r\n" +
                                     "错误信息: " + E.Message() + "\r\n" +
                                     "异常类型: " + E.ClassName(),
            TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
    }
}

// ================== 发送cmd命令 ==================
void __fastcall Tmainform::sendcmdbtnClick(TObject* Sender) {
    String TargetIP, CommandContent, PermissionStr;
    int TargetPort;
    String JSONStr;
    
    if (!ValidateAndGetTargetIP(cmdIPtext->Text.Trim(), TargetIP)) return;
    if (!CheckLocalNetworkAvailable()) return;
    
    CommandContent = cmdtext->Text.Trim();
    
    if (CommandContent == "") {
        TDialogService::MessageDialog("cmd命令不能为空！",
            TMsgDlgType::mtWarning, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
        return;
    }
    
    if (user->IsChecked) {
        PermissionStr = "USER";
        TargetPort = 25105;
    } else {
        PermissionStr = "SYSTEM";
        TargetPort = 25106;
    }
    
    try {
        FCurrentRequestID = TGUID::NewGuid().ToString();
        JSONStr = BuildCmdJSON(FDeviceGUID, FCurrentUsername, CommandContent, PermissionStr, FCurrentRequestID);
        
        Timeout->Enabled = false;
        FResponseProcessed = false;
        
        mainUDP->Send(TargetIP, TargetPort, JSONStr, IndyTextEncoding_UTF8);
        
        FCurrentActionBtn = sendcmdbtn;
        FCurrentActionType = "cmd";
        sendcmdbtn->Text = "cmd命令已发送，等待执行结果...";
        sendcmdbtn->TextSettings->FontColor = TAlphaColorRec::Black;
        
        DisableSendButtons();
        Timeout->Enabled = true;
        
    } catch (Exception& E) {
        FCurrentActionBtn = sendcmdbtn;
        FCurrentActionType = "cmd";
        
        int ErrorCode = ExtractSocketErrorCode(E.Message());
        String FriendlyMsg;
        
        switch (ErrorCode) {
            case 10054: case 104: FriendlyMsg = "目标设备未响应，请检查对方是否在线"; break;
            case 10061: case 111: FriendlyMsg = "对方拒绝了连接，请检查防火墙设置"; break;
            case 10060: case 110: FriendlyMsg = "发送超时，请检查网络连接"; break;
            case 10065: case 113: FriendlyMsg = "目标主机不可达，请检查IP地址是否可用"; break;
            case 10051: case 101: FriendlyMsg = "目标网络不可达，请检查网络设置"; break;
            case 10064: case 112: FriendlyMsg = "目标主机已关机或离线"; break;
            case 10013: case 13: FriendlyMsg = "您无权访问"; break;
            case 10048: case 98: FriendlyMsg = "端口已被占用，请关闭占用程序"; break;
            case 10049: case 99: FriendlyMsg = "IP地址不可用，请检查输入是否正确"; break;
            default: FriendlyMsg = E.Message(); break;
        }
        
        sendcmdbtn->Text = "cmd命令发送失败";
        sendcmdbtn->TextSettings->FontColor = TAlphaColorRec::Red;
        Application->ProcessMessages();
        
        FCurrentRequestID = "";
        DisableSendButtons();
        ResetActionButton();
        
        TDialogService::MessageDialog("消息发送失败: " + FriendlyMsg + "\r\n" +
                                     "错误信息: " + E.Message() + "\r\n" +
                                     "异常类型: " + E.ClassName(),
            TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
    }
}

// ================== 版本比较 ==================
int Tmainform::CompareVersion(const String V1, const String V2) {
    TArray<String> Parts1 = V1.Split({"."});
    TArray<String> Parts2 = V2.Split({"."});
    
    for (int i = 0; i < 3; i++) {
        int Num1 = 0, Num2 = 0;
        if (i < Parts1.Length) Num1 = StrToIntDef(Parts1[i], 0);
        if (i < Parts2.Length) Num2 = StrToIntDef(Parts2[i], 0);
        
        if (Num1 > Num2) return 1;
        else if (Num1 < Num2) return -1;
    }
    
    return 0;
}

// ================== 获取更新级别 ==================
int Tmainform::GetVersionLevel(const String CurrentVer, const String NewVer) {
    TArray<String> PartsCurr = CurrentVer.Split({"."});
    TArray<String> PartsNew = NewVer.Split({"."});
    
    int CurrMajor = StrToIntDef(PartsCurr[0], 0);
    int CurrMinor = StrToIntDef(PartsCurr[1], 0);
    int CurrRev = StrToIntDef(PartsCurr[2], 0);
    
    int NewMajor = StrToIntDef(PartsNew[0], 0);
    int NewMinor = StrToIntDef(PartsNew[1], 0);
    int NewRev = StrToIntDef(PartsNew[2], 0);
    
    if (NewMajor > CurrMajor) return 1;
    else if (NewMinor > CurrMinor) return 2;
    else if (NewRev > CurrRev) return 3;
    
    return 3;
}

// ================== 打开下载链接 ==================
void Tmainform::OpenDownloadUrl(const String Url) {
    #ifdef _WIN32
    ShellExecute(0, L"open", Url.c_str(), L"", L"", SW_SHOWNORMAL);
    #endif
    #ifdef __APPLE__
    _system(("open " + Url).c_str());
    #endif
    #ifdef __linux__
    _system(("xdg-open " + Url).c_str());
    #endif
}

// ================== 显示更新对话框 ==================
void Tmainform::ShowUpdateDialog(const String VersionInfo, const String UpdateNotes, 
    const String PublishDate, const String DownloadUrl, int UpdateLevel) {
    String DialogMsg, DialogTitle;
    
    if (UpdateLevel == 1) {
        DialogTitle = "全新版本 v" + VersionInfo;
    } else {
        DialogTitle = "发现新版本 v" + VersionInfo;
    }
    
    DialogMsg = DialogTitle + "\r\n\r\n";
    
    if (PublishDate != "") {
        DialogMsg += "发布时间: " + PublishDate + "\r\n\r\n";
    }
    
    DialogMsg += "更新内容: \r\n" + UpdateNotes + "\r\n\r\n";
    DialogMsg += "当前版本: v" + APP_VERSION + "\r\n\r\n";
    
    if (UpdateLevel == 1) {
        DialogMsg += "本次更新为架构层面升级，建议立即更新！";
    } else if (UpdateLevel == 2) {
        DialogMsg += "建议更新以获得更好的体验，是否现在更新？";
    } else {
        DialogMsg += "是否现在更新？";
    }
    
    if (UpdateLevel == 1) {
        TDialogService::MessageDialog(DialogMsg, TMsgDlgType::mtInformation,
            {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0,
            [this, DownloadUrl](const TModalResult AResult) {
                if (AResult == mrOk) {
                    OpenDownloadUrl(DownloadUrl);
                }
            });
    } else {
        TDialogService::MessageDialog(DialogMsg, TMsgDlgType::mtInformation,
            {TMsgDlgBtn::mbYes, TMsgDlgBtn::mbNo}, TMsgDlgBtn::mbYes, 0,
            [this, DownloadUrl](const TModalResult AResult) {
                if (AResult == mrYes) {
                    OpenDownloadUrl(DownloadUrl);
                }
            });
    }
}

// ================== 解析版本响应 ==================
void Tmainform::ParseVersionResponse(const String Content, bool ShowDialog) {
    try {
        TJSONObject* JSON = dynamic_cast<TJSONObject*>(TJSONObject::ParseJSONValue(Content));
        if (JSON == nullptr) {
            if (ShowDialog) {
                TDialogService::MessageDialog("版本信息获取失败",
                    TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
            }
            FUpdatingInProgress = false;
            return;
        }
        
        std::unique_ptr<TJSONObject> jsonPtr(JSON);
        
        String NewVersion, UpdateNotes, DownloadUrl, PublishDate;
        
        #ifdef _WIN32
        NewVersion = jsonPtr->GetValue<String>("windows_version");
        UpdateNotes = jsonPtr->GetValue<String>("windows_notes");
        DownloadUrl = jsonPtr->GetValue<String>("windows");
        PublishDate = jsonPtr->GetValue<String>("windows_date");
        #endif
        #ifdef __APPLE__
        NewVersion = jsonPtr->GetValue<String>("mac_version");
        UpdateNotes = jsonPtr->GetValue<String>("mac_notes");
        DownloadUrl = jsonPtr->GetValue<String>("mac");
        PublishDate = jsonPtr->GetValue<String>("mac_date");
        #endif
        #ifdef __linux__
        NewVersion = jsonPtr->GetValue<String>("linux_version");
        UpdateNotes = jsonPtr->GetValue<String>("linux_notes");
        DownloadUrl = jsonPtr->GetValue<String>("linux");
        PublishDate = jsonPtr->GetValue<String>("linux_date");
        #endif
        
        if (NewVersion == "") {
            if (ShowDialog) {
                TDialogService::MessageDialog("版本信息获取失败",
                    TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
            }
            FUpdatingInProgress = false;
            return;
        }
        
        if (CompareVersion(NewVersion, APP_VERSION) > 0) {
            updatenotify->Visible = true;
            int UpdateLevel = GetVersionLevel(APP_VERSION, NewVersion);
            
            if (UpdateLevel == 1) {
                ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
            } else if (UpdateLevel == 2) {
                if (!ShowDialog) {
                    String CountStr = LoadConfigFromFile("Update", "StartupCount", "0");
                    int StartupCount = StrToIntDef(CountStr, 0);
                    if (StartupCount >= 8) {
                        ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
                        SaveConfigToFile("Update", "StartupCount", "0");
                    }
                } else {
                    ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
                }
            } else if (UpdateLevel == 3) {
                if (ShowDialog) {
                    ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
                }
            }
        } else {
            updatenotify->Visible = false;
            if (ShowDialog) {
                TDialogService::MessageDialog("当前已是最新版本~赞！",
                    TMsgDlgType::mtInformation, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
            }
        }
    } catch (Exception& E) {
        if (ShowDialog) {
            TDialogService::MessageDialog("解析更新信息失败: " + E.Message(),
                TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
        }
    }
    
    FUpdatingInProgress = false;
}

// ================== 执行检查更新 ==================
void Tmainform::DoCheckUpdate(bool ShowDialog) {
    #ifdef _WIN32
    VersionHTTPClient->UserAgent = "RemoteControl-Windows/" + APP_VERSION;
    #endif
    #ifdef __APPLE__
    VersionHTTPClient->UserAgent = "RemoteControl-macOS/" + APP_VERSION;
    #endif
    #ifdef __linux__
    VersionHTTPClient->UserAgent = "RemoteControl-Linux/" + APP_VERSION;
    #endif
    
    for (int RetryCount = 0; RetryCount <= 2; RetryCount++) {
        try {
            IHTTPResponse Response = VersionHTTPClient->Get("https://stackni.github.io/remote-control-platform/version.json");
            String Content = Response->ContentAsString(TEncoding::UTF8);
            
            TThread::Queue(nullptr,
                [this, Content, ShowDialog]() {
                    ParseVersionResponse(Content, ShowDialog);
                });
            return;
        } catch (Exception& E) {
            String ErrorMsg = "错误信息: " + E.Message() + sLineBreak +
                             "错误类型: " + E.ClassName();
            if (RetryCount == 2) {
                if (ShowDialog) {
                    TThread::Queue(nullptr,
                        [ErrorMsg]() {
                            TDialogService::MessageDialog("检查更新时出错" + sLineBreak + ErrorMsg,
                                TMsgDlgType::mtError, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
                        });
                }
                break;
            }
        }
    }
    FUpdatingInProgress = false;
}

// ================== 检查更新入口 ==================
void Tmainform::CheckForUpdate(bool ShowDialog) {
    if (FUpdatingInProgress) {
        if (ShowDialog) {
            TDialogService::MessageDialog("正在检查更新，请稍后再试！",
                TMsgDlgType::mtInformation, {TMsgDlgBtn::mbOK}, TMsgDlgBtn::mbOK, 0, nullptr);
        }
        return;
    }
    
    FUpdatingInProgress = true;
    
    TThread::CreateAnonymousThread(
        [this, ShowDialog]() {
            DoCheckUpdate(ShowDialog);
        })->Start();
}

// ================== 跳过证书检查 ==================
void __fastcall Tmainform::VersionHTTPClientValidateServerCertificate(
    const TObject* Sender, const TURLRequest* ARequest,
    const TCertificate* Certificate, bool& Accepted) {
    Accepted = true;
}
