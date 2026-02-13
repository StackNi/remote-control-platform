using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media.Animation;
using System.Windows.Threading;

namespace 远程控制平台接收端
{
    public partial class Window1 : Window
    {
        private DispatcherTimer visibilityTimer;
        private DispatcherTimer scrollTimer;
        private double screenWidth;
        private bool isCloseButtonPressed = false;
        private List<Label> messageLabels = new List<Label>();
        private string currentMessage = "";
        private double scrollSpeed = 6;

        public Window1()
        {
            InitializeComponent();
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
    
            // 鼠标按下：停止拖动，记录按下状态
            this.CloseButton.MouseLeftButtonDown += (s, e) => 
            {
                isCloseButtonPressed = true;
                e.Handled = true; // 阻止窗口拖动
            };
    
            // 鼠标松开：如果在按钮上松开且之前是按下的，则关闭
            this.CloseButton.MouseLeftButtonUp += (s, e) => 
            {
                if (isCloseButtonPressed)
                {
                    this.StartFadeOutAndClose();
                }
                isCloseButtonPressed = false;
            };
    
            // 鼠标离开按钮时重置状态
            this.CloseButton.MouseLeave += (s, e) => 
            {
                isCloseButtonPressed = false;
            };
            
            InitializeWindowPosition();
            SetupTimers();
            this.Visibility = Visibility.Collapsed;
            this.Opacity = 0; // 初始完全透明
            
            // 添加键盘事件处理
            this.KeyDown += Window_KeyDown;
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

            scrollTimer = new DispatcherTimer();
            scrollTimer.Interval = TimeSpan.FromMilliseconds(16);
            scrollTimer.Tick += ScrollTimer_Tick;
        }

        // 键盘事件处理
        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.System && e.SystemKey == Key.F4)
            {
                e.Handled = true; // 阻止默认关闭行为
                StartFadeOutAndClose();
            }
        }

    	private void StartFadeOutAndClose()
    	{
        	try
        	{
            	visibilityTimer.Stop();
            
            	DoubleAnimation fadeOutAnimation = new DoubleAnimation();
            	fadeOutAnimation.From = this.Opacity;
            	fadeOutAnimation.To = 0;
            	fadeOutAnimation.Duration = TimeSpan.FromSeconds(0.8);
            
            	fadeOutAnimation.Completed += (s, e) =>
            	{
            	    this.Close(); // 窗口关闭会自动清理所有资源
            	};
            
            	this.BeginAnimation(Window.OpacityProperty, fadeOutAnimation);
        	}
        	catch (Exception ex)
        	{
        	    this.Close();
        	}
    	}

    	public void DisplayMessage(string username, string ip, string message, int duration)
    	{
        	try
        	{
            
            	UserInfoLabel.Content = "用户 " + username + " 发来的消息" + "（IP：" + ip + "）：";
            	currentMessage = message + "                      ";
            
            	CreateMessageLabels(); // 直接创建新标签
            	StartScrolling();
            
            	this.Visibility = Visibility.Visible;
            	StartOpacityAnimation();
            
            	if (duration > 0 && duration <= 86400)
            	{
                	visibilityTimer.Interval = TimeSpan.FromSeconds(duration);
                	visibilityTimer.Start();
            	}
            
            	this.Title = "远程控制平台 - 跑马灯模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
            	SendConfirmation(ip, username);
        	}
        	catch (Exception ex)
        	{
            	var app = Application.Current as App;
            	if (app != null)
            	{
                	app.SendErrorMessage(ip, username, "消息显示失败: " + ex.Message);
            	}
            	MessageBox.Show("显示消息错误: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
        	}
    	}

        private void StartOpacityAnimation()
        {
            // 创建透明度动画
            DoubleAnimation opacityAnimation = new DoubleAnimation();
            opacityAnimation.From = 0; // 从完全透明开始
            opacityAnimation.To = 1;   // 到完全不透明结束
            opacityAnimation.Duration = TimeSpan.FromSeconds(0.8); // 0.8秒持续时间
            
            // 开始动画
            this.BeginAnimation(Window.OpacityProperty, opacityAnimation);
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
            catch (Exception ex)
            {
                Console.WriteLine("发送确认失败: " + ex.Message);
            }
        }

        private void StartScrolling()
        {
            try
            {
                // 强制立即布局更新
                this.UpdateLayout();
                MessageCanvas.UpdateLayout();
        
                // 等待布局完成后再创建消息标签
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
        	// 创建第一个标签
        	Label firstLabel = CreateMessageLabel(currentMessage);
        	MessageCanvas.Children.Add(firstLabel);
        	messageLabels.Add(firstLabel);
        
        	// 测量和计算标签数量
        	firstLabel.Measure(new Size(double.PositiveInfinity, double.PositiveInfinity));
        	double textWidth = firstLabel.DesiredSize.Width;
        	double canvasWidth = MessageCanvas.ActualWidth;
        
        	if (textWidth <= 0) textWidth = 100;
        	if (canvasWidth <= 0) canvasWidth = SystemParameters.PrimaryScreenWidth;
        
        	int labelCount = (int)Math.Ceiling(canvasWidth / textWidth) + 2;
        	labelCount = Math.Min(labelCount, 20); // 限制上限
        
       	    // 创建额外标签
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
    
    // 第一个标签从画布最右侧开始
    for (int i = 0; i < messageLabels.Count; i++)
    {
        Canvas.SetLeft(messageLabels[i], canvasWidth + (i * labelWidth));
        Canvas.SetTop(messageLabels[i], -7);
    }
}

private void ScrollTimer_Tick(object sender, EventArgs e)
{
    try
    {
        if (messageLabels.Count == 0) return;
        
        // 测量标签宽度
        messageLabels[0].Measure(new Size(double.PositiveInfinity, double.PositiveInfinity));
        double labelWidth = messageLabels[0].DesiredSize.Width;
        double canvasWidth = MessageCanvas.ActualWidth;
        
        // 移动所有标签
        for (int i = 0; i < messageLabels.Count; i++)
        {
            double currentLeft = Canvas.GetLeft(messageLabels[i]);
            double newLeft = currentLeft - scrollSpeed;
            Canvas.SetLeft(messageLabels[i], newLeft);
        }
        
        // 检查第一个标签是否完全移出屏幕左侧
        double firstLabelLeft = Canvas.GetLeft(messageLabels[0]);
        if (firstLabelLeft <= -labelWidth)
        {
            // 将第一个标签移到队列末尾，并放置在最右侧
            Label firstLabel = messageLabels[0];
            messageLabels.RemoveAt(0);
            messageLabels.Add(firstLabel);
            
            // 获取最后一个标签的位置
            double lastLabelLeft = Canvas.GetLeft(messageLabels[messageLabels.Count - 2]);
            Canvas.SetLeft(firstLabel, lastLabelLeft + labelWidth);
        }
    }
    catch (Exception ex)
    {
        // 忽略滚动过程中的小错误
        Console.WriteLine("滚动错误: " + ex.Message);
    }
}

        private void VisibilityTimer_Tick(object sender, EventArgs e)
        {
            try
            {
                visibilityTimer.Stop();
                
                // 使用淡出动效关闭窗口
                StartFadeOutAndClose();
            }
            catch (Exception ex)
            {
                MessageBox.Show("隐藏消息错误: " + ex.Message, "错误", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            // 停止计时器并清理资源
            try
            {
                visibilityTimer.Stop();
            }
            catch (Exception ex)
            {
                Console.WriteLine("停止计时器错误: " + ex.Message);
            }
        }
        
        private void Window_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            // 开始拖动窗口
            this.DragMove();
        }
    }
}