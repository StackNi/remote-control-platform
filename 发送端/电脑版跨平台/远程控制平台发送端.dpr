program 远程控制平台发送端;

uses
  System.SysUtils,
  System.IOUtils,
  System.JSON,
  FMX.Forms,
  远程控制平台发送端带界面 in '远程控制平台发送端带界面.pas' {mainform},
  FMX.Skia,
  // 单实例依赖
  SingleInstance in 'SingleInstance.pas';

{$R *.res}

function GetAppConfigPath: string;
var
  AppDataPath: string;
begin
  {$IFDEF MSWINDOWS}
  // Windows: 使用 AppData\Roaming
  AppDataPath := GetEnvironmentVariable('APPDATA');
  if AppDataPath = '' then
    AppDataPath := TPath.GetHomePath;
    
  // 创建 "远程控制平台" 文件夹
  Result := TPath.Combine(AppDataPath, '远程控制平台');
  {$ENDIF}
  
  {$IFDEF MACOS}
  // macOS: 使用应用支持目录
  Result := TPath.Combine(TPath.GetHomePath, 'Library/Application Support/远程控制平台');
  {$ENDIF}
  
  {$IFDEF LINUX}
  // Linux: 使用 .config 目录
  Result := TPath.Combine(TPath.GetHomePath, '.config/远程控制平台');
  {$ENDIF}
  
  // 确保目录存在
  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);
    
  Result := TPath.Combine(Result, 'config.json');
end;

function LoadSkiaSetting: Boolean;
var
  ConfigPath: string;
  JSON: TJSONObject;
  Value: string;
begin
  Result := True; // 默认启用Skia
  ConfigPath := GetAppConfigPath;
  
  if not TFile.Exists(ConfigPath) then
    Exit;

  try
    JSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(ConfigPath)) as TJSONObject;
    if JSON = nil then
      Exit;
    try
      if JSON.TryGetValue<string>('Graphics.SkiaEnabled', Value) then
        Result := StrToBoolDef(Value, True);
    finally
      JSON.Free;
    end;
  except
    // JSON 损坏时用默认值
    Result := True;
  end;
end;

begin
  // 设置应用标题
  Application.Title := '远程控制平台发送端';
  // 在程序启动时检查并设置Skia
  GlobalUseSkia := LoadSkiaSetting;
  GlobalUseSkiaFilters := True;
  GlobalSkiaTextLocale := 'zh-CN';
  
  // 检查单实例
  if not TSingleInstance.CheckInstance(True) then
    Exit;

  Application.Initialize;
  Application.CreateForm(Tmainform, mainform);
  Application.Run;
end.