// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Welcome to Linksy';

  @override
  String get onboardingChooseLanguage => 'Choose your language';

  @override
  String get onboardingLanguageHint => 'You can change it later in Settings.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingSetUpTitle => 'Set up Linksy';

  @override
  String get onboardingSetUpSubtitle =>
      'Choose what Linksy may do. Nothing leaves this phone until you say so.';

  @override
  String get onboardingNotifications => 'Notifications';

  @override
  String get onboardingNotificationsDetail =>
      'Files arriving, and when a computer uses your screen, camera or microphone, with a button to stop.';

  @override
  String get onboardingCamera => 'Camera';

  @override
  String get onboardingCameraDetail =>
      'Scans pairing QR codes, and lets a computer use it as a webcam when you allow it.';

  @override
  String get onboardingAway => 'Away from home';

  @override
  String get onboardingAwayDetail =>
      'Reach your computers over the internet when you\'re not on the same Wi-Fi. Encrypted end to end.';

  @override
  String get onboardingBackground => 'Keep running in the background';

  @override
  String get onboardingBackgroundDetail =>
      'Files and calls keep working when Linksy is closed. Shows a quiet notification.';

  @override
  String get onboardingFolder => 'Share a folder with computers';

  @override
  String get onboardingFolderDetail =>
      'Your computers can open one folder you choose in their Files app.';

  @override
  String get onboardingPhotos => 'Photo backup folder';

  @override
  String get onboardingPhotosDetail =>
      'Choose your camera folder to back up new photos to a computer. Turned on per computer.';

  @override
  String get onboardingLocate => 'Let computers locate this phone';

  @override
  String get onboardingLocateDetail =>
      'A computer can ask where this phone is, once. Nothing is kept.';

  @override
  String get onboardingAllow => 'Allow';

  @override
  String get onboardingAllowed => 'Allowed';

  @override
  String get onboardingChooseFolder => 'Choose';

  @override
  String onboardingFolderChosen(String folder) {
    return '“$folder”';
  }

  @override
  String get onboardingAnytime =>
      'You can turn any of these on or off anytime in Settings.';

  @override
  String get onboardingStart => 'Start using Linksy';

  @override
  String get onboardingBack => 'Back';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageDone => 'Done';

  @override
  String get ctlClipboardFileTooBig =>
      'Only a file up to 10 MB fits on the clipboard.';

  @override
  String get ctlClipboardCopyFailed => 'Couldn’t put it on the clipboard';

  @override
  String get ctlLocateOff => 'Locating is turned off in Linksy on this phone';

  @override
  String get ctlYourComputer => 'your computer';

  @override
  String get ctlAnd => 'and';

  @override
  String ctlKeepingLocked(String names) {
    return 'Keeping $names locked when you leave';
  }

  @override
  String get ctlStayingConnected => 'Staying connected to your computers';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name wants to send you $count files',
      one: '$name wants to send you a file',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'The clipboard is empty.';

  @override
  String get ctlClipboardTooMuch =>
      'The clipboard holds too much text to send.';

  @override
  String get ctlPing => 'Ping';

  @override
  String ctlPingFrom(String name) {
    return 'From $name';
  }

  @override
  String get ctlTextTooMuch => 'That’s too much text to send.';

  @override
  String get ctlDeclined => 'Declined';

  @override
  String get ctlScreenPermission =>
      'Sharing the screen needs Android’s permission to capture it.';

  @override
  String get ctlCameraPermission =>
      'Linksy needs the camera permission to work as a webcam.';

  @override
  String get ctlMicrophonePermission =>
      'Linksy needs the microphone permission to be a microphone.';

  @override
  String get ctlTerminalTitle => 'Terminal';

  @override
  String get errorThatDevice => 'That device';

  @override
  String get errorOtherDevice => 'The other device';

  @override
  String get errorComputerOnCable => 'The computer on the cable';

  @override
  String errorDeviceAt(String address) {
    return 'The device at $address';
  }

  @override
  String errorUnreachable(String name) {
    return '$name isn\'t reachable. Check that it\'s on and on this network.';
  }

  @override
  String errorDeclined(String name) {
    return '$name declined.';
  }

  @override
  String errorTimeout(String name) {
    return '$name didn\'t answer in time.';
  }

  @override
  String errorNotPaired(String name) {
    return '$name isn\'t paired anymore. Pair again to share.';
  }

  @override
  String errorUnsupported(String name) {
    return '$name can\'t do that yet.';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name allows that only on the same network. Its owner can allow everything from away for this phone.';
  }

  @override
  String get errorInvalid => 'That didn’t work.';

  @override
  String get errorSomethingWrong => 'Something went wrong.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Something went wrong: $detail';
  }

  @override
  String get terminalRefusedComputer => 'The computer';

  @override
  String get terminalRefusedCode => 'Wrong code.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wrong code, $count tries left.',
      one: 'Wrong code, 1 try left.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Too many wrong codes. Unlock the terminal on $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'On $name, open this phone’s page and allow the terminal there.';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name allows a terminal only on the same network, unless “Allow Everything From Away” is on there.';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name can\'t open a terminal.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return '8 terminals already run on $name for this phone. Close one first.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name didn’t allow it.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$os $kind';
  }

  @override
  String get modelKindDesktop => 'desktop';

  @override
  String get modelKindLaptop => 'laptop';

  @override
  String get modelKindPhone => 'phone';

  @override
  String get modelKindTablet => 'tablet';

  @override
  String get modelOsUnknown => 'Unknown';

  @override
  String get deviceNothingOfKind => 'Nothing of that kind yet.';

  @override
  String deviceBattery(int level) {
    return '$level%';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level%, charging';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Reachable from away until $day';
  }

  @override
  String get deviceLocksWhenLeave => 'Locks when you leave with this phone';

  @override
  String get deviceBack => 'Back';

  @override
  String get deviceMore => 'More';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Change picture';

  @override
  String get deviceAddPicture => 'Add a picture';

  @override
  String get deviceRemovePicture => 'Remove picture';

  @override
  String get deviceForgetThis => 'Forget this device';

  @override
  String deviceForgetTitle(String name) {
    return 'Forget $name?';
  }

  @override
  String get deviceForgetBody =>
      'You’ll need to pair again to share with it. Its activity on this phone is cleared too.';

  @override
  String get deviceForget => 'Forget';

  @override
  String get deviceCancel => 'Cancel';

  @override
  String get deviceSendFiles => 'Send files';

  @override
  String get deviceSendFilesCaption => 'Photos, documents, anything';

  @override
  String get deviceClipboard => 'Clipboard';

  @override
  String get deviceClipboardCaption => 'Send what you copied';

  @override
  String get devicePing => 'Ping';

  @override
  String get devicePingCaption => 'Make it chime';

  @override
  String get deviceRemote => 'Remote';

  @override
  String get deviceRemoteCaption => 'Touchpad and slides';

  @override
  String get deviceRinging => 'Ringing…';

  @override
  String get deviceFindIt => 'Find it';

  @override
  String get deviceTapToStop => 'Tap to stop';

  @override
  String get deviceFindItCaption => 'Make it ring loudly';

  @override
  String get devicePrevious => 'Previous';

  @override
  String get devicePause => 'Pause';

  @override
  String get devicePlay => 'Play';

  @override
  String get deviceNext => 'Next';

  @override
  String deviceAllowOn(String name) {
    return 'Allow it on $name…';
  }

  @override
  String get deviceSeeScreen => 'See its screen';

  @override
  String get deviceSeeScreenCaption =>
      'Watch it here, or control it with touch';

  @override
  String get deviceWatch => 'Watch';

  @override
  String get deviceControl => 'Control';

  @override
  String get deviceTerminal => 'Terminal';

  @override
  String deviceTerminalShell(String name) {
    return 'A shell on $name, locked by its code';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terminals open',
      one: '1 terminal open',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'All';

  @override
  String get deviceFilterFiles => 'Files';

  @override
  String get deviceFilterClipboard => 'Clipboard';

  @override
  String get deviceFilterLinks => 'Links';

  @override
  String get deviceFilterShowAll => 'Show All';

  @override
  String get deviceFilterShowFiles => 'Show Files';

  @override
  String get deviceFilterShowClipboard => 'Show Clipboard';

  @override
  String get deviceFilterShowLinks => 'Show Links';

  @override
  String get deviceActivity => 'Activity';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Ready when $name asks';
  }

  @override
  String get deviceWebcam => 'Webcam';

  @override
  String get deviceInUseNow => 'In use now';

  @override
  String get deviceControls => 'Controls';

  @override
  String get deviceMicrophone => 'Microphone';

  @override
  String get deviceStop => 'Stop';

  @override
  String get deviceSecondDisplay => 'Second display';

  @override
  String get deviceShowingNow => 'Showing now';

  @override
  String deviceReadySize(int width, int height) {
    return 'Ready · $width × $height';
  }

  @override
  String get devicePhoneAs => 'This phone as';

  @override
  String deviceStartedOn(String name) {
    return 'Started on $name';
  }

  @override
  String get deviceFasterOverUsb => 'Faster and steadier over a USB cable.';

  @override
  String get deviceBackUpPhotos => 'Back up photos';

  @override
  String devicePhotosGoTo(String name) {
    return 'New photos go to $name’s Pictures folder';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name doesn’t take photos. Turn on “Import Photos From Phones” there.';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'From $folder';
  }

  @override
  String get devicePhotosFromCamera => 'From your camera folder';

  @override
  String devicePhotosLast(String time) {
    return 'last $time';
  }

  @override
  String get deviceGetClipboard => 'Get its clipboard';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'Text copied on $name lands here while connected';
  }

  @override
  String get deviceAwayAll => 'Allow everything from away';

  @override
  String get deviceAwayAllOn =>
      'From away too: this screen, webcam, microphone and files';

  @override
  String get deviceAwayAllOff =>
      'From away: clipboard, links, files and ring only';

  @override
  String get deviceNothingShared => 'Nothing shared yet';

  @override
  String deviceNothingSharedBody(String name) {
    return 'Files, clipboard text and pings between this phone and $name line up here.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '“$text”';
  }

  @override
  String get activityClipboardText => 'Clipboard text';

  @override
  String get activityPing => 'Ping';

  @override
  String get activityYourScreen => 'Your screen';

  @override
  String get activityYourCamera => 'Your camera';

  @override
  String get activitySecondDisplay => 'Second display';

  @override
  String get activityLink => 'Link';

  @override
  String get activityRangThisPhone => 'Rang this phone';

  @override
  String get activityRangIt => 'Rang it';

  @override
  String get activityTouchpadKeyboard => 'Touchpad and keyboard';

  @override
  String get activityItsScreen => 'Its screen';

  @override
  String get activityYourMicrophone => 'Your microphone';

  @override
  String get activityWhereThisPhone => 'Where this phone is';

  @override
  String get activityWatchingNow => 'Watching now';

  @override
  String get activityWatched => 'Watched';

  @override
  String get activityInUseWebcam => 'In use as a webcam';

  @override
  String get activityUsedWebcam => 'Used as a webcam';

  @override
  String get activityBeingControlled => 'Being controlled now';

  @override
  String get activityWatchedControlled => 'Watched and controlled';

  @override
  String get activityWatchedFromPhone => 'Watched from this phone';

  @override
  String get activityInUseNow => 'In use now';

  @override
  String get activityWasTouchpad => 'This phone was its touchpad';

  @override
  String get activityWasSecondDisplay => 'This phone was its second display';

  @override
  String get activityLinkReceived => 'Link received';

  @override
  String get activityOpenedOnComputer => 'Opened on the computer';

  @override
  String get activityInUseMicrophone => 'In use as a microphone';

  @override
  String get activityUsedMicrophone => 'Used as a microphone';

  @override
  String get activityNotTold => 'Not told';

  @override
  String get activityToldWhere => 'Told it where this phone is';

  @override
  String get activityAskedToFind => 'Asked to find this phone';

  @override
  String get activityToFindIt => 'To find it';

  @override
  String get activityDeclined => 'Declined';

  @override
  String get activityFailed => 'Failed';

  @override
  String get activityInProgress => 'In progress';

  @override
  String get activityCopiedHere => 'Copied here';

  @override
  String get activityReceived => 'Received';

  @override
  String get activitySent => 'Sent';

  @override
  String get activityStop => 'Stop';

  @override
  String get activityCancel => 'Cancel';

  @override
  String get activityCopyAgain => 'Copy again';

  @override
  String get activityCopied => 'Copied';

  @override
  String get activityCopyLink => 'Copy link';

  @override
  String get activityLinkCopied => 'Link copied';

  @override
  String get activityNoAppForLink => 'No app here opens that link.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name isn’t there anymore.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'No app on this phone opens $name.';
  }

  @override
  String get activityWaitingForYou => 'Waiting for you to accept…';

  @override
  String get activityWaitingForDevice => 'Waiting for the device to accept…';

  @override
  String activityWaitingFor(String name) {
    return 'Waiting for $name to accept…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done of $total';
  }

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeYourDevices => 'Your devices';

  @override
  String get homeNearbyNotPaired => 'Nearby, not paired';

  @override
  String get homeAddDevice => 'Add a device';

  @override
  String homeVisible(String name) {
    return '$name is visible on this Wi-Fi';
  }

  @override
  String get homeUpdateTitle => 'Update Linksy to keep connecting';

  @override
  String get homeUpdateBody =>
      'Your computers now speak a newer Linksy than this app.';

  @override
  String get homeGetUpdate => 'Get the update';

  @override
  String get homeSendFiles => 'Send files';

  @override
  String get homePair => 'Pair';

  @override
  String get homeStepOpen => 'Open Linksy on your computer';

  @override
  String get homeStepChoose => 'Choose “Add Device”';

  @override
  String get homeStepScan => 'Scan it with this phone';

  @override
  String get homeConnectTitle => 'Connect your\nfirst device';

  @override
  String get homeConnectSubtitle =>
      'Straight over your Wi-Fi. No account, no cloud.';

  @override
  String get homeScanQr => 'Scan QR code';

  @override
  String get homePairByAddress => 'Pair by address instead';

  @override
  String get pairingAddDevice => 'Add a device';

  @override
  String get pairingAddDeviceHint =>
      'On the other device, open Linksy and choose “Add Device”.';

  @override
  String get pairingScanQr => 'Scan QR code';

  @override
  String get pairingScanQrCaption => 'Fastest. Nothing to type.';

  @override
  String get pairingByAddress => 'Pair by address';

  @override
  String get pairingByAddressCaption => 'When the other device can’t be found.';

  @override
  String pairingWith(String name) {
    return 'Pairing with $name…';
  }

  @override
  String get pairingWithOtherDevice => 'Pairing with the other device…';

  @override
  String get pairingAddressHint =>
      'It’s in Linksy’s Preferences on the other device.';

  @override
  String pairingPortHint(String port) {
    return 'Port $port unless you add another.';
  }

  @override
  String get pairingPair => 'Pair';

  @override
  String pairingWantsToPair(String name) {
    return '$name wants to pair';
  }

  @override
  String pairingPairWith(String name) {
    return 'Pair with $name';
  }

  @override
  String get pairingCodeHint => 'Both screens should show this code.';

  @override
  String pairingCodeLabel(String code) {
    return 'Code $code';
  }

  @override
  String get pairingCodesMatch => 'Codes match';

  @override
  String get scanNeedsCamera =>
      'Linksy needs the camera to scan the pairing code. Allow it, or pair by address.';

  @override
  String get scanCameraUnavailable => 'The camera isn’t available.';

  @override
  String get scanFlashlight => 'Flashlight';

  @override
  String get scanTitle => 'Scan the code';

  @override
  String get scanWrongCode =>
      'That’s not a Linksy code. On your computer, open Linksy → Pair with QR Code.';

  @override
  String get scanHint =>
      'On your computer, open Linksy and choose “Add Device”.';

  @override
  String get shareSheetPutOnClipboard => 'Put on a clipboard';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Send $count files',
      one: 'Send a file',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Open on a computer';

  @override
  String get shareSheetSendToClipboard => 'Send to a clipboard';

  @override
  String get shareSheetNoClipboardFiles =>
      'None of your computers takes files on its clipboard yet. Update Linksy there.';

  @override
  String get shareSheetNoComputers =>
      'Pair a computer first, then share to it from any app.';

  @override
  String get shareSheetSendFileInstead => 'Send the file instead';

  @override
  String get shareSheetClipboardInstead =>
      'Put it on the computer’s clipboard instead';

  @override
  String get shareSheetOpenLinkInstead => 'Open the link instead';

  @override
  String get shareSheetSendAsTextInstead =>
      'Send as text to the clipboard instead';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Putting it on $name’s clipboard';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Putting it on the computer’s clipboard';

  @override
  String shareSheetOpened(String name) {
    return 'Opened on $name';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Opened on the computer';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'Sent to $name’s clipboard';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'Sent to the computer’s clipboard';

  @override
  String shareSheetSentALink(String name) {
    return '$name sent a link';
  }

  @override
  String get shareSheetOpen => 'Open';

  @override
  String get shareSheetCopyLink => 'Copy link';

  @override
  String get shareSheetLinkCopied => 'Link copied';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: 'a file',
    );
    return '$name is sending you $_temp0';
  }

  @override
  String incomingTotal(String size) {
    return '$size in total';
  }

  @override
  String incomingMore(int count) {
    return '+ $count more';
  }

  @override
  String get incomingAccept => 'Accept';

  @override
  String get appInvalidPairingLink => 'That pairing link isn’t valid.';

  @override
  String appPairingFailed(String reason) {
    return 'Pairing failed: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'Couldn’t pair with $name: $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Paired with $name';
  }

  @override
  String appNotification(String name, String text) {
    return '$name: $text';
  }

  @override
  String appCopiedText(String name) {
    return 'Copied text from $name';
  }

  @override
  String appCopiedFile(String file, String name) {
    return 'Copied $file from $name';
  }

  @override
  String get appCouldntStart => 'Linksy couldn’t start';

  @override
  String get commonDismiss => 'Dismiss';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDecline => 'Decline';

  @override
  String get commonClose => 'Close';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonConnected => 'Connected';

  @override
  String get commonNearby => 'Nearby';

  @override
  String get commonNotNearby => 'Not nearby';

  @override
  String get commonUsbCable => 'USB cable';

  @override
  String get commonAwayFromHome => 'Away from home';

  @override
  String get commonSameWifi => 'Same Wi-Fi';

  @override
  String get commonConnectedByUsb => 'Connected by USB';

  @override
  String get commonConnectedAway => 'Connected away from home';

  @override
  String commonBattery(int level) {
    return 'Battery $level percent';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Battery $level percent, charging';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bytes',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds left',
      one: '1 second left',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes left',
      one: '1 minute left',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'about $count hours left',
      one: 'about 1 hour left',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Today';

  @override
  String get formatYesterday => 'Yesterday';

  @override
  String get formatPhone => 'Phone';

  @override
  String get settingsBack => 'Back';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsReceiving => 'Receiving';

  @override
  String get settingsSaveLocation => 'Save location';

  @override
  String get settingsSaveLocationPath => 'Downloads › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Accept from my devices';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'Files from paired devices arrive without asking.';

  @override
  String get settingsConnection => 'Connection';

  @override
  String get settingsStayConnected => 'Stay connected';

  @override
  String get settingsStayConnectedCaption =>
      'Faster sharing with nearby devices. Uses more battery.';

  @override
  String get settingsKeepRunning => 'Keep running in the background';

  @override
  String get settingsKeepRunningCaption =>
      'Files, photo backup and calls keep working when Linksy is closed. Shows a quiet notification.';

  @override
  String get settingsAwayFromHome => 'Away from home';

  @override
  String get settingsAwayFromHomeCaption =>
      'Reach your computers over the internet when you’re not on the same network, for a week after you last were. Encrypted end to end.';

  @override
  String get settingsRelay => 'Relay server';

  @override
  String get settingsRelayDefault => 'Linksy’s own';

  @override
  String get settingsRelayCaption =>
      'The address of a relay you host yourself, like https://relay.example.com. Leave it empty for Linksy’s own. Set the same relay on every device.';

  @override
  String get settingsWithYourComputers => 'With your computers';

  @override
  String get settingsPauseMusic => 'Pause music during calls';

  @override
  String get settingsPauseMusicCaption =>
      'Your computers pause what plays while a call rings or goes on, and resume after.';

  @override
  String get settingsBrowseFiles => 'Let computers browse files';

  @override
  String get settingsBrowseFilesChoose =>
      'Choose a folder your computers can open in their Files app, like Documents (Android doesn’t allow Download).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Shares “$folder”. Tap to choose another folder.';
  }

  @override
  String get settingsPicture => 'Picture of this phone';

  @override
  String get settingsPictureChoose =>
      'Your computers show it for this phone. Tap to choose one.';

  @override
  String get settingsPictureChange =>
      'Your computers show it for this phone. Tap to change it.';

  @override
  String get settingsPictureRemove => 'Remove';

  @override
  String get settingsLocate => 'Let computers locate this phone';

  @override
  String get settingsLocateCaption =>
      'A computer can ask where this phone is, once, to find it. Nothing is kept or tracked. Works while Linksy is open.';

  @override
  String get settingsLocatePermission =>
      'Linksy needs the location permission for this.';

  @override
  String get settingsPhotoFolder => 'Photo folder';

  @override
  String get settingsPhotoFolderChoose =>
      'Choose your camera folder (DCIM › Camera) to back up photos to a computer.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Backs up “$folder”. Turn it on per computer, on its page.';
  }

  @override
  String get settingsThisApp => 'This app';

  @override
  String get settingsPermissions => 'Permissions';

  @override
  String get settingsDemo => 'Demo';

  @override
  String get settingsDemoCaption =>
      'Simulated devices until the Linksy core is connected. These start what another device would.';

  @override
  String get settingsDemoReceiveFiles => 'Receive files';

  @override
  String get settingsDemoReceivePairing => 'Receive a pairing request';

  @override
  String get settingsDemoReceiveClipboard => 'Receive clipboard text';

  @override
  String get settingsTagline =>
      'Your devices, connected.\nNo account, no cloud.';

  @override
  String get settingsNameTitle => 'Name this phone';

  @override
  String get settingsNameCaption => 'Your other devices see this name.';

  @override
  String get settingsSave => 'Save';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String settingsRename(String name) {
    return 'Rename $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'This phone · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Notifications and camera';

  @override
  String get settingsPermissionsWhat =>
      'What Linksy asks Android for, and why.';

  @override
  String get settingsPermissionsBoth => 'Both allowed.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of 2 allowed. Tap to allow the rest.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsIntro =>
      'Linksy asks only for what it needs, and you can change any of these later in Settings.';

  @override
  String get permissionsNotifications => 'Notifications';

  @override
  String get permissionsNotificationsWhy =>
      'Shows when a computer sees your screen or uses your camera, with a button to stop it.';

  @override
  String get permissionsCamera => 'Camera';

  @override
  String get permissionsCameraWhy =>
      'Scans the pairing QR code, and lets a computer use this phone as a webcam when you allow it.';

  @override
  String get permissionsAllow => 'Allow';

  @override
  String get permissionsAllowed => 'Allowed';

  @override
  String get permissionsDone => 'Done';

  @override
  String get remoteBack => 'Back';

  @override
  String get remoteTitle => 'Remote';

  @override
  String remoteAllowOn(String name) {
    return 'Allow it on $name';
  }

  @override
  String remoteAsks(String name) {
    return 'Linksy on $name asks whether this phone may move its pointer and type.';
  }

  @override
  String get remoteFailed => 'That didn’t work';

  @override
  String get remoteStopped => 'The remote stopped';

  @override
  String remoteEndedBy(String name) {
    return '$name ended it.';
  }

  @override
  String get remoteTryAgain => 'Try again';

  @override
  String get remoteTouchpad => 'Touchpad';

  @override
  String get remoteSlides => 'Slides';

  @override
  String get remoteTouchpadHint =>
      'Move with one finger, tap to click\nTwo fingers scroll, two-finger tap right-clicks';

  @override
  String get remoteLeftClick => 'Left click';

  @override
  String get remoteRightClick => 'Right click';

  @override
  String get remoteKeyboard => 'Keyboard';

  @override
  String get remoteNextSlide => 'Next slide';

  @override
  String get remoteNext => 'Next';

  @override
  String get remotePreviousSlide => 'Previous slide';

  @override
  String get remoteSlideBack => 'Back';

  @override
  String get remoteStartShow => 'Start (F5)';

  @override
  String get remoteEndShow => 'End (Esc)';

  @override
  String get remoteVolumeHint =>
      'Volume down: next · Volume up: back. The screen stays on.';

  @override
  String get ringTitle => 'Here I am!';

  @override
  String ringLookingFor(String name) {
    return '$name is looking for this phone.';
  }

  @override
  String get ringFoundIt => 'Found it';

  @override
  String get webcamBack => 'Back';

  @override
  String get webcamTitle => 'Webcam';

  @override
  String webcamLiveOn(String name) {
    return 'Live on $name';
  }

  @override
  String get webcamStopSemantic => 'Stop the webcam';

  @override
  String get webcamStop => 'Stop';

  @override
  String get webcamBadgeLive => 'LIVE';

  @override
  String get webcamBadgeLock => 'AE/AF LOCK';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'TORCH';

  @override
  String get webcamFacingFront => 'Front';

  @override
  String get webcamFacingBack => 'Back';

  @override
  String get webcamTorch => 'Torch';

  @override
  String get webcamPortrait => 'Portrait';

  @override
  String get webcamLandscape => 'Landscape';

  @override
  String get webcamLocked => 'Locked';

  @override
  String get webcamLock => 'Lock';

  @override
  String get webcamTabLight => 'Light';

  @override
  String get webcamTabFocus => 'Focus';

  @override
  String get webcamTabColor => 'Color';

  @override
  String get webcamTabStream => 'Stream';

  @override
  String get webcamBrightness => 'Brightness';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto => 'This camera sets exposure by itself.';

  @override
  String get webcamLockExposure => 'Lock exposure';

  @override
  String get webcamLockExposureDetail =>
      'Keeps the brightness as it is now. Hold the picture to lock on a spot.';

  @override
  String get webcamFocus => 'Focus';

  @override
  String get webcamFocusFixed => 'This camera has fixed focus.';

  @override
  String get webcamFocusSpotDetail =>
      'Held where you tapped. Double-tap the picture for auto.';

  @override
  String get webcamFocusManualDetail => 'Set by hand below.';

  @override
  String get webcamFocusAutoDetail =>
      'Follows the picture. Tap it to focus on a spot.';

  @override
  String get webcamFocusAuto => 'Auto';

  @override
  String get webcamFocusSpot => 'Spot';

  @override
  String get webcamFocusManual => 'Manual';

  @override
  String get webcamDistance => 'Distance';

  @override
  String get webcamFar => 'Far';

  @override
  String get webcamNear => 'Near';

  @override
  String get webcamWbAuto => 'Auto';

  @override
  String get webcamWbDaylight => 'Daylight';

  @override
  String get webcamWbCloudy => 'Cloudy';

  @override
  String get webcamWbShade => 'Shade';

  @override
  String get webcamWbIncandescent => 'Warm light';

  @override
  String get webcamWbFluorescent => 'Office light';

  @override
  String get webcamWhiteBalance => 'White balance';

  @override
  String get webcamLockColors => 'Lock colors';

  @override
  String get webcamLockColorsDetail =>
      'Stops the colors shifting as the light changes.';

  @override
  String get webcamOrientation => 'Orientation';

  @override
  String get webcamOrientationPortraitDetail =>
      'Hold the phone upright; bars at the sides.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Hold the phone sideways; it fills the frame.';

  @override
  String get webcamFrameRate => 'Frame rate';

  @override
  String get webcamFps60Detail =>
      'Smoother motion; uses more data and battery.';

  @override
  String get webcamFps30Detail => 'Steady for video calls.';

  @override
  String get webcamFpsOnly30 => 'This camera does up to 30 fps.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Resolution';

  @override
  String get webcamResolution1080Detail =>
      'Full HD, for a big screen; more data.';

  @override
  String get webcamResolution720Detail => 'HD, right for video calls.';

  @override
  String get webcamResolutionOnly720 => 'This camera streams 720p.';

  @override
  String get webcamQuality => 'Quality';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, for a busy Wi-Fi.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, the most detail.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, sharp for video calls.';
  }

  @override
  String get webcamQualitySaver => 'Saver';

  @override
  String get webcamQualityStandard => 'Standard';

  @override
  String get webcamQualityHigh => 'High';

  @override
  String get webcamStabilization => 'Stabilization';

  @override
  String get webcamStabilizationDetail => 'Smooths out hand shake.';

  @override
  String get webcamMirror => 'Mirror the preview';

  @override
  String get webcamMirrorDetail =>
      'On this phone only; the computer gets it unmirrored.';

  @override
  String get webcamFormat => 'Format';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Reset';

  @override
  String webcamResetSetting(String setting) {
    return 'Reset $setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name wants to see your screen';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Everything on this phone’s screen shows on $name until you stop. Android asks you to confirm next.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name wants to control your screen';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '$name sees this phone’s screen and can tap, swipe and type on it until you stop. Android asks you to confirm next.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name wants to use your camera';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '$name gets this phone’s camera as a webcam until you stop. Zoom, focus, light, lenses and rotation are in Linksy while it runs.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name wants to use this phone as a touchpad';
  }

  @override
  String get sharingInputRequestDetail =>
      'Unexpected: computers don’t ask this. Don’t allow it.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name wants to use your microphone';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '$name hears this phone’s microphone until you stop, as a microphone any of its apps can use. Android asks you to confirm next.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name wants to use this screen as a second display';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'This phone shows a screen of $name full screen. Touch it to click and drag; scroll with two fingers. Go back to stop.';
  }

  @override
  String get sharingAllow => 'Allow';

  @override
  String get sharingDontAllow => 'Don’t allow';

  @override
  String get sharingProtectionHint =>
      'Top bar or notifications black on the computer? Android’s screen share protection hides them. Turn on “Disable screen share protections” in Developer options, then share again.';

  @override
  String get sharingGotIt => 'Got it';

  @override
  String get sharingDeveloperOptions => 'Developer options';

  @override
  String sharingControlling(String name) {
    return '$name is controlling your screen';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name is using your camera';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name is using your microphone';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Sharing your screen with $name';
  }

  @override
  String get sharingTapForCameraControls => 'Tap for camera controls';

  @override
  String get sharingSwitchCamera => 'Switch camera';

  @override
  String get sharingStopSharing => 'Stop sharing';

  @override
  String get sharingStop => 'Stop';

  @override
  String get sharingCameraControls => 'Camera controls';

  @override
  String displaySecondHint(String name) {
    return '$name’s second display · go back to stop';
  }

  @override
  String displayControlHint(String name) {
    return '$name’s screen · touch to click · go back to stop';
  }

  @override
  String displayWatchHint(String name) {
    return '$name’s screen · go back to stop';
  }

  @override
  String terminalTabClosed(String title) {
    return '“$title” closed';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '“$title” ended on $name';
  }

  @override
  String get terminalCloseTitle => 'Close this terminal?';

  @override
  String terminalCloseDetail(String name) {
    return 'The shell ends on $name, with anything still running in it. To come back to it later, keep it running instead.';
  }

  @override
  String get terminalKeepRunning => 'Keep running';

  @override
  String get terminalClose => 'Close';

  @override
  String get terminalTheComputer => 'the computer';

  @override
  String get terminalDetached => 'Detached';

  @override
  String terminalDetachedDetail(String name) {
    return 'Still running on $name. Reattach to see it again; the code is asked again.';
  }

  @override
  String get terminalReattach => 'Reattach';

  @override
  String terminalOn(String name) {
    return 'Terminal on $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Detached · still running on $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Opening on $name…';
  }

  @override
  String get terminalWaitingForCode => 'Waiting for the code';

  @override
  String get terminalEnded => 'Ended';

  @override
  String get terminalBack => 'Back';

  @override
  String get terminalTitle => 'Terminal';

  @override
  String get terminalMenu => 'Terminal menu';

  @override
  String get terminalDetachMenu => 'Leave it running (detach)';

  @override
  String terminalCloseTab(String title) {
    return 'Close $title';
  }

  @override
  String get terminalNew => 'New terminal';

  @override
  String terminalShellOn(String name) {
    return 'A shell on $name';
  }

  @override
  String get terminalShellDetail =>
      'Runs as you on the computer, in your home folder. Each time it opens, it asks for the terminal code set there.';

  @override
  String get terminalStillRunning => 'STILL RUNNING';

  @override
  String terminalReattachTab(String title) {
    return 'Reattach $title';
  }

  @override
  String terminalStarted(String time) {
    return 'Started $time';
  }

  @override
  String get terminalKeyLeft => 'Left';

  @override
  String get terminalKeyUp => 'Up';

  @override
  String get terminalKeyDown => 'Down';

  @override
  String get terminalKeyRight => 'Right';

  @override
  String get terminalCodeTitle => 'Terminal code';

  @override
  String terminalCodeDetail(String name) {
    return 'The code set on $name in Preferences › Terminal. Linksy never keeps it.';
  }

  @override
  String get terminalCodePassphrase => 'Passphrase';

  @override
  String get terminalCodeDigitsHint => '6 or more digits';

  @override
  String get terminalCodeUseDigits => 'Use digits';

  @override
  String get terminalCodeUseLetters => 'Use letters';

  @override
  String get terminalOpening => 'Opening…';

  @override
  String get terminalOpen => 'Open terminal';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String usbConnectedTo(String name) {
    return 'Connected to $name by USB cable';
  }

  @override
  String get usbPairTitle => 'A computer is on the cable';

  @override
  String get usbPairBody =>
      'It isn’t paired with this phone yet. Pair with it over the cable? Both screens show a code to compare.';

  @override
  String get usbPairAction => 'Pair';
}
