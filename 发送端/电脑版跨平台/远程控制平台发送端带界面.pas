unit 远程控制平台发送端带界面;

interface

uses
  System.SysUtils, System.UITypes, System.Classes, FMX.Types, FMX.Controls,
  FMX.Controls.Presentation, FMX.Forms, FMX.Objects, FMX.Layouts, FMX.StdCtrls,
  IdUDPServer, IdUDPClient, IdGlobal, FMX.Edit, FMX.Effects, FMX.Filter.Effects,
  FMX.Platform, System.IOUtils, System.IniFiles, System.DateUtils, IdStack,
  FMX.Skia, System.Skia, IdBaseComponent, IdComponent, IdUDPBase, FMX.ComboEdit,
  System.Generics.Collections, FMX.DialogService
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
    background: TRectangle;
    closeimage: TSkSvg;
    Layout: TLayout;
    minimizeimage: TSkSvg;
    appicon: TImage;
    sidebar: TLayout;
    sendbtn: TSkSvg;
    endbtn: TSkSvg;
    cmdbtn: TSkSvg;
    userplanebackground: TRectangle;
    sendlayout: TLayout;
    sendUDP: TIdUDPClient;
    backUDP: TIdUDPServer;
    sendScrollBox: TVertScrollBox;
    msgtext: TEdit;
    msgtextClear: TClearEditButton;
    backgroundGlowEffect: TGlowEffect;
    appiconGlowEffect: TGlowEffect;
    line: TLine;
    pinimage: TSkSvg;
    topmosted: TFillRGBEffect;
    sendclickedbtn: TSkSvg;
    endclickedbtn: TSkSvg;
    cmdclickedbtn: TSkSvg;
    sendhighlight: TFillRGBEffect;
    endhighlight: TFillRGBEffect;
    cmdhighlight: TFillRGBEffect;
    sendmsgbtn: TButton;
    sendcaption: TLabel;
    sendIPlabel: TLabel;
    marqueen: TRadioButton;
    sendmodeoptions: TLayout;
    sendmodelabel: TLabel;
    normal: TRadioButton;
    msgdurationlabel: TLabel;
    msgdurationtext: TEdit;
    msgdurationspinbtn: TSpinEditButton;
    typewriter: TRadioButton;
    blink: TRadioButton;
    fullscreen: TRadioButton;
    manualcloseSwitch: TSwitch;
    manualcloseSwitchlabel: TLabel;
    endlayout: TLayout;
    endcaption: TLabel;
    endIPlabel: TLabel;
    endmsgbtn: TButton;
    cmdlayout: TLayout;
    cmdcaption: TLabel;
    cmdIPlabel: TLabel;
    endScrollBox: TVertScrollBox;
    cmdScrollBox: TVertScrollBox;
    cmdtext: TEdit;
    cmdtextClear: TClearEditButton;
    cmdtextlabel: TLabel;
    system: TRadioButton;
    permissionoptions: TLayout;
    permissionlabel: TLabel;
    user: TRadioButton;
    sendcmdbtn: TButton;
    homelayout: TLayout;
    guidecaption: TLabel;
    version: TLabel;
    homesendbtn: TRectangle;
    homesendbtnlabel: TLabel;
    homelistbtn: TRectangle;
    homelistcontainer: TRectangle;
    homeendbtn: TRectangle;
    homecmdbtn: TRectangle;
    homeendbtnlabel: TLabel;
    homecmdbtnlabel: TLabel;
    homelistdown: TSkSvg;
    homelistup: TSkSvg;
    homebtn: TSkSvg;
    mobilebtn: TSkSvg;
    settingsbtn: TSkSvg;
    homehighlight: TFillRGBEffect;
    mobilehighlight: TFillRGBEffect;
    settingshighlight: TFillRGBEffect;
    homeclickedbtn: TSkSvg;
    mobileclickedbtn: TSkSvg;
    settingsclickedbtn: TSkSvg;
    mobilelayout: TLayout;
    apkQRCode: TImage;
    mobiledownloadhint: TLabel;
    androidonlyhint: TLabel;
    mobilecaption: TLabel;
    mobileScrollBox: TVertScrollBox;
    settingslayout: TLayout;
    settingscaption: TLabel;
    settingsScrollBox: TVertScrollBox;
    homecurrentusername: TLabel;
    homelocalIPbtn: TCircle;
    homelocalIPimage: TSkSvg;
    homelocalIPlabel: TLabel;
    homedonatebtn: TCircle;
    homedonateimage: TSkSvg;
    homedonatelabel: TLabel;
    localIPlayout: TLayout;
    localIPScrollBox: TVertScrollBox;
    localIPcaption: TLabel;
    localIPlabel: TLabel;
    backfromlocalIPbtn: TSkSvg;
    donatelayout: TLayout;
    donatecaption: TLabel;
    donateScrollBox: TVertScrollBox;
    backfromdonatebtn: TSkSvg;
    donateQRCode: TImage;
    donatehint: TLabel;
    refreshlocalIPbtn: TButton;
    copylocalIPbtn: TButton;
    homeglobeimage: TSkSvg;
    generalsettingslabel: TLabel;
    changeusernamebtn: TButton;
    changeIPlistbtn: TButton;
    advancedoptions: TLabel;
    skiaswitch: TSwitch;
    skiaswitchlabel: TLabel;
    changeusernamelayout: TLayout;
    changeusernamecaption: TLabel;
    backfromchangeusernamebtn: TSkSvg;
    changeusernameScrollBox: TVertScrollBox;
    currentusername: TLabel;
    newusernametext: TEdit;
    newusernametextClear: TClearEditButton;
    newusernamebtn: TButton;
    newusernamelabel: TLabel;
    changeIPlistlayout: TLayout;
    backfromchangeIPlistbtn: TSkSvg;
    changeIPlistcaption: TLabel;
    changeIPlistScrollBox: TVertScrollBox;
    sendIPtext: TComboEdit;
    endIPtext: TComboEdit;
    cmdIPtext: TComboEdit;
    localIPitem: TRectangle;
    localIPtip: TLabel;
    localitemcolor: TRectangle;
    localIPtipIP: TLabel;
    addIPtipbtn: TButton;
    homelistpopup: TPopup;
    homelistpopupparent: TLayout;
    appcard: TPopup;
    appcardrect: TRectangle;
    appcardrectGlowEffect: TGlowEffect;
    appname: TLabel;
    appversion: TLabel;
    applogo: TImage;
    applogoGlowEffect: TGlowEffect;
    homegithubbtn: TCircle;
    homegithublabel: TLabel;
    homegithubimage: TSkSvg;

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

  private
    { Private declarations }
    FActiveSidebarButton: TControl;
    FActiveHomeSubPage: THomeSubPage;
    FActiveSettingsSubPage: TSettingsSubPage;
    FActiveButtonType: string;
    FCurrentUsername: string;
    FIPItems: TList<TRectangle>;
    FIPLines: TList<TLine>;
    FIPAliases: TIPAliasList;
    FCurrentIPItem: TRectangle;
    FCanappiconEffectchange: Boolean;
    procedure SetActiveSidebarButton(Button: TControl);
    procedure SaveTopMostSetting(TopMost: Boolean);
    function LoadTopMostSetting: Boolean;
    function GetRandomGreeting: string;
    function GetIPAddressInfo: string;
    function GetAppConfigPath: string;
    function LoadSkiaSetting: Boolean;
    procedure UpdatePinImageState;
    procedure UpdateSidebarButtonState(ButtonType: string; IsActive: Boolean);
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
    procedure CreateIPItem(const Item: TIPAliasItem; Index: Integer; IsLocalLoopback: Boolean = False);
    procedure UpdateLayout;
    procedure UpdateComboEditItems;
    procedure DisablesendUDPbtn;
    procedure EnablesendUDPbtn;

    function ValidateIPAddress(const IP: string): Boolean;
    procedure AddIPAlias(const Name, IP: string);
    procedure ShowIPitemButtons(IPitem: TRectangle);
    procedure HideIPitemButtons(IPitem: TRectangle);
    function ValidateAndGetTargetIP(const InputText: string; out TargetIP: string): Boolean;
    function CheckLocalNetworkAvailable: Boolean;

  public
    { Public declarations }
  end;

