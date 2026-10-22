// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Добро пожаловать в Linksy';

  @override
  String get onboardingChooseLanguage => 'Выберите язык';

  @override
  String get onboardingLanguageHint => 'Его можно изменить позже в настройках.';

  @override
  String get onboardingContinue => 'Продолжить';

  @override
  String get onboardingSetUpTitle => 'Настройка Linksy';

  @override
  String get onboardingSetUpSubtitle =>
      'Выберите, что может делать Linksy. Ничего не покинет этот телефон, пока вы не разрешите.';

  @override
  String get onboardingNotifications => 'Уведомления';

  @override
  String get onboardingNotificationsDetail =>
      'О входящих файлах и о том, когда компьютер использует ваш экран, камеру или микрофон, — с кнопкой «Остановить».';

  @override
  String get onboardingCamera => 'Камера';

  @override
  String get onboardingCameraDetail =>
      'Сканирует QR-коды для сопряжения и, с вашего разрешения, позволяет компьютеру использовать её как веб-камеру.';

  @override
  String get onboardingAway => 'Вне дома';

  @override
  String get onboardingAwayDetail =>
      'Доступ к вашим компьютерам через интернет, когда вы не в одной сети Wi-Fi. Сквозное шифрование.';

  @override
  String get onboardingBackground => 'Работать в фоне';

  @override
  String get onboardingBackgroundDetail =>
      'Файлы и звонки работают, даже когда Linksy закрыт. Показывается тихое уведомление.';

  @override
  String get onboardingFolder => 'Открыть папку для компьютеров';

  @override
  String get onboardingFolderDetail =>
      'Ваши компьютеры смогут открыть выбранную вами папку в своём файловом менеджере.';

  @override
  String get onboardingPhotos => 'Папка для резервного копирования фото';

  @override
  String get onboardingPhotosDetail =>
      'Выберите папку камеры, чтобы копировать новые фото на компьютер. Включается для каждого компьютера отдельно.';

  @override
  String get onboardingLocate => 'Разрешить компьютерам находить этот телефон';

  @override
  String get onboardingLocateDetail =>
      'Компьютер может один раз спросить, где этот телефон. Ничего не сохраняется.';

  @override
  String get onboardingAllow => 'Разрешить';

  @override
  String get onboardingAllowed => 'Разрешено';

  @override
  String get onboardingChooseFolder => 'Выбрать';

  @override
  String onboardingFolderChosen(String folder) {
    return '«$folder»';
  }

  @override
  String get onboardingAnytime =>
      'Любой из этих пунктов можно включить или выключить в настройках в любое время.';

  @override
  String get onboardingStart => 'Начать пользоваться Linksy';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get languageDone => 'Готово';

  @override
  String get ctlClipboardFileTooBig =>
      'В буфер обмена помещается только файл размером до 10 MB.';

  @override
  String get ctlClipboardCopyFailed => 'Не удалось поместить в буфер обмена';

  @override
  String get ctlLocateOff =>
      'Определение местоположения выключено в Linksy на этом телефоне';

  @override
  String get ctlYourComputer => 'ваш компьютер';

  @override
  String get ctlAnd => 'и';

  @override
  String ctlKeepingLocked(String names) {
    return '$names будут блокироваться, когда вы уходите';
  }

  @override
  String get ctlStayingConnected =>
      'Связь с вашими компьютерами поддерживается';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name хочет отправить вам $count файла',
      many: '$name хочет отправить вам $count файлов',
      few: '$name хочет отправить вам $count файла',
      one: '$name хочет отправить вам $count файл',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'Буфер обмена пуст.';

  @override
  String get ctlClipboardTooMuch =>
      'В буфере обмена слишком много текста для отправки.';

  @override
  String get ctlPing => 'Сигнал';

  @override
  String ctlPingFrom(String name) {
    return 'От $name';
  }

  @override
  String get ctlTextTooMuch => 'Слишком много текста для отправки.';

  @override
  String get ctlDeclined => 'Отклонено';

  @override
  String get ctlScreenPermission =>
      'Для показа экрана нужно разрешение Android на его запись.';

  @override
  String get ctlCameraPermission =>
      'Чтобы работать как веб-камера, Linksy нужно разрешение на камеру.';

  @override
  String get ctlMicrophonePermission =>
      'Чтобы работать как микрофон, Linksy нужно разрешение на микрофон.';

  @override
  String get ctlTerminalTitle => 'Терминал';

  @override
  String get errorThatDevice => 'Это устройство';

  @override
  String get errorOtherDevice => 'Другое устройство';

  @override
  String get errorComputerOnCable => 'Компьютер на кабеле';

  @override
  String errorDeviceAt(String address) {
    return 'Устройство по адресу $address';
  }

  @override
  String errorUnreachable(String name) {
    return '$name: нет связи. Проверьте, что устройство включено и в этой сети.';
  }

  @override
  String errorDeclined(String name) {
    return '$name: запрос отклонён.';
  }

  @override
  String errorTimeout(String name) {
    return '$name: нет ответа вовремя.';
  }

  @override
  String errorNotPaired(String name) {
    return '$name: сопряжение больше не действует. Выполните сопряжение снова, чтобы делиться.';
  }

  @override
  String errorUnsupported(String name) {
    return '$name пока так не умеет.';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name разрешает это только в той же сети. Владелец может разрешить для этого телефона всё вне дома.';
  }

  @override
  String get errorInvalid => 'Не получилось.';

  @override
  String get errorSomethingWrong => 'Что-то пошло не так.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Что-то пошло не так: $detail';
  }

  @override
  String get terminalRefusedComputer => 'Компьютер';

  @override
  String get terminalRefusedCode => 'Неверный код.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Неверный код, осталось $count попытки.',
      many: 'Неверный код, осталось $count попыток.',
      few: 'Неверный код, осталось $count попытки.',
      one: 'Неверный код, осталась $count попытка.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Слишком много неверных кодов. Разблокируйте терминал на $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'На $name откройте страницу этого телефона и разрешите там терминал.';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name разрешает терминал только в той же сети, если там не включено «Разрешить всё вне дома».';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name не может открыть терминал.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return 'На $name для этого телефона уже запущено 8 терминалов. Сначала закройте один.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name не разрешил.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$kind $os';
  }

  @override
  String get modelKindDesktop => 'Настольный компьютер';

  @override
  String get modelKindLaptop => 'Ноутбук';

  @override
  String get modelKindPhone => 'Телефон';

  @override
  String get modelKindTablet => 'Планшет';

  @override
  String get modelOsUnknown => 'Неизвестно';

  @override
  String get deviceNothingOfKind => 'Здесь пока ничего нет.';

  @override
  String deviceBattery(int level) {
    return '$level%';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level%, заряжается';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Доступен вне дома до $day';
  }

  @override
  String get deviceLocksWhenLeave =>
      'Блокируется, когда вы уходите с этим телефоном';

  @override
  String get deviceBack => 'Назад';

  @override
  String get deviceMore => 'Ещё';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Сменить картинку';

  @override
  String get deviceAddPicture => 'Добавить картинку';

  @override
  String get deviceRemovePicture => 'Удалить картинку';

  @override
  String get deviceForgetThis => 'Забыть это устройство';

  @override
  String deviceForgetTitle(String name) {
    return 'Забыть $name?';
  }

  @override
  String get deviceForgetBody =>
      'Чтобы снова делиться с ним, понадобится новое сопряжение. Его история на этом телефоне тоже будет удалена.';

  @override
  String get deviceForget => 'Забыть';

  @override
  String get deviceCancel => 'Отмена';

  @override
  String get deviceSendFiles => 'Отправить файлы';

  @override
  String get deviceSendFilesCaption => 'Фото, документы, что угодно';

  @override
  String get deviceClipboard => 'Буфер обмена';

  @override
  String get deviceClipboardCaption => 'Отправить скопированное';

  @override
  String get devicePing => 'Сигнал';

  @override
  String get devicePingCaption => 'Пусть прозвенит';

  @override
  String get deviceRemote => 'Пульт';

  @override
  String get deviceRemoteCaption => 'Тачпад и слайды';

  @override
  String get deviceRinging => 'Звонит…';

  @override
  String get deviceFindIt => 'Найти';

  @override
  String get deviceTapToStop => 'Нажмите, чтобы остановить';

  @override
  String get deviceFindItCaption => 'Громкий звонок';

  @override
  String get devicePrevious => 'Предыдущий';

  @override
  String get devicePause => 'Пауза';

  @override
  String get devicePlay => 'Воспроизвести';

  @override
  String get deviceNext => 'Следующий';

  @override
  String deviceAllowOn(String name) {
    return 'Разрешите на $name…';
  }

  @override
  String get deviceSeeScreen => 'Его экран';

  @override
  String get deviceSeeScreenCaption =>
      'Смотрите здесь или управляйте касаниями';

  @override
  String get deviceWatch => 'Смотреть';

  @override
  String get deviceControl => 'Управлять';

  @override
  String get deviceTerminal => 'Терминал';

  @override
  String deviceTerminalShell(String name) {
    return 'Командная оболочка на $name, защищённая кодом';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Открыто $count терминала',
      many: 'Открыто $count терминалов',
      few: 'Открыто $count терминала',
      one: 'Открыт $count терминал',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'Все';

  @override
  String get deviceFilterFiles => 'Файлы';

  @override
  String get deviceFilterClipboard => 'Буфер';

  @override
  String get deviceFilterLinks => 'Ссылки';

  @override
  String get deviceFilterShowAll => 'Показать всё';

  @override
  String get deviceFilterShowFiles => 'Показать файлы';

  @override
  String get deviceFilterShowClipboard => 'Показать буфер обмена';

  @override
  String get deviceFilterShowLinks => 'Показать ссылки';

  @override
  String get deviceActivity => 'История';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Готов, когда $name попросит';
  }

  @override
  String get deviceWebcam => 'Веб-камера';

  @override
  String get deviceInUseNow => 'Используется';

  @override
  String get deviceControls => 'Настройки';

  @override
  String get deviceMicrophone => 'Микрофон';

  @override
  String get deviceStop => 'Стоп';

  @override
  String get deviceSecondDisplay => 'Второй экран';

  @override
  String get deviceShowingNow => 'Показывает';

  @override
  String deviceReadySize(int width, int height) {
    return 'Готов · $width × $height';
  }

  @override
  String get devicePhoneAs => 'Этот телефон как';

  @override
  String deviceStartedOn(String name) {
    return 'Запускается на $name';
  }

  @override
  String get deviceFasterOverUsb => 'Через USB-кабель быстрее и стабильнее.';

  @override
  String get deviceBackUpPhotos => 'Копировать фото';

  @override
  String devicePhotosGoTo(String name) {
    return 'Новые фото попадут в папку «Изображения» на $name';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name не принимает фото. Включите там «Импортировать фото с телефонов».';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'Из $folder';
  }

  @override
  String get devicePhotosFromCamera => 'Из папки камеры';

  @override
  String devicePhotosLast(String time) {
    return 'последний раз $time';
  }

  @override
  String get deviceGetClipboard => 'Получать его буфер обмена';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'Текст, скопированный на $name, появляется здесь, пока есть связь';
  }

  @override
  String get deviceAwayAll => 'Разрешить всё вне дома';

  @override
  String get deviceAwayAllOn =>
      'Вне дома тоже: этот экран, веб-камера, микрофон и файлы';

  @override
  String get deviceAwayAllOff =>
      'Вне дома: только буфер обмена, ссылки, файлы и звонок';

  @override
  String get deviceNothingShared => 'Пока ничего не отправлено';

  @override
  String deviceNothingSharedBody(String name) {
    return 'Здесь появятся файлы, текст из буфера обмена и сигналы между этим телефоном и $name.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count объекта',
      many: '$count объектов',
      few: '$count объекта',
      one: '$count объект',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '«$text»';
  }

  @override
  String get activityClipboardText => 'Текст из буфера обмена';

  @override
  String get activityPing => 'Сигнал';

  @override
  String get activityYourScreen => 'Ваш экран';

  @override
  String get activityYourCamera => 'Ваша камера';

  @override
  String get activitySecondDisplay => 'Второй экран';

  @override
  String get activityLink => 'Ссылка';

  @override
  String get activityRangThisPhone => 'Звонок на этот телефон';

  @override
  String get activityRangIt => 'Звонок на устройство';

  @override
  String get activityTouchpadKeyboard => 'Тачпад и клавиатура';

  @override
  String get activityItsScreen => 'Его экран';

  @override
  String get activityYourMicrophone => 'Ваш микрофон';

  @override
  String get activityWhereThisPhone => 'Где этот телефон';

  @override
  String get activityWatchingNow => 'Просмотр идёт';

  @override
  String get activityWatched => 'Просмотрен';

  @override
  String get activityInUseWebcam => 'Работает как веб-камера';

  @override
  String get activityUsedWebcam => 'Работала как веб-камера';

  @override
  String get activityBeingControlled => 'Сейчас под управлением';

  @override
  String get activityWatchedControlled => 'Просмотр и управление';

  @override
  String get activityWatchedFromPhone => 'Просмотрен с этого телефона';

  @override
  String get activityInUseNow => 'Используется';

  @override
  String get activityWasTouchpad => 'Этот телефон был его тачпадом';

  @override
  String get activityWasSecondDisplay => 'Этот телефон был его вторым экраном';

  @override
  String get activityLinkReceived => 'Ссылка получена';

  @override
  String get activityOpenedOnComputer => 'Открыта на компьютере';

  @override
  String get activityInUseMicrophone => 'Работает как микрофон';

  @override
  String get activityUsedMicrophone => 'Работал как микрофон';

  @override
  String get activityNotTold => 'Не сообщено';

  @override
  String get activityToldWhere => 'Сообщено, где этот телефон';

  @override
  String get activityAskedToFind => 'Запрос найти этот телефон';

  @override
  String get activityToFindIt => 'Чтобы найти его';

  @override
  String get activityDeclined => 'Отклонено';

  @override
  String get activityFailed => 'Ошибка';

  @override
  String get activityInProgress => 'Выполняется';

  @override
  String get activityCopiedHere => 'Скопировано сюда';

  @override
  String get activityReceived => 'Получено';

  @override
  String get activitySent => 'Отправлено';

  @override
  String get activityStop => 'Остановить';

  @override
  String get activityCancel => 'Отменить';

  @override
  String get activityCopyAgain => 'Скопировать снова';

  @override
  String get activityCopied => 'Скопировано';

  @override
  String get activityCopyLink => 'Копировать ссылку';

  @override
  String get activityLinkCopied => 'Ссылка скопирована';

  @override
  String get activityNoAppForLink =>
      'Здесь нет приложения, которое откроет эту ссылку.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name больше нет на месте.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'На этом телефоне нет приложения, которое откроет $name.';
  }

  @override
  String get activityWaitingForYou => 'Ждём, пока вы примете…';

  @override
  String get activityWaitingForDevice => 'Ждём, пока устройство примет…';

  @override
  String activityWaitingFor(String name) {
    return 'Ждём, пока $name примет…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done из $total';
  }

  @override
  String get homeSettings => 'Настройки';

  @override
  String get homeYourDevices => 'Ваши устройства';

  @override
  String get homeNearbyNotPaired => 'Рядом, без сопряжения';

  @override
  String get homeAddDevice => 'Добавить устройство';

  @override
  String homeVisible(String name) {
    return '$name виден в этой сети Wi-Fi';
  }

  @override
  String get homeUpdateTitle => 'Обновите Linksy, чтобы оставаться на связи';

  @override
  String get homeUpdateBody =>
      'Ваши компьютеры используют более новую версию Linksy, чем это приложение.';

  @override
  String get homeGetUpdate => 'Обновить';

  @override
  String get homeSendFiles => 'Отправить файлы';

  @override
  String get homePair => 'Связать';

  @override
  String get homeStepOpen => 'Откройте Linksy на компьютере';

  @override
  String get homeStepChoose => 'Выберите «Добавить устройство»';

  @override
  String get homeStepScan => 'Отсканируйте его этим телефоном';

  @override
  String get homeConnectTitle => 'Подключите\nпервое устройство';

  @override
  String get homeConnectSubtitle =>
      'Напрямую через ваш Wi-Fi. Без аккаунта и облака.';

  @override
  String get homeScanQr => 'Сканировать QR-код';

  @override
  String get homePairByAddress => 'Связать по адресу';

  @override
  String get pairingAddDevice => 'Добавить устройство';

  @override
  String get pairingAddDeviceHint =>
      'На другом устройстве откройте Linksy и выберите «Добавить устройство».';

  @override
  String get pairingScanQr => 'Сканировать QR-код';

  @override
  String get pairingScanQrCaption => 'Быстрее всего. Ничего не надо вводить.';

  @override
  String get pairingByAddress => 'Связать по адресу';

  @override
  String get pairingByAddressCaption => 'Если другое устройство не находится.';

  @override
  String pairingWith(String name) {
    return 'Сопряжение с $name…';
  }

  @override
  String get pairingWithOtherDevice => 'Сопряжение с другим устройством…';

  @override
  String get pairingAddressHint =>
      'Адрес указан в настройках Linksy на другом устройстве.';

  @override
  String pairingPortHint(String port) {
    return 'Порт $port, если не указать другой.';
  }

  @override
  String get pairingPair => 'Связать';

  @override
  String pairingWantsToPair(String name) {
    return '$name хочет связаться';
  }

  @override
  String pairingPairWith(String name) {
    return 'Сопряжение с $name';
  }

  @override
  String get pairingCodeHint => 'На обоих экранах должен быть этот код.';

  @override
  String pairingCodeLabel(String code) {
    return 'Код $code';
  }

  @override
  String get pairingCodesMatch => 'Коды совпадают';

  @override
  String get scanNeedsCamera =>
      'Чтобы отсканировать код сопряжения, Linksy нужна камера. Разрешите её или свяжитесь по адресу.';

  @override
  String get scanCameraUnavailable => 'Камера недоступна.';

  @override
  String get scanFlashlight => 'Фонарик';

  @override
  String get scanTitle => 'Отсканируйте код';

  @override
  String get scanWrongCode =>
      'Это не код Linksy. На компьютере откройте Linksy → Pair with QR Code.';

  @override
  String get scanHint =>
      'На компьютере откройте Linksy и выберите «Добавить устройство».';

  @override
  String get shareSheetPutOnClipboard => 'В буфер обмена';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Отправить $count файла',
      many: 'Отправить $count файлов',
      few: 'Отправить $count файла',
      one: 'Отправить $count файл',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Открыть на компьютере';

  @override
  String get shareSheetSendToClipboard => 'Отправить в буфер обмена';

  @override
  String get shareSheetNoClipboardFiles =>
      'Ни один из ваших компьютеров пока не принимает файлы в буфер обмена. Обновите там Linksy.';

  @override
  String get shareSheetNoComputers =>
      'Сначала свяжите компьютер, а потом делитесь с ним из любого приложения.';

  @override
  String get shareSheetSendFileInstead => 'Лучше отправить файл';

  @override
  String get shareSheetClipboardInstead =>
      'Лучше поместить в буфер обмена компьютера';

  @override
  String get shareSheetOpenLinkInstead => 'Лучше открыть ссылку';

  @override
  String get shareSheetSendAsTextInstead =>
      'Лучше отправить текстом в буфер обмена';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Помещаем в буфер обмена $name';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Помещаем в буфер обмена компьютера';

  @override
  String shareSheetOpened(String name) {
    return 'Открыто на $name';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Открыто на компьютере';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'Отправлено в буфер обмена $name';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'Отправлено в буфер обмена компьютера';

  @override
  String shareSheetSentALink(String name) {
    return '$name отправил ссылку';
  }

  @override
  String get shareSheetOpen => 'Открыть';

  @override
  String get shareSheetCopyLink => 'Копировать ссылку';

  @override
  String get shareSheetLinkCopied => 'Ссылка скопирована';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$name отправляет вам $_temp0';
  }

  @override
  String incomingTotal(String size) {
    return 'Всего $size';
  }

  @override
  String incomingMore(int count) {
    return '+ ещё $count';
  }

  @override
  String get incomingAccept => 'Принять';

  @override
  String get appInvalidPairingLink =>
      'Эта ссылка для сопряжения недействительна.';

  @override
  String appPairingFailed(String reason) {
    return 'Сопряжение не удалось: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'Не удалось связаться с $name: $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Связано с $name';
  }

  @override
  String appNotification(String name, String text) {
    return '$name: $text';
  }

  @override
  String appCopiedText(String name) {
    return 'Скопирован текст с $name';
  }

  @override
  String appCopiedFile(String file, String name) {
    return 'Скопирован $file с $name';
  }

  @override
  String get appCouldntStart => 'Не удалось запустить Linksy';

  @override
  String get commonDismiss => 'Скрыть';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDecline => 'Отклонить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonNotNow => 'Не сейчас';

  @override
  String get commonConnected => 'Подключено';

  @override
  String get commonNearby => 'Рядом';

  @override
  String get commonNotNearby => 'Не рядом';

  @override
  String get commonUsbCable => 'USB-кабель';

  @override
  String get commonAwayFromHome => 'Вне дома';

  @override
  String get commonSameWifi => 'Та же сеть Wi-Fi';

  @override
  String get commonConnectedByUsb => 'Подключено по USB';

  @override
  String get commonConnectedAway => 'Подключено вне дома';

  @override
  String commonBattery(int level) {
    return 'Батарея $level процентов';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Батарея $level процентов, заряжается';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count байта',
      many: '$count байт',
      few: '$count байта',
      one: '$count байт',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count секунды',
      many: 'Осталось $count секунд',
      few: 'Осталось $count секунды',
      one: 'Осталась $count секунда',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось $count минуты',
      many: 'Осталось $count минут',
      few: 'Осталось $count минуты',
      one: 'Осталась $count минута',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось около $count часа',
      many: 'Осталось около $count часов',
      few: 'Осталось около $count часов',
      one: 'Осталось около $count часа',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Сегодня';

  @override
  String get formatYesterday => 'Вчера';

  @override
  String get formatPhone => 'Телефон';

  @override
  String get settingsBack => 'Назад';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsReceiving => 'Получение';

  @override
  String get settingsSaveLocation => 'Куда сохранять';

  @override
  String get settingsSaveLocationPath => 'Загрузки › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Принимать с моих устройств';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'Файлы со связанных устройств приходят без вопросов.';

  @override
  String get settingsConnection => 'Подключение';

  @override
  String get settingsStayConnected => 'Оставаться на связи';

  @override
  String get settingsStayConnectedCaption =>
      'Быстрее обмен с устройствами рядом. Расходует больше заряда.';

  @override
  String get settingsKeepRunning => 'Работать в фоне';

  @override
  String get settingsKeepRunningCaption =>
      'Файлы, копирование фото и звонки работают, даже когда Linksy закрыт. Показывается тихое уведомление.';

  @override
  String get settingsAwayFromHome => 'Вне дома';

  @override
  String get settingsAwayFromHomeCaption =>
      'Доступ к вашим компьютерам через интернет, когда вы не в одной сети, — в течение недели после последней встречи в ней. Сквозное шифрование.';

  @override
  String get settingsRelay => 'Релейный сервер';

  @override
  String get settingsRelayDefault => 'Релей Linksy';

  @override
  String get settingsRelayCaption =>
      'Адрес релея, который вы разместили сами, например https://relay.example.com. Оставьте пустым, чтобы использовать релей Linksy. Задайте один и тот же релей на всех устройствах.';

  @override
  String get settingsWithYourComputers => 'С вашими компьютерами';

  @override
  String get settingsPauseMusic => 'Пауза музыки при звонках';

  @override
  String get settingsPauseMusicCaption =>
      'Ваши компьютеры ставят воспроизведение на паузу, пока идёт вызов или разговор, и продолжают после.';

  @override
  String get settingsBrowseFiles => 'Доступ компьютеров к файлам';

  @override
  String get settingsBrowseFilesChoose =>
      'Выберите папку, которую компьютеры смогут открыть в файловом менеджере, например «Документы» (Android не разрешает «Загрузки»).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Открыта папка «$folder». Нажмите, чтобы выбрать другую.';
  }

  @override
  String get settingsPicture => 'Картинка этого телефона';

  @override
  String get settingsPictureChoose =>
      'Ваши компьютеры показывают её для этого телефона. Нажмите, чтобы выбрать.';

  @override
  String get settingsPictureChange =>
      'Ваши компьютеры показывают её для этого телефона. Нажмите, чтобы сменить.';

  @override
  String get settingsPictureRemove => 'Удалить';

  @override
  String get settingsLocate => 'Разрешить компьютерам находить этот телефон';

  @override
  String get settingsLocateCaption =>
      'Компьютер может один раз спросить, где этот телефон, чтобы найти его. Ничего не сохраняется и не отслеживается. Работает, пока Linksy открыт.';

  @override
  String get settingsLocatePermission =>
      'Для этого Linksy нужно разрешение на геолокацию.';

  @override
  String get settingsPhotoFolder => 'Папка с фото';

  @override
  String get settingsPhotoFolderChoose =>
      'Выберите папку камеры (DCIM › Camera), чтобы копировать фото на компьютер.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Копируется «$folder». Включайте для каждого компьютера на его странице.';
  }

  @override
  String get settingsThisApp => 'Это приложение';

  @override
  String get settingsPermissions => 'Разрешения';

  @override
  String get settingsDemo => 'Демо';

  @override
  String get settingsDemoCaption =>
      'Имитация устройств, пока ядро Linksy не подключено. Эти кнопки запускают то, что сделало бы другое устройство.';

  @override
  String get settingsDemoReceiveFiles => 'Получить файлы';

  @override
  String get settingsDemoReceivePairing => 'Получить запрос на сопряжение';

  @override
  String get settingsDemoReceiveClipboard => 'Получить текст в буфер обмена';

  @override
  String get settingsTagline =>
      'Ваши устройства на связи.\nБез аккаунта и облака.';

  @override
  String get settingsNameTitle => 'Имя этого телефона';

  @override
  String get settingsNameCaption => 'Это имя видят ваши другие устройства.';

  @override
  String get settingsSave => 'Сохранить';

  @override
  String get settingsCancel => 'Отмена';

  @override
  String settingsRename(String name) {
    return 'Переименовать $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'Этот телефон · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Уведомления и камера';

  @override
  String get settingsPermissionsWhat =>
      'Что Linksy запрашивает у Android и зачем.';

  @override
  String get settingsPermissionsBoth => 'Оба разрешены.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Разрешено $count из 2. Нажмите, чтобы разрешить остальные.',
      many: 'Разрешено $count из 2. Нажмите, чтобы разрешить остальные.',
      few: 'Разрешено $count из 2. Нажмите, чтобы разрешить остальные.',
      one: 'Разрешено $count из 2. Нажмите, чтобы разрешить остальные.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Разрешения';

  @override
  String get permissionsIntro =>
      'Linksy просит только то, что нужно, и любое из этого можно изменить позже в настройках.';

  @override
  String get permissionsNotifications => 'Уведомления';

  @override
  String get permissionsNotificationsWhy =>
      'Показывают, когда компьютер видит ваш экран или использует камеру, с кнопкой, чтобы это остановить.';

  @override
  String get permissionsCamera => 'Камера';

  @override
  String get permissionsCameraWhy =>
      'Сканирует QR-код сопряжения и, с вашего разрешения, позволяет компьютеру использовать этот телефон как веб-камеру.';

  @override
  String get permissionsAllow => 'Разрешить';

  @override
  String get permissionsAllowed => 'Разрешено';

  @override
  String get permissionsDone => 'Готово';

  @override
  String get remoteBack => 'Назад';

  @override
  String get remoteTitle => 'Пульт';

  @override
  String remoteAllowOn(String name) {
    return 'Разрешите на $name';
  }

  @override
  String remoteAsks(String name) {
    return 'Linksy на $name спрашивает, может ли этот телефон двигать указатель и печатать.';
  }

  @override
  String get remoteFailed => 'Не получилось';

  @override
  String get remoteStopped => 'Пульт отключён';

  @override
  String remoteEndedBy(String name) {
    return '$name завершил сеанс.';
  }

  @override
  String get remoteTryAgain => 'Повторить';

  @override
  String get remoteTouchpad => 'Тачпад';

  @override
  String get remoteSlides => 'Слайды';

  @override
  String get remoteTouchpadHint =>
      'Ведите одним пальцем, коснитесь для щелчка\nДвумя пальцами — прокрутка, касание двумя — правый щелчок';

  @override
  String get remoteLeftClick => 'Левый щелчок';

  @override
  String get remoteRightClick => 'Правый щелчок';

  @override
  String get remoteKeyboard => 'Клавиатура';

  @override
  String get remoteNextSlide => 'Следующий слайд';

  @override
  String get remoteNext => 'Далее';

  @override
  String get remotePreviousSlide => 'Предыдущий слайд';

  @override
  String get remoteSlideBack => 'Назад';

  @override
  String get remoteStartShow => 'Начать (F5)';

  @override
  String get remoteEndShow => 'Завершить (Esc)';

  @override
  String get remoteVolumeHint =>
      'Громкость вниз: далее · Громкость вверх: назад. Экран не гаснет.';

  @override
  String get ringTitle => 'Я здесь!';

  @override
  String ringLookingFor(String name) {
    return '$name ищет этот телефон.';
  }

  @override
  String get ringFoundIt => 'Нашёл';

  @override
  String get webcamBack => 'Назад';

  @override
  String get webcamTitle => 'Веб-камера';

  @override
  String webcamLiveOn(String name) {
    return 'В эфире на $name';
  }

  @override
  String get webcamStopSemantic => 'Остановить веб-камеру';

  @override
  String get webcamStop => 'Стоп';

  @override
  String get webcamBadgeLive => 'ЭФИР';

  @override
  String get webcamBadgeLock => 'AE/AF ЗАФИКС.';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'ФОНАРИК';

  @override
  String get webcamFacingFront => 'Фронтальная';

  @override
  String get webcamFacingBack => 'Основная';

  @override
  String get webcamTorch => 'Фонарик';

  @override
  String get webcamPortrait => 'Портрет';

  @override
  String get webcamLandscape => 'Альбом';

  @override
  String get webcamLocked => 'Зафиксировано';

  @override
  String get webcamLock => 'Фиксировать';

  @override
  String get webcamTabLight => 'Свет';

  @override
  String get webcamTabFocus => 'Фокус';

  @override
  String get webcamTabColor => 'Цвет';

  @override
  String get webcamTabStream => 'Поток';

  @override
  String get webcamBrightness => 'Яркость';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto => 'Эта камера сама настраивает экспозицию.';

  @override
  String get webcamLockExposure => 'Фиксировать экспозицию';

  @override
  String get webcamLockExposureDetail =>
      'Сохраняет текущую яркость. Удерживайте палец на изображении, чтобы зафиксировать точку.';

  @override
  String get webcamFocus => 'Фокус';

  @override
  String get webcamFocusFixed => 'У этой камеры фиксированный фокус.';

  @override
  String get webcamFocusSpotDetail =>
      'Держится там, где вы коснулись. Дважды коснитесь изображения для автофокуса.';

  @override
  String get webcamFocusManualDetail => 'Настраивается вручную ниже.';

  @override
  String get webcamFocusAutoDetail =>
      'Следует за изображением. Коснитесь, чтобы сфокусироваться на точке.';

  @override
  String get webcamFocusAuto => 'Авто';

  @override
  String get webcamFocusSpot => 'Точка';

  @override
  String get webcamFocusManual => 'Вручную';

  @override
  String get webcamDistance => 'Расстояние';

  @override
  String get webcamFar => 'Далеко';

  @override
  String get webcamNear => 'Близко';

  @override
  String get webcamWbAuto => 'Авто';

  @override
  String get webcamWbDaylight => 'Дневной свет';

  @override
  String get webcamWbCloudy => 'Облачно';

  @override
  String get webcamWbShade => 'Тень';

  @override
  String get webcamWbIncandescent => 'Тёплый свет';

  @override
  String get webcamWbFluorescent => 'Офисный свет';

  @override
  String get webcamWhiteBalance => 'Баланс белого';

  @override
  String get webcamLockColors => 'Фиксировать цвета';

  @override
  String get webcamLockColorsDetail => 'Цвета не меняются вместе с освещением.';

  @override
  String get webcamOrientation => 'Ориентация';

  @override
  String get webcamOrientationPortraitDetail =>
      'Держите телефон вертикально; полосы по бокам.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Держите телефон горизонтально; изображение заполняет кадр.';

  @override
  String get webcamFrameRate => 'Частота кадров';

  @override
  String get webcamFps60Detail =>
      'Плавнее движение; больше трафика и расхода заряда.';

  @override
  String get webcamFps30Detail => 'Стабильно для видеозвонков.';

  @override
  String get webcamFpsOnly30 => 'Эта камера снимает до 30 fps.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Разрешение';

  @override
  String get webcamResolution1080Detail =>
      'Full HD для большого экрана; больше трафика.';

  @override
  String get webcamResolution720Detail => 'HD, в самый раз для видеозвонков.';

  @override
  String get webcamResolutionOnly720 => 'Эта камера передаёт 720p.';

  @override
  String get webcamQuality => 'Качество';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, для загруженного Wi-Fi.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, максимум деталей.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, чётко для видеозвонков.';
  }

  @override
  String get webcamQualitySaver => 'Экономное';

  @override
  String get webcamQualityStandard => 'Стандартное';

  @override
  String get webcamQualityHigh => 'Высокое';

  @override
  String get webcamStabilization => 'Стабилизация';

  @override
  String get webcamStabilizationDetail => 'Сглаживает дрожание рук.';

  @override
  String get webcamMirror => 'Зеркальный предпросмотр';

  @override
  String get webcamMirrorDetail =>
      'Только на этом телефоне; компьютер получает незеркальное изображение.';

  @override
  String get webcamFormat => 'Формат';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Сбросить';

  @override
  String webcamResetSetting(String setting) {
    return 'Сбросить: $setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Масштаб $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name хочет видеть ваш экран';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Всё, что на экране этого телефона, будет видно на $name, пока вы не остановите. Далее Android попросит подтвердить.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name хочет управлять вашим экраном';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '$name видит экран этого телефона и может нажимать, проводить и печатать на нём, пока вы не остановите. Далее Android попросит подтвердить.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name хочет использовать вашу камеру';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '$name получает камеру этого телефона как веб-камеру, пока вы не остановите. Масштаб, фокус, свет, объективы и поворот — в Linksy, пока она работает.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name хочет использовать этот телефон как тачпад';
  }

  @override
  String get sharingInputRequestDetail =>
      'Странно: компьютеры такое не запрашивают. Не разрешайте.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name хочет использовать ваш микрофон';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '$name слышит микрофон этого телефона, пока вы не остановите, — как микрофон для любых его приложений. Далее Android попросит подтвердить.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name хочет использовать этот экран как второй дисплей';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'Этот телефон показывает экран $name во весь экран. Касайтесь, чтобы щёлкать и перетаскивать; прокручивайте двумя пальцами. Вернитесь назад, чтобы остановить.';
  }

  @override
  String get sharingAllow => 'Разрешить';

  @override
  String get sharingDontAllow => 'Не разрешать';

  @override
  String get sharingProtectionHint =>
      'Верхняя панель или уведомления на компьютере чёрные? Их скрывает защита Android при показе экрана. Включите «Отключить защиту при демонстрации экрана» в параметрах разработчика и начните показ снова.';

  @override
  String get sharingGotIt => 'Понятно';

  @override
  String get sharingDeveloperOptions => 'Для разработчиков';

  @override
  String sharingControlling(String name) {
    return '$name управляет вашим экраном';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name использует вашу камеру';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name использует ваш микрофон';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Ваш экран виден на $name';
  }

  @override
  String get sharingTapForCameraControls => 'Нажмите для настроек камеры';

  @override
  String get sharingSwitchCamera => 'Сменить камеру';

  @override
  String get sharingStopSharing => 'Прекратить показ';

  @override
  String get sharingStop => 'Стоп';

  @override
  String get sharingCameraControls => 'Настройки камеры';

  @override
  String displaySecondHint(String name) {
    return 'Второй экран $name · вернитесь назад, чтобы остановить';
  }

  @override
  String displayControlHint(String name) {
    return 'Экран $name · касание — щелчок · вернитесь назад, чтобы остановить';
  }

  @override
  String displayWatchHint(String name) {
    return 'Экран $name · вернитесь назад, чтобы остановить';
  }

  @override
  String terminalTabClosed(String title) {
    return '«$title» закрыт';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '«$title» завершён на $name';
  }

  @override
  String get terminalCloseTitle => 'Закрыть этот терминал?';

  @override
  String terminalCloseDetail(String name) {
    return 'Оболочка на $name завершится вместе со всем, что в ней ещё работает. Чтобы вернуться к ней позже, оставьте её работать.';
  }

  @override
  String get terminalKeepRunning => 'Оставить работать';

  @override
  String get terminalClose => 'Закрыть';

  @override
  String get terminalTheComputer => 'компьютер';

  @override
  String get terminalDetached => 'Отключён';

  @override
  String terminalDetachedDetail(String name) {
    return 'Всё ещё работает на $name. Подключитесь снова, чтобы увидеть его; код будет запрошен заново.';
  }

  @override
  String get terminalReattach => 'Подключиться';

  @override
  String terminalOn(String name) {
    return 'Терминал на $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Отключён · работает на $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Открывается на $name…';
  }

  @override
  String get terminalWaitingForCode => 'Ожидание кода';

  @override
  String get terminalEnded => 'Завершён';

  @override
  String get terminalBack => 'Назад';

  @override
  String get terminalTitle => 'Терминал';

  @override
  String get terminalMenu => 'Меню терминала';

  @override
  String get terminalDetachMenu => 'Оставить работать (отключиться)';

  @override
  String terminalCloseTab(String title) {
    return 'Закрыть $title';
  }

  @override
  String get terminalNew => 'Новый терминал';

  @override
  String terminalShellOn(String name) {
    return 'Оболочка на $name';
  }

  @override
  String get terminalShellDetail =>
      'Работает от вашего имени на компьютере, в домашней папке. При каждом открытии запрашивает код терминала, заданный там.';

  @override
  String get terminalStillRunning => 'ЕЩЁ РАБОТАЮТ';

  @override
  String terminalReattachTab(String title) {
    return 'Подключиться к $title';
  }

  @override
  String terminalStarted(String time) {
    return 'Запущен в $time';
  }

  @override
  String get terminalKeyLeft => 'Влево';

  @override
  String get terminalKeyUp => 'Вверх';

  @override
  String get terminalKeyDown => 'Вниз';

  @override
  String get terminalKeyRight => 'Вправо';

  @override
  String get terminalCodeTitle => 'Код терминала';

  @override
  String terminalCodeDetail(String name) {
    return 'Код, заданный на $name в разделе Настройки › Терминал. Linksy его не хранит.';
  }

  @override
  String get terminalCodePassphrase => 'Парольная фраза';

  @override
  String get terminalCodeDigitsHint => '6 цифр или больше';

  @override
  String get terminalCodeUseDigits => 'Цифры';

  @override
  String get terminalCodeUseLetters => 'Буквы';

  @override
  String get terminalOpening => 'Открывается…';

  @override
  String get terminalOpen => 'Открыть терминал';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsThemeSystem => 'Как в системе';

  @override
  String get settingsThemeLight => 'Светлое';

  @override
  String get settingsThemeDark => 'Тёмное';

  @override
  String usbConnectedTo(String name) {
    return 'Подключено к $name по USB-кабелю';
  }

  @override
  String get usbPairTitle => 'К кабелю подключён компьютер';

  @override
  String get usbPairBody =>
      'Он ещё не связан с этим телефоном. Связать по кабелю? На обоих экранах появится код для сравнения.';

  @override
  String get usbPairAction => 'Связать';
}
