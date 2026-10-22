import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_mg.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('mg'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// The app's name; not translated.
  ///
  /// In en, this message translates to:
  /// **'Linksy'**
  String get appTitle;

  /// First screen title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Linksy'**
  String get onboardingWelcome;

  /// No description provided for @onboardingChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get onboardingChooseLanguage;

  /// No description provided for @onboardingLanguageHint.
  ///
  /// In en, this message translates to:
  /// **'You can change it later in Settings.'**
  String get onboardingLanguageHint;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingSetUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up Linksy'**
  String get onboardingSetUpTitle;

  /// No description provided for @onboardingSetUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what Linksy may do. Nothing leaves this phone until you say so.'**
  String get onboardingSetUpSubtitle;

  /// No description provided for @onboardingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboardingNotifications;

  /// No description provided for @onboardingNotificationsDetail.
  ///
  /// In en, this message translates to:
  /// **'Files arriving, and when a computer uses your screen, camera or microphone, with a button to stop.'**
  String get onboardingNotificationsDetail;

  /// No description provided for @onboardingCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get onboardingCamera;

  /// No description provided for @onboardingCameraDetail.
  ///
  /// In en, this message translates to:
  /// **'Scans pairing QR codes, and lets a computer use it as a webcam when you allow it.'**
  String get onboardingCameraDetail;

  /// No description provided for @onboardingAway.
  ///
  /// In en, this message translates to:
  /// **'Away from home'**
  String get onboardingAway;

  /// No description provided for @onboardingAwayDetail.
  ///
  /// In en, this message translates to:
  /// **'Reach your computers over the internet when you\'re not on the same Wi-Fi. Encrypted end to end.'**
  String get onboardingAwayDetail;

  /// No description provided for @onboardingBackground.
  ///
  /// In en, this message translates to:
  /// **'Keep running in the background'**
  String get onboardingBackground;

  /// No description provided for @onboardingBackgroundDetail.
  ///
  /// In en, this message translates to:
  /// **'Files and calls keep working when Linksy is closed. Shows a quiet notification.'**
  String get onboardingBackgroundDetail;

  /// No description provided for @onboardingFolder.
  ///
  /// In en, this message translates to:
  /// **'Share a folder with computers'**
  String get onboardingFolder;

  /// No description provided for @onboardingFolderDetail.
  ///
  /// In en, this message translates to:
  /// **'Your computers can open one folder you choose in their Files app.'**
  String get onboardingFolderDetail;

  /// No description provided for @onboardingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photo backup folder'**
  String get onboardingPhotos;

  /// No description provided for @onboardingPhotosDetail.
  ///
  /// In en, this message translates to:
  /// **'Choose your camera folder to back up new photos to a computer. Turned on per computer.'**
  String get onboardingPhotosDetail;

  /// No description provided for @onboardingLocate.
  ///
  /// In en, this message translates to:
  /// **'Let computers locate this phone'**
  String get onboardingLocate;

  /// No description provided for @onboardingLocateDetail.
  ///
  /// In en, this message translates to:
  /// **'A computer can ask where this phone is, once. Nothing is kept.'**
  String get onboardingLocateDetail;

  /// No description provided for @onboardingAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get onboardingAllow;

  /// No description provided for @onboardingAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get onboardingAllowed;

  /// Button to pick a folder.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get onboardingChooseFolder;

  /// No description provided for @onboardingFolderChosen.
  ///
  /// In en, this message translates to:
  /// **'“{folder}”'**
  String onboardingFolderChosen(String folder);

  /// No description provided for @onboardingAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can turn any of these on or off anytime in Settings.'**
  String get onboardingAnytime;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start using Linksy'**
  String get onboardingStart;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get languageDone;

  /// Error when sharing a file to a computer's clipboard that is too big
  ///
  /// In en, this message translates to:
  /// **'Only a file up to 10 MB fits on the clipboard.'**
  String get ctlClipboardFileTooBig;

  /// Activity reason: a file received for the clipboard couldn't be copied
  ///
  /// In en, this message translates to:
  /// **'Couldn’t put it on the clipboard'**
  String get ctlClipboardCopyFailed;

  /// Sent to the computer (and shown) when it asks for the phone's location but locating is off
  ///
  /// In en, this message translates to:
  /// **'Locating is turned off in Linksy on this phone'**
  String get ctlLocateOff;

  /// Fallback name for a computer whose name is unknown, used inside sentences
  ///
  /// In en, this message translates to:
  /// **'your computer'**
  String get ctlYourComputer;

  /// Word joining device names in a list, e.g. 'fedora and macbook'
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get ctlAnd;

  /// Persistent notification while computers lock when the phone leaves; names is an already joined list
  ///
  /// In en, this message translates to:
  /// **'Keeping {names} locked when you leave'**
  String ctlKeepingLocked(String names);

  /// Persistent notification while Linksy keeps running in the background
  ///
  /// In en, this message translates to:
  /// **'Staying connected to your computers'**
  String get ctlStayingConnected;

  /// Notification when a device wants to send files
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{name} wants to send you a file} other{{name} wants to send you {count} files}}'**
  String ctlTransferRequest(int count, String name);

  /// Error when sending the clipboard but it is empty
  ///
  /// In en, this message translates to:
  /// **'The clipboard is empty.'**
  String get ctlClipboardEmpty;

  /// Error when the clipboard text is too large to send
  ///
  /// In en, this message translates to:
  /// **'The clipboard holds too much text to send.'**
  String get ctlClipboardTooMuch;

  /// Title of a ping notification sent to a computer, and its timeline entry
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get ctlPing;

  /// Body of a ping notification shown on the computer; name is this phone's name
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String ctlPingFrom(String name);

  /// Error when shared text is too large to send
  ///
  /// In en, this message translates to:
  /// **'That’s too much text to send.'**
  String get ctlTextTooMuch;

  /// Activity reason after the user declined a request
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get ctlDeclined;

  /// Error when Android screen capture permission was refused
  ///
  /// In en, this message translates to:
  /// **'Sharing the screen needs Android’s permission to capture it.'**
  String get ctlScreenPermission;

  /// Error when the camera permission was refused
  ///
  /// In en, this message translates to:
  /// **'Linksy needs the camera permission to work as a webcam.'**
  String get ctlCameraPermission;

  /// Error when the microphone permission was refused
  ///
  /// In en, this message translates to:
  /// **'Linksy needs the microphone permission to be a microphone.'**
  String get ctlMicrophonePermission;

  /// Default title of a remote terminal tab
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get ctlTerminalTitle;

  /// Device name used in error sentences when the device is unknown
  ///
  /// In en, this message translates to:
  /// **'That device'**
  String get errorThatDevice;

  /// Device name used in error sentences when none is given
  ///
  /// In en, this message translates to:
  /// **'The other device'**
  String get errorOtherDevice;

  /// Device name in error sentences for a computer connected by USB cable
  ///
  /// In en, this message translates to:
  /// **'The computer on the cable'**
  String get errorComputerOnCable;

  /// Device name in error sentences when pairing by address
  ///
  /// In en, this message translates to:
  /// **'The device at {address}'**
  String errorDeviceAt(String address);

  /// Error: the device can't be reached
  ///
  /// In en, this message translates to:
  /// **'{name} isn\'t reachable. Check that it\'s on and on this network.'**
  String errorUnreachable(String name);

  /// Error: the device declined the request
  ///
  /// In en, this message translates to:
  /// **'{name} declined.'**
  String errorDeclined(String name);

  /// Error: the device didn't answer in time
  ///
  /// In en, this message translates to:
  /// **'{name} didn\'t answer in time.'**
  String errorTimeout(String name);

  /// Error: the device is no longer paired
  ///
  /// In en, this message translates to:
  /// **'{name} isn\'t paired anymore. Pair again to share.'**
  String errorNotPaired(String name);

  /// Error: the device doesn't support this
  ///
  /// In en, this message translates to:
  /// **'{name} can\'t do that yet.'**
  String errorUnsupported(String name);

  /// Error: the device only allows this on the same network
  ///
  /// In en, this message translates to:
  /// **'{name} allows that only on the same network. Its owner can allow everything from away for this phone.'**
  String errorNotFromAway(String name);

  /// Generic error for an invalid request
  ///
  /// In en, this message translates to:
  /// **'That didn’t work.'**
  String get errorInvalid;

  /// Generic error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorSomethingWrong;

  /// Generic error with technical detail
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {detail}'**
  String errorSomethingWrongDetail(String detail);

  /// Fallback name of the computer in terminal refusal messages
  ///
  /// In en, this message translates to:
  /// **'The computer'**
  String get terminalRefusedComputer;

  /// Terminal refused: the code was wrong
  ///
  /// In en, this message translates to:
  /// **'Wrong code.'**
  String get terminalRefusedCode;

  /// Terminal refused: wrong code, with tries left
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Wrong code, 1 try left.} other{Wrong code, {count} tries left.}}'**
  String terminalRefusedCodeTries(int count);

  /// Terminal refused: locked after too many wrong codes
  ///
  /// In en, this message translates to:
  /// **'Too many wrong codes. Unlock the terminal on {name}.'**
  String terminalRefusedLocked(String name);

  /// Terminal refused: the computer has terminal turned off for this phone; 'Allow Terminal' is a setting on the computer
  ///
  /// In en, this message translates to:
  /// **'On {name}, open this phone’s page and allow the terminal there.'**
  String terminalRefusedOff(String name);

  /// Terminal refused from away; “Allow Everything From Away” is a setting on the computer
  ///
  /// In en, this message translates to:
  /// **'{name} allows a terminal only on the same network, unless “Allow Everything From Away” is on there.'**
  String terminalRefusedAway(String name);

  /// Terminal refused: not supported
  ///
  /// In en, this message translates to:
  /// **'{name} can\'t open a terminal.'**
  String terminalRefusedUnsupported(String name);

  /// Terminal refused: limit of 8 terminals reached
  ///
  /// In en, this message translates to:
  /// **'8 terminals already run on {name} for this phone. Close one first.'**
  String terminalRefusedLimit(String name);

  /// Terminal refused: the computer's user declined
  ///
  /// In en, this message translates to:
  /// **'{name} didn’t allow it.'**
  String terminalRefusedDeclined(String name);

  /// Device description, e.g. 'Linux laptop'; os is the OS name, kind a device kind word
  ///
  /// In en, this message translates to:
  /// **'{os} {kind}'**
  String modelDescription(String os, String kind);

  /// Device kind, used inside modelDescription
  ///
  /// In en, this message translates to:
  /// **'desktop'**
  String get modelKindDesktop;

  /// Device kind, used inside modelDescription
  ///
  /// In en, this message translates to:
  /// **'laptop'**
  String get modelKindLaptop;

  /// Device kind, used inside modelDescription
  ///
  /// In en, this message translates to:
  /// **'phone'**
  String get modelKindPhone;

  /// Device kind, used inside modelDescription
  ///
  /// In en, this message translates to:
  /// **'tablet'**
  String get modelKindTablet;

  /// OS name when the device's OS is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get modelOsUnknown;

  /// Device timeline: the selected filter has no entries
  ///
  /// In en, this message translates to:
  /// **'Nothing of that kind yet.'**
  String get deviceNothingOfKind;

  /// Device page: battery level
  ///
  /// In en, this message translates to:
  /// **'{level}%'**
  String deviceBattery(int level);

  /// Device page: battery level while charging
  ///
  /// In en, this message translates to:
  /// **'{level}%, charging'**
  String deviceBatteryCharging(int level);

  /// Device page: away access expiry; day is a formatted day
  ///
  /// In en, this message translates to:
  /// **'Reachable from away until {day}'**
  String deviceReachableUntil(String day);

  /// Device page: the computer locks when the phone goes away
  ///
  /// In en, this message translates to:
  /// **'Locks when you leave with this phone'**
  String get deviceLocksWhenLeave;

  /// Tooltip of the back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get deviceBack;

  /// Tooltip of the device menu button
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get deviceMore;

  /// Device menu: the device's short ID
  ///
  /// In en, this message translates to:
  /// **'ID {id}'**
  String deviceShortId(String id);

  /// Device menu: replace the device's banner picture
  ///
  /// In en, this message translates to:
  /// **'Change picture'**
  String get deviceChangePicture;

  /// Device menu: set a banner picture for the device
  ///
  /// In en, this message translates to:
  /// **'Add a picture'**
  String get deviceAddPicture;

  /// Device menu: remove the banner picture
  ///
  /// In en, this message translates to:
  /// **'Remove picture'**
  String get deviceRemovePicture;

  /// Device menu: unpair the device
  ///
  /// In en, this message translates to:
  /// **'Forget this device'**
  String get deviceForgetThis;

  /// Forget dialog title; name is the device
  ///
  /// In en, this message translates to:
  /// **'Forget {name}?'**
  String deviceForgetTitle(String name);

  /// Forget dialog body
  ///
  /// In en, this message translates to:
  /// **'You’ll need to pair again to share with it. Its activity on this phone is cleared too.'**
  String get deviceForgetBody;

  /// Forget dialog: confirm button
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get deviceForget;

  /// Forget dialog: cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deviceCancel;

  /// Device page: main action to send files
  ///
  /// In en, this message translates to:
  /// **'Send files'**
  String get deviceSendFiles;

  /// Caption under Send files
  ///
  /// In en, this message translates to:
  /// **'Photos, documents, anything'**
  String get deviceSendFilesCaption;

  /// Device page action: send the clipboard
  ///
  /// In en, this message translates to:
  /// **'Clipboard'**
  String get deviceClipboard;

  /// Caption of the Clipboard action
  ///
  /// In en, this message translates to:
  /// **'Send what you copied'**
  String get deviceClipboardCaption;

  /// Device page action: make the device chime
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get devicePing;

  /// Caption of the Ping action
  ///
  /// In en, this message translates to:
  /// **'Make it chime'**
  String get devicePingCaption;

  /// Device page action: touchpad / slide remote
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get deviceRemote;

  /// Caption of the Remote action
  ///
  /// In en, this message translates to:
  /// **'Touchpad and slides'**
  String get deviceRemoteCaption;

  /// Find action while the device rings
  ///
  /// In en, this message translates to:
  /// **'Ringing…'**
  String get deviceRinging;

  /// Find action: ring the device to find it
  ///
  /// In en, this message translates to:
  /// **'Find it'**
  String get deviceFindIt;

  /// Caption of the Find action while ringing
  ///
  /// In en, this message translates to:
  /// **'Tap to stop'**
  String get deviceTapToStop;

  /// Caption of the Find action
  ///
  /// In en, this message translates to:
  /// **'Make it ring loudly'**
  String get deviceFindItCaption;

  /// Media control: previous track
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get devicePrevious;

  /// Media control: pause
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get devicePause;

  /// Media control: play
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get devicePlay;

  /// Media control: next track
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get deviceNext;

  /// Message after asking to see a computer's screen; name is the computer
  ///
  /// In en, this message translates to:
  /// **'Allow it on {name}…'**
  String deviceAllowOn(String name);

  /// Card title: view the computer's screen
  ///
  /// In en, this message translates to:
  /// **'See its screen'**
  String get deviceSeeScreen;

  /// Caption of the See its screen card
  ///
  /// In en, this message translates to:
  /// **'Watch it here, or control it with touch'**
  String get deviceSeeScreenCaption;

  /// Button: watch the computer's screen
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get deviceWatch;

  /// Button: control the computer's screen with touch
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get deviceControl;

  /// Card title: a shell on the computer
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get deviceTerminal;

  /// Terminal card caption when none is open; name is the computer
  ///
  /// In en, this message translates to:
  /// **'A shell on {name}, locked by its code'**
  String deviceTerminalShell(String name);

  /// Terminal card caption: how many terminals are open
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 terminal open} other{{count} terminals open}}'**
  String deviceTerminalsOpen(int count);

  /// Timeline filter: everything
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get deviceFilterAll;

  /// Timeline filter: files
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get deviceFilterFiles;

  /// Timeline filter: clipboard
  ///
  /// In en, this message translates to:
  /// **'Clipboard'**
  String get deviceFilterClipboard;

  /// Timeline filter: links
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get deviceFilterLinks;

  /// Screen reader label of the All filter
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get deviceFilterShowAll;

  /// Screen reader label of the Files filter
  ///
  /// In en, this message translates to:
  /// **'Show Files'**
  String get deviceFilterShowFiles;

  /// Screen reader label of the Clipboard filter
  ///
  /// In en, this message translates to:
  /// **'Show Clipboard'**
  String get deviceFilterShowClipboard;

  /// Screen reader label of the Links filter
  ///
  /// In en, this message translates to:
  /// **'Show Links'**
  String get deviceFilterShowLinks;

  /// Section heading above the device's timeline
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get deviceActivity;

  /// This phone as webcam/mic/display: idle state; name is the computer
  ///
  /// In en, this message translates to:
  /// **'Ready when {name} asks'**
  String deviceReadyWhenAsks(String name);

  /// This phone as: webcam row
  ///
  /// In en, this message translates to:
  /// **'Webcam'**
  String get deviceWebcam;

  /// This phone as: the webcam or microphone is live
  ///
  /// In en, this message translates to:
  /// **'In use now'**
  String get deviceInUseNow;

  /// Button: open the webcam controls
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get deviceControls;

  /// This phone as: microphone row
  ///
  /// In en, this message translates to:
  /// **'Microphone'**
  String get deviceMicrophone;

  /// Button: stop the microphone
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get deviceStop;

  /// This phone as: second display row
  ///
  /// In en, this message translates to:
  /// **'Second display'**
  String get deviceSecondDisplay;

  /// This phone as: the second display is live
  ///
  /// In en, this message translates to:
  /// **'Showing now'**
  String get deviceShowingNow;

  /// Second display idle, with this phone's screen size in pixels
  ///
  /// In en, this message translates to:
  /// **'Ready · {width} × {height}'**
  String deviceReadySize(int width, int height);

  /// Card title: what this phone can be for the computer
  ///
  /// In en, this message translates to:
  /// **'This phone as'**
  String get devicePhoneAs;

  /// Card note: these are started from the computer; name is the computer
  ///
  /// In en, this message translates to:
  /// **'Started on {name}'**
  String deviceStartedOn(String name);

  /// Hint under This phone as
  ///
  /// In en, this message translates to:
  /// **'Faster and steadier over a USB cable.'**
  String get deviceFasterOverUsb;

  /// Switch: back up photos to the computer
  ///
  /// In en, this message translates to:
  /// **'Back up photos'**
  String get deviceBackUpPhotos;

  /// Photo backup off; name is the computer
  ///
  /// In en, this message translates to:
  /// **'New photos go to {name}’s Pictures folder'**
  String devicePhotosGoTo(String name);

  /// Photo backup refused by the computer; the quoted text is the desktop app's setting name
  ///
  /// In en, this message translates to:
  /// **'{name} doesn’t take photos. Turn on “Import Photos From Phones” there.'**
  String devicePhotosDeclined(String name);

  /// Photo backup on: the folder photos are taken from
  ///
  /// In en, this message translates to:
  /// **'From {folder}'**
  String devicePhotosFrom(String folder);

  /// Photo backup on, default folder
  ///
  /// In en, this message translates to:
  /// **'From your camera folder'**
  String get devicePhotosFromCamera;

  /// Photo backup: time of the last backup, shown after a separator
  ///
  /// In en, this message translates to:
  /// **'last {time}'**
  String devicePhotosLast(String time);

  /// Switch: receive the computer's clipboard
  ///
  /// In en, this message translates to:
  /// **'Get its clipboard'**
  String get deviceGetClipboard;

  /// Detail of Get its clipboard; name is the computer
  ///
  /// In en, this message translates to:
  /// **'Text copied on {name} lands here while connected'**
  String deviceGetClipboardDetail(String name);

  /// Switch: allow all features when not on the same network
  ///
  /// In en, this message translates to:
  /// **'Allow everything from away'**
  String get deviceAwayAll;

  /// Detail of Allow everything from away, on
  ///
  /// In en, this message translates to:
  /// **'From away too: this screen, webcam, microphone and files'**
  String get deviceAwayAllOn;

  /// Detail of Allow everything from away, off
  ///
  /// In en, this message translates to:
  /// **'From away: clipboard, links, files and ring only'**
  String get deviceAwayAllOff;

  /// Empty device timeline title
  ///
  /// In en, this message translates to:
  /// **'Nothing shared yet'**
  String get deviceNothingShared;

  /// Empty device timeline body; name is the device
  ///
  /// In en, this message translates to:
  /// **'Files, clipboard text and pings between this phone and {name} line up here.'**
  String deviceNothingSharedBody(String name);

  /// Timeline title: several files sent at once
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String activityItems(int count);

  /// Timeline title: clipboard text, quoted
  ///
  /// In en, this message translates to:
  /// **'“{text}”'**
  String activityQuoted(String text);

  /// Timeline title: clipboard text without content
  ///
  /// In en, this message translates to:
  /// **'Clipboard text'**
  String get activityClipboardText;

  /// Timeline title: a ping
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get activityPing;

  /// Timeline title: this phone's screen was shared
  ///
  /// In en, this message translates to:
  /// **'Your screen'**
  String get activityYourScreen;

  /// Timeline title: this phone's camera was used as a webcam
  ///
  /// In en, this message translates to:
  /// **'Your camera'**
  String get activityYourCamera;

  /// Timeline title: this phone was a second display
  ///
  /// In en, this message translates to:
  /// **'Second display'**
  String get activitySecondDisplay;

  /// Timeline title fallback for a link
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get activityLink;

  /// Timeline title: the computer rang this phone
  ///
  /// In en, this message translates to:
  /// **'Rang this phone'**
  String get activityRangThisPhone;

  /// Timeline title: this phone rang the computer
  ///
  /// In en, this message translates to:
  /// **'Rang it'**
  String get activityRangIt;

  /// Timeline title: remote control session
  ///
  /// In en, this message translates to:
  /// **'Touchpad and keyboard'**
  String get activityTouchpadKeyboard;

  /// Timeline title: the computer's screen was watched
  ///
  /// In en, this message translates to:
  /// **'Its screen'**
  String get activityItsScreen;

  /// Timeline title: this phone's microphone was used
  ///
  /// In en, this message translates to:
  /// **'Your microphone'**
  String get activityYourMicrophone;

  /// Timeline title: location request
  ///
  /// In en, this message translates to:
  /// **'Where this phone is'**
  String get activityWhereThisPhone;

  /// Timeline detail: screen being watched
  ///
  /// In en, this message translates to:
  /// **'Watching now'**
  String get activityWatchingNow;

  /// Timeline detail: screen was watched
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get activityWatched;

  /// Timeline detail: camera live as webcam
  ///
  /// In en, this message translates to:
  /// **'In use as a webcam'**
  String get activityInUseWebcam;

  /// Timeline detail: camera was a webcam
  ///
  /// In en, this message translates to:
  /// **'Used as a webcam'**
  String get activityUsedWebcam;

  /// Timeline detail: screen being controlled
  ///
  /// In en, this message translates to:
  /// **'Being controlled now'**
  String get activityBeingControlled;

  /// Timeline detail: screen was watched and controlled
  ///
  /// In en, this message translates to:
  /// **'Watched and controlled'**
  String get activityWatchedControlled;

  /// Timeline detail: the computer's screen was watched
  ///
  /// In en, this message translates to:
  /// **'Watched from this phone'**
  String get activityWatchedFromPhone;

  /// Timeline detail: session live
  ///
  /// In en, this message translates to:
  /// **'In use now'**
  String get activityInUseNow;

  /// Timeline detail: remote control ended
  ///
  /// In en, this message translates to:
  /// **'This phone was its touchpad'**
  String get activityWasTouchpad;

  /// Timeline detail: second display ended
  ///
  /// In en, this message translates to:
  /// **'This phone was its second display'**
  String get activityWasSecondDisplay;

  /// Timeline detail: incoming link
  ///
  /// In en, this message translates to:
  /// **'Link received'**
  String get activityLinkReceived;

  /// Timeline detail: link sent and opened
  ///
  /// In en, this message translates to:
  /// **'Opened on the computer'**
  String get activityOpenedOnComputer;

  /// Timeline detail: microphone live
  ///
  /// In en, this message translates to:
  /// **'In use as a microphone'**
  String get activityInUseMicrophone;

  /// Timeline detail: microphone ended
  ///
  /// In en, this message translates to:
  /// **'Used as a microphone'**
  String get activityUsedMicrophone;

  /// Timeline detail: location request declined
  ///
  /// In en, this message translates to:
  /// **'Not told'**
  String get activityNotTold;

  /// Timeline detail: location shared
  ///
  /// In en, this message translates to:
  /// **'Told it where this phone is'**
  String get activityToldWhere;

  /// Timeline detail: the computer rang this phone
  ///
  /// In en, this message translates to:
  /// **'Asked to find this phone'**
  String get activityAskedToFind;

  /// Timeline detail: this phone rang the computer
  ///
  /// In en, this message translates to:
  /// **'To find it'**
  String get activityToFindIt;

  /// Timeline status: declined
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get activityDeclined;

  /// Timeline status: failed
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get activityFailed;

  /// Timeline status: in progress
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get activityInProgress;

  /// Timeline status: clipboard received on this phone
  ///
  /// In en, this message translates to:
  /// **'Copied here'**
  String get activityCopiedHere;

  /// Timeline status: received
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get activityReceived;

  /// Timeline status: sent
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get activitySent;

  /// Tooltip: stop a live session
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get activityStop;

  /// Tooltip: cancel a transfer
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get activityCancel;

  /// Tooltip: copy clipboard text again
  ///
  /// In en, this message translates to:
  /// **'Copy again'**
  String get activityCopyAgain;

  /// Message after copying
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get activityCopied;

  /// Tooltip: copy a link
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get activityCopyLink;

  /// Message after copying a link
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get activityLinkCopied;

  /// Error: no app can open the link
  ///
  /// In en, this message translates to:
  /// **'No app here opens that link.'**
  String get activityNoAppForLink;

  /// Sheet title listing received files
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String activityFiles(int count);

  /// Error: the received file was moved or deleted; name is the file
  ///
  /// In en, this message translates to:
  /// **'{name} isn’t there anymore.'**
  String activityFileMissing(String name);

  /// Error: no app opens the file; name is the file
  ///
  /// In en, this message translates to:
  /// **'No app on this phone opens {name}.'**
  String activityNoAppForFile(String name);

  /// Transfer waiting for this phone's user
  ///
  /// In en, this message translates to:
  /// **'Waiting for you to accept…'**
  String get activityWaitingForYou;

  /// Transfer waiting for an unknown device
  ///
  /// In en, this message translates to:
  /// **'Waiting for the device to accept…'**
  String get activityWaitingForDevice;

  /// Transfer waiting for the other device; name is the device
  ///
  /// In en, this message translates to:
  /// **'Waiting for {name} to accept…'**
  String activityWaitingFor(String name);

  /// Transfer progress; both are formatted sizes like 2.1 MB
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String activityProgress(String done, String total);

  /// Tooltip of the gear button on the home screen that opens Settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// Section label above the list of paired devices (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Your devices'**
  String get homeYourDevices;

  /// Section label above devices found on the network but not paired yet (shown in capitals).
  ///
  /// In en, this message translates to:
  /// **'Nearby, not paired'**
  String get homeNearbyNotPaired;

  /// Floating button on the home screen that starts pairing a new device.
  ///
  /// In en, this message translates to:
  /// **'Add a device'**
  String get homeAddDevice;

  /// Line under the top bar: this phone can be found by other devices. name is this phone's name.
  ///
  /// In en, this message translates to:
  /// **'{name} is visible on this Wi-Fi'**
  String homeVisible(String name);

  /// Title of a warning card when the computers run a newer protocol than this app.
  ///
  /// In en, this message translates to:
  /// **'Update Linksy to keep connecting'**
  String get homeUpdateTitle;

  /// Body of the update warning card.
  ///
  /// In en, this message translates to:
  /// **'Your computers now speak a newer Linksy than this app.'**
  String get homeUpdateBody;

  /// Button on the update warning card that opens the download page.
  ///
  /// In en, this message translates to:
  /// **'Get the update'**
  String get homeGetUpdate;

  /// Accessibility label of the round send button on a device row.
  ///
  /// In en, this message translates to:
  /// **'Send files'**
  String get homeSendFiles;

  /// Button on a nearby unpaired device row that starts pairing.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get homePair;

  /// Step 1 of 'Connect your first device'.
  ///
  /// In en, this message translates to:
  /// **'Open Linksy on your computer'**
  String get homeStepOpen;

  /// Step 2 of 'Connect your first device'. “Pair with QR Code” is the desktop app's menu item; translate it as the desktop app does.
  ///
  /// In en, this message translates to:
  /// **'Choose “Add Device”'**
  String get homeStepChoose;

  /// Step 3 of 'Connect your first device'; 'it' is the QR code.
  ///
  /// In en, this message translates to:
  /// **'Scan it with this phone'**
  String get homeStepScan;

  /// Large title on the empty home screen. Keep the line break where it reads well.
  ///
  /// In en, this message translates to:
  /// **'Connect your\nfirst device'**
  String get homeConnectTitle;

  /// Subtitle under 'Connect your first device'.
  ///
  /// In en, this message translates to:
  /// **'Straight over your Wi-Fi. No account, no cloud.'**
  String get homeConnectSubtitle;

  /// Main button on the empty home screen that opens the QR scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get homeScanQr;

  /// Secondary button on the empty home screen: pair by typing the computer's IP address.
  ///
  /// In en, this message translates to:
  /// **'Pair by address instead'**
  String get homePairByAddress;

  /// Title of the 'Add a device' bottom sheet.
  ///
  /// In en, this message translates to:
  /// **'Add a device'**
  String get pairingAddDevice;

  /// Hint in the 'Add a device' sheet. “Pair with QR Code” is the desktop app's menu item.
  ///
  /// In en, this message translates to:
  /// **'On the other device, open Linksy and choose “Add Device”.'**
  String get pairingAddDeviceHint;

  /// Option in the 'Add a device' sheet that opens the QR scanner.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get pairingScanQr;

  /// Caption under 'Scan QR code' in the 'Add a device' sheet.
  ///
  /// In en, this message translates to:
  /// **'Fastest. Nothing to type.'**
  String get pairingScanQrCaption;

  /// Option in the 'Add a device' sheet, and title of the dialog to type a computer's IP address.
  ///
  /// In en, this message translates to:
  /// **'Pair by address'**
  String get pairingByAddress;

  /// Caption under 'Pair by address' in the 'Add a device' sheet.
  ///
  /// In en, this message translates to:
  /// **'When the other device can’t be found.'**
  String get pairingByAddressCaption;

  /// Snack bar while pairing starts with a device. name is the device's name.
  ///
  /// In en, this message translates to:
  /// **'Pairing with {name}…'**
  String pairingWith(String name);

  /// Snack bar while pairing starts from a pairing link that carries no device name.
  ///
  /// In en, this message translates to:
  /// **'Pairing with the other device…'**
  String get pairingWithOtherDevice;

  /// Hint in the 'Pair by address' dialog: where to find the address.
  ///
  /// In en, this message translates to:
  /// **'It’s in Linksy’s Preferences on the other device.'**
  String get pairingAddressHint;

  /// Hint under the address field: the default network port. port is a number like 47200; do not format it.
  ///
  /// In en, this message translates to:
  /// **'Port {port} unless you add another.'**
  String pairingPortHint(String port);

  /// Button in the 'Pair by address' dialog that starts pairing.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pairingPair;

  /// Title of the pairing dialog when another device asked to pair. name is that device's name.
  ///
  /// In en, this message translates to:
  /// **'{name} wants to pair'**
  String pairingWantsToPair(String name);

  /// Title of the pairing dialog when this phone asked to pair. name is the other device's name.
  ///
  /// In en, this message translates to:
  /// **'Pair with {name}'**
  String pairingPairWith(String name);

  /// Under the pairing dialog title, above the 6-digit code.
  ///
  /// In en, this message translates to:
  /// **'Both screens should show this code.'**
  String get pairingCodeHint;

  /// Accessibility label of the 6-digit pairing code. code is like '123 456'.
  ///
  /// In en, this message translates to:
  /// **'Code {code}'**
  String pairingCodeLabel(String code);

  /// Button in the pairing dialog to accept: the codes on both screens are the same.
  ///
  /// In en, this message translates to:
  /// **'Codes match'**
  String get pairingCodesMatch;

  /// Shown in the scanner when camera permission was refused.
  ///
  /// In en, this message translates to:
  /// **'Linksy needs the camera to scan the pairing code. Allow it, or pair by address.'**
  String get scanNeedsCamera;

  /// Shown in the scanner when the camera can't start.
  ///
  /// In en, this message translates to:
  /// **'The camera isn’t available.'**
  String get scanCameraUnavailable;

  /// Tooltip of the flashlight button in the QR scanner.
  ///
  /// In en, this message translates to:
  /// **'Flashlight'**
  String get scanFlashlight;

  /// Large title over the QR scanner's camera view.
  ///
  /// In en, this message translates to:
  /// **'Scan the code'**
  String get scanTitle;

  /// Shown in the scanner when a QR code that isn't a Linksy pairing code was scanned. 'Pair with QR Code' is the desktop app's menu item.
  ///
  /// In en, this message translates to:
  /// **'That’s not a Linksy code. On your computer, open Linksy → Pair with QR Code.'**
  String get scanWrongCode;

  /// Hint at the bottom of the QR scanner. “Pair with QR Code” is the desktop app's menu item.
  ///
  /// In en, this message translates to:
  /// **'On your computer, open Linksy and choose “Add Device”.'**
  String get scanHint;

  /// Title of the share sheet when one shared file goes onto a computer's clipboard.
  ///
  /// In en, this message translates to:
  /// **'Put on a clipboard'**
  String get shareSheetPutOnClipboard;

  /// Title of the share sheet when files were shared to Linksy from another app.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Send a file} other{Send {count} files}}'**
  String shareSheetSendFiles(int count);

  /// Title of the share sheet when a web link was shared: it opens in a computer's browser.
  ///
  /// In en, this message translates to:
  /// **'Open on a computer'**
  String get shareSheetOpenOnComputer;

  /// Title of the share sheet when text was shared: it goes to a computer's clipboard.
  ///
  /// In en, this message translates to:
  /// **'Send to a clipboard'**
  String get shareSheetSendToClipboard;

  /// Share sheet, no computer supports files on its clipboard.
  ///
  /// In en, this message translates to:
  /// **'None of your computers takes files on its clipboard yet. Update Linksy there.'**
  String get shareSheetNoClipboardFiles;

  /// Share sheet, no paired computer yet.
  ///
  /// In en, this message translates to:
  /// **'Pair a computer first, then share to it from any app.'**
  String get shareSheetNoComputers;

  /// Share sheet button: send the file normally rather than onto the clipboard.
  ///
  /// In en, this message translates to:
  /// **'Send the file instead'**
  String get shareSheetSendFileInstead;

  /// Share sheet button: put the one shared file onto the computer's clipboard.
  ///
  /// In en, this message translates to:
  /// **'Put it on the computer’s clipboard instead'**
  String get shareSheetClipboardInstead;

  /// Share sheet button: open the shared link in the computer's browser.
  ///
  /// In en, this message translates to:
  /// **'Open the link instead'**
  String get shareSheetOpenLinkInstead;

  /// Share sheet button: send the shared link as text to the computer's clipboard.
  ///
  /// In en, this message translates to:
  /// **'Send as text to the clipboard instead'**
  String get shareSheetSendAsTextInstead;

  /// Snack bar after sharing a file onto a computer's clipboard. name is the computer's name.
  ///
  /// In en, this message translates to:
  /// **'Putting it on {name}’s clipboard'**
  String shareSheetPuttingOnClipboard(String name);

  /// Snack bar after sharing a file onto a computer's clipboard, when its name isn't known.
  ///
  /// In en, this message translates to:
  /// **'Putting it on the computer’s clipboard'**
  String get shareSheetPuttingOnClipboardUnnamed;

  /// Snack bar after a shared link was opened on a computer. name is the computer's name.
  ///
  /// In en, this message translates to:
  /// **'Opened on {name}'**
  String shareSheetOpened(String name);

  /// Snack bar after a shared link was opened on a computer whose name isn't known.
  ///
  /// In en, this message translates to:
  /// **'Opened on the computer'**
  String get shareSheetOpenedUnnamed;

  /// Snack bar after shared text was sent to a computer's clipboard. name is the computer's name.
  ///
  /// In en, this message translates to:
  /// **'Sent to {name}’s clipboard'**
  String shareSheetSentToClipboard(String name);

  /// Snack bar after shared text was sent to a computer's clipboard, when its name isn't known.
  ///
  /// In en, this message translates to:
  /// **'Sent to the computer’s clipboard'**
  String get shareSheetSentToClipboardUnnamed;

  /// Title of the dialog when a computer sent a web link to this phone. name is the computer's name.
  ///
  /// In en, this message translates to:
  /// **'{name} sent a link'**
  String shareSheetSentALink(String name);

  /// Button in the received-link dialog: open the link on this phone.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get shareSheetOpen;

  /// Button in the received-link dialog: copy the link.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get shareSheetCopyLink;

  /// Snack bar after copying a received link.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get shareSheetLinkCopied;

  /// Title of the incoming-files sheet. name is the sending device's name (shown in a stronger color).
  ///
  /// In en, this message translates to:
  /// **'{name} is sending you {count, plural, =1{a file} other{{count} files}}'**
  String incomingSendingYou(String name, int count);

  /// Total size of the incoming files. size is like '2.1 MB'.
  ///
  /// In en, this message translates to:
  /// **'{size} in total'**
  String incomingTotal(String size);

  /// Under the first few incoming file names: how many more files there are.
  ///
  /// In en, this message translates to:
  /// **'+ {count} more'**
  String incomingMore(int count);

  /// Button in the incoming-files sheet: receive the files.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get incomingAccept;

  /// Snack bar when a linksy:// pairing link can't be read.
  ///
  /// In en, this message translates to:
  /// **'That pairing link isn’t valid.'**
  String get appInvalidPairingLink;

  /// Snack bar when pairing failed. reason is an explanation (may be in English).
  ///
  /// In en, this message translates to:
  /// **'Pairing failed: {reason}'**
  String appPairingFailed(String reason);

  /// Snack bar when pairing with a device failed. name is the device's name; reason is an explanation.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t pair with {name}: {reason}'**
  String appCouldntPair(String name, String reason);

  /// Snack bar when pairing succeeded. name is the device's name.
  ///
  /// In en, this message translates to:
  /// **'Paired with {name}'**
  String appPairedWith(String name);

  /// Snack bar showing a notification a computer sent: its name, then the notification's text.
  ///
  /// In en, this message translates to:
  /// **'{name}: {text}'**
  String appNotification(String name, String text);

  /// Snack bar when a computer put text on this phone's clipboard. name is the computer's name.
  ///
  /// In en, this message translates to:
  /// **'Copied text from {name}'**
  String appCopiedText(String name);

  /// Snack bar when a computer put a file on this phone's clipboard. file is the file name; name is the computer's name.
  ///
  /// In en, this message translates to:
  /// **'Copied {file} from {name}'**
  String appCopiedFile(String file, String name);

  /// Title of the screen shown when the app fails to start; an error message follows.
  ///
  /// In en, this message translates to:
  /// **'Linksy couldn’t start'**
  String get appCouldntStart;

  /// Tooltip of the close button on a notice card.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get commonDismiss;

  /// Generic Cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Button to refuse a pairing request or incoming files.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get commonDecline;

  /// Tooltip of a close (X) button.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Button that closes a dialog without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get commonNotNow;

  /// A device's status: connected right now.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get commonConnected;

  /// A device's status: found on the same network, not connected.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get commonNearby;

  /// A device's status: not found on the network.
  ///
  /// In en, this message translates to:
  /// **'Not nearby'**
  String get commonNotNearby;

  /// How a device is reached, in lists: over a USB cable.
  ///
  /// In en, this message translates to:
  /// **'USB cable'**
  String get commonUsbCable;

  /// How a device is reached, in lists: over the internet (not on the same Wi-Fi).
  ///
  /// In en, this message translates to:
  /// **'Away from home'**
  String get commonAwayFromHome;

  /// How a device is reached, in lists: on the same Wi-Fi network.
  ///
  /// In en, this message translates to:
  /// **'Same Wi-Fi'**
  String get commonSameWifi;

  /// A device's status: connected over a USB cable.
  ///
  /// In en, this message translates to:
  /// **'Connected by USB'**
  String get commonConnectedByUsb;

  /// A device's status: connected over the internet.
  ///
  /// In en, this message translates to:
  /// **'Connected away from home'**
  String get commonConnectedAway;

  /// Accessibility label of a device's battery ring. level is 0 to 100.
  ///
  /// In en, this message translates to:
  /// **'Battery {level} percent'**
  String commonBattery(int level);

  /// Accessibility label of a device's battery ring while it charges. level is 0 to 100.
  ///
  /// In en, this message translates to:
  /// **'Battery {level} percent, charging'**
  String commonBatteryCharging(int level);

  /// A size under 1 kB, like '512 bytes'.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} bytes}}'**
  String formatBytesSmall(int count);

  /// Time left in a transfer.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second left} other{{count} seconds left}}'**
  String formatSecondsLeft(int count);

  /// Time left in a transfer.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute left} other{{count} minutes left}}'**
  String formatMinutesLeft(int count);

  /// Time left in a transfer, rounded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{about 1 hour left} other{about {count} hours left}}'**
  String formatHoursLeft(int count);

  /// Day heading in a device's timeline.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get formatToday;

  /// Day heading in a device's timeline.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get formatYesterday;

  /// Name of this phone's main storage in folder paths, like 'Phone › Download › Linksy'.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get formatPhone;

  /// Tooltip of the back button on the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get settingsBack;

  /// Title of the Settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section label: receiving files
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get settingsReceiving;

  /// Settings row: where received files are saved
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get settingsSaveLocation;

  /// Settings row caption: the folder received files go to (Downloads folder, then Linksy subfolder)
  ///
  /// In en, this message translates to:
  /// **'Downloads › Linksy'**
  String get settingsSaveLocationPath;

  /// Settings switch: accept files from paired devices automatically
  ///
  /// In en, this message translates to:
  /// **'Accept from my devices'**
  String get settingsAcceptFromMyDevices;

  /// Caption of the auto-accept switch
  ///
  /// In en, this message translates to:
  /// **'Files from paired devices arrive without asking.'**
  String get settingsAcceptFromMyDevicesCaption;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsConnection;

  /// Settings switch: keep connections to nearby devices open
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get settingsStayConnected;

  /// Caption of the Stay connected switch
  ///
  /// In en, this message translates to:
  /// **'Faster sharing with nearby devices. Uses more battery.'**
  String get settingsStayConnectedCaption;

  /// Settings switch: keep the app running when closed
  ///
  /// In en, this message translates to:
  /// **'Keep running in the background'**
  String get settingsKeepRunning;

  /// Caption of the background switch
  ///
  /// In en, this message translates to:
  /// **'Files, photo backup and calls keep working when Linksy is closed. Shows a quiet notification.'**
  String get settingsKeepRunningCaption;

  /// Settings switch: reach computers over the internet
  ///
  /// In en, this message translates to:
  /// **'Away from home'**
  String get settingsAwayFromHome;

  /// Caption of the Away from home switch
  ///
  /// In en, this message translates to:
  /// **'Reach your computers over the internet when you’re not on the same network, for a week after you last were. Encrypted end to end.'**
  String get settingsAwayFromHomeCaption;

  /// Settings row: the relay used away from home; opens a dialog to change it
  ///
  /// In en, this message translates to:
  /// **'Relay server'**
  String get settingsRelay;

  /// Caption of the Relay server row when no relay of the user's own is set
  ///
  /// In en, this message translates to:
  /// **'Linksy’s own'**
  String get settingsRelayDefault;

  /// Caption of the dialog that asks for the relay's address
  ///
  /// In en, this message translates to:
  /// **'The address of a relay you host yourself, like https://relay.example.com. Leave it empty for Linksy’s own. Set the same relay on every device.'**
  String get settingsRelayCaption;

  /// Settings section label: features shared with paired computers
  ///
  /// In en, this message translates to:
  /// **'With your computers'**
  String get settingsWithYourComputers;

  /// Settings switch: computers pause media during phone calls
  ///
  /// In en, this message translates to:
  /// **'Pause music during calls'**
  String get settingsPauseMusic;

  /// Caption of the Pause music switch
  ///
  /// In en, this message translates to:
  /// **'Your computers pause what plays while a call rings or goes on, and resume after.'**
  String get settingsPauseMusicCaption;

  /// Settings switch: share a phone folder with computers
  ///
  /// In en, this message translates to:
  /// **'Let computers browse files'**
  String get settingsBrowseFiles;

  /// Caption when no shared folder is chosen yet
  ///
  /// In en, this message translates to:
  /// **'Choose a folder your computers can open in their Files app, like Documents (Android doesn’t allow Download).'**
  String get settingsBrowseFilesChoose;

  /// Caption showing the folder shared with computers
  ///
  /// In en, this message translates to:
  /// **'Shares “{folder}”. Tap to choose another folder.'**
  String settingsSharesFolder(String folder);

  /// Settings row: the picture computers show for this phone
  ///
  /// In en, this message translates to:
  /// **'Picture of this phone'**
  String get settingsPicture;

  /// Caption when no picture is chosen
  ///
  /// In en, this message translates to:
  /// **'Your computers show it for this phone. Tap to choose one.'**
  String get settingsPictureChoose;

  /// Caption when a picture is chosen
  ///
  /// In en, this message translates to:
  /// **'Your computers show it for this phone. Tap to change it.'**
  String get settingsPictureChange;

  /// Button that removes the phone picture
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get settingsPictureRemove;

  /// Settings switch: allow computers to ask for the phone location
  ///
  /// In en, this message translates to:
  /// **'Let computers locate this phone'**
  String get settingsLocate;

  /// Caption of the locate switch
  ///
  /// In en, this message translates to:
  /// **'A computer can ask where this phone is, once, to find it. Nothing is kept or tracked. Works while Linksy is open.'**
  String get settingsLocateCaption;

  /// Message when the location permission was refused
  ///
  /// In en, this message translates to:
  /// **'Linksy needs the location permission for this.'**
  String get settingsLocatePermission;

  /// Settings row: the camera folder backed up to computers
  ///
  /// In en, this message translates to:
  /// **'Photo folder'**
  String get settingsPhotoFolder;

  /// Caption when no photo folder is chosen
  ///
  /// In en, this message translates to:
  /// **'Choose your camera folder (DCIM › Camera) to back up photos to a computer.'**
  String get settingsPhotoFolderChoose;

  /// Caption showing the backed-up photo folder
  ///
  /// In en, this message translates to:
  /// **'Backs up “{folder}”. Turn it on per computer, on its page.'**
  String settingsPhotoFolderBacksUp(String folder);

  /// Settings section label: app preferences
  ///
  /// In en, this message translates to:
  /// **'This app'**
  String get settingsThisApp;

  /// Settings section label
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsPermissions;

  /// Settings section label for the demo tools
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get settingsDemo;

  /// Explanation of the demo section
  ///
  /// In en, this message translates to:
  /// **'Simulated devices until the Linksy core is connected. These start what another device would.'**
  String get settingsDemoCaption;

  /// Demo action: simulate incoming files
  ///
  /// In en, this message translates to:
  /// **'Receive files'**
  String get settingsDemoReceiveFiles;

  /// Demo action: simulate an incoming pairing request
  ///
  /// In en, this message translates to:
  /// **'Receive a pairing request'**
  String get settingsDemoReceivePairing;

  /// Demo action: simulate incoming clipboard text
  ///
  /// In en, this message translates to:
  /// **'Receive clipboard text'**
  String get settingsDemoReceiveClipboard;

  /// App tagline at the bottom of Settings (two lines)
  ///
  /// In en, this message translates to:
  /// **'Your devices, connected.\nNo account, no cloud.'**
  String get settingsTagline;

  /// Title of the rename dialog
  ///
  /// In en, this message translates to:
  /// **'Name this phone'**
  String get settingsNameTitle;

  /// Subtitle of the rename dialog
  ///
  /// In en, this message translates to:
  /// **'Your other devices see this name.'**
  String get settingsNameCaption;

  /// Button in the rename dialog
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingsSave;

  /// Button in the rename dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// Accessibility label of the phone card; name is the phone name
  ///
  /// In en, this message translates to:
  /// **'Rename {name}'**
  String settingsRename(String name);

  /// Under the phone name; shortId is a short device code
  ///
  /// In en, this message translates to:
  /// **'This phone · {shortId}'**
  String settingsThisPhone(String shortId);

  /// Settings row that opens the permissions sheet
  ///
  /// In en, this message translates to:
  /// **'Notifications and camera'**
  String get settingsPermissionsRow;

  /// Caption of the permissions row while loading
  ///
  /// In en, this message translates to:
  /// **'What Linksy asks Android for, and why.'**
  String get settingsPermissionsWhat;

  /// Caption when both permissions are allowed
  ///
  /// In en, this message translates to:
  /// **'Both allowed.'**
  String get settingsPermissionsBoth;

  /// Caption when some of the 2 permissions are allowed
  ///
  /// In en, this message translates to:
  /// **'{count, plural, other{{count} of 2 allowed. Tap to allow the rest.}}'**
  String settingsPermissionsSome(int count);

  /// Title of the permissions sheet
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// Intro text of the permissions sheet
  ///
  /// In en, this message translates to:
  /// **'Linksy asks only for what it needs, and you can change any of these later in Settings.'**
  String get permissionsIntro;

  /// Permission name: notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get permissionsNotifications;

  /// Why the app needs the notifications permission
  ///
  /// In en, this message translates to:
  /// **'Shows when a computer sees your screen or uses your camera, with a button to stop it.'**
  String get permissionsNotificationsWhy;

  /// Permission name: camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionsCamera;

  /// Why the app needs the camera permission
  ///
  /// In en, this message translates to:
  /// **'Scans the pairing QR code, and lets a computer use this phone as a webcam when you allow it.'**
  String get permissionsCameraWhy;

  /// Button that asks Android for a permission
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permissionsAllow;

  /// Shown when a permission is already granted
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permissionsAllowed;

  /// Button that closes the permissions sheet
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get permissionsDone;

  /// Tooltip of the back button on the Remote screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get remoteBack;

  /// Title of the screen that uses the phone as a computer remote
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remoteTitle;

  /// Title while waiting for the computer to allow remote control; name is the computer
  ///
  /// In en, this message translates to:
  /// **'Allow it on {name}'**
  String remoteAllowOn(String name);

  /// Detail while waiting for the computer to allow remote control
  ///
  /// In en, this message translates to:
  /// **'Linksy on {name} asks whether this phone may move its pointer and type.'**
  String remoteAsks(String name);

  /// Title when the remote could not start
  ///
  /// In en, this message translates to:
  /// **'That didn’t work'**
  String get remoteFailed;

  /// Title when the computer ended the remote
  ///
  /// In en, this message translates to:
  /// **'The remote stopped'**
  String get remoteStopped;

  /// Detail when the computer ended the remote; name is the computer
  ///
  /// In en, this message translates to:
  /// **'{name} ended it.'**
  String remoteEndedBy(String name);

  /// Button that retries starting the remote
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get remoteTryAgain;

  /// Remote mode tab: touchpad
  ///
  /// In en, this message translates to:
  /// **'Touchpad'**
  String get remoteTouchpad;

  /// Remote mode tab: presentation remote
  ///
  /// In en, this message translates to:
  /// **'Slides'**
  String get remoteSlides;

  /// Hint on the touchpad area (two lines)
  ///
  /// In en, this message translates to:
  /// **'Move with one finger, tap to click\nTwo fingers scroll, two-finger tap right-clicks'**
  String get remoteTouchpadHint;

  /// Touchpad button
  ///
  /// In en, this message translates to:
  /// **'Left click'**
  String get remoteLeftClick;

  /// Touchpad button
  ///
  /// In en, this message translates to:
  /// **'Right click'**
  String get remoteRightClick;

  /// Button that shows the keyboard to type on the computer
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get remoteKeyboard;

  /// Accessibility label of the Next button
  ///
  /// In en, this message translates to:
  /// **'Next slide'**
  String get remoteNextSlide;

  /// Big button: next slide
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get remoteNext;

  /// Accessibility label of the Back button
  ///
  /// In en, this message translates to:
  /// **'Previous slide'**
  String get remotePreviousSlide;

  /// Big button: previous slide
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get remoteSlideBack;

  /// Button that starts the slideshow (sends F5)
  ///
  /// In en, this message translates to:
  /// **'Start (F5)'**
  String get remoteStartShow;

  /// Button that ends the slideshow (sends Esc)
  ///
  /// In en, this message translates to:
  /// **'End (Esc)'**
  String get remoteEndShow;

  /// Hint under the slide buttons
  ///
  /// In en, this message translates to:
  /// **'Volume down: next · Volume up: back. The screen stays on.'**
  String get remoteVolumeHint;

  /// Big title while the phone rings because a computer is looking for it
  ///
  /// In en, this message translates to:
  /// **'Here I am!'**
  String get ringTitle;

  /// Under the title; name is the computer that rings the phone
  ///
  /// In en, this message translates to:
  /// **'{name} is looking for this phone.'**
  String ringLookingFor(String name);

  /// Button that stops the ringing
  ///
  /// In en, this message translates to:
  /// **'Found it'**
  String get ringFoundIt;

  /// Tooltip: go back from the webcam screen
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get webcamBack;

  /// Webcam screen title
  ///
  /// In en, this message translates to:
  /// **'Webcam'**
  String get webcamTitle;

  /// Webcam screen subtitle; name is the computer receiving the picture
  ///
  /// In en, this message translates to:
  /// **'Live on {name}'**
  String webcamLiveOn(String name);

  /// Accessibility label of the Stop button
  ///
  /// In en, this message translates to:
  /// **'Stop the webcam'**
  String get webcamStopSemantic;

  /// Button that stops the webcam
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get webcamStop;

  /// Badge over the preview while streaming (uppercase)
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get webcamBadgeLive;

  /// Badge: auto exposure / auto focus locked (uppercase)
  ///
  /// In en, this message translates to:
  /// **'AE/AF LOCK'**
  String get webcamBadgeLock;

  /// Badge: manual focus (short abbreviation)
  ///
  /// In en, this message translates to:
  /// **'MF'**
  String get webcamBadgeManualFocus;

  /// Badge: the flashlight is on (uppercase)
  ///
  /// In en, this message translates to:
  /// **'TORCH'**
  String get webcamBadgeTorch;

  /// Action label: the front camera is in use
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get webcamFacingFront;

  /// Action label: the back camera is in use
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get webcamFacingBack;

  /// Action: turn the flashlight on/off
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get webcamTorch;

  /// Orientation: upright
  ///
  /// In en, this message translates to:
  /// **'Portrait'**
  String get webcamPortrait;

  /// Orientation: sideways
  ///
  /// In en, this message translates to:
  /// **'Landscape'**
  String get webcamLandscape;

  /// Action label: exposure and white balance are locked
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get webcamLocked;

  /// Action: lock exposure and white balance
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get webcamLock;

  /// Settings tab: exposure
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get webcamTabLight;

  /// Settings tab: focus
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get webcamTabFocus;

  /// Settings tab: white balance
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get webcamTabColor;

  /// Settings tab: stream format
  ///
  /// In en, this message translates to:
  /// **'Stream'**
  String get webcamTabStream;

  /// Setting title: exposure compensation
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get webcamBrightness;

  /// Exposure compensation value; value is a signed number like +0.7
  ///
  /// In en, this message translates to:
  /// **'{value} EV'**
  String webcamExposureValue(String value);

  /// Shown when the camera has no exposure control
  ///
  /// In en, this message translates to:
  /// **'This camera sets exposure by itself.'**
  String get webcamExposureAuto;

  /// Setting title
  ///
  /// In en, this message translates to:
  /// **'Lock exposure'**
  String get webcamLockExposure;

  /// Lock exposure explanation
  ///
  /// In en, this message translates to:
  /// **'Keeps the brightness as it is now. Hold the picture to lock on a spot.'**
  String get webcamLockExposureDetail;

  /// Setting title
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get webcamFocus;

  /// Shown when focus cannot be changed
  ///
  /// In en, this message translates to:
  /// **'This camera has fixed focus.'**
  String get webcamFocusFixed;

  /// Focus explanation in spot mode
  ///
  /// In en, this message translates to:
  /// **'Held where you tapped. Double-tap the picture for auto.'**
  String get webcamFocusSpotDetail;

  /// Focus explanation in manual mode
  ///
  /// In en, this message translates to:
  /// **'Set by hand below.'**
  String get webcamFocusManualDetail;

  /// Focus explanation in auto mode
  ///
  /// In en, this message translates to:
  /// **'Follows the picture. Tap it to focus on a spot.'**
  String get webcamFocusAutoDetail;

  /// Focus mode option
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get webcamFocusAuto;

  /// Focus mode option: focus on a tapped point
  ///
  /// In en, this message translates to:
  /// **'Spot'**
  String get webcamFocusSpot;

  /// Focus mode option
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get webcamFocusManual;

  /// Setting title: manual focus distance
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get webcamDistance;

  /// Left end of the focus distance slider
  ///
  /// In en, this message translates to:
  /// **'Far'**
  String get webcamFar;

  /// Right end of the focus distance slider
  ///
  /// In en, this message translates to:
  /// **'Near'**
  String get webcamNear;

  /// White balance option
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get webcamWbAuto;

  /// White balance option
  ///
  /// In en, this message translates to:
  /// **'Daylight'**
  String get webcamWbDaylight;

  /// White balance option
  ///
  /// In en, this message translates to:
  /// **'Cloudy'**
  String get webcamWbCloudy;

  /// White balance option
  ///
  /// In en, this message translates to:
  /// **'Shade'**
  String get webcamWbShade;

  /// White balance option: incandescent bulbs
  ///
  /// In en, this message translates to:
  /// **'Warm light'**
  String get webcamWbIncandescent;

  /// White balance option: fluorescent tubes
  ///
  /// In en, this message translates to:
  /// **'Office light'**
  String get webcamWbFluorescent;

  /// Setting title
  ///
  /// In en, this message translates to:
  /// **'White balance'**
  String get webcamWhiteBalance;

  /// Setting title: white balance lock
  ///
  /// In en, this message translates to:
  /// **'Lock colors'**
  String get webcamLockColors;

  /// Lock colors explanation
  ///
  /// In en, this message translates to:
  /// **'Stops the colors shifting as the light changes.'**
  String get webcamLockColorsDetail;

  /// Setting title
  ///
  /// In en, this message translates to:
  /// **'Orientation'**
  String get webcamOrientation;

  /// Portrait orientation explanation
  ///
  /// In en, this message translates to:
  /// **'Hold the phone upright; bars at the sides.'**
  String get webcamOrientationPortraitDetail;

  /// Landscape orientation explanation
  ///
  /// In en, this message translates to:
  /// **'Hold the phone sideways; it fills the frame.'**
  String get webcamOrientationLandscapeDetail;

  /// Setting title
  ///
  /// In en, this message translates to:
  /// **'Frame rate'**
  String get webcamFrameRate;

  /// Explanation of 60 fps
  ///
  /// In en, this message translates to:
  /// **'Smoother motion; uses more data and battery.'**
  String get webcamFps60Detail;

  /// Explanation of 30 fps
  ///
  /// In en, this message translates to:
  /// **'Steady for video calls.'**
  String get webcamFps30Detail;

  /// Shown when 60 fps is not available
  ///
  /// In en, this message translates to:
  /// **'This camera does up to 30 fps.'**
  String get webcamFpsOnly30;

  /// Frame rate option; fps is a number like 30
  ///
  /// In en, this message translates to:
  /// **'{fps} fps'**
  String webcamFps(String fps);

  /// Setting title
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get webcamResolution;

  /// Explanation of 1080p
  ///
  /// In en, this message translates to:
  /// **'Full HD, for a big screen; more data.'**
  String get webcamResolution1080Detail;

  /// Explanation of 720p
  ///
  /// In en, this message translates to:
  /// **'HD, right for video calls.'**
  String get webcamResolution720Detail;

  /// Shown when 1080p is not available
  ///
  /// In en, this message translates to:
  /// **'This camera streams 720p.'**
  String get webcamResolutionOnly720;

  /// Setting title: bitrate
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get webcamQuality;

  /// Saver quality explanation; mbps is a number
  ///
  /// In en, this message translates to:
  /// **'{mbps} Mbps, for a busy Wi-Fi.'**
  String webcamQualitySaverDetail(String mbps);

  /// High quality explanation; mbps is a number
  ///
  /// In en, this message translates to:
  /// **'{mbps} Mbps, the most detail.'**
  String webcamQualityHighDetail(String mbps);

  /// Standard quality explanation; mbps is a number
  ///
  /// In en, this message translates to:
  /// **'{mbps} Mbps, sharp for video calls.'**
  String webcamQualityStandardDetail(String mbps);

  /// Quality option: low bitrate
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get webcamQualitySaver;

  /// Quality option
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get webcamQualityStandard;

  /// Quality option: high bitrate
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get webcamQualityHigh;

  /// Setting title: video stabilization
  ///
  /// In en, this message translates to:
  /// **'Stabilization'**
  String get webcamStabilization;

  /// Stabilization explanation
  ///
  /// In en, this message translates to:
  /// **'Smooths out hand shake.'**
  String get webcamStabilizationDetail;

  /// Setting title (front camera)
  ///
  /// In en, this message translates to:
  /// **'Mirror the preview'**
  String get webcamMirror;

  /// Mirror explanation
  ///
  /// In en, this message translates to:
  /// **'On this phone only; the computer gets it unmirrored.'**
  String get webcamMirrorDetail;

  /// Setting title: the stream format summary
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get webcamFormat;

  /// Stream format summary, e.g. 1280×720 · 30 fps · H.264
  ///
  /// In en, this message translates to:
  /// **'{width}×{height} · {fps} fps · H.264'**
  String webcamFormatValue(String width, String height, String fps);

  /// Button: reset a setting to its default
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get webcamReset;

  /// Accessibility label of Reset; setting is the setting title
  ///
  /// In en, this message translates to:
  /// **'Reset {setting}'**
  String webcamResetSetting(String setting);

  /// Accessibility label of a zoom chip; zoom is like 2×
  ///
  /// In en, this message translates to:
  /// **'Zoom {zoom}'**
  String webcamZoomTo(String zoom);

  /// Request dialog title; name is a computer
  ///
  /// In en, this message translates to:
  /// **'{name} wants to see your screen'**
  String sharingScreenRequestTitle(String name);

  /// Screen share request explanation
  ///
  /// In en, this message translates to:
  /// **'Everything on this phone’s screen shows on {name} until you stop. Android asks you to confirm next.'**
  String sharingScreenRequestDetail(String name);

  /// Request dialog title; name is a computer
  ///
  /// In en, this message translates to:
  /// **'{name} wants to control your screen'**
  String sharingControlRequestTitle(String name);

  /// Remote control request explanation
  ///
  /// In en, this message translates to:
  /// **'{name} sees this phone’s screen and can tap, swipe and type on it until you stop. Android asks you to confirm next.'**
  String sharingControlRequestDetail(String name);

  /// Request dialog title; name is a computer
  ///
  /// In en, this message translates to:
  /// **'{name} wants to use your camera'**
  String sharingCameraRequestTitle(String name);

  /// Webcam request explanation
  ///
  /// In en, this message translates to:
  /// **'{name} gets this phone’s camera as a webcam until you stop. Zoom, focus, light, lenses and rotation are in Linksy while it runs.'**
  String sharingCameraRequestDetail(String name);

  /// Request dialog title; name is a computer
  ///
  /// In en, this message translates to:
  /// **'{name} wants to use this phone as a touchpad'**
  String sharingInputRequestTitle(String name);

  /// Touchpad request warning
  ///
  /// In en, this message translates to:
  /// **'Unexpected: computers don’t ask this. Don’t allow it.'**
  String get sharingInputRequestDetail;

  /// Request dialog title; name is a computer
  ///
  /// In en, this message translates to:
  /// **'{name} wants to use your microphone'**
  String sharingMicrophoneRequestTitle(String name);

  /// Microphone request explanation
  ///
  /// In en, this message translates to:
  /// **'{name} hears this phone’s microphone until you stop, as a microphone any of its apps can use. Android asks you to confirm next.'**
  String sharingMicrophoneRequestDetail(String name);

  /// Request dialog title; name is a computer
  ///
  /// In en, this message translates to:
  /// **'{name} wants to use this screen as a second display'**
  String sharingDisplayRequestTitle(String name);

  /// Second display request explanation
  ///
  /// In en, this message translates to:
  /// **'This phone shows a screen of {name} full screen. Touch it to click and drag; scroll with two fingers. Go back to stop.'**
  String sharingDisplayRequestDetail(String name);

  /// Request dialog: accept
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get sharingAllow;

  /// Request dialog: refuse
  ///
  /// In en, this message translates to:
  /// **'Don’t allow'**
  String get sharingDontAllow;

  /// Hint about Android 15 screen share protection; the quoted text is the Android setting name
  ///
  /// In en, this message translates to:
  /// **'Top bar or notifications black on the computer? Android’s screen share protection hides them. Turn on “Disable screen share protections” in Developer options, then share again.'**
  String get sharingProtectionHint;

  /// Dismiss the hint
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get sharingGotIt;

  /// Opens Android's Developer options
  ///
  /// In en, this message translates to:
  /// **'Developer options'**
  String get sharingDeveloperOptions;

  /// Live share banner
  ///
  /// In en, this message translates to:
  /// **'{name} is controlling your screen'**
  String sharingControlling(String name);

  /// Live share banner
  ///
  /// In en, this message translates to:
  /// **'{name} is using your camera'**
  String sharingUsingCamera(String name);

  /// Live share banner
  ///
  /// In en, this message translates to:
  /// **'{name} is using your microphone'**
  String sharingUsingMicrophone(String name);

  /// Live share banner
  ///
  /// In en, this message translates to:
  /// **'Sharing your screen with {name}'**
  String sharingScreenWith(String name);

  /// Webcam banner subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap for camera controls'**
  String get sharingTapForCameraControls;

  /// Tooltip: flip between front and back camera
  ///
  /// In en, this message translates to:
  /// **'Switch camera'**
  String get sharingSwitchCamera;

  /// Accessibility label of Stop on the banner
  ///
  /// In en, this message translates to:
  /// **'Stop sharing'**
  String get sharingStopSharing;

  /// Banner button that stops the share
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get sharingStop;

  /// Accessibility label: opens the webcam screen
  ///
  /// In en, this message translates to:
  /// **'Camera controls'**
  String get sharingCameraControls;

  /// Hint over the second display; name is a computer
  ///
  /// In en, this message translates to:
  /// **'{name}’s second display · go back to stop'**
  String displaySecondHint(String name);

  /// Hint while controlling a computer's screen
  ///
  /// In en, this message translates to:
  /// **'{name}’s screen · touch to click · go back to stop'**
  String displayControlHint(String name);

  /// Hint while watching a computer's screen
  ///
  /// In en, this message translates to:
  /// **'{name}’s screen · go back to stop'**
  String displayWatchHint(String name);

  /// Message: a terminal tab was closed here
  ///
  /// In en, this message translates to:
  /// **'“{title}” closed'**
  String terminalTabClosed(String title);

  /// Message: the shell ended on the computer
  ///
  /// In en, this message translates to:
  /// **'“{title}” ended on {name}'**
  String terminalTabEnded(String title, String name);

  /// Confirm dialog title
  ///
  /// In en, this message translates to:
  /// **'Close this terminal?'**
  String get terminalCloseTitle;

  /// Confirm dialog text; name is a computer
  ///
  /// In en, this message translates to:
  /// **'The shell ends on {name}, with anything still running in it. To come back to it later, keep it running instead.'**
  String terminalCloseDetail(String name);

  /// Dialog button: detach instead of closing
  ///
  /// In en, this message translates to:
  /// **'Keep running'**
  String get terminalKeepRunning;

  /// Button: close the terminal
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get terminalClose;

  /// Fallback name when the computer's name is unknown, used inside sentences
  ///
  /// In en, this message translates to:
  /// **'the computer'**
  String get terminalTheComputer;

  /// Card title: the shell runs without this phone attached
  ///
  /// In en, this message translates to:
  /// **'Detached'**
  String get terminalDetached;

  /// Detached card text
  ///
  /// In en, this message translates to:
  /// **'Still running on {name}. Reattach to see it again; the code is asked again.'**
  String terminalDetachedDetail(String name);

  /// Button: reconnect to a running shell
  ///
  /// In en, this message translates to:
  /// **'Reattach'**
  String get terminalReattach;

  /// Header status
  ///
  /// In en, this message translates to:
  /// **'Terminal on {name}'**
  String terminalOn(String name);

  /// Header status
  ///
  /// In en, this message translates to:
  /// **'Detached · still running on {name}'**
  String terminalDetachedOn(String name);

  /// Header status
  ///
  /// In en, this message translates to:
  /// **'Opening on {name}…'**
  String terminalOpeningOn(String name);

  /// Header status
  ///
  /// In en, this message translates to:
  /// **'Waiting for the code'**
  String get terminalWaitingForCode;

  /// Header status: the shell has ended
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get terminalEnded;

  /// Tooltip: go back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get terminalBack;

  /// Header title when no tab is open
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminalTitle;

  /// Tooltip of the menu button
  ///
  /// In en, this message translates to:
  /// **'Terminal menu'**
  String get terminalMenu;

  /// Menu item
  ///
  /// In en, this message translates to:
  /// **'Leave it running (detach)'**
  String get terminalDetachMenu;

  /// Accessibility label: close a tab
  ///
  /// In en, this message translates to:
  /// **'Close {title}'**
  String terminalCloseTab(String title);

  /// Button: open a new terminal
  ///
  /// In en, this message translates to:
  /// **'New terminal'**
  String get terminalNew;

  /// Start screen title
  ///
  /// In en, this message translates to:
  /// **'A shell on {name}'**
  String terminalShellOn(String name);

  /// Start screen explanation
  ///
  /// In en, this message translates to:
  /// **'Runs as you on the computer, in your home folder. Each time it opens, it asks for the terminal code set there.'**
  String get terminalShellDetail;

  /// Section header (uppercase): shells still running on the computer
  ///
  /// In en, this message translates to:
  /// **'STILL RUNNING'**
  String get terminalStillRunning;

  /// Accessibility label: reattach a running shell
  ///
  /// In en, this message translates to:
  /// **'Reattach {title}'**
  String terminalReattachTab(String title);

  /// When a running shell was started; time is a formatted clock time
  ///
  /// In en, this message translates to:
  /// **'Started {time}'**
  String terminalStarted(String time);

  /// Key bar: left arrow key
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get terminalKeyLeft;

  /// Key bar: up arrow key
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get terminalKeyUp;

  /// Key bar: down arrow key
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get terminalKeyDown;

  /// Key bar: right arrow key
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get terminalKeyRight;

  /// Code sheet title
  ///
  /// In en, this message translates to:
  /// **'Terminal code'**
  String get terminalCodeTitle;

  /// Code sheet explanation; Preferences › Terminal is the desktop app's menu path
  ///
  /// In en, this message translates to:
  /// **'The code set on {name} in Preferences › Terminal. Linksy never keeps it.'**
  String terminalCodeDetail(String name);

  /// Code field hint when letters are allowed
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get terminalCodePassphrase;

  /// Code field hint for a numeric code
  ///
  /// In en, this message translates to:
  /// **'6 or more digits'**
  String get terminalCodeDigitsHint;

  /// Switch the keyboard to numbers
  ///
  /// In en, this message translates to:
  /// **'Use digits'**
  String get terminalCodeUseDigits;

  /// Switch the keyboard to letters
  ///
  /// In en, this message translates to:
  /// **'Use letters'**
  String get terminalCodeUseLetters;

  /// Button while opening the terminal
  ///
  /// In en, this message translates to:
  /// **'Opening…'**
  String get terminalOpening;

  /// Button: open the terminal with the code
  ///
  /// In en, this message translates to:
  /// **'Open terminal'**
  String get terminalOpen;

  /// Settings row: light, dark or system theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Theme follows the phone's setting.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Brief message when a computer connects through the USB cable
  ///
  /// In en, this message translates to:
  /// **'Connected to {name} by USB cable'**
  String usbConnectedTo(String name);

  /// Dialog title: an unpaired computer is on the USB cable
  ///
  /// In en, this message translates to:
  /// **'A computer is on the cable'**
  String get usbPairTitle;

  /// Dialog text offering to pair over the USB cable
  ///
  /// In en, this message translates to:
  /// **'It isn’t paired with this phone yet. Pair with it over the cable? Both screens show a code to compare.'**
  String get usbPairBody;

  /// Button: pair with the computer on the cable
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get usbPairAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'mg',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'mg':
      return AppLocalizationsMg();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
