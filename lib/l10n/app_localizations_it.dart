// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Benvenuto in Linksy';

  @override
  String get onboardingChooseLanguage => 'Scegli la lingua';

  @override
  String get onboardingLanguageHint =>
      'Puoi cambiarla più tardi nelle Impostazioni.';

  @override
  String get onboardingContinue => 'Continua';

  @override
  String get onboardingSetUpTitle => 'Configura Linksy';

  @override
  String get onboardingSetUpSubtitle =>
      'Scegli cosa può fare Linksy. Nulla lascia questo telefono finché non lo decidi tu.';

  @override
  String get onboardingNotifications => 'Notifiche';

  @override
  String get onboardingNotificationsDetail =>
      'File in arrivo, e quando un computer usa lo schermo, la fotocamera o il microfono, con un pulsante per interrompere.';

  @override
  String get onboardingCamera => 'Fotocamera';

  @override
  String get onboardingCameraDetail =>
      'Scansiona i codici QR di associazione e permette a un computer di usarla come webcam, se lo consenti.';

  @override
  String get onboardingAway => 'Fuori casa';

  @override
  String get onboardingAwayDetail =>
      'Raggiungi i tuoi computer via internet quando non sei sulla stessa Wi-Fi. Crittografia end-to-end.';

  @override
  String get onboardingBackground => 'Resta attivo in background';

  @override
  String get onboardingBackgroundDetail =>
      'File e chiamate continuano a funzionare quando Linksy è chiuso. Mostra una notifica discreta.';

  @override
  String get onboardingFolder => 'Condividi una cartella con i computer';

  @override
  String get onboardingFolderDetail =>
      'I tuoi computer possono aprire una cartella a tua scelta nella loro app File.';

  @override
  String get onboardingPhotos => 'Cartella per il backup delle foto';

  @override
  String get onboardingPhotosDetail =>
      'Scegli la cartella della fotocamera per fare il backup delle nuove foto su un computer. Si attiva per ogni computer.';

  @override
  String get onboardingLocate =>
      'Permetti ai computer di localizzare questo telefono';

  @override
  String get onboardingLocateDetail =>
      'Un computer può chiedere dove si trova questo telefono, una volta. Non viene salvato nulla.';

  @override
  String get onboardingAllow => 'Consenti';

  @override
  String get onboardingAllowed => 'Consentito';

  @override
  String get onboardingChooseFolder => 'Scegli';

  @override
  String onboardingFolderChosen(String folder) {
    return '“$folder”';
  }

  @override
  String get onboardingAnytime =>
      'Puoi attivare o disattivare ognuna di queste opzioni quando vuoi nelle Impostazioni.';

  @override
  String get onboardingStart => 'Inizia a usare Linksy';

  @override
  String get onboardingBack => 'Indietro';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get languageDone => 'Fatto';

  @override
  String get ctlClipboardFileTooBig =>
      'Negli appunti entra solo un file fino a 10 MB.';

  @override
  String get ctlClipboardCopyFailed => 'Impossibile copiarlo negli appunti';

  @override
  String get ctlLocateOff =>
      'La localizzazione è disattivata in Linksy su questo telefono';

  @override
  String get ctlYourComputer => 'il tuo computer';

  @override
  String get ctlAnd => 'e';

  @override
  String ctlKeepingLocked(String names) {
    return '$names restano bloccati quando ti allontani';
  }

  @override
  String get ctlStayingConnected => 'Connesso ai tuoi computer';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name vuole inviarti $count file',
      one: '$name vuole inviarti un file',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'Gli appunti sono vuoti.';

  @override
  String get ctlClipboardTooMuch =>
      'Gli appunti contengono troppo testo da inviare.';

  @override
  String get ctlPing => 'Ping';

  @override
  String ctlPingFrom(String name) {
    return 'Da $name';
  }

  @override
  String get ctlTextTooMuch => 'È troppo testo da inviare.';

  @override
  String get ctlDeclined => 'Rifiutato';

  @override
  String get ctlScreenPermission =>
      'Per condividere lo schermo serve il permesso di Android per acquisirlo.';

  @override
  String get ctlCameraPermission =>
      'Linksy ha bisogno del permesso della fotocamera per funzionare come webcam.';

  @override
  String get ctlMicrophonePermission =>
      'Linksy ha bisogno del permesso del microfono per fare da microfono.';

  @override
  String get ctlTerminalTitle => 'Terminale';

  @override
  String get errorThatDevice => 'Quel dispositivo';

  @override
  String get errorOtherDevice => 'L’altro dispositivo';

  @override
  String get errorComputerOnCable => 'Il computer collegato via cavo';

  @override
  String errorDeviceAt(String address) {
    return 'Il dispositivo all’indirizzo $address';
  }

  @override
  String errorUnreachable(String name) {
    return '$name non è raggiungibile. Controlla che sia acceso e su questa rete.';
  }

  @override
  String errorDeclined(String name) {
    return '$name ha rifiutato.';
  }

  @override
  String errorTimeout(String name) {
    return '$name non ha risposto in tempo.';
  }

  @override
  String errorNotPaired(String name) {
    return '$name non è più associato. Associalo di nuovo per condividere.';
  }

  @override
  String errorUnsupported(String name) {
    return '$name non può ancora farlo.';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name lo consente solo sulla stessa rete. Il proprietario può consentire tutto da fuori casa per questo telefono.';
  }

  @override
  String get errorInvalid => 'Non ha funzionato.';

  @override
  String get errorSomethingWrong => 'Qualcosa è andato storto.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Qualcosa è andato storto: $detail';
  }

  @override
  String get terminalRefusedComputer => 'Il computer';

  @override
  String get terminalRefusedCode => 'Codice errato.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Codice errato, ti restano $count tentativi.',
      one: 'Codice errato, ti resta 1 tentativo.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Troppi codici errati. Sblocca il terminale su $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'Su $name, apri la pagina di questo telefono e consenti lì il terminale.';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name consente un terminale solo sulla stessa rete, a meno che lì non sia attivo “Consenti tutto da fuori casa”.';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name non può aprire un terminale.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return 'Su $name sono già aperti 8 terminali per questo telefono. Chiudine uno prima.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name non l’ha consentito.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$kind $os';
  }

  @override
  String get modelKindDesktop => 'Desktop';

  @override
  String get modelKindLaptop => 'Portatile';

  @override
  String get modelKindPhone => 'Telefono';

  @override
  String get modelKindTablet => 'Tablet';

  @override
  String get modelOsUnknown => 'sconosciuto';

  @override
  String get deviceNothingOfKind => 'Ancora niente di questo tipo.';

  @override
  String deviceBattery(int level) {
    return '$level%';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level%, in carica';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Raggiungibile da fuori casa fino a $day';
  }

  @override
  String get deviceLocksWhenLeave =>
      'Si blocca quando ti allontani con questo telefono';

  @override
  String get deviceBack => 'Indietro';

  @override
  String get deviceMore => 'Altro';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Cambia immagine';

  @override
  String get deviceAddPicture => 'Aggiungi un’immagine';

  @override
  String get deviceRemovePicture => 'Rimuovi immagine';

  @override
  String get deviceForgetThis => 'Dimentica questo dispositivo';

  @override
  String deviceForgetTitle(String name) {
    return 'Dimenticare $name?';
  }

  @override
  String get deviceForgetBody =>
      'Dovrai associarlo di nuovo per condividere. Anche la sua attività su questo telefono viene cancellata.';

  @override
  String get deviceForget => 'Dimentica';

  @override
  String get deviceCancel => 'Annulla';

  @override
  String get deviceSendFiles => 'Invia file';

  @override
  String get deviceSendFilesCaption => 'Foto, documenti, qualsiasi cosa';

  @override
  String get deviceClipboard => 'Appunti';

  @override
  String get deviceClipboardCaption => 'Invia ciò che hai copiato';

  @override
  String get devicePing => 'Ping';

  @override
  String get devicePingCaption => 'Fallo suonare';

  @override
  String get deviceRemote => 'Telecomando';

  @override
  String get deviceRemoteCaption => 'Touchpad e slide';

  @override
  String get deviceRinging => 'Sta squillando…';

  @override
  String get deviceFindIt => 'Trovalo';

  @override
  String get deviceTapToStop => 'Tocca per fermare';

  @override
  String get deviceFindItCaption => 'Fallo squillare forte';

  @override
  String get devicePrevious => 'Precedente';

  @override
  String get devicePause => 'Pausa';

  @override
  String get devicePlay => 'Riproduci';

  @override
  String get deviceNext => 'Successivo';

  @override
  String deviceAllowOn(String name) {
    return 'Consentilo su $name…';
  }

  @override
  String get deviceSeeScreen => 'Vedi il suo schermo';

  @override
  String get deviceSeeScreenCaption => 'Guardalo qui o controllalo al tocco';

  @override
  String get deviceWatch => 'Guarda';

  @override
  String get deviceControl => 'Controlla';

  @override
  String get deviceTerminal => 'Terminale';

  @override
  String deviceTerminalShell(String name) {
    return 'Una shell su $name, protetta dal suo codice';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terminali aperti',
      one: '1 terminale aperto',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'Tutto';

  @override
  String get deviceFilterFiles => 'File';

  @override
  String get deviceFilterClipboard => 'Appunti';

  @override
  String get deviceFilterLinks => 'Link';

  @override
  String get deviceFilterShowAll => 'Mostra tutto';

  @override
  String get deviceFilterShowFiles => 'Mostra file';

  @override
  String get deviceFilterShowClipboard => 'Mostra appunti';

  @override
  String get deviceFilterShowLinks => 'Mostra link';

  @override
  String get deviceActivity => 'Attività';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Pronto quando $name lo chiede';
  }

  @override
  String get deviceWebcam => 'Webcam';

  @override
  String get deviceInUseNow => 'In uso ora';

  @override
  String get deviceControls => 'Controlli';

  @override
  String get deviceMicrophone => 'Microfono';

  @override
  String get deviceStop => 'Ferma';

  @override
  String get deviceSecondDisplay => 'Secondo schermo';

  @override
  String get deviceShowingNow => 'In uso ora';

  @override
  String deviceReadySize(int width, int height) {
    return 'Pronto · $width × $height';
  }

  @override
  String get devicePhoneAs => 'Questo telefono come';

  @override
  String deviceStartedOn(String name) {
    return 'Si avvia da $name';
  }

  @override
  String get deviceFasterOverUsb => 'Più veloce e stabile con un cavo USB.';

  @override
  String get deviceBackUpPhotos => 'Backup delle foto';

  @override
  String devicePhotosGoTo(String name) {
    return 'Le nuove foto vanno nella cartella Immagini di $name';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name non accetta foto. Attiva lì “Importa foto dai telefoni”.';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'Da $folder';
  }

  @override
  String get devicePhotosFromCamera => 'Dalla cartella della fotocamera';

  @override
  String devicePhotosLast(String time) {
    return 'ultimo $time';
  }

  @override
  String get deviceGetClipboard => 'Ricevi i suoi appunti';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'Il testo copiato su $name arriva qui finché sei connesso';
  }

  @override
  String get deviceAwayAll => 'Consenti tutto da fuori casa';

  @override
  String get deviceAwayAllOn =>
      'Anche da fuori casa: questo schermo, webcam, microfono e file';

  @override
  String get deviceAwayAllOff =>
      'Da fuori casa: solo appunti, link, file e squillo';

  @override
  String get deviceNothingShared => 'Ancora niente di condiviso';

  @override
  String deviceNothingSharedBody(String name) {
    return 'File, testo degli appunti e ping tra questo telefono e $name compaiono qui.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '“$text”';
  }

  @override
  String get activityClipboardText => 'Testo degli appunti';

  @override
  String get activityPing => 'Ping';

  @override
  String get activityYourScreen => 'Il tuo schermo';

  @override
  String get activityYourCamera => 'La tua fotocamera';

  @override
  String get activitySecondDisplay => 'Secondo schermo';

  @override
  String get activityLink => 'Link';

  @override
  String get activityRangThisPhone => 'Ha fatto squillare questo telefono';

  @override
  String get activityRangIt => 'Fatto squillare';

  @override
  String get activityTouchpadKeyboard => 'Touchpad e tastiera';

  @override
  String get activityItsScreen => 'Il suo schermo';

  @override
  String get activityYourMicrophone => 'Il tuo microfono';

  @override
  String get activityWhereThisPhone => 'Dov’è questo telefono';

  @override
  String get activityWatchingNow => 'In visione ora';

  @override
  String get activityWatched => 'Visto';

  @override
  String get activityInUseWebcam => 'In uso come webcam';

  @override
  String get activityUsedWebcam => 'Usata come webcam';

  @override
  String get activityBeingControlled => 'Controllato ora';

  @override
  String get activityWatchedControlled => 'Visto e controllato';

  @override
  String get activityWatchedFromPhone => 'Visto da questo telefono';

  @override
  String get activityInUseNow => 'In uso ora';

  @override
  String get activityWasTouchpad => 'Questo telefono è stato il suo touchpad';

  @override
  String get activityWasSecondDisplay =>
      'Questo telefono è stato il suo secondo schermo';

  @override
  String get activityLinkReceived => 'Link ricevuto';

  @override
  String get activityOpenedOnComputer => 'Aperto sul computer';

  @override
  String get activityInUseMicrophone => 'In uso come microfono';

  @override
  String get activityUsedMicrophone => 'Usato come microfono';

  @override
  String get activityNotTold => 'Non comunicato';

  @override
  String get activityToldWhere => 'Gli è stato detto dov’è questo telefono';

  @override
  String get activityAskedToFind => 'Ha chiesto di trovare questo telefono';

  @override
  String get activityToFindIt => 'Per trovarlo';

  @override
  String get activityDeclined => 'Rifiutato';

  @override
  String get activityFailed => 'Non riuscito';

  @override
  String get activityInProgress => 'In corso';

  @override
  String get activityCopiedHere => 'Copiato qui';

  @override
  String get activityReceived => 'Ricevuto';

  @override
  String get activitySent => 'Inviato';

  @override
  String get activityStop => 'Ferma';

  @override
  String get activityCancel => 'Annulla';

  @override
  String get activityCopyAgain => 'Copia di nuovo';

  @override
  String get activityCopied => 'Copiato';

  @override
  String get activityCopyLink => 'Copia link';

  @override
  String get activityLinkCopied => 'Link copiato';

  @override
  String get activityNoAppForLink => 'Nessuna app qui apre quel link.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count file',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name non c’è più.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'Nessuna app su questo telefono apre $name.';
  }

  @override
  String get activityWaitingForYou => 'In attesa che tu accetti…';

  @override
  String get activityWaitingForDevice =>
      'In attesa che il dispositivo accetti…';

  @override
  String activityWaitingFor(String name) {
    return 'In attesa che $name accetti…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done di $total';
  }

  @override
  String get homeSettings => 'Impostazioni';

  @override
  String get homeYourDevices => 'I tuoi dispositivi';

  @override
  String get homeNearbyNotPaired => 'Nelle vicinanze, non associati';

  @override
  String get homeAddDevice => 'Aggiungi un dispositivo';

  @override
  String homeVisible(String name) {
    return '$name è visibile su questa Wi-Fi';
  }

  @override
  String get homeUpdateTitle => 'Aggiorna Linksy per continuare a connetterti';

  @override
  String get homeUpdateBody =>
      'I tuoi computer ora usano una versione di Linksy più recente di questa app.';

  @override
  String get homeGetUpdate => 'Scarica l’aggiornamento';

  @override
  String get homeSendFiles => 'Invia file';

  @override
  String get homePair => 'Associa';

  @override
  String get homeStepOpen => 'Apri Linksy sul computer';

  @override
  String get homeStepChoose => 'Scegli “Aggiungi dispositivo”';

  @override
  String get homeStepScan => 'Scansionalo con questo telefono';

  @override
  String get homeConnectTitle => 'Connetti il tuo\nprimo dispositivo';

  @override
  String get homeConnectSubtitle =>
      'Direttamente sulla tua Wi-Fi. Nessun account, nessun cloud.';

  @override
  String get homeScanQr => 'Scansiona codice QR';

  @override
  String get homePairByAddress => 'Associa tramite indirizzo';

  @override
  String get pairingAddDevice => 'Aggiungi un dispositivo';

  @override
  String get pairingAddDeviceHint =>
      'Sull’altro dispositivo, apri Linksy e scegli “Aggiungi dispositivo”.';

  @override
  String get pairingScanQr => 'Scansiona codice QR';

  @override
  String get pairingScanQrCaption => 'Il modo più veloce. Niente da digitare.';

  @override
  String get pairingByAddress => 'Associa tramite indirizzo';

  @override
  String get pairingByAddressCaption =>
      'Quando l’altro dispositivo non viene trovato.';

  @override
  String pairingWith(String name) {
    return 'Associazione con $name…';
  }

  @override
  String get pairingWithOtherDevice => 'Associazione con l’altro dispositivo…';

  @override
  String get pairingAddressHint =>
      'Si trova nelle Preferenze di Linksy sull’altro dispositivo.';

  @override
  String pairingPortHint(String port) {
    return 'Porta $port, a meno che non ne aggiungi un’altra.';
  }

  @override
  String get pairingPair => 'Associa';

  @override
  String pairingWantsToPair(String name) {
    return '$name vuole associarsi';
  }

  @override
  String pairingPairWith(String name) {
    return 'Associa con $name';
  }

  @override
  String get pairingCodeHint =>
      'Entrambi gli schermi dovrebbero mostrare questo codice.';

  @override
  String pairingCodeLabel(String code) {
    return 'Codice $code';
  }

  @override
  String get pairingCodesMatch => 'I codici coincidono';

  @override
  String get scanNeedsCamera =>
      'Linksy ha bisogno della fotocamera per scansionare il codice di associazione. Consentila, oppure associa tramite indirizzo.';

  @override
  String get scanCameraUnavailable => 'La fotocamera non è disponibile.';

  @override
  String get scanFlashlight => 'Torcia';

  @override
  String get scanTitle => 'Scansiona il codice';

  @override
  String get scanWrongCode =>
      'Non è un codice Linksy. Sul computer, apri Linksy → Associa con codice QR.';

  @override
  String get scanHint =>
      'Sul computer, apri Linksy e scegli “Aggiungi dispositivo”.';

  @override
  String get shareSheetPutOnClipboard => 'Metti negli appunti';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Invia $count file',
      one: 'Invia un file',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Apri su un computer';

  @override
  String get shareSheetSendToClipboard => 'Invia agli appunti';

  @override
  String get shareSheetNoClipboardFiles =>
      'Nessuno dei tuoi computer accetta ancora file negli appunti. Aggiorna Linksy lì.';

  @override
  String get shareSheetNoComputers =>
      'Prima associa un computer, poi condividi con esso da qualsiasi app.';

  @override
  String get shareSheetSendFileInstead => 'Invia invece il file';

  @override
  String get shareSheetClipboardInstead =>
      'Mettilo invece negli appunti del computer';

  @override
  String get shareSheetOpenLinkInstead => 'Apri invece il link';

  @override
  String get shareSheetSendAsTextInstead =>
      'Invia invece come testo agli appunti';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Lo metto negli appunti di $name';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Lo metto negli appunti del computer';

  @override
  String shareSheetOpened(String name) {
    return 'Aperto su $name';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Aperto sul computer';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'Inviato agli appunti di $name';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'Inviato agli appunti del computer';

  @override
  String shareSheetSentALink(String name) {
    return '$name ha inviato un link';
  }

  @override
  String get shareSheetOpen => 'Apri';

  @override
  String get shareSheetCopyLink => 'Copia link';

  @override
  String get shareSheetLinkCopied => 'Link copiato';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count file',
      one: 'un file',
    );
    return '$name ti sta inviando $_temp0';
  }

  @override
  String incomingTotal(String size) {
    return '$size in totale';
  }

  @override
  String incomingMore(int count) {
    return '+ altri $count';
  }

  @override
  String get incomingAccept => 'Accetta';

  @override
  String get appInvalidPairingLink => 'Quel link di associazione non è valido.';

  @override
  String appPairingFailed(String reason) {
    return 'Associazione non riuscita: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'Impossibile associarsi con $name: $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Associato con $name';
  }

  @override
  String appNotification(String name, String text) {
    return '$name: $text';
  }

  @override
  String appCopiedText(String name) {
    return 'Testo copiato da $name';
  }

  @override
  String appCopiedFile(String file, String name) {
    return '$file copiato da $name';
  }

  @override
  String get appCouldntStart => 'Impossibile avviare Linksy';

  @override
  String get commonDismiss => 'Ignora';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonDecline => 'Rifiuta';

  @override
  String get commonClose => 'Chiudi';

  @override
  String get commonNotNow => 'Non ora';

  @override
  String get commonConnected => 'Connesso';

  @override
  String get commonNearby => 'Nelle vicinanze';

  @override
  String get commonNotNearby => 'Non nelle vicinanze';

  @override
  String get commonUsbCable => 'Cavo USB';

  @override
  String get commonAwayFromHome => 'Fuori casa';

  @override
  String get commonSameWifi => 'Stessa Wi-Fi';

  @override
  String get commonConnectedByUsb => 'Connesso via USB';

  @override
  String get commonConnectedAway => 'Connesso fuori casa';

  @override
  String commonBattery(int level) {
    return 'Batteria al $level percento';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Batteria al $level percento, in carica';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count byte',
      one: '1 byte',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondi rimanenti',
      one: '1 secondo rimanente',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti rimanenti',
      one: '1 minuto rimanente',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'circa $count ore rimanenti',
      one: 'circa 1 ora rimanente',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Oggi';

  @override
  String get formatYesterday => 'Ieri';

  @override
  String get formatPhone => 'Telefono';

  @override
  String get settingsBack => 'Indietro';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsReceiving => 'Ricezione';

  @override
  String get settingsSaveLocation => 'Posizione di salvataggio';

  @override
  String get settingsSaveLocationPath => 'Download › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Accetta dai miei dispositivi';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'I file dai dispositivi associati arrivano senza chiedere.';

  @override
  String get settingsConnection => 'Connessione';

  @override
  String get settingsStayConnected => 'Resta connesso';

  @override
  String get settingsStayConnectedCaption =>
      'Condivisione più rapida con i dispositivi vicini. Consuma più batteria.';

  @override
  String get settingsKeepRunning => 'Resta attivo in background';

  @override
  String get settingsKeepRunningCaption =>
      'File, backup delle foto e chiamate continuano a funzionare quando Linksy è chiuso. Mostra una notifica discreta.';

  @override
  String get settingsAwayFromHome => 'Fuori casa';

  @override
  String get settingsAwayFromHomeCaption =>
      'Raggiungi i tuoi computer via internet quando non sei sulla stessa rete, per una settimana dall’ultima volta che lo eri. Crittografia end-to-end.';

  @override
  String get settingsRelay => 'Server relay';

  @override
  String get settingsRelayDefault => 'Quello di Linksy';

  @override
  String get settingsRelayCaption =>
      'L’indirizzo di un relay che ospiti tu, come https://relay.example.com. Lascia vuoto per quello di Linksy. Imposta lo stesso relay su ogni dispositivo.';

  @override
  String get settingsWithYourComputers => 'Con i tuoi computer';

  @override
  String get settingsPauseMusic =>
      'Metti in pausa la musica durante le chiamate';

  @override
  String get settingsPauseMusicCaption =>
      'I tuoi computer mettono in pausa ciò che è in riproduzione mentre una chiamata squilla o è in corso, e riprendono dopo.';

  @override
  String get settingsBrowseFiles => 'Permetti ai computer di sfogliare i file';

  @override
  String get settingsBrowseFilesChoose =>
      'Scegli una cartella che i tuoi computer possono aprire nella loro app File, come Documenti (Android non consente Download).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Condivide “$folder”. Tocca per scegliere un’altra cartella.';
  }

  @override
  String get settingsPicture => 'Immagine di questo telefono';

  @override
  String get settingsPictureChoose =>
      'I tuoi computer la mostrano per questo telefono. Tocca per sceglierne una.';

  @override
  String get settingsPictureChange =>
      'I tuoi computer la mostrano per questo telefono. Tocca per cambiarla.';

  @override
  String get settingsPictureRemove => 'Rimuovi';

  @override
  String get settingsLocate =>
      'Permetti ai computer di localizzare questo telefono';

  @override
  String get settingsLocateCaption =>
      'Un computer può chiedere dove si trova questo telefono, una volta, per trovarlo. Nulla viene salvato o tracciato. Funziona mentre Linksy è aperto.';

  @override
  String get settingsLocatePermission =>
      'Per questo Linksy ha bisogno del permesso di localizzazione.';

  @override
  String get settingsPhotoFolder => 'Cartella delle foto';

  @override
  String get settingsPhotoFolderChoose =>
      'Scegli la cartella della fotocamera (DCIM › Camera) per fare il backup delle foto su un computer.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Backup di “$folder”. Attivalo per ogni computer, nella sua pagina.';
  }

  @override
  String get settingsThisApp => 'Questa app';

  @override
  String get settingsPermissions => 'Permessi';

  @override
  String get settingsDemo => 'Demo';

  @override
  String get settingsDemoCaption =>
      'Dispositivi simulati finché il core di Linksy non è collegato. Avviano ciò che farebbe un altro dispositivo.';

  @override
  String get settingsDemoReceiveFiles => 'Ricevi file';

  @override
  String get settingsDemoReceivePairing =>
      'Ricevi una richiesta di associazione';

  @override
  String get settingsDemoReceiveClipboard => 'Ricevi testo negli appunti';

  @override
  String get settingsTagline =>
      'I tuoi dispositivi, connessi.\nNessun account, nessun cloud.';

  @override
  String get settingsNameTitle => 'Dai un nome a questo telefono';

  @override
  String get settingsNameCaption =>
      'Gli altri tuoi dispositivi vedono questo nome.';

  @override
  String get settingsSave => 'Salva';

  @override
  String get settingsCancel => 'Annulla';

  @override
  String settingsRename(String name) {
    return 'Rinomina $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'Questo telefono · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Notifiche e fotocamera';

  @override
  String get settingsPermissionsWhat =>
      'Cosa chiede Linksy ad Android, e perché.';

  @override
  String get settingsPermissionsBoth => 'Entrambi consentiti.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count di 2 consentiti. Tocca per consentire il resto.',
      one: '1 di 2 consentito. Tocca per consentire il resto.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Permessi';

  @override
  String get permissionsIntro =>
      'Linksy chiede solo ciò che gli serve, e puoi cambiare tutto più tardi nelle Impostazioni.';

  @override
  String get permissionsNotifications => 'Notifiche';

  @override
  String get permissionsNotificationsWhy =>
      'Mostra quando un computer vede il tuo schermo o usa la fotocamera, con un pulsante per interrompere.';

  @override
  String get permissionsCamera => 'Fotocamera';

  @override
  String get permissionsCameraWhy =>
      'Scansiona il codice QR di associazione e permette a un computer di usare questo telefono come webcam, se lo consenti.';

  @override
  String get permissionsAllow => 'Consenti';

  @override
  String get permissionsAllowed => 'Consentito';

  @override
  String get permissionsDone => 'Fatto';

  @override
  String get remoteBack => 'Indietro';

  @override
  String get remoteTitle => 'Telecomando';

  @override
  String remoteAllowOn(String name) {
    return 'Consentilo su $name';
  }

  @override
  String remoteAsks(String name) {
    return 'Linksy su $name chiede se questo telefono può muovere il puntatore e digitare.';
  }

  @override
  String get remoteFailed => 'Non ha funzionato';

  @override
  String get remoteStopped => 'Il telecomando si è fermato';

  @override
  String remoteEndedBy(String name) {
    return '$name l’ha terminato.';
  }

  @override
  String get remoteTryAgain => 'Riprova';

  @override
  String get remoteTouchpad => 'Touchpad';

  @override
  String get remoteSlides => 'Slide';

  @override
  String get remoteTouchpadHint =>
      'Muovi con un dito, tocca per cliccare\nDue dita per scorrere, tocco con due dita per il clic destro';

  @override
  String get remoteLeftClick => 'Clic sinistro';

  @override
  String get remoteRightClick => 'Clic destro';

  @override
  String get remoteKeyboard => 'Tastiera';

  @override
  String get remoteNextSlide => 'Slide successiva';

  @override
  String get remoteNext => 'Avanti';

  @override
  String get remotePreviousSlide => 'Slide precedente';

  @override
  String get remoteSlideBack => 'Indietro';

  @override
  String get remoteStartShow => 'Avvia (F5)';

  @override
  String get remoteEndShow => 'Termina (Esc)';

  @override
  String get remoteVolumeHint =>
      'Volume giù: avanti · Volume su: indietro. Lo schermo resta acceso.';

  @override
  String get ringTitle => 'Sono qui!';

  @override
  String ringLookingFor(String name) {
    return '$name sta cercando questo telefono.';
  }

  @override
  String get ringFoundIt => 'Trovato';

  @override
  String get webcamBack => 'Indietro';

  @override
  String get webcamTitle => 'Webcam';

  @override
  String webcamLiveOn(String name) {
    return 'In diretta su $name';
  }

  @override
  String get webcamStopSemantic => 'Ferma la webcam';

  @override
  String get webcamStop => 'Ferma';

  @override
  String get webcamBadgeLive => 'LIVE';

  @override
  String get webcamBadgeLock => 'BLOCCO AE/AF';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'TORCIA';

  @override
  String get webcamFacingFront => 'Anteriore';

  @override
  String get webcamFacingBack => 'Posteriore';

  @override
  String get webcamTorch => 'Torcia';

  @override
  String get webcamPortrait => 'Verticale';

  @override
  String get webcamLandscape => 'Orizzontale';

  @override
  String get webcamLocked => 'Bloccato';

  @override
  String get webcamLock => 'Blocca';

  @override
  String get webcamTabLight => 'Luce';

  @override
  String get webcamTabFocus => 'Messa a fuoco';

  @override
  String get webcamTabColor => 'Colore';

  @override
  String get webcamTabStream => 'Stream';

  @override
  String get webcamBrightness => 'Luminosità';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto =>
      'Questa fotocamera regola l’esposizione da sola.';

  @override
  String get webcamLockExposure => 'Blocca esposizione';

  @override
  String get webcamLockExposureDetail =>
      'Mantiene la luminosità com’è ora. Tieni premuta l’immagine per bloccarla su un punto.';

  @override
  String get webcamFocus => 'Messa a fuoco';

  @override
  String get webcamFocusFixed => 'Questa fotocamera ha la messa a fuoco fissa.';

  @override
  String get webcamFocusSpotDetail =>
      'Fissata dove hai toccato. Tocca due volte l’immagine per tornare ad auto.';

  @override
  String get webcamFocusManualDetail => 'Regolata a mano qui sotto.';

  @override
  String get webcamFocusAutoDetail =>
      'Segue l’immagine. Toccala per mettere a fuoco un punto.';

  @override
  String get webcamFocusAuto => 'Auto';

  @override
  String get webcamFocusSpot => 'Punto';

  @override
  String get webcamFocusManual => 'Manuale';

  @override
  String get webcamDistance => 'Distanza';

  @override
  String get webcamFar => 'Lontano';

  @override
  String get webcamNear => 'Vicino';

  @override
  String get webcamWbAuto => 'Auto';

  @override
  String get webcamWbDaylight => 'Luce diurna';

  @override
  String get webcamWbCloudy => 'Nuvoloso';

  @override
  String get webcamWbShade => 'Ombra';

  @override
  String get webcamWbIncandescent => 'Luce calda';

  @override
  String get webcamWbFluorescent => 'Luce da ufficio';

  @override
  String get webcamWhiteBalance => 'Bilanciamento del bianco';

  @override
  String get webcamLockColors => 'Blocca colori';

  @override
  String get webcamLockColorsDetail =>
      'Evita che i colori cambino quando cambia la luce.';

  @override
  String get webcamOrientation => 'Orientamento';

  @override
  String get webcamOrientationPortraitDetail =>
      'Tieni il telefono in verticale; bande ai lati.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Tieni il telefono in orizzontale; riempie l’inquadratura.';

  @override
  String get webcamFrameRate => 'Frequenza fotogrammi';

  @override
  String get webcamFps60Detail =>
      'Movimenti più fluidi; usa più dati e batteria.';

  @override
  String get webcamFps30Detail => 'Stabile per le videochiamate.';

  @override
  String get webcamFpsOnly30 => 'Questa fotocamera arriva fino a 30 fps.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Risoluzione';

  @override
  String get webcamResolution1080Detail =>
      'Full HD, per uno schermo grande; più dati.';

  @override
  String get webcamResolution720Detail => 'HD, ideale per le videochiamate.';

  @override
  String get webcamResolutionOnly720 => 'Questa fotocamera trasmette in 720p.';

  @override
  String get webcamQuality => 'Qualità';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, per una Wi-Fi affollata.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, il massimo dettaglio.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, nitida per le videochiamate.';
  }

  @override
  String get webcamQualitySaver => 'Risparmio';

  @override
  String get webcamQualityStandard => 'Standard';

  @override
  String get webcamQualityHigh => 'Alta';

  @override
  String get webcamStabilization => 'Stabilizzazione';

  @override
  String get webcamStabilizationDetail => 'Attenua il tremolio della mano.';

  @override
  String get webcamMirror => 'Specchia l’anteprima';

  @override
  String get webcamMirrorDetail =>
      'Solo su questo telefono; il computer la riceve non specchiata.';

  @override
  String get webcamFormat => 'Formato';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Ripristina';

  @override
  String webcamResetSetting(String setting) {
    return 'Ripristina $setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name vuole vedere il tuo schermo';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Tutto ciò che appare sullo schermo di questo telefono viene mostrato su $name finché non interrompi. Poi Android ti chiede di confermare.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name vuole controllare il tuo schermo';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '$name vede lo schermo di questo telefono e può toccare, scorrere e digitare finché non interrompi. Poi Android ti chiede di confermare.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name vuole usare la tua fotocamera';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '$name usa la fotocamera di questo telefono come webcam finché non interrompi. Zoom, messa a fuoco, luce, obiettivi e rotazione sono in Linksy mentre è attiva.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name vuole usare questo telefono come touchpad';
  }

  @override
  String get sharingInputRequestDetail =>
      'Inatteso: i computer non lo chiedono. Non consentirlo.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name vuole usare il tuo microfono';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '$name sente il microfono di questo telefono finché non interrompi, come un microfono che tutte le sue app possono usare. Poi Android ti chiede di confermare.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name vuole usare questo schermo come secondo schermo';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'Questo telefono mostra uno schermo di $name a schermo intero. Tocca per cliccare e trascinare; scorri con due dita. Torna indietro per interrompere.';
  }

  @override
  String get sharingAllow => 'Consenti';

  @override
  String get sharingDontAllow => 'Non consentire';

  @override
  String get sharingProtectionHint =>
      'Barra superiore o notifiche nere sul computer? La protezione della condivisione schermo di Android le nasconde. Attiva “Disattiva protezioni condivisione schermo” nelle Opzioni sviluppatore, poi condividi di nuovo.';

  @override
  String get sharingGotIt => 'Ho capito';

  @override
  String get sharingDeveloperOptions => 'Opzioni sviluppatore';

  @override
  String sharingControlling(String name) {
    return '$name sta controllando il tuo schermo';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name sta usando la tua fotocamera';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name sta usando il tuo microfono';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Stai condividendo lo schermo con $name';
  }

  @override
  String get sharingTapForCameraControls =>
      'Tocca per i controlli della fotocamera';

  @override
  String get sharingSwitchCamera => 'Cambia fotocamera';

  @override
  String get sharingStopSharing => 'Interrompi condivisione';

  @override
  String get sharingStop => 'Ferma';

  @override
  String get sharingCameraControls => 'Controlli fotocamera';

  @override
  String displaySecondHint(String name) {
    return 'Secondo schermo di $name · torna indietro per interrompere';
  }

  @override
  String displayControlHint(String name) {
    return 'Schermo di $name · tocca per cliccare · torna indietro per interrompere';
  }

  @override
  String displayWatchHint(String name) {
    return 'Schermo di $name · torna indietro per interrompere';
  }

  @override
  String terminalTabClosed(String title) {
    return '“$title” chiuso';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '“$title” terminato su $name';
  }

  @override
  String get terminalCloseTitle => 'Chiudere questo terminale?';

  @override
  String terminalCloseDetail(String name) {
    return 'La shell termina su $name, insieme a tutto ciò che vi è ancora in esecuzione. Per tornarci più tardi, lasciala invece in esecuzione.';
  }

  @override
  String get terminalKeepRunning => 'Lascia in esecuzione';

  @override
  String get terminalClose => 'Chiudi';

  @override
  String get terminalTheComputer => 'il computer';

  @override
  String get terminalDetached => 'Scollegato';

  @override
  String terminalDetachedDetail(String name) {
    return 'Ancora in esecuzione su $name. Ricollegati per vederlo di nuovo; il codice verrà richiesto ancora.';
  }

  @override
  String get terminalReattach => 'Ricollega';

  @override
  String terminalOn(String name) {
    return 'Terminale su $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Scollegato · ancora in esecuzione su $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Apertura su $name…';
  }

  @override
  String get terminalWaitingForCode => 'In attesa del codice';

  @override
  String get terminalEnded => 'Terminato';

  @override
  String get terminalBack => 'Indietro';

  @override
  String get terminalTitle => 'Terminale';

  @override
  String get terminalMenu => 'Menu del terminale';

  @override
  String get terminalDetachMenu => 'Lascialo in esecuzione (scollega)';

  @override
  String terminalCloseTab(String title) {
    return 'Chiudi $title';
  }

  @override
  String get terminalNew => 'Nuovo terminale';

  @override
  String terminalShellOn(String name) {
    return 'Una shell su $name';
  }

  @override
  String get terminalShellDetail =>
      'Viene eseguita come te sul computer, nella tua cartella home. Ogni volta che si apre, chiede il codice del terminale impostato lì.';

  @override
  String get terminalStillRunning => 'ANCORA IN ESECUZIONE';

  @override
  String terminalReattachTab(String title) {
    return 'Ricollega $title';
  }

  @override
  String terminalStarted(String time) {
    return 'Avviato alle $time';
  }

  @override
  String get terminalKeyLeft => 'Sinistra';

  @override
  String get terminalKeyUp => 'Su';

  @override
  String get terminalKeyDown => 'Giù';

  @override
  String get terminalKeyRight => 'Destra';

  @override
  String get terminalCodeTitle => 'Codice del terminale';

  @override
  String terminalCodeDetail(String name) {
    return 'Il codice impostato su $name in Preferenze › Terminale. Linksy non lo conserva mai.';
  }

  @override
  String get terminalCodePassphrase => 'Passphrase';

  @override
  String get terminalCodeDigitsHint => '6 o più cifre';

  @override
  String get terminalCodeUseDigits => 'Usa cifre';

  @override
  String get terminalCodeUseLetters => 'Usa lettere';

  @override
  String get terminalOpening => 'Apertura…';

  @override
  String get terminalOpen => 'Apri terminale';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String usbConnectedTo(String name) {
    return 'Connesso a $name via cavo USB';
  }

  @override
  String get usbPairTitle => 'C’è un computer sul cavo';

  @override
  String get usbPairBody =>
      'Non è ancora associato a questo telefono. Associarlo tramite il cavo? Entrambi gli schermi mostrano un codice da confrontare.';

  @override
  String get usbPairAction => 'Associa';
}
