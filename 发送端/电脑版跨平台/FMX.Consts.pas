{*******************************************************}
{                                                       }
{              Delphi FireMonkey Platform               }
{                                                       }
{ Copyright(c) 2011-2025 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

unit FMX.Consts;

interface

{$SCOPEDENUMS ON}
uses
  System.Math.Vectors;

const
  StyleDescriptionName = 'Description';        // do not localize
  SMainItemStyle = 'menubaritemstyle';         // do not localize
  SSeparatorStyle = 'menuseparatorstyle';      // do not localize

  SMenuBarDisplayName = 'Menu Bar';            // do not localize
  SMenuAppDisplayName = 'Menu Application';    // do not localize

  SBMPImageExtension = '.bmp';                 // do not localize
  SJPGImageExtension = '.jpg';                 // do not localize
  SJPEGImageExtension = '.jpeg';               // do not localize
  SJP2ImageExtension = '.jp2';
  SPNGImageExtension = '.png';                 // do not localize
  SGIFImageExtension = '.gif';                 // do not localize
  STIFImageExtension = '.tif';                 // do not localize
  STIFFImageExtension = '.tiff';               // do not localize
  SICOImageExtension = '.ico';                 // do not localize
  SHDPImageExtension = '.hdp';                 // do not localize
  SWMPImageExtension = '.wmp';                 // do not localize
  STGAImageExtension = '.tga';                 // do not localize
  SICNSImageExtension = '.icns';               // do not localize

  // Keys for TPlatformServices.GlobalFlags
  GlobalDisableStylusGestures: string = 'GlobalDisableStylusGestures'; // do not localize
  EnableGlassFPSWorkaround: string = 'EnableGlassFPSWorkaround'; // do not localize

  FormUseDefaultPosition: Integer = -1; // same as CW_USEDEFAULT = DWORD($80000000)
  CommandQShortCut = 4177;

resourcestring

  { Error Strings }
  SInvalidPrinterOp       = '不支持在所选打印机上执行此操作';
  SInvalidPrinter         = '所选打印机无效';
  SPrinterIndexError      = '打印机索引超出范围';
  SDeviceOnPort           = '%s 在端口 %s';
  SNoDefaultPrinter       = '当前未选择默认打印机';
  SNotPrinting            = '打印机当前未在打印';
  SPrinting               = '正在打印';
  SInvalidPrinterSettings = '打印作业设置无效';
  SInvalidPageFormat      = '页面格式设置无效';
  SCantStartPrintJob      = '无法开始打印作业';
  SCantEndPrintJob        = '无法结束打印作业';
  SCantPrintNewPage       = '无法添加页面用于打印';
  SCantSetNumCopies       = '无法更改文档副本数量';
  StrCannotFocus          = '无法聚焦此控件';
  SResultCanNotBeNil      = '函数 ''%s'' 的返回值不能为 nil';
  SKeyAcceleratorConflict = '存在快捷键冲突';

  SInvalidStyleForPlatform = '您选择的样式在您当前选定的目标平台上不可用。您可以选择自定义样式，或移除此样式书，以允许 FireMonkey 在运行时自动加载原生样式。';
  SCannotLoadStyleFromStream = '无法从流加载样式';
  SCannotLoadStyleFromRes = '无法从资源加载样式';
  SCannotLoadStyleFromFile = '无法从文件 %s 加载样式';
  SCannotChangeInLiveBinding = '使用 LiveBindings 时无法更改此属性';

  SInvalidPrinterClass    = '打印机类无效: %s';
  SPromptArrayTooShort    = '值数组的长度必须大于等于提示数组的长度';
  SPromptArrayEmpty       = '提示数组不能为空';
  SUnsupportedInputQuery  = '不支持的 InputQuery 字段';
  SInvalidColorString     = '颜色字符串无效';

  SInvalidFmxHandle = 'FMX 句柄无效: %s%.*x';
  SInvalidFmxHandleClass = '句柄无效。 [%s] 应该是 [%s] 的实例';
  SDelayRelease = '目前无法更改窗口句柄';
  SMediaGlobalError  = '无法创建媒体控件';
  SMediaFileNotSupported  = '不支持的媒体文件 %s%';
  SMediaCannotUseAutofocus = '相机无法与自动对焦协同工作。错误="%s"';
  SUnsupportedPlatformService = '不支持的平台服务: %s';
  SServiceAlreadyRegistered = '服务 %s 已注册';
  SUnsupportedOSVersion = '不支持的操作系统版本: %s';
  SUnsupportedMultiInstance = '"%s" 的实例已存在。不支持多个实例';
  SNotInstance = '未创建 "%s" 的实例';
  SFlasherNotRegistered = '未注册闪烁控件类';
  SUnsupportedInterface = '类 %0:s 不支持接口 %1:s';
  SNullException = '已处理的空异常';
  SCannotGetDeviceIDForTestAds = '无法获取设备 ID。请使用 SetTestModeDeviceID。';
  SCannotCreateTimer = '无法创建定时器: 系统错误代码=%d';

  SErrorShortCut = '未知的按键组合 %s';
  SEUseHeirs = '您只能使用类 "%s" 的继承者';

  SUnavailableMenuId = '无法创建菜单 ID。所有 ID 已被分配';

  SInvalidGestureID = '手势 ID 无效 (%d)';
  SInvalidStreamFormat = '流格式无效';
  SDuplicateGestureName = '手势名称重复: %s';
  SDuplicateRecordedGestureName = '已存在名为 %s 的录制手势';
  SControlNotFound = '未找到控件';
  SRegisteredGestureNotFound = '未找到以下注册的手势:' + sLinebreak + sLinebreak + '%s';
  SErrorLoadingFile = '加载之前保存的设置文件时出错: %s' + sLinebreak + '您要删除它吗？';
  STooManyRegisteredGestures = '注册的手势过多';
  SDuplicateRegisteredGestureName = '已存在名为 %s 的注册手势';
  SUnableToSaveSettings = '无法保存设置';
  SInvalidGestureName = '手势名称无效 (%s)';
  SOutOfRange = '值必须在 %d 和 %d 之间';

  SAddIStylusAsyncPluginError = '无法添加 IStylusAsyncPlugin: %s';
  SAddIStylusSyncPluginError = '无法添加 IStylusSyncPlugin: %s';
  SRemoveIStylusAsyncPluginError = '无法移除 IStylusAsyncPlugin: %s';
  SRemoveIStylusSyncPluginError = '无法移除 IStylusSyncPlugin: %s';
  SStylusHandleError = '无法获取或设置窗口句柄: %s';
  SStylusEnableError = '无法启用或禁用 IRealTimeStylus: %s';
  SEnableRecognizerError = '无法启用或禁用 IGestureRecognizer: %s';
  SInitialGesturePointError = '无法获取初始手势点';
  SSetStylusGestureError = '无法设置触控笔手势: %s';
  StrESingleMainMenu = '主菜单只能是单个实例';
  SMainMenuSupportsOnlyTMenuItems = '主菜单仅支持 TMenuItem 子项';

  SNoImplementation = '未找到 %s 的实现';
  SNotImplementedOnPlatform = '%s 未在此平台上实现';
  {$IFDEF ANDROID}
  SInputQueryAndroidOverloads = '在 Android 平台上，仅支持使用 TInputCloseBoxProc 或 TInputCloseBoxEvent 的重载版本';
  {$ENDIF}

  SBitmapSizeNotEqual = '在复制操作中，位图大小必须相等';
  SBitmapCannotChangeCanvasQuality = '画布已被使用时，无法更改位图画布质量。';

  SBlockingDialogs = '阻塞式对话框';

  SCannotCreateScrollContent = '无法创建 %s，因为 |CreateScrollContent| 必须返回非 nil 对象';
  SContentCannotBeNil = '呈现从 TPresentedControl 收到 nil Content。内容不能为 nil。';

  SPointInTextLayoutError = '点不在布局内';
  SCaretLineIncorrect = 'TCaretPosition.Line 值不正确';
  SCaretPosIncorrect = 'TCaretPosition.Pos 值不正确';

  SInvalidSceneUpdatingPairCall = 'IScene.DisableUpdating/IScene.EnableUpdating 调用对无效';

  SNoPlatformStyle = '未找到平台样式'; // 当完全没有平台样式时发生
  SInvalidPlatformStyle = '未找到当前平台的平台样式'; // 当有平台样式，但不是正确的时候发生
  SNoIDeviceBehaviorBehavior = '未注册必需的 IDeviceBehavior';
  SStyleResourceDoesNotExist = '样式资源不存在';

  SDialogMustBeRunInUIThread = '消息必须在主 UI 线程中显示。';
  SObjectNonMainThreadUsage = '''%s'' 在非主线程上使用';

  { Dialog Strings }
  SMsgDlgWarning = '警告';
  SMsgDlgError = '错误';
  SMsgDlgInformation = '提示';
  SMsgDlgConfirm = '确认';
  SMsgDlgYes = '是(&Y)';
  SMsgDlgNo = '否(&N)';
  SMsgDlgOK = '确定';
  SMsgDlgCancel = '取消';
  SMsgDlgHelp = '帮助(&H)';
  SMsgDlgHelpNone = '无可用帮助';
  SMsgDlgHelpHelp = '帮助';
  SMsgDlgAbort = '中止(&A)';
  SMsgDlgRetry = '重试(&R)';
  SMsgDlgIgnore = '忽略(&I)';
  SMsgDlgAll = '全部(&A)';
  SMsgDlgNoToAll = '全部否(&N)';
  SMsgDlgYesToAll = '全部是(&Y)';
  SMsgDlgClose = '关闭';

  SWindowsVistaRequired = '%s 需要 Windows Vista 或更高版本';

  SUsername = '用户名(&U)';
  SPassword = '密码(&P)';
  SDomain = '域(&D)';
  SLogin = '登录';
  SHostRequiresAuthentication = '%s 需要身份验证';

  {$IF DEFINED(MACOS) and not DEFINED(IOS)}
  SAlertCreatedReleasedInconsistency = '平台 AlertCreated/AlertReleased 不一致';
  {$ENDIF}

  { Menus }
  SMenuAppQuit = '退出 %s';
  SMenuCloseWindow = '关闭窗口';
  SMenuAppHide = '隐藏 %s';
  SMenuAppHideOthers = '隐藏其他';
  SMenuServices = '服务';
  SMenuShowAll = '显示全部';
  SMenuWindow = '窗口';
  SAppDesign = '<应用程序标题>';
  SAppDefault = '应用程序';
  SGotoTab = '转到 %s';
  SGotoNilTab = '转到 <选项卡>';
  SMediaPlayerStart = '播放';
  SMediaPlayerPause = '暂停';
  SMediaPlayerStop = '停止';
  SMediaPlayerVolume = '%3.0F %%';

  SMsgGooglePlayServicesNeedUpdating = '需要更新 Google Play 服务。请前往 Play 商店更新 Google Play 服务，然后重启应用程序。';

const
  SChrHorizontalEllipsis = Chr($2026);
{$IFDEF MACOS}
  SmkcBkSp = Chr($232B); // (NSBackspaceCharacter);
  SmkcTab = Chr($21E5); // (NSTabCharacter);
  SmkcEsc = Chr($238B);
  SmkcEnter = Chr($21A9); // (NSCarriageReturnCharacter);
  SmkcPgUp = Chr($21DE); // (NSPageUpFunctionKey);
  SmkcPgDn = Chr($21DF); // (NSPageDownFunctionKey);
  SmkcEnd = Chr($2198); // (NSEndFunctionKey);
  SmkcDel = Chr($2326); // (NSDeleteCharacter);
  SmkcHome = Chr($2196); // (NSHomeFunctionKey);
  SmkcLeft = Chr($2190); // (NSLeftArrowFunctionKey);
  SmkcUp = Chr($2191); // (NSUpArrowFunctionKey);
  SmkcRight = Chr($2192); // (NSRightArrowFunctionKey);
  SmkcDown = Chr($2193); // (NSDownArrowFunctionKey);
  SmkcNumLock = Chr($2327);
  SmkcPara = Chr($00A7);
  SmkcShift = Chr($21E7);
  SmkcCtrl = Chr($2303);
  SmkcAlt = Chr($2325);
  SmkcCmd = Chr($2318);
  // Specific keys for OSX
  SmkcBacktab= Chr($21E4);
  SmkcIbLeft= Chr($21E0);
  SmkcIbUp= Chr($21E1);
  SmkcIbRight= Chr($21E2);
  SmkcIbDown= Chr($21E3);
  SmkcIbEnter= Chr($2305);
  SmkcIbHelp= Chr($225F);
{$ELSE}
  SmkcBkSp = 'BkSp';
  SmkcTab = 'Tab';
  SmkcEsc = 'Esc';
  SmkcEnter = 'Enter';
  SmkcPgUp = 'PgUp';
  SmkcPgDn = 'PgDn';
  SmkcEnd = 'End';
  SmkcDel = 'Del';
  SmkcHome = 'Home';
  SmkcLeft = 'Left';
  SmkcUp = 'Up';
  SmkcRight = 'Right';
  SmkcDown = 'Down';
  SmkcNumLock = 'Num Lock';
  SmkcPara = 'Paragraph';
  SmkcShift = 'Shift+';
  SmkcCtrl = 'Ctrl+';
  SmkcAlt = 'Alt+';
  SmkcCmd = 'Cmd+';

  SmkcLWin = 'Left Win';
  SmkcRWin = 'Right Win';
  SmkcApps = 'Application';
  SmkcClear = 'Clear';
  SmkcScroll = 'Scroll Lock';
  SmkcCancel = 'Break';
  SmkcLShift = 'Left Shift';
  SmkcRShift = 'Right Shift';
  SmkcLControl = 'Left Ctrl';
  SmkcRControl = 'Right Ctrl';
  SmkcLMenu = 'Left Alt';
  SmkcRMenu = 'Right Alt';
  SmkcCapital = 'Caps Lock';
{$ENDIF}
  SmkcOem102 = 'Oem \';
  SmkcSpace = 'Space';
  SmkcNext = 'Next';
  SmkcBack = 'Back';
  SmkcIns = 'Ins';
  SmkcPause = 'Pause';
  SmkcCamera = 'Camera';
  SmkcBrowserBack= 'BrowserBack';
  SmkcHardwareBack= 'HardwareBack';
  SmkcNum = 'Num %s';

resourcestring
  SEditUndo = '撤销';
  SEditRedo = '重做';
  SEditCopy = '复制';
  SEditCut = '剪切';
  SEditPaste = '粘贴';
  SEditDelete = '删除';
  SEditSelectAll = '全选';

  SAseLexerTokenError = '第 %d 行错误。预期 %s，但找到标记 %s。';
  SAseLexerCharError = '第 %d 行错误。预期字符 ''%s''，但找到字符 ''%s''。';
  SAseLexerFileCorruption = '文件已损坏。';

  SAseParserWrongMaterialsNumError = '材质数量错误';
  SAseParserWrongVertexNumError = '顶点数量错误';
  SAseParserWrongNormalNumError = '法线数量错误';
  SAseParserWrongTexCoordNumError = '纹理坐标数量错误';
  SAseParserWrongVertexIdxError = '顶点索引错误';
  SAseParserWrongFacesNumError = '面数量错误';
  SAseParserWrongFacesIdxError = '面索引错误';
  SAseParserWrongTriangleMeshNumError = '三角形网格数量错误';
  SAseParserWrongTriangleMeshIdxError = '三角形网格索引错误';
  SAseParserWrongTexCoordIdxError = '纹理坐标索引错误';
  SAseParserUnexpectedKyWordError = '意外的关键字';

  SIndexDataNotFoundError = '未找到索引数据。文件已损坏。';
  SEffectIdNotFoundError = '未找到效果 ID %s。文件已损坏。';
  SMeshIdNotFoundError = '未找到网格 ID %s。文件已损坏。';
  SControllerIdNotFoundError = '未找到控制器 ID %s。文件已损坏。';

  SCannotCreateCircularDependence = '无法在组件之间创建循环依赖';
  SPropertyOutOfRange = '%s 属性超出范围';

  SPrinterDPIChangeError = '打印时无法更改活动打印机的 DPI';
  SPrinterSettingsReadError = '读取打印机设置时发生错误: %s';
  SPrinterSettingsWriteError = '写入打印机设置时发生错误: %s';

  SVAllFiles = '所有文件';
  SVBitmaps = '位图文件';
  SVIcons = '图标文件';
  SVTIFFImages = 'TIFF 图像';
  SVJPGImages = 'JPEG 图像';
  SVPNGImages = 'PNG 图像';
  SVGIFImages = 'GIF 图像';
  SVJP2Images = 'Jpeg 2000 图像';
  SVTGAImages = 'TGA 图像';
  SWMPImages = 'WMP 图像';

  SVAviFiles = 'AVI 文件';
  SVWMVFiles = 'WMV 文件';
  SVMP4Files = 'Mpeg4 文件';
  SVMOVFiles = 'QuickTime 文件';
  SVM4VFiles = 'M4V 文件';
  SVMPGFiles = 'Mpeg 文件';

  SVWMAFiles = 'Windows Media Audio 文件';
  SVMP3Files = 'Mpeg Layer 3 文件';
  SVWAVFiles = 'WAV 文件';
  SVCAFFiles = 'Apple Core Audio Format 文件';
  SV3GPFiles = '3GP 音频文件';
  SVM4AFiles = 'M4A 文件';

  SAllFilesExt = '.*';
  SDefault = '所有文件';

  StrEChangeFixed  = '无法修改 "%s" (Fixed = True)';
  StrEDupScale     = '重复的比例值 %s';
  StrOther         = '其他比例';
  StrScale1        = '正常';
  StrScale2        = '高分辨率';

  SCodecFileExtensionCannotEmpty = '无法注册位图编解码器。编解码器文件扩展名不能为空。';
  SCodecClassCannotBeNil = '无法注册位图编解码器。编解码器类不能为 nil。';
  SCodecAlreadyExists = '无法注册位图编解码器。指定文件扩展名 "%s" 的编解码器已存在。';

  SAnimatedCodecAlreadyExists = '无法注册动画编解码器。指定文件扩展名 "%s" 的动画编解码器已存在。';
  SAnimatedCodecFramesSizeNotEqual = '无法向动画编解码器添加帧。帧的大小必须相等。';

  SFilterAlreadyExists = '无法注册过滤器。具有相同名称 "%s" 的过滤器已存在。';

  { Media }

  SNoFlashError = '此设备上无闪光灯';
  SNoTorchError = '此设备上无闪光灯';

  { Pickers }
  SPickerCancel = '取消';
  SPickerDone   = '完成';
  SEditorDone   = '完成';
  SListPickerIsNotFound = '此版本的 Android 没有列表选择器的实现';
  SDateTimePickerIsNotFound = '此版本的 Android 没有日期/时间选择器的实现';

  { Notification Center }
  SNotificationCancel = '取消';
  SNotificationCenterTitleIsNotSupported = '通知中心：iOS 不支持标题';
  SNotificationCenterActionIsNotSupported = '通知中心：Android 不支持操作';

  { Media Library }
  STakePhotoFromCamera = '拍照';
  STakePhotoFromLibarary = '从相册选择';
  SOpenStandartServices = '打开至';
  SSavedPhotoAlbum = '已保存的相册';
  SImageSaved = '图片已保存';
  SCannotConvertBitmapToNative = '无法将 FMX 位图转换为其对应的原生格式';

  { Canvas helpers / 2D and 3D engine / GPU }
  SBitmapIncorrectSize = '位图参数大小不正确。';
  SBitmapLoadingFailed = '加载位图失败。';
  SBitmapLoadingFailedNamed = '加载位图失败 (%s)。';
  SBitmapSizeTooBig = '位图尺寸太大。';
  SInvalidCanvasParameter = 'GetParameter 调用无效。';
  SThumbnailLoadingFailed = '加载缩略图失败。';
  SThumbnailLoadingFailedNamed = '加载缩略图失败 (%s)。';
  SBitmapSavingFailed = '保存位图失败。';
  SBitmapSavingFailedNamed = '保存位图失败 (%s)。';
  SBitmapFormatUnsupported = '不支持指定的位图格式。';
  SRetrieveSurfaceDescription = '无法获取表面描述。';
  SRetrieveSurfaceContents = '无法获取表面内容。';
  SAcquireBitmapAccess = '获取位图访问权限失败。';
  SVideoCaptureFault = '视频流捕获期间发生故障。';
  SNoCaptureDeviceManager = '未找到 CaptureDeviceManager 实现';
  SAudioCaptureUnauthorized = '未授权录制音频';
  SVideoCaptureUnauthorized = '未授权录制视频';
  SInvalidCallingConditions = '调用 ''%s'' 的条件无效。';
  SInvalidRenderingConditions = '渲染 ''%s'' 的条件无效。';
  STextureSizeTooSmall = '无法为 ''%s'' 创建纹理，因为尺寸太小。';
  SCannotAcquireBitmapAccess = '无法获取 ''%s'' 的位图访问权限。';
  SCannotFindSuitablePixelFormat = '无法找到适合 ''%s'' 的像素格式。';
  SCannotFindSuitableShader = '无法找到适合 ''%s'' 的着色器。';
  SCannotDetermineDirect3DLevel = '无法确定 Direct3D 支持级别。';
  SCannotCreateDirect3D = '无法为 ''%s'' 创建 Direct3D 对象。';
  SCannotCreateD2DFactory = '无法为 ''%s'' 创建 Direct2D 工厂对象。';
  SCannotCreateDWriteFactory = '无法为 ''%s'' 创建 DirectWrite 工厂对象。';
  SCannotCreateWICImagingFactory = '无法为 ''%s'' 创建 WIC 映像工厂对象。';
  SCannotCreateRenderTarget = '无法为 ''%s'' 创建渲染目标。';
  SCannotCreateD3DDevice = '无法为 ''%s'' 创建 Direct3D 设备。';
  SCannotAcquireDXGIFactory = '无法从 Direct3D 设备为 ''%s'' 获取 DXGI 工厂。';
  SCannotResizeBuffers = '无法为 ''%s'' 调整缓冲区大小。';
  SCannotAssociateWindowHandle = '无法为 ''%s'' 关联窗口句柄。';
  SCannotRetrieveDisplayMode = '无法为 ''%s'' 获取显示模式。';
  SCannotRetrieveBufferDesc = '无法为 ''%s'' 获取缓冲区描述。';
  SCannotCreateSamplerState = '无法为 ''%s'' 创建采样器状态。';
  SCannotRetrieveSurface = '无法为 ''%s'' 获取表面。';
  SCannotCreateTexture = '无法为 ''%s'' 创建纹理。';
  SCannotUploadTexture = '无法将像素数据上传到 ''%s'' 的纹理。';
  SCannotActivateTexture = '无法激活 ''%s'' 的纹理。';
  SCannotAcquireTextureAccess = '无法获取 ''%s'' 的纹理访问权限。';
  SCannotCopyTextureResource = '无法复制纹理资源 ''%s''。';
  SCannotCreateRenderTargetView = '无法为 ''%s'' 创建渲染目标视图。';
  SCannotActivateFrameBuffers = '无法为 ''%s'' 激活帧缓冲区。';
  SCannotCreateRenderBuffers = '无法为 ''%s'' 创建渲染缓冲区。';
  SCannotRetrieveRenderBuffers = '无法为 ''%s'' 获取设备渲染缓冲区。';
  SCannotActivateRenderBuffers = '无法为 ''%s'' 激活渲染缓冲区。';
  SCannotBeginRenderingScene = '无法为 ''%s'' 开始渲染场景。';
  SCannotSyncDeviceBuffers = '无法为 ''%s'' 同步设备缓冲区。';
  SCannotUploadDeviceBuffers = '无法为 ''%s'' 上传设备缓冲区。';
  SCannotCreateDepthStencil = '无法为 ''%s'' 创建深度/模板缓冲区。';
  SCannotRetrieveDepthStencil = '无法为 ''%s'' 获取设备深度/模板缓冲区。';
  SCannotActivateDepthStencil = '无法为 ''%s'' 激活深度/模板缓冲区。';
  SCannotCreateSwapChain = '无法为 ''%s'' 创建交换链。';
  SCannotResizeSwapChain = '无法为 ''%s'' 调整交换链大小。';
  SCannotActivateSwapChain = '无法为 ''%s'' 激活交换链。';
  SCannotCreateVertexShader = '无法为 ''%s'' 创建顶点着色器。';
  SCannotCreatePixelShader = '无法为 ''%s'' 创建像素着色器。';
  SCannotCreateVertexLayout = '无法为 ''%s'' 创建顶点布局。';
  SCannotCreateVertexDeclaration = '无法为 ''%s'' 创建顶点声明。';
  SCannotCreateVertexBuffer = '无法为 ''%s'' 创建顶点缓冲区。';
  SCannotCreateIndexBuffer = '无法为 ''%s'' 创建索引缓冲区。';
  SCannotCreateShader = '无法为 ''%s'' 创建着色器。';
  SCannotFindShaderVariable = '无法找到着色器变量 ''%s''。';
  SCannotActivateShaderProgram = '无法为 ''%s'' 激活着色器程序。';
  SCannotCreateMetalContext = '无法为 ''%s'' 创建 Metal 上下文。';
  SCannotCreateOpenGLContext = '无法为 ''%s'' 创建 OpenGL 上下文。';
  SCannotCreateOpenGLContextWithCode = '无法为 ''%s'' 创建 OpenGL 上下文。错误代码: %d。';
  SCannotCreatePBufferSurfaceWithCode = '无法创建 EGL PBuffer 表面。错误代码: %d。';
  SCannotUpdateOpenGLContext = '无法为 ''%s'' 更新 OpenGL 上下文。';
  SOpenGLErrorFlag = '[OpenGL] 检查 OpenGL 错误堆栈的值返回错误: 代码=(%d, "%s")';
  SOpenGLCannotCreateDummyContext = '[OpenGL] 无法为加载扩展列表创建虚拟上下文。';
  SCannotDrawMeshObject = '无法为 ''%s'' 绘制网格对象。';
  SErrorInContextMethod = '上下文中的错误: 方法=''%s''。';
  SFeatureNotSupported = '此功能在 ''%s'' 中不受支持。';
  SErrorCompressingStream = '压缩流时出错。';
  SErrorDecompressingStream = '解压缩流时出错。';
  SErrorUnpackingShaderCode = '解包着色器代码时出错。';
  SCannotPaintOnCanvasWithoutBeginScene = '无法执行渲染。未调用 BeginScene。';
  SCannotRunDirectShowFilterGraph = '一个或多个 DirectShow 过滤器无法运行';
  SCannotCreateDirectShowCaptureFilter = '无法创建 DirectShow 捕获过滤器';

  SCannotAddFixedSize = '当 ExpandStyle 为 TExpandStyle.FixedSize 时，无法添加列或行';
  SInvalidSpan = '''%d'' 不是有效的跨度值';
  SInvalidRowIndex = '行索引 %d 超出范围';
  SInvalidColumnIndex = '列索引 %d 超出范围';
  SInvalidControlItem = 'ControlItem.Control 不能设置为所属的 GridPanel';
  SCannotDeleteColumn = '无法删除包含控件的列';
  SCannotDeleteDefColumn = '不能删除默认列';
  SCannotDeleteRow = '无法删除包含控件的行';
  SCellMember = '成员';
  SCellSizeType = '尺寸类型';
  SCellValue = '值';
  SCellAutoSize = '自动';
  SCellPercentSize = '百分比';
  SCellAbsoluteSize = '绝对';
  SCellWeightSize = '权重';
  SCellColumn = '列%d';
  SCellRow = '行%d';

  SDateTimeMax = '日期超过最大值 "%s"';
  SDateTimeMin = '日期小于最小值 "%s"';

  SDateTimePickerShowModeNotSupported = '当前平台的日期时间选择器不支持 DateTime';

  SMediaLibraryOpenImageWith = '发送图片通过：';
  SMediaLibraryOpenTextWith = '发送文本通过：';
  SMediaLibraryOpenFilesWith = '发送文件通过：';
  SMediaLibraryOpenTextAndImageWith = '发送文本/图片通过：';
  SMediaLibraryOpenTextAndFilesWith = '发送文本/文件通过：';

  SNativePresentation = '原生 %s';

  { In-App Purchase }
  SIAPNotSetup = '应用内购买组件未设置';
  SIAPNoLicenseKey = '应用内购买组件没有许可证密钥';
  SIAPPayloadVerificationFailed = '交易负载验证失败';
  SIAPAlreadyPurchased = '项目已购买';
  SIAPNotAlreadyPurchased = '无法消费尚未购买的项目';
  SIAPSetupProblem = '设置应用内计费时出现问题';
  SIAPIllegalArguments = 'IAP API 中的参数问题';
  SITunesConnectionError = '无法连接到 iTunes Store';
  SProductsRequestInProgress = '产品请求已在处理中';
  SIAPProductNotInInventory = '产品 ID %s 无效';

  { Advertising }
  SAdFailedToLoadError = '广告加载失败: %d';

  { TMultiView }
  SCannotCreatePresentation = '没有 MultiView 无法创建 Presentation';
  SDrawer = '抽屉';
  SOverlapDrawer = '重叠抽屉';
  SDockedPanel = '停靠面板';
  SPopover = '弹出框';
  SNavigationPane = '导航窗格';
  SObjectCannotBeChild = '"%0:s" 的 "%1:s" 不能是 "%1:s" 的子控件或 "%1:s" 本身';

  { Presentations }
  SWrongModelClassType = '模型不是有效的类。预期 [%s]，但收到 [%s]';
  SWrongParameter = '[%] 参数不能为 nil';
  SControlWithoutPresentation = '[%s] 没有 Presentation';
  SControlClassIsNil = 'AControlClass 不能为 nil。工厂无法生成演示名称。';
  SPresentationProxyCreateError = '无法创建模型或 PresentedControl 为 nil 的演示代理。' +
    '请使用带参数的重载版本构造函数并传递正确的值。';
  SPresentationProxyClassNotFound = '未找到演示名称 [%s] 的演示代理类';
  SPresentationProxyClassIsNil = 'APresentationProxyClass 为 nil。工厂无法使用 nil 演示代理类注册演示。';
  SPresentationProxyNameIsEmpty = 'APresentationName 为空。工厂无法使用空演示名称注册演示。';
  SPresentationAlreadyRegistered = '此演示名称 [%s] 的演示代理类 [%s] 已注册。';
  SPresentationTitleInDesignTime = '%s (%s)';
  SProxyIsNotRegisteredWarning = '尚未为类 %s 注册 TStyledPresentationProxy 的后代。' + sLineBreak +
    '可能需要将 %s 模块添加到 uses 部分';
  { TScrollBox }
  SScrollBoxOwnerWrong = '|AOwner| 应该是 TCustomPresentedScrollBox 的实例';
  SScrollBoxAniCalculations = '无法创建样式化演示，因为 CreateAniCalculations 返回了 nil。';

  { Data Model }
  SDataModelKeyEmpty = '键不能为空。数据模型无法通过空名称的键设置或获取数据。';

  { Analytics }
  SInvalidActivityTrackingAppID = '应用程序 ID 无效';
  SAppAnalyticsDefaultPrivacyMessage = '隐私声明:' + sLineBreak + sLineBreak +
    '此应用程序会匿名跟踪您的使用情况，并将其发送给我们进行分析。我们使用此分析使软件更好地为您服务。' + sLineBreak + sLineBreak +
    '此跟踪是完全匿名的。不会跟踪任何个人身份信息，并且您的任何使用情况都无法追溯到您本人。' + sLineBreak + sLineBreak +
    '请单击“是”以帮助我们改进此软件。谢谢。';
  SCustomAnalyticsCategoryMissing = 'AppAnalytics 自定义事件错误：类别不能为空。';

  { Clipboard }
  SFormatAlreadyRegistered = '自定义剪贴板格式 "%s" 已注册';
  SFormatWasNotRegistered = '自定义剪贴板格式 "%s" 未注册';
  SDoesnotSupportCustomData = '%s 不支持自定义数据';

  { Helpers }

  SCannotConvertDelphiArrayToJStringArray = '无法将 Delphi 源数组转换为 Java JString 数组。[%d] 是未支持的类型';

  { Address Book }

  // Permission
  SCannotPerformOperation = '无法执行操作。您必须使用 AddressBook.RequestPermission 请求权限';
  SCannotPerformOperationRejectedAccess = '无法执行操作。用户拒绝访问通讯录';
  SRequiredPermissionsAreAbsent = '必需的权限 [%s] 未被授予。';
  SPermissionCannotChangeDataInAddressBook = '写入权限 [WRITE_CONTACTS] 未被授予。您将无法使用通讯录进行更改';
  SPermissionCannotGetDataFromAddressBook = '读取权限 [READ_CONTACTS] 未被授予。您将无法从通讯录获取数据';
  SPermissionCannotGetAccounts = '无法读取来源，因为您的应用程序没有 [GET_ACCOUNTS] 权限';
  SUserRejectedAddressBookPermission = '用户拒绝了权限';
  SUserRejectedCaptureDevicePermission = '用户拒绝了权限';
  SPermissionsRequestHasBeenCancelled = '权限请求已被取消';
  // Common
  SCannotSaveAddressBookChanges = '无法保存通讯录中的更改。%s';
  SFieldTypeIsNotSupportedOnCurrentPlatform = '指定的字段类型 [%s] 在当前平台上不受支持';
  SCannotSaveFieldValue = '无法保存 [%s]。%s';
  SCannotGetDisplayName = '无法获取显示名称。%s';
  SCannotExtractContactID = '无法提取新联系人的 ID';
  SCannotCheckExistingDataRecord = '无法检查现有数据记录。%s';
  SCannotExtractAddresses = '无法提取地址。%s';
  SCannotExtractMessagingServices = '无法获取消息服务信息。%s';
  SCannotExtractDates = '无法获取日期。%s';
  SCannotExtractMultipleStringValue = '无法提取多个字符串值。%s';
  SCannotExtractStringValue = '无法提取字符串值。%s';
  SSocialProfilesAreNotSupported = '当前平台不支持社交资料。';
  SCannotConvertTBitmapToJBitmap = '无法保存联系人照片。TBitmap 无法转换为 JBitmap。';
  SCannotBeginNewProcessing = '在前一个处理未完成之前无法开始新的处理';
  // Sources
  SCannotFetchAllSourcesNilArg = '无法获取来源。[%s] 不能为 nil。';
  SCannotCreateSource = '无法创建联系人，请使用 AddressBook.Sources 获取您设备上所有可用的来源。';
  SCannotCreateSourceNilArg = '无法创建来源实例。[%s] 不能为 nil。';
  SCannotGetSourceNameSourceRefRefNil = '无法获取来源名称。[SourceRef] 为 nil';
  SCannotGetSourceTypeSourceRefRefNil = '无法获取来源类型。[SourceRef] 为 nil';
  // Contacts
  SCannotFetchContacts = '无法获取联系人。%s';
  SCannotFetchAllContactsWrongClassArg = '无法获取联系人。[%s] 应该是 [%s] 类的实例。';
  SCannotFetchAllContactNilArg = '无法获取联系人。[%s] 不能为 nil。';
  SCannotFetchAllGroupsFromContact = '无法获取联系人的群组。%s';
  SCannotCreateContact = '无法创建联系人。';
  SCannotCreateContactNilArg = '无法创建联系人实例。[%s] 不能为 nil。';
  SCannotCreateContactWrongClassArg = '无法创建联系人实例。[%s] 应该是 [%s] 类的实例。';
  SCannotCreateContactUseFactoryMethod = '无法创建联系人，请使用 AddressBook.CreateContact。';
  SCannotSaveContact = '无法保存联系人。%s';
  SCannotSaveContactNilArg = '无法保存联系人。[%s] 不能为 nil。';
  SCannotSaveContactWrongClassArg = '无法保存联系人。[%s] 应该是 [%s] 类的实例。';
  SCannotSaveNotModifiedContact = '当联系人未修改时，无法保存联系人';
  SCannotRemoveContact = '无法删除联系人。%s';
  SCannotRemoveContactNilArg = '无法删除联系人。[%s] 不能为 nil。';
  SCannotRemoveContactWrongClassArg = '无法删除联系人。[%s] 应该是 [%s] 类的实例。';
  // Groups
  SCannotFetchGroups = '无法获取群组。%s';
  SCannotFetchAllGroupsWrongClassArg = '无法获取群组。[%s] 应该是 [%s] 类的实例。';
  SCannotFetchAllGroupsNilArg = '无法获取群组。[%s] 不能为 nil。';
  SCannotCreateGroup = '无法创建群组实例。';
  SCannotCreateGroupNilArg = '无法创建群组实例。[%s] 不能为 nil';
  SCannotCreateGroupWrongClassArg = '无法创建群组实例。[%s] 应该是 [%s] 类的实例。';
  SCannotCreateGroupUseFactoryMethod = '无法创建群组，请使用 AddressBook.CreateGroup。';
  SCannotSaveGroup = '无法保存群组。%s';
  SCannotSaveGroupNilArg = '无法保存群组。[%s] 不能为 nil。';
  SCannotSaveGroupWrongClassArg = '无法保存群组。[%s] 应该是 [%s] 类的实例。';
  SCannotRemoveGroup = '无法删除群组。%s';
  SCannotRemoveGroupNilArg = '无法删除群组。[%s] 不能为 nil。';
  SCannotRemoveGroupWrongClassArg = '无法删除群组。[%s] 应该是 [%s] 类的实例。';
  SCannotGetGroupNameGroupRefNil = '无法获取群组名称。GroupRef 为 nil';
  SCannotSetGroupName = '无法设置群组名称。%s';
  SCannotSetGroupNameGroupRefNil = '无法设置群组名称。GroupRef 为 nil';
  // Contacts in Group
  SCannotAddContactIntoGroup = '无法将联系人添加到群组。%s';
  SCannotAddContactIntoGroupNilArg = '无法将联系人添加到群组。[%s] 不能为 nil。';
  SCannotAddContactIntoGroupWrongClassArg = '无法将联系人添加到群组。[%s] 应该是 [%s] 类的实例。';
  SCannotAddContactIntoGroupContactIsNotInAddressBook = '无法将联系人添加到群组。联系人尚未在通讯录中。';
  SCannotAddContactIntoGroupGroupIsNotInAddressBook = '无法将联系人添加到群组。群组尚未在通讯录中。';
  SCannotRemoveContactFromGroup = '无法从群组中移除联系人。%s';
  SCannotRemoveContactFromGroupNilArg = '无法从群组中移除联系人。[%s] 不能为 nil。';
  SCannotRemoveContactFromGroupWrongClassArg = '无法从群组中移除联系人。[%s] 应该是 [%s] 类的实例。';
  SCannotFetchContactInGroup = '无法获取 ID = [%d] 的群组中的联系人。%s';
  SCannotFetchContactsInGroupNilArg = '无法检索联系人列表。[%s] 不能为 nil。';

  { Address fields kinds }

  SFirstName = '名';
  SLastName = '姓';
  SMiddleName = '中间名';
  SPrefix = '前缀';
  SSuffix = '后缀';
  SNickName = '昵称';
  SFirstNamePhonetic = '名（拼音）';
  SLastNamePhonetic = '姓（拼音）';
  SMiddleNamePhonetic = '中间名（拼音）';
  SOrganization = '组织';
  SJobTitle = '职位';
  SDepartment = '部门';
  SPhoto = '照片';
  SPhotoThumbnail = '照片缩略图';
  SNote = '备注';
  SURLs = '网址';
  SEMails = '电子邮件';
  SAddresses = '地址';
  SPhones = '电话';
  SDates = '日期';
  SRelatedNames = '相关名称';
  SMessagingServices = '消息服务';
  SBirthday = '生日';
  SCreationDate = '创建日期';
  SModificationDate = '修改日期';
  SSocialProfiles = '社交资料';
  SUnknowType = '未知类型值';

  { Sources }

  SSourceLocal = '本地来源';
  SSourceExchange = 'Exchange 来源';
  SSourceExchangeGAL = 'Exchange 全局地址列表';
  SSourceMobileMe = 'MobileMe';
  SSourceLDAP = 'LDAP';
  SSourceCardDAV = 'CardDAV';
  SSourceCardDAVSearch = '可搜索的 CardDAV';

  { Label types }

  SAddressBookHomeLabel = '住宅';
  SAddressBookWorkLabel = '工作';
  SAddressBookOtherLabel = '其他';

  { Phones types }

  SPhoneMain = '主要';
  SPhoneHome = '住宅';
  SPhoneMobile = '移动电话';
  SPhoneWork = '工作';
  SPhoneFaxWork = '工作传真';
  SPhoneFaxHome = '住宅传真';
  SPhoneFaxOther = '其他传真';
  SPhonePager = '寻呼机';
  SPhoneOther = '其他';
  SPhoneCallback = '回拨';
  SPhoneCar = '车载电话';
  SPhoneCompanyMain = '公司总机';
  SPhoneISDN = 'ISDN';
  SPhoneRadio = '无线电';
  SPhoneTelex = '电传';
  SPhoneTTYTDD = 'TTY TDD';
  SPhoneWorkMobile = '工作移动电话';
  SPhoneWorkPager = '工作寻呼机';
  SPhoneAssistant = '助理';
  SPhoneIPhone = 'iPhone';

  { Dates types }

  SDateAnniversary = '纪念日';
  SDateBirthday = '生日';
  SDateOther = '其他';

  { EMails types }

  SEmailsMobile = '移动电话';

  { Urls }

  SURLHomePage = '主页';
  SURLBlog = '博客';
  SURLProfile = '个人资料';
  SURLFTP = 'FTP';

  { Related names }

  SRelationAssistant = '助理';
  SRelationBrother = '兄弟';
  SRelationChild = '子女';
  SRelationDomesticPartner = '家庭伴侣';
  SRelationFather = '父亲';
  SRelationFriend = '朋友';
  SRelationManager = '经理';
  SRelationMother = '母亲';
  SRelationParent = '父母';
  SRelationPartner = '伴侣';
  SRelationReferredBy = '推荐人';
  SRelationRelative = '亲属';
  SRelationSister = '姐妹';
  SRelationSpouse = '配偶';

  { IM Protocol names }

  SProtocolAIM = 'AIM';
  SProtocolMSN = 'MSN';
  SProtocolYahoo = 'Yahoo';
  SProtocolSkype = 'Skype';
  SProtocolQQ = 'QQ';
  SProtocolGoogleTalk = 'Google Talk';
  SProtocolICQ = 'ICQ';
  SProtocolJabber = 'Jabber';
  SProtocolNetMeeting = '网络会议';
  SProtocolFacebook = 'Facebook';
  SProtocolGaduGadu = 'Gadu Gadu';

  { Social profile }

  SSocialProfileTwitter = 'Twitter';
  SSocialProfileGameCenter = '游戏中心';
  SSocialProfileSinaWeibo = '新浪微博';
  SSocialProfileFacebook = 'Facebook';
  SSocialProfileMySpace = 'MySpace';
  SSocialProfileLinkedIn = 'LinkedIn';
  SSocialProfileFlickr = 'Flickr';

  { TListView }
  SUseItemsPropertyToSetAdapter = '使用 Items 属性设置 TAppearanceListView 适配器';

  { Control/Object Helpers }
  SCannotFindParentBySpecifiedCriteria = '无法按指定条件找到父级';

  { Firebase }
  SFireBaseInstanceIdIsNotAvailable = 'FirebaseInstanceId 服务不可用';

  { WebBrowser }
  SEdgeBrowserEngineUnavailable = 'Edge 浏览器引擎不可用';
  SEdgeBrowserEngineCreateFailed = '创建 Edge 浏览器引擎实例失败';

  { TFontManager }
  SCannotFindFontResource = '未找到字体资源：ResourceName="%s"';
  SCannotFindFontFile = '未找到字体文件：FileName="%s"';

  { Biometric Auth }
  SBiometricNotImplemented = '此平台未实现生物识别支持';
  SBiometricPromptCancelTextDefault = '取消';
  SBiometricPromptTitleTextDefault = '验证身份';
  SBiometricErrorKeyNameEmpty = '密钥名不能为空';
  SBiometricErrorCannotAuthenticate = '无法执行身份验证';
  SBiometricErrorSystemError = '发生系统错误：%s';
  SBiometricErrorNotAvailable = '生物识别不可用';
  SBiometricEnterPINToRestore = '输入 PIN 码以恢复生物识别';
  SBiometricErrorAuthenticationDenied = '身份验证被拒绝';
  SBiometricErrorTooManyAttempts = '身份验证尝试次数过多';
  SBiometricErrorSystemErrorInvalidContext = '上下文无效';
  SBiometricErrorSystemErrorCancelledBySystem = '被系统取消';

implementation

end.