var
  mainform: Tmainform;

implementation

{$R *.fmx}
{$R *.Surface.fmx MSWINDOWS}
{$R *.Windows.fmx MSWINDOWS}
{$R *.NmXhdpiPh.fmx}
{$R *.iPad.fmx}

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

  if IP.Trim = '' then Exit;

  Parts := IP.Split(['.']);
  if Length(Parts) <> 4 then Exit;

  for i := 0 to 3 do
  begin
    if (Parts[i] = '') or not TryStrToInt(Parts[i], Num) then Exit;

    for var ch in Parts[i] do
    begin
      if (ch < '0') or (ch > '9') then Exit;
    end;
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
  if topmosted.Enabled then
  begin
    pinimage.Hint := '取消置顶';
    pinimage.Opacity := 1;
  end
  else
  begin
    pinimage.Hint := '置顶';
    pinimage.Opacity := 0.6;
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
  if BackFrom = 'localIP' then
    SubPage := hspLocalIP
  else if BackFrom = 'donate' then
    SubPage := hspDonate
  else if BackFrom = 'changeusername' then
  begin
    newusernametext.Text := '';

    if FActiveSettingsSubPage = sspChangeUsername then
    begin
      SetActiveSidebarButton(settingsbtn);
      ShowCorrespondingLayout('settings');
      FActiveSettingsSubPage := sspNone;
    end;
    Exit;
  end
  else if BackFrom = 'changeIPlist' then
  begin
    if FActiveSettingsSubPage = sspChangeIPList then
    begin
      SetActiveSidebarButton(settingsbtn);
      ShowCorrespondingLayout('settings');
      FActiveSettingsSubPage := sspNone;
    end;
    Exit;
  end
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
  UpdateSidebarButtonState(FActiveButtonType, False);

  sendhighlight.Enabled := False;
  endhighlight.Enabled := False;
  cmdhighlight.Enabled := False;
  homehighlight.Enabled := False;
  mobilehighlight.Enabled := False;
  settingshighlight.Enabled := False;

  sendclickedbtn.Visible := False;
  endclickedbtn.Visible := False;
  cmdclickedbtn.Visible := False;
  homeclickedbtn.Visible := False;
  mobileclickedbtn.Visible := False;
  settingsclickedbtn.Visible := False;

  sendbtn.Visible := True;
  endbtn.Visible := True;
  cmdbtn.Visible := True;
  homebtn.Visible := True;
  mobilebtn.Visible := True;
  settingsbtn.Visible := True;

  FActiveSidebarButton := Button;

  if Button = sendbtn then
  begin
    FActiveButtonType := 'send';
    sendbtn.Visible := False;
    sendclickedbtn.Visible := True;
    ShowCorrespondingLayout('send');
  end
  else if Button = endbtn then
  begin
    FActiveButtonType := 'end';
    endbtn.Visible := False;
    endclickedbtn.Visible := True;
    ShowCorrespondingLayout('end');
  end
  else if Button = cmdbtn then
  begin
    FActiveButtonType := 'cmd';
    cmdbtn.Visible := False;
    cmdclickedbtn.Visible := True;
    ShowCorrespondingLayout('cmd');
  end
  else if Button = homebtn then
  begin
    FActiveButtonType := 'home';
    homebtn.Visible := False;
    homeclickedbtn.Visible := True;
    ShowCorrespondingLayout('home');
  end
  else if Button = mobilebtn then
  begin
    FActiveButtonType := 'mobile';
    mobilebtn.Visible := False;
    mobileclickedbtn.Visible := True;
    ShowCorrespondingLayout('mobile');
  end
  else if Button = settingsbtn then
  begin
    FActiveButtonType := 'settings';
    settingsbtn.Visible := False;
    settingsclickedbtn.Visible := True;
    ShowCorrespondingLayout('settings');
  end;
