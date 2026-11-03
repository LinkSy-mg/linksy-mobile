// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Te damos la bienvenida a Linksy';

  @override
  String get onboardingChooseLanguage => 'Elige tu idioma';

  @override
  String get onboardingLanguageHint => 'Puedes cambiarlo más tarde en Ajustes.';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingSetUpTitle => 'Configura Linksy';

  @override
  String get onboardingSetUpSubtitle =>
      'Elige qué puede hacer Linksy. Nada sale de este teléfono hasta que tú lo digas.';

  @override
  String get onboardingNotifications => 'Notificaciones';

  @override
  String get onboardingNotificationsDetail =>
      'Archivos que llegan, y cuando una computadora usa tu pantalla, cámara o micrófono, con un botón para detenerlo.';

  @override
  String get onboardingCamera => 'Cámara';

  @override
  String get onboardingCameraDetail =>
      'Escanea códigos QR de emparejamiento y permite que una computadora la use como webcam cuando tú lo permitas.';

  @override
  String get onboardingAway => 'Fuera de casa';

  @override
  String get onboardingAwayDetail =>
      'Conéctate a tus computadoras por internet cuando no estés en la misma Wi-Fi. Cifrado de extremo a extremo.';

  @override
  String get onboardingBackground => 'Seguir activo en segundo plano';

  @override
  String get onboardingBackgroundDetail =>
      'Los archivos y las llamadas siguen funcionando cuando Linksy está cerrado. Muestra una notificación discreta.';

  @override
  String get onboardingFolder => 'Compartir una carpeta con computadoras';

  @override
  String get onboardingFolderDetail =>
      'Tus computadoras pueden abrir una carpeta que elijas en su app de Archivos.';

  @override
  String get onboardingPhotos => 'Carpeta de copia de fotos';

  @override
  String get onboardingPhotosDetail =>
      'Elige la carpeta de tu cámara para copiar las fotos nuevas en una computadora. Se activa en cada computadora.';

  @override
  String get onboardingLocate =>
      'Permitir que las computadoras ubiquen este teléfono';

  @override
  String get onboardingLocateDetail =>
      'Una computadora puede preguntar dónde está este teléfono, una vez. No se guarda nada.';

  @override
  String get onboardingAllow => 'Permitir';

  @override
  String get onboardingAllowed => 'Permitido';

  @override
  String get onboardingChooseFolder => 'Elegir';

  @override
  String onboardingFolderChosen(String folder) {
    return '“$folder”';
  }

  @override
  String get onboardingAnytime =>
      'Puedes activar o desactivar cualquiera de estas opciones cuando quieras en Ajustes.';

  @override
  String get onboardingStart => 'Empezar a usar Linksy';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageDone => 'Listo';

  @override
  String get ctlClipboardFileTooBig =>
      'Solo cabe en el portapapeles un archivo de hasta 10 MB.';

  @override
  String get ctlClipboardCopyFailed => 'No se pudo poner en el portapapeles';

  @override
  String get ctlLocateOff =>
      'La ubicación está desactivada en Linksy en este teléfono';

  @override
  String get ctlYourComputer => 'tu computadora';

  @override
  String get ctlAnd => 'y';

  @override
  String ctlKeepingLocked(String names) {
    return 'Bloqueo de $names al irte';
  }

  @override
  String get ctlStayingConnected => 'Conectado a tus computadoras';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name quiere enviarte $count archivos',
      one: '$name quiere enviarte un archivo',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'El portapapeles está vacío.';

  @override
  String get ctlClipboardTooMuch =>
      'El portapapeles tiene demasiado texto para enviarlo.';

  @override
  String get ctlPing => 'Ping';

  @override
  String ctlPingFrom(String name) {
    return 'De $name';
  }

  @override
  String get ctlTextTooMuch => 'Es demasiado texto para enviarlo.';

  @override
  String get ctlDeclined => 'Rechazado';

  @override
  String get ctlScreenPermission =>
      'Para compartir la pantalla se necesita el permiso de Android para capturarla.';

  @override
  String get ctlCameraPermission =>
      'Linksy necesita el permiso de cámara para funcionar como webcam.';

  @override
  String get ctlMicrophonePermission =>
      'Linksy necesita el permiso de micrófono para funcionar como micrófono.';

  @override
  String get ctlTerminalTitle => 'Terminal';

  @override
  String get errorThatDevice => 'Ese dispositivo';

  @override
  String get errorOtherDevice => 'El otro dispositivo';

  @override
  String get errorComputerOnCable => 'La computadora del cable';

  @override
  String errorDeviceAt(String address) {
    return 'El dispositivo en $address';
  }

  @override
  String errorUnreachable(String name) {
    return 'No se puede conectar con $name. Comprueba que esté encendido y en esta red.';
  }

  @override
  String errorDeclined(String name) {
    return '$name lo rechazó.';
  }

  @override
  String errorTimeout(String name) {
    return '$name no respondió a tiempo.';
  }

  @override
  String errorNotPaired(String name) {
    return '$name ya no está emparejado. Vuelve a emparejarlo para compartir.';
  }

  @override
  String errorUnsupported(String name) {
    return '$name todavía no puede hacer eso.';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name solo lo permite en la misma red. Su dueño puede permitir todo desde fuera para este teléfono.';
  }

  @override
  String get errorInvalid => 'Eso no funcionó.';

  @override
  String get errorSomethingWrong => 'Algo salió mal.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Algo salió mal: $detail';
  }

  @override
  String get terminalRefusedComputer => 'La computadora';

  @override
  String get terminalRefusedCode => 'Código incorrecto.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Código incorrecto, quedan $count intentos.',
      one: 'Código incorrecto, queda 1 intento.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Demasiados códigos incorrectos. Desbloquea la terminal en $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'En $name, abre la página de este teléfono y permite allí la terminal.';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name solo permite una terminal en la misma red, a menos que allí esté activado “Permitir todo desde fuera”.';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name no puede abrir una terminal.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return 'Ya hay 8 terminales abiertas en $name para este teléfono. Cierra una primero.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name no lo permitió.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$kind $os';
  }

  @override
  String get modelKindDesktop => 'Computadora de escritorio';

  @override
  String get modelKindLaptop => 'Portátil';

  @override
  String get modelKindPhone => 'Teléfono';

  @override
  String get modelKindTablet => 'Tableta';

  @override
  String get modelOsUnknown => 'desconocido';

  @override
  String get deviceNothingOfKind => 'Todavía no hay nada de este tipo.';

  @override
  String deviceBattery(int level) {
    return '$level %';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level %, cargando';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Accesible desde fuera hasta el $day';
  }

  @override
  String get deviceLocksWhenLeave =>
      'Se bloquea cuando te vas con este teléfono';

  @override
  String get deviceBack => 'Atrás';

  @override
  String get deviceMore => 'Más';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Cambiar imagen';

  @override
  String get deviceAddPicture => 'Añadir una imagen';

  @override
  String get deviceRemovePicture => 'Quitar imagen';

  @override
  String get deviceForgetThis => 'Olvidar este dispositivo';

  @override
  String deviceForgetTitle(String name) {
    return '¿Olvidar $name?';
  }

  @override
  String get deviceForgetBody =>
      'Tendrás que volver a emparejarlo para compartir con él. También se borra su actividad en este teléfono.';

  @override
  String get deviceForget => 'Olvidar';

  @override
  String get deviceCancel => 'Cancelar';

  @override
  String get deviceSendFiles => 'Enviar archivos';

  @override
  String get deviceSendFilesCaption => 'Fotos, documentos, lo que sea';

  @override
  String get deviceClipboard => 'Portapapeles';

  @override
  String get deviceClipboardCaption => 'Envía lo que copiaste';

  @override
  String get devicePing => 'Ping';

  @override
  String get devicePingCaption => 'Haz que suene';

  @override
  String get deviceRemote => 'Control remoto';

  @override
  String get deviceRemoteCaption => 'Touchpad y diapositivas';

  @override
  String get deviceRinging => 'Sonando…';

  @override
  String get deviceFindIt => 'Encontrarlo';

  @override
  String get deviceTapToStop => 'Toca para detener';

  @override
  String get deviceFindItCaption => 'Haz que suene fuerte';

  @override
  String get devicePrevious => 'Anterior';

  @override
  String get devicePause => 'Pausar';

  @override
  String get devicePlay => 'Reproducir';

  @override
  String get deviceNext => 'Siguiente';

  @override
  String deviceAllowOn(String name) {
    return 'Permítelo en $name…';
  }

  @override
  String get deviceSeeScreen => 'Ver su pantalla';

  @override
  String get deviceSeeScreenCaption => 'Mírala aquí o contrólala con el tacto';

  @override
  String get deviceWatch => 'Ver';

  @override
  String get deviceControl => 'Controlar';

  @override
  String get deviceTerminal => 'Terminal';

  @override
  String deviceTerminalShell(String name) {
    return 'Una shell en $name, protegida por su código';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terminales abiertas',
      one: '1 terminal abierta',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'Todo';

  @override
  String get deviceFilterFiles => 'Archivos';

  @override
  String get deviceFilterClipboard => 'Portapapeles';

  @override
  String get deviceFilterLinks => 'Enlaces';

  @override
  String get deviceFilterShowAll => 'Mostrar todo';

  @override
  String get deviceFilterShowFiles => 'Mostrar archivos';

  @override
  String get deviceFilterShowClipboard => 'Mostrar portapapeles';

  @override
  String get deviceFilterShowLinks => 'Mostrar enlaces';

  @override
  String get deviceActivity => 'Actividad';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Listo cuando $name lo pida';
  }

  @override
  String get deviceWebcam => 'Webcam';

  @override
  String get deviceInUseNow => 'En uso ahora';

  @override
  String get deviceControls => 'Controles';

  @override
  String get deviceMicrophone => 'Micrófono';

  @override
  String get deviceStop => 'Detener';

  @override
  String get deviceSecondDisplay => 'Segunda pantalla';

  @override
  String get deviceShowingNow => 'Mostrando ahora';

  @override
  String deviceReadySize(int width, int height) {
    return 'Lista · $width × $height';
  }

  @override
  String get devicePhoneAs => 'Este teléfono como';

  @override
  String deviceStartedOn(String name) {
    return 'Se inicia en $name';
  }

  @override
  String get deviceFasterOverUsb => 'Más rápido y estable con un cable USB.';

  @override
  String get deviceBackUpPhotos => 'Copiar fotos';

  @override
  String devicePhotosGoTo(String name) {
    return 'Las fotos nuevas van a la carpeta Imágenes de $name';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name no acepta fotos. Activa allí “Importar fotos de teléfonos”.';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'Desde $folder';
  }

  @override
  String get devicePhotosFromCamera => 'Desde la carpeta de tu cámara';

  @override
  String devicePhotosLast(String time) {
    return 'última: $time';
  }

  @override
  String get deviceGetClipboard => 'Recibir su portapapeles';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'El texto copiado en $name llega aquí mientras estén conectados';
  }

  @override
  String get deviceAwayAll => 'Permitir todo desde fuera';

  @override
  String get deviceAwayAllOn =>
      'También desde fuera: esta pantalla, webcam, micrófono y archivos';

  @override
  String get deviceAwayAllOff =>
      'Desde fuera: solo portapapeles, enlaces, archivos y timbre';

  @override
  String get deviceNothingShared => 'Todavía no se ha compartido nada';

  @override
  String deviceNothingSharedBody(String name) {
    return 'Los archivos, el texto del portapapeles y los pings entre este teléfono y $name aparecen aquí.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '“$text”';
  }

  @override
  String get activityClipboardText => 'Texto del portapapeles';

  @override
  String get activityPing => 'Ping';

  @override
  String get activityYourScreen => 'Tu pantalla';

  @override
  String get activityYourCamera => 'Tu cámara';

  @override
  String get activitySecondDisplay => 'Segunda pantalla';

  @override
  String get activityLink => 'Enlace';

  @override
  String get activityRangThisPhone => 'Hizo sonar este teléfono';

  @override
  String get activityRangIt => 'Lo hiciste sonar';

  @override
  String get activityTouchpadKeyboard => 'Touchpad y teclado';

  @override
  String get activityItsScreen => 'Su pantalla';

  @override
  String get activityYourMicrophone => 'Tu micrófono';

  @override
  String get activityWhereThisPhone => 'Dónde está este teléfono';

  @override
  String get activityWatchingNow => 'Viéndola ahora';

  @override
  String get activityWatched => 'Vista';

  @override
  String get activityInUseWebcam => 'En uso como webcam';

  @override
  String get activityUsedWebcam => 'Usada como webcam';

  @override
  String get activityBeingControlled => 'Controlada ahora';

  @override
  String get activityWatchedControlled => 'Vista y controlada';

  @override
  String get activityWatchedFromPhone => 'Vista desde este teléfono';

  @override
  String get activityInUseNow => 'En uso ahora';

  @override
  String get activityWasTouchpad => 'Este teléfono fue su touchpad';

  @override
  String get activityWasSecondDisplay =>
      'Este teléfono fue su segunda pantalla';

  @override
  String get activityLinkReceived => 'Enlace recibido';

  @override
  String get activityOpenedOnComputer => 'Abierto en la computadora';

  @override
  String get activityInUseMicrophone => 'En uso como micrófono';

  @override
  String get activityUsedMicrophone => 'Usado como micrófono';

  @override
  String get activityNotTold => 'No se le dijo';

  @override
  String get activityToldWhere => 'Se le dijo dónde está este teléfono';

  @override
  String get activityAskedToFind => 'Pidió encontrar este teléfono';

  @override
  String get activityToFindIt => 'Para encontrarlo';

  @override
  String get activityDeclined => 'Rechazado';

  @override
  String get activityFailed => 'Falló';

  @override
  String get activityInProgress => 'En curso';

  @override
  String get activityCopiedHere => 'Copiado aquí';

  @override
  String get activityReceived => 'Recibido';

  @override
  String get activitySent => 'Enviado';

  @override
  String get activityStop => 'Detener';

  @override
  String get activityCancel => 'Cancelar';

  @override
  String get activityCopyAgain => 'Copiar de nuevo';

  @override
  String get activityCopied => 'Copiado';

  @override
  String get activityCopyLink => 'Copiar enlace';

  @override
  String get activityLinkCopied => 'Enlace copiado';

  @override
  String get activityNoAppForLink => 'Ninguna app de aquí abre ese enlace.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: '1 archivo',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name ya no está ahí.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'Ninguna app de este teléfono abre $name.';
  }

  @override
  String get activityWaitingForYou => 'Esperando a que aceptes…';

  @override
  String get activityWaitingForDevice =>
      'Esperando a que el dispositivo acepte…';

  @override
  String activityWaitingFor(String name) {
    return 'Esperando a que $name acepte…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done de $total';
  }

  @override
  String get homeSettings => 'Ajustes';

  @override
  String get homeYourDevices => 'Tus dispositivos';

  @override
  String get homeNearbyNotPaired => 'Cerca, sin emparejar';

  @override
  String get homeAddDevice => 'Añadir un dispositivo';

  @override
  String homeVisible(String name) {
    return '$name es visible en esta Wi-Fi';
  }

  @override
  String get homeUpdateTitle => 'Actualiza Linksy para seguir conectándote';

  @override
  String get homeUpdateBody =>
      'Tus computadoras ya usan una versión de Linksy más nueva que esta app.';

  @override
  String get homeGetUpdate => 'Obtener la actualización';

  @override
  String get homeSendFiles => 'Enviar archivos';

  @override
  String get homePair => 'Emparejar';

  @override
  String get homeStepOpen => 'Abre Linksy en tu computadora';

  @override
  String get homeStepChoose => 'Elige “Añadir dispositivo”';

  @override
  String get homeStepScan => 'Escanéalo con este teléfono';

  @override
  String get homeConnectTitle => 'Conecta tu\nprimer dispositivo';

  @override
  String get homeConnectSubtitle =>
      'Directo por tu Wi-Fi. Sin cuenta, sin nube.';

  @override
  String get homeScanQr => 'Escanear código QR';

  @override
  String get homePairByAddress => 'Emparejar por dirección';

  @override
  String get pairingAddDevice => 'Añadir un dispositivo';

  @override
  String get pairingAddDeviceHint =>
      'En el otro dispositivo, abre Linksy y elige “Añadir dispositivo”.';

  @override
  String get pairingScanQr => 'Escanear código QR';

  @override
  String get pairingScanQrCaption => 'Lo más rápido. Sin escribir nada.';

  @override
  String get pairingByAddress => 'Emparejar por dirección';

  @override
  String get pairingByAddressCaption =>
      'Cuando no se encuentra el otro dispositivo.';

  @override
  String pairingWith(String name) {
    return 'Emparejando con $name…';
  }

  @override
  String get pairingWithOtherDevice => 'Emparejando con el otro dispositivo…';

  @override
  String get pairingAddressHint =>
      'Está en las Preferencias de Linksy en el otro dispositivo.';

  @override
  String pairingPortHint(String port) {
    return 'Puerto $port, salvo que indiques otro.';
  }

  @override
  String get pairingPair => 'Emparejar';

  @override
  String pairingWantsToPair(String name) {
    return '$name quiere emparejarse';
  }

  @override
  String pairingPairWith(String name) {
    return 'Emparejar con $name';
  }

  @override
  String get pairingCodeHint => 'Ambas pantallas deberían mostrar este código.';

  @override
  String pairingCodeLabel(String code) {
    return 'Código $code';
  }

  @override
  String get pairingCodesMatch => 'Los códigos coinciden';

  @override
  String get scanNeedsCamera =>
      'Linksy necesita la cámara para escanear el código de emparejamiento. Permítela o empareja por dirección.';

  @override
  String get scanCameraUnavailable => 'La cámara no está disponible.';

  @override
  String get scanFlashlight => 'Linterna';

  @override
  String get scanTitle => 'Escanea el código';

  @override
  String get scanWrongCode =>
      'Ese no es un código de Linksy. En tu computadora, abre Linksy → Emparejar con código QR.';

  @override
  String get scanHint =>
      'En tu computadora, abre Linksy y elige “Añadir dispositivo”.';

  @override
  String get shareSheetPutOnClipboard => 'Poner en un portapapeles';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviar $count archivos',
      one: 'Enviar un archivo',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Abrir en una computadora';

  @override
  String get shareSheetSendToClipboard => 'Enviar a un portapapeles';

  @override
  String get shareSheetNoClipboardFiles =>
      'Ninguna de tus computadoras acepta todavía archivos en su portapapeles. Actualiza Linksy en ellas.';

  @override
  String get shareSheetNoComputers =>
      'Primero empareja una computadora y luego comparte con ella desde cualquier app.';

  @override
  String get shareSheetSendFileInstead => 'Mejor enviar el archivo';

  @override
  String get shareSheetClipboardInstead =>
      'Mejor ponerlo en el portapapeles de la computadora';

  @override
  String get shareSheetOpenLinkInstead => 'Mejor abrir el enlace';

  @override
  String get shareSheetSendAsTextInstead =>
      'Mejor enviarlo como texto al portapapeles';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Poniéndolo en el portapapeles de $name';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Poniéndolo en el portapapeles de la computadora';

  @override
  String shareSheetOpened(String name) {
    return 'Abierto en $name';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Abierto en la computadora';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'Enviado al portapapeles de $name';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'Enviado al portapapeles de la computadora';

  @override
  String shareSheetSentALink(String name) {
    return '$name envió un enlace';
  }

  @override
  String get shareSheetOpen => 'Abrir';

  @override
  String get shareSheetCopyLink => 'Copiar enlace';

  @override
  String get shareSheetLinkCopied => 'Enlace copiado';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos',
      one: 'un archivo',
    );
    return '$name te está enviando $_temp0';
  }

  @override
  String incomingTotal(String size) {
    return '$size en total';
  }

  @override
  String incomingMore(int count) {
    return '+ $count más';
  }

  @override
  String get incomingAccept => 'Aceptar';

  @override
  String get appInvalidPairingLink =>
      'Ese enlace de emparejamiento no es válido.';

  @override
  String appPairingFailed(String reason) {
    return 'Falló el emparejamiento: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'No se pudo emparejar con $name: $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Emparejado con $name';
  }

  @override
  String appNotification(String name, String text) {
    return '$name: $text';
  }

  @override
  String appCopiedText(String name) {
    return 'Texto copiado de $name';
  }

  @override
  String appCopiedFile(String file, String name) {
    return '$file copiado de $name';
  }

  @override
  String get appCouldntStart => 'Linksy no pudo iniciarse';

  @override
  String get commonDismiss => 'Descartar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDecline => 'Rechazar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonNotNow => 'Ahora no';

  @override
  String get commonConnected => 'Conectado';

  @override
  String get commonNearby => 'Cerca';

  @override
  String get commonNotNearby => 'No está cerca';

  @override
  String get commonUsbCable => 'Cable USB';

  @override
  String get commonAwayFromHome => 'Fuera de casa';

  @override
  String get commonSameWifi => 'Misma Wi-Fi';

  @override
  String get commonConnectedByUsb => 'Conectado por USB';

  @override
  String get commonConnectedAway => 'Conectado fuera de casa';

  @override
  String commonBattery(int level) {
    return 'Batería al $level por ciento';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Batería al $level por ciento, cargando';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bytes',
      one: '1 byte',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count segundos',
      one: 'Queda 1 segundo',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count minutos',
      one: 'Queda 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan aprox. $count horas',
      one: 'Queda aprox. 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Hoy';

  @override
  String get formatYesterday => 'Ayer';

  @override
  String get formatPhone => 'Teléfono';

  @override
  String get settingsBack => 'Atrás';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSearch => 'Buscar en ajustes';

  @override
  String settingsNothingMatches(String query) {
    return 'Nada coincide con «$query»';
  }

  @override
  String get settingsRecommended => 'Recomendado';

  @override
  String get settingsReceiving => 'Recepción';

  @override
  String get settingsFiles => 'Archivos';

  @override
  String get settingsSaveLocation => 'Ubicación de guardado';

  @override
  String get settingsSaveLocationPath => 'Descargas › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Aceptar de mis dispositivos';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'Los archivos de dispositivos emparejados llegan sin preguntar.';

  @override
  String get settingsConnection => 'Conexión';

  @override
  String get settingsWays => 'Cómo llega a tus ordenadores';

  @override
  String get settingsStayConnected => 'Mantenerse conectado';

  @override
  String get settingsStayConnectedCaption =>
      'Comparte más rápido con dispositivos cercanos. Usa más batería.';

  @override
  String get settingsKeepRunning => 'Seguir activo en segundo plano';

  @override
  String get settingsKeepRunningCaption =>
      'Los archivos, la copia de fotos y las llamadas siguen funcionando cuando Linksy está cerrado. Muestra una notificación discreta.';

  @override
  String get settingsAwayFromHome => 'Fuera de casa';

  @override
  String get settingsAwayFromHomeCaption =>
      'Conéctate a tus computadoras por internet cuando no estés en la misma red, durante una semana desde la última vez que lo estuviste. Cifrado de extremo a extremo.';

  @override
  String get settingsRelay => 'Servidor de relé';

  @override
  String get settingsRelayDefault => 'El de Linksy';

  @override
  String get settingsRelayCaption =>
      'La dirección de un relé alojado por ti, como https://relay.example.com. Déjalo vacío para usar el de Linksy. Configura el mismo relé en todos los dispositivos.';

  @override
  String get settingsWithYourComputers => 'Con tus computadoras';

  @override
  String get settingsPauseMusic => 'Pausar la música en llamadas';

  @override
  String get settingsPauseMusicCaption =>
      'Tus computadoras pausan lo que suena mientras una llamada entra o está en curso, y lo reanudan después.';

  @override
  String get settingsBrowseFiles =>
      'Permitir que las computadoras exploren archivos';

  @override
  String get settingsFilesFolder => 'Una carpeta que elijas';

  @override
  String get settingsFilesAll => 'Todos los archivos';

  @override
  String get settingsFilesAllCaption =>
      'Tus ordenadores pueden abrir cualquier archivo de este teléfono.';

  @override
  String get settingsFilesAllAllow =>
      'Permite «Acceso a todos los archivos» para Linksy en los ajustes de Android.';

  @override
  String get settingsBrowseFilesChoose =>
      'Elige una carpeta que tus computadoras puedan abrir en su app de Archivos, como Documentos (Android no permite Descargas).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Comparte “$folder”. Toca para elegir otra carpeta.';
  }

  @override
  String get settingsPicture => 'Imagen de este teléfono';

  @override
  String get settingsPictureChoose =>
      'Tus computadoras la muestran para este teléfono. Toca para elegir una.';

  @override
  String get settingsPictureChange =>
      'Tus computadoras la muestran para este teléfono. Toca para cambiarla.';

  @override
  String get settingsPictureRemove => 'Quitar';

  @override
  String get settingsLocate =>
      'Permitir que las computadoras ubiquen este teléfono';

  @override
  String get settingsLocateCaption =>
      'Una computadora puede preguntar dónde está este teléfono, una vez, para encontrarlo. No se guarda ni se rastrea nada. Funciona mientras Linksy está abierto.';

  @override
  String get settingsLocatePermission =>
      'Linksy necesita el permiso de ubicación para esto.';

  @override
  String get settingsPhotoFolder => 'Carpeta de fotos';

  @override
  String get settingsPhotoFolderChoose =>
      'Elige la carpeta de tu cámara (DCIM › Camera) para copiar fotos en una computadora.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Copia “$folder”. Actívalo en cada computadora, en su página.';
  }

  @override
  String get settingsThisApp => 'Esta app';

  @override
  String get settingsPermissions => 'Permisos';

  @override
  String get settingsDemo => 'Demo';

  @override
  String get settingsDemoCaption =>
      'Dispositivos simulados hasta que se conecte el núcleo de Linksy. Inician lo que haría otro dispositivo.';

  @override
  String get settingsDemoReceiveFiles => 'Recibir archivos';

  @override
  String get settingsDemoReceivePairing =>
      'Recibir una solicitud de emparejamiento';

  @override
  String get settingsDemoReceiveClipboard => 'Recibir texto del portapapeles';

  @override
  String get settingsTagline =>
      'Tus dispositivos, conectados.\nSin cuenta, sin nube.';

  @override
  String get settingsNameTitle => 'Ponle nombre a este teléfono';

  @override
  String get settingsNameCaption => 'Tus otros dispositivos ven este nombre.';

  @override
  String get settingsSave => 'Guardar';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String settingsRename(String name) {
    return 'Cambiar el nombre de $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'Este teléfono · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Notificaciones y cámara';

  @override
  String get settingsPermissionsWhat =>
      'Lo que Linksy le pide a Android, y por qué.';

  @override
  String get settingsPermissionsBoth => 'Ambos permitidos.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de 2 permitidos. Toca para permitir el resto.',
      one: '1 de 2 permitido. Toca para permitir el resto.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Permisos';

  @override
  String get permissionsIntro =>
      'Linksy solo pide lo que necesita, y puedes cambiar cualquiera de estos permisos más tarde en Ajustes.';

  @override
  String get permissionsNotifications => 'Notificaciones';

  @override
  String get permissionsNotificationsWhy =>
      'Muestra cuando una computadora ve tu pantalla o usa tu cámara, con un botón para detenerlo.';

  @override
  String get permissionsCamera => 'Cámara';

  @override
  String get permissionsCameraWhy =>
      'Escanea el código QR de emparejamiento y permite que una computadora use este teléfono como webcam cuando tú lo permitas.';

  @override
  String get permissionsAllow => 'Permitir';

  @override
  String get permissionsAllowed => 'Permitido';

  @override
  String get permissionsDone => 'Listo';

  @override
  String get remoteBack => 'Atrás';

  @override
  String get remoteTitle => 'Control remoto';

  @override
  String remoteAllowOn(String name) {
    return 'Permítelo en $name';
  }

  @override
  String remoteAsks(String name) {
    return 'Linksy en $name pregunta si este teléfono puede mover su puntero y escribir.';
  }

  @override
  String get remoteFailed => 'Eso no funcionó';

  @override
  String get remoteStopped => 'El control remoto se detuvo';

  @override
  String remoteEndedBy(String name) {
    return '$name lo terminó.';
  }

  @override
  String get remoteTryAgain => 'Reintentar';

  @override
  String get remoteTouchpad => 'Touchpad';

  @override
  String get remoteSlides => 'Diapositivas';

  @override
  String get remoteTouchpadHint =>
      'Mueve con un dedo, toca para hacer clic\nDesplaza con dos dedos, toca con dos para clic derecho';

  @override
  String get remoteLeftClick => 'Clic izquierdo';

  @override
  String get remoteRightClick => 'Clic derecho';

  @override
  String get remoteKeyboard => 'Teclado';

  @override
  String get remoteNextSlide => 'Diapositiva siguiente';

  @override
  String get remoteNext => 'Siguiente';

  @override
  String get remotePreviousSlide => 'Diapositiva anterior';

  @override
  String get remoteSlideBack => 'Atrás';

  @override
  String get remoteStartShow => 'Iniciar (F5)';

  @override
  String get remoteEndShow => 'Terminar (Esc)';

  @override
  String get remoteVolumeHint =>
      'Bajar volumen: siguiente · Subir volumen: atrás. La pantalla sigue encendida.';

  @override
  String get ringTitle => '¡Aquí estoy!';

  @override
  String ringLookingFor(String name) {
    return '$name está buscando este teléfono.';
  }

  @override
  String get ringFoundIt => 'Lo encontré';

  @override
  String get webcamBack => 'Atrás';

  @override
  String get webcamTitle => 'Webcam';

  @override
  String webcamLiveOn(String name) {
    return 'En vivo en $name';
  }

  @override
  String get webcamStopSemantic => 'Detener la webcam';

  @override
  String get webcamStop => 'Detener';

  @override
  String get webcamBadgeLive => 'EN VIVO';

  @override
  String get webcamBadgeLock => 'BLOQUEO AE/AF';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'LINTERNA';

  @override
  String get webcamFacingFront => 'Frontal';

  @override
  String get webcamFacingBack => 'Trasera';

  @override
  String get webcamTorch => 'Linterna';

  @override
  String get webcamPortrait => 'Vertical';

  @override
  String get webcamLandscape => 'Horizontal';

  @override
  String get webcamLocked => 'Bloqueado';

  @override
  String get webcamLock => 'Bloquear';

  @override
  String get webcamTabLight => 'Luz';

  @override
  String get webcamTabFocus => 'Enfoque';

  @override
  String get webcamTabColor => 'Color';

  @override
  String get webcamTabStream => 'Transmisión';

  @override
  String get webcamBrightness => 'Brillo';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto =>
      'Esta cámara ajusta la exposición por sí sola.';

  @override
  String get webcamLockExposure => 'Bloquear exposición';

  @override
  String get webcamLockExposureDetail =>
      'Mantiene el brillo como está ahora. Mantén pulsada la imagen para fijarlo en un punto.';

  @override
  String get webcamFocus => 'Enfoque';

  @override
  String get webcamFocusFixed => 'Esta cámara tiene enfoque fijo.';

  @override
  String get webcamFocusSpotDetail =>
      'Fijo donde tocaste. Toca dos veces la imagen para volver a automático.';

  @override
  String get webcamFocusManualDetail => 'Se ajusta a mano abajo.';

  @override
  String get webcamFocusAutoDetail =>
      'Sigue la imagen. Tócala para enfocar un punto.';

  @override
  String get webcamFocusAuto => 'Auto';

  @override
  String get webcamFocusSpot => 'Punto';

  @override
  String get webcamFocusManual => 'Manual';

  @override
  String get webcamDistance => 'Distancia';

  @override
  String get webcamFar => 'Lejos';

  @override
  String get webcamNear => 'Cerca';

  @override
  String get webcamWbAuto => 'Auto';

  @override
  String get webcamWbDaylight => 'Luz de día';

  @override
  String get webcamWbCloudy => 'Nublado';

  @override
  String get webcamWbShade => 'Sombra';

  @override
  String get webcamWbIncandescent => 'Luz cálida';

  @override
  String get webcamWbFluorescent => 'Luz de oficina';

  @override
  String get webcamWhiteBalance => 'Balance de blancos';

  @override
  String get webcamLockColors => 'Bloquear colores';

  @override
  String get webcamLockColorsDetail =>
      'Evita que los colores cambien cuando cambia la luz.';

  @override
  String get webcamOrientation => 'Orientación';

  @override
  String get webcamOrientationPortraitDetail =>
      'Una imagen alta con barras a los lados, para las apps que la quieren.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Llena el cuadro y se mantiene derecha, como sea que esté el teléfono.';

  @override
  String get webcamFrameRate => 'Velocidad de fotogramas';

  @override
  String get webcamFps60Detail =>
      'Movimiento más fluido; usa más datos y batería.';

  @override
  String get webcamFps30Detail => 'Estable para videollamadas.';

  @override
  String get webcamFpsOnly30 => 'Esta cámara llega hasta 30 fps.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Resolución';

  @override
  String get webcamResolution1080Detail =>
      'Full HD, para una pantalla grande; más datos.';

  @override
  String get webcamResolution720Detail => 'HD, ideal para videollamadas.';

  @override
  String get webcamResolutionOnly720 => 'Esta cámara transmite en 720p.';

  @override
  String get webcamQuality => 'Calidad';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, para una Wi-Fi saturada.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, el máximo detalle.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, nítido para videollamadas.';
  }

  @override
  String get webcamQualitySaver => 'Ahorro';

  @override
  String get webcamQualityStandard => 'Estándar';

  @override
  String get webcamQualityHigh => 'Alta';

  @override
  String get webcamStabilization => 'Estabilización';

  @override
  String get webcamStabilizationDetail => 'Suaviza el temblor de la mano.';

  @override
  String get webcamMirror => 'Reflejar la vista previa';

  @override
  String get webcamMirrorDetail =>
      'Solo en este teléfono; la computadora la recibe sin reflejar.';

  @override
  String get webcamFormat => 'Formato';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Restablecer';

  @override
  String webcamResetSetting(String setting) {
    return 'Restablecer $setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name quiere ver tu pantalla';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Todo lo que hay en la pantalla de este teléfono se muestra en $name hasta que lo detengas. Después, Android te pedirá que lo confirmes.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name quiere controlar tu pantalla';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '$name ve la pantalla de este teléfono y puede tocar, deslizar y escribir en ella hasta que lo detengas. Después, Android te pedirá que lo confirmes.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name quiere usar tu cámara';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '$name recibe la cámara de este teléfono como webcam hasta que lo detengas. El zoom, el enfoque, la luz, las lentes y la rotación están en Linksy mientras funciona.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name quiere usar este teléfono como touchpad';
  }

  @override
  String get sharingInputRequestDetail =>
      'Inesperado: las computadoras no piden esto. No lo permitas.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name quiere usar tu micrófono';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '$name oye el micrófono de este teléfono hasta que lo detengas, como un micrófono que cualquiera de sus apps puede usar. Después, Android te pedirá que lo confirmes.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name quiere usar esta pantalla como segunda pantalla';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'Este teléfono muestra una pantalla de $name a pantalla completa. Tócala para hacer clic y arrastrar; desplázate con dos dedos. Vuelve atrás para detenerlo.';
  }

  @override
  String get sharingAllow => 'Permitir';

  @override
  String get sharingDontAllow => 'No permitir';

  @override
  String get sharingProtectionHint =>
      '¿La barra superior o las notificaciones se ven negras en la computadora? La protección al compartir pantalla de Android las oculta. Activa “Inhabilitar protecciones al compartir pantalla” en Opciones para desarrolladores y vuelve a compartir.';

  @override
  String get sharingGotIt => 'Entendido';

  @override
  String get sharingDeveloperOptions => 'Opciones para desarrolladores';

  @override
  String sharingControlling(String name) {
    return '$name está controlando tu pantalla';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name está usando tu cámara';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name está usando tu micrófono';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Compartiendo tu pantalla con $name';
  }

  @override
  String get sharingTapForCameraControls =>
      'Toca para ver los controles de cámara';

  @override
  String get sharingSwitchCamera => 'Cambiar de cámara';

  @override
  String get sharingStopSharing => 'Dejar de compartir';

  @override
  String get sharingStop => 'Detener';

  @override
  String get sharingCameraControls => 'Controles de cámara';

  @override
  String displaySecondHint(String name) {
    return 'Segunda pantalla de $name · vuelve atrás para detener';
  }

  @override
  String displayControlHint(String name) {
    return 'Pantalla de $name · toca para hacer clic · vuelve atrás para detener';
  }

  @override
  String displayWatchHint(String name) {
    return 'Pantalla de $name · vuelve atrás para detener';
  }

  @override
  String get displayChooseScreen => 'Elegir pantalla';

  @override
  String displayChooseOn(String name) {
    return 'Elige la pantalla en $name…';
  }

  @override
  String terminalTabClosed(String title) {
    return '“$title” cerrada';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '“$title” terminó en $name';
  }

  @override
  String get terminalCloseTitle => '¿Cerrar esta terminal?';

  @override
  String terminalCloseDetail(String name) {
    return 'La shell termina en $name, junto con todo lo que siga ejecutándose en ella. Para volver a ella más tarde, mejor déjala en ejecución.';
  }

  @override
  String get terminalKeepRunning => 'Dejar en ejecución';

  @override
  String get terminalClose => 'Cerrar';

  @override
  String get terminalTheComputer => 'la computadora';

  @override
  String get terminalDetached => 'Desconectada';

  @override
  String terminalDetachedDetail(String name) {
    return 'Sigue en ejecución en $name. Vuelve a conectarte para verla; se pedirá el código de nuevo.';
  }

  @override
  String get terminalReattach => 'Volver a conectar';

  @override
  String terminalOn(String name) {
    return 'Terminal en $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Desconectada · sigue en ejecución en $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Abriendo en $name…';
  }

  @override
  String get terminalWaitingForCode => 'Esperando el código';

  @override
  String get terminalEnded => 'Terminada';

  @override
  String get terminalBack => 'Atrás';

  @override
  String get terminalTitle => 'Terminal';

  @override
  String get terminalMenu => 'Menú de la terminal';

  @override
  String get terminalDetachMenu => 'Dejarla en ejecución (desconectar)';

  @override
  String terminalCloseTab(String title) {
    return 'Cerrar $title';
  }

  @override
  String get terminalNew => 'Nueva terminal';

  @override
  String terminalShellOn(String name) {
    return 'Una shell en $name';
  }

  @override
  String get terminalShellDetail =>
      'Se ejecuta con tu usuario en la computadora, en tu carpeta personal. Cada vez que se abre, pide el código de terminal configurado allí.';

  @override
  String get terminalStillRunning => 'SIGUEN EN EJECUCIÓN';

  @override
  String terminalReattachTab(String title) {
    return 'Volver a conectar $title';
  }

  @override
  String terminalStarted(String time) {
    return 'Iniciada: $time';
  }

  @override
  String get terminalKeyLeft => 'Izquierda';

  @override
  String get terminalKeyUp => 'Arriba';

  @override
  String get terminalKeyDown => 'Abajo';

  @override
  String get terminalKeyRight => 'Derecha';

  @override
  String get terminalCodeTitle => 'Código de terminal';

  @override
  String terminalCodeDetail(String name) {
    return 'El código configurado en $name en Preferencias › Terminal. Linksy nunca lo guarda.';
  }

  @override
  String get terminalCodePassphrase => 'Frase de contraseña';

  @override
  String get terminalCodeDigitsHint => '6 dígitos o más';

  @override
  String get terminalCodeUseDigits => 'Usar números';

  @override
  String get terminalCodeUseLetters => 'Usar letras';

  @override
  String get terminalOpening => 'Abriendo…';

  @override
  String get terminalOpen => 'Abrir terminal';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String usbConnectedTo(String name) {
    return 'Conectado a $name por cable USB';
  }

  @override
  String get usbConnecting => 'Conectando por cable USB…';

  @override
  String get usbPairTitle => 'Hay una computadora en el cable';

  @override
  String get usbPairBody =>
      'Aún no está vinculada con este teléfono. ¿Vincularla por el cable? Ambas pantallas muestran un código para comparar.';

  @override
  String get usbPairAction => 'Vincular';

  @override
  String get sendPhotos => 'Fotos y videos';

  @override
  String get sendPhotosCaption => 'De tu galería, varios a la vez';

  @override
  String get sendFiles => 'Archivos';

  @override
  String get sendFilesCaption => 'Documentos y todo lo demás';

  @override
  String activityPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '$count foto',
    );
    return '$_temp0';
  }

  @override
  String activityVideos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count videos',
      one: '$count video',
    );
    return '$_temp0';
  }

  @override
  String activityPhotosVideos(int count) {
    return '$count fotos y videos';
  }

  @override
  String get transfersTitle => 'Transferencias';

  @override
  String get transfersWaiting => 'Esperando';

  @override
  String transfersFilesDone(int done, int total) {
    return '$done de $total archivos';
  }

  @override
  String transfersTo(String name) {
    return 'A $name';
  }

  @override
  String transfersFrom(String name) {
    return 'De $name';
  }

  @override
  String get transfersAllDone => 'Todo listo';

  @override
  String transfersBubble(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count archivos en camino',
      one: '$count archivo en camino',
    );
    return '$_temp0';
  }

  @override
  String get newsTitle => 'Novedades';

  @override
  String newsHeading(String version) {
    return 'Novedades de Linksy $version';
  }

  @override
  String newsAllChanges(String version) {
    return 'Todos los cambios de la $version';
  }

  @override
  String get newsContinue => 'Continuar';

  @override
  String get newsStar => 'Dar una estrella a Linksy en GitHub';

  @override
  String get newsStarCaption =>
      'Linksy es libre y de código abierto. Una estrella en GitHub ayuda a que otros lo encuentren.';

  @override
  String get news024PrivateTitle => 'Privado en cualquier red';

  @override
  String get news024PrivateBody =>
      'En el wifi de un café o de una oficina, los desconocidos ya no ven el nombre de este teléfono. Tus ordenadores lo siguen encontrando, y Añadir dispositivo lo muestra a uno nuevo.';

  @override
  String get news024UpdateTitle => 'Actualizar con un toque';

  @override
  String get news024UpdateBody =>
      'Cuando sale una versión nueva, Actualizar ahora la descarga y la comprueba, y Android la instala.';

  @override
  String get news024NewsTitle => 'Las novedades, aquí mismo';

  @override
  String get news024NewsBody =>
      'Cada actualización muestra ahora lo que cambió, la primera vez que se abre. También está en Ajustes.';

  @override
  String updateAvailable(String version) {
    return 'Linksy $version está disponible';
  }

  @override
  String updateBody(String current) {
    return 'Tienes la $current. Linksy descarga la actualización y la comprueba, y Android te pide instalarla.';
  }

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get updateLater => 'Más tarde';

  @override
  String updateWhatChanged(String version) {
    return 'Qué cambia en $version';
  }

  @override
  String get updateToInstall => 'Se instalará';

  @override
  String updateDownloading(String percent) {
    return 'Descargando, $percent %';
  }

  @override
  String get updateInstalling => 'Android la está instalando…';

  @override
  String updateNewest(String version) {
    return 'Linksy $version es la versión más reciente.';
  }

  @override
  String get updateCheck => 'Buscar actualizaciones';

  @override
  String get updateFailedNetwork =>
      'La descarga no terminó. Comprueba la conexión e inténtalo de nuevo.';

  @override
  String get updateFailedCheck =>
      'La descarga no coincide con la suma de comprobación de la versión, así que no se instaló.';

  @override
  String get updateAllow =>
      'Permite que Linksy instale apps y vuelve a tocar Actualizar ahora.';

  @override
  String updateFailedInstall(String message) {
    return 'Android no la instaló: $message';
  }

  @override
  String get settingsMediaNotice => 'Música en las notificaciones';

  @override
  String get settingsMediaNoticeCaption =>
      'Lo que suena en tus ordenadores aparece en las notificaciones del teléfono, con sus botones.';

  @override
  String get settingsReverseScroll => 'Desplazamiento invertido';

  @override
  String get settingsReverseScrollCaption =>
      'Dos dedos desplazan al revés, en el touchpad y en la pantalla de un ordenador.';

  @override
  String get remoteNumbers => 'Números';

  @override
  String get remoteBackspace => 'Borrar';

  @override
  String get remoteEnter => 'Intro';

  @override
  String get deviceBack10 => '10 segundos atrás';

  @override
  String get deviceForward10 => '10 segundos adelante';

  @override
  String get news025MediaTitle =>
      'La música de tu ordenador, en las notificaciones';

  @override
  String get news025MediaBody =>
      'Lo que suena aparece en las notificaciones: reproducir, saltar, 10 segundos atrás o adelante y una barra de progreso. También en su página.';

  @override
  String get news025NumbersTitle => 'Números en el mando de presentaciones';

  @override
  String get news025NumbersBody =>
      'Escribe el número de una diapositiva y luego Intro para ir a ella. El teclado también funciona ahí.';

  @override
  String get news025RemoteTitle => 'Un mando más fiable';

  @override
  String get news025RemoteBody =>
      'Las mayúsculas ya no dejan Mayús pulsada en el ordenador, y el desplazamiento con dos dedos puede invertirse (Ajustes).';

  @override
  String get deviceMute => 'Silenciar';

  @override
  String get deviceUnmute => 'Activar sonido';

  @override
  String deviceVolume(String percent) {
    return 'Volumen $percent %';
  }

  @override
  String get news026VolumeTitle => 'El volumen del ordenador';

  @override
  String get news026VolumeBody =>
      'Súbelo o bájalo desde su página, o con las teclas de volumen de este teléfono mientras la página está abierta.';

  @override
  String get transfersNone => 'Nada en camino';

  @override
  String get transfersNoneBody =>
      'Los archivos que envías o recibes aparecen aquí, con su velocidad.';

  @override
  String get transfersRecent => 'Recientes';

  @override
  String transfersFastMovie(int seconds) {
    return 'Una película de 1 GB cada $seconds s';
  }

  @override
  String transfersFastPhotos(int count) {
    return 'Unas $count fotos por segundo';
  }

  @override
  String transfersFastSongs(int count) {
    return '$count canciones por segundo';
  }

  @override
  String get news026TransfersTitle => 'Transferencias, siempre a un toque';

  @override
  String get news026TransfersBody =>
      'El botón de abajo a la izquierda abre Transferencias en cualquier momento: archivos fluyendo a su velocidad real, el progreso de cada uno y lo que llegó y salió hace poco.';

  @override
  String get islandSeeMore => 'Ver más';

  @override
  String get transfersRouteDirect => 'Wi-Fi Direct';

  @override
  String get transfersRouteDirectSetup => 'Preparando Wi-Fi Direct';

  @override
  String transfersDirectFinding(String name) {
    return 'Buscando $name';
  }

  @override
  String get transfersDirectConnecting => 'Conectando';

  @override
  String get transfersDirectLinking => 'Enlazando';

  @override
  String get news028DirectTitle => 'Wi-Fi Direct para archivos grandes';

  @override
  String get news028DirectBody =>
      'Los archivos de 256 MB o más van directos a tu computadora por una conexión Wi-Fi propia, mucho más rápido que a través del router. Requiere Linksy 0.9.9 en la computadora.';

  @override
  String get news028BackgroundTitle => 'Archivos grandes, en segundo plano';

  @override
  String get news028BackgroundBody =>
      'Los videos largos empiezan a enviarse al instante y las transferencias siguen con la pantalla apagada, con su progreso en la barra de notificaciones.';

  @override
  String get settingsDirect => 'Wi-Fi Direct para archivos grandes';

  @override
  String get settingsDirectCaption =>
      'Más rápido, directo al otro dispositivo. Desactivado: siempre por tu Wi-Fi.';

  @override
  String get settingsLogs => 'Registros';

  @override
  String get settingsLogsCaption =>
      'Lo que pasó hace poco, para un informe de error';

  @override
  String get logsPrivacy =>
      'Los registros se quedan en este teléfono. No se envía nada: cópialos tú cuando informes de un problema.';

  @override
  String get logsThisPhone => 'Este teléfono';

  @override
  String get logsEvents => 'Lo que pasó';

  @override
  String get logsCopy => 'Copiar';

  @override
  String get logsCopied => 'Copiado';

  @override
  String get logsEmpty =>
      'Nada aún. Aquí aparecen conexiones, transferencias y pasos de Wi-Fi Direct.';

  @override
  String get news029PhonesTitle => 'Wi-Fi Direct entre teléfonos';

  @override
  String get news029PhonesBody =>
      'Los archivos grandes entre dos teléfonos ahora van directos de uno a otro, sin el router. Ambos necesitan Linksy 0.2.9. Puedes desactivarlo en Ajustes.';

  @override
  String get news029LogsTitle => 'Registros';

  @override
  String get news029LogsBody =>
      'Ajustes › Registros muestra este teléfono y lo que pasó hace poco, para copiarlo en un informe de error. Se quedan en este teléfono.';

  @override
  String pairingUpdateOlder(String name) {
    return 'Actualizar Linksy en $name hace el emparejamiento aún más seguro.';
  }

  @override
  String get settingsPhoneNotifications =>
      'Mostrar las notificaciones de este teléfono';

  @override
  String get settingsPhoneNotificationsCaption =>
      'En tus computadoras, con Responder para los mensajes.';

  @override
  String get settingsPhoneNotificationsAllow =>
      'Android aún no lo ha permitido. Toca para permitir el acceso a las notificaciones.';

  @override
  String get noticeAccessTitle => 'Permitir el acceso a las notificaciones';

  @override
  String get noticeAccessGreyed =>
      'Android desactiva este interruptor para las apps instaladas desde la web. Para permitirlo:';

  @override
  String get noticeAccessStepInfo => 'Abre Información de la app de Linksy.';

  @override
  String get noticeAccessStepRestricted =>
      'Toca ⋮ arriba a la derecha y luego Permitir ajustes restringidos.';

  @override
  String get noticeAccessStepAgain =>
      'Vuelve, toca Reintentar y activa Linksy.';

  @override
  String get noticeAccessPlain =>
      'Activa Linksy en Acceso a notificaciones de Android y vuelve.';

  @override
  String get commonOpenAppInfo => 'Abrir Información de la app';

  @override
  String get batteryGuide => 'Mantener Linksy activo';

  @override
  String batteryGuideCaption(String maker) {
    return 'Qué cambiar en este teléfono $maker';
  }

  @override
  String batteryIntro(String maker) {
    return 'Para ahorrar batería, algunos teléfonos cierran las apps en segundo plano, y Linksy pierde archivos y notificaciones. En este teléfono $maker:';
  }

  @override
  String get batteryAutostart =>
      'Información de la app › Inicio automático: activado.';

  @override
  String get batteryXiaomiSaver =>
      'Información de la app › Ahorro de batería: Sin restricciones.';

  @override
  String get batteryLockRecents =>
      'En las apps recientes, mantén pulsado Linksy y toca el candado, para que siga activo al borrarlas.';

  @override
  String get batterySamsungUnrestricted =>
      'Información de la app › Batería: Sin restricciones.';

  @override
  String get batterySamsungSleeping =>
      'Ajustes › Batería › Límites de uso en segundo plano: saca Linksy de las apps inactivas y en suspensión profunda.';

  @override
  String get batteryOppoBackground =>
      'Información de la app › Uso de batería: permite la actividad en segundo plano, en primer plano y el inicio automático.';

  @override
  String get batteryVivoBackground =>
      'Ajustes › Batería › Consumo en segundo plano: permite Linksy.';

  @override
  String get batteryHuaweiLaunch =>
      'Ajustes › Batería › Inicio de apps › Linksy: gestionar manualmente, con Inicio automático, Inicio secundario y Ejecutar en segundo plano activados.';

  @override
  String get batteryUnrestricted =>
      'Información de la app › Uso de batería de la app: Sin restricciones.';

  @override
  String get batteryKeepRunning =>
      'En Linksy: Ajustes › Conexión › Seguir activo en segundo plano.';

  @override
  String get batteryNames =>
      'Los nombres cambian un poco según la versión de Android.';

  @override
  String get updatePlayProtect =>
      'Linksy puede mostrar tus notificaciones en tus computadoras, así que Play Protect puede detener la instalación. Si pasa:';

  @override
  String get updateProtectStep1 => 'Play Store › tu foto › Play Protect › ⚙.';

  @override
  String get updateProtectStep2 => 'Desactiva Analizar apps con Play Protect.';

  @override
  String get updateProtectStep3 =>
      'Vuelve a tocar Actualizar ahora y luego vuelve a activar el análisis.';

  @override
  String get news032NotificationsTitle =>
      'Tus notificaciones en tu computadora';

  @override
  String get news032NotificationsBody =>
      'Los mensajes y demás notificaciones aparecen en tus computadoras emparejadas, con Responder. Actívalo en Ajustes › Con tus computadoras. Si Android desactiva el interruptor: Información de la app › ⋮ › Permitir ajustes restringidos.';

  @override
  String get news032BatteryTitle => 'Mantener Linksy activo';

  @override
  String get news032BatteryBody =>
      'Ajustes › Conexión › Mantener Linksy activo muestra qué cambiar según la marca de tu teléfono para que Linksy siga en segundo plano.';

  @override
  String get settingsReduceMotion => 'Reducir movimiento';

  @override
  String get settingsReduceMotionCaption =>
      'Las pantallas aparecen con un fundido en vez de deslizarse, y los botones se atenúan en vez de encogerse.';

  @override
  String get deviceDeck => 'Deck';

  @override
  String deviceDeckCaption(String name) {
    return 'Tus propios botones para $name';
  }

  @override
  String get deckEdit => 'Editar';

  @override
  String get deckDone => 'Listo';

  @override
  String deckAsking(String name) {
    return 'Preguntando a $name qué puede hacer el deck…';
  }

  @override
  String deckAway(String name) {
    return '$name no está conectada. El deck funciona en cuanto lo esté.';
  }

  @override
  String deckNothingOffered(String name) {
    return '$name aún no deja hacer nada al deck. Activa sus acciones en Linksy en la computadora.';
  }

  @override
  String get deckEmptyPage =>
      'Aquí no hay nada aún. Toca Editar y luego Agregar.';

  @override
  String get deckAdd => 'Agregar';

  @override
  String get deckAddTitle => 'Agregar al deck';

  @override
  String get deckUnavailable => 'No disponible';

  @override
  String get deckGroupMedia => 'Multimedia';

  @override
  String get deckGroupSound => 'Sonido';

  @override
  String get deckGroupSystem => 'Sistema';

  @override
  String get deckGroupCommands => 'Comandos';

  @override
  String get deckKindButton => 'Botón';

  @override
  String get deckKindToggle => 'Activado o no';

  @override
  String get deckKindSlider => 'Control deslizante';

  @override
  String get deckSize => 'Tamaño';

  @override
  String get deckSizeSmall => 'Pequeño';

  @override
  String get deckSizeWide => 'Ancho';

  @override
  String get deckSizeTall => 'Alto';

  @override
  String get deckSizeBig => 'Grande';

  @override
  String get deckSizeRow => 'Fila completa';

  @override
  String get deckColor => 'Color';

  @override
  String get deckIcon => 'Ícono';

  @override
  String get deckRemove => 'Quitar del deck';

  @override
  String get deckNewPage => 'Página nueva';

  @override
  String get deckRemovePage => 'Quitar esta página';

  @override
  String get deckMoveHint =>
      'Mantén presionado un botón y arrástralo para moverlo.';

  @override
  String get settingsGallery => 'Fotos en tus computadoras';

  @override
  String get settingsGalleryCaption =>
      'Tus computadoras pueden ver las fotos y videos de este teléfono y guardar los que elijas.';

  @override
  String get settingsGalleryDenied =>
      'Permite que Linksy vea tus fotos en los ajustes de Android.';

  @override
  String get deckGroupNetwork => 'Red';

  @override
  String get deckGroupPower => 'Energía';

  @override
  String get deckThemeTitle => 'Tema';

  @override
  String deckThemeAsMade(String name) {
    return 'Como en $name';
  }

  @override
  String get deckThemesShared => 'También en la computadora';

  @override
  String get deckThemesPhone => 'Solo en este teléfono';

  @override
  String get deckThemeStock => 'Estándar';

  @override
  String get deckThemeDots => 'Matriz de puntos';

  @override
  String get deckThemeEink => 'E-Ink';

  @override
  String get deckThemeTerm => 'Terminal';

  @override
  String get deckThemePixel => 'Píxel';

  @override
  String get deckThemeSignal => 'Signal';

  @override
  String get deckThemeGlass => 'Cristal';

  @override
  String get deckThemeMidnight => 'Medianoche';

  @override
  String deckNotAvailable(String name) {
    return 'No disponible en $name';
  }

  @override
  String get deckAwayShort => 'No conectada';

  @override
  String deckAwayNote(String name) {
    return '$name no está conectada. Los botones funcionan en cuanto lo esté.';
  }

  @override
  String get deckNothingPlaying => 'Nada en reproducción';

  @override
  String deckNoLayouts(String name) {
    return '$name aún no tiene un deck para este teléfono. Crea uno en Linksy en la computadora.';
  }
}
