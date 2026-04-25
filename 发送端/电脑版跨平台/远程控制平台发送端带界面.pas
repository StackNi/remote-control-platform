unit 远程控制平台发送端带界面;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, FMX.Types, FMX.Controls,
  FMX.Controls.Presentation, FMX.Forms, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  IdUDPServer, IdGlobal, FMX.Edit, FMX.Effects, FMX.Filter.Effects,
  FMX.Platform, System.IOUtils, System.IniFiles, System.DateUtils, IdStack,
  FMX.Skia, System.Skia, IdBaseComponent, IdUDPBase, IdComponent, FMX.ComboEdit,
  System.Generics.Collections, FMX.DialogService, IdSocketHandle,
  System.JSON, System.Net.HttpClientComponent, System.Net.URLClient,
  System.Net.HttpClient
  {$IFDEF MSWINDOWS}
  , FMX.Platform.Win, Winapi.Windows, Winapi.Messages, Winapi.ShellAPI
  {$ENDIF}
  {$IFDEF MACOS}
  , Posix.Stdlib, Macapi.CoreFoundation
  {$ENDIF}
  {$IFDEF LINUX}
  , Posix.Stdlib
  {$ENDIF};

type
  THomeSubPage = (hspNone, hspLocalIP, hspDonate);
  TSettingsSubPage = (sspNone, sspChangeUsername, sspChangeIPList);

  TIPAliasItem = record
    Name: string;
    IP: string;
  end;

  TIPAliasList = TList<TIPAliasItem>;

  Tmainform = class(TForm)
    closeimage: TSkSvg;
    minimizeimage: TSkSvg;
    appicon: TImage;
    sendbtn: TSkSvg;
    endbtn: TSkSvg;
    cmdbtn: TSkSvg;
    sendlayout: TLayout;
    msgtext: TEdit;
    appiconGlowEffect: TGlowEffect;
    pinimage: TSkSvg;
    sendclickedbtn: TSkSvg;
    endclickedbtn: TSkSvg;
    cmdclickedbtn: TSkSvg;
    sendmsgbtn: TButton;
    normal: TRadioButton;
    msgdurationtext: TEdit;
    msgdurationspinbtn: TSpinEditButton;
    typewriter: TRadioButton;
    blink: TRadioButton;
    fullscreen: TRadioButton;
    manualcloseSwitch: TSwitch;
    endlayout: TLayout;
    endmsgbtn: TButton;
    cmdlayout: TLayout;
    cmdtext: TEdit;
    user: TRadioButton;
    sendcmdbtn: TButton;
    homelayout: TLayout;
    guidecaption: TLabel;
    homesendbtn: TRectangle;
    homelistbtn: TRectangle;
    homeendbtn: TRectangle;
    homecmdbtn: TRectangle;
    homelistdown: TSkSvg;
    homelistup: TSkSvg;
    homebtn: TSkSvg;
    mobilebtn: TSkSvg;
    settingsbtn: TSkSvg;
    homeclickedbtn: TSkSvg;
    mobileclickedbtn: TSkSvg;
    settingsclickedbtn: TSkSvg;
    mobilelayout: TLayout;
    settingslayout: TLayout;
    homecurrentusername: TLabel;
    homelocalIPbtn: TCircle;
    homedonatebtn: TCircle;
    localIPlayout: TLayout;
    localIPcaption: TLabel;
    localIPlabel: TLabel;
    backfromlocalIPbtn: TSkSvg;
    donatelayout: TLayout;
    backfromdonatebtn: TSkSvg;
    refreshlocalIPbtn: TButton;
    copylocalIPbtn: TButton;
    changeusernamebtn: TButton;
    changeIPlistbtn: TButton;
    skiaswitch: TSwitch;
    changeusernamelayout: TLayout;
    backfromchangeusernamebtn: TSkSvg;
    currentusername: TLabel;
    newusernametext: TEdit;
    newusernamebtn: TButton;
    changeIPlistlayout: TLayout;
    backfromchangeIPlistbtn: TSkSvg;
    changeIPlistScrollBox: TVertScrollBox;
    sendIPtext: TComboEdit;
    endIPtext: TComboEdit;
    cmdIPtext: TComboEdit;
    localIPitem: TRectangle;
    localIPtip: TLabel;
    localIPtipIP: TLabel;
    addIPtipbtn: TButton;
    homelistpopup: TPopup;
    appcard: TPopup;
    homegithubbtn: TCircle;
    Timeout: TTimer;
    mainUDP: TIdUDPServer;
    websitebtn: TRectangle;
    homecheckupdatebtn: TCircle;
    updatenotify: TCircle;
    VersionHTTPClient: TNetHTTPClient;

    procedure backgroundMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure sidebarbtnMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure ctrlbtnClick(Sender: TObject);
    procedure sidebarbtnMouseLeave(Sender: TObject);
    procedure ctrlbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure ctrlbtnMouseLeave(Sender: TObject);
    procedure appiconMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure appiconMouseLeave(Sender: TObject);
    procedure sidebarbtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HomeButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure HomeButtonMouseLeave(Sender: TObject);
    procedure HomeButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure HomeButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure HomeButtonClick(Sender: TObject);
    procedure SettingsButtonClick(Sender: TObject);
    procedure backbtnClick(Sender: TObject);
    procedure backbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure backbtnMouseLeave(Sender: TObject);
    procedure refreshlocalIPbtnClick(Sender: TObject);
    procedure copylocalIPbtnClick(Sender: TObject);
    procedure newusernamebtnClick(Sender: TObject);
    procedure skiaswitchSwitch(Sender: TObject);
    procedure msgdurationspinbtnUpClick(Sender: TObject);
    procedure msgdurationspinbtnDownClick(Sender: TObject);
    procedure msgdurationspinbtnMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure ctrlIPtipbtnMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure ctrlIPtipbtnMouseLeave(Sender: TObject);
    procedure IPitemMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure IPitemMouseLeave(Sender: TObject);
    procedure addIPtipbtnClick(Sender: TObject);
    procedure EditIPClick(Sender: TObject);
    procedure DeleteIPClick(Sender: TObject);
    procedure sendmsgbtnClick(Sender: TObject);
    procedure endmsgbtnClick(Sender: TObject);
    procedure homelistpopupClosePopup(Sender: TObject);
    procedure appiconClick(Sender: TObject);
    procedure appcardClosePopup(Sender: TObject);
    procedure sendcmdbtnClick(Sender: TObject);
    procedure TimeoutTimer(Sender: TObject);
    procedure mainUDPUDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure mainUDPUDPException(AThread: TIdUDPListenerThread;
      ABinding: TIdSocketHandle; const AMessage: string;
      const AExceptionClass: TClass);
    procedure VersionHTTPClientValidateServerCertificate(const Sender: TObject;
      const ARequest: TURLRequest; const Certificate: TCertificate;
      var Accepted: Boolean);

  private
    { Private declarations }
    FActiveSidebarButton: TControl;
    FActiveHomeSubPage: THomeSubPage;
    FActiveSettingsSubPage: TSettingsSubPage;
    FCurrentUsername: string;
    FIPItems: TList<TRectangle>;
    FIPAliases: TIPAliasList;
    FCurrentIPItem: TRectangle;
    FappiconEffect: Boolean;
    FIsTopMost: Boolean;
    FCurrentActionBtn: TButton;  // 当前操作的按钮
    FCurrentActionType: string;   // 当前操作类型: 'send', 'end', 'cmd'
    FResponseProcessed: Boolean;  // 是否已经处理过响应（防止重复处理）
    FUpdatingInProgress: Boolean;  // 防止重复检查更新
    FStartupCheckDone: Boolean;    // 启动时是否已检查过
    procedure SetActiveSidebarButton(Button: TControl);
    procedure SaveTopMostSetting(TopMost: Boolean);
    function LoadTopMostSetting: Boolean;
    function GetRandomGreeting: string;
    function GetIPAddressInfo: string;
    function GetAppConfigPath: string;
    function LoadSkiaSetting: Boolean;
    procedure UpdatePinImageState;
    procedure ShowCorrespondingLayout(ButtonType: string);
    procedure HandleBackButtonClick(BackFrom: string);
    procedure ShowHomeSubPage(SubPage: THomeSubPage);
    procedure ShowSettingsSubPage(SubPage: TSettingsSubPage);
    procedure SaveSkiaSetting(SkiaEnabled: Boolean);
    procedure SaveConfigToFile(const Section, Key, Value: string);
    procedure SaveBoolConfigToFile(const Section, Key: string; Value: Boolean);
    function LoadConfigFromFile(const Section, Key, DefaultValue: string): string;
    function LoadBoolConfigFromFile(const Section, Key: string; DefaultValue: Boolean): Boolean;

    procedure LoadUserConfig;
    procedure SaveUserConfig;
    procedure UpdateAllUsernameDisplays;
    procedure LoadIPAliases;
    procedure SaveIPAliases;
    procedure ClearIPItems;
    procedure CreateIPItem(const Item: TIPAliasItem; Index: Integer);
    procedure UpdateLayout;
    procedure UpdateComboEditItems;
    procedure DisableSendButtons;
    procedure EnableSendButtons;

    function ValidateIPAddress(const IP: string): Boolean;
    procedure AddIPAlias(const Name, IP: string);
    procedure ShowIPitemButtons(IPitem: TRectangle);
    procedure HideIPitemButtons(IPitem: TRectangle);
    function ValidateAndGetTargetIP(const InputText: string; out TargetIP: string): Boolean;
    function CheckLocalNetworkAvailable: Boolean;
    procedure ResetActionButton;
    procedure CheckForUpdate(ShowDialog: Boolean = False);  // ShowDialog: True=用户主动检查, False=启动时自动检查
    procedure DoCheckUpdate(ShowDialog: Boolean);
    procedure ParseVersionResponse(const Content: string; ShowDialog: Boolean);
    procedure ShowUpdateDialog(const VersionInfo: string; const UpdateNotes: string; const PublishDate: string; const DownloadUrl: string; const UpdateLevel: Integer);
    function CompareVersion(const V1, V2: string): Integer;  // 返回: 1=V1>V2, 0=相等, -1=V1<V2
    function GetVersionLevel(const CurrentVer, NewVer: string): Integer;  // 返回: 1=主版本, 2=次版本, 3=修订版本
    procedure OpenDownloadUrl(const Url: string);

  public
    { Public declarations }
  end;

const
  APP_VERSION = '3.1.6';

var
  mainform: Tmainform;

implementation

{$R *.fmx}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}
{$R *.NmXhdpiPh.fmx}
{$R *.iPad.fmx}

// ================== 提取socket错误码 ==================
function ExtractSocketErrorCode(const Msg: string): Integer;
var
  HashPos: Integer;
  CodeStr: string;
  i: Integer;
begin
  Result := 0;
  HashPos := Pos('#', Msg);
  if HashPos > 0 then
  begin
    CodeStr := '';
    for i := HashPos + 1 to Length(Msg) do
    begin
      if CharInSet(Msg[i], ['0'..'9']) then
        CodeStr := CodeStr + Msg[i]
      else if CodeStr <> '' then
        Break;
    end;
    if CodeStr <> '' then
      Result := StrToIntDef(CodeStr, 0);
  end;
end;

// ================== 配置文件路径 ==================
function Tmainform.GetAppConfigPath: string;
var
  AppDataPath: string;