end;

procedure Tmainform.UpdateSidebarButtonState(ButtonType: string; IsActive: Boolean);
begin
  if ButtonType = 'send' then sendhighlight.Enabled := IsActive
  else if ButtonType = 'end' then endhighlight.Enabled := IsActive
  else if ButtonType = 'cmd' then cmdhighlight.Enabled := IsActive
  else if ButtonType = 'home' then homehighlight.Enabled := IsActive
  else if ButtonType = 'mobile' then mobilehighlight.Enabled := IsActive
  else if ButtonType = 'settings' then settingshighlight.Enabled := IsActive;
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

    // 从配置加载
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

    // 创建UI项
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

  // 清理IP项
  for var i := FIPItems.Count - 1 downto 0 do
  begin
    if (FIPItems[i] <> nil) and (FIPItems[i] <> localIPitem) then
    begin
      FIPItems[i].Free;
    end;
  end;
  FIPItems.Clear;
  if localIPitem <> nil then
    FIPItems.Add(localIPitem);

  // 清理分隔线
  for var i := FIPLines.Count - 1 downto 0 do
  begin
    FIPLines[i].Free;
  end;
  FIPLines.Clear;
end;

procedure Tmainform.CreateIPItem(const Item: TIPAliasItem; Index: Integer; IsLocalLoopback: Boolean = False);
var
  IPItem: TRectangle;
  IPtip: TLabel;
  IPtipIP: TLabel;
  editIPtipbtn: TSkSvg;
  deleteIPtipbtn: TSkSvg;
  itemcolor: TRectangle;
  editEffect: TFillRGBEffect;
  deleteEffect: TFillRGBEffect;
  DivideLine: TLine;
