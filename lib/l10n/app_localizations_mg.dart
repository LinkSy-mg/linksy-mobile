// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malagasy (`mg`).
class AppLocalizationsMg extends AppLocalizations {
  AppLocalizationsMg([String locale = 'mg']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Tongasoa eto amin\'i Linksy';

  @override
  String get onboardingChooseLanguage => 'Safidio ny fiteninao';

  @override
  String get onboardingLanguageHint =>
      'Azonao ovaina any amin\'ny Fikirana izany any aoriana.';

  @override
  String get onboardingContinue => 'Tohizo';

  @override
  String get onboardingSetUpTitle => 'Amboary i Linksy';

  @override
  String get onboardingSetUpSubtitle =>
      'Safidio izay azon\'i Linksy atao. Tsy misy mivoaka ity finday ity raha tsy ianao no milaza.';

  @override
  String get onboardingNotifications => 'Fampahafantarana';

  @override
  String get onboardingNotificationsDetail =>
      'Rakitra tonga, sy rehefa misy solosaina mampiasa ny efijerinao, ny fakantsarinao na ny mikrônao, miaraka amin\'ny bokotra hampitsaharana.';

  @override
  String get onboardingCamera => 'Fakantsary';

  @override
  String get onboardingCameraDetail =>
      'Mamaky ny QR code fampifandraisana, ary mamela solosaina hampiasa azy ho webcam rehefa avelanao.';

  @override
  String get onboardingAway => 'Lavitra ny trano';

  @override
  String get onboardingAwayDetail =>
      'Mifandraisa amin\'ny solosainao amin\'ny alalan\'ny internet rehefa tsy amin\'ny Wi-Fi iray ianareo. Voaaro tanteraka.';

  @override
  String get onboardingBackground => 'Mandeha foana ao ambadika';

  @override
  String get onboardingBackgroundDetail =>
      'Mbola mandeha ny rakitra sy ny antso na dia mikatona aza i Linksy. Misy fampahafantarana mangina.';

  @override
  String get onboardingFolder => 'Zarao lahatahiry amin\'ny solosaina';

  @override
  String get onboardingFolderDetail =>
      'Afaka manokatra lahatahiry iray safidianao ao amin\'ny Files ny solosainao.';

  @override
  String get onboardingPhotos => 'Lahatahiry fitahirizana sary';

  @override
  String get onboardingPhotosDetail =>
      'Safidio ny lahatahirin\'ny fakantsary mba hitahiry sary vaovao any amin\'ny solosaina. Alefa isaky ny solosaina.';

  @override
  String get onboardingLocate => 'Avelao hitady ity finday ity ny solosaina';

  @override
  String get onboardingLocateDetail =>
      'Afaka manontany indray mandeha ny solosaina hoe aiza ity finday ity. Tsy misy tehirizina.';

  @override
  String get onboardingAllow => 'Avelao';

  @override
  String get onboardingAllowed => 'Navela';

  @override
  String get onboardingChooseFolder => 'Safidio';

  @override
  String onboardingFolderChosen(String folder) {
    return '“$folder”';
  }

  @override
  String get onboardingAnytime =>
      'Azonao alefa na vonoina amin\'ny fotoana rehetra ao amin\'ny Fikirana ireo.';

  @override
  String get onboardingStart => 'Atombohy ny fampiasana an\'i Linksy';

  @override
  String get onboardingBack => 'Hiverina';

  @override
  String get settingsLanguage => 'Fiteny';

  @override
  String get languageDone => 'Vita';

  @override
  String get ctlClipboardFileTooBig =>
      'Rakitra hatramin\'ny 10 MB ihany no omby ao amin\'ny clipboard.';

  @override
  String get ctlClipboardCopyFailed => 'Tsy voapetraka tao amin\'ny clipboard';

  @override
  String get ctlLocateOff =>
      'Maty ao amin\'i Linksy amin\'ity finday ity ny fitadiavana toerana';

  @override
  String get ctlYourComputer => 'ny solosainao';

  @override
  String get ctlAnd => 'sy';

  @override
  String ctlKeepingLocked(String names) {
    return 'Hihidy foana $names rehefa miala ianao';
  }

  @override
  String get ctlStayingConnected => 'Mbola mifandray amin\'ny solosainao';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te handefa rakitra $count aminao $name',
      one: 'Te handefa rakitra aminao $name',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'Foana ny clipboard.';

  @override
  String get ctlClipboardTooMuch =>
      'Be loatra ny soratra ao amin\'ny clipboard ka tsy azo alefa.';

  @override
  String get ctlPing => 'Ping';

  @override
  String ctlPingFrom(String name) {
    return 'Avy amin\'i $name';
  }

  @override
  String get ctlTextTooMuch => 'Be loatra ny soratra alefa.';

  @override
  String get ctlDeclined => 'Nolavina';

  @override
  String get ctlScreenPermission =>
      'Mila ny alalan\'i Android hakana ny efijery ny fizarana efijery.';

  @override
  String get ctlCameraPermission =>
      'Mila alalana hampiasa ny fakantsary i Linksy mba ho webcam.';

  @override
  String get ctlMicrophonePermission =>
      'Mila alalana hampiasa ny mikrô i Linksy mba ho mikrô.';

  @override
  String get ctlTerminalTitle => 'Terminal';

  @override
  String get errorThatDevice => 'Io fitaovana io';

  @override
  String get errorOtherDevice => 'Ilay fitaovana iray';

  @override
  String get errorComputerOnCable => 'Ilay solosaina amin\'ny tariby';

  @override
  String errorDeviceAt(String address) {
    return 'Ilay fitaovana ao amin\'ny $address';
  }

  @override
  String errorUnreachable(String name) {
    return 'Tsy tratra $name. Jereo raha mandeha izy ary ao amin\'ity tambajotra ity.';
  }

  @override
  String errorDeclined(String name) {
    return 'Nandà $name.';
  }

  @override
  String errorTimeout(String name) {
    return 'Tsy namaly ara-potoana $name.';
  }

  @override
  String errorNotPaired(String name) {
    return 'Tsy mifandray intsony $name. Ampifandraiso indray vao afaka mizara.';
  }

  @override
  String errorUnsupported(String name) {
    return 'Tsy mbola mahavita an\'izany $name.';
  }

  @override
  String errorNotFromAway(String name) {
    return 'Amin\'ny tambajotra iray ihany no avelan\'i $name izany. Afaka mamela ny zava-drehetra avy lavitra ho an\'ity finday ity ny tompony.';
  }

  @override
  String get errorInvalid => 'Tsy nety izany.';

  @override
  String get errorSomethingWrong => 'Nisy olana.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Nisy olana: $detail';
  }

