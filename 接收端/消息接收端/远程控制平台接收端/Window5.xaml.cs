using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Media.Animation;
using System.Windows.Threading;

namespace 远程控制平台接收端
{
    public partial class Window5 : Window
    {
        private DispatcherTimer visibilityTimer;
        private bool isCloseButtonPressed = false;
        private string senderIP;
        private int remotePort;

        public Window5()
        {
            InitializeComponent();
            this.Left = 0;
            this.Top = 0;
            this.CloseButton.MouseEnter += (s, e) => 
            {
                var animation = new DoubleAnimation(1.0, TimeSpan.FromSeconds(0.2));
                this.CloseButton.BeginAnimation(OpacityProperty, animation);
            };

            this.CloseButton.MouseLeave += (s, e) => 
            {
                var animation = new DoubleAnimation(0.5, TimeSpan.FromSeconds(0.2));
                this.CloseButton.BeginAnimation(OpacityProperty, animation);
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
                    this.StartFadeOutAndClose();
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
        }

        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.System && e.SystemKey == Key.F4)
            {
                e.Handled = true;
                StartFadeOutAndClose();
            }
        }

        private void StartFadeOutAndClose()
        {
            try
            {
                DoubleAnimation fadeOutAnimation = new DoubleAnimation();
                fadeOutAnimation.From = this.Opacity;
                fadeOutAnimation.To = 0;
                fadeOutAnimation.Duration = TimeSpan.FromSeconds(0.8);
                
                fadeOutAnimation.Completed += (s, e) =>
                {
                    this.Close();
                };
                
                this.BeginAnimation(Window.OpacityProperty, fadeOutAnimation);
            }
            catch (Exception)
            {
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
                
                StartOpacityAnimation();
                
                if (duration > 0 && duration <= 86400)
                {
                    visibilityTimer.Interval = TimeSpan.FromSeconds(duration);
                    visibilityTimer.Start();
                }
                
                this.Title = "远程控制平台接收端 - 全屏模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
                
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

        private void StartOpacityAnimation()
        {
            DoubleAnimation opacityAnimation = new DoubleAnimation();
            opacityAnimation.From = 0;
            opacityAnimation.To = 1;
            opacityAnimation.Duration = TimeSpan.FromSeconds(0.8);
            
            this.BeginAnimation(Window.OpacityProperty, opacityAnimation);
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
            StartFadeOutAndClose();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            this.Visibility = Visibility.Collapsed;
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            visibilityTimer.Stop();
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