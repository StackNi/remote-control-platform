using System;
using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.ServiceProcess;
using System.ComponentModel;

namespace 远程控制平台命令执行端
{
    public class 远程控制平台命令执行端 : ServiceBase
    {
        private UdpClient udpClient;
        private bool isListening = true;
        private const int CMD_PORT = 25106;
        private Thread listeningThread;
        private IContainer components;

        public 远程控制平台命令执行端()
        {
            InitializeComponent();
            this.ServiceName = "RemoteControlCmdExecutor";
            this.CanStop = true;
            this.CanPauseAndContinue = false;
            this.AutoLog = true;
        }

        private void InitializeComponent()
        {
            this.components = new Container();
            this.ServiceName = "RemoteControlCmdExecutor";
        }

        protected override void OnStart(string[] args)
        {
            EventLog.WriteEntry("远程控制平台命令执行端服务启动", EventLogEntryType.Information);
            StartListening();
        }

        protected override void OnStop()
        {
            EventLog.WriteEntry("远程控制平台命令执行端服务停止", EventLogEntryType.Information);
            
            isListening = false;
            if (udpClient != null)
            {
                udpClient.Close();
            }
            if (listeningThread != null && listeningThread.IsAlive)
            {
                listeningThread.Join(3000);
            }
        }

        protected override void OnShutdown()
        {
            EventLog.WriteEntry("系统关机，服务停止", EventLogEntryType.Information);
            OnStop();
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void StartListening()
        {
            try
            {
                udpClient = new UdpClient(CMD_PORT);
                
                listeningThread = new Thread(new ThreadStart(ListenForCommands));
                listeningThread.IsBackground = true;
                listeningThread.Start();

                EventLog.WriteEntry("开始监听端口 " + CMD_PORT, EventLogEntryType.Information);
            }
            catch (Exception ex)
            {
                EventLog.WriteEntry("启动监听失败: " + ex.Message, EventLogEntryType.Error);
            }
        }

        private void ListenForCommands()
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
                        string command = messageParts[1];
                        string durationStr = messageParts[2];
                        string mode = messageParts[3];

                        if (mode == "CMD")
                        {
                            EventLog.WriteEntry("收到CMD命令: " + command, EventLogEntryType.Information);
                            ExecuteCmdCommand(remoteEP.Address.ToString(), command, remoteEP.Port);
                        }
                    }
                }
                catch (ObjectDisposedException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    if (isListening)
                    {
                        EventLog.WriteEntry("接收命令错误: " + ex.Message, EventLogEntryType.Warning);
                    }
                }
            }
        }

        private void ExecuteCmdCommand(string senderIP, string command, int remotePort)
        {
            ThreadPool.QueueUserWorkItem(state =>
            {
                try
                {
                    bool isGuiCommand = IsGuiCommand(command);

                    using (Process process = new Process())
                    {
                        string systemCmdPath = Environment.GetFolderPath(Environment.SpecialFolder.Windows) + @"\SysNative\cmd.exe";

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
                            if (process.WaitForExit(2500))
                            {
                                string error = process.StandardError.ReadToEnd();
                                
                                if (process.ExitCode != 0 && !string.IsNullOrWhiteSpace(error))
                                {
                                    string fullError = "CMD命令执行失败\n退出代码: " + process.ExitCode + "\n错误信息: " + error;
                                    SendResponse(senderIP, fullError, remotePort, true);
                                    EventLog.WriteEntry("CMD命令执行失败: " + command + ", 错误: " + error, EventLogEntryType.Error);
                                    return;
                                }
                            }
                            
                            SendResponse(senderIP, "CMD_EXECUTED_OK", remotePort, false);
                            EventLog.WriteEntry("CMD命令执行成功: " + command, EventLogEntryType.Information);
                        }
                        else
                        {
                            string output = process.StandardOutput.ReadToEnd();
                            string error = process.StandardError.ReadToEnd();
                            
                            process.WaitForExit();

                            if (process.ExitCode != 0 && !string.IsNullOrWhiteSpace(error))
                            {
                                string fullError = "CMD命令执行失败\n退出代码: " + process.ExitCode + "\n错误信息: " + error;
                                SendResponse(senderIP, fullError, remotePort, true);
                                EventLog.WriteEntry("CMD命令执行失败: " + command + ", 退出代码: " + process.ExitCode, EventLogEntryType.Error);
                            }
                            else
                            {
                                SendResponse(senderIP, "CMD_EXECUTED_OK", remotePort, false);
                                EventLog.WriteEntry("CMD命令执行成功: " + command, EventLogEntryType.Information);
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    SendResponse(senderIP, "执行CMD命令时出错\n错误信息: " + ex.Message, remotePort, true);
                    EventLog.WriteEntry("执行CMD命令时出错: " + command + ", 错误信息: " + ex.Message, EventLogEntryType.Error);
                }
            });
        }

        // 用同一个 udpClient 发送
        private void SendResponse(string senderIP, string message, int remotePort, bool isError)
        {
            try
            {
                IPEndPoint target = new IPEndPoint(IPAddress.Parse(senderIP), remotePort);
                
                // 如果是错误消息，加上 "ERROR:" 前缀
                string responseData = isError ? "ERROR:" + message : message;
                
                byte[] data = Encoding.UTF8.GetBytes(responseData);
                udpClient.Send(data, data.Length, target);
            }
            catch (Exception ex)
            {
                EventLog.WriteEntry("发送响应失败: " + ex.Message, EventLogEntryType.Warning);
            }
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
}