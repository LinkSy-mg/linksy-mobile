// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Linksy へようこそ';

  @override
  String get onboardingChooseLanguage => '言語を選択';

  @override
  String get onboardingLanguageHint => 'あとから設定で変更できます。';

  @override
  String get onboardingContinue => '続ける';

  @override
  String get onboardingSetUpTitle => 'Linksy の設定';

  @override
  String get onboardingSetUpSubtitle =>
      'Linksy にできることを選んでください。許可するまで、このスマートフォンから何も送信されません。';

  @override
  String get onboardingNotifications => '通知';

  @override
  String get onboardingNotificationsDetail =>
      'ファイルの受信や、コンピュータが画面・カメラ・マイクを使っているときにお知らせします。停止ボタン付きです。';

  @override
  String get onboardingCamera => 'カメラ';

  @override
  String get onboardingCameraDetail =>
      'ペアリング用の QR コードを読み取ります。許可すると、コンピュータのウェブカメラとしても使えます。';

  @override
  String get onboardingAway => '外出先から';

  @override
  String get onboardingAwayDetail =>
      '同じ Wi-Fi にいないときも、インターネット経由でコンピュータにつながります。エンドツーエンドで暗号化されます。';

  @override
  String get onboardingBackground => 'バックグラウンドで実行';

  @override
  String get onboardingBackgroundDetail =>
      'Linksy を閉じても、ファイルや通話の機能が動き続けます。控えめな通知が表示されます。';

  @override
  String get onboardingFolder => 'フォルダをコンピュータと共有';

  @override
  String get onboardingFolderDetail => '選んだフォルダを、コンピュータのファイルアプリから開けます。';

  @override
  String get onboardingPhotos => '写真のバックアップフォルダ';

  @override
  String get onboardingPhotosDetail =>
      'カメラのフォルダを選ぶと、新しい写真をコンピュータにバックアップできます。コンピュータごとにオンにします。';

  @override
  String get onboardingLocate => 'コンピュータからこのスマートフォンの位置を確認';

  @override
  String get onboardingLocateDetail =>
      'コンピュータがこのスマートフォンの場所を一度だけ確認できます。何も保存されません。';

  @override
  String get onboardingAllow => '許可';

  @override
  String get onboardingAllowed => '許可済み';

  @override
  String get onboardingChooseFolder => '選択';

  @override
  String onboardingFolderChosen(String folder) {
    return '「$folder」';
  }

  @override
  String get onboardingAnytime => 'これらはいつでも設定でオン・オフを切り替えられます。';

  @override
  String get onboardingStart => 'Linksy を使い始める';

  @override
  String get onboardingBack => '戻る';

  @override
  String get settingsLanguage => '言語';

  @override
  String get languageDone => '完了';

  @override
  String get ctlClipboardFileTooBig => 'クリップボードに入れられるファイルは 10 MB までです。';

  @override
  String get ctlClipboardCopyFailed => 'クリップボードにコピーできませんでした';

  @override
  String get ctlLocateOff => 'このスマートフォンの Linksy で位置の確認がオフになっています';

  @override
  String get ctlYourComputer => 'お使いのコンピュータ';

  @override
  String get ctlAnd => 'と';

  @override
  String ctlKeepingLocked(String names) {
    return '離れると $names をロックします';
  }

  @override
  String get ctlStayingConnected => 'コンピュータとの接続を維持しています';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name が $count 個のファイルを送ろうとしています',
      one: '$name がファイルを送ろうとしています',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'クリップボードが空です。';

  @override
  String get ctlClipboardTooMuch => 'クリップボードのテキストが多すぎて送信できません。';

  @override
  String get ctlPing => '呼び出し';

  @override
  String ctlPingFrom(String name) {
    return '$name から';
  }

  @override
  String get ctlTextTooMuch => 'テキストが多すぎて送信できません。';

  @override
  String get ctlDeclined => '拒否しました';

  @override
  String get ctlScreenPermission => '画面を共有するには、Android の画面キャプチャの許可が必要です。';

  @override
  String get ctlCameraPermission => 'ウェブカメラとして使うには、Linksy にカメラの許可が必要です。';

  @override
  String get ctlMicrophonePermission => 'マイクとして使うには、Linksy にマイクの許可が必要です。';

  @override
  String get ctlTerminalTitle => 'ターミナル';

  @override
  String get errorThatDevice => 'そのデバイス';

  @override
  String get errorOtherDevice => '相手のデバイス';

  @override
  String get errorComputerOnCable => 'ケーブルでつないだコンピュータ';

  @override
  String errorDeviceAt(String address) {
    return '$address のデバイス';
  }

  @override
  String errorUnreachable(String name) {
    return '$name に接続できません。電源が入っていて、このネットワークにつながっているか確認してください。';
  }

  @override
  String errorDeclined(String name) {
    return '$name が拒否しました。';
  }

  @override
  String errorTimeout(String name) {
    return '$name から時間内に応答がありませんでした。';
  }

  @override
  String errorNotPaired(String name) {
    return '$name とのペアリングが解除されています。共有するにはもう一度ペアリングしてください。';
  }

  @override
  String errorUnsupported(String name) {
    return '$name はまだこの機能に対応していません。';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name では、この操作は同じネットワーク上でのみ許可されています。持ち主がこのスマートフォンに「外出先からすべて許可」を設定できます。';
  }

  @override
  String get errorInvalid => 'うまくいきませんでした。';

  @override
  String get errorSomethingWrong => '問題が発生しました。';

  @override
  String errorSomethingWrongDetail(String detail) {
    return '問題が発生しました: $detail';
  }

  @override
  String get terminalRefusedComputer => 'コンピュータ';

  @override
  String get terminalRefusedCode => 'コードが違います。';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'コードが違います。残り $count 回です。',
      one: 'コードが違います。残り 1 回です。',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return '間違ったコードが多すぎます。$name でターミナルのロックを解除してください。';
  }

  @override
  String terminalRefusedOff(String name) {
    return '$name でこのスマートフォンのページを開き、ターミナルを許可してください。';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name では、「外出先からすべて許可」がオンでない限り、ターミナルは同じネットワーク上でのみ使えます。';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name ではターミナルを開けません。';
  }

  @override
  String terminalRefusedLimit(String name) {
    return '$name では、このスマートフォンのターミナルがすでに 8 個動いています。先にどれかを閉じてください。';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name で許可されませんでした。';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$os $kind';
  }

  @override
  String get modelKindDesktop => 'デスクトップ';

  @override
  String get modelKindLaptop => 'ノートパソコン';

  @override
  String get modelKindPhone => 'スマートフォン';

  @override
  String get modelKindTablet => 'タブレット';

  @override
  String get modelOsUnknown => '不明';

  @override
  String get deviceNothingOfKind => 'この種類の項目はまだありません。';

  @override
  String deviceBattery(int level) {
    return '$level%';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level%、充電中';
  }

  @override
  String deviceReachableUntil(String day) {
    return '$day まで外出先から接続可能';
  }

  @override
  String get deviceLocksWhenLeave => 'このスマートフォンを持って離れるとロックされます';

  @override
  String get deviceBack => '戻る';

  @override
  String get deviceMore => 'その他';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => '画像を変更';

  @override
  String get deviceAddPicture => '画像を追加';

  @override
  String get deviceRemovePicture => '画像を削除';

  @override
  String get deviceForgetThis => 'このデバイスの登録を解除';

  @override
  String deviceForgetTitle(String name) {
    return '$name の登録を解除しますか？';
  }

  @override
  String get deviceForgetBody =>
      '共有するには、もう一度ペアリングが必要になります。このスマートフォン上のアクティビティも消去されます。';

  @override
  String get deviceForget => '解除';

  @override
  String get deviceCancel => 'キャンセル';

  @override
  String get deviceSendFiles => 'ファイルを送信';

  @override
  String get deviceSendFilesCaption => '写真、書類、なんでも';

  @override
  String get deviceClipboard => 'クリップボード';

  @override
  String get deviceClipboardCaption => 'コピーした内容を送信';

  @override
  String get devicePing => '呼び出し';

  @override
  String get devicePingCaption => 'チャイムを鳴らす';

  @override
  String get deviceRemote => 'リモコン';

  @override
  String get deviceRemoteCaption => 'タッチパッドとスライド';

  @override
  String get deviceRinging => '鳴らしています…';

  @override
  String get deviceFindIt => '探す';

  @override
  String get deviceTapToStop => 'タップして停止';

  @override
  String get deviceFindItCaption => '大きな音で鳴らす';

  @override
  String get devicePrevious => '前へ';

  @override
  String get devicePause => '一時停止';

  @override
  String get devicePlay => '再生';

  @override
  String get deviceNext => '次へ';

  @override
  String deviceAllowOn(String name) {
    return '$name で許可してください…';
  }

  @override
  String get deviceSeeScreen => '画面を見る';

  @override
  String get deviceSeeScreenCaption => 'ここで見る、またはタッチで操作する';

  @override
  String get deviceWatch => '見る';

  @override
  String get deviceControl => '操作';

  @override
  String get deviceTerminal => 'ターミナル';

  @override
  String deviceTerminalShell(String name) {
    return '$name のシェル。コードで保護されています';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のターミナルが開いています',
      one: '1 個のターミナルが開いています',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'すべて';

  @override
  String get deviceFilterFiles => 'ファイル';

  @override
  String get deviceFilterClipboard => 'クリップボード';

  @override
  String get deviceFilterLinks => 'リンク';

  @override
  String get deviceFilterShowAll => 'すべてを表示';

  @override
  String get deviceFilterShowFiles => 'ファイルを表示';

  @override
  String get deviceFilterShowClipboard => 'クリップボードを表示';

  @override
  String get deviceFilterShowLinks => 'リンクを表示';

  @override
  String get deviceActivity => 'アクティビティ';

  @override
  String deviceReadyWhenAsks(String name) {
    return '$name からの要求を待機中';
  }

  @override
  String get deviceWebcam => 'ウェブカメラ';

  @override
  String get deviceInUseNow => '使用中';

  @override
  String get deviceControls => 'コントロール';

  @override
  String get deviceMicrophone => 'マイク';

  @override
  String get deviceStop => '停止';

  @override
  String get deviceSecondDisplay => 'セカンドディスプレイ';

  @override
  String get deviceShowingNow => '表示中';

  @override
  String deviceReadySize(int width, int height) {
    return '待機中 · $width × $height';
  }

  @override
  String get devicePhoneAs => 'このスマートフォンを使う';

  @override
  String deviceStartedOn(String name) {
    return '$name から開始します';
  }

  @override
  String get deviceFasterOverUsb => 'USB ケーブルなら、より速く安定します。';

  @override
  String get deviceBackUpPhotos => '写真をバックアップ';

  @override
  String devicePhotosGoTo(String name) {
    return '新しい写真は $name のピクチャフォルダに保存されます';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name は写真を受け付けていません。そちらで「スマートフォンから写真を取り込む」をオンにしてください。';
  }

  @override
  String devicePhotosFrom(String folder) {
    return '$folder から';
  }

  @override
  String get devicePhotosFromCamera => 'カメラのフォルダから';

  @override
  String devicePhotosLast(String time) {
    return '最終 $time';
  }

  @override
  String get deviceGetClipboard => 'クリップボードを受け取る';

  @override
  String deviceGetClipboardDetail(String name) {
    return '接続中、$name でコピーしたテキストがここに届きます';
  }

  @override
  String get deviceAwayAll => '外出先からすべて許可';

  @override
  String get deviceAwayAllOn => '外出先からも: この画面、ウェブカメラ、マイク、ファイル';

  @override
  String get deviceAwayAllOff => '外出先から: クリップボード、リンク、ファイル、呼び出しのみ';

  @override
  String get deviceNothingShared => 'まだ何も共有していません';

  @override
  String deviceNothingSharedBody(String name) {
    return 'このスマートフォンと $name の間のファイル、クリップボードのテキスト、呼び出しがここに並びます。';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
      one: '1 件',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '「$text」';
  }

  @override
  String get activityClipboardText => 'クリップボードのテキスト';

  @override
  String get activityPing => '呼び出し';

  @override
  String get activityYourScreen => 'あなたの画面';

  @override
  String get activityYourCamera => 'あなたのカメラ';

  @override
  String get activitySecondDisplay => 'セカンドディスプレイ';

  @override
  String get activityLink => 'リンク';

  @override
  String get activityRangThisPhone => 'このスマートフォンを鳴らしました';

  @override
  String get activityRangIt => '相手を鳴らしました';

  @override
  String get activityTouchpadKeyboard => 'タッチパッドとキーボード';

  @override
  String get activityItsScreen => '相手の画面';

  @override
  String get activityYourMicrophone => 'あなたのマイク';

  @override
  String get activityWhereThisPhone => 'このスマートフォンの場所';

  @override
  String get activityWatchingNow => '表示中';

  @override
  String get activityWatched => '表示しました';

  @override
  String get activityInUseWebcam => 'ウェブカメラとして使用中';

  @override
  String get activityUsedWebcam => 'ウェブカメラとして使用しました';

  @override
  String get activityBeingControlled => '操作されています';

  @override
  String get activityWatchedControlled => '表示・操作されました';

  @override
  String get activityWatchedFromPhone => 'このスマートフォンで表示しました';

  @override
  String get activityInUseNow => '使用中';

  @override
  String get activityWasTouchpad => 'このスマートフォンをタッチパッドとして使用しました';

  @override
  String get activityWasSecondDisplay => 'このスマートフォンをセカンドディスプレイとして使用しました';

  @override
  String get activityLinkReceived => 'リンクを受信しました';

  @override
  String get activityOpenedOnComputer => 'コンピュータで開きました';

  @override
  String get activityInUseMicrophone => 'マイクとして使用中';

  @override
  String get activityUsedMicrophone => 'マイクとして使用しました';

  @override
  String get activityNotTold => '伝えませんでした';

  @override
  String get activityToldWhere => 'このスマートフォンの場所を伝えました';

  @override
  String get activityAskedToFind => 'このスマートフォンを探す要求がありました';

  @override
  String get activityToFindIt => '探すため';

  @override
  String get activityDeclined => '拒否';

  @override
  String get activityFailed => '失敗';

  @override
  String get activityInProgress => '進行中';

  @override
  String get activityCopiedHere => 'ここにコピー済み';

  @override
  String get activityReceived => '受信済み';

  @override
  String get activitySent => '送信済み';

  @override
  String get activityStop => '停止';

  @override
  String get activityCancel => 'キャンセル';

  @override
  String get activityCopyAgain => 'もう一度コピー';

  @override
  String get activityCopied => 'コピーしました';

  @override
  String get activityCopyLink => 'リンクをコピー';

  @override
  String get activityLinkCopied => 'リンクをコピーしました';

  @override
  String get activityNoAppForLink => 'このリンクを開けるアプリがありません。';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のファイル',
      one: '1 個のファイル',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name はもう見つかりません。';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'このスマートフォンには $name を開けるアプリがありません。';
  }

  @override
  String get activityWaitingForYou => 'あなたの承認を待っています…';

  @override
  String get activityWaitingForDevice => 'デバイスの承認を待っています…';

  @override
  String activityWaitingFor(String name) {
    return '$name の承認を待っています…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done / $total';
  }

  @override
  String get homeSettings => '設定';

  @override
  String get homeYourDevices => 'あなたのデバイス';

  @override
  String get homeNearbyNotPaired => '近くにある未ペアリングのデバイス';

  @override
  String get homeAddDevice => 'デバイスを追加';

  @override
  String homeVisible(String name) {
    return '$name はこの Wi-Fi で表示されています';
  }

  @override
  String get homeUpdateTitle => '接続を続けるには Linksy をアップデートしてください';

  @override
  String get homeUpdateBody => 'お使いのコンピュータは、このアプリより新しい Linksy を使っています。';

  @override
  String get homeGetUpdate => 'アップデートを入手';

  @override
  String get homeSendFiles => 'ファイルを送信';

  @override
  String get homePair => 'ペアリング';

  @override
  String get homeStepOpen => 'コンピュータで Linksy を開きます';

  @override
  String get homeStepChoose => '「デバイスを追加」を選びます';

  @override
  String get homeStepScan => 'このスマートフォンで読み取ります';

  @override
  String get homeConnectTitle => '最初のデバイスを\n接続しましょう';

  @override
  String get homeConnectSubtitle => 'Wi-Fi で直接つながります。アカウントもクラウドも不要です。';

  @override
  String get homeScanQr => 'QR コードを読み取る';

  @override
  String get homePairByAddress => 'アドレスでペアリング';

  @override
  String get pairingAddDevice => 'デバイスを追加';

  @override
  String get pairingAddDeviceHint => '相手のデバイスで Linksy を開き、「デバイスを追加」を選んでください。';

  @override
  String get pairingScanQr => 'QR コードを読み取る';

  @override
  String get pairingScanQrCaption => '最速。入力は不要です。';

  @override
  String get pairingByAddress => 'アドレスでペアリング';

  @override
  String get pairingByAddressCaption => '相手のデバイスが見つからないときに。';

  @override
  String pairingWith(String name) {
    return '$name とペアリングしています…';
  }

  @override
  String get pairingWithOtherDevice => '相手のデバイスとペアリングしています…';

  @override
  String get pairingAddressHint => '相手のデバイスの Linksy の環境設定に表示されています。';

  @override
  String pairingPortHint(String port) {
    return '別のポートを追加しない限り、ポートは $port です。';
  }

  @override
  String get pairingPair => 'ペアリング';

  @override
  String pairingWantsToPair(String name) {
    return '$name がペアリングを求めています';
  }

  @override
  String pairingPairWith(String name) {
    return '$name とペアリング';
  }

  @override
  String get pairingCodeHint => '両方の画面にこのコードが表示されているはずです。';

  @override
  String pairingCodeLabel(String code) {
    return 'コード $code';
  }

  @override
  String get pairingCodesMatch => 'コードが一致';

  @override
  String get scanNeedsCamera =>
      'ペアリングコードを読み取るには、Linksy にカメラが必要です。許可するか、アドレスでペアリングしてください。';

  @override
  String get scanCameraUnavailable => 'カメラを使用できません。';

  @override
  String get scanFlashlight => 'ライト';

  @override
  String get scanTitle => 'コードを読み取る';

  @override
  String get scanWrongCode =>
      'Linksy のコードではありません。コンピュータで Linksy →「QR コードでペアリング」を開いてください。';

  @override
  String get scanHint => 'コンピュータで Linksy を開き、「デバイスを追加」を選んでください。';

  @override
  String get shareSheetPutOnClipboard => 'クリップボードに入れる';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のファイルを送信',
      one: '1 個のファイルを送信',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'コンピュータで開く';

  @override
  String get shareSheetSendToClipboard => 'クリップボードに送信';

  @override
  String get shareSheetNoClipboardFiles =>
      'クリップボードでファイルを受け取れるコンピュータがまだありません。そちらの Linksy をアップデートしてください。';

  @override
  String get shareSheetNoComputers => 'まずコンピュータとペアリングすると、どのアプリからでも共有できます。';

  @override
  String get shareSheetSendFileInstead => 'ファイルとして送信';

  @override
  String get shareSheetClipboardInstead => 'コンピュータのクリップボードに入れる';

  @override
  String get shareSheetOpenLinkInstead => 'リンクを開く';

  @override
  String get shareSheetSendAsTextInstead => 'テキストとしてクリップボードに送信';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return '$name のクリップボードに入れています';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed => 'コンピュータのクリップボードに入れています';

  @override
  String shareSheetOpened(String name) {
    return '$name で開きました';
  }

  @override
  String get shareSheetOpenedUnnamed => 'コンピュータで開きました';

  @override
  String shareSheetSentToClipboard(String name) {
    return '$name のクリップボードに送信しました';
  }

  @override
  String get shareSheetSentToClipboardUnnamed => 'コンピュータのクリップボードに送信しました';

  @override
  String shareSheetSentALink(String name) {
    return '$name からリンクが届きました';
  }

  @override
  String get shareSheetOpen => '開く';

  @override
  String get shareSheetCopyLink => 'リンクをコピー';

  @override
  String get shareSheetLinkCopied => 'リンクをコピーしました';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のファイル',
      one: '1 個のファイル',
    );
    return '$name が $_temp0を送ろうとしています';
  }

  @override
  String incomingTotal(String size) {
    return '合計 $size';
  }

  @override
  String incomingMore(int count) {
    return 'ほか $count 個';
  }

  @override
  String get incomingAccept => '受け取る';

  @override
  String get appInvalidPairingLink => 'このペアリングリンクは無効です。';

  @override
  String appPairingFailed(String reason) {
    return 'ペアリングに失敗しました: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return '$name とペアリングできませんでした: $reason';
  }

  @override
  String appPairedWith(String name) {
    return '$name とペアリングしました';
  }

  @override
  String appNotification(String name, String text) {
    return '$name: $text';
  }

  @override
  String appCopiedText(String name) {
    return '$name からテキストをコピーしました';
  }

  @override
  String appCopiedFile(String file, String name) {
    return '$name から $file をコピーしました';
  }

  @override
  String get appCouldntStart => 'Linksy を起動できませんでした';

  @override
  String get commonDismiss => '閉じる';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonDecline => '拒否';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonNotNow => '今はしない';

  @override
  String get commonConnected => '接続中';

  @override
  String get commonNearby => '近く';

  @override
  String get commonNotNearby => '近くにありません';

  @override
  String get commonUsbCable => 'USB ケーブル';

  @override
  String get commonAwayFromHome => '外出先';

  @override
  String get commonSameWifi => '同じ Wi-Fi';

  @override
  String get commonConnectedByUsb => 'USB で接続中';

  @override
  String get commonConnectedAway => '外出先から接続中';

  @override
  String commonBattery(int level) {
    return 'バッテリー $level パーセント';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'バッテリー $level パーセント、充電中';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count バイト',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '残り $count 秒',
      one: '残り 1 秒',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '残り $count 分',
      one: '残り 1 分',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '残り約 $count 時間',
      one: '残り約 1 時間',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => '今日';

  @override
  String get formatYesterday => '昨日';

  @override
  String get formatPhone => 'スマートフォン';

  @override
  String get settingsBack => '戻る';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsReceiving => '受信';

  @override
  String get settingsSaveLocation => '保存先';

  @override
  String get settingsSaveLocationPath => 'ダウンロード › Linksy';

  @override
  String get settingsAcceptFromMyDevices => '自分のデバイスから自動で受信';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'ペアリング済みのデバイスからのファイルは確認なしで届きます。';

  @override
  String get settingsConnection => '接続';

  @override
  String get settingsStayConnected => '接続を維持';

  @override
  String get settingsStayConnectedCaption =>
      '近くのデバイスとすばやく共有できます。バッテリーの消費が増えます。';

  @override
  String get settingsKeepRunning => 'バックグラウンドで実行';

  @override
  String get settingsKeepRunningCaption =>
      'Linksy を閉じても、ファイル、写真のバックアップ、通話の機能が動き続けます。控えめな通知が表示されます。';

  @override
  String get settingsAwayFromHome => '外出先から';

  @override
  String get settingsAwayFromHomeCaption =>
      '同じネットワークにいないときも、最後に同じネットワークにいてから 1 週間はインターネット経由でコンピュータにつながります。エンドツーエンドで暗号化されます。';

  @override
  String get settingsRelay => 'リレーサーバー';

  @override
  String get settingsRelayDefault => 'Linksy のリレー';

  @override
  String get settingsRelayCaption =>
      '自分で運用するリレーのアドレス（例: https://relay.example.com）。空のままなら Linksy のリレーを使います。すべてのデバイスに同じリレーを設定してください。';

  @override
  String get settingsWithYourComputers => 'コンピュータとの連携';

  @override
  String get settingsPauseMusic => '通話中は音楽を一時停止';

  @override
  String get settingsPauseMusicCaption => '着信中や通話中はコンピュータの再生を一時停止し、終わると再開します。';

  @override
  String get settingsBrowseFiles => 'コンピュータからファイルを閲覧';

  @override
  String get settingsBrowseFilesChoose =>
      'コンピュータのファイルアプリから開けるフォルダ（Documents など）を選んでください（Android では Download は選べません）。';

  @override
  String settingsSharesFolder(String folder) {
    return '「$folder」を共有中。タップして別のフォルダを選択します。';
  }

  @override
  String get settingsPicture => 'このスマートフォンの画像';

  @override
  String get settingsPictureChoose =>
      'コンピュータにこのスマートフォンの画像として表示されます。タップして選択します。';

  @override
  String get settingsPictureChange =>
      'コンピュータにこのスマートフォンの画像として表示されます。タップして変更します。';

  @override
  String get settingsPictureRemove => '削除';

  @override
  String get settingsLocate => 'コンピュータからこのスマートフォンの位置を確認';

  @override
  String get settingsLocateCaption =>
      'コンピュータが、このスマートフォンを探すために場所を一度だけ確認できます。保存や追跡は一切ありません。Linksy を開いている間に使えます。';

  @override
  String get settingsLocatePermission => 'この機能には、Linksy に位置情報の許可が必要です。';

  @override
  String get settingsPhotoFolder => '写真フォルダ';

  @override
  String get settingsPhotoFolderChoose =>
      '写真をコンピュータにバックアップするには、カメラのフォルダ（DCIM › Camera）を選んでください。';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return '「$folder」をバックアップします。各コンピュータのページでオンにしてください。';
  }

  @override
  String get settingsThisApp => 'このアプリ';

  @override
  String get settingsPermissions => '権限';

  @override
  String get settingsDemo => 'デモ';

  @override
  String get settingsDemoCaption =>
      'Linksy コアに接続するまでのシミュレーションデバイスです。ほかのデバイスが行う操作を開始します。';

  @override
  String get settingsDemoReceiveFiles => 'ファイルを受信';

  @override
  String get settingsDemoReceivePairing => 'ペアリング要求を受信';

  @override
  String get settingsDemoReceiveClipboard => 'クリップボードのテキストを受信';

  @override
  String get settingsTagline => 'あなたのデバイスを、ひとつに。\nアカウントもクラウドも不要。';

  @override
  String get settingsNameTitle => 'このスマートフォンの名前';

  @override
  String get settingsNameCaption => 'ほかのデバイスにはこの名前が表示されます。';

  @override
  String get settingsSave => '保存';

  @override
  String get settingsCancel => 'キャンセル';

  @override
  String settingsRename(String name) {
    return '$name の名前を変更';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'このスマートフォン · $shortId';
  }

  @override
  String get settingsPermissionsRow => '通知とカメラ';

  @override
  String get settingsPermissionsWhat => 'Linksy が Android に求める権限とその理由。';

  @override
  String get settingsPermissionsBoth => '両方とも許可済みです。';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '2 個中 $count 個を許可済み。タップして残りを許可します。',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => '権限';

  @override
  String get permissionsIntro => 'Linksy は必要なものだけを求めます。これらはあとから設定でいつでも変更できます。';

  @override
  String get permissionsNotifications => '通知';

  @override
  String get permissionsNotificationsWhy =>
      'コンピュータが画面を見ているときやカメラを使っているときに、停止ボタン付きでお知らせします。';

  @override
  String get permissionsCamera => 'カメラ';

  @override
  String get permissionsCameraWhy =>
      'ペアリング用の QR コードを読み取ります。許可すると、コンピュータがこのスマートフォンをウェブカメラとして使えます。';

  @override
  String get permissionsAllow => '許可';

  @override
  String get permissionsAllowed => '許可済み';

  @override
  String get permissionsDone => '完了';

  @override
  String get remoteBack => '戻る';

  @override
  String get remoteTitle => 'リモコン';

  @override
  String remoteAllowOn(String name) {
    return '$name で許可してください';
  }

  @override
  String remoteAsks(String name) {
    return '$name の Linksy が、このスマートフォンでポインタの移動と入力を許可するか確認しています。';
  }

  @override
  String get remoteFailed => 'うまくいきませんでした';

  @override
  String get remoteStopped => 'リモコンが停止しました';

  @override
  String remoteEndedBy(String name) {
    return '$name が終了しました。';
  }

  @override
  String get remoteTryAgain => '再試行';

  @override
  String get remoteTouchpad => 'タッチパッド';

  @override
  String get remoteSlides => 'スライド';

  @override
  String get remoteTouchpadHint => '1 本指で移動、タップでクリック\n2 本指でスクロール、2 本指タップで右クリック';

  @override
  String get remoteLeftClick => '左クリック';

  @override
  String get remoteRightClick => '右クリック';

  @override
  String get remoteKeyboard => 'キーボード';

  @override
  String get remoteNextSlide => '次のスライド';

  @override
  String get remoteNext => '次へ';

  @override
  String get remotePreviousSlide => '前のスライド';

  @override
  String get remoteSlideBack => '戻る';

  @override
  String get remoteStartShow => '開始 (F5)';

  @override
  String get remoteEndShow => '終了 (Esc)';

  @override
  String get remoteVolumeHint => '音量ダウン: 次へ · 音量アップ: 戻る。画面はオンのままです。';

  @override
  String get ringTitle => 'ここにいます！';

  @override
  String ringLookingFor(String name) {
    return '$name がこのスマートフォンを探しています。';
  }

  @override
  String get ringFoundIt => '見つかった';

  @override
  String get webcamBack => '戻る';

  @override
  String get webcamTitle => 'ウェブカメラ';

  @override
  String webcamLiveOn(String name) {
    return '$name に配信中';
  }

  @override
  String get webcamStopSemantic => 'ウェブカメラを停止';

  @override
  String get webcamStop => '停止';

  @override
  String get webcamBadgeLive => 'LIVE';

  @override
  String get webcamBadgeLock => 'AE/AF ロック';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'ライト';

  @override
  String get webcamFacingFront => '前面';

  @override
  String get webcamFacingBack => '背面';

  @override
  String get webcamTorch => 'ライト';

  @override
  String get webcamPortrait => '縦向き';

  @override
  String get webcamLandscape => '横向き';

  @override
  String get webcamLocked => 'ロック中';

  @override
  String get webcamLock => 'ロック';

  @override
  String get webcamTabLight => '明るさ';

  @override
  String get webcamTabFocus => 'フォーカス';

  @override
  String get webcamTabColor => '色';

  @override
  String get webcamTabStream => '配信';

  @override
  String get webcamBrightness => '明るさ';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto => 'このカメラは露出を自動で調整します。';

  @override
  String get webcamLockExposure => '露出をロック';

  @override
  String get webcamLockExposureDetail => '今の明るさを保ちます。映像を長押しすると、その位置でロックします。';

  @override
  String get webcamFocus => 'フォーカス';

  @override
  String get webcamFocusFixed => 'このカメラはフォーカスが固定です。';

  @override
  String get webcamFocusSpotDetail => 'タップした位置に固定しています。映像をダブルタップすると自動に戻ります。';

  @override
  String get webcamFocusManualDetail => '下で手動で調整します。';

  @override
  String get webcamFocusAutoDetail => '映像に合わせて調整します。タップするとその位置にフォーカスします。';

  @override
  String get webcamFocusAuto => '自動';

  @override
  String get webcamFocusSpot => 'スポット';

  @override
  String get webcamFocusManual => '手動';

  @override
  String get webcamDistance => '距離';

  @override
  String get webcamFar => '遠';

  @override
  String get webcamNear => '近';

  @override
  String get webcamWbAuto => '自動';

  @override
  String get webcamWbDaylight => '晴天';

  @override
  String get webcamWbCloudy => '曇天';

  @override
  String get webcamWbShade => '日陰';

  @override
  String get webcamWbIncandescent => '電球';

  @override
  String get webcamWbFluorescent => '蛍光灯';

  @override
  String get webcamWhiteBalance => 'ホワイトバランス';

  @override
  String get webcamLockColors => '色をロック';

  @override
  String get webcamLockColorsDetail => '光が変わっても色が変化しないようにします。';

  @override
  String get webcamOrientation => '向き';

  @override
  String get webcamOrientationPortraitDetail => 'スマートフォンを縦に持ちます。左右に帯が入ります。';

  @override
  String get webcamOrientationLandscapeDetail => 'スマートフォンを横に持ちます。フレーム全体に映ります。';

  @override
  String get webcamFrameRate => 'フレームレート';

  @override
  String get webcamFps60Detail => '動きがなめらかになります。データ通信量とバッテリーの消費が増えます。';

  @override
  String get webcamFps30Detail => 'ビデオ通話に安定した設定です。';

  @override
  String get webcamFpsOnly30 => 'このカメラは 30 fps までです。';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => '解像度';

  @override
  String get webcamResolution1080Detail => 'フル HD。大きな画面向けで、データ量が増えます。';

  @override
  String get webcamResolution720Detail => 'HD。ビデオ通話にちょうど良い設定です。';

  @override
  String get webcamResolutionOnly720 => 'このカメラは 720p で配信します。';

  @override
  String get webcamQuality => '画質';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps。混雑した Wi-Fi 向けです。';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps。最も精細です。';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps。ビデオ通話でもくっきり映ります。';
  }

  @override
  String get webcamQualitySaver => '節約';

  @override
  String get webcamQualityStandard => '標準';

  @override
  String get webcamQualityHigh => '高';

  @override
  String get webcamStabilization => '手ぶれ補正';

  @override
  String get webcamStabilizationDetail => '手ぶれを抑えます。';

  @override
  String get webcamMirror => 'プレビューを反転';

  @override
  String get webcamMirrorDetail => 'このスマートフォンでのみ反転します。コンピュータには反転されずに届きます。';

  @override
  String get webcamFormat => 'フォーマット';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'リセット';

  @override
  String webcamResetSetting(String setting) {
    return '$settingをリセット';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'ズーム $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name があなたの画面を見ようとしています';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return '停止するまで、このスマートフォンの画面に表示されるすべてが $name に表示されます。次に Android が確認を求めます。';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name があなたの画面を操作しようとしています';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '停止するまで、$name はこのスマートフォンの画面を見て、タップ、スワイプ、入力ができます。次に Android が確認を求めます。';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name があなたのカメラを使おうとしています';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '停止するまで、$name がこのスマートフォンのカメラをウェブカメラとして使います。使用中は Linksy でズーム、フォーカス、明るさ、レンズ、回転を調整できます。';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name がこのスマートフォンをタッチパッドとして使おうとしています';
  }

  @override
  String get sharingInputRequestDetail =>
      '想定外の要求です。コンピュータはこれを求めません。許可しないでください。';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name があなたのマイクを使おうとしています';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '停止するまで、$name はこのスマートフォンのマイクの音を、そのコンピュータのどのアプリでも使えるマイクとして受け取ります。次に Android が確認を求めます。';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name がこの画面をセカンドディスプレイとして使おうとしています';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'このスマートフォンに $name の画面が全画面で表示されます。タッチでクリックやドラッグ、2 本指でスクロールします。戻ると停止します。';
  }

  @override
  String get sharingAllow => '許可';

  @override
  String get sharingDontAllow => '許可しない';

  @override
  String get sharingProtectionHint =>
      'コンピュータで上部のバーや通知が黒く表示されますか？Android の画面共有保護によって隠されています。開発者向けオプションで「画面共有の保護を無効にする」をオンにしてから、もう一度共有してください。';

  @override
  String get sharingGotIt => 'OK';

  @override
  String get sharingDeveloperOptions => '開発者向けオプション';

  @override
  String sharingControlling(String name) {
    return '$name があなたの画面を操作しています';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name があなたのカメラを使っています';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name があなたのマイクを使っています';
  }

  @override
  String sharingScreenWith(String name) {
    return '$name と画面を共有しています';
  }

  @override
  String get sharingTapForCameraControls => 'タップしてカメラを調整';

  @override
  String get sharingSwitchCamera => 'カメラを切り替え';

  @override
  String get sharingStopSharing => '共有を停止';

  @override
  String get sharingStop => '停止';

  @override
  String get sharingCameraControls => 'カメラのコントロール';

  @override
  String displaySecondHint(String name) {
    return '$name のセカンドディスプレイ · 戻ると停止';
  }

  @override
  String displayControlHint(String name) {
    return '$name の画面 · タッチでクリック · 戻ると停止';
  }

  @override
  String displayWatchHint(String name) {
    return '$name の画面 · 戻ると停止';
  }

  @override
  String terminalTabClosed(String title) {
    return '「$title」を閉じました';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '「$title」が $name で終了しました';
  }

  @override
  String get terminalCloseTitle => 'このターミナルを閉じますか？';

  @override
  String terminalCloseDetail(String name) {
    return '$name のシェルが、実行中のものと一緒に終了します。あとで戻るには、代わりに実行したままにしてください。';
  }

  @override
  String get terminalKeepRunning => '実行したままにする';

  @override
  String get terminalClose => '閉じる';

  @override
  String get terminalTheComputer => 'コンピュータ';

  @override
  String get terminalDetached => '切断中';

  @override
  String terminalDetachedDetail(String name) {
    return '$name で実行中です。再接続するともう一度表示されます。コードを再度求められます。';
  }

  @override
  String get terminalReattach => '再接続';

  @override
  String terminalOn(String name) {
    return '$name のターミナル';
  }

  @override
  String terminalDetachedOn(String name) {
    return '切断中 · $name で実行中';
  }

  @override
  String terminalOpeningOn(String name) {
    return '$name で開いています…';
  }

  @override
  String get terminalWaitingForCode => 'コードを待っています';

  @override
  String get terminalEnded => '終了しました';

  @override
  String get terminalBack => '戻る';

  @override
  String get terminalTitle => 'ターミナル';

  @override
  String get terminalMenu => 'ターミナルメニュー';

  @override
  String get terminalDetachMenu => '実行したままにする（切断）';

  @override
  String terminalCloseTab(String title) {
    return '$title を閉じる';
  }

  @override
  String get terminalNew => '新しいターミナル';

  @override
  String terminalShellOn(String name) {
    return '$name のシェル';
  }

  @override
  String get terminalShellDetail =>
      'コンピュータ上であなたのユーザーとして、ホームフォルダで実行されます。開くたびに、そちらで設定したターミナルコードを求められます。';

  @override
  String get terminalStillRunning => '実行中';

  @override
  String terminalReattachTab(String title) {
    return '$title に再接続';
  }

  @override
  String terminalStarted(String time) {
    return '$time に開始';
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
  String get terminalCodeTitle => 'ターミナルコード';

  @override
  String terminalCodeDetail(String name) {
    return '$name の「環境設定 › ターミナル」で設定したコードです。Linksy はコードを保存しません。';
  }

  @override
  String get terminalCodePassphrase => 'パスフレーズ';

  @override
  String get terminalCodeDigitsHint => '6 桁以上の数字';

  @override
  String get terminalCodeUseDigits => '数字を使う';

  @override
  String get terminalCodeUseLetters => '文字を使う';

  @override
  String get terminalOpening => '開いています…';

  @override
  String get terminalOpen => 'ターミナルを開く';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsThemeSystem => 'システム';

  @override
  String get settingsThemeLight => 'ライト';

  @override
  String get settingsThemeDark => 'ダーク';

  @override
  String usbConnectedTo(String name) {
    return 'USB ケーブルで $name に接続しました';
  }

  @override
  String get usbPairTitle => 'ケーブルの先にコンピュータがあります';

  @override
  String get usbPairBody =>
      'このスマートフォンとはまだペアリングされていません。ケーブル経由でペアリングしますか？両方の画面にコードが表示されるので照合してください。';

  @override
  String get usbPairAction => 'ペアリング';
}