begin
  if IsLocalLoopback then
  begin
    localIPitem.Position.X := 8;
    localIPitem.Position.Y := 8;
    localIPitem.Width := 733;
    localIPitem.Height := 94;

    localIPtip.Text := '本地回环';
    localIPtipIP.Text := 'IP: 127.0.0.1';
    Exit;
  end;

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

    IPItem.Tag := Index;
    IPItem.OnMouseMove := IPitemMouseMove;
    IPItem.OnMouseLeave := IPitemMouseLeave;

    FIPItems.Add(IPItem);

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

    editEffect := TFillRGBEffect.Create(editIPtipbtn);
    editEffect.Parent := editIPtipbtn;
    editEffect.Name := 'editIPtipEffect_' + Index.ToString;
    editEffect.Enabled := False;
    editEffect.Color := $FF4FFF4F;

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

    deleteEffect := TFillRGBEffect.Create(deleteIPtipbtn);
    deleteEffect.Parent := deleteIPtipbtn;
    deleteEffect.Name := 'deleteIPtipEffect_' + Index.ToString;
    deleteEffect.Enabled := False;
    deleteEffect.Color := $FFFF4F4F;

    IPItem.Size.Width := 733;
    IPItem.Size.Height := 94;
    IPItem.Position.X := 8;

    DivideLine := TLine.Create(changeIPlistScrollBox);
    DivideLine.Parent := changeIPlistScrollBox;
    DivideLine.Name := 'divideIPtipsline_' + Index.ToString;
    DivideLine.LineType := TLineType.Diagonal;
    DivideLine.Stroke.Color := $FF363636;
    DivideLine.Size.Width := 717;
    DivideLine.Size.Height := 1;
    FIPLines.Add(DivideLine);

  except
    on E: Exception do
    begin
      if Assigned(IPItem) then IPItem.Free;
      raise;
    end;
  end;
end;

procedure Tmainform.UpdateLayout;
const
  NORMAL_WIDTH = 733;
  NARROW_WIDTH = 713;
  NORMAL_TIP_WIDTH = 610;
  NARROW_TIP_WIDTH = 590;
  NORMAL_LINE_WIDTH = 717;
  NARROW_LINE_WIDTH = 697;
  EDIT_BTN_X_NORMAL = 652;
  DELETE_BTN_X_NORMAL = 688;
  EDIT_BTN_X_NARROW = 632;
  DELETE_BTN_X_NARROW = 668;
  LINE_INDENT = 16;
  ITEM_SPACING = 8;
  MAX_HEIGHT = 475;
var
  i, j: Integer;
  TotalHeight: Single;
  NeedAdjustWidth: Boolean;
  Lbl: TLabel;
  Svg: TSkSvg;
  ItemWidth, TipWidth, LineWidth: Integer;
  EditBtnX, DeleteBtnX: Integer;
