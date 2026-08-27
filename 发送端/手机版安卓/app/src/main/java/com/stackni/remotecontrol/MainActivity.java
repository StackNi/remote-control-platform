package com.stackni.remotecontrol;

import android.app.*;
import android.os.*;
import android.content.Context;
import android.webkit.*;
import android.view.*;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.util.Log;
import java.net.*;
import java.io.*;
import java.util.*;
import android.graphics.Color;
import android.content.res.Configuration;
import android.content.Intent;
import android.net.Uri;
import android.content.SharedPreferences;
import android.widget.Toast;
import android.provider.Settings;
import android.support.v4.content.FileProvider;

import org.json.JSONObject;
import org.json.JSONException;

public class MainActivity extends Activity {
	
	private WebView webView;
	private static final String TAG = "RemoteControl";
	private View decorView;
	private String currentTheme = "light";
	private static final String VERSION_URL = "https://stackni.github.io/remote-control-platform/version.json";
	private String currentVersion = "3.2.0";
	private long lastBackPressTime = 0;
	private Toast backPressToast = null;
	private boolean isDownloading = false;
	
	// ========== UDP 通信相关 ==========
	private DatagramSocket udpSocket;
	private Thread receiveThread;
	private volatile boolean isWaitingForResponse = false;
	private String FDeviceGUID = "";
	private String FCurrentRequestID = "";
	private Handler timeoutHandler = new Handler();
	private Runnable timeoutRunnable;
	private String currentTargetIP = "";
	private int currentTargetPort = 25105;
	private boolean responseProcessed = false;
	private String pendingActionType = ""; // "send", "end", "cmd"
	
	// ========== 端口常量 ==========
	private static final int PORT_MESSAGE = 25105;
	private static final int PORT_SYSTEM_CMD = 25106;
	private static final int TIMEOUT_MS = 10000;
	
	// ========== 版本更新相关 ==========
	private VersionInfo pendingVersionInfo = null;
	private boolean isPageLoaded = false;
	
	// ========== 生命周期 ==========
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		setContentView(R.layout.activity_main);
		
		loadOrCreateGUID();
		applyInitialTheme();
		initUdpSocket();
		
		webView = (WebView) findViewById(R.id.webView);
		setupWebView();
		
		webView.addJavascriptInterface(new AndroidInterface(), "Android");
		decorView = getWindow().getDecorView();
		webView.loadUrl("file:///android_asset/index.html");
		
		// 增加启动次数（和 PC 端一致）
		SharedPreferences prefs = getSharedPreferences("update_prefs", MODE_PRIVATE);
		int startupCount = prefs.getInt("startup_count", 0);
		if (startupCount < 10) {
			startupCount++;
			prefs.edit().putInt("startup_count", startupCount).apply();
		}
		