begin
  {$IFDEF MSWINDOWS}
  AppDataPath := GetEnvironmentVariable('APPDATA');
  if AppDataPath = '' then
    AppDataPath := TPath.GetHomePath;

  Result := TPath.Combine(AppDataPath, '远程控制平台');
  {$ENDIF}

  {$IFDEF MACOS}
  Result := TPath.Combine(TPath.GetHomePath, 'Library/Application Support/远程控制平台');
  {$ENDIF}

  {$IFDEF LINUX}
  Result := TPath.Combine(TPath.GetHomePath, '.config/远程控制平台');
  {$ENDIF}

  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);

  Result := TPath.Combine(Result, 'config.ini');
end;

procedure Tmainform.SaveConfigToFile(const Section, Key, Value: string);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigPath);
  try
    Ini.WriteString(Section, Key, Value);
  finally
    Ini.Free;
  end;
end;

procedure Tmainform.SaveBoolConfigToFile(const Section, Key: string; Value: Boolean);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigPath);
  try
    Ini.WriteBool(Section, Key, Value);
  finally
    Ini.Free;
  end;
end;

function Tmainform.LoadConfigFromFile(const Section, Key, DefaultValue: string): string;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigPath);
  try
    Result := Ini.ReadString(Section, Key, DefaultValue);
  finally
    Ini.Free;
  end;
end;

function Tmainform.LoadBoolConfigFromFile(const Section, Key: string; DefaultValue: Boolean): Boolean;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetAppConfigPath);
  try
    Result := Ini.ReadBool(Section, Key, DefaultValue);
  finally
    Ini.Free;
  end;
end;

// ================== 用户配置 ==================
procedure Tmainform.LoadUserConfig;
begin
  FCurrentUsername := LoadConfigFromFile('User', 'Username', '').Trim;
  if FCurrentUsername = '' then
    FCurrentUsername := '默认用户';
end;

procedure Tmainform.SaveUserConfig;
begin
  SaveConfigToFile('User', 'Username', FCurrentUsername);
end;

procedure Tmainform.UpdateAllUsernameDisplays;
begin
  if Assigned(homecurrentusername) then
    homecurrentusername.Text := '当前用户: ' + FCurrentUsername;

  if Assigned(currentusername) then
    currentusername.Text := '当前用户: ' + FCurrentUsername;
end;

// ================== IP地址相关 ==================
function Tmainform.GetIPAddressInfo: string;
var
  i: Integer;
  IP: string;
  IPType: string;
  IPList: TStringList;
begin
  Result := '';
  IPList := TStringList.Create;
  try
    for i := 0 to GStack.LocalAddresses.Count - 1 do
    begin
      IP := GStack.LocalAddresses[i];

      if (Pos(':', IP) = 0) and (IP <> '127.0.0.1') then
      begin
        if Copy(IP, 1, 3) = '10.' then
          IPType := '私网A类'
        else if (Copy(IP, 1, 4) = '172.') and
                (StrToIntDef(Copy(IP, 5, Pos('.', Copy(IP, 5, 255)) - 1), 0) >= 16) and
                (StrToIntDef(Copy(IP, 5, Pos('.', Copy(IP, 5, 255)) - 1), 0) <= 31) then
          IPType := '私网B类'
        else if Copy(IP, 1, 8) = '192.168.' then
          IPType := '私网C类'
        else if Copy(IP, 1, 4) = '169.' then
          IPType := 'APIPA地址'
        else
          IPType := '公网地址';

        IPList.Add(IP + ' [' + IPType + ']');
      end;
    end;

    IPList.Sort;

    if IPList.Count > 0 then
    begin
      for i := 0 to IPList.Count - 1 do
      begin
        Result := Result + IPList[i];
        if i < IPList.Count - 1 then
          Result := Result + #13#10;
      end;
    end
    else
    begin
      Result := '未找到可用IP，请检查网络设置';
    end;

  finally
    IPList.Free;
  end;
end;

function Tmainform.ValidateIPAddress(const IP: string): Boolean;
var
  Parts: TArray<string>;
  i: Integer;
  Num: Integer;
begin
  Result := False;

  if IP.Trim = '' then
    Exit;

  Parts := IP.Split(['.']);
  if Length(Parts) <> 4 then
    Exit;

  for i := 0 to 3 do
  begin
    if Parts[i] = '' then
      Exit;

    for var ch in Parts[i] do
    begin
      if (ch < '0') or (ch > '9') then
        Exit;
    end;

    if (Length(Parts[i]) > 1) and (Parts[i][1] = '0') then
      Exit;

    if not TryStrToInt(Parts[i], Num) then
      Exit;

    if (Num < 0) or (Num > 255) then
      Exit;
  end;

  Result := True;
end;

// ================== Skia设置 ==================
procedure Tmainform.SaveSkiaSetting(SkiaEnabled: Boolean);
begin
  SaveBoolConfigToFile('Graphics', 'SkiaEnabled', SkiaEnabled);
end;

function Tmainform.LoadSkiaSetting: Boolean;
begin
  Result := LoadBoolConfigFromFile('Graphics', 'SkiaEnabled', True);
end;

// ================== 置顶设置 ==================
procedure Tmainform.SaveTopMostSetting(TopMost: Boolean);
begin
  SaveBoolConfigToFile('Window', 'TopMost', TopMost);
end;

function Tmainform.LoadTopMostSetting: Boolean;
begin
  Result := LoadBoolConfigFromFile('Window', 'TopMost', False);
end;

procedure Tmainform.UpdatePinImageState;
begin
  if FIsTopMost then
  begin
    pinimage.Hint := '取消置顶';
    pinimage.Opacity := 1;
    pinimage.Svg.OverrideColor := $FFFF4F4F;
  end
  else
  begin
    pinimage.Hint := '置顶';
    pinimage.Opacity := 0.6;
    pinimage.Svg.OverrideColor := 0;
  end;
end;

// ================== 问候语 ==================
function Tmainform.GetRandomGreeting: string;
var
  CurrentHour: Integer;
  TimeGreeting: string;
  RandomGreetings: TArray<string>;
begin
  CurrentHour := HourOf(Now);

  case CurrentHour of
    0..4:   TimeGreeting := '夜深了，';
    5..10:  TimeGreeting := '早上好，';
    11..13: TimeGreeting := '中午好，';
    14..17: TimeGreeting := '下午好，';
    18..21: TimeGreeting := '晚上好，';
    else    TimeGreeting := '夜深了，';
  end;

  case CurrentHour of
    0..4:
      RandomGreetings := [
        '还没睡呢',
        '有什么心事呢',
        '努力总有回报'
      ];
    5..10:
      RandomGreetings := [
        '新的一天开始啦',
        '一日之计在于晨',
        '开始工作吧'
      ];
    11..13:
      RandomGreetings := [
        '工作顺利吗',
        '放松一下吧'
      ];
    14..17:
      RandomGreetings := [
        '继续加油',
        '来杯下午茶吧'
      ];
    18..21:
      RandomGreetings := [
        '注意劳逸结合',
        '还在忙碌呢'
      ];
    else
      RandomGreetings := [
        '注意休息',
        '晚安'
      ];
  end;

  Randomize;
  Result := TimeGreeting + RandomGreetings[Random(Length(RandomGreetings))];
end;

// ================== 页面管理 ==================
procedure Tmainform.ShowCorrespondingLayout(ButtonType: string);
begin
  homelayout.Visible := False;
  sendlayout.Visible := False;
  endlayout.Visible := False;
  cmdlayout.Visible := False;
  mobilelayout.Visible := False;
  settingslayout.Visible := False;

  localIPlayout.Visible := False;
  donatelayout.Visible := False;
  changeusernamelayout.Visible := False;
  changeIPlistlayout.Visible := False;

  FActiveHomeSubPage := hspNone;
  FActiveSettingsSubPage := sspNone;

  if ButtonType = 'home' then
    homelayout.Visible := True
  else if ButtonType = 'send' then
    sendlayout.Visible := True
  else if ButtonType = 'end' then
    endlayout.Visible := True
  else if ButtonType = 'cmd' then
    cmdlayout.Visible := True
  else if ButtonType = 'mobile' then
    mobilelayout.Visible := True
  else if ButtonType = 'settings' then
    settingslayout.Visible := True;
end;

procedure Tmainform.ShowHomeSubPage(SubPage: THomeSubPage);
begin
  homelayout.Visible := False;
  sendlayout.Visible := False;
  endlayout.Visible := False;
  cmdlayout.Visible := False;
  mobilelayout.Visible := False;
  settingslayout.Visible := False;

  localIPlayout.Visible := False;
  donatelayout.Visible := False;

  case SubPage of
    hspLocalIP:
      begin
        localIPlayout.Visible := True;
        FActiveHomeSubPage := hspLocalIP;
      end;
    hspDonate:
      begin
        donatelayout.Visible := True;
        FActiveHomeSubPage := hspDonate;
      end;
  else
    FActiveHomeSubPage := hspNone;
  end;
end;

procedure Tmainform.ShowSettingsSubPage(SubPage: TSettingsSubPage);
begin
  homelayout.Visible := False;
  sendlayout.Visible := False;
  endlayout.Visible := False;
  cmdlayout.Visible := False;
  mobilelayout.Visible := False;
  settingslayout.Visible := False;

  localIPlayout.Visible := False;
  donatelayout.Visible := False;
  changeusernamelayout.Visible := False;
  changeIPlistlayout.Visible := False;

  FActiveHomeSubPage := hspNone;

  case SubPage of
    sspChangeUsername:
      begin
        changeusernamelayout.Visible := True;
        FActiveSettingsSubPage := sspChangeUsername;
      end;
    sspChangeIPList:
      begin
        changeIPlistlayout.Visible := True;
        FActiveSettingsSubPage := sspChangeIPList;
      end;
  else
    FActiveSettingsSubPage := sspNone;
  end;
end;

procedure Tmainform.HandleBackButtonClick(BackFrom: string);
var
  SubPage: THomeSubPage;
begin
  if (BackFrom = 'changeusername') or (BackFrom = 'changeIPlist') then
  begin
    newusernametext.Text := '';
    if FActiveSettingsSubPage <> sspNone then
    begin
      SetActiveSidebarButton(settingsbtn);
      ShowCorrespondingLayout('settings');
      FActiveSettingsSubPage := sspNone;
    end;
    Exit;
  end;

  if BackFrom = 'localIP' then
    SubPage := hspLocalIP
  else if BackFrom = 'donate' then
    SubPage := hspDonate
  else
    SubPage := hspNone;

  if FActiveHomeSubPage = SubPage then
  begin
    SetActiveSidebarButton(homebtn);
    ShowCorrespondingLayout('home');
    FActiveHomeSubPage := hspNone;
  end;
end;

procedure Tmainform.SetActiveSidebarButton(Button: TControl);
begin
  ShowCorrespondingLayout('');

  sendbtn.Svg.OverrideColor := 0;
  endbtn.Svg.OverrideColor := 0;
  cmdbtn.Svg.OverrideColor := 0;
  homebtn.Svg.OverrideColor := 0;
  mobilebtn.Svg.OverrideColor := 0;
  settingsbtn.Svg.OverrideColor := 0;

  sendbtn.Visible := True;
  endbtn.Visible := True;
  cmdbtn.Visible := True;
  homebtn.Visible := True;
  mobilebtn.Visible := True;
  settingsbtn.Visible := True;

  sendclickedbtn.Visible := False;
  endclickedbtn.Visible := False;
  cmdclickedbtn.Visible := False;
  homeclickedbtn.Visible := False;
  mobileclickedbtn.Visible := False;
  settingsclickedbtn.Visible := False;

  FActiveSidebarButton := Button;

  if Button = sendbtn then
  begin
    sendbtn.Visible := False;
    sendclickedbtn.Visible := True;
    ShowCorrespondingLayout('send');
  end
  else if Button = endbtn then
  begin
    endbtn.Visible := False;
    endclickedbtn.Visible := True;
    ShowCorrespondingLayout('end');
  end
  else if Button = cmdbtn then
  begin
    cmdbtn.Visible := False;
    cmdclickedbtn.Visible := True;
    ShowCorrespondingLayout('cmd');
  end
  else if Button = homebtn then
  begin
    homebtn.Visible := False;
    homeclickedbtn.Visible := True;
    ShowCorrespondingLayout('home');
  end
  else if Button = mobilebtn then
  begin
    mobilebtn.Visible := False;
    mobileclickedbtn.Visible := True;
    ShowCorrespondingLayout('mobile');
  end
  else if Button = settingsbtn then
  begin
    settingsbtn.Visible := False;
    settingsclickedbtn.Visible := True;
    ShowCorrespondingLayout('settings');
  end;
