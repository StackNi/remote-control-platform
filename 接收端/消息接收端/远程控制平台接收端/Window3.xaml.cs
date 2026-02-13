using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Threading;

namespace 远程控制平台接收端
{
    public partial class Window3 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer typewriterTimer;
        private DispatcherTimer blinkTimer;
        private bool isCloseButtonPressed = false;
        private string fullMessage = "";
        private int currentCharIndex = 0;
        private bool isTypewriterComplete = false;
        private int blinkCount = 0;
        private const int FINAL_BLINKS = 3;

        public Window3()
        {
            InitializeComponent();
            this.SizeChanged += Window3_SizeChanged;
            
            // 关闭按钮事件处理
            this.CloseButton.MouseEnter += CloseButton_MouseEnter;
            this.CloseButton.MouseLeave += CloseButton_MouseLeave;
            this.CloseButton.MouseLeftButtonDown += CloseButton_MouseLeftButtonDown;
            this.CloseButton.MouseLeftButtonUp += CloseButton_MouseLeftButtonUp;
            this.CloseButton.MouseLeave += CloseButton_MouseLeave2;
            
            SetupTimers();
            this.Opacity = 0;
            
            // 添加键盘事件处理
            this.KeyDown += Window_KeyDown;
        }

        private void Window3_SizeChanged(object sender, SizeChangedEventArgs e)
        {
            if (e.HeightChanged)
            {
                CenterWindowVertically();
            }
        }

        private void CloseButton_MouseEnter(object sender, MouseEventArgs e)
        {
            this.CloseButton.Opacity = 1.0;
        }

        private void CloseButton_MouseLeave(object sender, MouseEventArgs e)
        {
            this.CloseButton.Opacity = 0.5;
        }

        private void CloseButton_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            isCloseButtonPressed = true;
            e.Handled = true;
        }

        private void CloseButton_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
        {
            if (isCloseButtonPressed)
            {
                this.Close();
            }
            isCloseButtonPressed = false;
        }

        private void CloseButton_MouseLeave2(object sender, MouseEventArgs e)
        {
            isCloseButtonPressed = false;
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;
            
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

        public void DisplayMessage(string username, string ip, string message, int duration)
        {
            try
            {
                UserInfoTextBlock.Text = "用户 " + username + " 发来的消息" + "（IP：" + ip + "）：";
                
                // 初始化打字机效果
                fullMessage = message;
                currentCharIndex = 0;
                isTypewriterComplete = false;
                blinkCount = 0;
                MessageTextBlock.Inlines.Clear(); // 清空Inline
                
                this.Visibility = Visibility.Visible;

                // 窗口显示后垂直居中
                this.Dispatcher.BeginInvoke(new Action(() =>
                {
                    CenterWindowVertically();
                }), DispatcherPriority.Loaded);
                
                // 直接显示
                this.Opacity = 1.0;
                
                // 启动打字机效果
                typewriterTimer.Start();
                
                // 设置自动关闭定时器
                if (duration > 0 && duration <= 86400)
                {
                    visibilityTimer.Interval = TimeSpan.FromSeconds(duration);
                    visibilityTimer.Start();
                }
                
                this.Title = "远程控制平台接收端 - 打字机模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
                
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

        private void TypewriterTimer_Tick(object sender, EventArgs e)
        {
            if (currentCharIndex < fullMessage.Length)
            {
                // 清空TextBlock的Inline
                MessageTextBlock.Inlines.Clear();
                
                // 添加已打出的文字
                MessageTextBlock.Inlines.Add(new Run(fullMessage.Substring(0, currentCharIndex + 1)));
                
                // 添加光标（作为单独的Run）
                MessageTextBlock.Inlines.Add(new Run("▂")
                {
                    Foreground = System.Windows.Media.Brushes.White
                });
                
                currentCharIndex++;
                
                // 打字后滚动到底部
                ScrollToBottom();
            }
            else
            {
                // 打字完成
                typewriterTimer.Stop();
                isTypewriterComplete = true;
                
                // 启动最终闪烁效果
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
                // 闪烁完成，移除光标
                blinkTimer.Stop();
                MessageTextBlock.Inlines.Clear();
                MessageTextBlock.Inlines.Add(new Run(fullMessage));
                
                // 最后滚动一次到底部
                ScrollToBottom();
            }
            else
            {
                // 清空重新添加
                MessageTextBlock.Inlines.Clear();
                MessageTextBlock.Inlines.Add(new Run(fullMessage));
                
                if (blinkCount % 2 == 1)
                {
                    // 添加光标
                    MessageTextBlock.Inlines.Add(new Run("▂")
                    {
                        Foreground = System.Windows.Media.Brushes.White
                    });
                }
                
                // 闪烁过程中也滚动到底部
                ScrollToBottom();
            }
        }

        // 滚动到底部的方法
        private void ScrollToBottom()
        {
            if (MessageScrollViewer != null)
            {
                // 使用Dispatcher确保在UI线程执行
                Dispatcher.BeginInvoke(new Action(() =>
                {
                    MessageScrollViewer.ScrollToEnd();
                }), DispatcherPriority.Background);
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
            typewriterTimer.Stop();
            visibilityTimer.Stop();
            blinkTimer.Stop();
        }

        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            this.DragMove();
        }
    }
}