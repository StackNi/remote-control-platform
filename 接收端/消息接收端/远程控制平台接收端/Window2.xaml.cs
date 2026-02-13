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
    public partial class Window2 : Window
    {
        private DispatcherTimer visibilityTimer;
        private const int WM_NCHITTEST = 0x0084;
        private const int HTCLIENT = 1;
        private bool isCloseButtonPressed = false;

        public Window2()
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
            InitializeWindowSize();
            SetupTimers();
            this.Opacity = 0; // 初始完全透明
            
            // 添加键盘事件处理
            this.KeyDown += Window_KeyDown;
        }

        private void InitializeWindowSize()
        {
            this.Width = SystemParameters.PrimaryScreenWidth * 2 / 3;
            this.WindowStartupLocation = WindowStartupLocation.CenterScreen;
        }

        private void SetupTimers()
        {
            visibilityTimer = new DispatcherTimer();
            visibilityTimer.Tick += VisibilityTimer_Tick;
        }

        // 新增：键盘事件处理
        private void Window_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.System && e.SystemKey == Key.F4)
            {
                e.Handled = true; // 阻止默认关闭行为
                StartFadeOutAndClose();
            }
        }

        // 新增：淡出并关闭窗口（释放内存）
        private void StartFadeOutAndClose()
        {
            try
            {
                // 创建淡出动画
                DoubleAnimation fadeOutAnimation = new DoubleAnimation();
                fadeOutAnimation.From = this.Opacity;
                fadeOutAnimation.To = 0;
                fadeOutAnimation.Duration = TimeSpan.FromSeconds(0.8);
                
                // 动画完成后关闭窗口
                fadeOutAnimation.Completed += (s, e) =>
                {
                    this.Close(); // 关闭窗口，释放内存
                };
                
                // 开始动画
                this.BeginAnimation(Window.OpacityProperty, fadeOutAnimation);
            }
            catch (Exception ex)
            {
                // 如果动画失败，直接关闭
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
        
        // 启动透明度动画
        StartOpacityAnimation();
        
        // 修复：添加合理的时长限制
        if (duration > 0 && duration <= 86400) // 最大24小时
        {
            visibilityTimer.Interval = TimeSpan.FromSeconds(duration);
            visibilityTimer.Start();
        }
        // duration = 0 或超长数值都视为永久显示
        
        this.Title = "远程控制平台接收端 - 公告模式 - 最后接收: " + DateTime.Now.ToString("HH:mm:ss");
        
        SendConfirmation(ip, username);
    }
    catch (Exception ex)
    {
        // 修改调用方式
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

        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            this.Visibility = Visibility.Collapsed;
        }

        private void Window_Closing(object sender, System.ComponentModel.CancelEventArgs e)
        {
            // 只停止计时器（Window2没有scrollTimer）
            try
            {
                visibilityTimer.Stop();
                // 移除 scrollTimer 相关代码，因为Window2中没有这个变量
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

        protected override void OnClosed(EventArgs e)
        {
            base.OnClosed(e);
            // 这里不需要做任何事，窗口正常关闭
        }
    }
}