end;

// ================== IP别名管理核心功能 ==================
procedure Tmainform.LoadIPAliases;
var
  Ini: TIniFile;
  Sections: TStringList;
  i: Integer;
  Item: TIPAliasItem;
begin
  changeIPlistScrollBox.BeginUpdate;
  try
    ClearIPItems;
    if not Assigned(FIPAliases) then
      FIPAliases := TIPAliasList.Create
    else
      FIPAliases.Clear;

    Ini := TIniFile.Create(GetAppConfigPath);
    Sections := TStringList.Create;
    try
      Ini.ReadSection('tips', Sections);
      for i := 0 to Sections.Count - 1 do
      begin
        Item.Name := Sections[i];
        Item.IP := Ini.ReadString('tips', Item.Name, '');
        if (Item.Name <> '') and (Item.IP <> '') then
          FIPAliases.Add(Item);
      end;
    finally
      Sections.Free;
      Ini.Free;
    end;

    for i := 0 to FIPAliases.Count - 1 do
      CreateIPItem(FIPAliases[i], i);

    UpdateLayout;
    UpdateComboEditItems;
  finally
    changeIPlistScrollBox.EndUpdate;
  end;
end;

procedure Tmainform.SaveIPAliases;
var
  Ini: TIniFile;
  i: Integer;
begin
  Ini := TIniFile.Create(GetAppConfigPath);
  try
    Ini.EraseSection('tips');

    for i := 0 to FIPAliases.Count - 1 do
    begin
      Ini.WriteString('tips', FIPAliases[i].Name, FIPAliases[i].IP);
    end;
  finally
    Ini.Free;
  end;
end;

procedure Tmainform.ClearIPItems;
begin
  FCurrentIPItem := nil;

  for var i := FIPItems.Count - 1 downto 0 do
  begin
    var Item := FIPItems[i];
    FIPItems.Delete(i);
    Item.Free;
  end;
end;

procedure Tmainform.CreateIPItem(const Item: TIPAliasItem; Index: Integer);
var
  IPItem: TRectangle;
  IPtip: TLabel;
  IPtipIP: TLabel;
  editIPtipbtn: TSkSvg;
  deleteIPtipbtn: TSkSvg;
  itemcolor: TRectangle;
  IPItemDivideLine: TLine;
begin
  var ExistingName := 'IPitem_' + Index.ToString;
  var ExistingObj := changeIPlistScrollBox.FindComponent(ExistingName);
  if Assigned(ExistingObj) then
  begin
    changeIPlistScrollBox.RemoveObject(ExistingObj as TFmxObject);
    ExistingObj.Free;
  end;

  IPItem := TRectangle.Create(changeIPlistScrollBox);
  try
    IPItem.Parent := changeIPlistScrollBox;
    IPItem.Name := ExistingName;
    IPItem.Fill.Color := $FF2B2B2B;
    IPItem.Stroke.Thickness := 0;
    IPItem.ClipChildren := False;

    IPItem.Tag := Index;
    IPItem.OnMouseMove := IPitemMouseMove;
    IPItem.OnMouseLeave := IPitemMouseLeave;

    FIPItems.Add(IPItem);

    IPItemDivideLine := TLine.Create(IPItem);
    IPItemDivideLine.Parent := IPItem;
    IPItemDivideLine.Name := 'divide_' + Index.ToString;
    IPItemDivideLine.LineType := TLineType.Diagonal;
    IPItemDivideLine.Stroke.Color := $FF343434;
    IPItemDivideLine.Stroke.Thickness := 1;
    IPItemDivideLine.Size.Width := 717;
    IPItemDivideLine.Size.Height := 1;
    IPItemDivideLine.Position.X := 8;
    IPItemDivideLine.Position.Y := -4;
    IPItemDivideLine.HitTest := False;

    itemcolor := TRectangle.Create(IPItem);
    itemcolor.Parent := IPItem;
    itemcolor.Name := 'itemcolor_' + Index.ToString;
    itemcolor.Fill.Color := $FF4FFFFF;
    itemcolor.HitTest := False;
    itemcolor.Stroke.Thickness := 0;
    itemcolor.Size.Width := 6;
    itemcolor.Size.Height := 94;
    itemcolor.Align := TAlignLayout.Left;

    IPtip := TLabel.Create(IPItem);
    IPtip.Parent := IPItem;
    IPtip.Name := 'IPtip_' + Index.ToString;
    IPtip.StyledSettings := [TStyledSetting.Style];
    IPtip.TextSettings.Font.Family := 'Microsoft YaHei';
    IPtip.TextSettings.Font.Size := 20;
    IPtip.TextSettings.FontColor := TAlphaColorRec.White;
    IPtip.Text := Item.Name;
    IPtip.Position.X := 28;
    IPtip.Position.Y := 14;
    IPtip.Size.Width := 610;
    IPtip.Size.Height := 33;
    IPtip.HitTest := False;

    IPtipIP := TLabel.Create(IPItem);
    IPtipIP.Parent := IPItem;
    IPtipIP.Name := 'IPtipIP_' + Index.ToString;
    IPtipIP.StyledSettings := [TStyledSetting.Style];
    IPtipIP.TextSettings.Font.Family := 'Microsoft YaHei';
    IPtipIP.TextSettings.Font.Size := 16;
    IPtipIP.TextSettings.FontColor := $FF949494;
    IPtipIP.Text := 'IP: ' + Item.IP;
    IPtipIP.Position.X := 28;
    IPtipIP.Position.Y := 49;
    IPtipIP.Size.Width := 610;
    IPtipIP.Size.Height := 30;
    IPtipIP.HitTest := False;

    editIPtipbtn := TSkSvg.Create(IPItem);
    editIPtipbtn.Parent := IPItem;
    editIPtipbtn.Name := 'editIPtipbtn_' + Index.ToString;
    editIPtipbtn.Cursor := crHandPoint;
    editIPtipbtn.Hint := '修改提示词';
    editIPtipbtn.HitTest := True;
    editIPtipbtn.Position.X := 652;
    editIPtipbtn.Position.Y := 31;
    editIPtipbtn.Size.Width := 32;
    editIPtipbtn.Size.Height := 32;
    editIPtipbtn.Svg.Source :=
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="-6 -6 36 36" fill="none" stroke="#909090" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-edit-3"><path d="M12 20h9"></path><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path></svg>';

    editIPtipbtn.Tag := Index;
    editIPtipbtn.OnMouseMove := ctrlIPtipbtnMouseMove;
    editIPtipbtn.OnMouseLeave := ctrlIPtipbtnMouseLeave;
    editIPtipbtn.OnClick := EditIPClick;
    editIPtipbtn.Visible := False;

    deleteIPtipbtn := TSkSvg.Create(IPItem);
    deleteIPtipbtn.Parent := IPItem;
    deleteIPtipbtn.Name := 'deleteIPtipbtn_' + Index.ToString;
    deleteIPtipbtn.Cursor := crHandPoint;
    deleteIPtipbtn.Hint := '删除提示词';
    deleteIPtipbtn.HitTest := True;
    deleteIPtipbtn.Position.X := 688;
    deleteIPtipbtn.Position.Y := 31;
    deleteIPtipbtn.Size.Width := 32;
    deleteIPtipbtn.Size.Height := 32;
    deleteIPtipbtn.Svg.Source :=
      '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="-6 -6 36 36" fill="none" stroke="#909090" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-trash-2"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path><line x1="10" y1="11" x2="10" y2="17"></line><line x1="14" y1="11" x2="14" y2="17"></line></svg>';

    deleteIPtipbtn.Tag := Index;
    deleteIPtipbtn.OnMouseMove := ctrlIPtipbtnMouseMove;
    deleteIPtipbtn.OnMouseLeave := ctrlIPtipbtnMouseLeave;
    deleteIPtipbtn.OnClick := DeleteIPClick;
    deleteIPtipbtn.Visible := False;

    IPItem.Size.Width := 733;
    IPItem.Size.Height := 94;
    IPItem.Position.X := 8;

  except
    begin
      if Assigned(IPItem) then IPItem.Free;
      raise;
    end;
  end;
end;

procedure Tmainform.UpdateLayout;
const
  ITEM_SPACING = 7;
  MAX_HEIGHT = 475;
  NORMAL_WIDTH = 733;
  NARROW_WIDTH = 713;
  NORMAL_TIP_WIDTH = 610;
  NARROW_TIP_WIDTH = 590;
  EDIT_BTN_X_NORMAL = 652;
  DELETE_BTN_X_NORMAL = 688;
  EDIT_BTN_X_NARROW = 632;
  DELETE_BTN_X_NARROW = 668;
var
  i, j: Integer;
  TotalHeight: Single;
  NeedAdjustWidth: Boolean;
  Lbl: TLabel;
  Svg: TSkSvg;
  Line: TLine;
  ItemWidth, TipWidth: Integer;
  EditBtnX, DeleteBtnX: Integer;
begin
  TotalHeight := 0;

  if localIPitem <> nil then
  begin
    TotalHeight := TotalHeight + localIPitem.Height + ITEM_SPACING;
  end;

  for i := 0 to FIPItems.Count - 1 do
  begin
    if FIPItems[i] = localIPitem then
      Continue;

    FIPItems[i].Position.Y := TotalHeight;
    TotalHeight := TotalHeight + FIPItems[i].Height + ITEM_SPACING;
  end;

  NeedAdjustWidth := (TotalHeight + addIPtipbtn.Height) > MAX_HEIGHT;

  if NeedAdjustWidth then
  begin
    ItemWidth := NARROW_WIDTH;
    TipWidth := NARROW_TIP_WIDTH;
    EditBtnX := EDIT_BTN_X_NARROW;
    DeleteBtnX := DELETE_BTN_X_NARROW;
  end
  else
  begin
    ItemWidth := NORMAL_WIDTH;
    TipWidth := NORMAL_TIP_WIDTH;
    EditBtnX := EDIT_BTN_X_NORMAL;
    DeleteBtnX := DELETE_BTN_X_NORMAL;
  end;

  localIPitem.Width := ItemWidth;
  localIPtip.Width := TipWidth;
  localIPtipIP.Width := TipWidth;

  for i := 0 to FIPItems.Count - 1 do
  begin
    if FIPItems[i] = localIPitem then
      Continue;

    FIPItems[i].Width := ItemWidth;

    for j := 0 to FIPItems[i].ChildrenCount - 1 do
    begin
      if FIPItems[i].Children[j] is TLabel then
      begin
        Lbl := TLabel(FIPItems[i].Children[j]);
        if Pos('IPtip', Lbl.Name) > 0 then
          Lbl.Width := TipWidth;
      end
      else if FIPItems[i].Children[j] is TSkSvg then
      begin
        Svg := TSkSvg(FIPItems[i].Children[j]);
        if Pos('edit', Svg.Name) > 0 then
          Svg.Position.X := EditBtnX
        else if Pos('delete', Svg.Name) > 0 then
          Svg.Position.X := DeleteBtnX;
      end
      else if FIPItems[i].Children[j] is TLine then
      begin
        Line := TLine(FIPItems[i].Children[j]);
        if NeedAdjustWidth then
          Line.Width := ItemWidth - 16;
      end;
    end;
  end;

  addIPtipbtn.Width := ItemWidth;
  addIPtipbtn.Position.X := 8;
  addIPtipbtn.Position.Y := TotalHeight;
