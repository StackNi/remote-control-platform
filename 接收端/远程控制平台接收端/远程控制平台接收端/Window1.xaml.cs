using System;
using System.Collections.Generic;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media.Animation;
using System.Windows.Threading;
using System.Windows.Interop;
using System.Windows.Media;

namespace 远程控制平台接收端
{
    public partial class Window1 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer progressTimer;
        private DispatcherTimer scrollTimer;
        private double screenWidth;
        private bool isCloseButtonPressed = false;
        private List<Label> messageLabels = new List<Label>();
        private string currentMessage = "";
        private double scrollSpeed = 6;
        private string senderIP;
        private int remotePort;
        private string currentRequestID;
        private double totalDuration;
        private DateTime startTime;

        public Window1()
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
            
            InitializeWindowPosition();
            SetupTimers();
            this.Opacity = 0;
            this.KeyDown += Window_KeyDown;
            this.SizeChanged += Window_SizeChanged;
        }

        private void InitializeWindowPosition()
        {
            screenWidth = SystemParameters.PrimaryScreenWidth;
            this.Width = screenWidth - 12;
            
            double topPosition = SystemParameters.PrimaryScreenHeight * 0.24;
            this.Top = topPosition;
            this.Left = 6;
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;

            progressTimer = new DispatcherTimer();
            progressTimer.Interval = TimeSpan.FromMilliseconds(50);
            progressTimer.Tick += ProgressTimer_Tick;

            scrollTimer = new DispatcherTimer();
            scrollTimer.Interval = TimeSpan.FromMilliseconds(16);
            scrollTimer.Tick += ScrollTimer_Tick;
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
            
                UserInfoLabel.Content = "用户 " + username + " 发来的消息：";
                currentMessage = message + "                      ";
            
                CreateMessageLabels();
                StartScrolling();
            
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
                StartOpacityAnimation();
            
                this.Title = "远程控制平台 - 跑马灯模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
                
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

            double gridWidth = MainGrid.ActualWidth;
            if (gridWidth > 0)
            {
                TimeProgressBar.Width = gridWidth * remainingPercent;
            }
        }

        private void StartScrolling()
        {
            try
            {
                this.UpdateLayout();
                MessageCanvas.UpdateLayout();
        
                Dispatcher.BeginInvoke(new Action(() =>
                {
                    CreateMessageLabels();
                    scrollTimer.Start();
                }), DispatcherPriority.Render);
            }
            catch (Exception ex)
            {
                MessageBox.Show("启动滚动错误: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void CreateMessageLabels()
        {
            // 清空旧标签
            foreach (var label in messageLabels)
            {
                MessageCanvas.Children.Remove(label);
            }
            messageLabels.Clear();

            Label firstLabel = CreateMessageLabel(currentMessage);
            MessageCanvas.Children.Add(firstLabel);
            messageLabels.Add(firstLabel);
        
            firstLabel.Measure(new Size(double.PositiveInfinity, double.PositiveInfinity));
            double textWidth = firstLabel.DesiredSize.Width;
            double canvasWidth = MessageCanvas.ActualWidth;
        
            if (textWidth <= 0) textWidth = 100;
            if (canvasWidth <= 0) canvasWidth = SystemParameters.PrimaryScreenWidth;
        
            int labelCount = (int)Math.Ceiling(canvasWidth / textWidth) + 2;
            labelCount = Math.Min(labelCount, 20);
        
            for (int i = 1; i < labelCount; i++)
            {
                Label additionalLabel = CreateMessageLabel(currentMessage);
                MessageCanvas.Children.Add(additionalLabel);
                messageLabels.Add(additionalLabel);
            }
        
            PositionMessageLabels();
        }

        private Label CreateMessageLabel(string message)
        {
            return new Label
            {
                Content = message,
                Foreground = System.Windows.Media.Brushes.White,
                FontSize = 72,
                FontWeight = FontWeights.Bold,
                VerticalAlignment = VerticalAlignment.Center,
                Padding = new Thickness(0),
                Margin = new Thickness(0)
            };
        }

        private void PositionMessageLabels()
        {
            if (messageLabels.Count == 0) return;
            
            messageLabels[0].Measure(new Size(double.PositiveInfinity, double.PositiveInfinity));
            double labelWidth = messageLabels[0].DesiredSize.Width;
            double canvasWidth = MessageCanvas.ActualWidth;
            
            for (int i = 0; i < messageLabels.Count; i++)
            {
                Canvas.SetLeft(messageLabels[i], canvasWidth + (i * labelWidth));
                Canvas.SetTop(messageLabels[i], -7);
            }
        }

        private void ScrollTimer_Tick(object sender, EventArgs e)
        {
            if (messageLabels.Count == 0) return;
                
            messageLabels[0].Measure(new Size(double.PositiveInfinity, double.PositiveInfinity));
            double labelWidth = messageLabels[0].DesiredSize.Width;
            double canvasWidth = MessageCanvas.ActualWidth;
                
            for (int i = 0; i < messageLabels.Count; i++)
            {
                double currentLeft = Canvas.GetLeft(messageLabels[i]);
                double newLeft = currentLeft - scrollSpeed;
                Canvas.SetLeft(messageLabels[i], newLeft);
            }
                
            double firstLabelLeft = Canvas.GetLeft(messageLabels[0]);
            if (firstLabelLeft <= -labelWidth)
            {
                Label firstLabel = messageLabels[0];
                messageLabels.RemoveAt(0);
                messageLabels.Add(firstLabel);
                    
                double lastLabelLeft = Canvas.GetLeft(messageLabels[messageLabels.Count - 2]);
                Canvas.SetLeft(firstLabel, lastLabelLeft + labelWidth);
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

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
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
            scrollTimer.Stop();
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