// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Willkommen bei Linksy';

  @override
  String get onboardingChooseLanguage => 'Wähle deine Sprache';

  @override
  String get onboardingLanguageHint =>
      'Du kannst sie später in den Einstellungen ändern.';

  @override
  String get onboardingContinue => 'Weiter';

  @override
  String get onboardingSetUpTitle => 'Linksy einrichten';

  @override
  String get onboardingSetUpSubtitle =>
      'Wähle, was Linksy darf. Nichts verlässt dieses Handy, bevor du es sagst.';

  @override
  String get onboardingNotifications => 'Mitteilungen';

  @override
  String get onboardingNotificationsDetail =>
      'Eingehende Dateien – und wenn ein Computer deinen Bildschirm, deine Kamera oder dein Mikrofon nutzt, mit einem Knopf zum Beenden.';

  @override
  String get onboardingCamera => 'Kamera';

  @override
  String get onboardingCameraDetail =>
      'Scannt QR-Codes zum Koppeln und lässt einen Computer sie als Webcam nutzen, wenn du es erlaubst.';

  @override
  String get onboardingAway => 'Unterwegs';

  @override
  String get onboardingAwayDetail =>
      'Erreiche deine Computer über das Internet, wenn ihr nicht im selben Wi-Fi seid. Ende-zu-Ende-verschlüsselt.';

  @override
  String get onboardingBackground => 'Im Hintergrund weiterlaufen';

  @override
  String get onboardingBackgroundDetail =>
      'Dateien und Anrufe funktionieren auch, wenn Linksy geschlossen ist. Zeigt eine dezente Mitteilung.';

  @override
  String get onboardingFolder => 'Einen Ordner mit Computern teilen';

  @override
  String get onboardingFolderDetail =>
      'Deine Computer können einen Ordner deiner Wahl in ihrer Dateien-App öffnen.';

  @override
  String get onboardingPhotos => 'Ordner für Foto-Backup';

  @override
  String get onboardingPhotosDetail =>
      'Wähle deinen Kameraordner, um neue Fotos auf einem Computer zu sichern. Wird pro Computer eingeschaltet.';

  @override
  String get onboardingLocate => 'Computer dürfen dieses Handy orten';

  @override
  String get onboardingLocateDetail =>
      'Ein Computer kann einmalig fragen, wo dieses Handy ist. Nichts wird gespeichert.';

  @override
  String get onboardingAllow => 'Erlauben';

  @override
  String get onboardingAllowed => 'Erlaubt';

  @override
  String get onboardingChooseFolder => 'Wählen';

  @override
  String onboardingFolderChosen(String folder) {
    return '„$folder“';
  }

  @override
  String get onboardingAnytime =>
      'Du kannst all das jederzeit in den Einstellungen ein- oder ausschalten.';

  @override
  String get onboardingStart => 'Linksy loslegen';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageDone => 'Fertig';

  @override
  String get ctlClipboardFileTooBig =>
      'In die Zwischenablage passt nur eine Datei bis 10 MB.';

  @override
  String get ctlClipboardCopyFailed =>
      'Konnte nicht in die Zwischenablage kopiert werden';

  @override
  String get ctlLocateOff =>
      'Orten ist in Linksy auf diesem Handy ausgeschaltet';

  @override
  String get ctlYourComputer => 'dein Computer';

  @override
  String get ctlAnd => 'und';

  @override
  String ctlKeepingLocked(String names) {
    return '$names bleiben gesperrt, wenn du gehst';
  }

  @override
  String get ctlStayingConnected => 'Bleibt mit deinen Computern verbunden';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name möchte dir $count Dateien senden',
      one: '$name möchte dir eine Datei senden',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'Die Zwischenablage ist leer.';

  @override
  String get ctlClipboardTooMuch =>
      'Die Zwischenablage enthält zu viel Text zum Senden.';

  @override
  String get ctlPing => 'Ping';

  @override
  String ctlPingFrom(String name) {
    return 'Von $name';
  }

  @override
  String get ctlTextTooMuch => 'Das ist zu viel Text zum Senden.';

  @override
  String get ctlDeclined => 'Abgelehnt';

  @override
  String get ctlScreenPermission =>
      'Zum Teilen des Bildschirms braucht es die Android-Berechtigung zur Aufnahme.';

  @override
  String get ctlCameraPermission =>
      'Linksy braucht die Kameraberechtigung, um als Webcam zu arbeiten.';

  @override
  String get ctlMicrophonePermission =>
      'Linksy braucht die Mikrofonberechtigung, um als Mikrofon zu dienen.';

  @override
  String get ctlTerminalTitle => 'Terminal';

  @override
  String get errorThatDevice => 'Dieses Gerät';

  @override
  String get errorOtherDevice => 'Das andere Gerät';

  @override
  String get errorComputerOnCable => 'Der Computer am Kabel';

  @override
  String errorDeviceAt(String address) {
    return 'Das Gerät unter $address';
  }

  @override
  String errorUnreachable(String name) {
    return '$name ist nicht erreichbar. Prüfe, ob es an und in diesem Netzwerk ist.';
  }

  @override
  String errorDeclined(String name) {
    return '$name hat abgelehnt.';
  }

  @override
  String errorTimeout(String name) {
    return '$name hat nicht rechtzeitig geantwortet.';
  }

  @override
  String errorNotPaired(String name) {
    return '$name ist nicht mehr gekoppelt. Kopple erneut, um zu teilen.';
  }

  @override
  String errorUnsupported(String name) {
    return '$name kann das noch nicht.';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name erlaubt das nur im selben Netzwerk. Der Besitzer kann für dieses Handy alles von unterwegs erlauben.';
  }

  @override
  String get errorInvalid => 'Das hat nicht geklappt.';

  @override
  String get errorSomethingWrong => 'Etwas ist schiefgelaufen.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Etwas ist schiefgelaufen: $detail';
  }

  @override
  String get terminalRefusedComputer => 'Der Computer';

  @override
  String get terminalRefusedCode => 'Falscher Code.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Falscher Code, noch $count Versuche.',
      one: 'Falscher Code, noch 1 Versuch.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Zu viele falsche Codes. Entsperre das Terminal auf $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'Öffne auf $name die Seite dieses Handys und erlaube dort das Terminal.';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name erlaubt ein Terminal nur im selben Netzwerk, außer dort ist „Alles von unterwegs erlauben“ an.';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name kann kein Terminal öffnen.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return 'Auf $name laufen schon 8 Terminals für dieses Handy. Schließe zuerst eins.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name hat es nicht erlaubt.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$kind ($os)';
  }

  @override
  String get modelKindDesktop => 'Desktop-PC';

  @override
  String get modelKindLaptop => 'Laptop';

  @override
  String get modelKindPhone => 'Handy';

  @override
  String get modelKindTablet => 'Tablet';

  @override
  String get modelOsUnknown => 'Unbekannt';

  @override
  String get deviceNothingOfKind => 'Noch nichts davon.';

  @override
  String deviceBattery(int level) {
    return '$level %';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level %, lädt';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Von unterwegs erreichbar bis $day';
  }

  @override
  String get deviceLocksWhenLeave =>
      'Sperrt sich, wenn du mit diesem Handy gehst';

  @override
  String get deviceBack => 'Zurück';

  @override
  String get deviceMore => 'Mehr';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Bild ändern';

  @override
  String get deviceAddPicture => 'Bild hinzufügen';

  @override
  String get deviceRemovePicture => 'Bild entfernen';

  @override
  String get deviceForgetThis => 'Dieses Gerät vergessen';

  @override
  String deviceForgetTitle(String name) {
    return '$name vergessen?';
  }

  @override
  String get deviceForgetBody =>
      'Du musst erneut koppeln, um damit zu teilen. Sein Verlauf auf diesem Handy wird auch gelöscht.';

  @override
  String get deviceForget => 'Vergessen';

  @override
  String get deviceCancel => 'Abbrechen';

  @override
  String get deviceSendFiles => 'Dateien senden';

  @override
  String get deviceSendFilesCaption => 'Fotos, Dokumente, alles';

  @override
  String get deviceClipboard => 'Zwischenablage';

  @override
  String get deviceClipboardCaption => 'Sende, was du kopiert hast';

  @override
  String get devicePing => 'Ping';

  @override
  String get devicePingCaption => 'Lass es klingen';

  @override
  String get deviceRemote => 'Fernbedienung';

  @override
  String get deviceRemoteCaption => 'Touchpad und Folien';

  @override
  String get deviceRinging => 'Klingelt…';

  @override
  String get deviceFindIt => 'Finden';

  @override
  String get deviceTapToStop => 'Tippen zum Beenden';

  @override
  String get deviceFindItCaption => 'Lass es laut klingeln';

  @override
  String get devicePrevious => 'Zurück';

  @override
  String get devicePause => 'Pause';

  @override
  String get devicePlay => 'Abspielen';

  @override
  String get deviceNext => 'Weiter';

  @override
  String deviceAllowOn(String name) {
    return 'Erlaube es auf $name…';
  }

  @override
  String get deviceSeeScreen => 'Bildschirm ansehen';

  @override
  String get deviceSeeScreenCaption => 'Hier zuschauen oder per Touch steuern';

  @override
  String get deviceWatch => 'Ansehen';

  @override
  String get deviceControl => 'Steuern';

  @override
  String get deviceTerminal => 'Terminal';

  @override
  String deviceTerminalShell(String name) {
    return 'Eine Shell auf $name, mit Code geschützt';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Terminals offen',
      one: '1 Terminal offen',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'Alles';

  @override
  String get deviceFilterFiles => 'Dateien';

  @override
  String get deviceFilterClipboard => 'Zwischenablage';

  @override
  String get deviceFilterLinks => 'Links';

  @override
  String get deviceFilterShowAll => 'Alles anzeigen';

  @override
  String get deviceFilterShowFiles => 'Dateien anzeigen';

  @override
  String get deviceFilterShowClipboard => 'Zwischenablage anzeigen';

  @override
  String get deviceFilterShowLinks => 'Links anzeigen';

  @override
  String get deviceActivity => 'Verlauf';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Bereit, wenn $name fragt';
  }

  @override
  String get deviceWebcam => 'Webcam';

  @override
  String get deviceInUseNow => 'Gerade in Benutzung';

  @override
  String get deviceControls => 'Steuerung';

  @override
  String get deviceMicrophone => 'Mikrofon';

  @override
  String get deviceStop => 'Beenden';

  @override
  String get deviceSecondDisplay => 'Zweiter Bildschirm';

  @override
  String get deviceShowingNow => 'Wird gerade angezeigt';

  @override
  String deviceReadySize(int width, int height) {
    return 'Bereit · $width × $height';
  }

  @override
  String get devicePhoneAs => 'Dieses Handy als';

  @override
  String deviceStartedOn(String name) {
    return 'Gestartet auf $name';
  }

  @override
  String get deviceFasterOverUsb => 'Schneller und stabiler per USB-Kabel.';

  @override
  String get deviceBackUpPhotos => 'Fotos sichern';

  @override
  String devicePhotosGoTo(String name) {
    return 'Neue Fotos landen im Bilder-Ordner von $name';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name nimmt keine Fotos an. Schalte dort „Fotos von Handys importieren“ ein.';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'Aus $folder';
  }

  @override
  String get devicePhotosFromCamera => 'Aus deinem Kameraordner';

  @override
  String devicePhotosLast(String time) {
    return 'zuletzt $time';
  }

  @override
  String get deviceGetClipboard => 'Seine Zwischenablage empfangen';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'Auf $name kopierter Text landet hier, solange ihr verbunden seid';
  }

  @override
  String get deviceAwayAll => 'Alles von unterwegs erlauben';

  @override
  String get deviceAwayAllOn =>
      'Auch von unterwegs: dieser Bildschirm, Webcam, Mikrofon und Dateien';

  @override
  String get deviceAwayAllOff =>
      'Von unterwegs: nur Zwischenablage, Links, Dateien und Klingeln';

  @override
  String get deviceNothingShared => 'Noch nichts geteilt';

  @override
  String deviceNothingSharedBody(String name) {
    return 'Dateien, Text aus der Zwischenablage und Pings zwischen diesem Handy und $name erscheinen hier.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente',
      one: '1 Element',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '„$text“';
  }

  @override
  String get activityClipboardText => 'Text aus der Zwischenablage';

  @override
  String get activityPing => 'Ping';

  @override
  String get activityYourScreen => 'Dein Bildschirm';

  @override
  String get activityYourCamera => 'Deine Kamera';

  @override
  String get activitySecondDisplay => 'Zweiter Bildschirm';

  @override
  String get activityLink => 'Link';

  @override
  String get activityRangThisPhone => 'Hat dieses Handy klingeln lassen';

  @override
  String get activityRangIt => 'Klingeln lassen';

  @override
  String get activityTouchpadKeyboard => 'Touchpad und Tastatur';

  @override
  String get activityItsScreen => 'Sein Bildschirm';

  @override
  String get activityYourMicrophone => 'Dein Mikrofon';

  @override
  String get activityWhereThisPhone => 'Wo dieses Handy ist';

  @override
  String get activityWatchingNow => 'Wird gerade angesehen';

  @override
  String get activityWatched => 'Angesehen';

  @override
  String get activityInUseWebcam => 'Gerade als Webcam in Benutzung';

  @override
  String get activityUsedWebcam => 'Als Webcam genutzt';

  @override
  String get activityBeingControlled => 'Wird gerade gesteuert';

  @override
  String get activityWatchedControlled => 'Angesehen und gesteuert';

  @override
  String get activityWatchedFromPhone => 'Von diesem Handy aus angesehen';

  @override
  String get activityInUseNow => 'Gerade in Benutzung';

  @override
  String get activityWasTouchpad => 'Dieses Handy war sein Touchpad';

  @override
  String get activityWasSecondDisplay =>
      'Dieses Handy war sein zweiter Bildschirm';

  @override
  String get activityLinkReceived => 'Link empfangen';

  @override
  String get activityOpenedOnComputer => 'Auf dem Computer geöffnet';

  @override
  String get activityInUseMicrophone => 'Gerade als Mikrofon in Benutzung';

  @override
  String get activityUsedMicrophone => 'Als Mikrofon genutzt';

  @override
  String get activityNotTold => 'Nicht verraten';

  @override
  String get activityToldWhere => 'Standort dieses Handys mitgeteilt';

  @override
  String get activityAskedToFind => 'Wollte dieses Handy finden';

  @override
  String get activityToFindIt => 'Um es zu finden';

  @override
  String get activityDeclined => 'Abgelehnt';

  @override
  String get activityFailed => 'Fehlgeschlagen';

  @override
  String get activityInProgress => 'Läuft';

  @override
  String get activityCopiedHere => 'Hierher kopiert';

  @override
  String get activityReceived => 'Empfangen';

  @override
  String get activitySent => 'Gesendet';

  @override
  String get activityStop => 'Beenden';

  @override
  String get activityCancel => 'Abbrechen';

  @override
  String get activityCopyAgain => 'Erneut kopieren';

  @override
  String get activityCopied => 'Kopiert';

  @override
  String get activityCopyLink => 'Link kopieren';

  @override
  String get activityLinkCopied => 'Link kopiert';

  @override
  String get activityNoAppForLink => 'Keine App hier kann diesen Link öffnen.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien',
      one: '1 Datei',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name ist nicht mehr da.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'Keine App auf diesem Handy kann $name öffnen.';
  }

  @override
  String get activityWaitingForYou => 'Wartet, bis du annimmst…';

  @override
  String get activityWaitingForDevice => 'Wartet, bis das Gerät annimmt…';

  @override
  String activityWaitingFor(String name) {
    return 'Wartet, bis $name annimmt…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done von $total';
  }

  @override
  String get homeSettings => 'Einstellungen';

  @override
  String get homeYourDevices => 'Deine Geräte';

  @override
  String get homeNearbyNotPaired => 'In der Nähe, nicht gekoppelt';

  @override
  String get homeAddDevice => 'Gerät hinzufügen';

  @override
  String homeVisible(String name) {
    return '$name ist in diesem Wi-Fi sichtbar';
  }

  @override
  String get homeUpdateTitle => 'Aktualisiere Linksy, um verbunden zu bleiben';

  @override
  String get homeUpdateBody =>
      'Deine Computer sprechen jetzt ein neueres Linksy als diese App.';

  @override
  String get homeGetUpdate => 'Update holen';

  @override
  String get homeSendFiles => 'Dateien senden';

  @override
  String get homePair => 'Koppeln';

  @override
  String get homeStepOpen => 'Öffne Linksy auf deinem Computer';

  @override
  String get homeStepChoose => 'Wähle „Gerät hinzufügen“';

  @override
  String get homeStepScan => 'Scanne ihn mit diesem Handy';

  @override
  String get homeConnectTitle => 'Verbinde dein\nerstes Gerät';

  @override
  String get homeConnectSubtitle =>
      'Direkt über dein Wi-Fi. Kein Konto, keine Cloud.';

  @override
  String get homeScanQr => 'QR-Code scannen';

  @override
  String get homePairByAddress => 'Stattdessen per Adresse koppeln';

  @override
  String get pairingAddDevice => 'Gerät hinzufügen';

  @override
  String get pairingAddDeviceHint =>
      'Öffne Linksy auf dem anderen Gerät und wähle „Gerät hinzufügen“.';

  @override
  String get pairingScanQr => 'QR-Code scannen';

  @override
  String get pairingScanQrCaption => 'Am schnellsten. Nichts zu tippen.';

  @override
  String get pairingByAddress => 'Per Adresse koppeln';

  @override
  String get pairingByAddressCaption =>
      'Wenn das andere Gerät nicht gefunden wird.';

  @override
  String pairingWith(String name) {
    return 'Kopple mit $name…';
  }

  @override
  String get pairingWithOtherDevice => 'Kopple mit dem anderen Gerät…';

  @override
  String get pairingAddressHint =>
      'Steht in den Einstellungen von Linksy auf dem anderen Gerät.';

  @override
  String pairingPortHint(String port) {
    return 'Port $port, außer du gibst einen anderen an.';
  }

  @override
  String get pairingPair => 'Koppeln';

  @override
  String pairingWantsToPair(String name) {
    return '$name möchte koppeln';
  }

  @override
  String pairingPairWith(String name) {
    return 'Mit $name koppeln';
  }

  @override
  String get pairingCodeHint => 'Beide Bildschirme sollten diesen Code zeigen.';

  @override
  String pairingCodeLabel(String code) {
    return 'Code $code';
  }

  @override
  String get pairingCodesMatch => 'Codes stimmen überein';

  @override
  String get scanNeedsCamera =>
      'Linksy braucht die Kamera, um den Kopplungscode zu scannen. Erlaube sie oder kopple per Adresse.';

  @override
  String get scanCameraUnavailable => 'Die Kamera ist nicht verfügbar.';

  @override
  String get scanFlashlight => 'Taschenlampe';

  @override
  String get scanTitle => 'Scanne den Code';

  @override
  String get scanWrongCode =>
      'Das ist kein Linksy-Code. Öffne auf deinem Computer Linksy → Mit QR-Code koppeln.';

  @override
  String get scanHint =>
      'Öffne Linksy auf deinem Computer und wähle „Gerät hinzufügen“.';

  @override
  String get shareSheetPutOnClipboard => 'In eine Zwischenablage legen';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien senden',
      one: 'Eine Datei senden',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Auf einem Computer öffnen';

  @override
  String get shareSheetSendToClipboard => 'An eine Zwischenablage senden';

  @override
  String get shareSheetNoClipboardFiles =>
      'Noch keiner deiner Computer nimmt Dateien in die Zwischenablage. Aktualisiere Linksy dort.';

  @override
  String get shareSheetNoComputers =>
      'Kopple zuerst einen Computer, dann teile aus jeder App dorthin.';

  @override
  String get shareSheetSendFileInstead => 'Stattdessen die Datei senden';

  @override
  String get shareSheetClipboardInstead =>
      'Stattdessen in die Zwischenablage des Computers legen';

  @override
  String get shareSheetOpenLinkInstead => 'Stattdessen den Link öffnen';

  @override
  String get shareSheetSendAsTextInstead =>
      'Stattdessen als Text in die Zwischenablage senden';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Wird in die Zwischenablage von $name gelegt';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Wird in die Zwischenablage des Computers gelegt';

  @override
  String shareSheetOpened(String name) {
    return 'Auf $name geöffnet';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Auf dem Computer geöffnet';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'An die Zwischenablage von $name gesendet';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'An die Zwischenablage des Computers gesendet';

  @override
  String shareSheetSentALink(String name) {
    return '$name hat einen Link gesendet';
  }

  @override
  String get shareSheetOpen => 'Öffnen';

  @override
  String get shareSheetCopyLink => 'Link kopieren';

  @override
  String get shareSheetLinkCopied => 'Link kopiert';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien',
      one: 'eine Datei',
    );
    return '$name sendet dir $_temp0';
  }

  @override
  String incomingTotal(String size) {
    return '$size insgesamt';
  }

  @override
  String incomingMore(int count) {
    return '+ $count weitere';
  }

  @override
  String get incomingAccept => 'Annehmen';

  @override
  String get appInvalidPairingLink => 'Dieser Kopplungslink ist ungültig.';

  @override
  String appPairingFailed(String reason) {
    return 'Koppeln fehlgeschlagen: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'Koppeln mit $name fehlgeschlagen: $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Mit $name gekoppelt';
  }

  @override
  String appNotification(String name, String text) {
    return '$name: $text';
  }

  @override
  String appCopiedText(String name) {
    return 'Text von $name kopiert';
  }

  @override
  String appCopiedFile(String file, String name) {
    return '$file von $name kopiert';
  }

  @override
  String get appCouldntStart => 'Linksy konnte nicht starten';

  @override
  String get commonDismiss => 'Ausblenden';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDecline => 'Ablehnen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonNotNow => 'Nicht jetzt';

  @override
  String get commonConnected => 'Verbunden';

  @override
  String get commonNearby => 'In der Nähe';

  @override
  String get commonNotNearby => 'Nicht in der Nähe';

  @override
  String get commonUsbCable => 'USB-Kabel';

  @override
  String get commonAwayFromHome => 'Unterwegs';

  @override
  String get commonSameWifi => 'Selbes Wi-Fi';

  @override
  String get commonConnectedByUsb => 'Per USB verbunden';

  @override
  String get commonConnectedAway => 'Unterwegs verbunden';

  @override
  String commonBattery(int level) {
    return 'Akku $level Prozent';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Akku $level Prozent, lädt';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bytes',
      one: '1 Byte',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'noch $count Sekunden',
      one: 'noch 1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'noch $count Minuten',
      one: 'noch 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'noch etwa $count Stunden',
      one: 'noch etwa 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Heute';

  @override
  String get formatYesterday => 'Gestern';

  @override
  String get formatPhone => 'Handy';

  @override
  String get settingsBack => 'Zurück';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsReceiving => 'Empfangen';

  @override
  String get settingsSaveLocation => 'Speicherort';

  @override
  String get settingsSaveLocationPath => 'Downloads › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Von meinen Geräten annehmen';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'Dateien von gekoppelten Geräten kommen ohne Nachfrage an.';

  @override
  String get settingsConnection => 'Verbindung';

  @override
  String get settingsStayConnected => 'Verbunden bleiben';

  @override
  String get settingsStayConnectedCaption =>
      'Schnelleres Teilen mit Geräten in der Nähe. Braucht mehr Akku.';

  @override
  String get settingsKeepRunning => 'Im Hintergrund weiterlaufen';

  @override
  String get settingsKeepRunningCaption =>
      'Dateien, Foto-Backup und Anrufe funktionieren auch, wenn Linksy geschlossen ist. Zeigt eine dezente Mitteilung.';

  @override
  String get settingsAwayFromHome => 'Unterwegs';

  @override
  String get settingsAwayFromHomeCaption =>
      'Erreiche deine Computer über das Internet, wenn ihr nicht im selben Netzwerk seid – bis eine Woche nach dem letzten Mal. Ende-zu-Ende-verschlüsselt.';

  @override
  String get settingsRelay => 'Relay-Server';

  @override
  String get settingsRelayDefault => 'Linksys eigener';

  @override
  String get settingsRelayCaption =>
      'Die Adresse eines Relays, das du selbst betreibst, etwa https://relay.example.com. Leer lassen für Linksys eigenes. Stelle auf jedem Gerät dasselbe Relay ein.';

  @override
  String get settingsWithYourComputers => 'Mit deinen Computern';

  @override
  String get settingsPauseMusic => 'Musik bei Anrufen pausieren';

  @override
  String get settingsPauseMusicCaption =>
      'Deine Computer pausieren die Wiedergabe, während ein Anruf klingelt oder läuft, und setzen sie danach fort.';

  @override
  String get settingsBrowseFiles => 'Computer dürfen Dateien durchsuchen';

  @override
  String get settingsBrowseFilesChoose =>
      'Wähle einen Ordner, den deine Computer in ihrer Dateien-App öffnen können, z. B. Documents (Android erlaubt Download nicht).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Teilt „$folder“. Tippe, um einen anderen Ordner zu wählen.';
  }

  @override
  String get settingsPicture => 'Bild dieses Handys';

  @override
  String get settingsPictureChoose =>
      'Deine Computer zeigen es für dieses Handy. Tippe, um eins zu wählen.';

  @override
  String get settingsPictureChange =>
      'Deine Computer zeigen es für dieses Handy. Tippe, um es zu ändern.';

  @override
  String get settingsPictureRemove => 'Entfernen';

  @override
  String get settingsLocate => 'Computer dürfen dieses Handy orten';

  @override
  String get settingsLocateCaption =>
      'Ein Computer kann einmalig fragen, wo dieses Handy ist, um es zu finden. Nichts wird gespeichert oder verfolgt. Funktioniert, solange Linksy offen ist.';

  @override
  String get settingsLocatePermission =>
      'Linksy braucht dafür die Standortberechtigung.';

  @override
  String get settingsPhotoFolder => 'Fotoordner';

  @override
  String get settingsPhotoFolderChoose =>
      'Wähle deinen Kameraordner (DCIM › Camera), um Fotos auf einem Computer zu sichern.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Sichert „$folder“. Schalte es pro Computer auf dessen Seite ein.';
  }

  @override
  String get settingsThisApp => 'Diese App';

  @override
  String get settingsPermissions => 'Berechtigungen';

  @override
  String get settingsDemo => 'Demo';

  @override
  String get settingsDemoCaption =>
      'Simulierte Geräte, bis der Linksy-Kern verbunden ist. Sie starten, was ein anderes Gerät tun würde.';

  @override
  String get settingsDemoReceiveFiles => 'Dateien empfangen';

  @override
  String get settingsDemoReceivePairing => 'Kopplungsanfrage empfangen';

  @override
  String get settingsDemoReceiveClipboard =>
      'Text für die Zwischenablage empfangen';

  @override
  String get settingsTagline =>
      'Deine Geräte, verbunden.\nKein Konto, keine Cloud.';

  @override
  String get settingsNameTitle => 'Dieses Handy benennen';

  @override
  String get settingsNameCaption => 'Deine anderen Geräte sehen diesen Namen.';

  @override
  String get settingsSave => 'Speichern';

  @override
  String get settingsCancel => 'Abbrechen';

  @override
  String settingsRename(String name) {
    return '$name umbenennen';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'Dieses Handy · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Mitteilungen und Kamera';

  @override
  String get settingsPermissionsWhat =>
      'Was Linksy von Android braucht und warum.';

  @override
  String get settingsPermissionsBoth => 'Beide erlaubt.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count von 2 erlaubt. Tippe, um den Rest zu erlauben.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Berechtigungen';

  @override
  String get permissionsIntro =>
      'Linksy fragt nur nach dem, was es braucht, und du kannst alles später in den Einstellungen ändern.';

  @override
  String get permissionsNotifications => 'Mitteilungen';

  @override
  String get permissionsNotificationsWhy =>
      'Zeigt, wenn ein Computer deinen Bildschirm sieht oder deine Kamera nutzt, mit einem Knopf zum Beenden.';

  @override
  String get permissionsCamera => 'Kamera';

  @override
  String get permissionsCameraWhy =>
      'Scannt den QR-Code zum Koppeln und lässt einen Computer dieses Handy als Webcam nutzen, wenn du es erlaubst.';

  @override
  String get permissionsAllow => 'Erlauben';

  @override
  String get permissionsAllowed => 'Erlaubt';

  @override
  String get permissionsDone => 'Fertig';

  @override
  String get remoteBack => 'Zurück';

  @override
  String get remoteTitle => 'Fernbedienung';

  @override
  String remoteAllowOn(String name) {
    return 'Erlaube es auf $name';
  }

  @override
  String remoteAsks(String name) {
    return 'Linksy auf $name fragt, ob dieses Handy den Zeiger bewegen und tippen darf.';
  }

  @override
  String get remoteFailed => 'Das hat nicht geklappt';

  @override
  String get remoteStopped => 'Die Fernbedienung wurde beendet';

  @override
  String remoteEndedBy(String name) {
    return '$name hat sie beendet.';
  }

  @override
  String get remoteTryAgain => 'Erneut versuchen';

  @override
  String get remoteTouchpad => 'Touchpad';

  @override
  String get remoteSlides => 'Folien';

  @override
  String get remoteTouchpadHint =>
      'Mit einem Finger bewegen, tippen zum Klicken\nZwei Finger scrollen, Tippen mit zwei Fingern = Rechtsklick';

  @override
  String get remoteLeftClick => 'Linksklick';

  @override
  String get remoteRightClick => 'Rechtsklick';

  @override
  String get remoteKeyboard => 'Tastatur';

  @override
  String get remoteNextSlide => 'Nächste Folie';

  @override
  String get remoteNext => 'Weiter';

  @override
  String get remotePreviousSlide => 'Vorherige Folie';

  @override
  String get remoteSlideBack => 'Zurück';

  @override
  String get remoteStartShow => 'Start (F5)';

  @override
  String get remoteEndShow => 'Ende (Esc)';

  @override
  String get remoteVolumeHint =>
      'Leiser: weiter · Lauter: zurück. Der Bildschirm bleibt an.';

  @override
  String get ringTitle => 'Hier bin ich!';

  @override
  String ringLookingFor(String name) {
    return '$name sucht dieses Handy.';
  }

  @override
  String get ringFoundIt => 'Gefunden';

  @override
  String get webcamBack => 'Zurück';

  @override
  String get webcamTitle => 'Webcam';

  @override
  String webcamLiveOn(String name) {
    return 'Live auf $name';
  }

  @override
  String get webcamStopSemantic => 'Webcam beenden';

  @override
  String get webcamStop => 'Beenden';

  @override
  String get webcamBadgeLive => 'LIVE';

  @override
  String get webcamBadgeLock => 'AE/AF-SPERRE';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'LICHT';

  @override
  String get webcamFacingFront => 'Vorne';

  @override
  String get webcamFacingBack => 'Hinten';

  @override
  String get webcamTorch => 'Licht';

  @override
  String get webcamPortrait => 'Hochformat';

  @override
  String get webcamLandscape => 'Querformat';

  @override
  String get webcamLocked => 'Gesperrt';

  @override
  String get webcamLock => 'Sperren';

  @override
  String get webcamTabLight => 'Licht';

  @override
  String get webcamTabFocus => 'Fokus';

  @override
  String get webcamTabColor => 'Farbe';

  @override
  String get webcamTabStream => 'Stream';

  @override
  String get webcamBrightness => 'Helligkeit';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto => 'Diese Kamera regelt die Belichtung selbst.';

  @override
  String get webcamLockExposure => 'Belichtung sperren';

  @override
  String get webcamLockExposureDetail =>
      'Hält die Helligkeit, wie sie gerade ist. Halte das Bild gedrückt, um auf einen Punkt zu sperren.';

  @override
  String get webcamFocus => 'Fokus';

  @override
  String get webcamFocusFixed => 'Diese Kamera hat einen festen Fokus.';

  @override
  String get webcamFocusSpotDetail =>
      'Bleibt, wo du getippt hast. Tippe doppelt auf das Bild für Auto.';

  @override
  String get webcamFocusManualDetail => 'Unten von Hand eingestellt.';

  @override
  String get webcamFocusAutoDetail =>
      'Folgt dem Bild. Tippe darauf, um auf einen Punkt zu fokussieren.';

  @override
  String get webcamFocusAuto => 'Auto';

  @override
  String get webcamFocusSpot => 'Punkt';

  @override
  String get webcamFocusManual => 'Manuell';

  @override
  String get webcamDistance => 'Entfernung';

  @override
  String get webcamFar => 'Fern';

  @override
  String get webcamNear => 'Nah';

  @override
  String get webcamWbAuto => 'Auto';

  @override
  String get webcamWbDaylight => 'Tageslicht';

  @override
  String get webcamWbCloudy => 'Bewölkt';

  @override
  String get webcamWbShade => 'Schatten';

  @override
  String get webcamWbIncandescent => 'Warmes Licht';

  @override
  String get webcamWbFluorescent => 'Bürolicht';

  @override
  String get webcamWhiteBalance => 'Weißabgleich';

  @override
  String get webcamLockColors => 'Farben sperren';

  @override
  String get webcamLockColorsDetail =>
      'Verhindert, dass sich die Farben mit dem Licht verschieben.';

  @override
  String get webcamOrientation => 'Ausrichtung';

  @override
  String get webcamOrientationPortraitDetail =>
      'Halte das Handy aufrecht; Balken an den Seiten.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Halte das Handy quer; es füllt das Bild.';

  @override
  String get webcamFrameRate => 'Bildrate';

  @override
  String get webcamFps60Detail =>
      'Flüssigere Bewegung; braucht mehr Daten und Akku.';

  @override
  String get webcamFps30Detail => 'Stabil für Videoanrufe.';

  @override
  String get webcamFpsOnly30 => 'Diese Kamera schafft bis zu 30 fps.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Auflösung';

  @override
  String get webcamResolution1080Detail =>
      'Full HD, für einen großen Bildschirm; mehr Daten.';

  @override
  String get webcamResolution720Detail => 'HD, passend für Videoanrufe.';

  @override
  String get webcamResolutionOnly720 => 'Diese Kamera streamt in 720p.';

  @override
  String get webcamQuality => 'Qualität';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, für ein volles Wi-Fi.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, die meisten Details.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, scharf für Videoanrufe.';
  }

  @override
  String get webcamQualitySaver => 'Sparsam';

  @override
  String get webcamQualityStandard => 'Standard';

  @override
  String get webcamQualityHigh => 'Hoch';

  @override
  String get webcamStabilization => 'Stabilisierung';

  @override
  String get webcamStabilizationDetail => 'Gleicht Verwackeln aus.';

  @override
  String get webcamMirror => 'Vorschau spiegeln';

  @override
  String get webcamMirrorDetail =>
      'Nur auf diesem Handy; der Computer bekommt es ungespiegelt.';

  @override
  String get webcamFormat => 'Format';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Zurücksetzen';

  @override
  String webcamResetSetting(String setting) {
    return '$setting zurücksetzen';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name möchte deinen Bildschirm sehen';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Alles auf dem Bildschirm dieses Handys erscheint auf $name, bis du beendest. Android fragt gleich nach einer Bestätigung.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name möchte deinen Bildschirm steuern';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '$name sieht den Bildschirm dieses Handys und kann darauf tippen, wischen und schreiben, bis du beendest. Android fragt gleich nach einer Bestätigung.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name möchte deine Kamera nutzen';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '$name bekommt die Kamera dieses Handys als Webcam, bis du beendest. Zoom, Fokus, Licht, Objektive und Drehung findest du währenddessen in Linksy.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name möchte dieses Handy als Touchpad nutzen';
  }

  @override
  String get sharingInputRequestDetail =>
      'Unerwartet: Computer fragen das nicht. Erlaube es nicht.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name möchte dein Mikrofon nutzen';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '$name hört das Mikrofon dieses Handys, bis du beendest – als Mikrofon, das jede App dort nutzen kann. Android fragt gleich nach einer Bestätigung.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name möchte diesen Bildschirm als zweiten Bildschirm nutzen';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'Dieses Handy zeigt einen Bildschirm von $name im Vollbild. Tippe zum Klicken und Ziehen; scrolle mit zwei Fingern. Geh zurück, um zu beenden.';
  }

  @override
  String get sharingAllow => 'Erlauben';

  @override
  String get sharingDontAllow => 'Nicht erlauben';

  @override
  String get sharingProtectionHint =>
      'Statusleiste oder Mitteilungen auf dem Computer schwarz? Der Bildschirmfreigabe-Schutz von Android blendet sie aus. Schalte in den Entwickleroptionen „Schutz bei Bildschirmfreigabe deaktivieren“ ein und teile dann erneut.';

  @override
  String get sharingGotIt => 'Verstanden';

  @override
  String get sharingDeveloperOptions => 'Entwickleroptionen';

  @override
  String sharingControlling(String name) {
    return '$name steuert deinen Bildschirm';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name nutzt deine Kamera';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name nutzt dein Mikrofon';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Bildschirm wird mit $name geteilt';
  }

  @override
  String get sharingTapForCameraControls => 'Tippe für die Kamerasteuerung';

  @override
  String get sharingSwitchCamera => 'Kamera wechseln';

  @override
  String get sharingStopSharing => 'Teilen beenden';

  @override
  String get sharingStop => 'Beenden';

  @override
  String get sharingCameraControls => 'Kamerasteuerung';

  @override
  String displaySecondHint(String name) {
    return 'Zweiter Bildschirm von $name · zurück zum Beenden';
  }

  @override
  String displayControlHint(String name) {
    return 'Bildschirm von $name · tippen zum Klicken · zurück zum Beenden';
  }

  @override
  String displayWatchHint(String name) {
    return 'Bildschirm von $name · zurück zum Beenden';
  }

  @override
  String terminalTabClosed(String title) {
    return '„$title“ geschlossen';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '„$title“ auf $name beendet';
  }

  @override
  String get terminalCloseTitle => 'Dieses Terminal schließen?';

  @override
  String terminalCloseDetail(String name) {
    return 'Die Shell endet auf $name, samt allem, was darin noch läuft. Um später zurückzukommen, lass sie stattdessen weiterlaufen.';
  }

  @override
  String get terminalKeepRunning => 'Weiterlaufen lassen';

  @override
  String get terminalClose => 'Schließen';

  @override
  String get terminalTheComputer => 'der Computer';

  @override
  String get terminalDetached => 'Getrennt';

  @override
  String terminalDetachedDetail(String name) {
    return 'Läuft noch auf $name. Verbinde dich neu, um sie wieder zu sehen; der Code wird erneut abgefragt.';
  }

  @override
  String get terminalReattach => 'Neu verbinden';

  @override
  String terminalOn(String name) {
    return 'Terminal auf $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Getrennt · läuft noch auf $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Wird auf $name geöffnet…';
  }

  @override
  String get terminalWaitingForCode => 'Wartet auf den Code';

  @override
  String get terminalEnded => 'Beendet';

  @override
  String get terminalBack => 'Zurück';

  @override
  String get terminalTitle => 'Terminal';

  @override
  String get terminalMenu => 'Terminal-Menü';

  @override
  String get terminalDetachMenu => 'Weiterlaufen lassen (trennen)';

  @override
  String terminalCloseTab(String title) {
    return '$title schließen';
  }

  @override
  String get terminalNew => 'Neues Terminal';

  @override
  String terminalShellOn(String name) {
    return 'Eine Shell auf $name';
  }

  @override
  String get terminalShellDetail =>
      'Läuft als du auf dem Computer, in deinem Home-Ordner. Bei jedem Öffnen fragt sie nach dem dort festgelegten Terminal-Code.';

  @override
  String get terminalStillRunning => 'LÄUFT NOCH';

  @override
  String terminalReattachTab(String title) {
    return '$title neu verbinden';
  }

  @override
  String terminalStarted(String time) {
    return 'Gestartet $time';
  }

  @override
  String get terminalKeyLeft => 'Links';

  @override
  String get terminalKeyUp => 'Hoch';

  @override
  String get terminalKeyDown => 'Runter';

  @override
  String get terminalKeyRight => 'Rechts';

  @override
  String get terminalCodeTitle => 'Terminal-Code';

  @override
  String terminalCodeDetail(String name) {
    return 'Der Code, der auf $name unter Einstellungen › Terminal festgelegt ist. Linksy speichert ihn nie.';
  }

  @override
  String get terminalCodePassphrase => 'Passphrase';

  @override
  String get terminalCodeDigitsHint => '6 oder mehr Ziffern';

  @override
  String get terminalCodeUseDigits => 'Ziffern verwenden';

  @override
  String get terminalCodeUseLetters => 'Buchstaben verwenden';

  @override
  String get terminalOpening => 'Wird geöffnet…';

  @override
  String get terminalOpen => 'Terminal öffnen';

  @override
  String get settingsAppearance => 'Darstellung';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String usbConnectedTo(String name) {
    return 'Mit $name per USB-Kabel verbunden';
  }

  @override
  String get usbPairTitle => 'Ein Computer hängt am Kabel';

  @override
  String get usbPairBody =>
      'Er ist noch nicht mit diesem Handy gekoppelt. Über das Kabel koppeln? Beide Bildschirme zeigen einen Code zum Vergleichen.';

  @override
  String get usbPairAction => 'Koppeln';
}
