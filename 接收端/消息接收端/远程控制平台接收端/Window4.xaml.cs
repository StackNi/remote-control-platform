using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows;
using System.Windows.Input;
using System.Windows.Threading;
using System.Windows.Interop;

namespace 远程控制平台接收端
{
    public partial class Window4 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer blinkTimer;
        private bool isCloseButtonPressed = false;
        private int blinkCount = 0;
        private const int TOTAL_BLINKS = 15;
        private bool isVisibleState = true;
        private string senderIP;
        private int remotePort;

        public Window4()
        {
            InitializeComponent();
            
            this.CloseButton.MouseEnter += (s, e) => 
            {
                this.CloseButton.Opacity = 1.0;
            };

            this.CloseButton.MouseLeave += (s, e) => 
            {
                this.CloseButton.Opacity = 0.5;
            };
    
            this.CloseButton.MouseLeftButtonDown += (s, e) => 
            {
                isCloseButtonPressed = true;
                e.Handled = true;
            };
    
            this.CloseButton.MouseLeftButtonUp += (s, e) => 
            {
                if (isCloseButtonPressed)
                {
                    this.Close();
                }
                isCloseButtonPressed = false;
            };
    
            this.CloseButton.MouseLeave += (s, e) => 
            {
                isCloseButtonPressed = false;
            };
            
            SetupTimers();
            this.Opacity = 0;
            this.KeyDown += Window_KeyDown;
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;
            
            blinkTimer = new DispatcherTimer();
            blinkTimer.Interval = TimeSpan.FromMilliseconds(160);
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

        public void DisplayMessage(string username, string ip, string message, int duration, int remotePort)
        {
            try
            {
                this.senderIP = ip;
                this.remotePort = remotePort;
                
                UserInfoTextBlock.Text = "用户 " + username + " 发来的消息：";
                MessageTextBlock.Text = message;
                
                this.Visibility = Visibility.Visible;
                this.Opacity = 1.0;
                
                blinkCount = 0;
                isVisibleState = true;
                blinkTimer.Start();
                
                if (duration > 0 && duration <= 86400)
                {
                    visibilityTimer.Interval = TimeSpan.FromSeconds(duration);
                    visibilityTimer.Start();
                }
                
                this.Title = "远程控制平台接收端 - 闪烁模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
                
                SendConfirmation();
            }
            catch (Exception ex)
            {
                var app = Application.Current as App;
                if (app != null)
                {
                    app.SendResponse(ip, "显示消息窗口时出错\n错误信息: " + ex.Message, remotePort, true);
                }
                MessageBox.Show("显示消息错误: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void BlinkTimer_Tick(object sender, EventArgs e)
        {
            blinkCount++;
            
            if (blinkCount >= TOTAL_BLINKS * 2)
            {
                blinkTimer.Stop();
                this.Opacity = 1.0;
            }
            else
            {
                isVisibleState = !isVisibleState;
                this.Opacity = isVisibleState ? 1.0 : 0.3;
            }
        }

        private void SendConfirmation()
        {
            var app = Application.Current as App;
            if (app != null && !string.IsNullOrEmpty(senderIP) && remotePort > 0)
            {
                app.SendResponse(senderIP, "RECEIVED_OK", remotePort, false);
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
        
        protected override void OnSourceInitialized(EventArgs e)
        {
            base.OnSourceInitialized(e);
        
            var hwnd = new WindowInteropHelper(this).Handle;
            int style = NativeMethods.GetWindowLong(hwnd, NativeMethods.GWL_STYLE);
            style = style & ~NativeMethods.WS_SYSMENU;
            NativeMethods.SetWindowLong(hwnd, NativeMethods.GWL_STYLE, style);
        }
    }
}