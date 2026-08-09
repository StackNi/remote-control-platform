using System;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Threading;
using System.Windows.Interop;
using System.Windows.Media;

namespace 远程控制平台接收端
{
    public partial class Window3 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer progressTimer;
        private DispatcherTimer typewriterTimer;
        private DispatcherTimer blinkTimer;
        private bool isCloseButtonPressed = false;
        private string fullMessage = "";
        private int currentCharIndex = 0;
        private int blinkCount = 0;
        private const int FINAL_BLINKS = 3;
        private string senderIP;
        private int remotePort;
        private string currentRequestID;
        private double totalDuration;
        private DateTime startTime;

        public Window3()
        {
            InitializeComponent();

            this.Visibility = Visibility.Collapsed;

            this.SizeChanged += Window3_SizeChanged;
            
            this.CloseButton.MouseEnter += (s, e) => 
            {
                this.CloseButton.Opacity = 1.0;
            };

            this.CloseButton.MouseLeave += (s, e) => 
            {
                this.CloseButton.Opacity = 0.5;
                isCloseButtonPressed = false;
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
            
            SetupTimers();
            this.Opacity = 0;
            this.KeyDown += Window_KeyDown;
            this.SizeChanged += Window_SizeChanged;
        }

        private void Window3_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            if (e.HeightChanged)
            {
                CenterWindowVertically();
            }
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;

            progressTimer = new DispatcherTimer();
            progressTimer.Interval = TimeSpan.FromMilliseconds(50);
            progressTimer.Tick += ProgressTimer_Tick;
            
            typewriterTimer = new DispatcherTimer();
            typewriterTimer.Interval = TimeSpan.FromMilliseconds(40);
            typewriterTimer.Tick += TypewriterTimer_Tick;
            
            blinkTimer = new DispatcherTimer();
            blinkTimer.Interval = TimeSpan.FromMilliseconds(150);
            blinkTimer.Tick += BlinkTimer_Tick;
        }

        private void CenterWindowVertically()
        {
            this.Top = (SystemParameters.WorkArea.Height - this.ActualHeight) / 2;
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
                
                fullMessage = message;
                currentCharIndex = 0;
                blinkCount = 0;
                MessageTextBlock.Inlines.Clear();

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

                this.Dispatcher.BeginInvoke(new Action(() =>
                {
                    CenterWindowVertically();
                }), DispatcherPriority.Loaded);
                this.Opacity = 1.0;
                
                typewriterTimer.Start();
                
                this.Title = "远程控制平台接收端 - 打字机模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
                
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

        private void TypewriterTimer_Tick(object sender, EventArgs e)
        {
            if (currentCharIndex < fullMessage.Length)
            {
                MessageTextBlock.Inlines.Clear();
                MessageTextBlock.Inlines.Add(new Run(fullMessage.Substring(0, currentCharIndex + 1)));
                MessageTextBlock.Inlines.Add(new Run("▂")
                {
                    Foreground = System.Windows.Media.Brushes.White
                });
                
                currentCharIndex++;
                ScrollToBottom();
            }
            else
            {
                typewriterTimer.Stop();
                StartFinalBlink();
            }
        }

        private void StartFinalBlink()
        {
            blinkCount = 0;
            blinkTimer.Start();
        }

        private void BlinkTimer_Tick(object sender, EventArgs e)
        {
            blinkCount++;
            
            if (blinkCount >= FINAL_BLINKS * 3)
            {
                blinkTimer.Stop();
                MessageTextBlock.Inlines.Clear();
                MessageTextBlock.Inlines.Add(new Run(fullMessage));
                ScrollToBottom();
            }
            else
            {
                MessageTextBlock.Inlines.Clear();
                MessageTextBlock.Inlines.Add(new Run(fullMessage));
                
                if (blinkCount % 2 == 1)
                {
                    MessageTextBlock.Inlines.Add(new Run("▂")
                    {
                        Foreground = System.Windows.Media.Brushes.White
                    });
                }
                
                ScrollToBottom();
            }
        }

        private void ScrollToBottom()
        {
            if (MessageScrollViewer != null)
            {
                Dispatcher.BeginInvoke(new Action(() =>
                {
                    MessageScrollViewer.ScrollToEnd();
                }), DispatcherPriority.Background);
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
            typewriterTimer.Stop();
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