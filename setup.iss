; 汉化：MonKeyDu 
#define MyAppName "远程控制平台"
#define MyAppVersion "3.2.0"
#define MyAppPublisher "StackNi"
#define MyAppExeName "sender.exe"

[Setup]
AppId={{7A7BDA9D-3B6C-478F-AE9E-52362D1201A2}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableDirPage=no
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=远程控制平台安装包
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

[Languages]
Name: "chs"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Check: IsSenderSelected

[Files]
; 发送端文件
Source: "sender.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: IsSenderSelected
Source: "sk4d.dll"; DestDir: "{app}"; Flags: ignoreversion; Check: IsSenderSelected

; 接收端文件  
Source: "receiver.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: IsReceiverSelected

; 命令执行端文件
Source: "cmdreceiver.exe"; DestDir: "{app}"; Flags: ignoreversion; Check: IsReceiverSelected

[Icons]
Name: "{autoprograms}\远程控制平台发送端"; Filename: "{app}\{#MyAppExeName}"; Check: IsSenderSelected
Name: "{autodesktop}\远程控制平台发送端"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; Check: IsSenderSelected

[Run]
; 设置防火墙规则（先删后加，防止重复）
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""远程控制平台接收端"" program=""{app}\receiver.exe"""; Flags: runhidden; Check: IsReceiverSelected
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""远程控制平台发送端"" program=""{app}\sender.exe"""; Flags: runhidden; Check: IsSenderSelected
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""远程控制平台命令执行端"" program=""{app}\cmdreceiver.exe"""; Flags: runhidden; Check: IsReceiverSelected

Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""远程控制平台接收端"" dir=in action=allow program=""{app}\receiver.exe"" enable=yes profile=private,public"; Flags: runhidden shellexec; Check: IsReceiverSelected
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""远程控制平台发送端"" dir=in action=allow program=""{app}\sender.exe"" enable=yes profile=private,public"; Flags: runhidden shellexec; Check: IsSenderSelected
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""远程控制平台命令执行端"" dir=in action=allow program=""{app}\cmdreceiver.exe"" enable=yes profile=private,public"; Flags: runhidden shellexec; Check: IsReceiverSelected

; 注册表启动 - 接收端（先删后加）
Filename: "reg"; Parameters: "delete ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"" /v ""远程控制平台接收端"" /f"; Flags: runhidden; Check: IsReceiverSelected
Filename: "reg"; Parameters: "add ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"" /v ""远程控制平台接收端"" /t REG_SZ /d ""{app}\receiver.exe"" /f"; Flags: runhidden; Check: IsReceiverSelected

; 静默启动接收端（安装完成后立即启动）
Filename: "{app}\receiver.exe"; Flags: nowait runhidden; Check: IsReceiverSelected

; 创建Windows服务 - 命令执行端（先删后创，确保覆盖）
Filename: "sc"; Parameters: "stop ""远程控制平台命令执行端"""; Flags: runhidden; Check: IsReceiverSelected
Filename: "sc"; Parameters: "delete ""远程控制平台命令执行端"""; Flags: runhidden; Check: IsReceiverSelected
Filename: "sc"; Parameters: "create ""远程控制平台命令执行端"" binPath= ""{app}\cmdreceiver.exe"" start= auto"; Flags: runhidden; Check: IsReceiverSelected
Filename: "sc"; Parameters: "start ""远程控制平台命令执行端"""; Flags: runhidden; Check: IsReceiverSelected

; 询问是否启动发送端
Filename: "{app}\{#MyAppExeName}"; Description: "运行远程控制平台发送端"; Flags: nowait postinstall skipifsilent; Check: IsSenderSelected

[UninstallRun]
; 卸载时删除防火墙规则
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""远程控制平台接收端"" program=""{app}\receiver.exe"""; Flags: runhidden; Check: IsReceiverSelected
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""远程控制平台发送端"" program=""{app}\sender.exe"""; Flags: runhidden; Check: IsSenderSelected
Filename: "netsh"; Parameters: "advfirewall firewall delete rule name=""远程控制平台命令执行端"" program=""{app}\cmdreceiver.exe"""; Flags: runhidden; Check: IsReceiverSelected

; 删除注册表启动项
Filename: "reg"; Parameters: "delete ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"" /v ""远程控制平台接收端"" /f"; Flags: runhidden; Check: IsReceiverSelected

; 停止并删除Windows服务
Filename: "sc"; Parameters: "stop ""远程控制平台命令执行端"""; Flags: runhidden; Check: IsReceiverSelected
Filename: "sc"; Parameters: "delete ""远程控制平台命令执行端"""; Flags: runhidden; Check: IsReceiverSelected

; 终止进程
Filename: "{sys}\taskkill.exe"; Parameters: "/f /im receiver.exe"; Flags: runhidden; Check: IsReceiverSelected
Filename: "{sys}\taskkill.exe"; Parameters: "/f /im sender.exe"; Flags: runhidden; Check: IsSenderSelected
Filename: "{sys}\taskkill.exe"; Parameters: "/f /im cmdreceiver.exe"; Flags: runhidden; Check: IsReceiverSelected

[Code]
var
  InstallationTypePage: TWizardPage;
  FullInstallRadio: TNewRadioButton;
  ReceiverOnlyRadio: TNewRadioButton;
  SenderOnlyRadio: TNewRadioButton;
  InstallType: Integer; // 1=完整, 2=仅接收端, 3=仅发送端
  KeepUserConfig: Boolean; // 卸载时是否保留用户配置

function IsSenderSelected: Boolean;
begin
  Result := (InstallType = 1) or (InstallType = 3);
end;

function IsReceiverSelected: Boolean;
begin
  Result := (InstallType = 1) or (InstallType = 2);
end;

// 检查是否已安装旧版本（用于判断是否升级）
function IsUpgrade: Boolean;
var
  UninstallPath: string;
  UninstallString: string;
begin
  Result := False;
  UninstallPath := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + ExpandConstant('{#SetupSetting("AppId")}') + '_is1';
  
  if RegQueryStringValue(HKLM, UninstallPath, 'UninstallString', UninstallString) then
    Result := (UninstallString <> '');
  
  if not Result then
    if RegQueryStringValue(HKCU, UninstallPath, 'UninstallString', UninstallString) then
      Result := (UninstallString <> '');
end;

// 判断路径是否在 Roaming 下
function IsPathUnderRoaming(const Path: string): Boolean;
var
  RoamingPath: string;
begin
  RoamingPath := ExpandConstant('{userappdata}');
  Result := (Pos(LowerCase(RoamingPath), LowerCase(Path)) = 1);
end;

// 删除目录下所有文件
// KeepConfig: True = 保留 config.json，False = 删除所有文件
procedure DeleteAllFiles(Dir: string; KeepConfig: Boolean);
var
  FindRec: TFindRec;
  FilePath: string;
begin
  if Dir = '' then Exit;
  if not DirExists(Dir) then Exit;
  
  if FindFirst(Dir + '\*', FindRec) then
  try
    repeat
      if (FindRec.Name <> '.') and (FindRec.Name <> '..') then
      begin
        FilePath := Dir + '\' + FindRec.Name;
        
        if KeepConfig and (FindRec.Name = 'config.json') then
          Continue;
        
        if FindRec.Attributes and FILE_ATTRIBUTE_DIRECTORY <> 0 then
          DelTree(FilePath, True, True, True)
        else
          DeleteFile(FilePath);
      end;
    until not FindNext(FindRec);
  finally
    FindClose(FindRec);
  end;
end;

// 删除用户配置（Roaming 下的整个文件夹）
procedure DeleteUserConfigFolder;
var
  ConfigPath: string;
begin
  ConfigPath := ExpandConstant('{userappdata}') + '\远程控制平台';
  if DirExists(ConfigPath) then
    DelTree(ConfigPath, True, True, True);
end;

// 安装前清理旧文件
procedure CleanOldFiles;
var
  AppDir: string;
  KeepConfig: Boolean;
begin
  AppDir := ExpandConstant('{app}');
  
  // 判断安装目录是否在 APPDATA 下
  if IsPathUnderRoaming(AppDir) then
    KeepConfig := True   // 在 APPDATA 下：保留 config.json
  else
    KeepConfig := False; // 不在 APPDATA 下：全部删除
  
  DeleteAllFiles(AppDir, KeepConfig);
end;

// 安装前清理所有旧配置（注册表、服务、防火墙）
procedure CleanOldInstallation;
var
  ResultCode: Integer;
  AppDir: string;
begin
  AppDir := ExpandConstant('{app}');
  
  // 1. 删除防火墙规则（安装前清理，防止残留）
  Exec('netsh', 'advfirewall firewall delete rule name="远程控制平台接收端" program="' + AppDir + '\receiver.exe"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('netsh', 'advfirewall firewall delete rule name="远程控制平台发送端" program="' + AppDir + '\sender.exe"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('netsh', 'advfirewall firewall delete rule name="远程控制平台命令执行端" program="' + AppDir + '\cmdreceiver.exe"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  // 2. 删除注册表启动项
  Exec('reg', 'delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "远程控制平台接收端" /f', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  // 3. 停止并删除Windows服务
  Exec('sc', 'stop "远程控制平台命令执行端"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('sc', 'delete "远程控制平台命令执行端"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  // 4. 清理旧文件（保留 config.json）
  CleanOldFiles;
end;

// ⭐ 最佳时机：在 Inno Setup 锁定文件之前终止进程
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
begin
  // 终止所有相关进程（强制终止进程树）
  Exec('taskkill.exe', '/f /im receiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill.exe', '/f /im sender.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill.exe', '/f /im cmdreceiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  
  // 等待进程完全退出
  Sleep(1000);
  
  // 返回空字符串表示继续安装
  Result := '';
end;

procedure InitializeWizard();
begin
  InstallationTypePage := CreateCustomPage(wpSelectDir, '安装选项', '选择您想要安装的功能');
  
  FullInstallRadio := TNewRadioButton.Create(WizardForm);
  with FullInstallRadio do
  begin
    Parent := InstallationTypePage.Surface;
    Caption := '完整安装（发送端 + 接收端 + 命令执行端）';
    Left := ScaleX(0);
    Top := ScaleY(0);
    Width := ScaleX(450);
    Height := ScaleY(20);
    Checked := True;
  end;
  
  ReceiverOnlyRadio := TNewRadioButton.Create(WizardForm);
  with ReceiverOnlyRadio do
  begin
    Parent := InstallationTypePage.Surface;
    Caption := '仅接收端安装（接收端 + 命令执行端）';
    Left := ScaleX(0);
    Top := ScaleY(30);
    Width := ScaleX(450);
    Height := ScaleY(20);
  end;
  
  SenderOnlyRadio := TNewRadioButton.Create(WizardForm);
  with SenderOnlyRadio do
  begin
    Parent := InstallationTypePage.Surface;
    Caption := '仅发送端安装';
    Left := ScaleX(0);
    Top := ScaleY(60);
    Width := ScaleX(450);
    Height := ScaleY(20);
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  
  if CurPageID = InstallationTypePage.ID then
  begin
    if FullInstallRadio.Checked then
      InstallType := 1
    else if ReceiverOnlyRadio.Checked then
      InstallType := 2
    else if SenderOnlyRadio.Checked then
      InstallType := 3;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssInstall then
    CleanOldInstallation;
end;

procedure CurPageChanged(CurPageID: Integer);
var
  ResultCode: Integer;
begin
  if (CurPageID = wpFinished) and (InstallType = 2) then
  begin
    Exec('cmd.exe', '/k ipconfig | findstr /i "ipv4" & echo. & echo 以上是本机所有IP地址，请您及时记录以便在发送端中使用 & pause > nul', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  end;
end;

// ================== 卸载时询问是否保留用户配置 ==================
function InitializeUninstall(): Boolean;
begin
  Result := True;
  
  KeepUserConfig := (MsgBox('是否保留用户配置文件？', mbConfirmation, MB_YESNO) = IDYES);
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usPostUninstall then
  begin
    if not KeepUserConfig then
      DeleteUserConfigFolder;
  end;
end;
