using System;
using System.Windows;
using System.Windows.Input;
using System.Windows.Interop;
using System.Windows.Media.Animation;
using System.Windows.Threading;
using System.Windows.Media;

namespace 远程控制平台接收端
{
    public partial class Window2 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer progressTimer;
        private bool isCloseButtonPressed = false;
        private string senderIP;
        private int remotePort;
        private string currentRequestID;
        private double totalDuration;
        private DateTime startTime;

        public Window2()
        {
            InitializeComponent();

            this.Visibility = Visibility.Collapsed;

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
            this.SizeChanged += Window_SizeChanged;
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;

            progressTimer = new DispatcherTimer();
            progressTimer.Interval = TimeSpan.FromMilliseconds(50);
            progressTimer.Tick += ProgressTimer_Tick;
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
                visibilityTimer.Stop();
                progressTimer.Stop();

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

        public void DisplayMessage(string username, string ip, string message, int duration, int remotePort, string requestID)
        {
            try
            {
                this.senderIP = ip;
                this.remotePort = remotePort;
                this.currentRequestID = requestID;

                UserInfoTextBlock.Text = "用户 " + username + " 发来的消息：";
                MessageTextBlock.Text = message;

                if (duration > 0 && duration <= 86400)
                {
                    TimeProgressBar.Visibility = Visibility.Visible;

                    // 等待布局完成，获取实际宽度，并更新 Clip 几何
                    this.Dispatcher.BeginInvoke(new Action(() =>
                    {
                        double w = MainGrid.ActualWidth;
                        double h = MainGrid.ActualHeight;
                        if (w > 0 && h > 0)
                        {
                            // 更新裁剪几何的尺寸
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
                StartOpacityAnimation();

                this.Title = "远程控制平台接收端 - 公告模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");

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
                app.SendResponse(senderIP, currentRequestID, "", remotePort, false);
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

            // 用 MainGrid 的实际宽度来计算进度条宽度
            double gridWidth = MainGrid.ActualWidth;
            if (gridWidth > 0)
            {
                TimeProgressBar.Width = gridWidth * remainingPercent;
            }
        }

        private void VisibilityTimer_Tick(object sender, EventArgs e)
        {
            visibilityTimer.Stop();
            progressTimer.Stop();
            StartFadeOutAndClose();
        }

        private void Window_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            // 更新裁剪几何的尺寸
            double w = MainGrid.ActualWidth;
            double h = MainGrid.ActualHeight;
            if (w > 0 && h > 0)
            {
                ClipGeometry.Rect = new Rect(0, 0, w, h);
            }

            // 按比例调整进度条宽度
            if (TimeProgressBar.Visibility == Visibility.Visible && TimeProgressBar.Width > 0 && MainGrid.ActualWidth > 0)
            {
                double currentPercent = TimeProgressBar.Width / MainGrid.ActualWidth;
                if (currentPercent > 0 && currentPercent <= 1)
                {
                    TimeProgressBar.Width = MainGrid.ActualWidth * currentPercent;
                }
            }
        }

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            // 窗口加载完成后，设置裁剪几何的尺寸
            double w = MainGrid.ActualWidth;
            double h = MainGrid.ActualHeight;
            if (w > 0 && h > 0)
            {
                ClipGeometry.Rect = new Rect(0, 0, w, h);
            }
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            visibilityTimer.Stop();
            progressTimer.Stop();
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