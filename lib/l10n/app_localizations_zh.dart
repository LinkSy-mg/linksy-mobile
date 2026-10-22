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
  String get settingsReceiving => '接收';

  @override
  String get settingsSaveLocation => '保存位置';

  @override
  String get settingsSaveLocationPath => '下载 › Linksy';

  @override
  String get settingsAcceptFromMyDevices => '自动接受我的设备';

  @override
  String get settingsAcceptFromMyDevicesCaption => '来自已配对设备的文件无需确认即可接收。';

  @override
  String get settingsConnection => '连接';

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
  String get webcamOrientationPortraitDetail => '竖握手机；画面两侧会有黑边。';

  @override
  String get webcamOrientationLandscapeDetail => '横握手机；画面铺满。';

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
  String get usbPairTitle => '数据线上有一台电脑';

  @override
  String get usbPairBody => '它尚未与这部手机配对。要通过数据线配对吗？两边屏幕都会显示一个代码供比对。';

  @override
  String get usbPairAction => '配对';
}