end;

procedure Tmainform.UpdateComboEditItems;
var
  i: Integer;
begin
  sendIPtext.Items.Clear;
  endIPtext.Items.Clear;
  cmdIPtext.Items.Clear;

  sendIPtext.Items.Add('本地回环');
  endIPtext.Items.Add('本地回环');
  cmdIPtext.Items.Add('本地回环');

  for i := 0 to FIPAliases.Count - 1 do
  begin
    sendIPtext.Items.Add(FIPAliases[i].Name);
    endIPtext.Items.Add(FIPAliases[i].Name);
    cmdIPtext.Items.Add(FIPAliases[i].Name);
  end;
end;

procedure Tmainform.AddIPAlias(const Name, IP: string);
begin
  var Item: TIPAliasItem;
  Item.Name := Name;
  Item.IP := IP;
  FIPAliases.Add(Item);

  var Ini := TIniFile.Create(GetAppConfigPath);
  try
    Ini.WriteString('tips', Name, IP);
  finally
    Ini.Free;
  end;

  LoadIPAliases;
end;

// ================== 事件处理 ==================
procedure Tmainform.backgroundMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton.mbLeft then
  begin
    {$IFDEF MSWINDOWS}
    var FormHandle: HWND := WindowHandleToPlatform(Handle).Wnd;
    ReleaseCapture;
    PostMessage(FormHandle, WM_NCLBUTTONDOWN, HTCAPTION, 0);
    {$ELSE}
    StartWindowDrag;
    {$ENDIF}
  end;
end;