begin
  TotalHeight := ITEM_SPACING;

  // 定位本地回环项
  if localIPitem <> nil then
  begin
    localIPitem.Position.Y := TotalHeight;
    TotalHeight := TotalHeight + localIPitem.Height + ITEM_SPACING;
  end;

  // 定位所有自定义IP项和分隔线
  for i := 0 to FIPItems.Count - 1 do
  begin
    if FIPItems[i] = localIPitem then
      Continue;

    if i > 0 then
    begin
      var LineIndex := i - 1;
      if LineIndex < FIPLines.Count then
      begin
        FIPLines[LineIndex].Position.Y := TotalHeight - 4;
        FIPLines[LineIndex].Position.X := LINE_INDENT;
      end;
    end;

    FIPItems[i].Position.Y := TotalHeight;
    TotalHeight := TotalHeight + FIPItems[i].Height + ITEM_SPACING;
  end;

  // 检查是否需要调整宽度
  NeedAdjustWidth := (TotalHeight + addIPtipbtn.Height) > MAX_HEIGHT;

  // 根据是否需要调整宽度，设置不同的尺寸
  if NeedAdjustWidth then
  begin
    ItemWidth := NARROW_WIDTH;
    TipWidth := NARROW_TIP_WIDTH;
    LineWidth := NARROW_LINE_WIDTH;
    EditBtnX := EDIT_BTN_X_NARROW;
    DeleteBtnX := DELETE_BTN_X_NARROW;
  end
  else
  begin
    ItemWidth := NORMAL_WIDTH;
    TipWidth := NORMAL_TIP_WIDTH;
    LineWidth := NORMAL_LINE_WIDTH;
    EditBtnX := EDIT_BTN_X_NORMAL;
    DeleteBtnX := DELETE_BTN_X_NORMAL;
  end;

  // 应用宽度调整到本地回环项
  localIPitem.Width := ItemWidth;
  localIPtip.Width := TipWidth;
  localIPtipIP.Width := TipWidth;

  // 应用宽度调整到所有自定义IP项
  for i := 0 to FIPItems.Count - 1 do
  begin
    if FIPItems[i] = localIPitem then
      Continue;

    FIPItems[i].Width := ItemWidth;

    // 调整子控件
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
        var HasEditInName := Pos('edit', Svg.Name) > 0;
        var HasDeleteInName := Pos('delete', Svg.Name) > 0;

        if HasEditInName then
          Svg.Position.X := EditBtnX
        else if HasDeleteInName then
          Svg.Position.X := DeleteBtnX;
      end;
    end;
  end;

  // 调整分隔线宽度
  for i := 0 to FIPLines.Count - 1 do
  begin
    FIPLines[i].Width := LineWidth;
    FIPLines[i].Position.X := LINE_INDENT;
  end;

  // 调整添加按钮的位置和宽度
  addIPtipbtn.Width := ItemWidth;
  addIPtipbtn.Position.X := ITEM_SPACING;
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

  // 保存到配置文件
  var Ini := TIniFile.Create(GetAppConfigPath);
  try
    Ini.WriteString('tips', Name, IP);
  finally
    Ini.Free;
  end;

  // 刷新显示
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
    if topmosted.Enabled then
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

      topmosted.Enabled := False;
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

      topmosted.Enabled := True;
      SaveTopMostSetting(True);
    end;

    UpdatePinImageState;
  end;
end;

procedure Tmainform.ctrlbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Sender is TSksvg then
  begin
    if (Sender = pinimage) and topmosted.Enabled then
      Exit;

    (Sender as TSksvg).Opacity := 1;
  end;
end;

procedure Tmainform.appcardClosePopup(Sender: TObject);
begin
  FCanappiconEffectchange := True;

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
  FCanappiconEffectchange := False;
  appicon.Opacity := 1;
  appiconGlowEffect.Opacity := 1;
  appiconGlowEffect.Enabled := True;
end;

procedure Tmainform.appiconMouseLeave(Sender: TObject);
begin
if FCanappiconEffectchange = False then Exit;
  appicon.Opacity := 0.8;
  appiconGlowEffect.Opacity := 0.6;
  appiconGlowEffect.Enabled := False;
end;

