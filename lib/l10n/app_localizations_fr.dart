// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Bienvenue dans Linksy';

  @override
  String get onboardingChooseLanguage => 'Choisissez votre langue';

  @override
  String get onboardingLanguageHint =>
      'Vous pourrez la changer plus tard dans les Réglages.';

  @override
  String get onboardingContinue => 'Continuer';

  @override
  String get onboardingSetUpTitle => 'Configurer Linksy';

  @override
  String get onboardingSetUpSubtitle =>
      'Choisissez ce que Linksy peut faire. Rien ne quitte ce téléphone sans votre accord.';

  @override
  String get onboardingNotifications => 'Notifications';

  @override
  String get onboardingNotificationsDetail =>
      'Fichiers reçus, et quand un ordinateur utilise votre écran, votre caméra ou votre micro, avec un bouton pour arrêter.';

  @override
  String get onboardingCamera => 'Caméra';

  @override
  String get onboardingCameraDetail =>
      'Scanne les QR codes d’association, et permet à un ordinateur de l’utiliser comme webcam si vous l’autorisez.';

  @override
  String get onboardingAway => 'Hors de chez vous';

  @override
  String get onboardingAwayDetail =>
      'Accédez à vos ordinateurs par Internet quand vous n’êtes pas sur le même Wi-Fi. Chiffré de bout en bout.';

  @override
  String get onboardingBackground => 'Continuer en arrière-plan';

  @override
  String get onboardingBackgroundDetail =>
      'Les fichiers et les appels fonctionnent même quand Linksy est fermé. Affiche une notification discrète.';

  @override
  String get onboardingFolder => 'Partager un dossier avec les ordinateurs';

  @override
  String get onboardingFolderDetail =>
      'Vos ordinateurs peuvent ouvrir un dossier de votre choix dans leur app Fichiers.';

  @override
  String get onboardingPhotos => 'Dossier de sauvegarde des photos';

  @override
  String get onboardingPhotosDetail =>
      'Choisissez le dossier de l’appareil photo pour sauvegarder les nouvelles photos sur un ordinateur. À activer pour chaque ordinateur.';

  @override
  String get onboardingLocate =>
      'Permettre aux ordinateurs de localiser ce téléphone';

  @override
  String get onboardingLocateDetail =>
      'Un ordinateur peut demander où se trouve ce téléphone, une fois. Rien n’est conservé.';

  @override
  String get onboardingAllow => 'Autoriser';

  @override
  String get onboardingAllowed => 'Autorisé';

  @override
  String get onboardingChooseFolder => 'Choisir';

  @override
  String onboardingFolderChosen(String folder) {
    return '« $folder »';
  }

  @override
  String get onboardingAnytime =>
      'Vous pouvez activer ou désactiver chacun de ces éléments à tout moment dans les Réglages.';

  @override
  String get onboardingStart => 'Commencer avec Linksy';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageDone => 'OK';

  @override
  String get ctlClipboardFileTooBig =>
      'Le presse-papiers n’accepte qu’un fichier de 10 MB maximum.';

  @override
  String get ctlClipboardCopyFailed =>
      'Impossible de le mettre dans le presse-papiers';

  @override
  String get ctlLocateOff =>
      'La localisation est désactivée dans Linksy sur ce téléphone';

  @override
  String get ctlYourComputer => 'votre ordinateur';

  @override
  String get ctlAnd => 'et';

  @override
  String ctlKeepingLocked(String names) {
    return '$names se verrouillent quand vous partez';
  }

  @override
  String get ctlStayingConnected => 'Connecté à vos ordinateurs';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name veut vous envoyer $count fichiers',
      one: '$name veut vous envoyer un fichier',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'Le presse-papiers est vide.';

  @override
  String get ctlClipboardTooMuch =>
      'Le presse-papiers contient trop de texte à envoyer.';

  @override
  String get ctlPing => 'Ping';

  @override
  String ctlPingFrom(String name) {
    return 'De $name';
  }

  @override
  String get ctlTextTooMuch => 'Ce texte est trop long à envoyer.';

  @override
  String get ctlDeclined => 'Refusé';

  @override
  String get ctlScreenPermission =>
      'Pour partager l’écran, Android doit autoriser sa capture.';

  @override
  String get ctlCameraPermission =>
      'Linksy a besoin de l’autorisation Caméra pour servir de webcam.';

  @override
  String get ctlMicrophonePermission =>
      'Linksy a besoin de l’autorisation Micro pour servir de micro.';

  @override
  String get ctlTerminalTitle => 'Terminal';

  @override
  String get errorThatDevice => 'Cet appareil';

  @override
  String get errorOtherDevice => 'L’autre appareil';

  @override
  String get errorComputerOnCable => 'L’ordinateur relié par câble';

  @override
  String errorDeviceAt(String address) {
    return 'L’appareil à l’adresse $address';
  }

  @override
  String errorUnreachable(String name) {
    return '$name est injoignable. Vérifiez qu’il est allumé et sur ce réseau.';
  }

  @override
  String errorDeclined(String name) {
    return '$name a refusé.';
  }

  @override
  String errorTimeout(String name) {
    return '$name n’a pas répondu à temps.';
  }

  @override
  String errorNotPaired(String name) {
    return '$name n’est plus associé. Associez-le à nouveau pour partager.';
  }

  @override
  String errorUnsupported(String name) {
    return '$name ne sait pas encore faire ça.';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name ne l’autorise que sur le même réseau. Son propriétaire peut tout autoriser à distance pour ce téléphone.';
  }

  @override
  String get errorInvalid => 'Ça n’a pas marché.';

  @override
  String get errorSomethingWrong => 'Un problème est survenu.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Un problème est survenu : $detail';
  }

  @override
  String get terminalRefusedComputer => 'L’ordinateur';

  @override
  String get terminalRefusedCode => 'Code incorrect.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Code incorrect, $count essais restants.',
      one: 'Code incorrect, 1 essai restant.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Trop de codes incorrects. Déverrouillez le terminal sur $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'Sur $name, ouvrez la page de ce téléphone et autorisez-y le terminal.';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name n’autorise le terminal que sur le même réseau, sauf si « Tout autoriser à distance » y est activé.';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name ne peut pas ouvrir de terminal.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return '8 terminaux tournent déjà sur $name pour ce téléphone. Fermez-en un d’abord.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name ne l’a pas autorisé.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$kind $os';
  }

  @override
  String get modelKindDesktop => 'Ordinateur de bureau';

  @override
  String get modelKindLaptop => 'Ordinateur portable';

  @override
  String get modelKindPhone => 'Téléphone';

  @override
  String get modelKindTablet => 'Tablette';

  @override
  String get modelOsUnknown => 'inconnu';

  @override
  String get deviceNothingOfKind => 'Rien de ce type pour l’instant.';

  @override
  String deviceBattery(int level) {
    return '$level %';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level %, en charge';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Accessible à distance jusqu’au $day';
  }

  @override
  String get deviceLocksWhenLeave =>
      'Se verrouille quand vous partez avec ce téléphone';

  @override
  String get deviceBack => 'Retour';

  @override
  String get deviceMore => 'Plus';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Changer l’image';

  @override
  String get deviceAddPicture => 'Ajouter une image';

  @override
  String get deviceRemovePicture => 'Supprimer l’image';

  @override
  String get deviceForgetThis => 'Oublier cet appareil';

  @override
  String deviceForgetTitle(String name) {
    return 'Oublier $name ?';
  }

  @override
  String get deviceForgetBody =>
      'Il faudra l’associer à nouveau pour partager avec lui. Son activité sur ce téléphone est aussi effacée.';

  @override
  String get deviceForget => 'Oublier';

  @override
  String get deviceCancel => 'Annuler';

  @override
  String get deviceSendFiles => 'Envoyer des fichiers';

  @override
  String get deviceSendFilesCaption => 'Photos, documents, tout';

  @override
  String get deviceClipboard => 'Presse-papiers';

  @override
  String get deviceClipboardCaption => 'Envoyez ce que vous avez copié';

  @override
  String get devicePing => 'Ping';

  @override
  String get devicePingCaption => 'Le faire tinter';

  @override
  String get deviceRemote => 'Télécommande';

  @override
  String get deviceRemoteCaption => 'Pavé tactile et diapos';

  @override
  String get deviceRinging => 'Sonnerie…';

  @override
  String get deviceFindIt => 'Le retrouver';

  @override
  String get deviceTapToStop => 'Touchez pour arrêter';

  @override
  String get deviceFindItCaption => 'Le faire sonner fort';

  @override
  String get devicePrevious => 'Précédent';

  @override
  String get devicePause => 'Pause';

  @override
  String get devicePlay => 'Lecture';

  @override
  String get deviceNext => 'Suivant';

  @override
  String deviceAllowOn(String name) {
    return 'Autorisez-le sur $name…';
  }

  @override
  String get deviceSeeScreen => 'Voir son écran';

  @override
  String get deviceSeeScreenCaption =>
      'Regardez-le ici, ou contrôlez-le au toucher';

  @override
  String get deviceWatch => 'Regarder';

  @override
  String get deviceControl => 'Contrôler';

  @override
  String get deviceTerminal => 'Terminal';

  @override
  String deviceTerminalShell(String name) {
    return 'Un shell sur $name, protégé par son code';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terminaux ouverts',
      one: '1 terminal ouvert',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'Tout';

  @override
  String get deviceFilterFiles => 'Fichiers';

  @override
  String get deviceFilterClipboard => 'Presse-papiers';

  @override
  String get deviceFilterLinks => 'Liens';

  @override
  String get deviceFilterShowAll => 'Tout afficher';

  @override
  String get deviceFilterShowFiles => 'Afficher les fichiers';

  @override
  String get deviceFilterShowClipboard => 'Afficher le presse-papiers';

  @override
  String get deviceFilterShowLinks => 'Afficher les liens';

  @override
  String get deviceActivity => 'Activité';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Prêt quand $name le demande';
  }

  @override
  String get deviceWebcam => 'Webcam';

  @override
  String get deviceInUseNow => 'En cours d’utilisation';

  @override
  String get deviceControls => 'Réglages';

  @override
  String get deviceMicrophone => 'Micro';

  @override
  String get deviceStop => 'Arrêter';

  @override
  String get deviceSecondDisplay => 'Second écran';

  @override
  String get deviceShowingNow => 'Affichage en cours';

  @override
  String deviceReadySize(int width, int height) {
    return 'Prêt · $width × $height';
  }

  @override
  String get devicePhoneAs => 'Ce téléphone comme';

  @override
  String deviceStartedOn(String name) {
    return 'Se lance depuis $name';
  }

  @override
  String get deviceFasterOverUsb =>
      'Plus rapide et plus stable avec un câble USB.';

  @override
  String get deviceBackUpPhotos => 'Sauvegarder les photos';

  @override
  String devicePhotosGoTo(String name) {
    return 'Les nouvelles photos vont dans le dossier Images de $name';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name n’accepte pas les photos. Activez-y « Importer les photos des téléphones ».';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'Depuis $folder';
  }

  @override
  String get devicePhotosFromCamera => 'Depuis le dossier de l’appareil photo';

  @override
  String devicePhotosLast(String time) {
    return 'dernière : $time';
  }

  @override
  String get deviceGetClipboard => 'Recevoir son presse-papiers';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'Le texte copié sur $name arrive ici tant que vous êtes connecté';
  }

  @override
  String get deviceAwayAll => 'Tout autoriser à distance';

  @override
  String get deviceAwayAllOn =>
      'À distance aussi : cet écran, la webcam, le micro et les fichiers';

  @override
  String get deviceAwayAllOff =>
      'À distance : presse-papiers, liens, fichiers et sonnerie uniquement';

  @override
  String get deviceNothingShared => 'Rien de partagé pour l’instant';

  @override
  String deviceNothingSharedBody(String name) {
    return 'Les fichiers, le texte copié et les pings entre ce téléphone et $name s’affichent ici.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '« $text »';
  }

  @override
  String get activityClipboardText => 'Texte du presse-papiers';

  @override
  String get activityPing => 'Ping';

  @override
  String get activityYourScreen => 'Votre écran';

  @override
  String get activityYourCamera => 'Votre caméra';

  @override
  String get activitySecondDisplay => 'Second écran';

  @override
  String get activityLink => 'Lien';

  @override
  String get activityRangThisPhone => 'A fait sonner ce téléphone';

  @override
  String get activityRangIt => 'Sonnerie envoyée';

  @override
  String get activityTouchpadKeyboard => 'Pavé tactile et clavier';

  @override
  String get activityItsScreen => 'Son écran';

  @override
  String get activityYourMicrophone => 'Votre micro';

  @override
  String get activityWhereThisPhone => 'Position de ce téléphone';

  @override
  String get activityWatchingNow => 'Visionnage en cours';

  @override
  String get activityWatched => 'Regardé';

  @override
  String get activityInUseWebcam => 'Utilisée comme webcam';

  @override
  String get activityUsedWebcam => 'A servi de webcam';

  @override
  String get activityBeingControlled => 'Contrôlé en ce moment';

  @override
  String get activityWatchedControlled => 'Regardé et contrôlé';

  @override
  String get activityWatchedFromPhone => 'Regardé depuis ce téléphone';

  @override
  String get activityInUseNow => 'En cours d’utilisation';

  @override
  String get activityWasTouchpad => 'Ce téléphone a servi de pavé tactile';

  @override
  String get activityWasSecondDisplay => 'Ce téléphone a servi de second écran';

  @override
  String get activityLinkReceived => 'Lien reçu';

  @override
  String get activityOpenedOnComputer => 'Ouvert sur l’ordinateur';

  @override
  String get activityInUseMicrophone => 'Utilisé comme micro';

  @override
  String get activityUsedMicrophone => 'A servi de micro';

  @override
  String get activityNotTold => 'Non communiquée';

  @override
  String get activityToldWhere => 'Position de ce téléphone communiquée';

  @override
  String get activityAskedToFind => 'A demandé à retrouver ce téléphone';

  @override
  String get activityToFindIt => 'Pour le retrouver';

  @override
  String get activityDeclined => 'Refusé';

  @override
  String get activityFailed => 'Échec';

  @override
  String get activityInProgress => 'En cours';

  @override
  String get activityCopiedHere => 'Copié ici';

  @override
  String get activityReceived => 'Reçu';

  @override
  String get activitySent => 'Envoyé';

  @override
  String get activityStop => 'Arrêter';

  @override
  String get activityCancel => 'Annuler';

  @override
  String get activityCopyAgain => 'Copier à nouveau';

  @override
  String get activityCopied => 'Copié';

  @override
  String get activityCopyLink => 'Copier le lien';

  @override
  String get activityLinkCopied => 'Lien copié';

  @override
  String get activityNoAppForLink => 'Aucune app ici n’ouvre ce lien.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: '1 fichier',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name n’est plus là.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'Aucune app sur ce téléphone n’ouvre $name.';
  }

  @override
  String get activityWaitingForYou => 'En attente de votre accord…';

  @override
  String get activityWaitingForDevice =>
      'En attente de l’accord de l’appareil…';

  @override
  String activityWaitingFor(String name) {
    return 'En attente de l’accord de $name…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done sur $total';
  }

  @override
  String get homeSettings => 'Réglages';

  @override
  String get homeYourDevices => 'Vos appareils';

  @override
  String get homeNearbyNotPaired => 'À proximité, non associés';

  @override
  String get homeAddDevice => 'Ajouter un appareil';

  @override
  String homeVisible(String name) {
    return '$name est visible sur ce Wi-Fi';
  }

  @override
  String get homeUpdateTitle => 'Mettez Linksy à jour pour rester connecté';

  @override
  String get homeUpdateBody =>
      'Vos ordinateurs utilisent une version de Linksy plus récente que cette app.';

  @override
  String get homeGetUpdate => 'Obtenir la mise à jour';

  @override
  String get homeSendFiles => 'Envoyer des fichiers';

  @override
  String get homePair => 'Associer';

  @override
  String get homeStepOpen => 'Ouvrez Linksy sur votre ordinateur';

  @override
  String get homeStepChoose => 'Choisissez « Ajouter un appareil »';

  @override
  String get homeStepScan => 'Scannez-le avec ce téléphone';

  @override
  String get homeConnectTitle => 'Connectez votre\npremier appareil';

  @override
  String get homeConnectSubtitle =>
      'Directement par votre Wi-Fi. Sans compte, sans cloud.';

  @override
  String get homeScanQr => 'Scanner le QR code';

  @override
  String get homePairByAddress => 'Associer plutôt par adresse';

  @override
  String get pairingAddDevice => 'Ajouter un appareil';

  @override
  String get pairingAddDeviceHint =>
      'Sur l’autre appareil, ouvrez Linksy et choisissez « Ajouter un appareil ».';

  @override
  String get pairingScanQr => 'Scanner le QR code';

  @override
  String get pairingScanQrCaption => 'Le plus rapide. Rien à taper.';

  @override
  String get pairingByAddress => 'Associer par adresse';

  @override
  String get pairingByAddressCaption =>
      'Quand l’autre appareil est introuvable.';

  @override
  String pairingWith(String name) {
    return 'Association avec $name…';
  }

  @override
  String get pairingWithOtherDevice => 'Association avec l’autre appareil…';

  @override
  String get pairingAddressHint =>
      'Elle figure dans les Préférences de Linksy sur l’autre appareil.';

  @override
  String pairingPortHint(String port) {
    return 'Port $port, sauf si vous en indiquez un autre.';
  }

  @override
  String get pairingPair => 'Associer';

  @override
  String pairingWantsToPair(String name) {
    return '$name veut s’associer';
  }

  @override
  String pairingPairWith(String name) {
    return 'Associer avec $name';
  }

  @override
  String get pairingCodeHint => 'Les deux écrans doivent afficher ce code.';

  @override
  String pairingCodeLabel(String code) {
    return 'Code $code';
  }

  @override
  String get pairingCodesMatch => 'Les codes correspondent';

  @override
  String get scanNeedsCamera =>
      'Linksy a besoin de la caméra pour scanner le code d’association. Autorisez-la, ou associez par adresse.';

  @override
  String get scanCameraUnavailable => 'La caméra n’est pas disponible.';

  @override
  String get scanFlashlight => 'Lampe torche';

  @override
  String get scanTitle => 'Scannez le code';

  @override
  String get scanWrongCode =>
      'Ce n’est pas un code Linksy. Sur votre ordinateur, ouvrez Linksy → Pair with QR Code.';

  @override
  String get scanHint =>
      'Sur votre ordinateur, ouvrez Linksy et choisissez « Ajouter un appareil ».';

  @override
  String get shareSheetPutOnClipboard => 'Mettre dans un presse-papiers';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Envoyer $count fichiers',
      one: 'Envoyer un fichier',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Ouvrir sur un ordinateur';

  @override
  String get shareSheetSendToClipboard => 'Envoyer vers un presse-papiers';

  @override
  String get shareSheetNoClipboardFiles =>
      'Aucun de vos ordinateurs n’accepte encore de fichiers dans son presse-papiers. Mettez-y Linksy à jour.';

  @override
  String get shareSheetNoComputers =>
      'Associez d’abord un ordinateur, puis partagez-lui du contenu depuis n’importe quelle app.';

  @override
  String get shareSheetSendFileInstead => 'Envoyer plutôt le fichier';

  @override
  String get shareSheetClipboardInstead =>
      'Le mettre plutôt dans le presse-papiers de l’ordinateur';

  @override
  String get shareSheetOpenLinkInstead => 'Ouvrir plutôt le lien';

  @override
  String get shareSheetSendAsTextInstead =>
      'Envoyer plutôt en texte vers le presse-papiers';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Envoi vers le presse-papiers de $name';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Envoi vers le presse-papiers de l’ordinateur';

  @override
  String shareSheetOpened(String name) {
    return 'Ouvert sur $name';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Ouvert sur l’ordinateur';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'Envoyé dans le presse-papiers de $name';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'Envoyé dans le presse-papiers de l’ordinateur';

  @override
  String shareSheetSentALink(String name) {
    return '$name a envoyé un lien';
  }

  @override
  String get shareSheetOpen => 'Ouvrir';

  @override
  String get shareSheetCopyLink => 'Copier le lien';

  @override
  String get shareSheetLinkCopied => 'Lien copié';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: 'un fichier',
    );
    return '$name vous envoie $_temp0';
  }

  @override
  String incomingTotal(String size) {
    return '$size au total';
  }

  @override
  String incomingMore(int count) {
    return '+ $count autres';
  }

  @override
  String get incomingAccept => 'Accepter';

  @override
  String get appInvalidPairingLink => 'Ce lien d’association n’est pas valide.';

  @override
  String appPairingFailed(String reason) {
    return 'Échec de l’association : $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'Impossible de s’associer avec $name : $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Associé avec $name';
  }

  @override
  String appNotification(String name, String text) {
    return '$name : $text';
  }

  @override
  String appCopiedText(String name) {
    return 'Texte copié depuis $name';
  }

  @override
  String appCopiedFile(String file, String name) {
    return '$file copié depuis $name';
  }

  @override
  String get appCouldntStart => 'Linksy n’a pas pu démarrer';

  @override
  String get commonDismiss => 'Ignorer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDecline => 'Refuser';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonNotNow => 'Pas maintenant';

  @override
  String get commonConnected => 'Connecté';

  @override
  String get commonNearby => 'À proximité';

  @override
  String get commonNotNearby => 'Pas à proximité';

  @override
  String get commonUsbCable => 'Câble USB';

  @override
  String get commonAwayFromHome => 'Hors de chez vous';

  @override
  String get commonSameWifi => 'Même Wi-Fi';

  @override
  String get commonConnectedByUsb => 'Connecté par USB';

  @override
  String get commonConnectedAway => 'Connecté à distance';

  @override
  String commonBattery(int level) {
    return 'Batterie à $level pour cent';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Batterie à $level pour cent, en charge';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count octets',
      one: '$count octet',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count secondes restantes',
      one: '1 seconde restante',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes restantes',
      one: '1 minute restante',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'environ $count heures restantes',
      one: 'environ 1 heure restante',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Aujourd’hui';

  @override
  String get formatYesterday => 'Hier';

  @override
  String get formatPhone => 'Téléphone';

  @override
  String get settingsBack => 'Retour';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsReceiving => 'Réception';

  @override
  String get settingsSaveLocation => 'Emplacement d’enregistrement';

  @override
  String get settingsSaveLocationPath => 'Téléchargements › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Accepter de mes appareils';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'Les fichiers des appareils associés arrivent sans demande.';

  @override
  String get settingsConnection => 'Connexion';

  @override
  String get settingsStayConnected => 'Rester connecté';

  @override
  String get settingsStayConnectedCaption =>
      'Partage plus rapide avec les appareils proches. Consomme plus de batterie.';

  @override
  String get settingsKeepRunning => 'Continuer en arrière-plan';

  @override
  String get settingsKeepRunningCaption =>
      'Les fichiers, la sauvegarde des photos et les appels fonctionnent même quand Linksy est fermé. Affiche une notification discrète.';

  @override
  String get settingsAwayFromHome => 'Hors de chez vous';

  @override
  String get settingsAwayFromHomeCaption =>
      'Accédez à vos ordinateurs par Internet quand vous n’êtes pas sur le même réseau, pendant une semaine après votre dernière connexion locale. Chiffré de bout en bout.';

  @override
  String get settingsRelay => 'Serveur relais';

  @override
  String get settingsRelayDefault => 'Celui de Linksy';

  @override
  String get settingsRelayCaption =>
      'L’adresse d’un relais que vous hébergez, comme https://relay.example.com. Laissez vide pour celui de Linksy. Réglez le même relais sur chaque appareil.';

  @override
  String get settingsWithYourComputers => 'Avec vos ordinateurs';

  @override
  String get settingsPauseMusic =>
      'Mettre la musique en pause pendant les appels';

  @override
  String get settingsPauseMusicCaption =>
      'Vos ordinateurs mettent en pause ce qui joue pendant qu’un appel sonne ou dure, puis reprennent ensuite.';

  @override
  String get settingsBrowseFiles =>
      'Permettre aux ordinateurs de parcourir les fichiers';

  @override
  String get settingsBrowseFilesChoose =>
      'Choisissez un dossier que vos ordinateurs pourront ouvrir dans leur app Fichiers, comme Documents (Android n’autorise pas Download).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Partage « $folder ». Touchez pour choisir un autre dossier.';
  }

  @override
  String get settingsPicture => 'Image de ce téléphone';

  @override
  String get settingsPictureChoose =>
      'Vos ordinateurs l’affichent pour ce téléphone. Touchez pour en choisir une.';

  @override
  String get settingsPictureChange =>
      'Vos ordinateurs l’affichent pour ce téléphone. Touchez pour la changer.';

  @override
  String get settingsPictureRemove => 'Supprimer';

  @override
  String get settingsLocate =>
      'Permettre aux ordinateurs de localiser ce téléphone';

  @override
  String get settingsLocateCaption =>
      'Un ordinateur peut demander où se trouve ce téléphone, une fois, pour le retrouver. Rien n’est conservé ni suivi. Fonctionne quand Linksy est ouvert.';

  @override
  String get settingsLocatePermission =>
      'Linksy a besoin de l’autorisation de localisation pour cela.';

  @override
  String get settingsPhotoFolder => 'Dossier photos';

  @override
  String get settingsPhotoFolderChoose =>
      'Choisissez le dossier de l’appareil photo (DCIM › Camera) pour sauvegarder les photos sur un ordinateur.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Sauvegarde « $folder ». Activez-la pour chaque ordinateur, sur sa page.';
  }

  @override
  String get settingsThisApp => 'Cette app';

  @override
  String get settingsPermissions => 'Autorisations';

  @override
  String get settingsDemo => 'Démo';

  @override
  String get settingsDemoCaption =>
      'Appareils simulés tant que le cœur de Linksy n’est pas connecté. Ces actions lancent ce qu’un autre appareil ferait.';

  @override
  String get settingsDemoReceiveFiles => 'Recevoir des fichiers';

  @override
  String get settingsDemoReceivePairing => 'Recevoir une demande d’association';

  @override
  String get settingsDemoReceiveClipboard => 'Recevoir du texte copié';

  @override
  String get settingsTagline =>
      'Vos appareils, connectés.\nSans compte, sans cloud.';

  @override
  String get settingsNameTitle => 'Nommer ce téléphone';

  @override
  String get settingsNameCaption => 'Vos autres appareils voient ce nom.';

  @override
  String get settingsSave => 'Enregistrer';

  @override
  String get settingsCancel => 'Annuler';

  @override
  String settingsRename(String name) {
    return 'Renommer $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'Ce téléphone · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Notifications et caméra';

  @override
  String get settingsPermissionsWhat =>
      'Ce que Linksy demande à Android, et pourquoi.';

  @override
  String get settingsPermissionsBoth => 'Les deux sont autorisées.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sur 2 autorisées. Touchez pour autoriser le reste.',
      one: '$count sur 2 autorisée. Touchez pour autoriser le reste.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Autorisations';

  @override
  String get permissionsIntro =>
      'Linksy ne demande que ce dont il a besoin, et vous pouvez modifier chacune de ces autorisations plus tard dans les Réglages.';

  @override
  String get permissionsNotifications => 'Notifications';

  @override
  String get permissionsNotificationsWhy =>
      'Indique quand un ordinateur voit votre écran ou utilise votre caméra, avec un bouton pour arrêter.';

  @override
  String get permissionsCamera => 'Caméra';

  @override
  String get permissionsCameraWhy =>
      'Scanne le QR code d’association, et permet à un ordinateur d’utiliser ce téléphone comme webcam si vous l’autorisez.';

  @override
  String get permissionsAllow => 'Autoriser';

  @override
  String get permissionsAllowed => 'Autorisé';

  @override
  String get permissionsDone => 'OK';

  @override
  String get remoteBack => 'Retour';

  @override
  String get remoteTitle => 'Télécommande';

  @override
  String remoteAllowOn(String name) {
    return 'Autorisez-le sur $name';
  }

  @override
  String remoteAsks(String name) {
    return 'Linksy sur $name demande si ce téléphone peut déplacer son pointeur et taper du texte.';
  }

  @override
  String get remoteFailed => 'Ça n’a pas marché';

  @override
  String get remoteStopped => 'La télécommande s’est arrêtée';

  @override
  String remoteEndedBy(String name) {
    return '$name y a mis fin.';
  }

  @override
  String get remoteTryAgain => 'Réessayer';

  @override
  String get remoteTouchpad => 'Pavé tactile';

  @override
  String get remoteSlides => 'Diapos';

  @override
  String get remoteTouchpadHint =>
      'Déplacez avec un doigt, touchez pour cliquer\nDeux doigts pour défiler, touchez à deux doigts pour un clic droit';

  @override
  String get remoteLeftClick => 'Clic gauche';

  @override
  String get remoteRightClick => 'Clic droit';

  @override
  String get remoteKeyboard => 'Clavier';

  @override
  String get remoteNextSlide => 'Diapo suivante';

  @override
  String get remoteNext => 'Suivante';

  @override
  String get remotePreviousSlide => 'Diapo précédente';

  @override
  String get remoteSlideBack => 'Précédente';

  @override
  String get remoteStartShow => 'Lancer (F5)';

  @override
  String get remoteEndShow => 'Quitter (Esc)';

  @override
  String get remoteVolumeHint =>
      'Volume bas : suivante · Volume haut : précédente. L’écran reste allumé.';

  @override
  String get ringTitle => 'Je suis là !';

  @override
  String ringLookingFor(String name) {
    return '$name cherche ce téléphone.';
  }

  @override
  String get ringFoundIt => 'Trouvé';

  @override
  String get webcamBack => 'Retour';

  @override
  String get webcamTitle => 'Webcam';

  @override
  String webcamLiveOn(String name) {
    return 'En direct sur $name';
  }

  @override
  String get webcamStopSemantic => 'Arrêter la webcam';

  @override
  String get webcamStop => 'Arrêter';

  @override
  String get webcamBadgeLive => 'EN DIRECT';

  @override
  String get webcamBadgeLock => 'VERROU AE/AF';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'TORCHE';

  @override
  String get webcamFacingFront => 'Avant';

  @override
  String get webcamFacingBack => 'Arrière';

  @override
  String get webcamTorch => 'Torche';

  @override
  String get webcamPortrait => 'Portrait';

  @override
  String get webcamLandscape => 'Paysage';

  @override
  String get webcamLocked => 'Verrouillé';

  @override
  String get webcamLock => 'Verrouiller';

  @override
  String get webcamTabLight => 'Lumière';

  @override
  String get webcamTabFocus => 'Mise au point';

  @override
  String get webcamTabColor => 'Couleur';

  @override
  String get webcamTabStream => 'Flux';

  @override
  String get webcamBrightness => 'Luminosité';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto => 'Cette caméra règle l’exposition elle-même.';

  @override
  String get webcamLockExposure => 'Verrouiller l’exposition';

  @override
  String get webcamLockExposureDetail =>
      'Garde la luminosité actuelle. Maintenez l’image pour verrouiller sur un point.';

  @override
  String get webcamFocus => 'Mise au point';

  @override
  String get webcamFocusFixed => 'Cette caméra a une mise au point fixe.';

  @override
  String get webcamFocusSpotDetail =>
      'Fixée là où vous avez touché. Touchez deux fois l’image pour revenir en auto.';

  @override
  String get webcamFocusManualDetail => 'Réglée à la main ci-dessous.';

  @override
  String get webcamFocusAutoDetail =>
      'Suit l’image. Touchez-la pour faire la mise au point sur un point.';

  @override
  String get webcamFocusAuto => 'Auto';

  @override
  String get webcamFocusSpot => 'Point';

  @override
  String get webcamFocusManual => 'Manuelle';

  @override
  String get webcamDistance => 'Distance';

  @override
  String get webcamFar => 'Loin';

  @override
  String get webcamNear => 'Près';

  @override
  String get webcamWbAuto => 'Auto';

  @override
  String get webcamWbDaylight => 'Lumière du jour';

  @override
  String get webcamWbCloudy => 'Nuageux';

  @override
  String get webcamWbShade => 'Ombre';

  @override
  String get webcamWbIncandescent => 'Lumière chaude';

  @override
  String get webcamWbFluorescent => 'Lumière de bureau';

  @override
  String get webcamWhiteBalance => 'Balance des blancs';

  @override
  String get webcamLockColors => 'Verrouiller les couleurs';

  @override
  String get webcamLockColorsDetail =>
      'Empêche les couleurs de varier quand la lumière change.';

  @override
  String get webcamOrientation => 'Orientation';

  @override
  String get webcamOrientationPortraitDetail =>
      'Tenez le téléphone droit ; bandes sur les côtés.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Tenez le téléphone à l’horizontale ; l’image remplit le cadre.';

  @override
  String get webcamFrameRate => 'Fréquence d’images';

  @override
  String get webcamFps60Detail =>
      'Mouvements plus fluides ; consomme plus de données et de batterie.';

  @override
  String get webcamFps30Detail => 'Stable pour les appels vidéo.';

  @override
  String get webcamFpsOnly30 => 'Cette caméra va jusqu’à 30 fps.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Résolution';

  @override
  String get webcamResolution1080Detail =>
      'Full HD, pour un grand écran ; plus de données.';

  @override
  String get webcamResolution720Detail => 'HD, idéal pour les appels vidéo.';

  @override
  String get webcamResolutionOnly720 => 'Cette caméra diffuse en 720p.';

  @override
  String get webcamQuality => 'Qualité';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, pour un Wi-Fi chargé.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, le plus de détails.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, net pour les appels vidéo.';
  }

  @override
  String get webcamQualitySaver => 'Économie';

  @override
  String get webcamQualityStandard => 'Standard';

  @override
  String get webcamQualityHigh => 'Élevée';

  @override
  String get webcamStabilization => 'Stabilisation';

  @override
  String get webcamStabilizationDetail =>
      'Atténue les tremblements de la main.';

  @override
  String get webcamMirror => 'Inverser l’aperçu';

  @override
  String get webcamMirrorDetail =>
      'Sur ce téléphone seulement ; l’ordinateur reçoit l’image non inversée.';

  @override
  String get webcamFormat => 'Format';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Réinitialiser';

  @override
  String webcamResetSetting(String setting) {
    return 'Réinitialiser $setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name veut voir votre écran';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Tout ce qui s’affiche sur l’écran de ce téléphone apparaît sur $name jusqu’à ce que vous arrêtiez. Android vous demandera ensuite de confirmer.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name veut contrôler votre écran';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '$name voit l’écran de ce téléphone et peut toucher, balayer et taper dessus jusqu’à ce que vous arrêtiez. Android vous demandera ensuite de confirmer.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name veut utiliser votre caméra';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '$name utilise la caméra de ce téléphone comme webcam jusqu’à ce que vous arrêtiez. Zoom, mise au point, lumière, objectifs et rotation se règlent dans Linksy pendant ce temps.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name veut utiliser ce téléphone comme pavé tactile';
  }

  @override
  String get sharingInputRequestDetail =>
      'Inattendu : les ordinateurs ne demandent pas cela. Ne l’autorisez pas.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name veut utiliser votre micro';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '$name entend le micro de ce téléphone jusqu’à ce que vous arrêtiez, comme un micro que toutes ses apps peuvent utiliser. Android vous demandera ensuite de confirmer.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name veut utiliser cet écran comme second écran';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'Ce téléphone affiche un écran de $name en plein écran. Touchez pour cliquer et glisser ; faites défiler à deux doigts. Revenez en arrière pour arrêter.';
  }

  @override
  String get sharingAllow => 'Autoriser';

  @override
  String get sharingDontAllow => 'Ne pas autoriser';

  @override
  String get sharingProtectionHint =>
      'Barre du haut ou notifications en noir sur l’ordinateur ? La protection du partage d’écran d’Android les masque. Activez « Désactiver les protections du partage d’écran » dans les Options pour les développeurs, puis partagez à nouveau.';

  @override
  String get sharingGotIt => 'Compris';

  @override
  String get sharingDeveloperOptions => 'Options pour les développeurs';

  @override
  String sharingControlling(String name) {
    return '$name contrôle votre écran';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name utilise votre caméra';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name utilise votre micro';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Partage de votre écran avec $name';
  }

  @override
  String get sharingTapForCameraControls =>
      'Touchez pour les réglages de la caméra';

  @override
  String get sharingSwitchCamera => 'Changer de caméra';

  @override
  String get sharingStopSharing => 'Arrêter le partage';

  @override
  String get sharingStop => 'Arrêter';

  @override
  String get sharingCameraControls => 'Réglages de la caméra';

  @override
  String displaySecondHint(String name) {
    return 'Second écran de $name · revenez en arrière pour arrêter';
  }

  @override
  String displayControlHint(String name) {
    return 'Écran de $name · touchez pour cliquer · revenez en arrière pour arrêter';
  }

  @override
  String displayWatchHint(String name) {
    return 'Écran de $name · revenez en arrière pour arrêter';
  }

  @override
  String terminalTabClosed(String title) {
    return '« $title » fermé';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '« $title » s’est terminé sur $name';
  }

  @override
  String get terminalCloseTitle => 'Fermer ce terminal ?';

  @override
  String terminalCloseDetail(String name) {
    return 'Le shell se termine sur $name, avec tout ce qui y tourne encore. Pour y revenir plus tard, laissez-le plutôt tourner.';
  }

  @override
  String get terminalKeepRunning => 'Laisser tourner';

  @override
  String get terminalClose => 'Fermer';

  @override
  String get terminalTheComputer => 'l’ordinateur';

  @override
  String get terminalDetached => 'Détaché';

  @override
  String terminalDetachedDetail(String name) {
    return 'Toujours actif sur $name. Rattachez-le pour le revoir ; le code sera redemandé.';
  }

  @override
  String get terminalReattach => 'Rattacher';

  @override
  String terminalOn(String name) {
    return 'Terminal sur $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Détaché · toujours actif sur $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Ouverture sur $name…';
  }

  @override
  String get terminalWaitingForCode => 'En attente du code';

  @override
  String get terminalEnded => 'Terminé';

  @override
  String get terminalBack => 'Retour';

  @override
  String get terminalTitle => 'Terminal';

  @override
  String get terminalMenu => 'Menu du terminal';

  @override
  String get terminalDetachMenu => 'Le laisser tourner (détacher)';

  @override
  String terminalCloseTab(String title) {
    return 'Fermer $title';
  }

  @override
  String get terminalNew => 'Nouveau terminal';

  @override
  String terminalShellOn(String name) {
    return 'Un shell sur $name';
  }

  @override
  String get terminalShellDetail =>
      'S’exécute sous votre compte sur l’ordinateur, dans votre dossier personnel. À chaque ouverture, il demande le code du terminal défini sur l’ordinateur.';

  @override
  String get terminalStillRunning => 'TOUJOURS ACTIFS';

  @override
  String terminalReattachTab(String title) {
    return 'Rattacher $title';
  }

  @override
  String terminalStarted(String time) {
    return 'Lancé à $time';
  }

  @override
  String get terminalKeyLeft => 'Gauche';

  @override
  String get terminalKeyUp => 'Haut';

  @override
  String get terminalKeyDown => 'Bas';

  @override
  String get terminalKeyRight => 'Droite';

  @override
  String get terminalCodeTitle => 'Code du terminal';

  @override
  String terminalCodeDetail(String name) {
    return 'Le code défini sur $name dans Préférences › Terminal. Linksy ne le conserve jamais.';
  }

  @override
  String get terminalCodePassphrase => 'Phrase secrète';

  @override
  String get terminalCodeDigitsHint => '6 chiffres ou plus';

  @override
  String get terminalCodeUseDigits => 'Utiliser des chiffres';

  @override
  String get terminalCodeUseLetters => 'Utiliser des lettres';

  @override
  String get terminalOpening => 'Ouverture…';

  @override
  String get terminalOpen => 'Ouvrir le terminal';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String usbConnectedTo(String name) {
    return 'Connecté à $name par câble USB';
  }

  @override
  String get usbPairTitle => 'Un ordinateur est sur le câble';

  @override
  String get usbPairBody =>
      'Il n’est pas encore associé à ce téléphone. L’associer par le câble ? Les deux écrans affichent un code à comparer.';

  @override
  String get usbPairAction => 'Associer';
}