procedure Tmainform.ctrlbtnClick(Sender: TObject);
begin
  if Sender = minimizeimage then
  begin
    WindowState := TWindowState.wsMinimized;
  end
  else if Sender = closeimage then
  begin
    Application.Terminate;
  end
  else if Sender = pinimage then
  begin
    if FIsTopMost then
    begin
      {$IFDEF MSWINDOWS}
      var Wnd := FormToHWND(Self);
      var Style := GetWindowLong(Wnd, GWL_EXSTYLE);
      SetWindowLong(Wnd, GWL_EXSTYLE, Style and not WS_EX_TOPMOST);
      SetWindowPos(Wnd, HWND_NOTOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      {$ELSE}
      FormStyle := TFormStyle.Normal;
      {$ENDIF}

      FIsTopMost := False;
      SaveTopMostSetting(False);
    end
    else
    begin
      {$IFDEF MSWINDOWS}
      var Wnd := FormToHWND(Self);
      var Style := GetWindowLong(Wnd, GWL_EXSTYLE);
      SetWindowLong(Wnd, GWL_EXSTYLE, Style or WS_EX_TOPMOST);
      SetWindowPos(Wnd, HWND_TOPMOST, 0, 0, 0, 0,
        SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
      {$ELSE}
      FormStyle := TFormStyle.StayOnTop;
      {$ENDIF}

      FIsTopMost := True;
      SaveTopMostSetting(True);
    end;

    UpdatePinImageState;
  end;
end;

procedure Tmainform.ctrlbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Sender is TSksvg then
  begin
    if (Sender = pinimage) and FIsTopMost then
      Exit;

    (Sender as TSksvg).Opacity := 1;
  end;
end;

procedure Tmainform.ctrlbtnMouseLeave(Sender: TObject);
begin
  if Sender is TSksvg then
  begin
    if (Sender = pinimage) and FIsTopMost then
      Exit;

    (Sender as TSksvg).Opacity := 0.6;
  end;
end;

procedure Tmainform.appcardClosePopup(Sender: TObject);
begin
  websitebtn.Fill.Color := $FFFF4F4F;
  FappiconEffect := True;

  if appicon.IsMouseOver then
  begin
    appicon.Opacity := 0.9;
    appiconGlowEffect.Opacity := 0.8;
    appiconGlowEffect.Enabled := True;
  end
  else
  begin
    appicon.Opacity := 0.8;
    appiconGlowEffect.Opacity := 0.6;
    appiconGlowEffect.Enabled := False;
  end;
end;

procedure Tmainform.appiconClick(Sender: TObject);
begin
  appcard.IsOpen := True;
  FappiconEffect := False;
  appicon.Opacity := 1;
  appiconGlowEffect.Opacity := 1;
  appiconGlowEffect.Enabled := True;
end;

procedure Tmainform.appiconMouseLeave(Sender: TObject);
begin
if FappiconEffect = False then Exit;
  appicon.Opacity := 0.8;
  appiconGlowEffect.Opacity := 0.6;
  appiconGlowEffect.Enabled := False;
end;

procedure Tmainform.appiconMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
if FappiconEffect = False then Exit;
  appicon.Opacity := 0.9;
  appiconGlowEffect.Opacity := 0.8;
  appiconGlowEffect.Enabled := True;
end;

procedure Tmainform.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
  StartupCount: Integer;
begin
  Constraints.MinWidth := 882;
  Constraints.MaxWidth := 882;
  Constraints.MinHeight := 600;
  Constraints.MaxHeight := 600;
  Self.Width := 882;
  Self.Height := 600;

  {$IFDEF MSWINDOWS}
  var H: HWND := WindowHandleToPlatform(Handle).Wnd;
  var WA: TRect; SystemParametersInfo(SPI_GETWORKAREA, 0, @WA, 0);
  var FR: TRect; GetWindowRect(H, FR);
  var NewLeft := WA.Left + (WA.Width - (FR.Right - FR.Left)) div 2;
  var NewTop := WA.Top + (WA.Height - (FR.Bottom - FR.Top)) div 2;
  if NewTop < WA.Top then
    NewTop := WA.Top;
  if NewLeft < WA.Left then
    NewLeft := WA.Left;
  SetWindowPos(H, 0, NewLeft, NewTop, 0, 0, SWP_NOZORDER or SWP_NOSIZE);
  {$ENDIF}

  guidecaption.Text := GetRandomGreeting;

  homelistdown.Visible := True;
  homelistup.Visible := False;
  localIPlabel.Text := '正在获取本机IP地址...';
  TThread.CreateAnonymousThread(
    procedure
    var
      IPInfo: string;
    begin
      IPInfo := GetIPAddressInfo;
      TThread.Queue(nil,
        procedure
        begin
          localIPlabel.Text := IPInfo;
        end);
    end).Start;

  SetActiveSidebarButton(homebtn);

  FIsTopMost := LoadTopMostSetting;
  if FIsTopMost then
  begin
    {$IFDEF MSWINDOWS}
    var Wnd := FormToHWND(Self);
    SetWindowLong(Wnd, GWL_EXSTYLE, GetWindowLong(Wnd, GWL_EXSTYLE) or WS_EX_TOPMOST);
    SetWindowPos(Wnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    {$ELSE}
    FormStyle := TFormStyle.StayOnTop;
    {$ENDIF}
  end
  else
  begin
    {$IFDEF MSWINDOWS}
    var Wnd := FormToHWND(Self);
    SetWindowLong(Wnd, GWL_EXSTYLE, GetWindowLong(Wnd, GWL_EXSTYLE) and not WS_EX_TOPMOST);
    SetWindowPos(Wnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    {$ELSE}
    FormStyle := TFormStyle.Normal;
    {$ENDIF}
  end;
  UpdatePinImageState;

  FIPAliases := TIPAliasList.Create;
  FIPItems := TList<TRectangle>.Create;
  FCurrentIPItem := nil;
  FappiconEffect := True;
  FCurrentActionBtn := nil;
  FCurrentActionType := '';
  FResponseProcessed := False;

  Ini := TIniFile.Create(GetAppConfigPath);
  try
    StartupCount := Ini.ReadInteger('Update', 'StartupCount', 0);
    if StartupCount < 10 then
    begin
      StartupCount := StartupCount + 1;
      Ini.WriteInteger('Update', 'StartupCount', StartupCount);
    end;
    // 如果已经达到10，不再增加
  finally
    Ini.Free;
  end;

  LoadIPAliases;
  LoadUserConfig;
  UpdateAllUsernameDisplays;
  skiaswitch.IsChecked := LoadSkiaSetting;

  // 启动时检查更新
  FUpdatingInProgress := False;
  FStartupCheckDone := False;
  CheckForUpdate(False);  // 启动时自动检查，不弹窗提示
end;

procedure Tmainform.FormResize(Sender: TObject);
begin
  if (Width <> 882) or (Height <> 600) then
  begin
    OnResize := nil;
    try
      Width := 882;
      Height := 600;
    finally
      OnResize := FormResize;
    end;
  end;
end;

procedure Tmainform.sidebarbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Sender is TControl then
  begin
    if Sender = sendbtn then
      sendbtn.Svg.OverrideColor := $FFFF4F4F
    else if Sender = endbtn then
      endbtn.Svg.OverrideColor := $FFFF4F4F
    else if Sender = cmdbtn then
      cmdbtn.Svg.OverrideColor := $FFFF4F4F
    else if Sender = homebtn then
      homebtn.Svg.OverrideColor := $FFFF4F4F
    else if Sender = mobilebtn then
      mobilebtn.Svg.OverrideColor := $FFFF4F4F
    else if Sender = settingsbtn then
      settingsbtn.Svg.OverrideColor := $FFFF4F4F;
  end;
end;

procedure Tmainform.sidebarbtnMouseLeave(Sender: TObject);
begin
  if (Sender is TControl) and (Sender <> FActiveSidebarButton) then
  begin
    if Sender = sendbtn then
      sendbtn.Svg.OverrideColor := 0
    else if Sender = endbtn then
      endbtn.Svg.OverrideColor := 0
    else if Sender = cmdbtn then
      cmdbtn.Svg.OverrideColor := 0
    else if Sender = homebtn then
      homebtn.Svg.OverrideColor := 0
    else if Sender = mobilebtn then
      mobilebtn.Svg.OverrideColor := 0
    else if Sender = settingsbtn then
      settingsbtn.Svg.OverrideColor := 0;
  end;
end;

procedure Tmainform.skiaswitchSwitch(Sender: TObject);
begin
  SaveSkiaSetting(skiaswitch.IsChecked);
end;

procedure Tmainform.sidebarbtnClick(Sender: TObject);
begin
  if Sender is TControl then
  begin
    SetActiveSidebarButton(Sender as TControl);
  end;
end;

procedure Tmainform.HomeButtonMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Sender is TRectangle then
  begin
    if Sender = homelistbtn then
    begin
      TRectangle(Sender).Fill.Color := $FFE04141;
      Exit;
    end;

    if ssLeft in Shift then
    begin
      if TRectangle(Sender).IsMouseOver then
        TRectangle(Sender).Fill.Color := $FFFF7E7E
      else
        TRectangle(Sender).Fill.Color := $FFFF4F4F;
    end
    else
    begin
      TRectangle(Sender).Fill.Color := $FFE04141;
    end;
  end
  else if Sender is TCircle then
  begin
    if ssLeft in Shift then
    begin
      if TCircle(Sender).IsMouseOver then
        TCircle(Sender).Opacity := 0.1
      else
        TCircle(Sender).Opacity := 0.2;
    end
    else
    begin
      TCircle(Sender).Opacity := 0.4;
    end;
  end;
end;

procedure Tmainform.HomeButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if Button <> TMouseButton.mbLeft then
    Exit;

  if Sender is TRectangle then
  begin
    if Sender = homelistbtn then
      TRectangle(Sender).Fill.Color := $FFE04141
    else
      TRectangle(Sender).Fill.Color := $FFFF4F4F;
  end
  else if Sender is TCircle then
  begin
    TCircle(Sender).Opacity := 0.2;
  end;
end;

procedure Tmainform.homelistpopupClosePopup(Sender: TObject);
begin
  homelistup.Visible := False;
  homelistdown.Visible := True;
  homeendbtn.Fill.Color := $FFFF4F4F;
  homecmdbtn.Fill.Color := $FFFF4F4F;

  if homelistbtn.IsMouseOver then
    homelistbtn.Fill.Color := $FFE04141
  else
    homelistbtn.Fill.Color := $FFFF4F4F;
end;

procedure Tmainform.HomeButtonMouseLeave(Sender: TObject);
begin
  if Sender is TRectangle then
  begin
    if (Sender = homelistbtn) and homelistpopup.IsOpen then
    begin
      TRectangle(Sender).Fill.Color := $FFE04141;
      Exit;
    end;

    TRectangle(Sender).Fill.Color := $FFFF4F4F;
  end
  else if Sender is TCircle then
  begin
    TCircle(Sender).Opacity := 0.2;
  end;
end;

procedure Tmainform.HomeButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if (Sender is TRectangle) and (Button = TMouseButton.mbLeft) then
  begin
    if Sender = homelistbtn then
      Exit;

    TRectangle(Sender).Fill.Color := $FFFF7E7E;
  end
  else if (Sender is TCircle) and (Button = TMouseButton.mbLeft) then
  begin
    TCircle(Sender).Opacity := 0.1;
  end;
end;

procedure Tmainform.HomeButtonClick(Sender: TObject);
begin
  if Sender = homelistbtn then
  begin
    homelistup.Visible := True;
    homelistdown.Visible := False;
    homelistpopup.IsOpen := True;
    homelistbtn.Fill.Color := $FFE04141;
  end
  else if Sender = homesendbtn then
  begin
    sidebarbtnClick(sendbtn);
    homelistpopup.IsOpen := False;
  end
  else if Sender = homeendbtn then
  begin
    sidebarbtnClick(endbtn);
    homelistpopup.IsOpen := False;
  end
  else if Sender = homecmdbtn then
  begin
    sidebarbtnClick(cmdbtn);
    homelistpopup.IsOpen := False;
  end
  else if Sender = homecheckupdatebtn then
  begin
    CheckForUpdate(True);  // 用户点击检查更新，会弹窗提示
  end
  else if Sender = homelocalIPbtn then
  begin
    ShowHomeSubPage(hspLocalIP);
  end
  else if Sender = homegithubbtn then
  begin
    {$IFDEF MSWINDOWS}
    ShellExecute(0, 'open', 'https://github.com/StackNi/remote-control-platform/', '', '', SW_SHOWNORMAL);
    {$ENDIF}

    {$IFDEF MACOS}
    _system(PAnsiChar('open ' + AnsiString('https://github.com/StackNi/remote-control-platform/')));
    {$ENDIF}

    {$IFDEF LINUX}
    _system(PAnsiChar('xdg-open ' + AnsiString('https://github.com/StackNi/remote-control-platform/')));
    {$ENDIF}
  end
  else if Sender = homedonatebtn then
  begin
    ShowHomeSubPage(hspDonate);
  end
  else if Sender = websitebtn then
  begin
    {$IFDEF MSWINDOWS}
    ShellExecute(0, 'open', 'https://stackni.github.io/remote-control-platform/', '', '', SW_SHOWNORMAL);
    {$ENDIF}

    {$IFDEF MACOS}
    _system(PAnsiChar('open ' + AnsiString('https://stackni.github.io/remote-control-platform/')));
    {$ENDIF}

    {$IFDEF LINUX}
    _system(PAnsiChar('xdg-open ' + AnsiString('https://stackni.github.io/remote-control-platform/')));
    {$ENDIF}
  end;
end;

procedure Tmainform.SettingsButtonClick(Sender: TObject);
begin
  if Sender = changeusernamebtn then
    ShowSettingsSubPage(sspChangeUsername)
  else if Sender = changeIPlistbtn then
  begin
    ShowSettingsSubPage(sspChangeIPList);
  end;
end;

procedure Tmainform.backbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Sender is TSksvg then
  begin
    (Sender as TSksvg).Opacity := 1.0;
  end;
end;

procedure Tmainform.backbtnMouseLeave(Sender: TObject);
begin
  if Sender is TSksvg then
  begin
    (Sender as TSksvg).Opacity := 0.6;
  end;
end;

procedure Tmainform.backbtnClick(Sender: TObject);
begin
  if Sender = backfromlocalIPbtn then
    HandleBackButtonClick('localIP')
  else if Sender = backfromdonatebtn then
    HandleBackButtonClick('donate')
  else if Sender = backfromchangeusernamebtn then
    HandleBackButtonClick('changeusername')
  else if Sender = backfromchangeIPlistbtn then
    HandleBackButtonClick('changeIPlist');
end;

procedure Tmainform.refreshlocalIPbtnClick(Sender: TObject);
begin
  localIPlabel.Text := GetIPAddressInfo;

  refreshlocalIPbtn.Text := '已刷新';
  refreshlocalIPbtn.Enabled := False;

  TThread.CreateAnonymousThread(
    procedure
    begin
      Sleep(1000);
      TThread.Queue(nil,
        procedure
        begin
          refreshlocalIPbtn.Text := '刷新';
          refreshlocalIPbtn.Enabled := True;
        end);
    end).Start;
end;

procedure Tmainform.copylocalIPbtnClick(Sender: TObject);
var
  ClipboardService: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, IInterface(ClipboardService)) then
  begin
    ClipboardService.SetClipboard(localIPlabel.Text);

    copylocalIPbtn.Text := '已复制';
    copylocalIPbtn.Enabled := False;

    TThread.CreateAnonymousThread(
      procedure
      begin
        Sleep(1000);
        TThread.Queue(nil,
          procedure
          begin
            copylocalIPbtn.Text := '复制';
            copylocalIPbtn.Enabled := True;
          end);
      end).Start;
  end
  else
  begin
    TDialogService.MessageDialog('无法访问剪贴板',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
  end;
end;

procedure Tmainform.newusernamebtnClick(Sender: TObject);
var
  InputText: string;
begin
  InputText := newusernametext.Text.Trim;

  if InputText = '' then
    FCurrentUsername := '默认用户'
  else if Pos('|', InputText) > 0 then
  begin
    TDialogService.MessageDialog('用户名中不能包含"|"分隔符！',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end
  else
    FCurrentUsername := InputText;

  SaveUserConfig;
  UpdateAllUsernameDisplays;

  TDialogService.MessageDialog('用户名已更改为: ' + FCurrentUsername,
    TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);

  newusernametext.Text := '';
  HandleBackButtonClick('changeusername');
end;

procedure Tmainform.msgdurationspinbtnDownClick(Sender: TObject);
var
  Value: Int64;
begin
  if msgdurationtext.Text = '' then
    msgdurationtext.Text := '0'
  else if TryStrToInt64(msgdurationtext.Text, Value) then
    if Value > 0 then
      msgdurationtext.Text := IntToStr(Value - 1);
end;

procedure Tmainform.msgdurationspinbtnUpClick(Sender: TObject);
var
  Value: Int64;
begin
  if msgdurationtext.Text = '' then
    msgdurationtext.Text := '1'
  else if TryStrToInt64(msgdurationtext.Text, Value) then
    if Value < High(Int64) then
      msgdurationtext.Text := IntToStr(Value + 1);
end;

procedure Tmainform.msgdurationspinbtnMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
begin
  if msgdurationtext.IsFocused then
  begin
    if WheelDelta > 0 then
      msgdurationspinbtnUpClick(msgdurationspinbtn)
    else
      msgdurationspinbtnDownClick(msgdurationspinbtn);
    Handled := True;
  end
  else
  begin
    Handled := False;
  end;
end;

// ================== 按钮效果事件 ==================
procedure Tmainform.ctrlIPtipbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if (Sender is TSkSvg) then
  begin
    var Svg := TSkSvg(Sender);

    if Pos('edit', Svg.Name) > 0 then
      Svg.Svg.OverrideColor := $FF4FFF4F
    else if Pos('delete', Svg.Name) > 0 then
      Svg.Svg.OverrideColor := $FFFF4F4F;

    if Assigned(Svg.Parent) and (Svg.Parent is TRectangle) then
    begin
      var ParentRect := TRectangle(Svg.Parent);
      FCurrentIPItem := ParentRect;
      ShowIPitemButtons(ParentRect);
    end;
  end;
end;

procedure Tmainform.ctrlIPtipbtnMouseLeave(Sender: TObject);
begin
  if Sender is TSkSvg then
  begin
    var Svg := TSkSvg(Sender);
    Svg.Svg.OverrideColor := 0;
  end;
end;

procedure Tmainform.IPitemMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if (Sender is TRectangle) then
  begin
    var Rect := TRectangle(Sender);

    if Rect = localIPitem then
      Exit;

    if Assigned(FCurrentIPItem) and (FCurrentIPItem <> Rect) and (FCurrentIPItem <> localIPitem) then
    begin
      HideIPitemButtons(FCurrentIPItem);
    end;

    FCurrentIPItem := Rect;
    ShowIPitemButtons(Rect);
  end;
end;

procedure Tmainform.IPitemMouseLeave(Sender: TObject);
begin
  if Sender is TRectangle then
  begin
    var Rect := TRectangle(Sender);

    if Rect = localIPitem then
      Exit;

    if (Rect <> nil) and (Rect = FCurrentIPItem) then
    begin
      HideIPitemButtons(Rect);
      FCurrentIPItem := nil;
    end;
  end;
end;

procedure Tmainform.ShowIPitemButtons(IPitem: TRectangle);
begin
  if (IPitem = nil) or (IPitem = localIPitem) then Exit;

  for var i := 0 to IPitem.ChildrenCount - 1 do
  begin
    if IPitem.Children[i] is TSkSvg then
    begin
      var Svg := TSkSvg(IPitem.Children[i]);
      if Pos('edit', Svg.Name) > 0 then
        Svg.Visible := True
      else if Pos('delete', Svg.Name) > 0 then
        Svg.Visible := True;
    end;
  end;
end;

procedure Tmainform.HideIPitemButtons(IPitem: TRectangle);
begin
  if (IPitem = nil) or (IPitem = localIPitem) then Exit;

  for var i := 0 to IPitem.ChildrenCount - 1 do
  begin
    if IPitem.Children[i] is TSkSvg then
    begin
      var Svg := TSkSvg(IPitem.Children[i]);
      if Pos('edit', Svg.Name) > 0 then
        Svg.Visible := False
      else if Pos('delete', Svg.Name) > 0 then
        Svg.Visible := False;
    end;
  end;
end;

procedure Tmainform.addIPtipbtnClick(Sender: TObject);
var
  Name, IP: string;
begin
  TDialogService.InputQuery('添加提示词',
    ['输入提示词:'],
    [''],
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      if AResult = mrOk then
      begin
        Name := AValues[0].Trim;

        if Name = '' then
        begin
          TDialogService.MessageDialog('提示词不能为空！',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
          Exit;
        end;

        if Name = '本地回环' then
        begin
          TDialogService.MessageDialog('不能使用保留提示词！',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
          Exit;
        end;

        for var Item in FIPAliases do
        begin
          if Item.Name = Name then
          begin
            TDialogService.MessageDialog('该提示词已存在！',
              TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
            Exit;
          end;
        end;

        TDialogService.InputQuery('添加提示词',
          ['输入对应IP地址:'],
          [''],
          procedure(const AResult2: TModalResult; const AValues2: array of string)
          begin
            if AResult2 = mrOk then
            begin
              IP := AValues2[0].Trim;

              if not ValidateIPAddress(IP) then
              begin
                TDialogService.MessageDialog('请输入有效的IPv4地址！',
                  TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
                Exit;
              end;

              AddIPAlias(Name, IP);

              TDialogService.MessageDialog('添加成功！',
                TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
            end;
          end);
      end;
    end);
end;

// ================== 修改提示词 ==================
procedure Tmainform.EditIPClick(Sender: TObject);
var
  Index: Integer;
  CurrentName, NewName: string;
begin
  if Sender is TSkSvg then
  begin
    Index := TSkSvg(Sender).Tag;

    if (Index < 0) or (Index >= FIPAliases.Count) then
    begin
      LoadIPAliases;
      Exit;
    end;

    CurrentName := FIPAliases[Index].Name;

    TDialogService.InputQuery('修改提示词',
      ['输入新的提示词:'],
      [CurrentName],
      procedure(const AResult: TModalResult; const AValues: array of string)
      begin
        if AResult <> mrOk then Exit;

        NewName := AValues[0].Trim;

        if NewName = '' then
        begin
          TDialogService.MessageDialog('提示词不能为空！',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
          Exit;
        end;

        if NewName = '本地回环' then
        begin
          TDialogService.MessageDialog('不能使用保留提示词！',
            TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
          Exit;
        end;

        for var i := 0 to FIPAliases.Count - 1 do
        begin
          if (i <> Index) and (FIPAliases[i].Name = NewName) then
          begin
            TDialogService.MessageDialog('该提示词已存在！',
              TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
            Exit;
          end;
        end;

        var Item := FIPAliases[Index];
        Item.Name := NewName;
        FIPAliases[Index] := Item;

        SaveIPAliases;
        LoadIPAliases;

        TDialogService.MessageDialog('提示词修改成功！',
          TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end);
  end;
end;

procedure Tmainform.DeleteIPClick(Sender: TObject);
var
  Index: Integer;
begin
  if Sender is TSkSvg then
  begin
    Index := TSkSvg(Sender).Tag;

    if (Index < 0) or (Index >= FIPAliases.Count) then
    begin
      LoadIPAliases;
      Exit;
    end;

    TDialogService.MessageDialog('确定要删除该提示词吗？',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo,
      0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          FIPAliases.Delete(Index);
          SaveIPAliases;
          LoadIPAliases;
        end;
      end);
  end;
end;

// ================== 处理目标IP ==================
function Tmainform.ValidateAndGetTargetIP(const InputText: string; out TargetIP: string): Boolean;
begin
  Result := False;
  TargetIP := InputText.Trim;

  if TargetIP = '' then
  begin
    TDialogService.MessageDialog('请输入目标IP地址或提示词！',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if TargetIP = '本地回环' then
  begin
    TargetIP := '127.0.0.1';
    Result := True;
    Exit;
  end
  else
  begin
    for var Item in FIPAliases do
      if Item.Name = TargetIP then
      begin
        TargetIP := Item.IP;
        Break;
      end;

    if not ValidateIPAddress(TargetIP) then
    begin
      TDialogService.MessageDialog('请输入有效的IPv4地址或提示词！',
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      Exit;
    end;
  end;

  Result := True;
end;

// ================== 检查本地网络 ==================
function Tmainform.CheckLocalNetworkAvailable: Boolean;
begin
  Result := GStack.LocalAddresses.Count > 0;
  if not Result then
  begin
    TDialogService.MessageDialog('未找到可用IP，请检查网络设置',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
  end;
end;

// ================== 禁用所有发送按钮 ==================
procedure Tmainform.DisableSendButtons;
begin
  sendmsgbtn.Enabled := False;
  endmsgbtn.Enabled := False;
  sendcmdbtn.Enabled := False;
end;

// ================== 启用所有发送按钮 ==================
procedure Tmainform.EnableSendButtons;
begin
  sendmsgbtn.Enabled := True;
  endmsgbtn.Enabled := True;
  sendcmdbtn.Enabled := True;
end;

// ================== 延迟3秒恢复发送按钮 ==================
procedure Tmainform.ResetActionButton;
begin
  if Assigned(FCurrentActionBtn) then
  begin
    TThread.CreateAnonymousThread(
      procedure
      begin
        Sleep(3000);
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(FCurrentActionBtn) then
            begin
              if FCurrentActionType = 'send' then
                FCurrentActionBtn.Text := '发送消息'
              else if FCurrentActionType = 'end' then
                FCurrentActionBtn.Text := '结束消息'
              else if FCurrentActionType = 'cmd' then
                FCurrentActionBtn.Text := '发送cmd命令'
              else
                FCurrentActionBtn.Text := '发送UDP';

              FCurrentActionBtn.TextSettings.FontColor := TAlphaColorRec.Black;
              EnableSendButtons;
              FCurrentActionBtn := nil;
              FCurrentActionType := '';
              FResponseProcessed := False;
            end;
          end);
      end).Start;
  end;
end;

// ================== mainUDP接收处理 ==================
procedure Tmainform.mainUDPUDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  ReceivedText, FinalText, ErrorMsg: string;
  FinalColor: TAlphaColor;
  IsError: Boolean;
begin
  if (FCurrentActionBtn = nil) or (FCurrentActionBtn.Enabled) or FResponseProcessed then
    Exit;

  ReceivedText := IndyTextEncoding_UTF8.GetString(AData).Trim;
  IsError := ReceivedText.StartsWith('ERROR:');

  if IsError then
  begin
    ErrorMsg := ReceivedText.Substring(6);
    if FCurrentActionType = 'send' then
      FinalText := '消息接收时出错'
    else if FCurrentActionType = 'end' then
      FinalText := '消息结束时出错'
    else if FCurrentActionType = 'cmd' then
      FinalText := 'cmd命令执行时出错'
    else
      FinalText := '接收失败';

    FinalColor := TAlphaColorRec.Red;
  end
  else
  begin
    if ((FCurrentActionType = 'send') and (ReceivedText = 'RECEIVED_OK')) or
       ((FCurrentActionType = 'cmd') and (ReceivedText = 'CMD_EXECUTED_OK')) or
       ((FCurrentActionType = 'end') and (ReceivedText = 'WINDOWS_CLOSED_OK')) then
    begin
      if FCurrentActionType = 'send' then
        FinalText := '对方已确认收到消息'
      else if FCurrentActionType = 'end' then
        FinalText := '消息窗口已成功关闭'
      else if FCurrentActionType = 'cmd' then
        FinalText := 'cmd命令执行成功'
      else
        FinalText := '操作成功';

      FinalColor := TAlphaColorRec.Green;
    end
    else
      Exit;
  end;

  TThread.Queue(nil,
    procedure
    begin
      Timeout.Enabled := False;
    end);

  FResponseProcessed := True;

  TThread.Queue(nil,
    procedure
    begin
      if Assigned(FCurrentActionBtn) then
      begin
        FCurrentActionBtn.Text := FinalText;
        FCurrentActionBtn.TextSettings.FontColor := FinalColor;
        Application.ProcessMessages;

        ResetActionButton;

        if IsError then
        begin
          TDialogService.MessageDialog('来自接收端的错误: ' + ErrorMsg,
            TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
        end;
      end;
    end);
end;

// ================== mainUDP异常处理 ==================
procedure Tmainform.mainUDPUDPException(AThread: TIdUDPListenerThread;
  ABinding: TIdSocketHandle; const AMessage: string;
  const AExceptionClass: TClass);
var
  ErrorMsg, ButtonMsg, DisplayMsg: string;
  ErrorCode: Integer;
begin
  ErrorCode := ExtractSocketErrorCode(AMessage);

  TThread.Queue(nil,
    procedure
    begin
      case ErrorCode of
        10054, 104:
          begin
            ButtonMsg := '接收端未就绪';
            ErrorMsg := '目标设备的接收端程序未运行，连接被重置';
          end;
        10061, 111:
          begin
            ButtonMsg := '连接被拒';
            ErrorMsg := '对方拒绝了连接，请检查防火墙设置';
          end;
        10060, 110:
          begin
            ButtonMsg := '响应超时';
            ErrorMsg := '等待对方响应超时，请检查网络连接';
          end;
        10065, 113:
          begin
            ButtonMsg := '主机不可达';
            ErrorMsg := '目标主机不可达，请检查IP地址是否可用';
          end;
        10051, 101:
          begin
            ButtonMsg := '网络不可达';
            ErrorMsg := '目标网络不可达，请检查网络设置';
          end;
        10064, 112:
          begin
            ButtonMsg := '对方已离线';
            ErrorMsg := '目标主机已关机或离线';
          end;
        10013, 13:
          begin
            ButtonMsg := '权限不足';
            ErrorMsg := '您无权访问';
          end;
        10048, 98:
          begin
            ButtonMsg := '端口被占用';
            ErrorMsg := '端口已被占用，请关闭占用程序';
          end;
        10049, 99:
          begin
            ButtonMsg := '地址无效';
            ErrorMsg := 'IP地址不可用，请检查输入是否正确';
          end;
        10040, 90:
          begin
            ButtonMsg := '数据包过大';
            ErrorMsg := '发送的数据包超过大小限制';
          end;
        10004, 4:
          begin
            ButtonMsg := '操作中断';
            ErrorMsg := '网络操作被系统中断';
          end;
        10014, 14:
          begin
            ButtonMsg := '系统错误';
            ErrorMsg := '系统网络地址错误';
          end;
        10022, 22:
          begin
            ButtonMsg := '参数错误';
            ErrorMsg := '网络参数设置错误';
          end;
        10024, 24:
          begin
            ButtonMsg := '系统资源不足';
            ErrorMsg := '系统打开文件过多，请关闭一些程序';
          end;
        10035, 11:
          begin
            ButtonMsg := '操作阻塞';
            ErrorMsg := '网络操作暂时无法完成，请稍后重试';
          end;
        10036, 115:
          begin
            ButtonMsg := '操作进行中';
            ErrorMsg := '网络操作正在进行中';
          end;
        10037, 114:
          begin
            ButtonMsg := '操作已开始';
            ErrorMsg := '网络操作已在进行中';
          end;
        10038, 88:
          begin
            ButtonMsg := '套接字错误';
            ErrorMsg := '网络套接字无效，请重启程序';
          end;
        10039, 89:
          begin
            ButtonMsg := '地址缺失';
            ErrorMsg := '需要指定目标地址';
          end;
        10041, 41:
          begin
            ButtonMsg := '协议错误';
            ErrorMsg := '网络协议类型错误';
          end;
        10042, 42:
          begin
            ButtonMsg := '协议选项错误';
            ErrorMsg := '不支持的协议选项';
          end;
        10043, 43:
          begin
            ButtonMsg := '协议不支持';
            ErrorMsg := '不支持的网络协议';
          end;
        10044, 44:
          begin
            ButtonMsg := '套接字不支持';
            ErrorMsg := '不支持的套接字类型';
          end;
        10045, 95:
          begin
            ButtonMsg := '操作不支持';
            ErrorMsg := '不支持的网络操作';
          end;
        10046, 96:
          begin
            ButtonMsg := '协议族不支持';
            ErrorMsg := '不支持的协议族';
          end;
        10047, 97:
          begin
            ButtonMsg := '地址族不支持';
            ErrorMsg := '不支持的地址类型';
          end;
        10050, 100:
          begin
            ButtonMsg := '网络断开';
            ErrorMsg := '网络连接已断开';
          end;
        10052, 102:
          begin
            ButtonMsg := '网络重置';
            ErrorMsg := '网络连接被重置';
          end;
        10053, 103:
          begin
            ButtonMsg := '连接中止';
            ErrorMsg := '连接被中止';
          end;
        10055, 105:
          begin
            ButtonMsg := '缓冲区不足';
            ErrorMsg := '网络缓冲区不足，请稍后重试';
          end;
        10056, 106:
          begin
            ButtonMsg := '已连接';
            ErrorMsg := '套接字已处于连接状态';
          end;
        10057, 107:
          begin
            ButtonMsg := '未连接';
            ErrorMsg := '套接字未建立连接';
          end;
        10058, 108:
          begin
            ButtonMsg := '连接已关闭';
            ErrorMsg := '连接已被关闭';
          end;
        10059, 109:
          begin
            ButtonMsg := '引用过多';
            ErrorMsg := '网络连接引用过多';
          end;
        10062, 40:
          begin
            ButtonMsg := '路由循环';
            ErrorMsg := '检测到路由循环';
          end;
        10063, 36:
          begin
            ButtonMsg := '名称过长';
            ErrorMsg := '主机名或路径过长';
          end;
        10091:
          begin
            ButtonMsg := '网络未就绪';
            ErrorMsg := '网络子系统未准备好';
          end;
        10092:
          begin
            ButtonMsg := '版本不支持';
            ErrorMsg := 'Windows Sockets版本不支持';
          end;
        10093:
          begin
            ButtonMsg := '网络未初始化';
            ErrorMsg := '网络组件未初始化，请重启程序';
          end;
        10109:
          begin
            ButtonMsg := '服务错误';
            ErrorMsg := '网络服务供应方初始化失败';
          end;
        11001, 2:
          begin
            ButtonMsg := '主机未找到';
            ErrorMsg := '无法解析主机名，请检查DNS设置';
          end;
        11002:
          begin
            ButtonMsg := 'DNS错误';
            ErrorMsg := 'DNS解析失败，请稍后重试';
          end;
        11003:
          begin
            ButtonMsg := 'DNS错误';
            ErrorMsg := 'DNS解析不可恢复的错误';
          end;
        11004:
          begin
            ButtonMsg := 'DNS无记录';
            ErrorMsg := 'DNS请求成功但无记录';
          end;
      else
        begin
          ButtonMsg := '发生未知错误';
          ErrorMsg := '未知错误';
        end;
      end;

      DisplayMsg := '消息接收失败: ' + ErrorMsg + #13#10 +
                    '错误信息: ' + AMessage + #13#10 +
                    '异常类型: ' + AExceptionClass.ClassName;

      if Assigned(FCurrentActionBtn) then
      begin
        FCurrentActionBtn.Text := ButtonMsg;
        FCurrentActionBtn.TextSettings.FontColor := TAlphaColorRec.Yellow;
        Application.ProcessMessages;
        ResetActionButton;
      end;

      TDialogService.MessageDialog(DisplayMsg,
        TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end);
end;

// ================== 10秒计时器 ==================
procedure Tmainform.TimeoutTimer(Sender: TObject);
var
  FinalText: string;
begin
  Timeout.Enabled := False;

  if (FCurrentActionBtn = nil) or (FCurrentActionBtn.Enabled) or FResponseProcessed then
    Exit;

  if FCurrentActionType = 'send' then
    FinalText := '消息已发出，未收到对方确认'
  else if FCurrentActionType = 'end' then
    FinalText := '结束命令已发出，未收到对方确认'
  else if FCurrentActionType = 'cmd' then
    FinalText := 'cmd命令已发出，执行状态未知'
  else
    FinalText := '操作已完成';

  FResponseProcessed := True;

  if Assigned(FCurrentActionBtn) then
  begin
    FCurrentActionBtn.Text := FinalText;
    FCurrentActionBtn.TextSettings.FontColor := TAlphaColorRec.Darkviolet;
  end;

  ResetActionButton;
end;

// ================== 发送消息 ==================
procedure Tmainform.sendmsgbtnClick(Sender: TObject);
var
  TargetIP, MessageContent, DurationStr, DisplayModeStr: string;
begin
  if not ValidateAndGetTargetIP(sendIPtext.Text.Trim, TargetIP) then Exit;
  if not CheckLocalNetworkAvailable then Exit;

  MessageContent := msgtext.Text.Trim;

  if MessageContent = '' then
  begin
    TDialogService.MessageDialog('消息不能为空！',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if Pos('|', MessageContent) > 0 then
  begin
    TDialogService.MessageDialog('消息内容中不允许包含"|"分隔符！',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  DurationStr := msgdurationtext.Text.Trim;
  if (DurationStr = '') or (DurationStr = '0') then
    DurationStr := '-1';

  if normal.IsChecked then
    DisplayModeStr := 'NORMAL'
  else if typewriter.IsChecked then
    DisplayModeStr := 'TYPEWRITER'
  else if blink.IsChecked then
    DisplayModeStr := 'BLINK'
  else if fullscreen.IsChecked then
    DisplayModeStr := 'FULLSCREEN'
  else
    DisplayModeStr := 'MARQUEEN';

  if not manualcloseSwitch.IsChecked then
    DisplayModeStr := DisplayModeStr + '_NOCLOSE';

  try
    var MessageToSend := Format('%s|%s|%s|%s',
      [FCurrentUsername, MessageContent, DurationStr, DisplayModeStr]);

    Timeout.Enabled := False;
    FResponseProcessed := False;

    mainUDP.Send(TargetIP, 25105, MessageToSend, IndyTextEncoding_UTF8);

    FCurrentActionBtn := sendmsgbtn;
    FCurrentActionType := 'send';
    sendmsgbtn.Text := '消息已发送，等待对方接收...';
    sendmsgbtn.TextSettings.FontColor := TAlphaColorRec.Black;

    DisableSendButtons;
    Timeout.Enabled := True;

  except
    on E: Exception do
    begin
      FCurrentActionBtn := sendmsgbtn;
      FCurrentActionType := 'send';

      var ErrorCode := ExtractSocketErrorCode(E.Message);
      var FriendlyMsg := '';

      case ErrorCode of
        10054, 104:  FriendlyMsg := '目标设备未响应，请检查对方是否在线';
        10061, 111:  FriendlyMsg := '对方拒绝了连接，请检查防火墙设置';
        10060, 110:  FriendlyMsg := '发送超时，请检查网络连接';
        10065, 113:  FriendlyMsg := '目标主机不可达，请检查IP地址是否可用';
        10051, 101:  FriendlyMsg := '目标网络不可达，请检查网络设置';
        10064, 112:  FriendlyMsg := '目标主机已关机或离线';
        10013, 13:   FriendlyMsg := '您无权访问';
        10048, 98:   FriendlyMsg := '端口已被占用，请关闭占用程序';
        10049, 99:   FriendlyMsg := 'IP地址不可用，请检查输入是否正确';
      else
        FriendlyMsg := E.Message;
      end;

      sendmsgbtn.Text := '消息发送失败';
      sendmsgbtn.TextSettings.FontColor := TAlphaColorRec.Red;
      Application.ProcessMessages;

      DisableSendButtons;
      ResetActionButton;

      TDialogService.MessageDialog('消息发送失败: ' + FriendlyMsg + #13#10 +
                                   '错误信息: ' + E.Message + #13#10 +
                                   '异常类型: ' + E.ClassName,
        TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  end;
end;

// ================== 结束消息 ==================
procedure Tmainform.endmsgbtnClick(Sender: TObject);
var
  TargetIP: string;
begin
  if not ValidateAndGetTargetIP(endIPtext.Text.Trim, TargetIP) then Exit;
  if not CheckLocalNetworkAvailable then Exit;

  try
    var MessageToSend := Format('%s|%s|%s|%s',
      [FCurrentUsername, 'CLOSE_ALL_WINDOWS', '0', 'CLOSE']);

    Timeout.Enabled := False;
    FResponseProcessed := False;

    mainUDP.Send(TargetIP, 25105, MessageToSend, IndyTextEncoding_UTF8);

    FCurrentActionBtn := endmsgbtn;
    FCurrentActionType := 'end';
    endmsgbtn.Text := '结束命令已发送，等待对方响应...';
    endmsgbtn.TextSettings.FontColor := TAlphaColorRec.Black;

    DisableSendButtons;
    Timeout.Enabled := True;

  except
    on E: Exception do
    begin
      FCurrentActionBtn := endmsgbtn;
      FCurrentActionType := 'end';

      var ErrorCode := ExtractSocketErrorCode(E.Message);
      var FriendlyMsg := '';

      case ErrorCode of
        10054, 104:  FriendlyMsg := '目标设备未响应，请检查对方是否在线';
        10061, 111:  FriendlyMsg := '对方拒绝了连接，请检查防火墙设置';
        10060, 110:  FriendlyMsg := '发送超时，请检查网络连接';
        10065, 113:  FriendlyMsg := '目标主机不可达，请检查IP地址是否可用';
        10051, 101:  FriendlyMsg := '目标网络不可达，请检查网络设置';
        10064, 112:  FriendlyMsg := '目标主机已关机或离线';
        10013, 13:   FriendlyMsg := '您无权访问';
        10048, 98:   FriendlyMsg := '端口已被占用，请关闭占用程序';
        10049, 99:   FriendlyMsg := 'IP地址不可用，请检查输入是否正确';
      else
        FriendlyMsg := E.Message;
      end;

      endmsgbtn.Text := '结束命令发送失败';
      endmsgbtn.TextSettings.FontColor := TAlphaColorRec.Red;
      Application.ProcessMessages;

      DisableSendButtons;
      ResetActionButton;

      TDialogService.MessageDialog('消息发送失败: ' + FriendlyMsg + #13#10 +
                                   '错误信息: ' + E.Message + #13#10 +
                                   '异常类型: ' + E.ClassName,
        TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  end;
end;

// ================== 发送cmd命令 ==================
procedure Tmainform.sendcmdbtnClick(Sender: TObject);
var
  TargetIP, CommandContent, PermissionStr: string;
  TargetPort: Integer;
begin
  if not ValidateAndGetTargetIP(cmdIPtext.Text.Trim, TargetIP) then Exit;
  if not CheckLocalNetworkAvailable then Exit;

  CommandContent := cmdtext.Text.Trim;

  if CommandContent = '' then
  begin
    TDialogService.MessageDialog('cmd命令不能为空！',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if Pos('|', CommandContent) > 0 then
  begin
    TDialogService.MessageDialog('cmd命令中不允许包含"|"分隔符！',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  if user.IsChecked then
  begin
    PermissionStr := 'USER';
    TargetPort := 25105;
  end
  else
  begin
    PermissionStr := 'SYSTEM';
    TargetPort := 25106;
  end;

  try
    var MessageToSend := Format('%s|%s|5|CMD|%s',
      [FCurrentUsername, CommandContent, PermissionStr]);

    Timeout.Enabled := False;
    FResponseProcessed := False;

    mainUDP.Send(TargetIP, TargetPort, MessageToSend, IndyTextEncoding_UTF8);

    FCurrentActionBtn := sendcmdbtn;
    FCurrentActionType := 'cmd';
    sendcmdbtn.Text := 'cmd命令已发送，等待执行结果...';
    sendcmdbtn.TextSettings.FontColor := TAlphaColorRec.Black;

    DisableSendButtons;
    Timeout.Enabled := True;

  except
    on E: Exception do
    begin
      FCurrentActionBtn := sendcmdbtn;
      FCurrentActionType := 'cmd';

      var ErrorCode := ExtractSocketErrorCode(E.Message);
      var FriendlyMsg := '';

      case ErrorCode of
        10054, 104:  FriendlyMsg := '目标设备未响应，请检查对方是否在线';
        10061, 111:  FriendlyMsg := '对方拒绝了连接，请检查防火墙设置';
        10060, 110:  FriendlyMsg := '发送超时，请检查网络连接';
        10065, 113:  FriendlyMsg := '目标主机不可达，请检查IP地址是否可用';
        10051, 101:  FriendlyMsg := '目标网络不可达，请检查网络设置';
        10064, 112:  FriendlyMsg := '目标主机已关机或离线';
        10013, 13:   FriendlyMsg := '您无权访问';
        10048, 98:   FriendlyMsg := '端口已被占用，请关闭占用程序';
        10049, 99:   FriendlyMsg := 'IP地址不可用，请检查输入是否正确';
      else
        FriendlyMsg := E.Message;
      end;

      sendcmdbtn.Text := 'cmd命令发送失败';
      sendcmdbtn.TextSettings.FontColor := TAlphaColorRec.Red;
      Application.ProcessMessages;

      DisableSendButtons;
      ResetActionButton;

      TDialogService.MessageDialog('消息发送失败: ' + FriendlyMsg + #13#10 +
                                   '错误信息: ' + E.Message + #13#10 +
                                   '异常类型: ' + E.ClassName,
        TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  end;
end;

// ================== 版本比较 ==================
function Tmainform.CompareVersion(const V1, V2: string): Integer;
var
  Parts1, Parts2: TArray<string>;
  i: Integer;
  Num1, Num2: Integer;
begin
  Result := 0;
  Parts1 := V1.Split(['.']);
  Parts2 := V2.Split(['.']);

  for i := 0 to 2 do
  begin
    Num1 := 0;
    Num2 := 0;
    if i < Length(Parts1) then
      Num1 := StrToIntDef(Parts1[i], 0);
    if i < Length(Parts2) then
      Num2 := StrToIntDef(Parts2[i], 0);

    if Num1 > Num2 then
    begin
      Result := 1;
      Exit;
    end
    else if Num1 < Num2 then
    begin
      Result := -1;
      Exit;
    end;
  end;
end;

// ================== 获取更新级别 ==================
function Tmainform.GetVersionLevel(const CurrentVer, NewVer: string): Integer;
var
  PartsCurr, PartsNew: TArray<string>;
  CurrMajor, CurrMinor, CurrRev: Integer;
  NewMajor, NewMinor, NewRev: Integer;
begin
  Result := 3;
  PartsCurr := CurrentVer.Split(['.']);
  PartsNew := NewVer.Split(['.']);

  CurrMajor := StrToIntDef(PartsCurr[0], 0);
  CurrMinor := StrToIntDef(PartsCurr[1], 0);
  CurrRev := StrToIntDef(PartsCurr[2], 0);

  NewMajor := StrToIntDef(PartsNew[0], 0);
  NewMinor := StrToIntDef(PartsNew[1], 0);
  NewRev := StrToIntDef(PartsNew[2], 0);

  if NewMajor > CurrMajor then
    Result := 1
  else if NewMinor > CurrMinor then
    Result := 2
  else if NewRev > CurrRev then
    Result := 3;
end;

// ================== 打开下载链接 ==================
procedure Tmainform.OpenDownloadUrl(const Url: string);
begin
  {$IFDEF MSWINDOWS}
  ShellExecute(0, 'open', PChar(Url), '', '', SW_SHOWNORMAL);
  {$ENDIF}
  {$IFDEF MACOS}
  _system(PAnsiChar('open ' + AnsiString(Url)));
  {$ENDIF}
  {$IFDEF LINUX}
  _system(PAnsiChar('xdg-open ' + AnsiString(Url)));
  {$ENDIF}
end;

// ================== 显示更新对话框 ==================
procedure Tmainform.ShowUpdateDialog(const VersionInfo: string;
                                      const UpdateNotes: string;
                                      const PublishDate: string;
                                      const DownloadUrl: string;
                                      const UpdateLevel: Integer);
var
  DialogMsg: string;
  DialogTitle: string;
begin
  // 根据更新级别设置标题
  if UpdateLevel = 1 then
    DialogTitle := '全新版本 v' + VersionInfo
  else
    DialogTitle := '发现新版本 v' + VersionInfo;

  // 构建弹窗内容
  DialogMsg := DialogTitle + #13#10#13#10;

  if PublishDate <> '' then
    DialogMsg := DialogMsg + '发布时间: ' + PublishDate + #13#10;

  DialogMsg := DialogMsg + '更新内容: ' + #13#10 + UpdateNotes + #13#10#13#10;

  DialogMsg := DialogMsg + '当前版本: v' + APP_VERSION + #13#10#13#10;

  if UpdateLevel = 1 then
    DialogMsg := DialogMsg + '本次更新为架构层面升级，建议立即更新！'
  else if UpdateLevel = 2 then
    DialogMsg := DialogMsg + '建议更新以获得更好的体验，是否现在更新？'
  else
    DialogMsg := DialogMsg + '是否现在更新？';

  if UpdateLevel = 1 then
  begin
    TDialogService.MessageDialog(DialogMsg, TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrOk then
          OpenDownloadUrl(DownloadUrl);
      end);
  end
  else
  begin
    TDialogService.MessageDialog(DialogMsg, TMsgDlgType.mtInformation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
          OpenDownloadUrl(DownloadUrl);
      end);
  end;
end;

// ================== 解析版本响应 ==================
procedure Tmainform.ParseVersionResponse(const Content: string; ShowDialog: Boolean);
var
  JSON: TJSONObject;
  NewVersion: string;
  UpdateNotes: string;
  DownloadUrl: string;
  PublishDate: string;
  UpdateLevel: Integer;
  StartupCount: Integer;
  Ini: TIniFile;
begin
  try
    JSON := TJSONObject.ParseJSONValue(Content) as TJSONObject;
    try
      {$IFDEF MSWINDOWS}
      NewVersion := JSON.GetValue<string>('windows_version');
      UpdateNotes := JSON.GetValue<string>('windows_notes');
      DownloadUrl := JSON.GetValue<string>('windows');
      PublishDate := JSON.GetValue<string>('windows_date');
      {$ENDIF}
      {$IFDEF MACOS}
      NewVersion := JSON.GetValue<string>('mac_version');
      UpdateNotes := JSON.GetValue<string>('mac_notes');
      DownloadUrl := JSON.GetValue<string>('mac');
      PublishDate := JSON.GetValue<string>('mac_date');
      {$ENDIF}
      {$IFDEF LINUX}
      NewVersion := JSON.GetValue<string>('linux_version');
      UpdateNotes := JSON.GetValue<string>('linux_notes');
      DownloadUrl := JSON.GetValue<string>('linux');
      PublishDate := JSON.GetValue<string>('linux_date');
      {$ENDIF}

      if NewVersion = '' then
      begin
        if ShowDialog then
          TDialogService.MessageDialog('版本信息获取失败',
            TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
        Exit;
      end;

      // 检查是否有更新
      if CompareVersion(NewVersion, APP_VERSION) > 0 then
      begin
        // 有更新：显示红点
        updatenotify.Visible := True;

        // 获取更新级别
        UpdateLevel := GetVersionLevel(APP_VERSION, NewVersion);

        // 根据更新级别决定是否弹窗
        if UpdateLevel = 1 then
        begin
          // 主版本更新：强制弹窗
          ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
        end
        else if UpdateLevel = 2 then
        begin
          // 次版本更新：判断启动计数是否 ≥8
          if not ShowDialog then  // 启动时自动检查
          begin
            Ini := TIniFile.Create(GetAppConfigPath);
            try
              // 读取已累加的启动次数（由 FormCreate 每次启动时累加）
              StartupCount := Ini.ReadInteger('Update', 'StartupCount', 0);

              if StartupCount >= 8 then
              begin
                ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
                // 弹窗后重置计数为0（开始新一轮）
                Ini.WriteInteger('Update', 'StartupCount', 0);
              end;
              // 未满8次：不弹窗，计数保持不变
            finally
              Ini.Free;
            end;
          end
          else  // 用户手动点击检查更新，直接弹窗
          begin
            ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
          end;
        end
        else if UpdateLevel = 3 then
        begin
          // 修订版本更新：只显示红点
          if ShowDialog then
            ShowUpdateDialog(NewVersion, UpdateNotes, PublishDate, DownloadUrl, UpdateLevel);
        end;
      end
      else
      begin
        // 无更新：隐藏红点
        updatenotify.Visible := False;

        if ShowDialog then
          TDialogService.MessageDialog('当前已是最新版本~赞！',
            TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
      end;
    finally
      JSON.Free;
    end;
  except
    on E: Exception do
    begin
      if ShowDialog then
        TDialogService.MessageDialog('解析更新信息失败: ' + E.Message,
          TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  end;

  FUpdatingInProgress := False;
end;

// ================== 执行检查更新==================
procedure Tmainform.DoCheckUpdate(ShowDialog: Boolean);
var
  Response: IHTTPResponse;
  Content: string;
  RetryCount: Integer;
  ErrorMsg: string;
begin
  {$IFDEF MSWINDOWS}
  VersionHTTPClient.UserAgent := 'RemoteControl-Windows/' + APP_VERSION;
  {$ENDIF}
  {$IFDEF MACOS}
    VersionHTTPClient.UserAgent := 'RemoteControl-macOS/' + APP_VERSION;
  {$ENDIF}
  {$IFDEF LINUX}
    VersionHTTPClient.UserAgent := 'RemoteControl-Linux/' + APP_VERSION;
  {$ENDIF}
  for RetryCount := 0 to 2 do
  begin
    try
      Response := VersionHTTPClient.Get('https://stackni.github.io/remote-control-platform/version.json');
      Content := Response.ContentAsString(TEncoding.UTF8);

      TThread.Queue(nil,
        procedure
        begin
          ParseVersionResponse(Content, ShowDialog);
        end);
      Exit;
    except
      on E: Exception do
      begin
        ErrorMsg := '错误信息: ' + E.Message + sLineBreak +
                    '错误类型: ' + E.ClassName;
        if RetryCount = 2 then
        begin
          if ShowDialog then
            TThread.Queue(nil,
              procedure
              begin
                TDialogService.MessageDialog('检查更新时出错' + sLineBreak + ErrorMsg,
                  TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
              end);
          Break;
        end;
      end;
    end;
  end;
  FUpdatingInProgress := False;
end;

// ================== 检查更新入口 ==================
procedure Tmainform.CheckForUpdate(ShowDialog: Boolean);
begin
  if FUpdatingInProgress then
  begin
    if ShowDialog then
    begin
      TDialogService.MessageDialog('正在检查更新，请稍后再试！',
        TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
    Exit;
  end;

  FUpdatingInProgress := True;

  // 使用匿名线程异步执行检查更新，不阻塞主线程
  TThread.CreateAnonymousThread(
    procedure
    begin
      DoCheckUpdate(ShowDialog);
    end
  ).Start;
end;

// ================== 跳过证书检查 ==================
procedure Tmainform.VersionHTTPClientValidateServerCertificate(
  const Sender: TObject; const ARequest: TURLRequest;
  const Certificate: TCertificate; var Accepted: Boolean);
begin
  Accepted := True;
end;

end.