procedure Tmainform.appiconMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
if FCanappiconEffectchange = False then Exit;
  appicon.Opacity := 0.9;
  appiconGlowEffect.Opacity := 0.8;
  appiconGlowEffect.Enabled := True;
end;

procedure Tmainform.FormCreate(Sender: TObject);
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
  localIPlabel.Text := GetIPAddressInfo;

  // 默认首页
  SetActiveSidebarButton(homebtn);

  topmosted.Enabled := LoadTopMostSetting;
  if topmosted.Enabled then
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

  // 初始化数据
  FIPAliases := TIPAliasList.Create;
  FIPItems := TList<TRectangle>.Create;
  FIPLines := TList<TLine>.Create;
  FCurrentIPItem := nil;
  FCanappiconEffectchange := True;

  LoadUserConfig;
  UpdateAllUsernameDisplays;
  LoadIPAliases;

  skiaswitch.IsChecked := LoadSkiaSetting;
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

procedure Tmainform.ctrlbtnMouseLeave(Sender: TObject);
begin
  if Sender is TSksvg then
  begin
    if (Sender = pinimage) and topmosted.Enabled then
      Exit;

    (Sender as TSksvg).Opacity := 0.6;
  end;
end;

procedure Tmainform.sidebarbtnMouseLeave(Sender: TObject);
begin
  if (Sender is TControl) and (Sender <> FActiveSidebarButton) then
  begin
    if Sender = sendbtn then UpdateSidebarButtonState('send', False)
    else if Sender = endbtn then UpdateSidebarButtonState('end', False)
    else if Sender = cmdbtn then UpdateSidebarButtonState('cmd', False)
    else if Sender = homebtn then UpdateSidebarButtonState('home', False)
    else if Sender = mobilebtn then UpdateSidebarButtonState('mobile', False)
    else if Sender = settingsbtn then UpdateSidebarButtonState('settings', False);
  end;
end;

procedure Tmainform.sidebarbtnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if Sender is TControl then
  begin
    if Sender = sendbtn then sendhighlight.Enabled := True
    else if Sender = endbtn then endhighlight.Enabled := True
    else if Sender = cmdbtn then cmdhighlight.Enabled := True
    else if Sender = homebtn then homehighlight.Enabled := True
    else if Sender = mobilebtn then mobilehighlight.Enabled := True
    else if Sender = settingsbtn then settingshighlight.Enabled := True;
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
    if ssLeft in Shift then
    begin
      if TRectangle(Sender).IsMouseOver then
        TRectangle(Sender).Fill.Color := $FFFF6F6F
      else
        TRectangle(Sender).Fill.Color := $FFFF4F4F;
    end
    else
    begin
      TRectangle(Sender).Fill.Color := $FFFF2F2F;
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
    if (Sender = homelistbtn) then
      TRectangle(Sender).Fill.Color := $FFFF2F2F
    else
      TRectangle(Sender).Fill.Color := $FFFF4F4F;
  end
  else if Sender is TCircle then
  begin
    TCircle(Sender).Opacity := 0.4;
  end;
end;

procedure Tmainform.homelistpopupClosePopup(Sender: TObject);
begin
  homelistup.Visible := False;
  homelistdown.Visible := True;
end;

procedure Tmainform.HomeButtonMouseLeave(Sender: TObject);
begin
  if Sender is TRectangle then
  begin
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
    TRectangle(Sender).Fill.Color := $FFFF6F6F;
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
  else if Sender = homelocalIPbtn then
  begin
    ShowHomeSubPage(hspLocalIP);
  end
  else if Sender = homegithubbtn then
  begin
    {$IFDEF MSWINDOWS}
    ShellExecute(0, 'open', 'https://github.com/StackNi/remote-control/', '', '', SW_SHOWNORMAL);
    {$ENDIF}

    {$IFDEF MACOS}
    _system(PAnsiChar('open ' + AnsiString('https://github.com/StackNi/remote-control/')));
    {$ENDIF}

    {$IFDEF LINUX}
    _system(PAnsiChar('xdg-open ' + AnsiString('https://github.com/StackNi/remote-control/')));
    {$ENDIF}
  end
  else if Sender = homedonatebtn then
  begin
    ShowHomeSubPage(hspDonate);
  end;
end;

