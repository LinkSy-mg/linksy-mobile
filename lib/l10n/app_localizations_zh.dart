// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => '欢迎使用 Linksy';

  @override
  String get onboardingChooseLanguage => '选择语言';

  @override
  String get onboardingLanguageHint => '之后可以在“设置”中更改。';

  @override
  String get onboardingContinue => '继续';

  @override
  String get onboardingSetUpTitle => '设置 Linksy';

  @override
  String get onboardingSetUpSubtitle => '选择 Linksy 可以做什么。除非你同意，任何内容都不会离开这部手机。';

  @override
  String get onboardingNotifications => '通知';

  @override
  String get onboardingNotificationsDetail =>
      '文件送达时，以及电脑使用你的屏幕、相机或麦克风时通知你，并提供停止按钮。';

  @override
  String get onboardingCamera => '相机';

  @override
  String get onboardingCameraDetail => '扫描配对二维码；经你允许后，电脑还能把它用作摄像头。';

  @override
  String get onboardingAway => '离家时';

  @override
  String get onboardingAwayDetail => '不在同一 Wi-Fi 时，也能通过互联网连接你的电脑。端到端加密。';

  @override
  String get onboardingBackground => '在后台保持运行';

  @override
  String get onboardingBackgroundDetail => 'Linksy 关闭后，文件和来电功能仍可使用。会显示一条安静的通知。';

  @override
  String get onboardingFolder => '与电脑共享文件夹';

  @override
  String get onboardingFolderDetail => '你的电脑可以在其“文件”应用中打开你选择的一个文件夹。';

  @override
  String get onboardingPhotos => '照片备份文件夹';

  @override
  String get onboardingPhotosDetail => '选择相机文件夹，把新照片备份到电脑。可按电脑分别开启。';

  @override
  String get onboardingLocate => '允许电脑定位这部手机';

  @override
  String get onboardingLocateDetail => '电脑可以询问一次这部手机的位置。不会保留任何记录。';

  @override
  String get onboardingAllow => '允许';

  @override
  String get onboardingAllowed => '已允许';

  @override
  String get onboardingChooseFolder => '选择';

  @override
  String onboardingFolderChosen(String folder) {
    return '“$folder”';
  }

  @override
  String get onboardingAnytime => '这些选项都可以随时在“设置”中开启或关闭。';

  @override
  String get onboardingStart => '开始使用 Linksy';

  @override
  String get onboardingBack => '返回';

  @override
  String get settingsLanguage => '语言';

  @override
  String get languageDone => '完成';

  @override
  String get ctlClipboardFileTooBig => '剪贴板只能放下不超过 10 MB 的文件。';

  @override
  String get ctlClipboardCopyFailed => '无法放到剪贴板';

  @override
  String get ctlLocateOff => '这部手机上的 Linksy 已关闭定位';

  @override
  String get ctlYourComputer => '你的电脑';

  @override
  String get ctlAnd => '和';

  @override
  String ctlKeepingLocked(String names) {
    return '你离开时，$names 将保持锁定';
  }

  @override
  String get ctlStayingConnected => '正与你的电脑保持连接';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name 想给你发送 $count 个文件',
      one: '$name 想给你发送一个文件',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => '剪贴板是空的。';

  @override
  String get ctlClipboardTooMuch => '剪贴板中的文字太多，无法发送。';

  @override
  String get ctlPing => '提醒';

  @override
  String ctlPingFrom(String name) {
    return '来自 $name';
  }

  @override
  String get ctlTextTooMuch => '文字太多，无法发送。';

  @override
  String get ctlDeclined => '已拒绝';

  @override
  String get ctlScreenPermission => '共享屏幕需要 Android 授予录屏权限。';

  @override
  String get ctlCameraPermission => 'Linksy 需要相机权限才能用作摄像头。';

  @override
  String get ctlMicrophonePermission => 'Linksy 需要麦克风权限才能用作麦克风。';

  @override
  String get ctlTerminalTitle => '终端';

  @override
  String get errorThatDevice => '该设备';

  @override
  String get errorOtherDevice => '对方设备';

  @override
  String get errorComputerOnCable => '数据线连接的电脑';

  @override
  String errorDeviceAt(String address) {
    return '位于 $address 的设备';
  }

  @override
  String errorUnreachable(String name) {
    return '无法连接 $name。请确认它已开机并在此网络中。';
  }

  @override
  String errorDeclined(String name) {
    return '$name 已拒绝。';
  }

  @override
  String errorTimeout(String name) {
    return '$name 未及时响应。';
  }

  @override
  String errorNotPaired(String name) {
    return '$name 已不再配对。请重新配对后再共享。';
  }

  @override
  String errorUnsupported(String name) {
    return '$name 暂时还不支持此操作。';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name 仅允许在同一网络中这样做。它的主人可以为这部手机开启“离家时允许全部功能”。';
  }

  @override
  String get errorInvalid => '操作未成功。';

  @override
  String get errorSomethingWrong => '出了点问题。';

  @override
  String errorSomethingWrongDetail(String detail) {
    return '出了点问题：$detail';
  }

  @override
  String get terminalRefusedComputer => '电脑';

  @override
  String get terminalRefusedCode => '代码错误。';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '代码错误，还剩 $count 次机会。',
      one: '代码错误，还剩 1 次机会。',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return '错误次数过多。请在 $name 上解锁终端。';
  }

  @override
  String terminalRefusedOff(String name) {
    return '请在 $name 上打开这部手机的页面，并在那里允许终端。';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name 仅允许在同一网络中打开终端，除非在那里开启了“离家时允许全部功能”。';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name 无法打开终端。';
  }

  @override
  String terminalRefusedLimit(String name) {
    return '$name 上已为这部手机运行了 8 个终端。请先关闭一个。';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name 未允许。';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$os $kind';
  }

  @override
  String get modelKindDesktop => '台式机';

  @override
  String get modelKindLaptop => '笔记本电脑';

  @override
  String get modelKindPhone => '手机';

  @override
  String get modelKindTablet => '平板';

  @override
  String get modelOsUnknown => '未知';

  @override
  String get deviceNothingOfKind => '暂无此类内容。';

  @override
  String deviceBattery(int level) {
    return '$level%';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level%，充电中';
  }

  @override
  String deviceReachableUntil(String day) {
    return '离家时可连接，直到 $day';
  }

  @override
  String get deviceLocksWhenLeave => '你带着这部手机离开时会锁定';

  @override
  String get deviceBack => '返回';

  @override
  String get deviceMore => '更多';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => '更换图片';

  @override
  String get deviceAddPicture => '添加图片';

  @override
  String get deviceRemovePicture => '移除图片';

  @override
  String get deviceForgetThis => '忘记此设备';

  @override
  String deviceForgetTitle(String name) {
    return '忘记 $name？';
  }

  @override
  String get deviceForgetBody => '要再与它共享，需要重新配对。它在这部手机上的活动记录也会被清除。';

  @override
  String get deviceForget => '忘记';

  @override
  String get deviceCancel => '取消';

  @override
  String get deviceSendFiles => '发送文件';

  @override
  String get deviceSendFilesCaption => '照片、文档，什么都行';

  @override
  String get deviceClipboard => '剪贴板';

  @override
  String get deviceClipboardCaption => '发送你复制的内容';

  @override
  String get devicePing => '提醒';

  @override
  String get devicePingCaption => '让它响一声';

  @override
  String get deviceRemote => '遥控';

  @override
  String get deviceRemoteCaption => '触控板和幻灯片';

  @override
  String get deviceRinging => '正在响铃…';

  @override
  String get deviceFindIt => '查找';

  @override
  String get deviceTapToStop => '轻点停止';

  @override
  String get deviceFindItCaption => '让它大声响铃';

  @override
  String get devicePrevious => '上一首';

  @override
  String get devicePause => '暂停';

  @override
  String get devicePlay => '播放';

  @override
  String get deviceNext => '下一首';

  @override
  String deviceAllowOn(String name) {
    return '请在 $name 上允许…';
  }

  @override
  String get deviceSeeScreen => '查看它的屏幕';

  @override
  String get deviceSeeScreenCaption => '在这里观看，或用触控操作它';

  @override
  String get deviceWatch => '观看';

  @override
  String get deviceControl => '控制';

  @override
  String get deviceTerminal => '终端';

  @override
  String deviceTerminalShell(String name) {
    return '$name 上的 Shell，由其代码保护';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已打开 $count 个终端',
      one: '已打开 1 个终端',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => '全部';

  @override
  String get deviceFilterFiles => '文件';

  @override
  String get deviceFilterClipboard => '剪贴板';

  @override
  String get deviceFilterLinks => '链接';

  @override
  String get deviceFilterShowAll => '显示全部';

  @override
  String get deviceFilterShowFiles => '显示文件';

  @override
  String get deviceFilterShowClipboard => '显示剪贴板';

  @override
  String get deviceFilterShowLinks => '显示链接';

  @override
  String get deviceActivity => '活动';

  @override
  String deviceReadyWhenAsks(String name) {
    return '$name 请求时即可使用';
  }

  @override
  String get deviceWebcam => '摄像头';

  @override
  String get deviceInUseNow => '正在使用';

  @override
  String get deviceControls => '控制项';

  @override
  String get deviceMicrophone => '麦克风';

  @override
  String get deviceStop => '停止';

  @override
  String get deviceSecondDisplay => '第二屏幕';

  @override
  String get deviceShowingNow => '正在显示';

  @override
  String deviceReadySize(int width, int height) {
    return '就绪 · $width × $height';
  }

  @override
  String get devicePhoneAs => '把这部手机用作';

  @override
  String deviceStartedOn(String name) {
    return '在 $name 上启动';
  }

  @override
  String get deviceFasterOverUsb => '用 USB 数据线连接更快、更稳定。';

  @override
  String get deviceBackUpPhotos => '备份照片';

  @override
  String devicePhotosGoTo(String name) {
    return '新照片会存入 $name 的“图片”文件夹';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name 不接收照片。请在那里开启“从手机导入照片”。';
  }

  @override
  String devicePhotosFrom(String folder) {
    return '来自 $folder';
  }

  @override
  String get devicePhotosFromCamera => '来自你的相机文件夹';

  @override
  String devicePhotosLast(String time) {
    return '上次 $time';
  }

  @override
  String get deviceGetClipboard => '获取它的剪贴板';

  @override
  String deviceGetClipboardDetail(String name) {
    return '连接期间，在 $name 上复制的文字会出现在这里';
  }

  @override
  String get deviceAwayAll => '离家时允许全部功能';

  @override
  String get deviceAwayAllOn => '离家时也可使用：本机屏幕、摄像头、麦克风和文件';

  @override
  String get deviceAwayAllOff => '离家时仅限：剪贴板、链接、文件和响铃';

  @override
  String get deviceNothingShared => '还没有共享任何内容';

  @override
  String deviceNothingSharedBody(String name) {
    return '这部手机与 $name 之间的文件、剪贴板文字和提醒会显示在这里。';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
      one: '1 项',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '“$text”';
  }

  @override
  String get activityClipboardText => '剪贴板文字';

  @override
  String get activityPing => '提醒';

  @override
  String get activityYourScreen => '你的屏幕';

  @override
  String get activityYourCamera => '你的相机';

  @override
  String get activitySecondDisplay => '第二屏幕';

  @override
  String get activityLink => '链接';

  @override
  String get activityRangThisPhone => '让这部手机响铃';

  @override
  String get activityRangIt => '让它响铃';

  @override
  String get activityTouchpadKeyboard => '触控板和键盘';

  @override
  String get activityItsScreen => '它的屏幕';

  @override
  String get activityYourMicrophone => '你的麦克风';

  @override
  String get activityWhereThisPhone => '这部手机的位置';

  @override
  String get activityWatchingNow => '正在观看';

  @override
  String get activityWatched => '已观看';

  @override
  String get activityInUseWebcam => '正用作摄像头';

  @override
  String get activityUsedWebcam => '曾用作摄像头';

  @override
  String get activityBeingControlled => '正在被控制';

  @override
  String get activityWatchedControlled => '已观看并控制';

  @override
  String get activityWatchedFromPhone => '从这部手机观看';

  @override
  String get activityInUseNow => '正在使用';

  @override
  String get activityWasTouchpad => '这部手机曾是它的触控板';

  @override
  String get activityWasSecondDisplay => '这部手机曾是它的第二屏幕';

  @override
  String get activityLinkReceived => '收到链接';

  @override
  String get activityOpenedOnComputer => '已在电脑上打开';

  @override
  String get activityInUseMicrophone => '正用作麦克风';

  @override
  String get activityUsedMicrophone => '曾用作麦克风';

  @override
  String get activityNotTold => '未告知';

  @override
  String get activityToldWhere => '已告知这部手机的位置';

  @override
  String get activityAskedToFind => '请求查找这部手机';

  @override
  String get activityToFindIt => '用于查找它';

  @override
  String get activityDeclined => '已拒绝';

  @override
  String get activityFailed => '失败';

  @override
  String get activityInProgress => '进行中';

  @override
  String get activityCopiedHere => '已复制到本机';

  @override
  String get activityReceived => '已接收';

  @override
  String get activitySent => '已发送';

  @override
  String get activityStop => '停止';

  @override
  String get activityCancel => '取消';

  @override
  String get activityCopyAgain => '再次复制';

  @override
  String get activityCopied => '已复制';

  @override
  String get activityCopyLink => '复制链接';

  @override
  String get activityLinkCopied => '链接已复制';

  @override
  String get activityNoAppForLink => '此设备上没有能打开该链接的应用。';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个文件',
      one: '1 个文件',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name 已不在原处。';
  }

  @override
  String activityNoAppForFile(String name) {
    return '这部手机上没有能打开 $name 的应用。';
  }

  @override
  String get activityWaitingForYou => '等待你接受…';

  @override
  String get activityWaitingForDevice => '等待设备接受…';

  @override
  String activityWaitingFor(String name) {
    return '等待 $name 接受…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get homeSettings => '设置';

  @override
  String get homeYourDevices => '你的设备';

  @override
  String get homeNearbyNotPaired => '附近，未配对';

  @override
  String get homeAddDevice => '添加设备';

  @override
  String homeVisible(String name) {
    return '$name 在此 Wi-Fi 中可被发现';
  }

  @override
  String get homeUpdateTitle => '更新 Linksy 以保持连接';

  @override
  String get homeUpdateBody => '你的电脑使用的 Linksy 比此应用更新。';

  @override
  String get homeGetUpdate => '获取更新';

  @override
  String get homeSendFiles => '发送文件';

  @override
  String get homePair => '配对';

  @override
  String get homeStepOpen => '在电脑上打开 Linksy';

  @override
  String get homeStepChoose => '选择“添加设备”';

  @override
  String get homeStepScan => '用这部手机扫描';

  @override
  String get homeConnectTitle => '连接你的\n第一台设备';

  @override
  String get homeConnectSubtitle => '直接通过你的 Wi-Fi。无需账号，无需云端。';

  @override
  String get homeScanQr => '扫描二维码';

  @override
  String get homePairByAddress => '改用地址配对';

  @override
  String get pairingAddDevice => '添加设备';

  @override
  String get pairingAddDeviceHint => '在另一台设备上打开 Linksy，然后选择“添加设备”。';

  @override
  String get pairingScanQr => '扫描二维码';

  @override
  String get pairingScanQrCaption => '最快，无需输入。';

  @override
  String get pairingByAddress => '通过地址配对';

  @override
  String get pairingByAddressCaption => '找不到另一台设备时使用。';

  @override
  String pairingWith(String name) {
    return '正在与 $name 配对…';
  }

  @override
  String get pairingWithOtherDevice => '正在与另一台设备配对…';

  @override
  String get pairingAddressHint => '可在另一台设备上 Linksy 的“偏好设置”中找到。';

  @override
  String pairingPortHint(String port) {
    return '默认端口为 $port，除非你另行填写。';
  }

  @override
  String get pairingPair => '配对';

  @override
  String pairingWantsToPair(String name) {
    return '$name 请求配对';
  }

  @override
  String pairingPairWith(String name) {
    return '与 $name 配对';
  }

  @override
  String get pairingCodeHint => '两个屏幕上应显示相同的代码。';

  @override
  String pairingCodeLabel(String code) {
    return '代码 $code';
  }

  @override
  String get pairingCodesMatch => '代码一致';

  @override
  String get scanNeedsCamera => 'Linksy 需要相机来扫描配对码。请允许使用，或通过地址配对。';

  @override
  String get scanCameraUnavailable => '相机不可用。';

  @override
  String get scanFlashlight => '手电筒';

  @override
  String get scanTitle => '扫描代码';

  @override
  String get scanWrongCode => '这不是 Linksy 代码。请在电脑上打开 Linksy → 用二维码配对。';

  @override
  String get scanHint => '在电脑上打开 Linksy，然后选择“添加设备”。';

  @override
  String get shareSheetPutOnClipboard => '放到剪贴板';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '发送 $count 个文件',
      one: '发送 1 个文件',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => '在电脑上打开';

  @override
  String get shareSheetSendToClipboard => '发送到剪贴板';

  @override
  String get shareSheetNoClipboardFiles => '你的电脑都还不支持把文件放到剪贴板。请在电脑上更新 Linksy。';

  @override
  String get shareSheetNoComputers => '先配对一台电脑，然后就能从任意应用分享给它。';

  @override
  String get shareSheetSendFileInstead => '改为发送文件';

  @override
  String get shareSheetClipboardInstead => '改为放到电脑的剪贴板';

  @override
  String get shareSheetOpenLinkInstead => '改为打开链接';

  @override
  String get shareSheetSendAsTextInstead => '改为以文字发送到剪贴板';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return '正在放到 $name 的剪贴板';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed => '正在放到电脑的剪贴板';

  @override
  String shareSheetOpened(String name) {
    return '已在 $name 上打开';
  }

  @override
  String get shareSheetOpenedUnnamed => '已在电脑上打开';

  @override
  String shareSheetSentToClipboard(String name) {
    return '已发送到 $name 的剪贴板';
  }

  @override
  String get shareSheetSentToClipboardUnnamed => '已发送到电脑的剪贴板';

  @override
  String shareSheetSentALink(String name) {
    return '$name 发来一个链接';
  }

  @override
  String get shareSheetOpen => '打开';

  @override
  String get shareSheetCopyLink => '复制链接';

  @override
  String get shareSheetLinkCopied => '链接已复制';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' $count 个文件',
      one: ' 1 个文件',
    );
    return '$name 正在向你发送$_temp0';
  }

  @override
  String incomingTotal(String size) {
    return '共 $size';
  }

  @override
  String incomingMore(int count) {
    return '+ 另外 $count 个';
  }

  @override
  String get incomingAccept => '接受';

  @override
  String get appInvalidPairingLink => '该配对链接无效。';

  @override
  String appPairingFailed(String reason) {
    return '配对失败：$reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return '无法与 $name 配对：$reason';
  }

  @override
  String appPairedWith(String name) {
    return '已与 $name 配对';
  }

  @override
  String appNotification(String name, String text) {
    return '$name：$text';
  }

  @override
  String appCopiedText(String name) {
    return '已复制来自 $name 的文字';
  }

  @override
  String appCopiedFile(String file, String name) {
    return '已复制来自 $name 的 $file';
  }

  @override
  String get appCouldntStart => 'Linksy 无法启动';

  @override
  String get commonDismiss => '关闭';

  @override
  String get commonCancel => '取消';

  @override
  String get commonDecline => '拒绝';

  @override
  String get commonClose => '关闭';

  @override
  String get commonNotNow => '以后再说';

  @override
  String get commonConnected => '已连接';

  @override
  String get commonNearby => '在附近';

  @override
  String get commonNotNearby => '不在附近';

  @override
  String get commonUsbCable => 'USB 数据线';

  @override
  String get commonAwayFromHome => '离家时';

  @override
  String get commonSameWifi => '同一 Wi-Fi';

  @override
  String get commonConnectedByUsb => '已通过 USB 连接';

  @override
  String get commonConnectedAway => '已远程连接';

  @override
  String commonBattery(int level) {
    return '电量百分之 $level';
  }

  @override
  String commonBatteryCharging(int level) {
    return '电量百分之 $level，充电中';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 字节',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还剩 $count 秒',
      one: '还剩 1 秒',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还剩 $count 分钟',
      one: '还剩 1 分钟',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还剩约 $count 小时',
      one: '还剩约 1 小时',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => '今天';

  @override
  String get formatYesterday => '昨天';

  @override
  String get formatPhone => '手机';

  @override
  String get settingsBack => '返回';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsSearch => '搜索设置';

  @override
  String settingsNothingMatches(String query) {
    return '没有与“$query”匹配的设置';
  }

  @override
  String get settingsRecommended => '推荐';

  @override
  String get settingsReceiving => '接收';

  @override
  String get settingsFiles => '文件';

  @override
  String get settingsSaveLocation => '保存位置';

  @override
  String settingsSaveLocationUse(String path) {
    return '使用 $path';
  }

  @override
  String get settingsSaveLocationPath => '下载 › Linksy';

  @override
  String get settingsAcceptFromMyDevices => '自动接受我的设备';

  @override
  String get settingsAcceptFromMyDevicesCaption => '来自已配对设备的文件无需确认即可接收。';

  @override
  String get settingsConnection => '连接';

  @override
  String get settingsWays => '它如何连接你的电脑';

  @override
  String get settingsStayConnected => '保持连接';

  @override
  String get settingsStayConnectedCaption => '与附近设备共享更快，但更耗电。';

  @override
  String get settingsKeepRunning => '在后台保持运行';

  @override
  String get settingsKeepRunningCaption =>
      'Linksy 关闭后，文件、照片备份和来电功能仍可使用。会显示一条安静的通知。';

  @override
  String get settingsAwayFromHome => '离家时';

  @override
  String get settingsAwayFromHomeCaption =>
      '不在同一网络时，也能通过互联网连接你的电脑，有效期为最后一次同网后的一周。端到端加密。';

  @override
  String get settingsRelay => '中继服务器';

  @override
  String get settingsRelayDefault => 'Linksy 自带';

  @override
  String get settingsRelayCaption =>
      '你自己托管的中继地址，例如 https://relay.example.com。留空则使用 Linksy 的中继。请在每台设备上设置相同的中继。';

  @override
  String get settingsWithYourComputers => '与你的电脑';

  @override
  String get settingsPauseMusic => '通话时暂停音乐';

  @override
  String get settingsPauseMusicCaption => '来电响铃或通话期间，你的电脑会暂停正在播放的内容，结束后继续播放。';

  @override
  String get settingsBrowseFiles => '允许电脑浏览文件';

  @override
  String get settingsFilesFolder => '你选择的文件夹';

  @override
  String get settingsFilesAll => '所有文件';

  @override
  String get settingsFilesAllCaption => '你的电脑可以打开这部手机上的所有文件。';

  @override
  String get settingsFilesAllAllow => '在 Android 设置中允许 Linksy“访问所有文件”。';

  @override
  String get settingsBrowseFilesChoose =>
      '选择一个电脑可以在“文件”应用中打开的文件夹，例如“文档”（Android 不允许选择“下载”）。';

  @override
  String settingsSharesFolder(String folder) {
    return '正在共享“$folder”。轻点可选择其他文件夹。';
  }

  @override
  String get settingsPicture => '这部手机的图片';

  @override
  String get settingsPictureChoose => '你的电脑会用它代表这部手机。轻点选择一张。';

  @override
  String get settingsPictureChange => '你的电脑会用它代表这部手机。轻点更换。';

  @override
  String get settingsPictureRemove => '移除';

  @override
  String get settingsLocate => '允许电脑定位这部手机';

  @override
  String get settingsLocateCaption =>
      '电脑可以询问一次这部手机的位置来找到它。不会保留或追踪任何信息。Linksy 打开时可用。';

  @override
  String get settingsLocatePermission => 'Linksy 需要位置权限才能使用此功能。';

  @override
  String get settingsPhotoFolder => '照片文件夹';

  @override
  String get settingsPhotoFolderChoose => '选择你的相机文件夹（DCIM › Camera），把照片备份到电脑。';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return '正在备份“$folder”。请在每台电脑的页面上分别开启。';
  }

  @override
  String get settingsThisApp => '本应用';

  @override
  String get settingsPermissions => '权限';

  @override
  String get settingsDemo => '演示';

  @override
  String get settingsDemoCaption => '连接 Linksy 核心前的模拟设备。这些操作会模拟另一台设备发起的动作。';

  @override
  String get settingsDemoReceiveFiles => '接收文件';

  @override
  String get settingsDemoReceivePairing => '接收配对请求';

  @override
  String get settingsDemoReceiveClipboard => '接收剪贴板文字';

  @override
  String get settingsTagline => '你的设备，互相连接。\n无需账号，无需云端。';

  @override
  String get settingsNameTitle => '为这部手机命名';

  @override
  String get settingsNameCaption => '你的其他设备会看到这个名称。';

  @override
  String get settingsSave => '保存';

  @override
  String get settingsCancel => '取消';

  @override
  String settingsRename(String name) {
    return '重命名 $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return '这部手机 · $shortId';
  }

  @override
  String get settingsPermissionsRow => '通知和相机';

  @override
  String get settingsPermissionsWhat => 'Linksy 向 Android 申请哪些权限，以及原因。';

  @override
  String get settingsPermissionsBoth => '均已允许。';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已允许 $count/2 项。轻点允许其余权限。',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => '权限';

  @override
  String get permissionsIntro => 'Linksy 只申请必要的权限，你之后可以在“设置”中更改任何一项。';

  @override
  String get permissionsNotifications => '通知';

  @override
  String get permissionsNotificationsWhy => '电脑查看你的屏幕或使用你的相机时会显示通知，并提供停止按钮。';

  @override
  String get permissionsCamera => '相机';

  @override
  String get permissionsCameraWhy => '扫描配对二维码；经你允许后，电脑还能把这部手机用作摄像头。';

  @override
  String get permissionsAllow => '允许';

  @override
  String get permissionsAllowed => '已允许';

  @override
  String get permissionsDone => '完成';

  @override
  String get remoteBack => '返回';

  @override
  String get remoteTitle => '遥控';

  @override
  String remoteAllowOn(String name) {
    return '请在 $name 上允许';
  }

  @override
  String remoteAsks(String name) {
    return '$name 上的 Linksy 正在询问是否允许这部手机移动其指针并输入文字。';
  }

  @override
  String get remoteFailed => '操作未成功';

  @override
  String get remoteStopped => '遥控已停止';

  @override
  String remoteEndedBy(String name) {
    return '$name 已结束遥控。';
  }

  @override
  String get remoteTryAgain => '重试';

  @override
  String get remoteTouchpad => '触控板';

  @override
  String get remoteSlides => '幻灯片';

  @override
  String get remoteTouchpadHint => '单指移动，轻点即单击\n双指滚动，双指轻点即右键单击';

  @override
  String get remoteLeftClick => '左键';

  @override
  String get remoteRightClick => '右键';

  @override
  String get remoteKeyboard => '键盘';

  @override
  String get remoteNextSlide => '下一张幻灯片';

  @override
  String get remoteNext => '下一张';

  @override
  String get remotePreviousSlide => '上一张幻灯片';

  @override
  String get remoteSlideBack => '上一张';

  @override
  String get remoteStartShow => '开始 (F5)';

  @override
  String get remoteEndShow => '结束 (Esc)';

  @override
  String get remoteVolumeHint => '音量减：下一张 · 音量加：上一张。屏幕保持常亮。';

  @override
  String get ringTitle => '我在这儿！';

  @override
  String ringLookingFor(String name) {
    return '$name 正在寻找这部手机。';
  }

  @override
  String get ringFoundIt => '找到了';

  @override
  String get webcamBack => '返回';

  @override
  String get webcamTitle => '摄像头';

  @override
  String webcamLiveOn(String name) {
    return '正在 $name 上直播';
  }

  @override
  String get webcamStopSemantic => '停止摄像头';

  @override
  String get webcamStop => '停止';

  @override
  String get webcamBadgeLive => '直播中';

  @override
  String get webcamBadgeLock => 'AE/AF 锁定';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => '手电筒';

  @override
  String get webcamFacingFront => '前置';

  @override
  String get webcamFacingBack => '后置';

  @override
  String get webcamTorch => '手电筒';

  @override
  String get webcamPortrait => '竖屏';

  @override
  String get webcamLandscape => '横屏';

  @override
  String get webcamLocked => '已锁定';

  @override
  String get webcamLock => '锁定';

  @override
  String get webcamTabLight => '光线';

  @override
  String get webcamTabFocus => '对焦';

  @override
  String get webcamTabColor => '色彩';

  @override
  String get webcamTabStream => '视频流';

  @override
  String get webcamBrightness => '亮度';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto => '此相机会自动设置曝光。';

  @override
  String get webcamLockExposure => '锁定曝光';

  @override
  String get webcamLockExposureDetail => '保持当前亮度。按住画面可锁定到某一点。';

  @override
  String get webcamFocus => '对焦';

  @override
  String get webcamFocusFixed => '此相机为固定对焦。';

  @override
  String get webcamFocusSpotDetail => '保持在你轻点的位置。双击画面恢复自动。';

  @override
  String get webcamFocusManualDetail => '在下方手动设置。';

  @override
  String get webcamFocusAutoDetail => '跟随画面变化。轻点画面可对焦到某一点。';

  @override
  String get webcamFocusAuto => '自动';

  @override
  String get webcamFocusSpot => '定点';

  @override
  String get webcamFocusManual => '手动';

  @override
  String get webcamDistance => '距离';

  @override
  String get webcamFar => '远';

  @override
  String get webcamNear => '近';

  @override
  String get webcamWbAuto => '自动';

  @override
  String get webcamWbDaylight => '日光';

  @override
  String get webcamWbCloudy => '阴天';

  @override
  String get webcamWbShade => '阴影';

  @override
  String get webcamWbIncandescent => '暖光';

  @override
  String get webcamWbFluorescent => '办公室灯光';

  @override
  String get webcamWhiteBalance => '白平衡';

  @override
  String get webcamLockColors => '锁定色彩';

  @override
  String get webcamLockColorsDetail => '防止色彩随光线变化而偏移。';

  @override
  String get webcamOrientation => '方向';

  @override
  String get webcamOrientationPortraitDetail => '竖长的画面，两侧有黑边，适合需要竖屏画面的应用。';

  @override
  String get webcamOrientationLandscapeDetail => '填满画面并始终保持正向，无论手机如何摆放。';

  @override
  String get webcamFrameRate => '帧率';

  @override
  String get webcamFps60Detail => '动作更流畅；更耗流量和电量。';

  @override
  String get webcamFps30Detail => '视频通话稳定流畅。';

  @override
  String get webcamFpsOnly30 => '此相机最高支持 30 fps。';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => '分辨率';

  @override
  String get webcamResolution1080Detail => '全高清，适合大屏幕；流量更多。';

  @override
  String get webcamResolution720Detail => '高清，适合视频通话。';

  @override
  String get webcamResolutionOnly720 => '此相机以 720p 传输。';

  @override
  String get webcamQuality => '画质';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps，适合繁忙的 Wi-Fi。';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps，细节最丰富。';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps，视频通话足够清晰。';
  }

  @override
  String get webcamQualitySaver => '省流';

  @override
  String get webcamQualityStandard => '标准';

  @override
  String get webcamQualityHigh => '高';

  @override
  String get webcamStabilization => '防抖';

  @override
  String get webcamStabilizationDetail => '减轻手抖。';

  @override
  String get webcamMirror => '镜像预览';

  @override
  String get webcamMirrorDetail => '仅在这部手机上镜像；电脑收到的是未镜像的画面。';

  @override
  String get webcamFormat => '格式';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => '重置';

  @override
  String webcamResetSetting(String setting) {
    return '重置$setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return '缩放 $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name 想查看你的屏幕';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return '在你停止之前，这部手机屏幕上的所有内容都会显示在 $name 上。接下来 Android 会请你确认。';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name 想控制你的屏幕';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '在你停止之前，$name 可以看到这部手机的屏幕，并在上面轻点、滑动和输入。接下来 Android 会请你确认。';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name 想使用你的相机';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '在你停止之前，$name 会把这部手机的相机用作摄像头。运行期间，可在 Linksy 中调整缩放、对焦、光线、镜头和旋转。';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name 想把这部手机用作触控板';
  }

  @override
  String get sharingInputRequestDetail => '异常请求：电脑不会这样请求。请不要允许。';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name 想使用你的麦克风';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '在你停止之前，$name 能听到这部手机的麦克风，它的任何应用都可将其用作麦克风。接下来 Android 会请你确认。';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name 想把这块屏幕用作第二屏幕';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return '这部手机会全屏显示 $name 的一块屏幕。触摸即可点击和拖动；双指滚动。返回即可停止。';
  }

  @override
  String get sharingAllow => '允许';

  @override
  String get sharingDontAllow => '不允许';

  @override
  String get sharingProtectionHint =>
      '电脑上的顶栏或通知是黑的？这是 Android 的屏幕共享保护把它们隐藏了。请在“开发者选项”中开启“停用屏幕共享保护”，然后重新共享。';

  @override
  String get sharingGotIt => '知道了';

  @override
  String get sharingDeveloperOptions => '开发者选项';

  @override
  String sharingControlling(String name) {
    return '$name 正在控制你的屏幕';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name 正在使用你的相机';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name 正在使用你的麦克风';
  }

  @override
  String sharingScreenWith(String name) {
    return '正在与 $name 共享你的屏幕';
  }

  @override
  String get sharingTapForCameraControls => '轻点打开相机控制';

  @override
  String get sharingSwitchCamera => '切换相机';

  @override
  String get sharingStopSharing => '停止共享';

  @override
  String get sharingStop => '停止';

  @override
  String get sharingCameraControls => '相机控制';

  @override
  String displaySecondHint(String name) {
    return '$name 的第二屏幕 · 返回即可停止';
  }

  @override
  String displayControlHint(String name) {
    return '$name 的屏幕 · 触摸即可点击 · 返回即可停止';
  }

  @override
  String displayWatchHint(String name) {
    return '$name 的屏幕 · 返回即可停止';
  }

  @override
  String get displayChooseScreen => '选择屏幕';

  @override
  String displayChooseOn(String name) {
    return '请在 $name 上选择屏幕…';
  }

  @override
  String terminalTabClosed(String title) {
    return '“$title”已关闭';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '“$title”已在 $name 上结束';
  }

  @override
  String get terminalCloseTitle => '关闭此终端？';

  @override
  String terminalCloseDetail(String name) {
    return 'Shell 会在 $name 上结束，其中仍在运行的内容也会一并结束。如果之后还想回来，请改为保持运行。';
  }

  @override
  String get terminalKeepRunning => '保持运行';

  @override
  String get terminalClose => '关闭';

  @override
  String get terminalTheComputer => '电脑';

  @override
  String get terminalDetached => '已分离';

  @override
  String terminalDetachedDetail(String name) {
    return '仍在 $name 上运行。重新连接即可再次查看；届时会再次要求输入代码。';
  }

  @override
  String get terminalReattach => '重新连接';

  @override
  String terminalOn(String name) {
    return '$name 上的终端';
  }

  @override
  String terminalDetachedOn(String name) {
    return '已分离 · 仍在 $name 上运行';
  }

  @override
  String terminalOpeningOn(String name) {
    return '正在 $name 上打开…';
  }

  @override
  String get terminalWaitingForCode => '等待输入代码';

  @override
  String get terminalEnded => '已结束';

  @override
  String get terminalBack => '返回';

  @override
  String get terminalTitle => '终端';

  @override
  String get terminalMenu => '终端菜单';

  @override
  String get terminalDetachMenu => '保持运行（分离）';

  @override
  String terminalCloseTab(String title) {
    return '关闭 $title';
  }

  @override
  String get terminalNew => '新建终端';

  @override
  String terminalShellOn(String name) {
    return '$name 上的 Shell';
  }

  @override
  String get terminalShellDetail =>
      '以你的身份在电脑上运行，位于你的主文件夹。每次打开时，都会要求输入在那里设置的终端代码。';

  @override
  String get terminalStillRunning => '仍在运行';

  @override
  String terminalReattachTab(String title) {
    return '重新连接 $title';
  }

  @override
  String terminalStarted(String time) {
    return '启动于 $time';
  }

  @override
  String get terminalKeyLeft => '左';

  @override
  String get terminalKeyUp => '上';

  @override
  String get terminalKeyDown => '下';

  @override
  String get terminalKeyRight => '右';

  @override
  String get terminalCodeTitle => '终端代码';

  @override
  String terminalCodeDetail(String name) {
    return '即在 $name 的“偏好设置 › 终端”中设置的代码。Linksy 从不保存它。';
  }

  @override
  String get terminalCodePassphrase => '密码短语';

  @override
  String get terminalCodeDigitsHint => '6 位或更多数字';

  @override
  String get terminalCodeUseDigits => '使用数字';

  @override
  String get terminalCodeUseLetters => '使用字母';

  @override
  String get terminalOpening => '正在打开…';

  @override
  String get terminalOpen => '打开终端';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsThemeSystem => '跟随系统';

  @override
  String get settingsThemeLight => '浅色';

  @override
  String get settingsThemeDark => '深色';

  @override
  String usbConnectedTo(String name) {
    return '已通过 USB 数据线连接到 $name';
  }

  @override
  String get usbConnecting => '正在通过 USB 数据线连接…';

  @override
  String get usbPairTitle => '数据线上有一台电脑';

  @override
  String get usbPairBody => '它尚未与这部手机配对。要通过数据线配对吗？两边屏幕都会显示一个代码供比对。';

  @override
  String get usbPairAction => '配对';

  @override
  String get sendPhotos => '照片和视频';

  @override
  String get sendPhotosCaption => '从相册中一次选多张';

  @override
  String get sendFiles => '文件';

  @override
  String get sendFilesCaption => '文档及其他所有文件';

  @override
  String activityPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 张照片',
    );
    return '$_temp0';
  }

  @override
  String activityVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个视频',
    );
    return '$_temp0';
  }

  @override
  String activityPhotosVideos(int count) {
    return '$count 张照片和视频';
  }

  @override
  String get transfersTitle => '传输';

  @override
  String get transfersWaiting => '等待开始';

  @override
  String transfersFilesDone(int done, int total) {
    return '$done/$total 个文件';
  }

  @override
  String transfersTo(String name) {
    return '发送到 $name';
  }

  @override
  String transfersFrom(String name) {
    return '来自 $name';
  }

  @override
  String get transfersAllDone => '全部完成';

  @override
  String transfersBubble(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个文件传输中',
    );
    return '$_temp0';
  }

  @override
  String get newsTitle => '新功能';

  @override
  String newsHeading(String version) {
    return 'Linksy $version 新功能';
  }

  @override
  String newsAllChanges(String version) {
    return '$version 的全部更改';
  }

  @override
  String get newsContinue => '继续';

  @override
  String get newsStar => '在 GitHub 上为 Linksy 点星';

  @override
  String get newsStarCaption => 'Linksy 是自由开源软件。在 GitHub 上点个星，能帮助更多人发现它。';

  @override
  String get news024PrivateTitle => '在任何网络上都不暴露';

  @override
  String get news024PrivateBody =>
      '在咖啡馆或办公室的 Wi-Fi 上，陌生人不再能看到这部手机的名称。你的电脑仍能找到它，“添加设备”会把它显示给新电脑。';

  @override
  String get news024UpdateTitle => '一键更新';

  @override
  String get news024UpdateBody => '有新版本时，“立即更新”会下载并校验它，然后由 Android 安装。';

  @override
  String get news024NewsTitle => '新功能就在这里';

  @override
  String get news024NewsBody => '每次更新后首次打开时，都会显示有哪些变化。设置里也能看到。';

  @override
  String updateAvailable(String version) {
    return 'Linksy $version 已推出';
  }

  @override
  String updateBody(String current) {
    return '当前是 $current。Linksy 会下载并校验更新，然后 Android 会请你确认安装。';
  }

  @override
  String get updateNow => '立即更新';

  @override
  String get updateLater => '稍后';

  @override
  String updateWhatChanged(String version) {
    return '$version 的更新内容';
  }

  @override
  String get updateToInstall => '将要安装';

  @override
  String updateDownloading(String percent) {
    return '正在下载，$percent%';
  }

  @override
  String get updateInstalling => 'Android 正在安装…';

  @override
  String updateNewest(String version) {
    return 'Linksy $version 已是最新版本。';
  }

  @override
  String get updateCheck => '检查更新';

  @override
  String get updateFailedNetwork => '下载未完成。请检查网络连接后重试。';

  @override
  String get updateFailedCheck => '下载的文件与该版本的校验和不符，因此没有安装。';

  @override
  String get updateAllow => '请允许 Linksy 安装应用，然后再点一次“立即更新”。';

  @override
  String updateFailedInstall(String message) {
    return 'Android 未能安装：$message';
  }

  @override
  String get settingsMediaNotice => '在通知中显示音乐';

  @override
  String get settingsMediaNoticeCaption => '电脑正在播放的内容会显示在手机通知中，并带有按钮。';

  @override
  String get settingsReverseScroll => '反向滚动';

  @override
  String get settingsReverseScrollCaption => '双指反向滚动，适用于触控板和电脑屏幕。';

  @override
  String get remoteNumbers => '数字';

  @override
  String get remoteBackspace => '删除';

  @override
  String get remoteEnter => '回车';

  @override
  String get deviceBack10 => '后退 10 秒';

  @override
  String get deviceForward10 => '前进 10 秒';

  @override
  String get news025MediaTitle => '电脑的音乐显示在通知中';

  @override
  String get news025MediaBody =>
      '正在播放的内容会显示在通知里：播放、切换、后退或前进 10 秒，以及进度条。设备页面上也有。';

  @override
  String get news025NumbersTitle => '演示遥控器上的数字';

  @override
  String get news025NumbersBody => '输入幻灯片编号再按回车即可跳转。那里也可以用键盘。';

  @override
  String get news025RemoteTitle => '更可靠的遥控';

  @override
  String get news025RemoteBody => '输入大写字母后电脑上的 Shift 不会再卡住，双指滚动也可以反向（设置）。';

  @override
  String get deviceMute => '静音';

  @override
  String get deviceUnmute => '取消静音';

  @override
  String deviceVolume(String percent) {
    return '音量 $percent%';
  }

  @override
  String get news026VolumeTitle => '电脑的音量';

  @override
  String get news026VolumeBody => '在电脑的页面上调高或调低，页面打开时也可以用这台手机的音量键。';

  @override
  String get transfersNone => '没有正在传输的文件';

  @override
  String get transfersNoneBody => '你发送或接收的文件会显示在这里，并显示速度。';

  @override
  String get transfersRecent => '最近';

  @override
  String transfersFastMovie(int seconds) {
    return '每 $seconds 秒一部 1 GB 的电影';
  }

  @override
  String transfersFastPhotos(int count) {
    return '每秒约 $count 张照片';
  }

  @override
  String transfersFastSongs(int count) {
    return '每秒 $count 首歌';
  }

  @override
  String get news026TransfersTitle => '传输随时一点即达';

  @override
  String get news026TransfersBody =>
      '左下角的按钮随时打开传输页面：文件以真实速度流动，每个文件的进度，以及最近收发的内容。';

  @override
  String get islandSeeMore => '查看更多';

  @override
  String get transfersRouteDirect => 'Wi-Fi Direct';

  @override
  String get transfersRouteDirectSetup => '正在建立 Wi-Fi Direct';

  @override
  String transfersDirectFinding(String name) {
    return '正在查找 $name';
  }

  @override
  String get transfersDirectConnecting => '正在连接';

  @override
  String get transfersDirectLinking => '正在建立链接';

  @override
  String get news028DirectTitle => '大文件走 Wi-Fi Direct';

  @override
  String get news028DirectBody =>
      '256 MB 及以上的文件通过专属 Wi-Fi 连接直接传到电脑，比经过路由器快得多。电脑需要 Linksy 0.9.9。';

  @override
  String get news028BackgroundTitle => '大文件，后台传输';

  @override
  String get news028BackgroundBody => '长视频立即开始发送，熄屏时传输也会继续，进度显示在通知栏中。';

  @override
  String get settingsDirect => '大文件使用 Wi-Fi Direct';

  @override
  String get settingsDirectCaption => '更快，直接传到另一台设备。关闭：始终通过你的 Wi-Fi。';

  @override
  String get settingsLogs => '日志';

  @override
  String get settingsLogsCaption => '最近发生的事，用于报告问题';

  @override
  String get logsPrivacy => '日志只保存在这台手机上，不会发送到任何地方：报告问题时请自行复制。';

  @override
  String get logsThisPhone => '这台手机';

  @override
  String get logsEvents => '发生了什么';

  @override
  String get logsCopy => '复制';

  @override
  String get logsCopied => '已复制';

  @override
  String get logsEmpty => '暂无内容。连接、传输和 Wi-Fi Direct 步骤会显示在这里。';

  @override
  String get news029PhonesTitle => '手机之间的 Wi-Fi Direct';

  @override
  String get news029PhonesBody =>
      '两台手机之间的大文件现在直接传输，不经过路由器。两台都需要 Linksy 0.2.9。可以在设置中关闭。';

  @override
  String get news029LogsTitle => '日志';

  @override
  String get news029LogsBody =>
      '设置 › 日志显示这台手机的信息和最近发生的事，可复制到问题报告中。日志只保存在这台手机上。';

  @override
  String pairingUpdateOlder(String name) {
    return '更新 $name 上的 Linksy，配对会更安全。';
  }

  @override
  String get settingsPhoneNotifications => '显示这部手机的通知';

  @override
  String get settingsPhoneNotificationsCaption => '显示在你的电脑上，消息可直接回复。';

  @override
  String get settingsPhoneNotificationsAllow => 'Android 还没有允许。点按以允许通知使用权。';

  @override
  String get noticeAccessTitle => '允许通知使用权';

  @override
  String get noticeAccessGreyed => '对于从网页安装的应用，Android 会将此开关变灰。要允许它：';

  @override
  String get noticeAccessStepInfo => '打开 Linksy 的应用信息。';

  @override
  String get noticeAccessStepRestricted => '点按右上角的 ⋮，然后点按“允许受限制的设置”。';

  @override
  String get noticeAccessStepAgain => '再次打开“通知使用权”并开启 Linksy。';

  @override
  String get noticeAccessPlain => '在 Android 的“通知使用权”中开启 Linksy，然后返回。';

  @override
  String get commonOpenAppInfo => '打开应用信息';

  @override
  String get batteryGuide => '让 Linksy 保持运行';

  @override
  String batteryGuideCaption(String maker) {
    return '这部 $maker 手机需要更改的设置';
  }

  @override
  String batteryIntro(String maker) {
    return '为了省电，有些手机会关闭后台应用，Linksy 就会漏收文件和通知。在这部 $maker 手机上：';
  }

  @override
  String get batteryAutostart => '应用信息 › 自启动：开启。';

  @override
  String get batteryXiaomiSaver => '应用信息 › 省电策略：无限制。';

  @override
  String get batteryLockRecents => '在最近任务中，长按 Linksy 并点按锁，这样清理时它会继续运行。';

  @override
  String get batterySamsungUnrestricted => '应用信息 › 电池：不受限制。';

  @override
  String get batterySamsungSleeping =>
      '设置 › 电池 › 后台使用限制：把 Linksy 移出休眠应用和深度休眠应用。';

  @override
  String get batteryOppoBackground => '应用信息 › 耗电管理：允许后台运行、前台运行和自动启动。';

  @override
  String get batteryVivoBackground => '设置 › 电池 › 后台耗电管理：允许 Linksy。';

  @override
  String get batteryHuaweiLaunch =>
      '设置 › 电池 › 应用启动管理 › Linksy：手动管理，开启自动启动、关联启动和后台活动。';

  @override
  String get batteryUnrestricted => '应用信息 › 应用的电池用量：无限制。';

  @override
  String get batteryKeepRunning => '在 Linksy 中：设置 › 连接 › 在后台保持运行。';

  @override
  String get batteryNames => '不同版本的 Android 中名称会略有不同。';

  @override
  String get updatePlayProtect =>
      'Linksy 可以在你的电脑上显示通知，因此 Play 保护机制可能会阻止安装。如果出现这种情况：';

  @override
  String get updateProtectStep1 => 'Play 商店 › 你的头像 › Play 保护机制 › ⚙。';

  @override
  String get updateProtectStep2 => '关闭“使用 Play 保护机制扫描应用”。';

  @override
  String get updateProtectStep3 => '再次点按“立即更新”，然后重新开启扫描。';

  @override
  String get news032NotificationsTitle => '在电脑上查看你的通知';

  @override
  String get news032NotificationsBody =>
      '消息和其他通知会显示在已配对的电脑上，并可直接回复。在 设置 › 与你的电脑 中开启。如果 Android 将开关变灰：应用信息 › ⋮ › 允许受限制的设置。';

  @override
  String get news032BatteryTitle => '让 Linksy 保持运行';

  @override
  String get news032BatteryBody =>
      '设置 › 连接 › 让 Linksy 保持运行 会按你的手机品牌说明需要更改的设置，让 Linksy 在后台继续运行。';

  @override
  String get settingsReduceMotion => '减少动态效果';

  @override
  String get settingsReduceMotionCaption => '页面淡入而不滑动，按钮变淡而不缩小。';

  @override
  String get deviceDeck => '控制面板';

  @override
  String deviceDeckCaption(String name) {
    return '你为 $name 设置的按钮';
  }

  @override
  String get deckEdit => '编辑';

  @override
  String get deckDone => '完成';

  @override
  String deckAsking(String name) {
    return '正在询问 $name 控制面板可以做什么…';
  }

  @override
  String deckAway(String name) {
    return '$name 未连接。连接后控制面板即可使用。';
  }

  @override
  String deckNothingOffered(String name) {
    return '$name 还没有允许控制面板做任何事。请在电脑上的 Linksy 中开启相应操作。';
  }

  @override
  String get deckEmptyPage => '这里还没有内容。点按“编辑”，然后点按“添加”。';

  @override
  String get deckAdd => '添加';

  @override
  String get deckAddTitle => '添加到控制面板';

  @override
  String get deckUnavailable => '不可用';

  @override
  String get deckGroupMedia => '媒体';

  @override
  String get deckGroupSound => '声音';

  @override
  String get deckGroupSystem => '系统';

  @override
  String get deckGroupCommands => '命令';

  @override
  String get deckKindButton => '按钮';

  @override
  String get deckKindToggle => '开或关';

  @override
  String get deckKindSlider => '滑块';

  @override
  String get deckSize => '大小';

  @override
  String get deckSizeSmall => '小';

  @override
  String get deckSizeWide => '宽';

  @override
  String get deckSizeTall => '高';

  @override
  String get deckSizeBig => '大';

  @override
  String get deckSizeRow => '整行';

  @override
  String get deckColor => '颜色';

  @override
  String get deckIcon => '图标';

  @override
  String get deckRemove => '从控制面板移除';

  @override
  String get deckNewPage => '新页面';

  @override
  String get deckRemovePage => '移除此页面';

  @override
  String get deckMoveHint => '按住按钮并拖动即可移动。';

  @override
  String get settingsGallery => '在电脑上查看照片';

  @override
  String get settingsGalleryCaption => '你的电脑可以浏览这部手机上的照片和视频，并保存你选中的。';

  @override
  String get settingsGalleryDenied => '请在 Android 设置中允许 Linksy 查看你的照片。';

  @override
  String get deckGroupNetwork => '网络';

  @override
  String get deckGroupPower => '电源';

  @override
  String get deckThemeTitle => '主题';

  @override
  String deckThemeAsMade(String name) {
    return '与 $name 上相同';
  }

  @override
  String get deckThemesShared => '电脑上也有';

  @override
  String get deckThemesPhone => '仅限这部手机';

  @override
  String get deckThemeStock => '标准';

  @override
  String get deckThemeDots => '点阵';

  @override
  String get deckThemeEink => '墨水屏';

  @override
  String get deckThemeTerm => '终端';

  @override
  String get deckThemePixel => '像素';

  @override
  String get deckThemeSignal => 'Signal';

  @override
  String get deckThemeGlass => '玻璃';

  @override
  String get deckThemeMidnight => '午夜';

  @override
  String deckNotAvailable(String name) {
    return '$name 上不可用';
  }

  @override
  String get deckAwayShort => '未连接';

  @override
  String deckAwayNote(String name) {
    return '$name 未连接。连接后这些按钮即可使用。';
  }

  @override
  String get deckNothingPlaying => '没有正在播放的内容';

  @override
  String deckNoLayouts(String name) {
    return '$name 还没有为这部手机设置控制面板。请在电脑上的 Linksy 中创建一个。';
  }

  @override
  String get news033DeckTitle => '控制面板：电脑的按钮';

  @override
  String get news033DeckBody =>
      '播放、音量、静音、Wi-Fi 和你自己的命令，在电脑上的 Linksy 中布置，在这里使用：电脑页面 › 控制 › 控制面板。长按控制面板的名称可更换外观。需要电脑上最新版的 Linksy。';

  @override
  String get news033PhotosTitle => '在电脑上查看你的照片';

  @override
  String get news033PhotosBody =>
      '电脑的图库可以逐页浏览这部手机的照片和视频，并保存你选中的。设置 › 文件 › 在电脑上查看照片。';

  @override
  String get news033MessagesTitle => '更早的消息';

  @override
  String get news033MessagesBody => '在电脑上，对话也会显示更早的消息，通知消失后一天内仍可回复。';

  @override
  String get onboardingMessages => '在电脑上查看消息';

  @override
  String get onboardingMessagesDetail => '在电脑的收件箱中阅读并回复你的消息和通知。';

  @override
  String get onboardingGalleryDetail =>
      '在电脑的图库中浏览这部手机的照片和视频。Android 询问时，请选择“全部允许”。';

  @override
  String get homeTurnOnTitle => '在电脑上查看你的消息和照片';

  @override
  String get homeTurnOnBody => '它们会显示在电脑的收件箱和图库中。';

  @override
  String get homeTurnOnMessages => '开启消息';

  @override
  String get homeTurnOnPhotos => '开启照片';

  @override
  String turnOnAskMessages(String name) {
    return '$name 请求显示这部手机的消息';
  }

  @override
  String turnOnAskPhotos(String name) {
    return '$name 请求显示这部手机的照片';
  }

  @override
  String get turnOnNow => '开启';

  @override
  String get settingsDemoAsk => '电脑将在 4 秒后请求';

  @override
  String get noticeAccessStepSwitch =>
      '打开“通知使用权”并开启 Linksy。如果开关是灰色的，也请点按一下：Android 会拒绝，之后才能进行下一步。';

  @override
  String get noticeAccessOpen => '打开通知使用权';
}
