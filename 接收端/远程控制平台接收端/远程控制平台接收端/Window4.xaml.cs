using System;
using System.Windows;
using System.Windows.Input;
using System.Windows.Threading;
using System.Windows.Interop;
using System.Windows.Media;

namespace 远程控制平台接收端
{
    public partial class Window4 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer progressTimer;
        private DispatcherTimer blinkTimer;
        private bool isCloseButtonPressed = false;
        private int blinkCount = 0;
        private const int TOTAL_BLINKS = 15;
        private bool isVisibleState = true;
        private string senderIP;
        private int remotePort;
        private string currentRequestID;
        private double totalDuration;
        private DateTime startTime;

        public Window4()
        {
            InitializeComponent();

            this.Visibility = Visibility.Collapsed;

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
            this.SizeChanged += Window_SizeChanged;
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;

            progressTimer = new DispatcherTimer();
            progressTimer.Interval = TimeSpan.FromMilliseconds(50);
            progressTimer.Tick += ProgressTimer_Tick;
            
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

        public void DisplayMessage(string username, string ip, string message, int duration, int remotePort, string requestID)
        {
            try
            {
                this.senderIP = ip;
                this.remotePort = remotePort;
                this.currentRequestID = requestID;
                
                UserInfoTextBlock.Text = "用户 " + username + " 发来的消息：";
                MessageTextBlock.Text = message;

                // 处理进度条
                if (duration > 0 && duration <= 86400)
                {
                    TimeProgressBar.Visibility = Visibility.Visible;

                    this.Dispatcher.BeginInvoke(new Action(() =>
                    {
                        double w = MainGrid.ActualWidth;
                        double h = MainGrid.ActualHeight;
                        if (w > 0 && h > 0)
                        {
                            ClipGeometry.Rect = new Rect(0, 0, w, h);
                            TimeProgressBar.Width = w;
                        }
                    }), DispatcherPriority.Loaded);

                    totalDuration = duration;
                    startTime = DateTime.Now;
                    progressTimer.Start();
                    visibilityTimer.Interval = TimeSpan.FromSeconds(duration);
                    visibilityTimer.Start();
                }
                else
                {
                    TimeProgressBar.Visibility = Visibility.Collapsed;
                    TimeProgressBar.Width = 0;
                }
                
                this.Visibility = Visibility.Visible;
                this.Opacity = 1.0;
                
                blinkCount = 0;
                isVisibleState = true;
                blinkTimer.Start();
                
                this.Title = "远程控制平台接收端 - 闪烁模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
                
                SendConfirmation();
            }
            catch (Exception ex)
            {
                var app = Application.Current as App;
                if (app != null)
                {
                    app.SendResponse(ip, requestID, "显示消息窗口时出错\n错误信息: " + ex.Message, remotePort, true);
                }
                MessageBox.Show("显示消息错误: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void ProgressTimer_Tick(object sender, EventArgs e)
        {
            double elapsedSeconds = (DateTime.Now - startTime).TotalSeconds;
            double remainingPercent = 1 - (elapsedSeconds / totalDuration);

            if (remainingPercent <= 0)
            {
                progressTimer.Stop();
                TimeProgressBar.Width = 0;
                return;
            }

            double gridWidth = MainGrid.ActualWidth;
            if (gridWidth > 0)
            {
                TimeProgressBar.Width = gridWidth * remainingPercent;
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
                app.SendResponse(senderIP, currentRequestID, "", remotePort, false);
            }
        }

        private void VisibilityTimer_Tick(object sender, EventArgs e)
        {
            visibilityTimer.Stop();
            progressTimer.Stop();
            this.Close();
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            double w = MainGrid.ActualWidth;
            double h = MainGrid.ActualHeight;
            if (w > 0 && h > 0)
            {
                ClipGeometry.Rect = new Rect(0, 0, w, h);
            }
        }

        private void Window_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            double w = MainGrid.ActualWidth;
            double h = MainGrid.ActualHeight;
            if (w > 0 && h > 0)
            {
                ClipGeometry.Rect = new Rect(0, 0, w, h);
            }

            if (TimeProgressBar.Visibility == Visibility.Visible && TimeProgressBar.Width > 0 && MainGrid.ActualWidth > 0)
            {
                double currentPercent = TimeProgressBar.Width / MainGrid.ActualWidth;
                if (currentPercent > 0 && currentPercent <= 1)
                {
                    TimeProgressBar.Width = MainGrid.ActualWidth * currentPercent;
                }
            }
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            visibilityTimer.Stop();
            progressTimer.Stop();
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