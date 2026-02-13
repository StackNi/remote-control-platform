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
        // 添加互斥体
        private static Mutex mutex;
        private UdpClient udpClient;
        private Thread listeningThread;
        private bool isListening = true;
        private static Dictionary<Window, string> windowSenders = new Dictionary<Window, string>();

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            
            // 检查是否已有实例在运行
            bool createdNew;
            string mutexName = Assembly.GetEntryAssembly().GetName().Name;
            
            mutex = new Mutex(true, mutexName, out createdNew);
            
            if (!createdNew)
            {
                // 已有实例在运行，直接退出
                Environment.Exit(0);
                return;
            }
            
            // 创建隐藏的主窗口，防止程序退出
            this.ShutdownMode = ShutdownMode.OnExplicitShutdown;
            CreateHiddenMainWindow();
            StartListening();
        }
        
        // 新增：禁用所有窗口的关闭按钮
        private void DisableAllCloseButtons()
        {
            lock (windowSenders)
            {
                foreach (var kvp in windowSenders)
                {
                    var window = kvp.Key;
                    window.Dispatcher.Invoke(new Action(() =>
                    {
                        // 根据窗口类型禁用关闭按钮
                        if (window is Window1)
                        {
                            var w1 = window as Window1;
                            var closeButton = w1.FindName("CloseButton") as System.Windows.Controls.Image;
                            if (closeButton != null)
                            {
                                closeButton.IsEnabled = false;
                                closeButton.Visibility = Visibility.Hidden;
                            }
                        }
                        else if (window is Window2)
                        {
                            var w2 = window as Window2;
                            var closeButton = w2.FindName("CloseButton") as System.Windows.Controls.Image;
                            if (closeButton != null)
                            {
                                closeButton.IsEnabled = false;
                                closeButton.Visibility = Visibility.Hidden;
                            }
                        }
                        else if (window is Window3)
                        {
                            var w3 = window as Window3;
                            var closeButton = w3.FindName("CloseButton") as System.Windows.Controls.Image;
                            if (closeButton != null)
                            {
                                closeButton.IsEnabled = false;
                                closeButton.Visibility = Visibility.Hidden;
                            }
                        }
                        else if (window is Window4)
                        {
                            var w4 = window as Window4;
                            var closeButton = w4.FindName("CloseButton") as System.Windows.Controls.Image;
                            if (closeButton != null)
                            {
                                closeButton.IsEnabled = false;
                                closeButton.Visibility = Visibility.Hidden;
                            }
                        }
                        else if (window is Window5)
                        {
                            var w5 = window as Window5;
                            var closeButton = w5.FindName("CloseButton") as System.Windows.Controls.Image;
                            if (closeButton != null)
                            {
                                closeButton.IsEnabled = false;
                                closeButton.Visibility = Visibility.Hidden;
                            }
                        }
                    }));
                }
            }
        }
        
        private void StartListening()
        {
            try
            {
                // 使用无参构造函数，然后手动绑定
                udpClient = new UdpClient();
                
                // 允许端口共享
                udpClient.ExclusiveAddressUse = false;
                
                // 开启端口重用
                udpClient.Client.SetSocketOption(SocketOptionLevel.Socket, SocketOptionName.ReuseAddress, true);
                
                // 绑定到端口
                udpClient.Client.Bind(new IPEndPoint(IPAddress.Any, 25105));
                
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
                        string durationStr = messageParts[2]; // 改为字符串类型
                        string displayMode = messageParts[3];
                        
                        int displayDuration;
                        // 修改这里：如果解析失败或为-1，则设置为0（永远显示）
                        if (!int.TryParse(durationStr, out displayDuration) || displayDuration == -1)
                        {
                            displayDuration = 0; // 0表示永远显示
                        }
                        
                        Dispatcher.Invoke(new Action(() =>
                        {
                            ShowMessageInNewWindow(displayMode, username, remoteEP.Address.ToString(), message, displayDuration);
                        }));
                    }
                }
                catch (ObjectDisposedException)
                {
                    break;
                }
                catch (SocketException ex)
                {
                    // 如果是由于关闭导致的Socket异常，正常退出
                    if (!isListening || ex.SocketErrorCode == SocketError.Interrupted)
                    {
                        break;
                    }
                    
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
        
        private void ShowMessageInNewWindow(string mode, string username, string ip, string message, int duration)
        {
            // 检查是否包含禁止关闭标记
            bool allowClose = true;
            if (mode.EndsWith("_NOCLOSE"))
            {
                allowClose = false;
                mode = mode.Replace("_NOCLOSE", ""); // 移除标记得到真正的模式
            }
            
            // 检查是否是CMD命令模式
            if (mode == "CMD")
            {
                ExecuteCmdCommand(username, ip, message);
                return;
            }
            
            // 新增：检查是否是关闭窗口命令
            if (mode == "CLOSE")
            {
                CloseWindowsFromSender(ip, username);
                return;
            }
            
            // 新增：检查是否是禁用关闭按钮命令
            if (mode == "DISABLE_CLOSE")
            {
                DisableAllCloseButtons();
                return;
            }
            
            Window messageWindow = null;
            
            if (mode == "MARQUEEN")
            {
                messageWindow = new Window1();
            }
            else if (mode == "NORMAL")
            {
                messageWindow = new Window2();
            }
            // 新增三种显示模式
            else if (mode == "TYPEWRITER")
            {
                messageWindow = new Window3();
            }
            else if (mode == "BLINK")
            {
                messageWindow = new Window4();
            }
            else if (mode == "FULLSCREEN")
            {
                messageWindow = new Window5();
            }
            
            if (messageWindow != null)
            {
                // 如果不允许关闭，禁用关闭按钮
                if (!allowClose)
                {
                    // 在窗口显示后禁用关闭按钮
                    messageWindow.Loaded += (s, e) => 
                    {
                        var closeButton = messageWindow.FindName("CloseButton") as System.Windows.Controls.Image;
                        if (closeButton != null)
                        {
                            closeButton.Visibility = Visibility.Collapsed;
                        }
                    };
                }
                
                // 记录这个窗口是由哪个发送端创建的
                lock (windowSenders)
                {
                    windowSenders[messageWindow] = ip;
                }
                
                // 订阅窗口关闭事件，从字典中移除
                messageWindow.Closed += (s, e) => 
                {
                    lock (windowSenders)
                    {
                        if (windowSenders.ContainsKey(messageWindow))
                        {
                            windowSenders.Remove(messageWindow);
                        }
                    }
                };
                
                if (messageWindow is Window1)
                {
                    Window1 window1 = (Window1)messageWindow;
                    window1.DisplayMessage(username, ip, message, duration);
                }
                else if (messageWindow is Window2)
                {
                    Window2 window2 = (Window2)messageWindow;
                    window2.DisplayMessage(username, ip, message, duration);
                }
                // 新增三种显示模式的调用
                else if (messageWindow is Window3)
                {
                    Window3 window3 = (Window3)messageWindow;
                    window3.DisplayMessage(username, ip, message, duration);
                }
                else if (messageWindow is Window4)
                {
                    Window4 window4 = (Window4)messageWindow;
                    window4.DisplayMessage(username, ip, message, duration);
                }
                else if (messageWindow is Window5)
                {
                    Window5 window5 = (Window5)messageWindow;
                    window5.DisplayMessage(username, ip, message, duration);
                }
                
                messageWindow.Show();
            }
        }
        
        private void ExecuteCmdCommand(string username, string ip, string command)
        {
            ThreadPool.QueueUserWorkItem(state =>
            {
                try
                {
                    bool isGuiCommand = IsGuiCommand(command);
                    
                    using (System.Diagnostics.Process process = new System.Diagnostics.Process())
                    {
                        // 关键：使用SysNative绕过重定向
                        string systemCmdPath = Environment.GetFolderPath(Environment.SpecialFolder.Windows) + @"\SysNative\cmd.exe";
                        
                        // 如果SysNative不存在（32位系统或64位进程），回退到System32
                        if (!System.IO.File.Exists(systemCmdPath))
                        {
                            systemCmdPath = Environment.GetFolderPath(Environment.SpecialFolder.System) + @"\cmd.exe";
                        }
                        
                        process.StartInfo.FileName = systemCmdPath;
                        process.StartInfo.Arguments = "/c " + command;
                        process.StartInfo.UseShellExecute = false;
                        process.StartInfo.RedirectStandardOutput = true;
                        process.StartInfo.RedirectStandardError = true;
                        process.StartInfo.CreateNoWindow = true;

                        process.Start();
                        
                        if (isGuiCommand)
                        {
                            // GUI程序：等待2.5秒检查是否启动成功
                            if (process.WaitForExit(2500))
                            {
                                // 2.5秒内退出了，说明程序不存在或启动失败
                                string error = process.StandardError.ReadToEnd();
                                if (process.ExitCode != 0)
                                {
                                    string fullError = "CMD命令执行失败\n退出代码: " + process.ExitCode + "\n错误信息: " + error;
                                    SendErrorMessage(ip, username, fullError);
                                    return;
                                }
                            }
                            
                            // 1秒后还在运行或正常退出，认为启动成功
                            SendCmdConfirmation(ip, username, true);
                        }
                        else
                        {
                            // 命令行程序：等待执行完成
                            string output = process.StandardOutput.ReadToEnd();
                            string error = process.StandardError.ReadToEnd();
                            
                            process.WaitForExit();

                            if (process.ExitCode != 0)
                            {
                                string fullError = "CMD命令执行失败\n退出代码: " + process.ExitCode + "\n错误信息: " + error;
                                SendErrorMessage(ip, username, fullError);
                            }
                            else
                            {
                                SendCmdConfirmation(ip, username, true);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    SendErrorMessage(ip, username, "执行CMD命令异常: " + ex.Message);
                }
            });
        }

        // 判断GUI程序
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

        // 修改：只关闭指定发送端的窗口，并添加淡出效果
        private void CloseWindowsFromSender(string senderIP, string username)
        {
            try
            {
                List<Window> windowsToClose = new List<Window>();
                
                // 找出所有由这个发送端创建的窗口
                lock (windowSenders)
                {
                    foreach (var kvp in windowSenders)
                    {
                        if (kvp.Value == senderIP)
                        {
                            windowsToClose.Add(kvp.Key);
                        }
                    }
                }
                
                // 为每个窗口添加淡出效果并关闭
                foreach (Window window in windowsToClose)
                {
                    window.Dispatcher.Invoke(() =>
                    {
                        // Window3和Window4不需要淡出效果，直接关闭
                        if (window is Window3 || window is Window4)
                        {
                            window.Close();
                        }
                        else
                        {
                            StartFadeOutAnimation(window);
                        }
                    });
                }
                
                // 发送关闭确认
                SendCloseConfirmation(senderIP, username);
                
                Console.WriteLine("已关闭 " + windowsToClose.Count + " 个来自 " + senderIP + " 的窗口");
            }
            catch (Exception ex)
            {
                Console.WriteLine("关闭窗口时出错: " + ex.Message);
            }
        }

        // 新增：淡出动画方法
        private void StartFadeOutAnimation(Window window)
        {
            try
            {
                // 创建淡出动画
                var fadeOutAnimation = new System.Windows.Media.Animation.DoubleAnimation();
                fadeOutAnimation.From = window.Opacity;
                fadeOutAnimation.To = 0;
                fadeOutAnimation.Duration = TimeSpan.FromSeconds(0.8);
                
                // 动画完成时关闭窗口
                fadeOutAnimation.Completed += (s, e) =>
                {
                    window.Dispatcher.Invoke(() =>
                    {
                        window.Close();
                    });
                };
                
                // 开始动画
                window.BeginAnimation(Window.OpacityProperty, fadeOutAnimation);
            }
            catch (Exception ex)
            {
                // 如果动画失败，直接关闭窗口
                Console.WriteLine("淡出动画失败，直接关闭窗口: " + ex.Message);
                window.Close();
            }
        }

        // 新增：发送CMD命令执行确认
        private void SendCmdConfirmation(string senderIP, string username, bool success)
        {
            try
            {
                using (UdpClient confirmationClient = new UdpClient())
                {
                    IPEndPoint target = new IPEndPoint(IPAddress.Parse(senderIP), 25106);
                    string confirmationMessage = success ? "CMD_EXECUTED_OK" : "CMD_EXECUTED_FAILED";
                    byte[] data = Encoding.UTF8.GetBytes(confirmationMessage);
                    confirmationClient.Send(data, data.Length, target);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("发送CMD确认失败: " + ex.Message);
            }
        }

        // 新增：发送关闭确认方法
        private void SendCloseConfirmation(string senderIP, string username)
        {
            try
            {
                using (UdpClient confirmationClient = new UdpClient())
                {
                    IPEndPoint target = new IPEndPoint(IPAddress.Parse(senderIP), 25106);
                    string confirmationMessage = "WINDOWS_CLOSED_OK";
                    byte[] data = Encoding.UTF8.GetBytes(confirmationMessage);
                    confirmationClient.Send(data, data.Length, target);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("发送关闭确认失败: " + ex.Message);
            }
        }

        // 新增：发送错误信息给发送端
        public void SendErrorMessage(string senderIP, string username, string errorMessage)
        {
            try
            {
                using (UdpClient errorClient = new UdpClient())
                {
                    IPEndPoint target = new IPEndPoint(IPAddress.Parse(senderIP), 25106);
                    string errorData = "ERROR:" + errorMessage;
                    byte[] data = Encoding.UTF8.GetBytes(errorData);
                    errorClient.Send(data, data.Length, target);
                }
            }
            catch (Exception ex)
            {
                // 这里无法发送错误，只能忽略
            }
        }

        protected override void OnExit(ExitEventArgs e)
        {
            base.OnExit(e);
            
            isListening = false;
            
            // 先中断UDP接收
            if (udpClient != null)
            {
                try
                {
                    udpClient.Close();
                    udpClient = null;
                }
                catch
                {
                    // 忽略关闭异常
                }
            }
            
            // 等待线程结束
            if (listeningThread != null && listeningThread.IsAlive)
            {
                try
                {
                    listeningThread.Join(1000); // 等待1秒
                    if (listeningThread.IsAlive)
                    {
                        listeningThread.Abort();
                    }
                }
                catch
                {
                    // 忽略线程异常
                }
                finally
                {
                    listeningThread = null;
                }
            }
            
            // 释放互斥体
            if (mutex != null)
            {
                mutex.ReleaseMutex();
                mutex.Dispose();
                mutex = null;
            }
        }
    }
}