		// 启动自动检查更新（和 PC 端一致，传 False）
		checkForUpdateSilent();
	}
	
	private void setupWebView() {
		if (currentTheme.equals("dark")) {
			webView.setBackgroundColor(Color.parseColor("#121212"));
		} else {
			webView.setBackgroundColor(Color.WHITE);
		}
		
		WebSettings webSettings = webView.getSettings();
		webSettings.setJavaScriptEnabled(true);
		webSettings.setDomStorageEnabled(true);
		webSettings.setDatabaseEnabled(true);
		String databasePath = this.getApplicationContext().getDir("database", Context.MODE_PRIVATE).getPath();
		webSettings.setDatabasePath(databasePath);
		webSettings.setAppCacheEnabled(true);
		webSettings.setAppCachePath(getApplicationContext().getCacheDir().getPath());
		webSettings.setCacheMode(WebSettings.LOAD_DEFAULT);
		webSettings.setAllowFileAccess(true);
		webSettings.setAllowFileAccessFromFileURLs(true);
		webSettings.setAllowUniversalAccessFromFileURLs(true);
		
		webView.setWebViewClient(new WebViewClient() {
			@Override
			public void onPageFinished(WebView view, String url) {
				super.onPageFinished(view, url);
				isPageLoaded = true;
				notifyWebViewOfSystemTheme();
				notifyWebViewOfGUID();
				// 页面加载完成后，如果有待处理的更新通知，立即发送
				notifyPendingUpdateIfReady();
			}
		});
		
		webView.setWebChromeClient(new WebChromeClient() {
			@Override
			public boolean onJsAlert(WebView view, String url, String message, JsResult result) {
				boolean isFromWarningPage = message.startsWith("[WARNING]");
				final String displayMessage = isFromWarningPage ? message.substring(9) : message;
				
				AlertDialog dialog = new AlertDialog.Builder(MainActivity.this)
				.setTitle(isFromWarningPage ? "提示" : "提示")
				.setMessage(displayMessage)
				.setPositiveButton("确定", (d, which) -> {
					result.confirm();
					if (isFromWarningPage) {
						returnToHomePage();
					}
				})
				.setCancelable(false)
				.create();
				dialog.show();
				return true;
			}
			
			@Override
			public boolean onJsConfirm(WebView view, String url, String message, JsResult result) {
				new AlertDialog.Builder(MainActivity.this)
				.setTitle("确认")
				.setMessage(message)
				.setPositiveButton("确定", (dialog, which) -> result.confirm())
				.setNegativeButton("取消", (dialog, which) -> result.cancel())
				.setCancelable(false)
				.create()
				.show();
				return true;
			}
			
			@Override
			public boolean onJsPrompt(WebView view, String url, String message, String defaultValue, JsPromptResult result) {
				final EditText input = new EditText(MainActivity.this);
				input.setText(defaultValue);
				
				new AlertDialog.Builder(MainActivity.this)
				.setTitle(message)
				.setView(input)
				.setPositiveButton("确定", (dialog, which) -> {
					result.confirm(input.getText().toString());
				})
				.setNegativeButton("取消", (dialog, which) -> result.cancel())
				.setCancelable(false)
				.create()
				.show();
				return true;
			}
		});
	}
	
	// ================== GUID 管理 ==================
	private void loadOrCreateGUID() {
		SharedPreferences prefs = getSharedPreferences("device_prefs", MODE_PRIVATE);
		FDeviceGUID = prefs.getString("device_guid", "");
		if (FDeviceGUID.isEmpty()) {
			FDeviceGUID = UUID.randomUUID().toString();
			prefs.edit().putString("device_guid", FDeviceGUID).apply();
		}
		Log.d(TAG, "设备GUID: " + FDeviceGUID);
	}
	
	private void notifyWebViewOfGUID() {
		String js = "javascript:if(window._setDeviceGUID) { window._setDeviceGUID('" + escapeJS(FDeviceGUID) + "'); }";
		evaluateJS(js);
	}
	
	// ================== UDP Socket 管理 ==================
	private void initUdpSocket() {
		try {
			udpSocket = new DatagramSocket();
			udpSocket.setSoTimeout(1000);
			Log.d(TAG, "UDP Socket 初始化完成，本地端口: " + udpSocket.getLocalPort());
		} catch (SocketException e) {
			Log.e(TAG, "UDP Socket 初始化失败", e);
		}
	}
	
	private void ensureUdpSocket() {
		if (udpSocket == null || udpSocket.isClosed()) {
			initUdpSocket();
		}
	}
	
	// ================== JSON 消息构建 ==================
	private String buildMessageJSON(String username, String content, String duration, String displayMode, String requestID) {
		try {
			JSONObject json = new JSONObject();
			json.put("type", "message");
			json.put("deviceGUID", FDeviceGUID);
			json.put("username", username);
			json.put("content", content);
			json.put("duration", duration);
			json.put("displayMode", displayMode);
			json.put("requestID", requestID);
			return json.toString();
		} catch (JSONException e) {
			Log.e(TAG, "构建消息JSON失败", e);
			return "{}";
		}
	}
	
	private String buildCloseJSON(String username, String requestID) {
		try {
			JSONObject json = new JSONObject();
			json.put("type", "close");
			json.put("deviceGUID", FDeviceGUID);
			json.put("username", username);
			json.put("requestID", requestID);
			return json.toString();
		} catch (JSONException e) {
			Log.e(TAG, "构建关闭JSON失败", e);
			return "{}";
		}
	}
	
	private String buildCmdJSON(String username, String command, String permission, String requestID) {
		try {
			JSONObject json = new JSONObject();
			json.put("type", "cmd");
			json.put("deviceGUID", FDeviceGUID);
			json.put("username", username);
			json.put("command", command);
			json.put("permission", permission);
			json.put("requestID", requestID);
			return json.toString();
		} catch (JSONException e) {
			Log.e(TAG, "构建CMD JSON失败", e);
			return "{}";
		}
	}
	
	// ================== 发送UDP消息（核心方法，5参数） ==================
	private void doSendUdpMessage(String ipAddress, int port, String jsonData, String requestID, String actionType) {
		ensureUdpSocket();
		
		resetCommunicationState();
		
		FCurrentRequestID = requestID;
		pendingActionType = actionType;
		responseProcessed = false;
		currentTargetIP = ipAddress;
		currentTargetPort = port;
		
		try {
			byte[] sendData = jsonData.getBytes("UTF-8");
			InetAddress serverAddress = InetAddress.getByName(ipAddress);
			DatagramPacket sendPacket = new DatagramPacket(sendData, sendData.length, serverAddress, port);
			udpSocket.send(sendPacket);
			Log.d(TAG, "UDP发送成功: " + ipAddress + ":" + port + ", RequestID: " + requestID + ", Type: " + actionType);
			
			startTimeoutTimer();
			startReceiving();
			
		} catch (UnknownHostException e) {
			Log.e(TAG, "未知主机", e);
			handleSendError("无法解析主机名，请检查IP地址是否正确", "warning");
		} catch (PortUnreachableException e) {
			Log.e(TAG, "端口不可达", e);
			handleSendError("目标端口不可达，请检查对方是否在线", "warning");
		} catch (NoRouteToHostException e) {
			Log.e(TAG, "无法路由到主机", e);
			handleSendError("无法路由到目标主机，请检查网络连接", "warning");
		} catch (ConnectException e) {
			Log.e(TAG, "连接被拒绝", e);
			handleSendError("连接被拒绝，请检查对方防火墙设置", "warning");
		} catch (SocketException e) {
			Log.e(TAG, "Socket错误", e);
			String msg = e.getMessage();
			if (msg != null && msg.contains("Permission denied")) {
				handleSendError("权限不足，无法发送", "warning");
			} else if (msg != null && msg.contains("Network is unreachable")) {
				handleSendError("网络不可达，请检查网络设置", "warning");
			} else {
				handleSendError("网络错误 - " + msg, "warning");
			}
		} catch (IOException e) {
			Log.e(TAG, "IO错误", e);
			handleSendError("IO错误 - " + e.getMessage(), "warning");
		} catch (Exception e) {
			Log.e(TAG, "发送失败", e);
			handleSendError("未知错误 - " + e.getMessage(), "warning");
		}
	}
	
	private void handleSendError(String errorMsg, String type) {
		responseProcessed = true;
		FCurrentRequestID = "";
		stopTimeoutTimer();
		stopReceiving();
		
		final String finalMsg = errorMsg;
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if ("warning".equals(type)) {
					showWarningPage(finalMsg);
				} else {
					showFailurePage("send-message-failure", finalMsg);
				}
			}
		});
	}
	
	// ================== 重置通信状态 ==================
	private void resetCommunicationState() {
		stopTimeoutTimer();
		stopReceiving();
		responseProcessed = false;
		FCurrentRequestID = "";
		pendingActionType = "";
	}
	
	// ================== 接收响应（三行协议） ==================
	private void startReceiving() {
		stopReceiving();
		isWaitingForResponse = true;
		
		receiveThread = new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					byte[] buffer = new byte[4096];
					DatagramPacket packet = new DatagramPacket(buffer, buffer.length);
					
					while (isWaitingForResponse) {
						try {
							udpSocket.receive(packet);
							String received = new String(packet.getData(), 0, packet.getLength(), "UTF-8");
							Log.d(TAG, "收到UDP响应:\n" + received);
							
							handleResponse(received);
							return;
							
						} catch (SocketTimeoutException e) {
							// 继续等待
						}
					}
				} catch (Exception e) {
					Log.e(TAG, "UDP接收错误", e);
				}
			}
		});
		receiveThread.start();
	}
	
	/**
	* 处理三行协议响应
	* 成功: {requestID}\nOK\n
	* 错误: {requestID}\nERR\n{errorMessage}\n
	* 计数(结束消息): {requestID}\n{count}\n
	*/
	private void handleResponse(String response) {
		isWaitingForResponse = false;
		stopTimeoutTimer();
		stopReceiving();
		
		if (responseProcessed) return;
		
		String[] lines = response.split("\n");
		if (lines.length < 2) {
			Log.w(TAG, "响应格式不正确（行数不足）");
			returnToHomePageAfterDelay(1000);
			return;
		}
		
		String requestID = lines[0].trim();
		if (!requestID.equals(FCurrentRequestID)) {
			Log.d(TAG, "忽略不匹配的响应，期望: " + FCurrentRequestID + ", 实际: " + requestID);
			return;
		}
		
		responseProcessed = true;
		FCurrentRequestID = "";
		
		String status = lines[1].trim();
		
		// === 结束消息计数响应（纯数字） ===
		if (status.matches("\\d+")) {
			final int count = Integer.parseInt(status);
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					if (count > 0) {
						String msg = "成功关闭 " + count + " 个消息窗口";
						showEndSuccessPage(msg);
						// ★★★ 成功关闭窗口后，重置状态（与超时/错误保持一致） ★★★
						resetCommunicationState();
					} else {
						showWarningPage("没有正在展示的消息窗口");
					}
				}
			});
			return;
		}
		
		if ("end".equals(pendingActionType)) {
			Log.d(TAG, "结束消息收到非预期状态，已丢弃: " + status);
			return;
		}
		
		// === 成功响应（send / cmd） ===
		if ("OK".equals(status)) {
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					if ("send".equals(pendingActionType)) {
						showSuccessPage("send-message-success");
					} else if ("cmd".equals(pendingActionType)) {
						showSuccessPage("send-cmd-success");
					} else {
						showSuccessPage("send-message-success");
					}
					// ★★★ 成功收到 OK 后，重置状态（与超时/错误保持一致） ★★★
					resetCommunicationState();
				}
			});
			return;
		}
		
		// === 错误响应（红色） ===
		if ("ERR".equals(status)) {
			String errorMsg = "";
			if (lines.length >= 3) {
				StringBuilder sb = new StringBuilder();
				for (int i = 2; i < lines.length; i++) {
					if (i > 2) sb.append("\n");
					sb.append(lines[i]);
				}
				errorMsg = sb.toString().trim();
			}
			if (errorMsg.isEmpty()) {
				errorMsg = "接收端返回了未知错误";
			}
			
			final String finalErrorMsg = errorMsg;
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					showFailurePageByType(finalErrorMsg);
					// showFailurePage 内部已经延迟调用 resetCommunicationState
				}
			});
			return;
		}
		
		Log.w(TAG, "收到未知状态: " + status);
	}
	
	private void showFailurePageByType(String errorMessage) {
		if ("send".equals(pendingActionType)) {
			showFailurePage("send-message-failure", errorMessage);
		} else if ("cmd".equals(pendingActionType)) {
			showFailurePage("send-cmd-failure", errorMessage);
		} else if ("end".equals(pendingActionType)) {
			showFailurePage("end-message-failure", errorMessage);
		} else {
			showFailurePage("send-message-failure", errorMessage);
		}
	}
	
	// ================== 超时管理 ==================
	private void startTimeoutTimer() {
		stopTimeoutTimer();
		timeoutRunnable = new Runnable() {
			@Override
			public void run() {
				if (isWaitingForResponse && !responseProcessed) {
					Log.d(TAG, "UDP响应超时（10秒）");
					isWaitingForResponse = false;
					responseProcessed = true;
					FCurrentRequestID = "";
					stopReceiving();
					
					runOnUiThread(new Runnable() {
						@Override
						public void run() {
							showTimeoutPage();
							// showTimeoutPage 内部会调用 resetCommunicationState
						}
					});
				}
			}
		};
		timeoutHandler.postDelayed(timeoutRunnable, TIMEOUT_MS);
	}
	
	private void stopTimeoutTimer() {
		if (timeoutRunnable != null) {
			timeoutHandler.removeCallbacks(timeoutRunnable);
			timeoutRunnable = null;
		}
	}
	
	private void stopReceiving() {
		isWaitingForResponse = false;
		if (receiveThread != null) {
			receiveThread.interrupt();
			receiveThread = null;
		}
	}
	
	// ================== 页面跳转 ==================
	private void evaluateJS(String js) {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			webView.evaluateJavascript(js, null);
		} else {
			webView.loadUrl(js);
		}
	}
	
	private void returnToHomePageAfterDelay(int delayMs) {
		new Handler().postDelayed(new Runnable() {
			@Override
			public void run() {
				returnToHomePage();
			}
		}, delayMs);
	}
	
	// ================== ★★★ 修改后的 showSuccessPage（不再改标题栏） ★★★ ==================
	private void showSuccessPage(String pageId) {
		String js = "javascript:(function() { " +
			"document.querySelectorAll('.page').forEach(function(p) { p.classList.remove('active'); }); " +
			"document.getElementById('" + pageId + "').classList.add('active'); " +
			"document.querySelector('.back-btn').style.display = 'none'; " +
			"document.querySelector('.footer').style.display = 'none'; " +
			"document.querySelector('.content').style.marginBottom = '0'; " +
			"setTimeout(function() { " +
			"    document.querySelector('.nav-item[data-target=\"home-page\"]').click(); " +
			"}, 3000); " +
			"})();";
		evaluateJS(js);
	}
	
	// ================== ★★★ 修改后的 showEndSuccessPage（不再改标题栏） ★★★ ==================
	private void showEndSuccessPage(String message) {
		String js = "javascript:(function() { " +
			"document.querySelectorAll('.page').forEach(function(p) { p.classList.remove('active'); }); " +
			"document.getElementById('end-message-success').classList.add('active'); " +
			"document.querySelector('.back-btn').style.display = 'none'; " +
			"document.querySelector('.footer').style.display = 'none'; " +
			"document.querySelector('.content').style.marginBottom = '0'; " +
			"var pElem = document.querySelector('#end-message-success p'); " +
			"if (pElem) pElem.textContent = '" + escapeJS(message) + "'; " +
			"setTimeout(function() { " +
			"    document.querySelector('.nav-item[data-target=\"home-page\"]').click(); " +
			"}, 3000); " +
			"})();";
		evaluateJS(js);
	}
	
	// ================== ★★★ 修改后的 showTimeoutPage（不再改标题栏） ★★★ ==================
	private void showTimeoutPage() {
		String actionType = pendingActionType;
		if (actionType == null || actionType.isEmpty()) {
			actionType = "send";
		}
		
		String titleText = "";
		switch(actionType) {
			case "send": titleText = "消息已发出，未收到对方确认"; break;
			case "end": titleText = "结束命令已发出，未收到对方确认"; break;
			case "cmd": titleText = "cmd命令已发出，执行状态未知"; break;
			default: titleText = "消息已发出，未收到对方确认";
		}
		
		String js = "javascript:(function() { " +
			"document.querySelectorAll('.page').forEach(function(p) { p.classList.remove('active'); }); " +
			"document.getElementById('timeout-page').classList.add('active'); " +
			"var h2 = document.querySelector('#timeout-page h2'); " +
			"if (h2) h2.textContent = '" + escapeJS(titleText) + "'; " +
			"document.querySelector('.back-btn').style.display = 'none'; " +
			"document.querySelector('.footer').style.display = 'none'; " +
			"document.querySelector('.content').style.marginBottom = '0'; " +
			"setTimeout(function() { " +
			"    document.querySelector('.nav-item[data-target=\"home-page\"]').click(); " +
			"}, 3000); " +
			"})();";
		evaluateJS(js);
		
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				resetCommunicationState();
			}
		});
	}
	
	// ================== ★★★ 修改后的 showWarningPage（不再改标题栏） ★★★ ==================
	private void showWarningPage(String errorMessage) {
		String js = "javascript:(function() { " +
			"document.querySelectorAll('.page').forEach(function(p) { p.classList.remove('active'); }); " +
			"document.getElementById('warning-page').classList.add('active'); " +
			"document.querySelector('.back-btn').style.display = 'none'; " +
			"document.querySelector('.footer').style.display = 'none'; " +
			"document.querySelector('.content').style.marginBottom = '0'; " +
			"var h2Elem = document.querySelector('#warning-page h2'); " +
			"if (h2Elem) h2Elem.textContent = '" + escapeJS(errorMessage) + "'; " +
			"var pElem = document.querySelector('#warning-page p'); " +
			"if (pElem) pElem.textContent = ''; " +
			"setTimeout(function() { " +
			"    document.querySelector('.nav-item[data-target=\"home-page\"]').click(); " +
			"}, 3000); " +
			"})();";
		evaluateJS(js);
		
		if (errorMessage != null && !errorMessage.equals("没有正在展示的消息窗口")) {
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					new AlertDialog.Builder(MainActivity.this)
						.setTitle("发生错误")
						.setMessage(errorMessage)
						.setPositiveButton("确定", null)
						.setCancelable(false)
						.create()
						.show();
				}
			});
		}
		
		new Handler().postDelayed(new Runnable() {
			@Override
			public void run() {
				resetCommunicationState();
			}
		}, 500);
	}
	
	// ================== ★★★ 修改后的 showFailurePage（不再改标题栏） ★★★ ==================
	private void showFailurePage(String pageId, String errorMessage) {
		String js = "javascript:(function() { " +
			"document.querySelectorAll('.page').forEach(function(p) { p.classList.remove('active'); }); " +
			"document.getElementById('" + pageId + "').classList.add('active'); " +
			"document.querySelector('.back-btn').style.display = 'none'; " +
			"document.querySelector('.footer').style.display = 'none'; " +
			"document.querySelector('.content').style.marginBottom = '0'; " +
			"var pElem = document.querySelector('#" + pageId + " p'); " +
			"if (pElem) pElem.textContent = ''; " +
			"setTimeout(function() { " +
			"    document.querySelector('.nav-item[data-target=\"home-page\"]').click(); " +
			"}, 3000); " +
			"})();";
		evaluateJS(js);
		
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				new AlertDialog.Builder(MainActivity.this)
					.setTitle("来自接收端的错误")
					.setMessage(errorMessage)
					.setPositiveButton("确定", null)
					.setCancelable(false)
					.create()
					.show();
			}
		});
		
		new Handler().postDelayed(new Runnable() {
			@Override
			public void run() {
				resetCommunicationState();
			}
		}, 500);
	}
	
	private void returnToHomePage() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				evaluateJS("javascript:document.querySelector('.nav-item[data-target=\"home-page\"]').click();");
			}
		});
	}
	
	private String escapeJS(String s) {
		if (s == null) return "";
		return s.replace("\\", "\\\\")
			.replace("'", "\\'")
			.replace("\"", "\\\"")
			.replace("\n", "\\n")
			.replace("\r", "\\r");
	}
	
	// ================== JavaScript 接口 ==================
	public class AndroidInterface {
		
		@JavascriptInterface
		public String sendUdpMessage(String ipAddress, int port, String jsonData) {
			Log.d(TAG, "sendUdpMessage 被调用: " + ipAddress + ":" + port);
			Log.d(TAG, "JSON数据: " + jsonData);
			
			try {
				JSONObject json = new JSONObject(jsonData);
				String type = json.optString("type", "");
				String requestID = json.optString("requestID", "");
				
				if (requestID.isEmpty()) {
					requestID = UUID.randomUUID().toString();
					json.put("requestID", requestID);
					jsonData = json.toString();
				}
				
				String actionType;
				if ("close".equals(type)) {
					actionType = "end";
				} else if ("cmd".equals(type)) {
					actionType = "cmd";
				} else {
					actionType = "send";
				}
				
				int targetPort = port;
				if (targetPort <= 0) {
					if ("cmd".equals(type)) {
						String permission = json.optString("permission", "USER");
						targetPort = "SYSTEM".equals(permission) ? PORT_SYSTEM_CMD : PORT_MESSAGE;
					} else {
						targetPort = PORT_MESSAGE;
					}
				}
				
				Log.d(TAG, "动作类型: " + actionType + ", 目标端口: " + targetPort);
				
				doSendUdpMessage(ipAddress, targetPort, jsonData, requestID, actionType);
				
				return "SUCCESS";
				
			} catch (JSONException e) {
				Log.e(TAG, "解析JSON失败", e);
				return "ERROR: JSON格式错误 - " + e.getMessage();
			} catch (Exception e) {
				Log.e(TAG, "发送失败", e);
				return "ERROR: " + e.getMessage();
			}
		}
		
		@JavascriptInterface
		public String getLocalIP() {
			return getLocalIPAddress();
		}
		
		@JavascriptInterface
		public String getAndCheckLocalIP() {
			String ip = getLocalIPAddress();
			if ("未知".equals(ip) || ip.isEmpty()) {
				return "ERROR: 未知IP";
			}
			return ip;
		}
		
		@JavascriptInterface
		public void onBackButtonHandled() {
			Log.d(TAG, "网页已处理返回键事件");
		}
		
		@JavascriptInterface
		public void setThemeMode(String theme) {
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
			return isSystemInDarkMode() ? "dark" : "light";
		}
		
		@JavascriptInterface
		public void openUrl(String url) {
			Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(intent);
		}
		
		@JavascriptInterface
		public String checkUpdate() {
			try {
				VersionInfo info = fetchVersionInfo();
				if (info == null) {
					return "{\"success\":false,\"error\":\"获取版本信息失败\"}";
				}
				
				boolean hasUpdate = isNewerVersion(info.latestVersion);
				String updateLevel = "normal";
				
				if (hasUpdate) {
					String[] latestParts = info.latestVersion.split("\\.");
					String[] currentParts = currentVersion.split("\\.");
					int latestMajor = Integer.parseInt(latestParts[0]);
					int currentMajor = Integer.parseInt(currentParts[0]);
					if (latestMajor > currentMajor) {
						updateLevel = "major";
					} else {
						int latestMinor = latestParts.length > 1 ? Integer.parseInt(latestParts[1]) : 0;
						int currentMinor = currentParts.length > 1 ? Integer.parseInt(currentParts[1]) : 0;
						if (latestMinor > currentMinor) {
							updateLevel = "normal";
						} else {
							updateLevel = "minor";
						}
					}
				}
				
				return "{" +
					"\"success\":true," +
					"\"hasUpdate\":" + hasUpdate + "," +
					"\"latestVersion\":\"" + escapeJson(info.latestVersion) + "\"," +
					"\"currentVersion\":\"" + currentVersion + "\"," +
					"\"releaseNotes\":\"" + escapeJson(info.releaseNotes) + "\"," +
					"\"downloadUrl\":\"" + info.downloadUrl + "\"," +
					"\"publishDate\":\"" + escapeJson(info.publishDate) + "\"," +
					"\"updateLevel\":\"" + updateLevel + "\"" +
					"}";
				
			} catch (Exception e) {
				Log.e(TAG, "检查更新失败", e);
				return "{\"success\":false,\"error\":\"" + escapeJson(e.getMessage()) + "\"}";
			}
		}
		
		@JavascriptInterface
		public void showToast(String message) {
			runOnUiThread(new Runnable() {
				@Override
				public void run() {
					Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT).show();
				}
			});
		}
		
		@JavascriptInterface
		public void downloadApkSilent(String downloadUrl) {
			Log.d(TAG, "收到静默下载请求: " + downloadUrl);
			silentDownloadApk(downloadUrl);
		}
		
		@JavascriptInterface
		public void downloadWithBrowser(String url) {
			Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
			intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(intent);
		}
		
		private String escapeJson(String s) {
			if (s == null) return "";
			return s.replace("\\", "\\\\")
				.replace("\"", "\\\"")
				.replace("\n", "\\n")
				.replace("\r", "\\r")
				.replace("\t", "\\t");
		}
	}
	
	// ================== 获取本机IP ==================
	private String getLocalIPAddress() {
		try {
			Enumeration<NetworkInterface> networkInterfaces = NetworkInterface.getNetworkInterfaces();
			while (networkInterfaces.hasMoreElements()) {
				NetworkInterface ni = networkInterfaces.nextElement();
				Enumeration<InetAddress> inetAddresses = ni.getInetAddresses();
				while (inetAddresses.hasMoreElements()) {
					InetAddress addr = inetAddresses.nextElement();
					if (!addr.isLoopbackAddress() && addr instanceof Inet4Address) {
						return addr.getHostAddress();
					}
				}
			}
			return "未知";
		} catch (Exception e) {
			Log.e(TAG, "获取本机IP失败", e);
			return "未知";
		}
	}
	
	// ================== 版本更新相关 ==================
	private class VersionInfo {
		String latestVersion;
		String releaseNotes;
		String downloadUrl;
		String publishDate;
		
		VersionInfo(String v, String notes, String url, String date) {
			latestVersion = v;
			releaseNotes = notes;
			downloadUrl = url;
			publishDate = date;
		}
	}
	
	private VersionInfo fetchVersionInfo() throws Exception {
		HttpURLConnection conn = null;
		BufferedReader reader = null;
		try {
			URL url = new URL(VERSION_URL);
			conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setConnectTimeout(5000);
			conn.setReadTimeout(5000);
			conn.setRequestProperty("User-Agent", "RemoteControl-Android/" + currentVersion);
			
			if (conn.getResponseCode() != 200) {
				throw new Exception("HTTP " + conn.getResponseCode());
			}
			
			reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
			StringBuilder sb = new StringBuilder();
			String line;
			while ((line = reader.readLine()) != null) {
				sb.append(line);
			}
			
			String json = sb.toString();
			String androidVersion = extractJsonValue(json, "android_version");
			String androidNotes = extractJsonValue(json, "android_notes");
			String androidDate = extractJsonValue(json, "android_date");
			String downloadUrl = extractJsonValue(json, "android");
			
			return new VersionInfo(androidVersion, androidNotes, downloadUrl, androidDate);
			
		} finally {
			if (reader != null) reader.close();
			if (conn != null) conn.disconnect();
		}
	}
	
	private String extractJsonValue(String json, String key) {
		String pattern = "\"" + key + "\"\\s*:\\s*\"([^\"]*)\"";
		java.util.regex.Pattern p = java.util.regex.Pattern.compile(pattern);
		java.util.regex.Matcher m = p.matcher(json);
		return m.find() ? m.group(1) : "";
	}
	
	private boolean isNewerVersion(String latestVersion) {
		try {
			String[] current = currentVersion.split("\\.");
			String[] latest = latestVersion.split("\\.");
			for (int i = 0; i < Math.max(current.length, latest.length); i++) {
				int c = i < current.length ? Integer.parseInt(current[i]) : 0;
				int l = i < latest.length ? Integer.parseInt(latest[i]) : 0;
				if (l > c) return true;
				if (l < c) return false;
			}
			return false;
		} catch (Exception e) {
			return false;
		}
	}
	
	// ================== 获取更新级别（和 PC 端一致） ==================
	private int getVersionLevel(String currentVer, String newVer) {
		try {
			String[] currentParts = currentVer.split("\\.");
			String[] newParts = newVer.split("\\.");
			
			int currMajor = Integer.parseInt(currentParts[0]);
			int currMinor = Integer.parseInt(currentParts[1]);
			int currRev = Integer.parseInt(currentParts[2]);
			
			int newMajor = Integer.parseInt(newParts[0]);
			int newMinor = Integer.parseInt(newParts[1]);
			int newRev = Integer.parseInt(newParts[2]);
			
			if (newMajor > currMajor) {
				return 1; // 大版本（架构层面升级）
			} else if (newMinor > currMinor) {
				return 2; // 中版本（功能更新）
			} else if (newRev > currRev) {
				return 3; // 小版本（补丁修复）
			}
			return 3;
		} catch (Exception e) {
			return 3;
		}
	}
	
	// ================== 自动检查更新（和 PC 端 HandleUpdateCheck 一致） ==================
	private void checkForUpdateSilent() {
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					VersionInfo info = fetchVersionInfo();
					if (info == null) {
						Log.d(TAG, "获取版本信息失败");
						return;
					}
					
					if (!isNewerVersion(info.latestVersion)) {
						Log.d(TAG, "当前已是最新版本");
						return;
					}
					
					int updateLevel = getVersionLevel(currentVersion, info.latestVersion);
					Log.d(TAG, "发现新版本: " + info.latestVersion + ", 更新级别: " + updateLevel);
					
					boolean shouldShowDialog = false;
					
					switch (updateLevel) {
						case 1: // 大版本 → 始终弹窗
							shouldShowDialog = true;
							break;
							
						case 2: { // 中版本 → 启动次数 ≥ 8 才弹窗
							SharedPreferences prefs = getSharedPreferences("update_prefs", MODE_PRIVATE);
							int startupCount = prefs.getInt("startup_count", 0);
							Log.d(TAG, "中版本更新，当前启动次数: " + startupCount);
							if (startupCount >= 8) {
								shouldShowDialog = true;
								prefs.edit().putInt("startup_count", 0).apply();
								Log.d(TAG, "启动次数达到阈值，弹窗并重置计数");
							}
							break;
						}
							
						case 3: // 小版本 → 不自动弹窗
							shouldShowDialog = false;
							break;
					}
					
					// ★★★ 先保存到缓存，准备通知红点 ★★★
					synchronized (MainActivity.this) {
						pendingVersionInfo = info;
					}
					
					if (shouldShowDialog) {
						// ★★★ 弹窗和红点都显示 ★★★
						runOnUiThread(new Runnable() {
							@Override
							public void run() {
								// 先通知红点（如果页面已加载）
								notifyPendingUpdateIfReady();
								
								// ★★★ 调用 HTML 的 showCustomUpdateDialog 弹窗 ★★★
								String updateLevelStr = (updateLevel == 1) ? "major" : "normal";
								boolean isMajorUpdate = (updateLevel == 1);
								
								String jsonData = String.format(
									"{" +
									"\"latestVersion\":\"%s\"," +
									"\"currentVersion\":\"%s\"," +
									"\"releaseNotes\":\"%s\"," +
									"\"downloadUrl\":\"%s\"," +
									"\"publishDate\":\"%s\"," +
									"\"isMajorUpdate\":%b," +
									"\"updateLevel\":\"%s\"" +
									"}",
									escapeJson(info.latestVersion),
									currentVersion,
									escapeJson(info.releaseNotes != null ? info.releaseNotes : ""),
									info.downloadUrl != null ? info.downloadUrl : "",
									escapeJson(info.publishDate != null ? info.publishDate : ""),
									isMajorUpdate,
									updateLevelStr
								);
								
								Log.d(TAG, "调用 HTML 弹窗: " + jsonData);
								evaluateJS("javascript:if(window.showCustomUpdateDialog) { showCustomUpdateDialog(" + jsonData + "); }");
							}
						});
					} else {
						// ★★★ 只显示红点 ★★★
						runOnUiThread(new Runnable() {
							@Override
							public void run() {
								notifyPendingUpdateIfReady();
							}
						});
					}
					
				} catch (Exception e) {
					Log.d(TAG, "自动检查更新失败: " + e.getMessage());
				}
			}
		}).start();
	}
	
	// ================== 待处理更新通知 ==================
	private void notifyPendingUpdateIfReady() {
		if (!isPageLoaded) {
			Log.d(TAG, "页面未加载完成，等待 onPageFinished");
			return;
		}
		
		VersionInfo info = null;
		synchronized (this) {
			if (pendingVersionInfo != null) {
				info = pendingVersionInfo;
				pendingVersionInfo = null;
			}
		}
		
		if (info != null) {
			Log.d(TAG, "通知 WebView 显示红点: " + info.latestVersion);
			notifyWebViewOfNewVersion(info);
		}
	}
	
	private void notifyWebViewOfNewVersion(VersionInfo info) {
		String json = String.format(
			"{\"hasNewVersion\":true,\"latestVersion\":\"%s\",\"updateLevel\":\"normal\"}",
			escapeJson(info.latestVersion)
		);
		evaluateJS("javascript:if(window.onNewVersionDetected) { onNewVersionDetected(" + json + "); }");
	}
	
	private String escapeJson(String s) {
		if (s == null) return "";
		return s.replace("\\", "\\\\")
			.replace("\"", "\\\"")
			.replace("\n", "\\n")
			.replace("\r", "\\r")
			.replace("\t", "\\t");
	}
	
	// ================== 静默下载 ==================
	private void silentDownloadApk(String downloadUrl) {
		if (isDownloading) {
			runOnUiThread(() -> Toast.makeText(MainActivity.this, "正在下载更新包，请稍后", Toast.LENGTH_SHORT).show());
			return;
		}
		
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
			if (!getPackageManager().canRequestPackageInstalls()) {
				runOnUiThread(() -> {
					Toast.makeText(MainActivity.this, "请先开启应用安装权限", Toast.LENGTH_SHORT).show();
					Intent intent = new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES);
					intent.setData(Uri.parse("package:" + getPackageName()));
					startActivity(intent);
				});
				return;
			}
		}
		
		runOnUiThread(() -> Toast.makeText(MainActivity.this, "开始下载更新包", Toast.LENGTH_SHORT).show());
		isDownloading = true;
		
		new Thread(() -> {
			HttpURLConnection conn = null;
			InputStream input = null;
			FileOutputStream output = null;
			
			try {
				File downloadDir = new File(getExternalFilesDir(null), "downloads");
				if (!downloadDir.exists()) downloadDir.mkdirs();
				
				final File apkFile = new File(downloadDir, "remote_control_update.apk");
				if (apkFile.exists()) apkFile.delete();
				
				URL url = new URL(downloadUrl);
				conn = (HttpURLConnection) url.openConnection();
				conn.setConnectTimeout(15000);
				conn.setReadTimeout(15000);
				conn.setRequestMethod("GET");
				
				if (conn.getResponseCode() != HttpURLConnection.HTTP_OK) {
					throw new Exception("服务器错误: " + conn.getResponseCode());
				}
				
				input = conn.getInputStream();
				output = new FileOutputStream(apkFile);
				
				byte[] buffer = new byte[4096];
				int bytesRead;
				while ((bytesRead = input.read(buffer)) != -1) {
					output.write(buffer, 0, bytesRead);
				}
				output.flush();
				
				runOnUiThread(() -> {
					Toast.makeText(MainActivity.this, "下载完成，准备安装", Toast.LENGTH_SHORT).show();
					installApk(apkFile);
				});
				
				isDownloading = false;
				
			} catch (final Exception e) {
				Log.e(TAG, "下载失败", e);
				runOnUiThread(() -> Toast.makeText(MainActivity.this, "下载失败，请重试", Toast.LENGTH_SHORT).show());
				isDownloading = false;
			} finally {
				try { if (input != null) input.close(); } catch (IOException e) {}
				try { if (output != null) output.close(); } catch (IOException e) {}
				if (conn != null) conn.disconnect();
			}
		}).start();
	}
	
	private void installApk(File apkFile) {
		try {
			Uri apkUri = FileProvider.getUriForFile(this, getPackageName() + ".fileprovider", apkFile);
			Intent installIntent = new Intent(Intent.ACTION_VIEW);
			installIntent.setDataAndType(apkUri, "application/vnd.android.package-archive");
			installIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
			installIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
			startActivity(installIntent);
		} catch (Exception e) {
			Log.e(TAG, "安装失败", e);
			new AlertDialog.Builder(MainActivity.this)
				.setTitle("自动安装更新失败")
				.setMessage("新版安装包已保存至：\n" + apkFile.getAbsolutePath() +
					"\n\n请使用系统文件管理器手动安装")
				.setPositiveButton("去手动安装", (dialog, which) -> {
					try {
						Uri dirUri = FileProvider.getUriForFile(MainActivity.this,
							getPackageName() + ".fileprovider", apkFile.getParentFile());
						Intent intent = new Intent(Intent.ACTION_VIEW);
						intent.setDataAndType(dirUri, "resource/folder");
						intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
						startActivity(intent);
					} catch (Exception ex) {
						Toast.makeText(MainActivity.this, "请使用文件管理器导航至：\n" + apkFile.getParent(), Toast.LENGTH_LONG).show();
					}
				})
				.setNegativeButton("取消", null)
				.show();
		}
	}
	
	// ================== 主题管理 ==================
	private void applyInitialTheme() {
		currentTheme = isSystemInDarkMode() ? "dark" : "light";
		applyAndroidTheme(currentTheme);
	}
	
	private boolean isSystemInDarkMode() {
		return (getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK)
			== Configuration.UI_MODE_NIGHT_YES;
	}
	
	private void notifyWebViewOfSystemTheme() {
		evaluateJS("javascript:if(window.handleSystemThemeChange){handleSystemThemeChange('" + currentTheme + "');}");
	}
	
	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		boolean isDark = (newConfig.uiMode & Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES;
		String newTheme = isDark ? "dark" : "light";
		if (!newTheme.equals(currentTheme)) {
			currentTheme = newTheme;
			runOnUiThread(() -> applyAndroidTheme(currentTheme));
			notifyWebViewOfSystemTheme();
		}
	}
	
	private void applyAndroidTheme(String theme) {
		if ("dark".equals(theme)) {
			applyDarkTheme();
		} else {
			applyLightTheme();
		}
		currentTheme = theme;
	}
	
	private void applyDarkTheme() {
		try {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
				getWindow().setStatusBarColor(Color.parseColor("#121212"));
				getWindow().setNavigationBarColor(Color.parseColor("#121212"));
			}
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				int flags = getWindow().getDecorView().getSystemUiVisibility();
				flags |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
				getWindow().getDecorView().setSystemUiVisibility(flags);
			}
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				int flags = getWindow().getDecorView().getSystemUiVisibility();
				flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
				getWindow().getDecorView().setSystemUiVisibility(flags);
			}
			webView.setBackgroundColor(Color.parseColor("#121212"));
		} catch (Exception e) {
			Log.e(TAG, "应用深色主题失败", e);
		}
	}
	
	private void applyLightTheme() {
		try {
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
				getWindow().setStatusBarColor(Color.parseColor("#3700B3"));
				getWindow().setNavigationBarColor(Color.WHITE);
			}
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
				int flags = getWindow().getDecorView().getSystemUiVisibility();
				flags &= ~View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
				getWindow().getDecorView().setSystemUiVisibility(flags);
			}
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				int flags = getWindow().getDecorView().getSystemUiVisibility();
				flags &= ~View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
				getWindow().getDecorView().setSystemUiVisibility(flags);
			}
			webView.setBackgroundColor(Color.WHITE);
		} catch (Exception e) {
			Log.e(TAG, "应用浅色主题失败", e);
		}
	}
	
	// ================== 返回键处理 ==================
	@Override
	public void onBackPressed() {
		if (webView.canGoBack()) {
			webView.goBack();
		} else {
			sendBackButtonEventToWeb();
		}
	}
	
	private void sendBackButtonEventToWeb() {
		String javascriptCode = "javascript:if(window.handleBackButton){window.handleBackButton();}else{window.androidBackButtonDefault();}";
		
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
			webView.evaluateJavascript(javascriptCode, new ValueCallback<String>() {
				@Override
				public void onReceiveValue(String value) {
					if ("false".equals(value) || value == null) {
						performDefaultBackAction();
					}
				}
			});
		} else {
			webView.loadUrl(javascriptCode);
			new Handler().postDelayed(new Runnable() {
				@Override
				public void run() {
					performDefaultBackAction();
				}
			}, 1000);
		}
	}
	
	private void performDefaultBackAction() {
		long currentTime = System.currentTimeMillis();
		
		if (currentTime - lastBackPressTime > 2000) {
			if (backPressToast != null) {
				backPressToast.cancel();
			}
			backPressToast = Toast.makeText(MainActivity.this, "再按一次退出应用", Toast.LENGTH_SHORT);
			backPressToast.show();
			lastBackPressTime = currentTime;
		} else {
			if (backPressToast != null) {
				backPressToast.cancel();
			}
			finish();
		}
	}
	
	// ================== 生命周期清理 ==================
	@Override
	protected void onDestroy() {
		super.onDestroy();
		stopTimeoutTimer();
		stopReceiving();
		if (udpSocket != null && !udpSocket.isClosed()) {
			udpSocket.close();
		}
	}
}