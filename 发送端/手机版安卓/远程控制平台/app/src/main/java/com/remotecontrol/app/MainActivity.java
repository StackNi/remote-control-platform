package com.remotecontrol.app;

import android.app.*;
import android.os.*;
import android.content.Context;
import android.webkit.*;
import android.view.*;
import android.widget.EditText;
import android.util.Log;
import java.net.*;
import java.io.*;
import java.util.*;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.content.res.Configuration;

public class MainActivity extends Activity {
	
	private WebView webView;
	private static final String TAG = "RemoteControl";
	private View decorView;
	private String currentTheme = "light"; // 默认主题
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		// 隐藏标题栏
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		
		// 设置布局
		setContentView(R.layout.activity_main);
		
		// 先初始化应用主题
		applyInitialTheme();
		
		// 初始化WebView
		webView = (WebView) findViewById(R.id.webView);
		
		// ★★★ 关键：根据当前主题设置WebView初始背景色 ★★★
		if (currentTheme.equals("dark")) {
			// 深色模式：纯黑色背景
			webView.setBackgroundColor(Color.parseColor("#121212"));
			} else {
			// 浅色模式：纯白色背景
			webView.setBackgroundColor(Color.WHITE);
		}
		
		WebSettings webSettings = webView.getSettings();
		
		// 启用JavaScript
		webSettings.setJavaScriptEnabled(true);
		
		// 启用DOM存储API（解决localStorage问题）
		webSettings.setDomStorageEnabled(true);
		
		// 启用数据库
		webSettings.setDatabaseEnabled(true);
		
		// 设置数据库路径
		String databasePath = this.getApplicationContext().getDir("database", Context.MODE_PRIVATE).getPath();
		webSettings.setDatabasePath(databasePath);
		
		// 启用AppCache
		webSettings.setAppCacheEnabled(true);
		webSettings.setAppCachePath(getApplicationContext().getCacheDir().getPath());
		
		// 设置缓存模式
		webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
		
		// 允许访问文件
		webSettings.setAllowFileAccess(true);
		webSettings.setAllowFileAccessFromFileURLs(true);
		webSettings.setAllowUniversalAccessFromFileURLs(true);
		
		// 设置WebViewClient
		webView.setWebViewClient(new WebViewClient() {
			@Override
			public void onPageFinished(WebView view, String url) {
				super.onPageFinished(view, url);
				// 页面加载完成后通知网页当前系统主题
				notifyWebViewOfSystemTheme();
			}
		});
		
