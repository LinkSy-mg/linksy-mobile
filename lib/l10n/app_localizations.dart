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

  /// Settings: placeholder of the search field
  ///
  /// In en, this message translates to:
  /// **'Search settings'**
  String get settingsSearch;

  /// Settings search: no setting matches
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”'**
  String settingsNothingMatches(String query);

  /// Settings: label of the card suggesting one thing to set up next
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get settingsRecommended;

  /// Settings section label: receiving files
  ///
  /// In en, this message translates to:
  /// **'Receiving'**
  String get settingsReceiving;

  /// Settings: the page about received files, the shared folder and photo backup
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get settingsFiles;

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

  /// Connection page: label over the list of ways the phone reaches computers (Same Wi-Fi, Away from home, Wi-Fi Direct, USB cable); not buttons
  ///
  /// In en, this message translates to:
  /// **'How it reaches your computers'**
  String get settingsWays;

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

  /// Browse files: computers see one folder the user picks
  ///
  /// In en, this message translates to:
  /// **'A folder you choose'**
  String get settingsFilesFolder;

  /// Browse files: computers see all of the phone's files (Android's All files access)
  ///
  /// In en, this message translates to:
  /// **'All files'**
  String get settingsFilesAll;

  /// Under All files, once allowed
  ///
  /// In en, this message translates to:
  /// **'Your computers can open every file on this phone.'**
  String get settingsFilesAllCaption;

  /// Under All files, before Android allows it
  ///
  /// In en, this message translates to:
  /// **'Allow “All files access” for Linksy in Android’s settings.'**
  String get settingsFilesAllAllow;

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
  /// **'A tall picture with bars at the sides, for apps that want one.'**
  String get webcamOrientationPortraitDetail;

  /// Landscape orientation explanation
  ///
  /// In en, this message translates to:
  /// **'Fills the frame and stays upright, however the phone stands.'**
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

  /// Button on a computer's screen viewer: ask its user to pick another screen
  ///
  /// In en, this message translates to:
  /// **'Choose screen'**
  String get displayChooseScreen;

  /// Shown after Choose screen, while the computer's user picks
  ///
  /// In en, this message translates to:
  /// **'Pick the screen on {name}…'**
  String displayChooseOn(String name);

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

  /// While the phone dials the computer through the USB cable
  ///
  /// In en, this message translates to:
  /// **'Connecting over the USB cable…'**
  String get usbConnecting;

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

  /// Send sheet: pick from the photo picker
  ///
  /// In en, this message translates to:
  /// **'Photos and videos'**
  String get sendPhotos;

  /// Caption under Photos and videos
  ///
  /// In en, this message translates to:
  /// **'From your gallery, many at once'**
  String get sendPhotosCaption;

  /// Send sheet: pick any file
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get sendFiles;

  /// Caption under Files
  ///
  /// In en, this message translates to:
  /// **'Documents and everything else'**
  String get sendFilesCaption;

  /// Timeline title: several photos sent at once
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String activityPhotos(int count);

  /// Timeline title: several videos sent at once
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 video} other{{count} videos}}'**
  String activityVideos(int count);

  /// Timeline title: photos and videos sent at once
  ///
  /// In en, this message translates to:
  /// **'{count} photos and videos'**
  String activityPhotosVideos(int count);

  /// Title of the page listing files on their way
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfersTitle;

  /// Transfers page: no bytes moving yet (the other side has not accepted)
  ///
  /// In en, this message translates to:
  /// **'Waiting to start'**
  String get transfersWaiting;

  /// Transfers page: files finished out of all
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} files'**
  String transfersFilesDone(int done, int total);

  /// Transfers page: files going to a device
  ///
  /// In en, this message translates to:
  /// **'To {name}'**
  String transfersTo(String name);

  /// Transfers page: files coming from a device
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String transfersFrom(String name);

  /// Transfers page when nothing is left
  ///
  /// In en, this message translates to:
  /// **'All done'**
  String get transfersAllDone;

  /// Accessibility label of the round transfer button
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file on its way} other{{count} files on their way}}'**
  String transfersBubble(int count);

  /// Title of the What's New page
  ///
  /// In en, this message translates to:
  /// **'What’s New'**
  String get newsTitle;

  /// Heading on the What's New page
  ///
  /// In en, this message translates to:
  /// **'What’s New in Linksy {version}'**
  String newsHeading(String version);

  /// Link to the full release notes
  ///
  /// In en, this message translates to:
  /// **'All Changes in {version}'**
  String newsAllChanges(String version);

  /// Button that closes What's New
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get newsContinue;

  /// Button that opens Linksy on GitHub
  ///
  /// In en, this message translates to:
  /// **'Star Linksy on GitHub'**
  String get newsStar;

  /// Under the GitHub star button
  ///
  /// In en, this message translates to:
  /// **'Linksy is free and open source. A star on GitHub helps others find it.'**
  String get newsStarCaption;

  /// 0.2.4 highlight: private discovery
  ///
  /// In en, this message translates to:
  /// **'Private on Every Network'**
  String get news024PrivateTitle;

  /// 0.2.4 highlight body
  ///
  /// In en, this message translates to:
  /// **'On a café’s or an office’s Wi-Fi, strangers no longer see this phone’s name. Your computers still find it, and Add Device shows it to a new one.'**
  String get news024PrivateBody;

  /// 0.2.4 highlight: Update Now
  ///
  /// In en, this message translates to:
  /// **'Update in One Tap'**
  String get news024UpdateTitle;

  /// 0.2.4 highlight body
  ///
  /// In en, this message translates to:
  /// **'When a new version is out, Update Now downloads it and checks it, then Android installs it.'**
  String get news024UpdateBody;

  /// 0.2.4 highlight: What's New
  ///
  /// In en, this message translates to:
  /// **'What’s New, Right Here'**
  String get news024NewsTitle;

  /// 0.2.4 highlight body
  ///
  /// In en, this message translates to:
  /// **'Each update now shows what changed, the first time it opens. It’s also in Settings.'**
  String get news024NewsBody;

  /// Card and sheet title when a newer version is out
  ///
  /// In en, this message translates to:
  /// **'Linksy {version} Is Available'**
  String updateAvailable(String version);

  /// Update sheet text
  ///
  /// In en, this message translates to:
  /// **'This is {current}. Linksy downloads the update and checks it, then Android asks you to install it.'**
  String updateBody(String current);

  /// Button that downloads and installs the update
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// Closes the update sheet
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// Update sheet: title of the release notes card
  ///
  /// In en, this message translates to:
  /// **'What changed in {version}'**
  String updateWhatChanged(String version);

  /// Update sheet: small label above the file that will be installed
  ///
  /// In en, this message translates to:
  /// **'To be installed'**
  String get updateToInstall;

  /// Download progress
  ///
  /// In en, this message translates to:
  /// **'Downloading, {percent}%'**
  String updateDownloading(String percent);

  /// While Android's installer runs
  ///
  /// In en, this message translates to:
  /// **'Android is installing it…'**
  String get updateInstalling;

  /// After Check for Updates finds nothing newer
  ///
  /// In en, this message translates to:
  /// **'Linksy {version} is the newest version.'**
  String updateNewest(String version);

  /// Settings row that checks for a newer version
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get updateCheck;

  /// Download failed
  ///
  /// In en, this message translates to:
  /// **'The download didn’t finish. Check the connection and try again.'**
  String get updateFailedNetwork;

  /// Checksum mismatch or missing
  ///
  /// In en, this message translates to:
  /// **'The download doesn’t match the release’s checksum, so it wasn’t installed.'**
  String get updateFailedCheck;

  /// Linksy may not install apps yet
  ///
  /// In en, this message translates to:
  /// **'Allow Linksy to install apps, then tap Update Now again.'**
  String get updateAllow;

  /// The installer refused
  ///
  /// In en, this message translates to:
  /// **'Android didn’t install it: {message}'**
  String updateFailedInstall(String message);

  /// Settings switch: a computer's music shows as a media notification on the phone
  ///
  /// In en, this message translates to:
  /// **'Music in notifications'**
  String get settingsMediaNotice;

  /// Caption of the media notification switch
  ///
  /// In en, this message translates to:
  /// **'What your computers play shows with the phone\'s notifications, with its buttons.'**
  String get settingsMediaNoticeCaption;

  /// Settings switch: two-finger scrolling on the remote touchpad goes the other way
  ///
  /// In en, this message translates to:
  /// **'Reverse scrolling'**
  String get settingsReverseScroll;

  /// Caption of the reverse scrolling switch
  ///
  /// In en, this message translates to:
  /// **'Two fingers scroll the other way, on the touchpad and on a computer\'s screen.'**
  String get settingsReverseScrollCaption;

  /// Presentation remote button: shows or hides a number pad
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get remoteNumbers;

  /// Number pad key that deletes (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get remoteBackspace;

  /// Number pad key Enter (accessibility label)
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get remoteEnter;

  /// Media control: 10 seconds back (tooltip)
  ///
  /// In en, this message translates to:
  /// **'10 seconds back'**
  String get deviceBack10;

  /// Media control: 10 seconds forward (tooltip)
  ///
  /// In en, this message translates to:
  /// **'10 seconds forward'**
  String get deviceForward10;

  /// What's New in 0.2.5
  ///
  /// In en, this message translates to:
  /// **'Your computer\'s music, in notifications'**
  String get news025MediaTitle;

  /// What's New in 0.2.5
  ///
  /// In en, this message translates to:
  /// **'What it plays shows with the phone\'s notifications: play, skip, 10 seconds back or forward, and a seek bar. Also on its page.'**
  String get news025MediaBody;

  /// What's New in 0.2.5
  ///
  /// In en, this message translates to:
  /// **'Numbers on the presenter remote'**
  String get news025NumbersTitle;

  /// What's New in 0.2.5
  ///
  /// In en, this message translates to:
  /// **'Type a slide\'s number, then Enter, to jump to it. The keyboard works there too.'**
  String get news025NumbersBody;

  /// What's New in 0.2.5
  ///
  /// In en, this message translates to:
  /// **'Smoother remote'**
  String get news025RemoteTitle;

  /// What's New in 0.2.5
  ///
  /// In en, this message translates to:
  /// **'Capitals no longer leave Shift stuck on the computer, and two-finger scrolling can go the other way (Settings).'**
  String get news025RemoteBody;

  /// The computer's volume: mute it (tooltip)
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get deviceMute;

  /// The computer's volume: unmute it (tooltip)
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get deviceUnmute;

  /// The computer's volume slider, for screen readers
  ///
  /// In en, this message translates to:
  /// **'Volume {percent} %'**
  String deviceVolume(String percent);

  /// What's New 0.2.6: the computer's volume (title)
  ///
  /// In en, this message translates to:
  /// **'The computer\'s volume'**
  String get news026VolumeTitle;

  /// What's New 0.2.6: the computer's volume (body)
  ///
  /// In en, this message translates to:
  /// **'Turn it up or down from its page, or with this phone\'s volume keys while the page is open.'**
  String get news026VolumeBody;

  /// Transfers page with nothing going (title)
  ///
  /// In en, this message translates to:
  /// **'Nothing on its way'**
  String get transfersNone;

  /// Transfers page with nothing going (body)
  ///
  /// In en, this message translates to:
  /// **'Files you send or receive show up here, with their speed.'**
  String get transfersNoneBody;

  /// Transfers page: finished transfers (section label)
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get transfersRecent;

  /// Transfers: the speed as something felt
  ///
  /// In en, this message translates to:
  /// **'A 1 GB movie every {seconds} s'**
  String transfersFastMovie(int seconds);

  /// Transfers: the speed as photos (about 3 MB each)
  ///
  /// In en, this message translates to:
  /// **'About {count} photos a second'**
  String transfersFastPhotos(int count);

  /// Transfers: the speed as songs (about 5 MB each)
  ///
  /// In en, this message translates to:
  /// **'{count} songs a second'**
  String transfersFastSongs(int count);

  /// What's New 0.2.6: the transfers page (title)
  ///
  /// In en, this message translates to:
  /// **'Transfers, always a tap away'**
  String get news026TransfersTitle;

  /// What's New 0.2.6: the transfers page (body)
  ///
  /// In en, this message translates to:
  /// **'The button at the bottom left opens Transfers any time: files flowing at their real speed, each file\'s progress, and what came and went lately.'**
  String get news026TransfersBody;

  /// Home's bottom island: open the whole list (Transfers)
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get islandSeeMore;

  /// A transfer goes over a Wi-Fi Direct link between the two devices (brand name, usually kept).
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Direct'**
  String get transfersRouteDirect;

  /// A Wi-Fi Direct link is being set up before a big transfer starts.
  ///
  /// In en, this message translates to:
  /// **'Setting up Wi-Fi Direct'**
  String get transfersRouteDirectSetup;

  /// Setting up a Wi-Fi Direct link: looking for the other device, by its name. Short, it sits in a small pill.
  ///
  /// In en, this message translates to:
  /// **'Finding {name}'**
  String transfersDirectFinding(String name);

  /// No description provided for @transfersDirectConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get transfersDirectConnecting;

  /// No description provided for @transfersDirectLinking.
  ///
  /// In en, this message translates to:
  /// **'Linking up'**
  String get transfersDirectLinking;

  /// What's New 0.2.8: Wi-Fi Direct (title)
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Direct for big files'**
  String get news028DirectTitle;

  /// What's New 0.2.8: Wi-Fi Direct (body)
  ///
  /// In en, this message translates to:
  /// **'Files of 256 MB or more go straight to your computer over a Wi-Fi link of their own, much faster than through the router. Needs Linksy 0.9.9 on the computer.'**
  String get news028DirectBody;

  /// What's New 0.2.8: big files and background transfers (title)
  ///
  /// In en, this message translates to:
  /// **'Big files, in the background'**
  String get news028BackgroundTitle;

  /// What's New 0.2.8: big files and background transfers (body)
  ///
  /// In en, this message translates to:
  /// **'Long videos start sending right away, and transfers keep going with the screen off, their progress in the notification bar.'**
  String get news028BackgroundBody;

  /// No description provided for @settingsDirect.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Direct for big files'**
  String get settingsDirect;

  /// No description provided for @settingsDirectCaption.
  ///
  /// In en, this message translates to:
  /// **'Faster, straight to the other device. Off: always through your Wi-Fi.'**
  String get settingsDirectCaption;

  /// No description provided for @settingsLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get settingsLogs;

  /// No description provided for @settingsLogsCaption.
  ///
  /// In en, this message translates to:
  /// **'What happened lately, for a bug report'**
  String get settingsLogsCaption;

  /// No description provided for @logsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Logs stay on this phone. Nothing is sent anywhere: copy them yourself when you report a problem.'**
  String get logsPrivacy;

  /// No description provided for @logsThisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get logsThisPhone;

  /// No description provided for @logsEvents.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get logsEvents;

  /// No description provided for @logsCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get logsCopy;

  /// No description provided for @logsCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get logsCopied;

  /// No description provided for @logsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing yet. Connections, transfers and Wi-Fi Direct steps show up here.'**
  String get logsEmpty;

  /// No description provided for @news029PhonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi Direct between phones'**
  String get news029PhonesTitle;

  /// No description provided for @news029PhonesBody.
  ///
  /// In en, this message translates to:
  /// **'Big files between two phones now go straight from one to the other, without the router. Both need Linksy 0.2.9. You can turn it off in Settings.'**
  String get news029PhonesBody;

  /// No description provided for @news029LogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get news029LogsTitle;

  /// No description provided for @news029LogsBody.
  ///
  /// In en, this message translates to:
  /// **'Settings › Logs shows this phone and what happened lately, to copy into a bug report. They stay on this phone.'**
  String get news029LogsBody;

  /// Small dim line under the pairing code when the other device has an older Linksy (pairing still works).
  ///
  /// In en, this message translates to:
  /// **'Updating Linksy on {name} makes pairing even safer.'**
  String pairingUpdateOlder(String name);

  /// Settings › With your computers: switch that mirrors this phone's notifications to paired computers
  ///
  /// In en, this message translates to:
  /// **'Show this phone\'s notifications'**
  String get settingsPhoneNotifications;

  /// Caption of that switch
  ///
  /// In en, this message translates to:
  /// **'On your computers, with Reply for messages.'**
  String get settingsPhoneNotificationsCaption;

  /// Caption (shown in red) when the switch is wanted but Android's Notification access isn't allowed
  ///
  /// In en, this message translates to:
  /// **'Android hasn\'t allowed it yet. Tap to allow notification access.'**
  String get settingsPhoneNotificationsAllow;

  /// Sheet title: guide to allow Notification access
  ///
  /// In en, this message translates to:
  /// **'Allow notification access'**
  String get noticeAccessTitle;

  /// Android 13+: Notification access is greyed out for apps installed from a browser (restricted settings)
  ///
  /// In en, this message translates to:
  /// **'Android greys out the switch for apps installed from the web. To allow it:'**
  String get noticeAccessGreyed;

  /// Step 1 of the restricted settings guide
  ///
  /// In en, this message translates to:
  /// **'Open App info for Linksy.'**
  String get noticeAccessStepInfo;

  /// Step 2: Android's own label is Allow restricted settings
  ///
  /// In en, this message translates to:
  /// **'Tap ⋮ at the top right, then Allow restricted settings.'**
  String get noticeAccessStepRestricted;

  /// Step 3; Try again is the button below
  ///
  /// In en, this message translates to:
  /// **'Open Notification access again and turn Linksy on.'**
  String get noticeAccessStepAgain;

  /// Before Android 13: just turn Linksy on in Notification access
  ///
  /// In en, this message translates to:
  /// **'Turn Linksy on in Android\'s Notification access, then come back.'**
  String get noticeAccessPlain;

  /// Button opening Android's App info page for Linksy
  ///
  /// In en, this message translates to:
  /// **'Open App info'**
  String get commonOpenAppInfo;

  /// Settings › Connection row and page title: per-brand steps so Android doesn't close Linksy
  ///
  /// In en, this message translates to:
  /// **'Keep Linksy alive'**
  String get batteryGuide;

  /// Caption of that row; maker is the phone's maker as Android writes it (realme, Xiaomi, samsung)
  ///
  /// In en, this message translates to:
  /// **'What to change on this {maker} phone'**
  String batteryGuideCaption(String maker);

  /// Intro of the battery guide page
  ///
  /// In en, this message translates to:
  /// **'To save battery, some phones close apps in the background, and Linksy then misses files and notifications. On this {maker} phone:'**
  String batteryIntro(String maker);

  /// Battery guide step (Xiaomi, vivo): Android's labels
  ///
  /// In en, this message translates to:
  /// **'App info › Autostart: on.'**
  String get batteryAutostart;

  /// Battery guide step (Xiaomi)
  ///
  /// In en, this message translates to:
  /// **'App info › Battery saver: No restrictions.'**
  String get batteryXiaomiSaver;

  /// Battery guide step (Xiaomi, OPPO, realme, OnePlus, vivo, Huawei): lock the app in the recent apps screen
  ///
  /// In en, this message translates to:
  /// **'In recent apps, hold Linksy and tap the lock, so clearing them leaves it running.'**
  String get batteryLockRecents;

  /// Battery guide step (Samsung)
  ///
  /// In en, this message translates to:
  /// **'App info › Battery: Unrestricted.'**
  String get batterySamsungUnrestricted;

  /// Battery guide step (Samsung)
  ///
  /// In en, this message translates to:
  /// **'Settings › Battery › Background usage limits: take Linksy out of Sleeping and Deep sleeping apps.'**
  String get batterySamsungSleeping;

  /// Battery guide step (OPPO, realme, OnePlus)
  ///
  /// In en, this message translates to:
  /// **'App info › Battery usage: allow background activity, foreground activity and auto launch.'**
  String get batteryOppoBackground;

  /// Battery guide step (vivo, iQOO)
  ///
  /// In en, this message translates to:
  /// **'Settings › Battery › Background power consumption: allow Linksy.'**
  String get batteryVivoBackground;

  /// Battery guide step (Huawei, Honor)
  ///
  /// In en, this message translates to:
  /// **'Settings › Battery › App launch › Linksy: manage manually, with Auto-launch, Secondary launch and Run in background on.'**
  String get batteryHuaweiLaunch;

  /// Battery guide step (Pixel and other phones)
  ///
  /// In en, this message translates to:
  /// **'App info › App battery usage: Unrestricted.'**
  String get batteryUnrestricted;

  /// Last step of the battery guide, for every phone
  ///
  /// In en, this message translates to:
  /// **'In Linksy: Settings › Connection › Keep running in the background.'**
  String get batteryKeepRunning;

  /// Small note under the battery guide's steps
  ///
  /// In en, this message translates to:
  /// **'The names change a little between versions of Android.'**
  String get batteryNames;

  /// Update sheet, Important box: Play Protect may block installing Linksy (it can read notifications); steps follow
  ///
  /// In en, this message translates to:
  /// **'Linksy can show your notifications on your computers, so Play Protect may stop the install. If it does:'**
  String get updatePlayProtect;

  /// Step 1 of getting past Play Protect: where its settings are
  ///
  /// In en, this message translates to:
  /// **'Play Store › your picture › Play Protect › ⚙.'**
  String get updateProtectStep1;

  /// Step 2: Play Protect's own label is Scan apps with Play Protect
  ///
  /// In en, this message translates to:
  /// **'Turn off Scan apps with Play Protect.'**
  String get updateProtectStep2;

  /// Step 3; Update Now is the button below
  ///
  /// In en, this message translates to:
  /// **'Tap Update Now again, then turn scanning back on.'**
  String get updateProtectStep3;

  /// What's New: this phone's notifications on its computers
  ///
  /// In en, this message translates to:
  /// **'Your notifications on your computer'**
  String get news032NotificationsTitle;

  /// What's New body; mentions Android 13+ restricted settings
  ///
  /// In en, this message translates to:
  /// **'Messages and other notifications show on your paired computers, with Reply. Turn it on in Settings › With your computers. If Android greys out the switch: App info › ⋮ › Allow restricted settings.'**
  String get news032NotificationsBody;

  /// What's New: the per-brand battery guide (same name as its Settings row)
  ///
  /// In en, this message translates to:
  /// **'Keep Linksy alive'**
  String get news032BatteryTitle;

  /// What's New body
  ///
  /// In en, this message translates to:
  /// **'Settings › Connection › Keep Linksy alive shows what to change on your phone\'s brand so Linksy keeps running in the background.'**
  String get news032BatteryBody;

  /// Settings › This app: a switch for fewer animations (like the phone's own Remove animations)
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// What Reduce motion changes
  ///
  /// In en, this message translates to:
  /// **'Screens fade instead of sliding, and buttons dim instead of shrinking.'**
  String get settingsReduceMotionCaption;

  /// Device page, Control section: the deck, this phone as buttons for the computer (desktop's own name for the feature)
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get deviceDeck;

  /// Under Deck; name is the computer
  ///
  /// In en, this message translates to:
  /// **'Your own buttons for {name}'**
  String deviceDeckCaption(String name);

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get deckEdit;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get deckDone;

  /// Deck screen, waiting for the computer's list of actions
  ///
  /// In en, this message translates to:
  /// **'Asking {name} what the deck may do…'**
  String deckAsking(String name);

  /// Deck screen when the computer isn't connected
  ///
  /// In en, this message translates to:
  /// **'{name} isn\'t connected. The deck works once it is.'**
  String deckAway(String name);

  /// Deck screen when the computer turned on no actions for this phone
  ///
  /// In en, this message translates to:
  /// **'{name} lets the deck do nothing yet. Turn its actions on in Linksy on the computer.'**
  String deckNothingOffered(String name);

  /// An empty page of the deck
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Tap Edit, then Add.'**
  String get deckEmptyPage;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get deckAdd;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Add to the deck'**
  String get deckAddTitle;

  /// On a deck button whose action the computer no longer offers
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get deckUnavailable;

  /// Group of deck actions sent by the computer as Media
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get deckGroupMedia;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get deckGroupSound;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get deckGroupSystem;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Commands'**
  String get deckGroupCommands;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get deckKindButton;

  /// A deck action that switches something on or off
  ///
  /// In en, this message translates to:
  /// **'On or off'**
  String get deckKindToggle;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Slider'**
  String get deckKindSlider;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get deckSize;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get deckSizeSmall;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Wide'**
  String get deckSizeWide;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Tall'**
  String get deckSizeTall;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Big'**
  String get deckSizeBig;

  /// Deck button size: as wide as the whole row
  ///
  /// In en, this message translates to:
  /// **'Full row'**
  String get deckSizeRow;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get deckColor;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get deckIcon;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Remove from the deck'**
  String get deckRemove;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'New page'**
  String get deckNewPage;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Remove this page'**
  String get deckRemovePage;

  /// Deck, editing: how to move a button
  ///
  /// In en, this message translates to:
  /// **'Hold a button and drag it to move it.'**
  String get deckMoveHint;

  /// Settings > Files: computers can browse this phone's photos (their Gallery)
  ///
  /// In en, this message translates to:
  /// **'Photos on your computers'**
  String get settingsGallery;

  /// Deck
  ///
  /// In en, this message translates to:
  /// **'Your computers can look through this phone\'s photos and videos, and save the ones you pick.'**
  String get settingsGalleryCaption;

  /// Snack bar when Android didn't allow photo access
  ///
  /// In en, this message translates to:
  /// **'Allow Linksy to see your photos in Android\'s settings.'**
  String get settingsGalleryDenied;

  /// Group of deck actions the computer offers (Wi-Fi, Bluetooth, airplane mode); the computer sends the group in English
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get deckGroupNetwork;

  /// Group of deck actions the computer offers (power profiles)
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get deckGroupPower;

  /// Sheet title: the deck's look, picked by holding the deck's name
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get deckThemeTitle;

  /// First choice of the theme sheet: the theme picked in the computer's deck editor; name is the computer
  ///
  /// In en, this message translates to:
  /// **'As on {name}'**
  String deckThemeAsMade(String name);

  /// Theme sheet section: the five themes the computer's editor also has
  ///
  /// In en, this message translates to:
  /// **'On the computer too'**
  String get deckThemesShared;

  /// Theme sheet section: themes only the phone has; the choice stays on the phone
  ///
  /// In en, this message translates to:
  /// **'Only on this phone'**
  String get deckThemesPhone;

  /// Deck theme: the GNOME look (the desktop's own translation)
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get deckThemeStock;

  /// Deck theme: black with lit dots (the desktop's own translation)
  ///
  /// In en, this message translates to:
  /// **'Dot Matrix'**
  String get deckThemeDots;

  /// Deck theme: paper and ink (the desktop's own translation)
  ///
  /// In en, this message translates to:
  /// **'E-Ink'**
  String get deckThemeEink;

  /// Deck theme: green terminal (the desktop's own translation)
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get deckThemeTerm;

  /// Deck theme: 16-colour pixel art (the desktop's own translation)
  ///
  /// In en, this message translates to:
  /// **'Pixel'**
  String get deckThemePixel;

  /// Deck theme of the phone: Linksy's own colours (Signal is the name of Linksy's design)
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get deckThemeSignal;

  /// Deck theme of the phone: frosted glass tiles
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get deckThemeGlass;

  /// Deck theme of the phone: black, for a screen kept on at night
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get deckThemeMidnight;

  /// Shown a moment after tapping a deck tile whose action the computer doesn't offer; name is the computer
  ///
  /// In en, this message translates to:
  /// **'Not available on {name}'**
  String deckNotAvailable(String name);

  /// Pill at the top of the deck while the computer isn't connected
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get deckAwayShort;

  /// Shown a moment after tapping a deck tile while the computer isn't connected
  ///
  /// In en, this message translates to:
  /// **'{name} isn\'t connected. The tiles work once it is.'**
  String deckAwayNote(String name);

  /// The deck's music tile when the computer plays nothing
  ///
  /// In en, this message translates to:
  /// **'Nothing playing'**
  String get deckNothingPlaying;

  /// Deck screen when the computer sent layouts but none for this phone
  ///
  /// In en, this message translates to:
  /// **'{name} has no deck for this phone yet. Make one in Linksy on the computer.'**
  String deckNoLayouts(String name);

  /// What's New 0.3.3: the deck, the phone as buttons for the computer, laid out on the computer
  ///
  /// In en, this message translates to:
  /// **'Deck: buttons for your computer'**
  String get news033DeckTitle;

  /// Its page › Control › Deck are the app's own labels
  ///
  /// In en, this message translates to:
  /// **'Play, volume, mute, Wi-Fi and your own commands, laid out in Linksy on the computer and used from here: its page › Control › Deck. Hold the deck\'s name to change its look. Needs the newest Linksy on the computer.'**
  String get news033DeckBody;

  /// What's New 0.3.3: the computer's Gallery shows this phone's photos
  ///
  /// In en, this message translates to:
  /// **'Your photos on your computer'**
  String get news033PhotosTitle;

  /// Settings › Files › Photos on your computers are the app's own labels
  ///
  /// In en, this message translates to:
  /// **'A computer\'s Gallery looks through this phone\'s photos and videos, page by page, and saves the ones you pick. Settings › Files › Photos on your computers.'**
  String get news033PhotosBody;

  /// What's New 0.3.3: earlier messages of a conversation, on the computer
  ///
  /// In en, this message translates to:
  /// **'Earlier messages'**
  String get news033MessagesTitle;

  /// What's New 0.3.3
  ///
  /// In en, this message translates to:
  /// **'On the computer, a conversation shows its earlier messages too, and Reply still works for a day after the notification is gone.'**
  String get news033MessagesBody;

  /// First-run setup row: this phone's messages and notifications in the computer's Inbox. Parallels settingsGallery
  ///
  /// In en, this message translates to:
  /// **'Messages on your computers'**
  String get onboardingMessages;

  /// Under that row, and on a computer's ask. Inbox is the computer's tab, as the desktop translates it
  ///
  /// In en, this message translates to:
  /// **'Read and answer your messages and notifications in the computer\'s Inbox.'**
  String get onboardingMessagesDetail;

  /// Under Photos on your computers in the first-run setup, and on a computer's ask. Gallery is the computer's tab; Allow all is Android's own label for photos and videos
  ///
  /// In en, this message translates to:
  /// **'Look through this phone\'s photos and videos in the computer\'s Gallery. When Android asks, pick Allow all.'**
  String get onboardingGalleryDetail;

  /// One-time home card for people updating, when the computer's Inbox or Gallery isn't on
  ///
  /// In en, this message translates to:
  /// **'Your messages and photos on your computers'**
  String get homeTurnOnTitle;

  /// Under that title
  ///
  /// In en, this message translates to:
  /// **'See them in the computer\'s Inbox and Gallery.'**
  String get homeTurnOnBody;

  /// Button on that card
  ///
  /// In en, this message translates to:
  /// **'Turn On Messages'**
  String get homeTurnOnMessages;

  /// Button on that card
  ///
  /// In en, this message translates to:
  /// **'Turn On Photos'**
  String get homeTurnOnPhotos;

  /// A computer's Ask the Phone, as a sheet and a notification; name is the computer
  ///
  /// In en, this message translates to:
  /// **'{name} asks to show this phone\'s messages'**
  String turnOnAskMessages(String name);

  /// A computer's Ask the Phone, as a sheet and a notification; name is the computer
  ///
  /// In en, this message translates to:
  /// **'{name} asks to show this phone\'s photos'**
  String turnOnAskPhotos(String name);

  /// Button on that sheet
  ///
  /// In en, this message translates to:
  /// **'Turn On'**
  String get turnOnNow;

  /// Demo mode only: a computer's Ask the Phone comes 4 seconds after the tap
  ///
  /// In en, this message translates to:
  /// **'A computer asks for it, in 4 seconds'**
  String get settingsDemoAsk;

  /// First step for a switch Android greys out: Allow restricted settings only appears in App info after Android refused once (tested on Android 15)
  ///
  /// In en, this message translates to:
  /// **'Open Notification access and turn Linksy on. If its switch is greyed out, tap it anyway: Android refuses, and that makes the next step possible.'**
  String get noticeAccessStepSwitch;

  /// Button opening Android's Notification access page for Linksy
  ///
  /// In en, this message translates to:
  /// **'Open Notification access'**
  String get noticeAccessOpen;
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