procedure Tmainform.SettingsButtonClick(Sender: TObject);
begin
  if Sender = changeusernamebtn then
    ShowSettingsSubPage(sspChangeUsername)
  else if Sender = changeIPlistbtn then
    ShowSettingsSubPage(sspChangeIPList);
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

    var EffectName := '';
    if Pos('edit', Svg.Name) > 0 then
      EffectName := 'editIPtipEffect_' + Svg.Tag.ToString
    else if Pos('delete', Svg.Name) > 0 then
      EffectName := 'deleteIPtipEffect_' + Svg.Tag.ToString;

    if EffectName <> '' then
    begin
      var Effect := Svg.FindComponent(EffectName) as TFillRGBEffect;
      if Assigned(Effect) then
        Effect.Enabled := True;
    end;

    // 当鼠标移动到按钮上时，确保这个IPitem是当前IPitem
    if Assigned(Svg.Parent) and (Svg.Parent is TRectangle) then
    begin
      var ParentRect := TRectangle(Svg.Parent);
      FCurrentIPItem := ParentRect;

      // 显示这个IPitem的所有按钮
      ShowIPitemButtons(ParentRect);
    end;
  end;
end;

procedure Tmainform.ctrlIPtipbtnMouseLeave(Sender: TObject);
begin
  if Sender is TSkSvg then
  begin
    var Svg := TSkSvg(Sender);

    var EffectName := '';
    if Pos('edit', Svg.Name) > 0 then
      EffectName := 'editIPtipEffect_' + Svg.Tag.ToString
    else if Pos('delete', Svg.Name) > 0 then
      EffectName := 'deleteIPtipEffect_' + Svg.Tag.ToString;

    if EffectName <> '' then
    begin
      var Effect := Svg.FindComponent(EffectName) as TFillRGBEffect;
      if Assigned(Effect) then
        Effect.Enabled := False;
    end;
  end;
end;

procedure Tmainform.IPitemMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
begin
  if (Sender is TRectangle) then
  begin
    var Rect := TRectangle(Sender);

    if Rect = localIPitem then
      Exit;

    // 如果当前IPitem和之前的不同，先隐藏之前IPitem的按钮
    if Assigned(FCurrentIPItem) and (FCurrentIPItem <> Rect) and (FCurrentIPItem <> localIPitem) then
    begin
      HideIPitemButtons(FCurrentIPItem);
    end;

    // 设置当前IPitem
    FCurrentIPItem := Rect;

    // 显示当前IPitem的按钮
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

    // 检查鼠标是否真的离开了当前IPitem
    if Rect = FCurrentIPItem then
    begin
      HideIPitemButtons(Rect);
      FCurrentIPItem := nil;
    end;
  end;
end;

