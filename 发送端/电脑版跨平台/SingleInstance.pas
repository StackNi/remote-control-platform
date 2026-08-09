unit SingleInstance;

interface

uses
  System.SysUtils;

type
  TSingleInstance = class
  private
    class var FIsFirstInstance: Boolean;

    {$IFDEF MSWINDOWS}
    class var FMutexHandle: THandle;
    class procedure InitializeWindows;
    class procedure CleanupWindows;
    {$ENDIF}

    {$IFDEF POSIX}
    class var FLockFileDescriptor: Integer;
    class var FLockFileName: string;
    class procedure InitializePosix;
    class procedure CleanupPosix;
    {$ENDIF}

  public
    class function CheckInstance(ShowMessageIfNotFirst: Boolean = True): Boolean;
    class procedure Release;
    class property IsFirstInstance: Boolean read FIsFirstInstance;
  end;

implementation

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF}
  {$IFDEF POSIX}
  Posix.Unistd, 
  Posix.Errno, 
  Posix.SysStat, 
  Posix.Fcntl,
  System.IOUtils,
  {$ENDIF}
  FMX.Dialogs;

{ TSingleInstance }

class function TSingleInstance.CheckInstance(ShowMessageIfNotFirst: Boolean = True): Boolean;
begin
  FIsFirstInstance := False;

  {$IFDEF MSWINDOWS}
  InitializeWindows;
  {$ENDIF}

  {$IFDEF POSIX}
  InitializePosix;
  {$ENDIF}

  if not FIsFirstInstance and ShowMessageIfNotFirst then
    ShowMessage('程序已经在运行中！');

  Result := FIsFirstInstance;
end;

{$IFDEF MSWINDOWS}
class procedure TSingleInstance.InitializeWindows;
var
  MutexName: string;
begin
  // Windows下用互斥体
  MutexName := 'StackNi_RemoteControl_Sender';
  
  FMutexHandle := CreateMutex(nil, True, PChar(MutexName));
  
  if (FMutexHandle = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    if FMutexHandle <> 0 then
      CloseHandle(FMutexHandle);
    FMutexHandle := 0;
    FIsFirstInstance := False;
  end
  else
    FIsFirstInstance := True;
end;

class procedure TSingleInstance.CleanupWindows;
begin
  if FMutexHandle <> 0 then
  begin
    ReleaseMutex(FMutexHandle);
    CloseHandle(FMutexHandle);
    FMutexHandle := 0;
  end;
end;
{$ENDIF}

{$IFDEF POSIX}
class procedure TSingleInstance.InitializePosix;
var
  LockFilePath: string;
  PID: string;
  PIDBytes: TBytes;
begin
  // Linux/macOS下用文件锁
  LockFilePath := TPath.GetTempPath + 'StackNi_RemoteControl_Sender.lock';
  FLockFileName := LockFilePath;

  // 尝试创建并锁定文件
  FLockFileDescriptor := open(PAnsiChar(AnsiString(LockFilePath)),
    O_RDWR or O_CREAT, S_IRUSR or S_IWUSR or S_IRGRP or S_IROTH);

  if FLockFileDescriptor = -1 then
  begin
    FIsFirstInstance := False;
    Exit;
  end;

  // 尝试获取文件锁（非阻塞）
  if flock(FLockFileDescriptor, LOCK_EX or LOCK_NB) = -1 then
  begin
    __close(FLockFileDescriptor);
    FLockFileDescriptor := -1;
    FIsFirstInstance := False;
    Exit;
  end;

  // 成功获取锁，写入当前进程ID
  PID := IntToStr(getpid());
  PIDBytes := TEncoding.UTF8.GetBytes(PID);
  ftruncate(FLockFileDescriptor, 0);
  write(FLockFileDescriptor, PIDBytes[0], Length(PIDBytes));

  FIsFirstInstance := True;
end;

class procedure TSingleInstance.CleanupPosix;
begin
  if FLockFileDescriptor <> -1 then
  begin
    flock(FLockFileDescriptor, LOCK_UN);
    __close(FLockFileDescriptor);
    FLockFileDescriptor := -1;
    
    // 删除锁文件
    // DeleteFile(FLockFileName);
  end;
end;
{$ENDIF}

class procedure TSingleInstance.Release;
begin
  {$IFDEF MSWINDOWS}
  CleanupWindows;
  {$ENDIF}

  {$IFDEF POSIX}
  CleanupPosix;
  {$ENDIF}
end;

initialization
  TSingleInstance.FIsFirstInstance := False;

  {$IFDEF MSWINDOWS}
  TSingleInstance.FMutexHandle := 0;
  {$ENDIF}

  {$IFDEF POSIX}
  TSingleInstance.FLockFileDescriptor := -1;
  {$ENDIF}

finalization
  TSingleInstance.Release;

end.