using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows;
using System.Windows.Input;
using System.Windows.Threading;

namespace 远程控制平台接收端
{
    public partial class Window4 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer blinkTimer;
        private bool isCloseButtonPressed = false;
        private int blinkCount = 0;
        private const int TOTAL_BLINKS = 15; // 总闪烁次数
        private bool isVisibleState = true;

        public Window4()
        {
            InitializeComponent();
            
            // 关闭按钮事件处理
            this.CloseButton.MouseEnter += (s, e) => 
            {
                this.CloseButton.Opacity = 1.0;
            };

            this.CloseButton.MouseLeave += (s, e) => 
            {
                this.CloseButton.Opacity = 0.5;
            };
    
            // 鼠标按下：停止拖动，记录按下状态
            this.CloseButton.MouseLeftButtonDown += (s, e) => 
            {
                isCloseButtonPressed = true;
                e.Handled = true;
            };
    
            // 鼠标松开：如果在按钮上松开且之前是按下的，则关闭
            this.CloseButton.MouseLeftButtonUp += (s, e) => 
            {
                if (isCloseButtonPressed)
                {
                    this.Close();
                }
                isCloseButtonPressed = false;
            };
    
            // 鼠标离开按钮时重置状态
            this.CloseButton.MouseLeave += (s, e) => 
            {
                isCloseButtonPressed = false;
            };
            
            SetupTimers();
            this.Opacity = 0;
            
            // 添加键盘事件处理
            this.KeyDown += Window_KeyDown;
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;
            
            blinkTimer = new DispatcherTimer();
            blinkTimer.Interval = TimeSpan.FromMilliseconds(160); // 闪烁频率160毫秒
            blinkTimer.Tick += BlinkTimer_Tick;
        }

        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.System && e.SystemKey == Key.F4)
            {
                e.Handled = true;
                this.Close();
            }
        }

        public void DisplayMessage(string username, string ip, string message, int duration)
        {
            try
            {
                UserInfoTextBlock.Text = "用户 " + username + " 发来的消息" + "（IP：" + ip + "）：";
                MessageTextBlock.Text = message;
                
                this.Visibility = Visibility.Visible;
                
                // 直接显示
                this.Opacity = 1.0;
                
                // 启动闪烁效果
                blinkCount = 0;
                isVisibleState = true;
                blinkTimer.Start();
                
                // 设置自动关闭定时器
                if (duration > 0 && duration <= 86400)
                {
                    visibilityTimer.Interval = TimeSpan.FromSeconds(duration);
                    visibilityTimer.Start();
                }
                
                this.Title = "远程控制平台接收端 - 闪烁模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
                
                SendConfirmation(ip, username);
            }
            catch (Exception ex)
            {
                var app = Application.Current as App;
                if (app != null)
                {
                    app.SendErrorMessage(ip, username, "消息显示失败: " + ex.Message);
                }
            }
        }

        private void BlinkTimer_Tick(object sender, EventArgs e)
        {
            blinkCount++;
            
            if (blinkCount >= TOTAL_BLINKS * 2)
            {
                // 闪烁完成，恢复正常显示
                blinkTimer.Stop();
                this.Opacity = 1.0;
            }
            else
            {
                // 切换显示状态
                isVisibleState = !isVisibleState;
                this.Opacity = isVisibleState ? 1.0 : 0.3; // 闪烁在完全不透明和30%透明之间切换
            }
        }

        private void SendConfirmation(string senderIP, string username)
        {
            try
            {
                using (UdpClient confirmationClient = new UdpClient())
                {
                    IPEndPoint target = new IPEndPoint(IPAddress.Parse(senderIP), 25106);
                    string confirmationMessage = "RECEIVED_OK";
                    byte[] data = Encoding.UTF8.GetBytes(confirmationMessage);
                    confirmationClient.Send(data, data.Length, target);
                }
            }
            catch
            {
                // 忽略发送失败
            }
        }

        private void VisibilityTimer_Tick(object sender, EventArgs e)
        {
            visibilityTimer.Stop();
            this.Close();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            this.Visibility = Visibility.Collapsed;
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            visibilityTimer.Stop();
            blinkTimer.Stop();
        }

        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            this.DragMove();
        }
    }
}