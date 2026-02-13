; 汉化：MonKeyDu 
#define MyAppName "远程控制平台"
#define MyAppVersion "3.1.27.5"
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
; 设置防火墙规则
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""远程控制平台接收端"" dir=in action=allow program=""{app}\receiver.exe"" enable=yes profile=private,public"; Flags: runhidden shellexec; Check: IsReceiverSelected
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""远程控制平台发送端"" dir=in action=allow program=""{app}\sender.exe"" enable=yes profile=private,public"; Flags: runhidden shellexec; Check: IsSenderSelected
Filename: "netsh"; Parameters: "advfirewall firewall add rule name=""远程控制平台命令执行端"" dir=in action=allow program=""{app}\cmdreceiver.exe"" enable=yes profile=private,public"; Flags: runhidden shellexec; Check: IsReceiverSelected

; 注册表启动 - 接收端
Filename: "reg"; Parameters: "add ""HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"" /v ""远程控制平台接收端"" /t REG_SZ /d ""{app}\receiver.exe"" /f"; Flags: runhidden; Check: IsReceiverSelected

; 静默启动接收端（安装完成后立即启动）
Filename: "{app}\receiver.exe"; Flags: nowait runhidden; Check: IsReceiverSelected

; 创建Windows服务 - 命令执行端（使用你手动成功的命令）
Filename: "sc"; Parameters: "create ""远程控制平台命令执行端"" binPath= ""{app}\cmdreceiver.exe"" start= auto"; Flags: runhidden; Check: IsReceiverSelected
Filename: "sc"; Parameters: "start ""远程控制平台命令执行端"""; Flags: runhidden; Check: IsReceiverSelected

; 询问是否启动发送端
Filename: "{app}\{#MyAppExeName}"; Description: "运行远程控制平台发送端"; Flags: nowait postinstall skipifsilent; Check: IsSenderSelected

[UninstallRun]
; 卸载时删除防火墙规则、关闭进程和服务
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

function IsSenderSelected: Boolean;
begin
  Result := (InstallType = 1) or (InstallType = 3);
end;

function IsReceiverSelected: Boolean;
begin
  Result := (InstallType = 1) or (InstallType = 2);
end;

// 检查是否已安装旧版本
function GetUninstallString: string;
var
  UninstallPath: string;
begin
  Result := '';
  UninstallPath := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\' + ExpandConstant('{#SetupSetting("AppId")}') + '_is1';
  
  if RegQueryStringValue(HKLM, UninstallPath, 'UninstallString', Result) then
    Exit;
  
  if RegQueryStringValue(HKCU, UninstallPath, 'UninstallString', Result) then
    Exit;
end;

function IsUpgrade: Boolean;
begin
  Result := (GetUninstallString() <> '');
end;

function UnInstallOldVersion: Integer;
var
  UninstallCommand: string;
  ResultCode: Integer;
begin
  Result := 0;
  UninstallCommand := GetUninstallString();
  if UninstallCommand <> '' then
  begin
    UninstallCommand := RemoveQuotes(UninstallCommand);
    if Pos(' /', UninstallCommand) > 0 then
      UninstallCommand := Copy(UninstallCommand, 1, Pos(' /', UninstallCommand) - 1);
    
    if Exec(UninstallCommand, '/SILENT', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
      Result := ResultCode
    else
      Result := -1;
  end;
end;

procedure InitializeWizard();
var
  ResultCode: Integer;
  OldVersionFound: Boolean;
  UninstallResult: Integer;
begin
  OldVersionFound := IsUpgrade();
  
  if OldVersionFound then
  begin
    if MsgBox('检测到此应用的旧版本，继续安装前请先卸载旧版本。' + #13#10 +
              '是否立即卸载旧版本？' + #13#10 + #13#10 +
              '选择"是"将自动为您卸载旧版本。' + #13#10 +
              '选择"否"将退出安装程序。',
              mbConfirmation, MB_YESNO) = IDYES then
    begin
      Exec('taskkill.exe', '/f /im receiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Exec('taskkill.exe', '/f /im sender.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      Exec('taskkill.exe', '/f /im cmdreceiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
      
      UninstallResult := UnInstallOldVersion();
      if UninstallResult = -1 then
      begin
        if MsgBox('旧版本卸载失败。' + #13#10 + #13#10 +
                  '是否继续安装新版本？' + #13#10 +
                  '选择"否"将退出安装程序。',
                  mbError, MB_YESNO) = IDNO then
          Abort;
      end;
    end
    else
      Abort;
  end
  else
  begin
    Exec('taskkill.exe', '/f /im receiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill.exe', '/f /im sender.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill.exe', '/f /im cmdreceiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
  
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
var
  ResultCode: Integer;
begin
  if CurStep = ssInstall then
  begin
    Exec('taskkill.exe', '/f /im receiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill.exe', '/f /im sender.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
    Exec('taskkill.exe', '/f /im cmdreceiver.exe /t', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  end;
end;
procedure CurPageChanged(CurPageID: Integer);
var
  ResultCode: Integer;
begin
  // 安装完成后，如果是仅接收端安装，显示IP地址
  if (CurPageID = wpFinished) and (InstallType = 2) then
  begin
    Exec('cmd.exe', '/k ipconfig | findstr /i "ipv4" & echo. & echo 以上是本机所有IP地址，请您及时记录以便在发送端中使用 & pause > nul', '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
  end;
end;