  @override
  String get terminalRefusedComputer => 'Ilay solosaina';

  @override
  String get terminalRefusedCode => 'Diso ny kaody.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Diso ny kaody, in-$count sisa.',
      one: 'Diso ny kaody, indray mandeha sisa.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Diso kaody imbetsaka loatra. Sokafy ny terminal ao amin\'i $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'Ao amin’i $name, sokafy ny pejin’ity finday ity ary avelao ny terminal ao.';
  }

  @override
  String terminalRefusedAway(String name) {
    return 'Amin’ny tambajotra iray ihany no avelan’i $name ny terminal, raha tsy alefa ao ny “Avelao avy lavitra ny zava-drehetra”.';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return 'Tsy afaka manokatra terminal $name.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return 'Efa misy terminal 8 mandeha ao amin\'i $name ho an\'ity finday ity. Akatony aloha ny iray.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return 'Tsy navelan\'i $name.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$kind $os';
  }

  @override
  String get modelKindDesktop => 'solosaina birao';

  @override
  String get modelKindLaptop => 'solosaina finday';

  @override
  String get modelKindPhone => 'finday';

  @override
  String get modelKindTablet => 'takelaka';

  @override
  String get modelOsUnknown => 'Tsy fantatra';

  @override
  String get deviceNothingOfKind => 'Mbola tsy misy toy izany.';

  @override
  String deviceBattery(int level) {
    return '$level%';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level%, eo am-pamenoana';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Tratra avy lavitra hatramin\'ny $day';
  }

  @override
  String get deviceLocksWhenLeave =>
      'Mihidy rehefa miala miaraka amin\'ity finday ity ianao';

  @override
  String get deviceBack => 'Hiverina';

  @override
  String get deviceMore => 'Hafa koa';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Ovay ny sary';

  @override
  String get deviceAddPicture => 'Asio sary';

  @override
  String get deviceRemovePicture => 'Esory ny sary';

  @override
  String get deviceForgetThis => 'Hadino ity fitaovana ity';

  @override
  String deviceForgetTitle(String name) {
    return 'Hadino $name?';
  }

  @override
  String get deviceForgetBody =>
      'Mila ampifandraisina indray ianao vao afaka mizara aminy. Voafafa koa ny asany tamin\'ity finday ity.';

  @override
  String get deviceForget => 'Hadino';

  @override
  String get deviceCancel => 'Foano';

  @override
  String get deviceSendFiles => 'Handefa rakitra';

  @override
  String get deviceSendFilesCaption => 'Sary, antontan-taratasy, izay rehetra';

  @override
  String get deviceClipboard => 'Clipboard';

  @override
  String get deviceClipboardCaption => 'Alefaso izay nadikanao';

  @override
  String get devicePing => 'Ping';

  @override
  String get devicePingCaption => 'Ampanenoy kely';

  @override
  String get deviceRemote => 'Fanaraha-davitra';

  @override
  String get deviceRemoteCaption => 'Touchpad sy slides';

  @override
  String get deviceRinging => 'Maneno…';

  @override
  String get deviceFindIt => 'Tadiavo';

  @override
  String get deviceTapToStop => 'Tsindrio hampitsahatra';

  @override
  String get deviceFindItCaption => 'Ampanenoy mafy';

  @override
  String get devicePrevious => 'Teo aloha';

  @override
  String get devicePause => 'Ajanony';

  @override
  String get devicePlay => 'Alefaso';

  @override
  String get deviceNext => 'Manaraka';

  @override
  String deviceAllowOn(String name) {
    return 'Avelao ao amin\'i $name…';
  }

  @override
  String get deviceSeeScreen => 'Jereo ny efijeriny';

  @override
  String get deviceSeeScreenCaption =>
      'Jereo eto, na fehezo amin\'ny fikasihana';

  @override
  String get deviceWatch => 'Jereo';

  @override
  String get deviceControl => 'Fehezo';

  @override
  String get deviceTerminal => 'Terminal';

  @override
  String deviceTerminalShell(String name) {
    return 'Shell ao amin\'i $name, voaaron\'ny kaodiny';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Terminal $count misokatra',
      one: 'Terminal 1 misokatra',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'Rehetra';

  @override
  String get deviceFilterFiles => 'Rakitra';

  @override
  String get deviceFilterClipboard => 'Clipboard';

  @override
  String get deviceFilterLinks => 'Rohy';

  @override
  String get deviceFilterShowAll => 'Asehoy ny rehetra';

  @override
  String get deviceFilterShowFiles => 'Asehoy ny rakitra';

  @override
  String get deviceFilterShowClipboard => 'Asehoy ny clipboard';

  @override
  String get deviceFilterShowLinks => 'Asehoy ny rohy';

  @override
  String get deviceActivity => 'Asa natao';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Vonona rehefa mangataka $name';
  }

  @override
  String get deviceWebcam => 'Webcam';

  @override
  String get deviceInUseNow => 'Ampiasaina izao';

  @override
  String get deviceControls => 'Fanaraha-maso';

  @override
  String get deviceMicrophone => 'Mikrô';

  @override
  String get deviceStop => 'Atsaharo';

  @override
  String get deviceSecondDisplay => 'Efijery faharoa';

  @override
  String get deviceShowingNow => 'Mampiseho izao';

  @override
  String deviceReadySize(int width, int height) {
    return 'Vonona · $width × $height';
  }

  @override
  String get devicePhoneAs => 'Ity finday ity ho';

  @override
  String deviceStartedOn(String name) {
    return 'Atomboka ao amin\'i $name';
  }

  @override
  String get deviceFasterOverUsb =>
      'Haingana sy milamina kokoa amin\'ny tariby USB.';

  @override
  String get deviceBackUpPhotos => 'Tehirizo ny sary';

  @override
  String devicePhotosGoTo(String name) {
    return 'Mankany amin\'ny lahatahiry Pictures an\'i $name ny sary vaovao';
  }

  @override
  String devicePhotosDeclined(String name) {
    return 'Tsy mandray sary $name. Alefaso ao ny “Ampidiro ny sary avy amin’ny finday”.';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'Avy amin\'ny $folder';
  }

  @override
  String get devicePhotosFromCamera =>
      'Avy amin\'ny lahatahirin\'ny fakantsary';

  @override
  String devicePhotosLast(String time) {
    return 'farany $time';
  }

  @override
  String get deviceGetClipboard => 'Raiso ny clipboard-ny';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'Tonga eto ny soratra nadika tao amin\'i $name raha mifandray';
  }

  @override
  String get deviceAwayAll => 'Avelao avy lavitra ny zava-drehetra';

  @override
  String get deviceAwayAllOn =>
      'Avy lavitra koa: ity efijery ity, webcam, mikrô ary rakitra';

  @override
  String get deviceAwayAllOff =>
      'Avy lavitra: clipboard, rohy, rakitra ary feo fiantsoana ihany';

  @override
  String get deviceNothingShared => 'Mbola tsy misy nozaraina';

  @override
  String deviceNothingSharedBody(String name) {
    return 'Miseho eto ny rakitra, ny soratra clipboard ary ny ping eo amin\'ity finday ity sy $name.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zavatra $count',
      one: 'Zavatra 1',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '“$text”';
  }

  @override
  String get activityClipboardText => 'Soratra clipboard';

  @override
  String get activityPing => 'Ping';

  @override
  String get activityYourScreen => 'Ny efijerinao';

  @override
  String get activityYourCamera => 'Ny fakantsarinao';

  @override
  String get activitySecondDisplay => 'Efijery faharoa';

  @override
  String get activityLink => 'Rohy';

  @override
  String get activityRangThisPhone => 'Nampaneno ity finday ity';

  @override
  String get activityRangIt => 'Nampanenoina';

  @override
  String get activityTouchpadKeyboard => 'Touchpad sy fitendry';

  @override
  String get activityItsScreen => 'Ny efijeriny';

  @override
  String get activityYourMicrophone => 'Ny mikrônao';

  @override
  String get activityWhereThisPhone => 'Aiza ity finday ity';

  @override
  String get activityWatchingNow => 'Jerena izao';

  @override
  String get activityWatched => 'Nojerena';

  @override
  String get activityInUseWebcam => 'Ampiasaina ho webcam';

  @override
  String get activityUsedWebcam => 'Nampiasaina ho webcam';

  @override
  String get activityBeingControlled => 'Fehezina izao';

  @override
  String get activityWatchedControlled => 'Nojerena sy nofehezina';

  @override
  String get activityWatchedFromPhone => 'Nojerena avy amin\'ity finday ity';

  @override
  String get activityInUseNow => 'Ampiasaina izao';

  @override
  String get activityWasTouchpad => 'Touchpad-ny ity finday ity';

  @override
  String get activityWasSecondDisplay => 'Efijery faharoany ity finday ity';

  @override
  String get activityLinkReceived => 'Rohy voaray';

  @override
  String get activityOpenedOnComputer => 'Nosokafana tao amin\'ny solosaina';

  @override
  String get activityInUseMicrophone => 'Ampiasaina ho mikrô';

  @override
  String get activityUsedMicrophone => 'Nampiasaina ho mikrô';

  @override
  String get activityNotTold => 'Tsy nolazaina';

  @override
  String get activityToldWhere =>
      'Nolazaina azy ny toerana misy ity finday ity';

  @override
  String get activityAskedToFind => 'Nangataka hitady ity finday ity';

  @override
  String get activityToFindIt => 'Mba hahitana azy';

  @override
  String get activityDeclined => 'Nolavina';

  @override
  String get activityFailed => 'Tsy nahomby';

  @override
  String get activityInProgress => 'Mandeha';

  @override
  String get activityCopiedHere => 'Voadika eto';

  @override
  String get activityReceived => 'Voaray';

  @override
  String get activitySent => 'Lasa';

  @override
  String get activityStop => 'Atsaharo';

  @override
  String get activityCancel => 'Foano';

  @override
  String get activityCopyAgain => 'Adikao indray';

  @override
  String get activityCopied => 'Voadika';

  @override
  String get activityCopyLink => 'Adikao ny rohy';

  @override
  String get activityLinkCopied => 'Voadika ny rohy';

  @override
  String get activityNoAppForLink => 'Tsy misy app eto mahasokatra io rohy io.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rakitra $count',
      one: 'Rakitra 1',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return 'Tsy eo intsony $name.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'Tsy misy app amin\'ity finday ity mahasokatra $name.';
  }

  @override
  String get activityWaitingForYou => 'Miandry anao hanaiky…';

  @override
  String get activityWaitingForDevice => 'Miandry ny fitaovana hanaiky…';

  @override
  String activityWaitingFor(String name) {
    return 'Miandry an\'i $name hanaiky…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done amin\'ny $total';
  }

  @override
  String get homeSettings => 'Fikirana';

  @override
  String get homeYourDevices => 'Ny fitaovanao';

  @override
  String get homeNearbyNotPaired => 'Akaiky, tsy mifandray';

  @override
  String get homeAddDevice => 'Hanampy fitaovana';

  @override
  String homeVisible(String name) {
    return 'Hita amin\'ity Wi-Fi ity $name';
  }

  @override
  String get homeUpdateTitle => 'Havaozy i Linksy mba hifandray foana';

  @override
  String get homeUpdateBody =>
      'Linksy vaovao kokoa noho ity app ity no ampiasain\'ny solosainao izao.';

  @override
  String get homeGetUpdate => 'Alaivo ny fanavaozana';

  @override
  String get homeSendFiles => 'Handefa rakitra';

  @override
  String get homePair => 'Ampifandraiso';

  @override
  String get homeStepOpen => 'Sokafy i Linksy ao amin\'ny solosainao';

  @override
  String get homeStepChoose => 'Safidio ny “Hanampy fitaovana”';

  @override
  String get homeStepScan => 'Vakio amin\'ity finday ity';

  @override
  String get homeConnectTitle => 'Ampifandraiso ny\nfitaovanao voalohany';

  @override
  String get homeConnectSubtitle =>
      'Mivantana amin\'ny Wi-Fi-nao. Tsy mila kaonty, tsy misy cloud.';

  @override
  String get homeScanQr => 'Vakio ny QR code';

  @override
  String get homePairByAddress => 'Ampifandraiso amin\'ny adiresy';

  @override
  String get pairingAddDevice => 'Hanampy fitaovana';

  @override
  String get pairingAddDeviceHint =>
      'Ao amin’ilay fitaovana iray, sokafy i Linksy ary safidio ny “Hanampy fitaovana”.';

  @override
  String get pairingScanQr => 'Vakio ny QR code';

  @override
  String get pairingScanQrCaption => 'Haingana indrindra. Tsy misy soratana.';

  @override
  String get pairingByAddress => 'Ampifandraiso amin\'ny adiresy';

  @override
  String get pairingByAddressCaption => 'Rehefa tsy hita ilay fitaovana iray.';

  @override
  String pairingWith(String name) {
    return 'Mampifandray amin\'i $name…';
  }

  @override
  String get pairingWithOtherDevice =>
      'Mampifandray amin\'ilay fitaovana iray…';

  @override
  String get pairingAddressHint =>
      'Ao amin\'ny Preferences an\'i Linksy ao amin\'ilay fitaovana iray izany.';

  @override
  String pairingPortHint(String port) {
    return 'Port $port raha tsy manampy hafa ianao.';
  }

  @override
  String get pairingPair => 'Ampifandraiso';

  @override
  String pairingWantsToPair(String name) {
    return 'Te hifandray $name';
  }

  @override
  String pairingPairWith(String name) {
    return 'Hifandray amin\'i $name';
  }

  @override
  String get pairingCodeHint =>
      'Tokony hiseho amin\'ny efijery roa ity kaody ity.';

  @override
  String pairingCodeLabel(String code) {
    return 'Kaody $code';
  }

  @override
  String get pairingCodesMatch => 'Mitovy ny kaody';

  @override
  String get scanNeedsCamera =>
      'Mila ny fakantsary i Linksy hamakiana ny kaody fampifandraisana. Avelao, na ampifandraiso amin\'ny adiresy.';

  @override
  String get scanCameraUnavailable => 'Tsy azo ampiasaina ny fakantsary.';

  @override
  String get scanFlashlight => 'Jiro';

  @override
  String get scanTitle => 'Vakio ny kaody';

  @override
  String get scanWrongCode =>
      'Tsy kaody Linksy io. Ao amin\'ny solosainao, sokafy Linksy → Pair with QR Code.';

  @override
  String get scanHint =>
      'Ao amin’ny solosainao, sokafy i Linksy ary safidio ny “Hanampy fitaovana”.';

  @override
  String get shareSheetPutOnClipboard => 'Apetraho amin\'ny clipboard';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Handefa rakitra $count',
      one: 'Handefa rakitra',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Sokafy amin\'ny solosaina';

  @override
  String get shareSheetSendToClipboard => 'Alefaso any amin\'ny clipboard';

  @override
  String get shareSheetNoClipboardFiles =>
      'Tsy misy amin\'ny solosainao mandray rakitra amin\'ny clipboard-ny aloha. Havaozy ao i Linksy.';

  @override
  String get shareSheetNoComputers =>
      'Ampifandraiso solosaina aloha, dia zarao aminy avy amin\'ny app rehetra.';

  @override
  String get shareSheetSendFileInstead => 'Alefaso ho rakitra ihany';

  @override
  String get shareSheetClipboardInstead =>
      'Apetraho amin\'ny clipboard-n\'ny solosaina kosa';

  @override
  String get shareSheetOpenLinkInstead => 'Sokafy ny rohy kosa';

  @override
  String get shareSheetSendAsTextInstead =>
      'Alefaso ho soratra any amin\'ny clipboard kosa';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Apetraka amin\'ny clipboard-n\'i $name';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Apetraka amin\'ny clipboard-n\'ny solosaina';

  @override
  String shareSheetOpened(String name) {
    return 'Nosokafana tao amin\'i $name';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Nosokafana tao amin\'ny solosaina';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'Lasa any amin\'ny clipboard-n\'i $name';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'Lasa any amin\'ny clipboard-n\'ny solosaina';

  @override
  String shareSheetSentALink(String name) {
    return 'Nandefa rohy $name';
  }

  @override
  String get shareSheetOpen => 'Sokafy';

  @override
  String get shareSheetCopyLink => 'Adikao ny rohy';

  @override
  String get shareSheetLinkCopied => 'Voadika ny rohy';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rakitra $count',
      one: 'rakitra iray',
    );
    return 'Mandefa $_temp0 aminao $name';
  }

  @override
  String incomingTotal(String size) {
    return '$size raha atambatra';
  }

  @override
  String incomingMore(int count) {
    return '+ $count hafa';
  }

  @override
  String get incomingAccept => 'Ekeo';

  @override
  String get appInvalidPairingLink => 'Tsy mety io rohy fampifandraisana io.';

  @override
  String appPairingFailed(String reason) {
    return 'Tsy nahomby ny fampifandraisana: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'Tsy afaka nifandray tamin\'i $name: $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Mifandray amin\'i $name';
  }

  @override
  String appNotification(String name, String text) {
    return '$name: $text';
  }

  @override
  String appCopiedText(String name) {
    return 'Soratra nadika avy amin\'i $name';
  }

  @override
  String appCopiedFile(String file, String name) {
    return 'Nadika avy amin\'i $name ny $file';
  }

  @override
  String get appCouldntStart => 'Tsy afaka nanomboka i Linksy';

  @override
  String get commonDismiss => 'Esory';

  @override
  String get commonCancel => 'Foano';

  @override
  String get commonDecline => 'Lavio';

  @override
  String get commonClose => 'Akatony';

  @override
  String get commonNotNow => 'Tsy izao';

  @override
  String get commonConnected => 'Mifandray';

  @override
  String get commonNearby => 'Akaiky';

  @override
  String get commonNotNearby => 'Tsy akaiky';

  @override
  String get commonUsbCable => 'Tariby USB';

  @override
  String get commonAwayFromHome => 'Lavitra ny trano';

  @override
  String get commonSameWifi => 'Wi-Fi iray ihany';

  @override
  String get commonConnectedByUsb => 'Mifandray amin\'ny USB';

  @override
  String get commonConnectedAway => 'Mifandray lavitra ny trano';

  @override
  String commonBattery(int level) {
    return 'Bateria $level isan-jato';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Bateria $level isan-jato, eo am-pamenoana';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count octets',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Segondra $count sisa',
      one: 'Segondra 1 sisa',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Minitra $count sisa',
      one: 'Minitra 1 sisa',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adiny $count eo ho eo sisa',
      one: 'Adiny 1 eo ho eo sisa',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Androany';

  @override
  String get formatYesterday => 'Omaly';

  @override
  String get formatPhone => 'Finday';

  @override
  String get settingsBack => 'Hiverina';

  @override
  String get settingsTitle => 'Fikirana';

  @override
  String get settingsReceiving => 'Fandraisana';

  @override
  String get settingsSaveLocation => 'Toerana itahirizana';

  @override
  String get settingsSaveLocationPath => 'Downloads › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Ekeo avy amin\'ny fitaovako';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'Tonga tsy anontaniana ny rakitra avy amin\'ny fitaovana mifandray.';

  @override
  String get settingsConnection => 'Fifandraisana';

  @override
  String get settingsStayConnected => 'Mifandray foana';

  @override
  String get settingsStayConnectedCaption =>
      'Fizarana haingana kokoa amin\'ny fitaovana akaiky. Mandany bateria bebe kokoa.';

  @override
  String get settingsKeepRunning => 'Mandeha foana ao ambadika';

  @override
  String get settingsKeepRunningCaption =>
      'Mbola mandeha ny rakitra, ny fitahirizana sary ary ny antso na dia mikatona aza i Linksy. Misy fampahafantarana mangina.';

  @override
  String get settingsAwayFromHome => 'Lavitra ny trano';

  @override
  String get settingsAwayFromHomeCaption =>
      'Mifandraisa amin\'ny solosainao amin\'ny alalan\'ny internet rehefa tsy amin\'ny tambajotra iray ianareo, mandritra ny herinandro taorian\'ny fotoana farany nisy anareo niaraka. Voaaro tanteraka.';

  @override
  String get settingsRelay => 'Mpampita (relay)';

  @override
  String get settingsRelayDefault => 'An\'i Linksy';

  @override
  String get settingsRelayCaption =>
      'Ny adiresin\'ny mpampita ampiasainao manokana, toy ny https://relay.example.com. Avelao ho foana raha an\'i Linksy. Apetraho mitovy amin\'ny fitaovana rehetra ny mpampita.';

  @override
  String get settingsWithYourComputers => 'Miaraka amin\'ny solosainao';

  @override
  String get settingsPauseMusic => 'Ajanony ny mozika mandritra ny antso';

  @override
  String get settingsPauseMusicCaption =>
      'Ajanon\'ny solosainao izay mandeha rehefa misy antso maneno na resaka, ary averiny avy eo.';

  @override
  String get settingsBrowseFiles => 'Avelao hijery rakitra ny solosaina';

  @override
  String get settingsBrowseFilesChoose =>
      'Safidio lahatahiry azon\'ny solosainao sokafana ao amin\'ny Files, toy ny Documents (tsy avelan\'i Android ny Download).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Mizara ny “$folder”. Tsindrio hisafidianana lahatahiry hafa.';
  }

  @override
  String get settingsPicture => 'Sarin\'ity finday ity';

  @override
  String get settingsPictureChoose =>
      'Asehon\'ny solosainao ho an\'ity finday ity izany. Tsindrio hisafidianana.';

  @override
  String get settingsPictureChange =>
      'Asehon\'ny solosainao ho an\'ity finday ity izany. Tsindrio hanovana azy.';

  @override
  String get settingsPictureRemove => 'Esory';

  @override
  String get settingsLocate => 'Avelao hitady ity finday ity ny solosaina';

  @override
  String get settingsLocateCaption =>
      'Afaka manontany indray mandeha ny solosaina hoe aiza ity finday ity, mba hahitana azy. Tsy misy tehirizina na arahina. Mandeha raha misokatra i Linksy.';

  @override
  String get settingsLocatePermission =>
      'Mila alalana hahafantatra ny toerana i Linksy amin\'ity.';

  @override
  String get settingsPhotoFolder => 'Lahatahiry sary';

  @override
  String get settingsPhotoFolderChoose =>
      'Safidio ny lahatahirin\'ny fakantsary (DCIM › Camera) hitahiry sary any amin\'ny solosaina.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Mitahiry ny “$folder”. Alefaso isaky ny solosaina, ao amin\'ny pejiny.';
  }

  @override
  String get settingsThisApp => 'Ity app ity';

  @override
  String get settingsPermissions => 'Alalana';

  @override
  String get settingsDemo => 'Demo';

  @override
  String get settingsDemoCaption =>
      'Fitaovana sandoka mandra-pifandray ny Linksy core. Manomboka izay ho ataon\'ny fitaovana hafa ireto.';

  @override
  String get settingsDemoReceiveFiles => 'Handray rakitra';

  @override
  String get settingsDemoReceivePairing =>
      'Handray fangatahana fampifandraisana';

  @override
  String get settingsDemoReceiveClipboard => 'Handray soratra clipboard';

  @override
  String get settingsTagline =>
      'Ny fitaovanao, mifandray.\nTsy mila kaonty, tsy misy cloud.';

  @override
  String get settingsNameTitle => 'Omeo anarana ity finday ity';

  @override
  String get settingsNameCaption =>
      'Hitan\'ny fitaovanao hafa ity anarana ity.';

  @override
  String get settingsSave => 'Tehirizo';

  @override
  String get settingsCancel => 'Foano';

  @override
  String settingsRename(String name) {
    return 'Ovay anarana $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'Ity finday ity · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Fampahafantarana sy fakantsary';

  @override
  String get settingsPermissionsWhat =>
      'Izay angatahan\'i Linksy amin\'i Android, sy ny antony.';

  @override
  String get settingsPermissionsBoth => 'Samy navela.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count amin\'ny 2 no navela. Tsindrio hamela ny sisa.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Alalana';

  @override
  String get permissionsIntro =>
      'Izay ilainy ihany no angatahan\'i Linksy, ary azonao ovaina any aoriana ao amin\'ny Fikirana ireo.';

  @override
  String get permissionsNotifications => 'Fampahafantarana';

  @override
  String get permissionsNotificationsWhy =>
      'Mampiseho rehefa misy solosaina mijery ny efijerinao na mampiasa ny fakantsarinao, miaraka amin\'ny bokotra hampitsaharana azy.';

  @override
  String get permissionsCamera => 'Fakantsary';

  @override
  String get permissionsCameraWhy =>
      'Mamaky ny QR code fampifandraisana, ary mamela solosaina hampiasa ity finday ity ho webcam rehefa avelanao.';

  @override
  String get permissionsAllow => 'Avelao';

  @override
  String get permissionsAllowed => 'Navela';

  @override
  String get permissionsDone => 'Vita';

  @override
  String get remoteBack => 'Hiverina';

  @override
  String get remoteTitle => 'Fanaraha-davitra';

  @override
  String remoteAllowOn(String name) {
    return 'Avelao ao amin\'i $name';
  }

  @override
  String remoteAsks(String name) {
    return 'Manontany i Linksy ao amin\'i $name raha azon\'ity finday ity hetsehina ny tondro sy hanoratana.';
  }

  @override
  String get remoteFailed => 'Tsy nety izany';

  @override
  String get remoteStopped => 'Nijanona ny fanaraha-davitra';

  @override
  String remoteEndedBy(String name) {
    return 'Notapitrin\'i $name izany.';
  }

  @override
  String get remoteTryAgain => 'Andramo indray';

  @override
  String get remoteTouchpad => 'Touchpad';

  @override
  String get remoteSlides => 'Slides';

  @override
  String get remoteTouchpadHint =>
      'Rantsantanana iray hanetsehana, tsindrio hipihana\nRantsantanana roa hanakodiavana, tsindrio amin\'ny roa ho an\'ny pitika havanana';

  @override
  String get remoteLeftClick => 'Pitika havia';

  @override
  String get remoteRightClick => 'Pitika havanana';

  @override
  String get remoteKeyboard => 'Fitendry';

  @override
  String get remoteNextSlide => 'Slide manaraka';

  @override
  String get remoteNext => 'Manaraka';

  @override
  String get remotePreviousSlide => 'Slide teo aloha';

  @override
  String get remoteSlideBack => 'Hiverina';

  @override
  String get remoteStartShow => 'Atombohy (F5)';

  @override
  String get remoteEndShow => 'Tapitra (Esc)';

  @override
  String get remoteVolumeHint =>
      'Feo midina: manaraka · Feo miakatra: hiverina. Mijanona mirehitra ny efijery.';

  @override
  String get ringTitle => 'Ato aho!';

  @override
  String ringLookingFor(String name) {
    return 'Mitady ity finday ity $name.';
  }

  @override
  String get ringFoundIt => 'Hita';

  @override
  String get webcamBack => 'Hiverina';

  @override
  String get webcamTitle => 'Webcam';

  @override
  String webcamLiveOn(String name) {
    return 'Mivantana ao amin\'i $name';
  }

  @override
  String get webcamStopSemantic => 'Atsaharo ny webcam';

  @override
  String get webcamStop => 'Atsaharo';

  @override
  String get webcamBadgeLive => 'MIVANTANA';

  @override
  String get webcamBadgeLock => 'AE/AF MIHIDY';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'JIRO';

  @override
  String get webcamFacingFront => 'Anoloana';

  @override
  String get webcamFacingBack => 'Aoriana';

  @override
  String get webcamTorch => 'Jiro';

  @override
  String get webcamPortrait => 'Mitsangana';

  @override
  String get webcamLandscape => 'Mandry';

  @override
  String get webcamLocked => 'Mihidy';

  @override
  String get webcamLock => 'Hidio';

  @override
  String get webcamTabLight => 'Hazavana';

  @override
  String get webcamTabFocus => 'Fahazavan-tsary';

  @override
  String get webcamTabColor => 'Loko';

  @override
  String get webcamTabStream => 'Fandefasana';

  @override
  String get webcamBrightness => 'Hamirapiratana';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto =>
      'Mandrindra ny hazavana ho azy ity fakantsary ity.';

  @override
  String get webcamLockExposure => 'Hidio ny hazavana';

  @override
  String get webcamLockExposureDetail =>
      'Tazomina toy izao ny hamirapiratana. Tsindrio ela ny sary hanidiana amin\'ny toerana iray.';

  @override
  String get webcamFocus => 'Fahazavan-tsary';

  @override
  String get webcamFocusFixed =>
      'Tsy miova ny fahazavan-tsarin\'ity fakantsary ity.';

  @override
  String get webcamFocusSpotDetail =>
      'Tazomina amin\'ny toerana notsindrianao. Tsindrio indroa ny sary ho an\'ny automatique.';

  @override
  String get webcamFocusManualDetail => 'Ianao no mandrindra eto ambany.';

  @override
  String get webcamFocusAutoDetail =>
      'Manaraka ny sary. Tsindrio mba hifantoka amin\'ny toerana iray.';

  @override
  String get webcamFocusAuto => 'Auto';

  @override
  String get webcamFocusSpot => 'Toerana';

  @override
  String get webcamFocusManual => 'Tanana';

  @override
  String get webcamDistance => 'Halavirana';

  @override
  String get webcamFar => 'Lavitra';

  @override
  String get webcamNear => 'Akaiky';

  @override
  String get webcamWbAuto => 'Auto';

  @override
  String get webcamWbDaylight => 'Hazavan\'andro';

  @override
  String get webcamWbCloudy => 'Rahona';

  @override
  String get webcamWbShade => 'Aloka';

  @override
  String get webcamWbIncandescent => 'Jiro mafana';

  @override
  String get webcamWbFluorescent => 'Jiro birao';

  @override
  String get webcamWhiteBalance => 'Fandanjana fotsy';

  @override
  String get webcamLockColors => 'Hidio ny loko';

  @override
  String get webcamLockColorsDetail =>
      'Tsy miova ny loko rehefa miova ny hazavana.';

  @override
  String get webcamOrientation => 'Fitodiana';

  @override
  String get webcamOrientationPortraitDetail =>
      'Atsangano ny finday; misy tsipika eo amin\'ny sisiny.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Ampandrio ny finday; feno ny sary.';

  @override
  String get webcamFrameRate => 'Isan-tsary';

  @override
  String get webcamFps60Detail =>
      'Malama kokoa ny fihetsika; mandany data sy bateria bebe kokoa.';

  @override
  String get webcamFps30Detail => 'Milamina ho an\'ny antso video.';

  @override
  String get webcamFpsOnly30 => 'Hatramin\'ny 30 fps ihany ity fakantsary ity.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Fahamendrehana';

  @override
  String get webcamResolution1080Detail =>
      'Full HD, ho an\'ny efijery lehibe; data bebe kokoa.';

  @override
  String get webcamResolution720Detail =>
      'HD, mety tsara ho an\'ny antso video.';

  @override
  String get webcamResolutionOnly720 => '720p no alefan\'ity fakantsary ity.';

  @override
  String get webcamQuality => 'Kalitao';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, ho an\'ny Wi-Fi be mpampiasa.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, antsipiriany betsaka indrindra.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, mazava ho an\'ny antso video.';
  }

  @override
  String get webcamQualitySaver => 'Mitsitsy';

  @override
  String get webcamQualityStandard => 'Mahazatra';

  @override
  String get webcamQualityHigh => 'Ambony';

  @override
  String get webcamStabilization => 'Fampitoniana';

  @override
  String get webcamStabilizationDetail => 'Manala ny hovitrovitry ny tanana.';

  @override
  String get webcamMirror => 'Ataovy fitaratra ny topi-maso';

  @override
  String get webcamMirrorDetail =>
      'Amin\'ity finday ity ihany; tsy fitaratra no azon\'ny solosaina.';

  @override
  String get webcamFormat => 'Endrika';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Avereno';

  @override
  String webcamResetSetting(String setting) {
    return 'Avereno ny $setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return 'Te hijery ny efijerinao $name';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Miseho ao amin\'i $name ny zava-drehetra eo amin\'ny efijerin\'ity finday ity mandra-pampitsaharinao. Hangataka fanamafisana i Android avy eo.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return 'Te hifehy ny efijerinao $name';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return 'Mahita ny efijerin\'ity finday ity $name ary afaka mikasika, mikosoka sy manoratra eo mandra-pampitsaharinao. Hangataka fanamafisana i Android avy eo.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return 'Te hampiasa ny fakantsarinao $name';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return 'Azon\'i $name ho webcam ny fakantsarin\'ity finday ity mandra-pampitsaharinao. Ao amin\'i Linksy ny zoom, fahazavan-tsary, hazavana, lantihy ary fihodinana mandritra izany.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return 'Te hampiasa ity finday ity ho touchpad $name';
  }

  @override
  String get sharingInputRequestDetail =>
      'Tsy nampoizina: tsy mangataka izany ny solosaina. Aza avela.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return 'Te hampiasa ny mikrônao $name';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return 'Mandre ny mikrôn\'ity finday ity $name mandra-pampitsaharinao, ho mikrô azon\'ny app rehetra ao aminy ampiasaina. Hangataka fanamafisana i Android avy eo.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return 'Te hampiasa ity efijery ity ho efijery faharoa $name';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'Mampiseho efijerin\'i $name feno ity finday ity. Kasiho hipihana sy hisintonana; rantsantanana roa hanakodiavana. Miverena hampitsahatra.';
  }

  @override
  String get sharingAllow => 'Avelao';

  @override
  String get sharingDontAllow => 'Aza avela';

  @override
  String get sharingProtectionHint =>
      'Mainty ao amin\'ny solosaina ny tsipika ambony na ny fampahafantarana? Ny fiarovana fizarana efijery an\'i Android no manafina azy. Alefaso ny “Disable screen share protections” ao amin\'ny Developer options, dia zarao indray.';

  @override
  String get sharingGotIt => 'Azoko';

  @override
  String get sharingDeveloperOptions => 'Developer options';

  @override
  String sharingControlling(String name) {
    return 'Mifehy ny efijerinao $name';
  }

  @override
  String sharingUsingCamera(String name) {
    return 'Mampiasa ny fakantsarinao $name';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return 'Mampiasa ny mikrônao $name';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Mizara ny efijerinao amin\'i $name';
  }

  @override
  String get sharingTapForCameraControls =>
      'Tsindrio ho an\'ny fandrindrana fakantsary';

  @override
  String get sharingSwitchCamera => 'Ovay fakantsary';

  @override
  String get sharingStopSharing => 'Atsaharo ny fizarana';

  @override
  String get sharingStop => 'Atsaharo';

  @override
  String get sharingCameraControls => 'Fandrindrana fakantsary';

  @override
  String displaySecondHint(String name) {
    return 'Efijery faharoan\'i $name · miverena hampitsahatra';
  }

  @override
  String displayControlHint(String name) {
    return 'Efijerin\'i $name · kasiho hipihana · miverena hampitsahatra';
  }

  @override
  String displayWatchHint(String name) {
    return 'Efijerin\'i $name · miverena hampitsahatra';
  }

  @override
  String terminalTabClosed(String title) {
    return 'Nikatona “$title”';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return 'Tapitra tao amin\'i $name “$title”';
  }

  @override
  String get terminalCloseTitle => 'Hakatona ity terminal ity?';

  @override
  String terminalCloseDetail(String name) {
    return 'Tapitra ao amin\'i $name ny shell, miaraka amin\'izay mbola mandeha ao. Raha te hiverina aminy any aoriana, avelao handeha foana kosa.';
  }

  @override
  String get terminalKeepRunning => 'Avelao handeha';

  @override
  String get terminalClose => 'Akatony';

  @override
  String get terminalTheComputer => 'ny solosaina';

  @override
  String get terminalDetached => 'Navela';

  @override
  String terminalDetachedDetail(String name) {
    return 'Mbola mandeha ao amin\'i $name. Ampifandraiso indray raha te hijery azy; hangatahina indray ny kaody.';
  }

  @override
  String get terminalReattach => 'Ampifandraiso indray';

  @override
  String terminalOn(String name) {
    return 'Terminal ao amin\'i $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Navela · mbola mandeha ao amin\'i $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Manokatra ao amin\'i $name…';
  }

  @override
  String get terminalWaitingForCode => 'Miandry ny kaody';

  @override
  String get terminalEnded => 'Tapitra';

  @override
  String get terminalBack => 'Hiverina';

  @override
  String get terminalTitle => 'Terminal';

  @override
  String get terminalMenu => 'Menu terminal';

  @override
  String get terminalDetachMenu => 'Avelao handeha (detach)';

  @override
  String terminalCloseTab(String title) {
    return 'Akatony $title';
  }

  @override
  String get terminalNew => 'Terminal vaovao';

  @override
  String terminalShellOn(String name) {
    return 'Shell ao amin\'i $name';
  }

  @override
  String get terminalShellDetail =>
      'Mandeha amin\'ny anaranao ao amin\'ny solosaina, ao amin\'ny lahatahiry fandraisanao. Isaky ny manokatra dia mangataka ny kaody terminal napetraka tao.';

  @override
  String get terminalStillRunning => 'MBOLA MANDEHA';

  @override
  String terminalReattachTab(String title) {
    return 'Ampifandraiso indray $title';
  }

  @override
  String terminalStarted(String time) {
    return 'Natomboka tamin\'ny $time';
  }

  @override
  String get terminalKeyLeft => 'Havia';

  @override
  String get terminalKeyUp => 'Ambony';

  @override
  String get terminalKeyDown => 'Ambany';

  @override
  String get terminalKeyRight => 'Havanana';

  @override
  String get terminalCodeTitle => 'Kaody terminal';

  @override
  String terminalCodeDetail(String name) {
    return 'Ilay kaody napetraka tao amin’i $name ao amin’ny Fikirana › Terminal. Tsy tehirizin’i Linksy mihitsy.';
  }

  @override
  String get terminalCodePassphrase => 'Teny miafina';

  @override
  String get terminalCodeDigitsHint => 'Isa 6 na mihoatra';

  @override
  String get terminalCodeUseDigits => 'Ampiasao isa';

  @override
  String get terminalCodeUseLetters => 'Ampiasao litera';

  @override
  String get terminalOpening => 'Manokatra…';

  @override
  String get terminalOpen => 'Sokafy ny terminal';

  @override
  String get settingsAppearance => 'Endrika';

  @override
  String get settingsThemeSystem => 'Araka ny finday';

  @override
  String get settingsThemeLight => 'Mazava';

  @override
  String get settingsThemeDark => 'Maizina';

  @override
  String usbConnectedTo(String name) {
    return 'Mifandray amin’i $name amin’ny tariby USB';
  }

  @override
  String get usbPairTitle => 'Misy solosaina amin’ny tariby';

  @override
  String get usbPairBody =>
      'Mbola tsy mifamatotra amin’ity finday ity izy. Ampifamatorina amin’ny tariby ve? Samy mampiseho kaody hampitahaina ny efijery roa.';

  @override
  String get usbPairAction => 'Ampifamatory';
}