		// 设置WebChromeClient - 处理JavaScript对话框
		webView.setWebChromeClient(new WebChromeClient() {
			@Override
			public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
				// 显示Alert对话框
				new AlertDialog.Builder(MainActivity.this)
				.setTitle("提示")
				.setMessage(message)
				.setPositiveButton("确定", (dialog, which) -> {
					result.confirm(); // 确认结果
				})
				.setCancelable(false)
				.create()
				.show();
				return true; // 表示我们已经处理了这个对话框
			}
			
			@Override
			public boolean onJsConfirm(WebView view, String url, String message, JsResult result) {
				// 显示Confirm对话框
				new AlertDialog.Builder(MainActivity.this)
				.setTitle("确认")
				.setMessage(message)
				.setPositiveButton("确定", (dialog, which) -> {
					result.confirm(); // 确认
				})
				.setNegativeButton("取消", (dialog, which) -> {
					result.cancel(); // 取消
				})
				.setCancelable(false)
				.create()
				.show();
				return true; // 表示我们已经处理了这个对话框
			}
			
			@Override
			public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, JsPromptResult result) {
				// 显示Prompt对话框（如果需要）
				final EditText input = new EditText(MainActivity.this);
				input.setText(defaultValue);
				
				new AlertDialog.Builder(MainActivity.this)
				.setTitle(message)
				.setView(input)
				.setPositiveButton("确定", (dialog, which) -> {
					String value = input.getText().toString();
					result.confirm(value); // 确认并返回输入的值
				})
				.setNegativeButton("取消", (dialog, which) -> {
					result.cancel(); // 取消
				})
				.setCancelable(false)
				.create()
				.show();
				return true; // 表示我们已经处理了这个对话框
			}
		});
		
		// 添加JavaScript接口
		webView.addJavascriptInterface(new AndroidInterface(), "Android");
		
		// 获取decorView用于设置导航栏颜色
		decorView = getWindow().getDecorView();
		
		// 加载本地HTML文件
		webView.loadUrl("file:///android_asset/remotecontrol.html");
		
		// 在Android代码中设置WebView
		webView.setClickable(true);
		webView.setFocusableInTouchMode(true);
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		
		// 当系统配置改变时（包括主题变化），更新应用主题
		boolean isSystemDarkMode = (newConfig.uiMode & Configuration.UI_MODE_NIGHT_MASK)
		== Configuration.UI_MODE_NIGHT_YES;
		
		String newTheme = isSystemDarkMode ? "dark" : "light";
		
		// 只有当主题真正改变时才更新
		if (!newTheme.equals(currentTheme)) {
			Log.d(TAG, "系统主题变化: " + currentTheme + " -> " + newTheme);
			currentTheme = newTheme;
			
			// 立即更新WebView背景色
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					if (currentTheme.equals("dark")) {
						webView.setBackgroundColor(Color.parseColor("#121212"));
						} else {
						webView.setBackgroundColor(Color.WHITE);
					}
				}
			});
			
			applyAndroidTheme(newTheme);
			
			// 通知网页系统主题已变化
			notifyWebViewOfSystemTheme();
		}
	}
	
	// 通知网页系统主题变化
	private void notifyWebViewOfSystemTheme() {
		String javascriptCode = "javascript:if(window.handleSystemThemeChange){handleSystemThemeChange('" + currentTheme + "');}";
		
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			webView.evaluateJavascript(javascriptCode, null);
			} else {
			webView.loadUrl(javascriptCode);
		}
		
		Log.d(TAG, "通知网页系统主题: " + currentTheme);
	}
	
	// 初始化应用主题
	private void applyInitialTheme() {
		// 根据系统设置应用主题
		if (isSystemInDarkMode()) {
			applyDarkTheme();
			currentTheme = "dark";
			} else {
			applyLightTheme();
			currentTheme = "light";
		}
	}
	
	// 检查系统是否处于深色模式
	private boolean isSystemInDarkMode() {
		int nightModeFlags = getResources().getConfiguration().uiMode &
		android.content.res.Configuration.UI_MODE_NIGHT_MASK;
		return nightModeFlags == android.content.res.Configuration.UI_MODE_NIGHT_YES;
	}
	
	@Override
	public void onBackPressed() {
		// 检查WebView是否可以返回
		if (webView.canGoBack()) {
			webView.goBack();
			} else {
			// 给网页发送返回键事件消息
			sendBackButtonEventToWeb();
		}
	}

	// 根据系统主题设置窗口背景色
	private void setWindowBackgroundBySystemTheme() {
		Window window = getWindow();
		
		// 创建根据系统主题变化的背景色
		int backgroundColor;
		
		if (isSystemInDarkMode()) {
			// 深色模式 - 使用深灰色
			backgroundColor = Color.parseColor("#121212"); // 或者 0xFF121212
			} else {
			// 浅色模式 - 使用白色
			backgroundColor = Color.WHITE; // 或者 0xFFFFFFFF
		}
		
		// 设置窗口背景
		window.setBackgroundDrawable(new ColorDrawable(backgroundColor));
	}
	
	// 给网页发送返回键事件
	private void sendBackButtonEventToWeb() {
		// 使用JavaScript向网页发送消息
		String javascriptCode = "javascript:if(window.handleBackButton){window.handleBackButton();}else{window.androidBackButtonDefault();}";
		
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			webView.evaluateJavascript(javascriptCode, new ValueCallback<String>() {
				@Override
				public void onReceiveValue(String value) {
					// 回调处理，如果网页没有处理返回键，则执行默认退出逻辑
					if ("false".equals(value) || value == null) {
						performDefaultBackAction();
					}
				}
			});
			} else {
			// 对于低版本Android，使用loadUrl方式
			webView.loadUrl(javascriptCode);
			
			// 延迟检查是否需要执行默认退出逻辑
			new Handler().postDelayed(new Runnable() {
				@Override
				public void run() {
					performDefaultBackAction();
				}
			}, 1000);
		}
	}
	
	// 执行默认的返回操作（退出应用）
	private void performDefaultBackAction() {
		// 显示退出确认对话框
		new AlertDialog.Builder(MainActivity.this)
		.setTitle("退出应用")
		.setMessage("确定要退出远程控制平台吗？")
		.setPositiveButton("确定", (dialog, which) -> {
			// 退出应用
			finish();
		})
		.setNegativeButton("取消", (dialog, which) -> {
			// 什么都不做，留在当前页面
		})
		.setCancelable(false)
		.create()
		.show();
	}
	
	// 应用Android主题
	private void applyAndroidTheme(String theme) {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if ("dark".equals(theme)) {
					// 夜间模式
					applyDarkTheme();
					currentTheme = "dark";
					} else {
					// 日间模式
					applyLightTheme();
					currentTheme = "light";
				}
			}
		});
	}
	
	// 应用深色主题
	private void applyDarkTheme() {
		try {
			// 设置状态栏颜色（顶部栏）
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
				getWindow().setStatusBarColor(Color.parseColor("#121212"));
			}
			
			// 设置导航栏颜色（底部栏）
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
				getWindow().setNavigationBarColor(Color.parseColor("#121212"));
			}
			
			// 设置导航栏图标颜色（浅色）- 深色背景用浅色图标
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				View decorView = getWindow().getDecorView();
				int flags = decorView.getSystemUiVisibility();
				flags |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
				decorView.setSystemUiVisibility(flags);
			}
			
			// 设置状态栏文字颜色为浅色（深色背景用白色文字）
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				View decorView = getWindow().getDecorView();
				int flags = decorView.getSystemUiVisibility();
				flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR; // 清除浅色状态栏标志，使用深色文字
				decorView.setSystemUiVisibility(flags);
			}
			
			Log.d(TAG, "已应用Android深色主题");
			} catch (Exception e) {
			Log.e(TAG, "应用深色主题失败", e);
		}
	}
	
	// 应用浅色主题
	private void applyLightTheme() {
		try {
			// 设置状态栏颜色（顶部栏）- 紫色
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
				getWindow().setStatusBarColor(Color.parseColor("#3700B3"));
			}
			
			// 设置导航栏颜色（底部栏）- 白色
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
				getWindow().setNavigationBarColor(Color.parseColor("#FFFFFF"));
			}
			
			// 设置导航栏图标颜色（深色）- 浅色背景用深色图标
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				View decorView = getWindow().getDecorView();
				int flags = decorView.getSystemUiVisibility();
				flags &= ~View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR; // 清除浅色导航栏标志，使用深色图标
				decorView.setSystemUiVisibility(flags);
			}
			
			// 设置状态栏文字颜色为浅色（紫色背景用白色文字）
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				View decorView = getWindow().getDecorView();
				int flags = decorView.getSystemUiVisibility();
				flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR; // 清除浅色状态栏标志，使用白色文字
				decorView.setSystemUiVisibility(flags);
			}
			
			Log.d(TAG, "已应用Android浅色主题");
			} catch (Exception e) {
			Log.e(TAG, "应用浅色主题失败", e);
		}
	}
	
	// JavaScript接口类
	private class AndroidInterface {
		@JavascriptInterface
		public String sendUdpMessage(String ipAddress, int port, String message) {
			return sendUdpPacket(ipAddress, port, message);
		}
		
		@JavascriptInterface
		public String getLocalIP() {
			return getLocalIPAddress();
		}
		
		@JavascriptInterface
		public String getAndCheckLocalIP() {
			// 获取并检查当前IP，如果未知则返回错误
			String ip = getLocalIPAddress();
			if ("未知".equals(ip)) {
				return "ERROR: 未知IP";
			}
			return ip;
		}
		
		@JavascriptInterface
		public void onBackButtonHandled() {
			// 网页通知已经处理了返回键事件
			Log.d(TAG, "网页已处理返回键事件");
		}
		
		@JavascriptInterface
		public void setThemeMode(String theme) {
			// 网页通知主题变化 - 实时同步
			Log.d(TAG, "收到网页主题变化: " + theme);
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					applyAndroidTheme(theme);
				}
			});
		}
		
		@JavascriptInterface
		public String getSystemTheme() {
			// 提供给网页查询当前系统主题
			return isSystemInDarkMode() ? "dark" : "light";
		}

        @JavascriptInterface
        public void openUrl(String url) {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            startActivity(intent);
        }
	}
	
	// 发送UDP数据包
	private String sendUdpPacket(String ipAddress, int port, String message) {
		DatagramSocket socket = null;
		try {
			// 创建UDP socket
			socket = new DatagramSocket();
			socket.setSoTimeout(5000); // 设置超时5秒
			
			// 转换消息为字节数组
			byte[] sendData = message.getBytes("UTF-8");
			
			// 创建数据包
			InetAddress serverAddress = InetAddress.getByName(ipAddress);
			DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, serverAddress, port);
			
			// 发送数据包
			socket.send(sendPacket);
			Log.d(TAG, "UDP消息发送成功: " + ipAddress + ":" + port + " - " + message);
			
			return "SUCCESS";
			
			} catch (UnknownHostException e) {
			Log.e(TAG, "未知主机: " + ipAddress, e);
			return "ERROR: 未知主机 - " + e.getMessage();
			} catch (SocketException e) {
			Log.e(TAG, "Socket错误", e);
			return "ERROR: Socket错误 - " + e.getMessage();
			} catch (IOException e) {
			Log.e(TAG, "IO错误", e);
			return "ERROR: IO错误 - " + e.getMessage();
			} catch (Exception e) {
			Log.e(TAG, "发送UDP消息时发生未知错误", e);
			return "ERROR: 未知错误 - " + e.getMessage();
			} finally {
			if (socket != null && !socket.isClosed()) {
				socket.close();
			}
		}
	}
	
	// 获取本机IP地址
	private String getLocalIPAddress() {
		try {
			Enumeration<NetworkInterface> networkInterfaces = NetworkInterface.getNetworkInterfaces();
			
			// 第一轮：查找私有IP地址
			while (networkInterfaces.hasMoreElements()) {
				NetworkInterface networkInterface = networkInterfaces.nextElement();
				Enumeration<InetAddress> inetAddresses = networkInterface.getInetAddresses();
				while (inetAddresses.hasMoreElements()) {
					InetAddress inetAddress = inetAddresses.nextElement();
					if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
						String ip = inetAddress.getHostAddress();
						// 优先返回私有IP地址（局域网）
						if (ip.startsWith("192.168.") || ip.startsWith("10.") || ip.startsWith("172.")) {
							return ip;
						}
					}
				}
			}
			
			// 第二轮：如果没有找到私有IP，返回任意一个非回环的IPv4地址
			networkInterfaces = NetworkInterface.getNetworkInterfaces(); // 重新获取枚举
			while (networkInterfaces.hasMoreElements()) {
				NetworkInterface networkInterface = networkInterfaces.nextElement();
				Enumeration<InetAddress> inetAddresses = networkInterface.getInetAddresses();
				while (inetAddresses.hasMoreElements()) {
					InetAddress inetAddress = inetAddresses.nextElement();
					if (!inetAddress.isLoopbackAddress() && inetAddress instanceof Inet4Address) {
						return inetAddress.getHostAddress();
					}
				}
			}
			
			return "未知";
			
			} catch (Exception e) {
			Log.e(TAG, "获取本机IP地址失败", e);
			return "未知";
		}
	}
}