procedure Tmainform.ShowIPitemButtons(IPitem: TRectangle);
begin
  if (IPitem = nil) or (IPitem = localIPitem) then Exit;

  // 查找按钮组件
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

        // 继续询问IP地址
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
                TDialogService.MessageDialog('IP地址格式不正确！',
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

    // 验证索引有效性
    if (Index < 0) or (Index >= FIPAliases.Count) then
    begin
      // 索引无效，重新加载列表
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

        // 直接修改数据
        var Item := FIPAliases[Index];
        Item.Name := NewName;
        FIPAliases[Index] := Item;

        // 保存并重新加载
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
  ItemName: string;
begin
  if Sender is TSkSvg then
  begin
    Index := TSkSvg(Sender).Tag;

    // 验证索引
    if (Index < 0) or (Index >= FIPAliases.Count) then
    begin
      LoadIPAliases;
      Exit;
    end;

    ItemName := FIPAliases[Index].Name;

    TDialogService.MessageDialog('确定要删除该提示词吗？',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo,
      0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          // 直接从列表中删除
          FIPAliases.Delete(Index);

          // 保存并重新加载
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
    // 查找IP别名
    for var Item in FIPAliases do
      if Item.Name = TargetIP then
      begin
        TargetIP := Item.IP;
        Break;
      end;

    if not ValidateIPAddress(TargetIP) then
    begin
      TDialogService.MessageDialog('未找到对应的IP地址！',
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

// ================== 禁用所有发送UDP的按钮 ==================
procedure Tmainform.DisablesendUDPbtn;
begin
  sendmsgbtn.Enabled := False;
  endmsgbtn.Enabled := False;
  sendcmdbtn.Enabled := False;
end;

// ================== 启用所有发送UDP的按钮 ==================
procedure Tmainform.EnablesendUDPbtn;
begin
  sendmsgbtn.Enabled := True;
  endmsgbtn.Enabled := True;
  sendcmdbtn.Enabled := True;
end;

procedure Tmainform.sendmsgbtnClick(Sender: TObject);
var
  TargetIP, MessageContent, DurationStr, DisplayModeStr: string;
begin
  sendUDP.Port := 25105;

  // ================== 第一步：检查目标IP==================
  if not ValidateAndGetTargetIP(sendIPtext.Text.Trim, TargetIP) then Exit;

  // ================== 第二步：检查本机IP地址==================
  if not CheckLocalNetworkAvailable then Exit;

  // ================== 第三步：检查消息内容==================
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

  // ================== 第四步：获取显示时长==================
  DurationStr := msgdurationtext.Text.Trim;
  if (DurationStr = '') or (DurationStr = '0') then
    DurationStr := '-1';

  // ================== 第五步：确定显示模式==================
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

  // ================== 第六步：构建并发送消息==================
  try
    sendUDP.Host := TargetIP;

    var MessageToSend := Format('%s|%s|%s|%s',
      [FCurrentUsername, MessageContent, DurationStr, DisplayModeStr]);

    sendUDP.Send(MessageToSend, IndyTextEncoding_UTF8);
    DisablesendUDPbtn;

  except
    on E: Exception do
    begin
      TDialogService.MessageDialog('发送失败：' + E.Message,
        TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  end;
end;

procedure Tmainform.endmsgbtnClick(Sender: TObject);
var
  TargetIP: string;
begin
  sendUDP.Port := 25105;

  // ================== 第一步：检查目标IP==================
  if not ValidateAndGetTargetIP(endIPtext.Text.Trim, TargetIP) then Exit;

  // ================== 第二步：检查本机IP地址==================
  if not CheckLocalNetworkAvailable then Exit;

  // ================== 第三步：构建并发送关闭消息==================
  try
    sendUDP.Host := TargetIP;

    var MessageToSend := Format('%s|%s|%s|%s',
      [FCurrentUsername, 'CLOSE_ALL_WINDOWS', '0', 'CLOSE']);

    sendUDP.Send(MessageToSend, IndyTextEncoding_UTF8);
    DisablesendUDPbtn;

  except
    on E: Exception do
    begin
      TDialogService.MessageDialog('发送失败：' + E.Message,
        TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  end;
end;

procedure Tmainform.sendcmdbtnClick(Sender: TObject);
var
  TargetIP, CommandContent, PermissionStr: string;
  TargetPort: Integer;
begin
  // ================== 第一步：检查目标IP ==================
  if not ValidateAndGetTargetIP(cmdIPtext.Text.Trim, TargetIP) then Exit;

  // ================== 第二步：检查本机IP地址 ==================
  if not CheckLocalNetworkAvailable then Exit;

  // ================== 第三步：检查命令内容 ==================
  CommandContent := cmdtext.Text.Trim;

  if CommandContent = '' then
  begin
    TDialogService.MessageDialog('命令不能为空！',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    Exit;
  end;

  // ================== 第四步：确定权限级别和端口 ==================
  if user.IsChecked then
  begin
    PermissionStr := 'USER';
    TargetPort := 25105;
  end
  else
  begin
    PermissionStr := 'SYSTEM';
    TargetPort := 25107;
  end;

  sendUDP.Port := TargetPort;

  // ================== 第五步：构建并发送命令消息 ==================
  try
    sendUDP.Host := TargetIP;

    var MessageToSend := Format('%s|%s|5|CMD|%s',
      [FCurrentUsername, CommandContent, PermissionStr]);

    sendUDP.Send(MessageToSend, IndyTextEncoding_UTF8);
    DisablesendUDPbtn;

  except
    on E: Exception do
    begin
      TDialogService.MessageDialog('发送失败：' + E.Message,
        TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil);
    end;
  end;
end;

end.
