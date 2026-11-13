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
      'Von unterwegs: Zwischenablage, Links, Dateien, Klingeln, Fotos und Regler';

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
  String get activityReconnecting =>
      'Verbindung weg, geht weiter, sobald sie zurück ist';

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
  String get settingsSearch => 'Einstellungen durchsuchen';

  @override
  String settingsNothingMatches(String query) {
    return 'Nichts passt zu „$query“';
  }

  @override
  String get settingsRecommended => 'Empfohlen';

  @override
  String get settingsReceiving => 'Empfangen';

  @override
  String get settingsFiles => 'Dateien';

  @override
  String get settingsSaveLocation => 'Speicherort';

  @override
  String settingsSaveLocationUse(String path) {
    return '$path verwenden';
  }

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
  String get settingsWays => 'Wie es deine Computer erreicht';

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
  String get settingsStartAtBoot => 'Mit dem Telefon starten';

  @override
  String get settingsStartAtBootCaption =>
      'Nach einem Neustart sehen deine Computer dieses Telefon, ohne dass du Linksy öffnest. Zeigt eine dezente Benachrichtigung.';

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
  String get settingsFilesFolder => 'Ein Ordner deiner Wahl';

  @override
  String get settingsFilesAll => 'Alle Dateien';

  @override
  String get settingsFilesAllCaption =>
      'Deine Computer können jede Datei auf diesem Handy öffnen.';

  @override
  String get settingsFilesAllAllow =>
      'Erlaube Linksy „Zugriff auf alle Dateien“ in den Android-Einstellungen.';

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
  String get remoteDragHint =>
      'Doppelt tippen und wischen zum Ziehen, tippen zum Loslassen';

  @override
  String get remoteDragging =>
      'Ziehen. Finger anheben und weitermachen, tippen zum Loslassen';

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
  String get remoteBrowser => 'Browser';

  @override
  String get remoteWebBack => 'Zurück';

  @override
  String get remoteWebForward => 'Vor';

  @override
  String get remoteWebReload => 'Neu laden';

  @override
  String get remoteWebHome => 'Startseite';

  @override
  String get remoteWebNewTab => 'Neuer Tab';

  @override
  String get remoteWebCloseTab => 'Tab schließen';

  @override
  String get remoteWebNextTab => 'Nächster Tab';

  @override
  String get remoteWebPrevTab => 'Vorheriger Tab';

  @override
  String get remoteWebAddress => 'Adresse';

  @override
  String get remoteWebHint =>
      'Steuert den Browser im Vordergrund des Computers.';

  @override
  String get remoteFirstSlide => 'Erste';

  @override
  String get remoteLastSlide => 'Letzte';

  @override
  String get remoteBlackScreen => 'Schwarz';

  @override
  String get remoteWhiteScreen => 'Weiß';

  @override
  String get remoteFromHere => 'Ab hier';

  @override
  String get remoteModHint =>
      'Tippen: mit der nächsten Taste. Halten: allein drücken.';

  @override
  String get switchTitle => 'Wechseln zu';

  @override
  String get switchHere => 'Hier';

  @override
  String get switchOpen => 'Offen';

  @override
  String get settingsPointerSpeed => 'Touchpad-Tempo';

  @override
  String get settingsPointerSpeedCaption =>
      'Wie weit der Zeiger des Computers bei gleicher Wischbewegung geht';

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
      'Ein hohes Bild mit Balken an den Seiten, für Apps, die eines wollen.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Füllt das Bild und bleibt aufrecht, egal wie das Handy steht.';

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
  String get displayChooseScreen => 'Bildschirm wählen';

  @override
  String displayChooseOn(String name) {
    return 'Wähle den Bildschirm auf $name…';
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
  String get usbConnecting => 'Verbinde per USB-Kabel…';

  @override
  String get usbPairTitle => 'Ein Computer hängt am Kabel';

  @override
  String get usbPairBody =>
      'Er ist noch nicht mit diesem Handy gekoppelt. Über das Kabel koppeln? Beide Bildschirme zeigen einen Code zum Vergleichen.';

  @override
  String get usbPairAction => 'Koppeln';

  @override
  String get sendPhotos => 'Fotos und Videos';

  @override
  String get sendPhotosCaption => 'Aus deiner Galerie, viele auf einmal';

  @override
  String get sendFiles => 'Dateien';

  @override
  String get sendFilesCaption => 'Dokumente und alles andere';

  @override
  String activityPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fotos',
      one: '$count Foto',
    );
    return '$_temp0';
  }

  @override
  String activityVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Videos',
      one: '$count Video',
    );
    return '$_temp0';
  }

  @override
  String activityPhotosVideos(int count) {
    return '$count Fotos und Videos';
  }

  @override
  String get transfersTitle => 'Übertragungen';

  @override
  String get transfersWaiting => 'Wartet';

  @override
  String transfersFilesDone(int done, int total) {
    return '$done von $total Dateien';
  }

  @override
  String transfersTo(String name) {
    return 'An $name';
  }

  @override
  String transfersFrom(String name) {
    return 'Von $name';
  }

  @override
  String get transfersAllDone => 'Alles fertig';

  @override
  String transfersBubble(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien unterwegs',
      one: '$count Datei unterwegs',
    );
    return '$_temp0';
  }

  @override
  String get newsTitle => 'Neuigkeiten';

  @override
  String newsHeading(String version) {
    return 'Neu in Linksy $version';
  }

  @override
  String newsAllChanges(String version) {
    return 'Alle Änderungen in $version';
  }

  @override
  String get newsContinue => 'Weiter';

  @override
  String get newsStar => 'Linksy auf GitHub einen Stern geben';

  @override
  String get newsStarCaption =>
      'Linksy ist frei und quelloffen. Ein Stern auf GitHub hilft anderen, es zu finden.';

  @override
  String get news024PrivateTitle => 'Privat in jedem Netz';

  @override
  String get news024PrivateBody =>
      'Im WLAN eines Cafés oder Büros sehen Fremde den Namen dieses Telefons nicht mehr. Deine Computer finden es weiterhin, und Gerät hinzufügen zeigt es einem neuen.';

  @override
  String get news024UpdateTitle => 'Update mit einem Tippen';

  @override
  String get news024UpdateBody =>
      'Wenn eine neue Version erscheint, lädt Jetzt aktualisieren sie herunter und prüft sie, dann installiert Android sie.';

  @override
  String get news024NewsTitle => 'Neuigkeiten, genau hier';

  @override
  String get news024NewsBody =>
      'Jedes Update zeigt jetzt beim ersten Öffnen, was sich geändert hat. Es steht auch in den Einstellungen.';

  @override
  String updateAvailable(String version) {
    return 'Linksy $version ist verfügbar';
  }

  @override
  String updateBody(String current) {
    return 'Installiert ist $current. Linksy lädt das Update herunter und prüft es, dann bittet Android dich, es zu installieren.';
  }

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get updateLater => 'Später';

  @override
  String updateWhatChanged(String version) {
    return 'Was sich in $version ändert';
  }

  @override
  String get updateToInstall => 'Zu installieren';

  @override
  String updateDownloading(String percent) {
    return 'Wird geladen, $percent %';
  }

  @override
  String get updateInstalling => 'Android installiert es…';

  @override
  String updateNewest(String version) {
    return 'Linksy $version ist die neueste Version.';
  }

  @override
  String get updateCheck => 'Nach Updates suchen';

  @override
  String get updateFailedNetwork =>
      'Der Download wurde nicht abgeschlossen. Prüfe die Verbindung und versuche es erneut.';

  @override
  String get updateFailedCheck =>
      'Der Download passt nicht zur Prüfsumme der Version und wurde deshalb nicht installiert.';

  @override
  String get updateAllow =>
      'Erlaube Linksy, Apps zu installieren, und tippe dann erneut auf Jetzt aktualisieren.';

  @override
  String updateFailedInstall(String message) {
    return 'Android hat es nicht installiert: $message';
  }

  @override
  String get settingsMediaNotice => 'Musik in den Benachrichtigungen';

  @override
  String get settingsMediaNoticeCaption =>
      'Was deine Computer abspielen, erscheint bei den Benachrichtigungen des Telefons, mit Tasten.';

  @override
  String get settingsReverseScroll => 'Umgekehrt scrollen';

  @override
  String get settingsReverseScrollCaption =>
      'Zwei Finger scrollen andersherum, auf dem Touchpad und auf dem Bildschirm eines Computers.';

  @override
  String get remoteNumbers => 'Zahlen';

  @override
  String get remoteBackspace => 'Löschen';

  @override
  String get remoteEnter => 'Eingabe';

  @override
  String get deviceBack10 => '10 Sekunden zurück';

  @override
  String get deviceForward10 => '10 Sekunden vor';

  @override
  String get news025MediaTitle =>
      'Die Musik deines Computers in den Benachrichtigungen';

  @override
  String get news025MediaBody =>
      'Was er abspielt, erscheint bei den Benachrichtigungen: Abspielen, Überspringen, 10 Sekunden zurück oder vor und ein Fortschrittsbalken. Auch auf seiner Seite.';

  @override
  String get news025NumbersTitle => 'Zahlen auf der Präsentationsfernbedienung';

  @override
  String get news025NumbersBody =>
      'Gib die Nummer einer Folie ein, dann Eingabe, um dorthin zu springen. Die Tastatur geht dort auch.';

  @override
  String get news025RemoteTitle => 'Zuverlässigere Fernbedienung';

  @override
  String get news025RemoteBody =>
      'Großbuchstaben lassen Shift auf dem Computer nicht mehr hängen, und das Scrollen mit zwei Fingern lässt sich umkehren (Einstellungen).';

  @override
  String get deviceMute => 'Stumm';

  @override
  String get deviceUnmute => 'Ton an';

  @override
  String deviceVolume(String percent) {
    return 'Lautstärke $percent %';
  }

  @override
  String get news026VolumeTitle => 'Die Lautstärke des Computers';

  @override
  String get news026VolumeBody =>
      'Lauter oder leiser auf seiner Seite, oder mit den Lautstärketasten dieses Telefons, solange die Seite offen ist.';

  @override
  String get transfersNone => 'Gerade nichts unterwegs';

  @override
  String get transfersNoneBody =>
      'Dateien, die du sendest oder empfängst, erscheinen hier mit ihrer Geschwindigkeit.';

  @override
  String get transfersRecent => 'Zuletzt';

  @override
  String transfersFastMovie(int seconds) {
    return 'Ein 1-GB-Film alle $seconds s';
  }

  @override
  String transfersFastPhotos(int count) {
    return 'Etwa $count Fotos pro Sekunde';
  }

  @override
  String transfersFastSongs(int count) {
    return '$count Songs pro Sekunde';
  }

  @override
  String get news026TransfersTitle =>
      'Übertragungen, immer einen Tipp entfernt';

  @override
  String get news026TransfersBody =>
      'Der Knopf unten links öffnet jederzeit die Übertragungen: Dateien in ihrer echten Geschwindigkeit, der Fortschritt jeder Datei und was zuletzt kam und ging.';

  @override
  String get islandSeeMore => 'Mehr anzeigen';

  @override
  String get transfersRouteDirect => 'Wi-Fi Direct';

  @override
  String get transfersRouteDirectSetup => 'Wi-Fi Direct wird eingerichtet';

  @override
  String transfersDirectFinding(String name) {
    return 'Suche $name';
  }

  @override
  String get transfersDirectConnecting => 'Verbinden';

  @override
  String get transfersDirectLinking => 'Verknüpfen';

  @override
  String get news028DirectTitle => 'Wi-Fi Direct für große Dateien';

  @override
  String get news028DirectBody =>
      'Dateien ab 256 MB gehen über eine eigene WLAN-Verbindung direkt an deinen Computer, viel schneller als über den Router. Braucht Linksy 0.9.9 auf dem Computer.';

  @override
  String get news028BackgroundTitle => 'Große Dateien, im Hintergrund';

  @override
  String get news028BackgroundBody =>
      'Lange Videos werden sofort gesendet, und Übertragungen laufen bei ausgeschaltetem Bildschirm weiter, mit Fortschritt in der Benachrichtigungsleiste.';

  @override
  String get settingsDirect => 'Wi-Fi Direct für große Dateien';

  @override
  String get settingsDirectCaption =>
      'Schneller, direkt zum anderen Gerät. Aus: immer über dein WLAN.';

  @override
  String get settingsLogs => 'Protokolle';

  @override
  String get settingsLogsCaption =>
      'Was zuletzt passiert ist, für einen Fehlerbericht';

  @override
  String get logsPrivacy =>
      'Protokolle bleiben auf diesem Telefon. Nichts wird gesendet: Kopiere sie selbst, wenn du ein Problem meldest.';

  @override
  String get logsThisPhone => 'Dieses Telefon';

  @override
  String get logsEvents => 'Was passiert ist';

  @override
  String get logsCopy => 'Kopieren';

  @override
  String get logsCopied => 'Kopiert';

  @override
  String get logsEmpty =>
      'Noch nichts. Verbindungen, Übertragungen und Wi-Fi-Direct-Schritte erscheinen hier.';

  @override
  String get news029PhonesTitle => 'Wi-Fi Direct zwischen Telefonen';

  @override
  String get news029PhonesBody =>
      'Große Dateien gehen jetzt direkt von einem Telefon zum anderen, ohne Router. Beide brauchen Linksy 0.2.9. Du kannst es in den Einstellungen ausschalten.';

  @override
  String get news029LogsTitle => 'Protokolle';

  @override
  String get news029LogsBody =>
      'Einstellungen › Protokolle zeigt dieses Telefon und was zuletzt passiert ist, zum Kopieren in einen Fehlerbericht. Sie bleiben auf diesem Telefon.';

  @override
  String pairingUpdateOlder(String name) {
    return 'Ein Update von Linksy auf $name macht das Koppeln noch sicherer.';
  }

  @override
  String get settingsPhoneNotifications =>
      'Benachrichtigungen dieses Telefons zeigen';

  @override
  String get settingsPhoneNotificationsCaption =>
      'Auf deinen Computern, mit Antworten für Nachrichten.';

  @override
  String get settingsPhoneNotificationsAllow =>
      'Android hat es noch nicht erlaubt. Tippe, um den Benachrichtigungszugriff zu erlauben.';

  @override
  String get noticeAccessTitle => 'Benachrichtigungszugriff erlauben';

  @override
  String get noticeAccessGreyed =>
      'Android graut diesen Schalter für Apps aus, die aus dem Web installiert wurden. So erlaubst du es:';

  @override
  String get noticeAccessStepInfo => 'Öffne die App-Info von Linksy.';

  @override
  String get noticeAccessStepRestricted =>
      'Tippe oben rechts auf ⋮, dann auf Eingeschränkte Einstellungen zulassen.';

  @override
  String get noticeAccessStepAgain =>
      'Öffne den Benachrichtigungszugriff erneut und schalte Linksy ein.';

  @override
  String get noticeAccessPlain =>
      'Schalte Linksy in Androids Benachrichtigungszugriff ein und komm dann zurück.';

  @override
  String get commonOpenAppInfo => 'App-Info öffnen';

  @override
  String get batteryGuide => 'Linksy am Laufen halten';

  @override
  String batteryGuideCaption(String maker) {
    return 'Was auf diesem $maker-Telefon zu ändern ist';
  }

  @override
  String batteryIntro(String maker) {
    return 'Um Akku zu sparen, schließen manche Telefone Apps im Hintergrund, und Linksy verpasst dann Dateien und Benachrichtigungen. Auf diesem $maker-Telefon:';
  }

  @override
  String get batteryAutostart => 'App-Info › Autostart: an.';

  @override
  String get batteryXiaomiSaver =>
      'App-Info › Energiesparmodus: Keine Einschränkungen.';

  @override
  String get batteryLockRecents =>
      'Halte Linksy in den letzten Apps gedrückt und tippe auf das Schloss, damit es beim Leeren weiterläuft.';

  @override
  String get batterySamsungUnrestricted =>
      'App-Info › Akku: Nicht eingeschränkt.';

  @override
  String get batterySamsungSleeping =>
      'Einstellungen › Akku › Nutzungsbeschränkungen im Hintergrund: nimm Linksy aus den Apps im Standby und im Tiefschlaf.';

  @override
  String get batteryOppoBackground =>
      'App-Info › Akkunutzung: Aktivität im Hintergrund, im Vordergrund und automatischen Start erlauben.';

  @override
  String get batteryVivoBackground =>
      'Einstellungen › Akku › Energieverbrauch im Hintergrund: Linksy erlauben.';

  @override
  String get batteryHuaweiLaunch =>
      'Einstellungen › Akku › App-Start › Linksy: manuell verwalten, mit Automatischer Start, Sekundärer Start und Im Hintergrund ausführen an.';

  @override
  String get batteryUnrestricted =>
      'App-Info › Akkunutzung der App: Nicht eingeschränkt.';

  @override
  String get batteryKeepRunning =>
      'In Linksy: Einstellungen › Verbindung › Im Hintergrund weiterlaufen.';

  @override
  String get batteryNames =>
      'Die Namen unterscheiden sich je nach Android-Version etwas.';

  @override
  String get updatePlayProtect =>
      'Linksy kann deine Benachrichtigungen auf deinen Computern zeigen, deshalb kann Play Protect die Installation stoppen. Dann:';

  @override
  String get updateProtectStep1 => 'Play Store › dein Bild › Play Protect › ⚙.';

  @override
  String get updateProtectStep2 => 'Schalte Apps mit Play Protect scannen aus.';

  @override
  String get updateProtectStep3 =>
      'Tippe noch einmal auf Jetzt aktualisieren und schalte das Scannen danach wieder ein.';

  @override
  String get news032NotificationsTitle =>
      'Deine Benachrichtigungen auf dem Computer';

  @override
  String get news032NotificationsBody =>
      'Nachrichten und andere Benachrichtigungen erscheinen auf deinen gekoppelten Computern, mit Antworten. Einschalten unter Einstellungen › Mit deinen Computern. Graut Android den Schalter aus: App-Info › ⋮ › Eingeschränkte Einstellungen zulassen.';

  @override
  String get news032BatteryTitle => 'Linksy am Laufen halten';

  @override
  String get news032BatteryBody =>
      'Einstellungen › Verbindung › Linksy am Laufen halten zeigt, was du je nach Marke deines Telefons ändern musst, damit Linksy im Hintergrund weiterläuft.';

  @override
  String get settingsReduceMotion => 'Bewegung reduzieren';

  @override
  String get settingsReduceMotionCaption =>
      'Bildschirme blenden über, statt zu gleiten, und Tasten werden blasser, statt kleiner zu werden.';

  @override
  String get deviceDeck => 'Deck';

  @override
  String deviceDeckCaption(String name) {
    return 'Deine eigenen Tasten für $name';
  }

  @override
  String get deckEdit => 'Bearbeiten';

  @override
  String get deckDone => 'Fertig';

  @override
  String deckAsking(String name) {
    return '$name wird gefragt, was das Deck darf…';
  }

  @override
  String deckAway(String name) {
    return '$name ist nicht verbunden. Das Deck geht, sobald es verbunden ist.';
  }

  @override
  String deckNothingOffered(String name) {
    return '$name erlaubt dem Deck noch nichts. Schalte die Aktionen in Linksy auf dem Computer ein.';
  }

  @override
  String get deckEmptyPage =>
      'Hier ist noch nichts. Tippe auf Bearbeiten, dann auf Hinzufügen.';

  @override
  String get deckAdd => 'Hinzufügen';

  @override
  String get deckAddTitle => 'Zum Deck hinzufügen';

  @override
  String get deckUnavailable => 'Nicht verfügbar';

  @override
  String get deckGroupMedia => 'Medien';

  @override
  String get deckGroupSound => 'Ton';

  @override
  String get deckGroupSystem => 'System';

  @override
  String get deckGroupCommands => 'Befehle';

  @override
  String get deckKindButton => 'Taste';

  @override
  String get deckKindToggle => 'Ein oder aus';

  @override
  String get deckKindSlider => 'Schieberegler';

  @override
  String get deckSize => 'Größe';

  @override
  String get deckSizeSmall => 'Klein';

  @override
  String get deckSizeWide => 'Breit';

  @override
  String get deckSizeTall => 'Hoch';

  @override
  String get deckSizeBig => 'Groß';

  @override
  String get deckSizeRow => 'Ganze Zeile';

  @override
  String get deckColor => 'Farbe';

  @override
  String get deckIcon => 'Symbol';

  @override
  String get deckRemove => 'Vom Deck entfernen';

  @override
  String get deckNewPage => 'Neue Seite';

  @override
  String get deckRemovePage => 'Diese Seite entfernen';

  @override
  String get deckMoveHint =>
      'Halte eine Taste gedrückt und ziehe sie, um sie zu verschieben.';

  @override
  String get settingsGallery => 'Fotos auf deinen Computern';

  @override
  String get settingsGalleryCaption =>
      'Deine Computer können die Fotos und Videos dieses Telefons durchsehen und die gewählten speichern.';

  @override
  String get settingsGalleryDenied =>
      'Erlaube Linksy in den Android-Einstellungen, deine Fotos zu sehen.';

  @override
  String get deckGroupNetwork => 'Netzwerk';

  @override
  String get deckGroupPower => 'Energie';

  @override
  String get deckThemeTitle => 'Design';

  @override
  String deckThemeAsMade(String name) {
    return 'Wie auf $name';
  }

  @override
  String get deckThemesShared => 'Auch auf dem Computer';

  @override
  String get deckThemesPhone => 'Nur auf diesem Telefon';

  @override
  String get deckThemeStock => 'Standard';

  @override
  String get deckThemeDots => 'Punktmatrix';

  @override
  String get deckThemeEink => 'E-Ink';

  @override
  String get deckThemeTerm => 'Terminal';

  @override
  String get deckThemePixel => 'Pixel';

  @override
  String get deckThemeSignal => 'Signal';

  @override
  String get deckThemeGlass => 'Glas';

  @override
  String get deckThemeMidnight => 'Mitternacht';

  @override
  String deckNotAvailable(String name) {
    return 'Auf $name nicht verfügbar';
  }

  @override
  String get deckAwayShort => 'Nicht verbunden';

  @override
  String deckAwayNote(String name) {
    return '$name ist nicht verbunden. Die Kacheln gehen, sobald es verbunden ist.';
  }

  @override
  String get deckNothingPlaying => 'Es läuft nichts';

  @override
  String get deckPickPlayer => 'Welchen Player steuern';

  @override
  String get deckDisplay => 'Anzeige';

  @override
  String get deckFullScreen => 'Vollbild';

  @override
  String get deckFullScreenCaption =>
      'Blendet Status- und Navigationsleiste aus. Vom Rand wischen, um sie zu sehen.';

  @override
  String get deckRealCovers => 'Cover unverändert';

  @override
  String get deckRealCoversCaption => 'Nicht in Punkten oder Pixeln des Themes';

  @override
  String deckNoLayouts(String name) {
    return '$name hat noch kein Deck für dieses Telefon. Erstelle eins in Linksy auf dem Computer.';
  }

  @override
  String get news034TurnOnBody =>
      'Schalte sie über die Karte auf dem Startbildschirm ein, und Posteingang und Galerie des Computers füllen sich von selbst.';

  @override
  String get news034SaveTitle => 'Wähle, wohin Dateien gehen';

  @override
  String get news034SaveBody =>
      'Einstellungen › Dateien › Speicherort: Tippe darauf, um einen anderen Ordner für Empfangenes zu wählen.';

  @override
  String get news033DeckTitle => 'Deck: Tasten für deinen Computer';

  @override
  String get news033DeckBody =>
      'Wiedergabe, Lautstärke, Stumm, WLAN und deine eigenen Befehle, in Linksy auf dem Computer angeordnet und von hier aus bedient: seine Seite › Steuern › Deck. Halte den Namen des Decks gedrückt, um sein Aussehen zu ändern. Braucht das neueste Linksy auf dem Computer.';

  @override
  String get news033PhotosTitle => 'Deine Fotos auf deinem Computer';

  @override
  String get news033PhotosBody =>
      'Die Galerie eines Computers blättert Seite für Seite durch die Fotos und Videos dieses Telefons und speichert die, die du auswählst. Einstellungen › Dateien › Fotos auf deinen Computern.';

  @override
  String get news033MessagesTitle => 'Frühere Nachrichten';

  @override
  String get news033MessagesBody =>
      'Auf dem Computer zeigt ein Gespräch auch seine früheren Nachrichten, und Antworten geht noch einen Tag, nachdem die Benachrichtigung verschwunden ist.';

  @override
  String get onboardingMessages => 'Nachrichten auf deinen Computern';

  @override
  String get onboardingMessagesDetail =>
      'Lies und beantworte deine Nachrichten und Benachrichtigungen im Posteingang des Computers.';

  @override
  String get onboardingGalleryDetail =>
      'Sieh dir die Fotos und Videos dieses Telefons in der Galerie des Computers an. Wenn Android fragt, wähle Alle zulassen.';

  @override
  String get homeTurnOnTitle =>
      'Deine Nachrichten und Fotos auf deinen Computern';

  @override
  String get homeTurnOnBody =>
      'Sieh sie im Posteingang und in der Galerie des Computers.';

  @override
  String get homeTurnOnMessages => 'Nachrichten einschalten';

  @override
  String get homeTurnOnPhotos => 'Fotos einschalten';

  @override
  String turnOnAskMessages(String name) {
    return '$name möchte die Nachrichten dieses Telefons anzeigen';
  }

  @override
  String turnOnAskPhotos(String name) {
    return '$name möchte die Fotos dieses Telefons anzeigen';
  }

  @override
  String get turnOnNow => 'Einschalten';

  @override
  String get settingsDemoAsk => 'Ein Computer fragt danach, in 4 Sekunden';

  @override
  String get noticeAccessStepSwitch =>
      'Öffne den Benachrichtigungszugriff und schalte Linksy ein. Ist der Schalter ausgegraut, tippe trotzdem darauf: Android lehnt ab, und erst das macht den nächsten Schritt möglich.';

  @override
  String get noticeAccessOpen => 'Benachrichtigungszugriff öffnen';

  @override
  String get phoneClipboard => 'Zwischenablage senden';

  @override
  String phoneClipboardCaption(String name) {
    return 'Was hier kopiert ist, geht an $name';
  }

  @override
  String get phoneNoteHint => 'Eine Notiz oder ein Link';

  @override
  String get phoneSend => 'Senden';

  @override
  String phoneFind(String name) {
    return '$name finden';
  }

  @override
  String get phoneFindCaption => 'Klingelt laut, auch wenn es stumm ist';

  @override
  String get phoneWhere => 'Wo ist es?';

  @override
  String get phoneWhereCaption => 'Fragt einmal nach dem Standort';

  @override
  String phoneWhereRefused(String name, String reason) {
    return '$name hat den Standort nicht genannt: $reason';
  }

  @override
  String get phoneFromThis => 'Von diesem Telefon';

  @override
  String get phonePhotos => 'Fotos und Videos';

  @override
  String get phonePhotosCaption => 'Nach Tag oder Album';

  @override
  String get phoneAllowPhotos => 'Fotos erlauben';

  @override
  String get phoneAllowPhotosCaption =>
      'Linksy braucht das, um deine Fotos hier zu zeigen. Nichts geht weg, bis du es sendest.';

  @override
  String get phoneFiles => 'Dateien und Ordner';

  @override
  String get phoneFilesCaption => 'Mit der Dateiauswahl von Android';

  @override
  String get phoneChooseFiles => 'Dateien auswählen';

  @override
  String get phoneChooseFolder => 'Ordner auswählen';

  @override
  String get phoneApps => 'Apps';

  @override
  String get phoneAppsCaption => 'Eine App senden oder aktualisieren';

  @override
  String get phoneAppsNote =>
      'Daten und Anmeldungen einer App ziehen nicht mit um. Apps, die eine Lizenz oder ein Konto prüfen, starten vielleicht nicht.';

  @override
  String get phoneAppsSearch => 'Apps suchen';

  @override
  String get phoneSortName => 'Name';

  @override
  String get phoneSortSize => 'Größe';

  @override
  String phoneAppNotThere(String name) {
    return 'Nicht auf $name';
  }

  @override
  String get phoneAppUpdate => 'Aktualisieren (dort älter)';

  @override
  String get phoneAppSame => 'Schon dort';

  @override
  String get phoneAppNewer => 'Dort neuer';

  @override
  String phoneAppOtherSigner(String name) {
    return '$name hat sie von einem anderen Entwickler. Android kann sie nicht aktualisieren, nur ersetzen, und das löscht ihre Daten.';
  }

  @override
  String get phoneAllAlbums => 'Alle';

  @override
  String get phoneNoPhotos => 'Noch keine Fotos hier';

  @override
  String get phoneNoApps => 'Keine Apps zum Senden';

  @override
  String phoneSelected(int count, String size) {
    return '$count ausgewählt · $size';
  }

  @override
  String phoneSendTo(String name) {
    return 'An $name senden';
  }

  @override
  String get phoneClear => 'Leeren';

  @override
  String get routeDirect => 'Direktverbindung';

  @override
  String get routeLan => 'Gleiches Netzwerk';

  @override
  String get routeAway => 'Über das Internet · nutzt mobile Daten';

  @override
  String get routeUsb => 'Kabel';

  @override
  String routeAbout(String time) {
    return 'etwa $time';
  }

  @override
  String get routeSettingUp => 'Direktverbindung wird eingerichtet…';

  @override
  String routeNotDirect(String reason) {
    return 'Keine Direktverbindung: $reason. Wird über das Netzwerk gesendet.';
  }

  @override
  String warnNoRoom(String name, String free, String size) {
    return '$name hat $free frei und das sind $size';
  }

  @override
  String warnWillAsk(String name) {
    return '$name fragt, bevor es das annimmt';
  }

  @override
  String warnCantInstall(String name) {
    return '$name muss zuerst Installationen von Linksy erlauben';
  }

  @override
  String warnCantInstallHow(String name) {
    return 'Auf $name: Android-Einstellungen › Apps › Spezieller App-Zugriff › Unbekannte Apps installieren › Linksy.';
  }

  @override
  String get mobileDataTitle => 'Über das Internet senden?';

  @override
  String mobileDataAsk(String size) {
    return 'Das geht über das Internet und verbraucht etwa $size mobile Daten.';
  }

  @override
  String phoneInstallAsk(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Apps von $name installieren?',
      one: 'Eine App von $name installieren?',
    );
    return '$_temp0';
  }

  @override
  String get phoneAppNew => 'Neu';

  @override
  String get phoneAppUpdateShort => 'Update';

  @override
  String get phoneInstall => 'Installieren';

  @override
  String get phoneInstallAllowBody =>
      'Android braucht einmal dein OK, bevor Linksy Apps installieren kann. Schalte „Aus dieser Quelle zulassen“ ein und komm zurück.';

  @override
  String get phoneInstallAllow => 'Installationen erlauben';

  @override
  String phoneInstalled(String app) {
    return '$app ist installiert';
  }

  @override
  String phoneInstallCancelled(String app) {
    return '$app wurde nicht installiert';
  }

  @override
  String phoneInstallMismatch(String app, String name) {
    return '$app ist nicht das, was $name angegeben hat, und wurde deshalb nicht installiert.';
  }

  @override
  String phoneInstallOtherSigner(String app) {
    return '$app auf diesem Telefon stammt von einem anderen Entwickler. Android kann sie nicht aktualisieren.';
  }

  @override
  String phoneInstallFailed(String app, String reason) {
    return '$app wurde nicht installiert: $reason';
  }

  @override
  String get news035PhonesTitle => 'Zwei Telefone, kein Computer';

  @override
  String get news035PhonesBody =>
      'Öffne ein gekoppeltes Telefon: Sende, was du kopiert hast, eine Notiz oder einen Link, lass es klingeln oder wähle Fotos und Dateien nach Tag.';

  @override
  String get news035AppsTitle => 'Apps an ein anderes Telefon senden';

  @override
  String get news035AppsBody =>
      'Linksy zeigt, was dort fehlt oder älter ist, und Android fragt vor der Installation. Daten und Anmeldungen bleiben zurück.';

  @override
  String get phoneNote => 'Notiz';

  @override
  String get phoneWhereShort => 'Wo';

  @override
  String get phoneShelfPhotos => 'Fotos';

  @override
  String get phoneSeeAll => 'Alle ansehen';

  @override
  String get phoneSelectDay => 'Tag auswählen';

  @override
  String get phoneHistory => 'Verlauf';

  @override
  String get deviceSnap => 'Foto';

  @override
  String snapSent(String name) {
    return 'Foto an $name gesendet';
  }

  @override
  String copySent(String name) {
    return 'Nach $name kopiert';
  }

  @override
  String get usbConnectCable => 'Per USB-Kabel verbinden';

  @override
  String get settingsSendCopied => 'Kopiertes senden';

  @override
  String get settingsSendCopiedCaption =>
      'Jedes Mal, wenn du zu Linksy zurückkehrst, geht Kopiertes an verbundene Computer. Auch Passwörter, lass es also im Zweifel aus.';

  @override
  String get doctorTitle => 'Warum sehe ich meinen Computer nicht?';

  @override
  String get doctorCaption => 'Findet, was im Weg ist, und was zu tun ist';

  @override
  String get doctorAllGood => 'Auf diesem Telefon ist alles in Ordnung';

  @override
  String get doctorAllGoodDetail =>
      'Wenn dein Computer weiter nicht erscheint, blockiert vielleicht seine Firewall, oder Linksy läuft dort nicht.';

  @override
  String get doctorWifi => 'WLAN ist nicht verbunden';

  @override
  String get doctorWifiDetail =>
      'Verbinde dich mit demselben Netzwerk wie dein Computer.';

  @override
  String get doctorHeard => 'In diesem Netzwerk ist kein Gerät zu hören';

  @override
  String get doctorHeardDetail =>
      'Dein Computer schläft vielleicht oder ist in einem anderen Netzwerk, oder dieser Router trennt Geräte, wie Gastnetze es tun.';

  @override
  String get doctorVpn => 'Ein VPN ist aktiv';

  @override
  String get doctorVpnDetail =>
      'Es kann deinen Computer vor diesem Telefon verbergen. Schalte es aus oder erlaube darin lokale Netzwerke.';

  @override
  String get doctorBattery => 'Akkusparen kann Linksy stoppen';

  @override
  String doctorBatteryDetail(String maker) {
    return '$maker-Telefone können Linksy im Hintergrund schließen.';
  }

  @override
  String get doctorPowerSave => 'Energiesparmodus ist an';

  @override
  String get doctorPowerSaveDetail =>
      'Er begrenzt, was Linksy bei ausgeschaltetem Bildschirm tun kann.';

  @override
  String get doctorDataSaver => 'Datensparmodus ist an';

  @override
  String get doctorDataSaverDetail =>
      'Er kann verhindern, dass Linksy sich im Hintergrund verbindet.';

  @override
  String get doctorOpenSettings => 'Einstellungen öffnen';

  @override
  String get doctorShowHow => 'Zeig mir wie';

  @override
  String get doctorCheckAgain => 'Erneut prüfen';

  @override
  String get news035DeckTitle => 'Dein Deck auf dem Handy bauen';

  @override
  String get news035DeckBody =>
      'Tippe auf den Stift oder halte eine Kachel. Zieh sie an jede Stelle und auf jede Größe, die anderen machen Platz. Dreh das Handy für das Querformat-Deck.';

  @override
  String get news035SnapTitle => 'Foto an den Computer';

  @override
  String get news035SnapBody =>
      'Mache ein Foto von der Seite eines Computers oder per Schnelleinstellung, und es landet direkt dort, bereit zum Einfügen.';

  @override
  String get news035CopyTitle => 'An Computer kopieren';

  @override
  String get news035CopyBody =>
      'Wähle Text in einer App aus und tippe auf An Computer kopieren. Und wenn keine Verbindung klappt, sagt Einstellungen › Verbindung warum.';

  @override
  String get controlsNoDnd =>
      'Erlaube Linksy zuerst auf dem Telefon den Zugriff auf „Bitte nicht stören“';

  @override
  String get controlsNoFlashlight =>
      'Die Taschenlampe kann gerade nicht benutzt werden';

  @override
  String get controlsDenied => 'Android hat das nicht erlaubt';

  @override
  String get snapNoCamera => 'Linksy braucht die Kamera-Berechtigung';

  @override
  String snapAsked(String name) {
    return 'Mach ein Foto für $name';
  }

  @override
  String get settingsComputerNotifications =>
      'Benachrichtigungen deines Computers';

  @override
  String get settingsComputerNotificationsCaption =>
      'Zeigt sie hier, sobald du es auch am Computer für dieses Telefon einschaltest';

  @override
  String get settingsDndAccess => 'Zugriff auf „Bitte nicht stören“';

  @override
  String get settingsDndAccessCaption =>
      'Lässt deine Computer „Bitte nicht stören“ hier ändern';

  @override
  String get settingsDndAccessOn => 'Erlaubt: deine Computer können es ändern';

  @override
  String get settingsTurnTaps => 'Tipps im Querformat drehen';

  @override
  String get settingsTurnTapsCaption =>
      'Nur wenn Tipps vom Computer bei quer gehaltenem Telefon falsch landen';

  @override
  String get deckDiscardTitle => 'Änderungen verwerfen?';

  @override
  String get deckDiscard => 'Verwerfen';

  @override
  String get deckKeepEditing => 'Weiter bearbeiten';

  @override
  String get deckUndo => 'Rückgängig';

  @override
  String get deckRedo => 'Wiederholen';

  @override
  String get deckCopy => 'Kopieren';

  @override
  String get deckPage => 'Seite';

  @override
  String deckPageN(int n) {
    return 'Seite $n';
  }

  @override
  String deckPages(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get deckRemoveShort => 'Entfernen';

  @override
  String get deckNoRoom => 'Hier ist kein Platz dafür';

  @override
  String get deckFillForMe => 'Für mich füllen';

  @override
  String get deckTryIt => 'Ausprobieren';

  @override
  String get deckLayouts => 'Layouts';

  @override
  String get deckPortrait => 'Hochformat';

  @override
  String get deckLandscape => 'Querformat';

  @override
  String get deckAddSearch => 'Suchen, was er kann';

  @override
  String get deckLive => 'Live auf dem Deck';

  @override
  String get deckSuggested => 'Vorschläge';

  @override
  String get deckMusic => 'Musik';

  @override
  String get deckClock => 'Uhr';

  @override
  String get deckName => 'Name';

  @override
  String get deckDoes => 'Was sie tut';

  @override
  String get deckAccent => 'Akzent';

  @override
  String get deckRename => 'Umbenennen';

  @override
  String get deckNewLayout => 'Neu beginnen mit';

  @override
  String get deckBlank => 'Leer';

  @override
  String get deckPresenter => 'Präsentation';

  @override
  String get deckLandscapeFromPortrait => 'Querformat aus Hochformat machen';

  @override
  String get deckMade => 'Fertig, sieh im Querformat nach';

  @override
  String deckUseComputers(String name) {
    return 'Das von $name verwenden';
  }

  @override
  String deckSavedHere(String name) {
    return 'Vorerst auf diesem Telefon gespeichert. $name behält sein eigenes, bis es dieses übernehmen kann.';
  }

  @override
  String get deckWidth => 'Breite';

  @override
  String get deckHeight => 'Höhe';

  @override
  String get deckStartFromPortrait => 'Mit deinem Hochformat-Deck beginnen';

  @override
  String get deckStartEmpty => 'Leer beginnen';
}
