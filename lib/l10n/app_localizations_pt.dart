// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Linksy';

  @override
  String get onboardingWelcome => 'Boas-vindas ao Linksy';

  @override
  String get onboardingChooseLanguage => 'Escolha seu idioma';

  @override
  String get onboardingLanguageHint =>
      'Você pode mudar depois em Configurações.';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingSetUpTitle => 'Configure o Linksy';

  @override
  String get onboardingSetUpSubtitle =>
      'Escolha o que o Linksy pode fazer. Nada sai deste celular sem você dizer.';

  @override
  String get onboardingNotifications => 'Notificações';

  @override
  String get onboardingNotificationsDetail =>
      'Arquivos chegando e quando um computador usa sua tela, câmera ou microfone, com um botão para parar.';

  @override
  String get onboardingCamera => 'Câmera';

  @override
  String get onboardingCameraDetail =>
      'Lê os códigos QR de pareamento e deixa um computador usá-la como webcam quando você permitir.';

  @override
  String get onboardingAway => 'Fora de casa';

  @override
  String get onboardingAwayDetail =>
      'Acesse seus computadores pela internet quando não estiver no mesmo Wi-Fi. Criptografado de ponta a ponta.';

  @override
  String get onboardingBackground => 'Continuar em segundo plano';

  @override
  String get onboardingBackgroundDetail =>
      'Arquivos e chamadas continuam funcionando com o Linksy fechado. Mostra uma notificação discreta.';

  @override
  String get onboardingFolder => 'Compartilhar uma pasta com computadores';

  @override
  String get onboardingFolderDetail =>
      'Seus computadores podem abrir uma pasta que você escolher no app Arquivos deles.';

  @override
  String get onboardingPhotos => 'Pasta de backup de fotos';

  @override
  String get onboardingPhotosDetail =>
      'Escolha a pasta da câmera para fazer backup das fotos novas em um computador. Ativado por computador.';

  @override
  String get onboardingLocate => 'Deixar computadores localizarem este celular';

  @override
  String get onboardingLocateDetail =>
      'Um computador pode perguntar onde este celular está, uma vez. Nada é guardado.';

  @override
  String get onboardingAllow => 'Permitir';

  @override
  String get onboardingAllowed => 'Permitido';

  @override
  String get onboardingChooseFolder => 'Escolher';

  @override
  String onboardingFolderChosen(String folder) {
    return '“$folder”';
  }

  @override
  String get onboardingAnytime =>
      'Você pode ativar ou desativar qualquer um destes a qualquer momento em Configurações.';

  @override
  String get onboardingStart => 'Começar a usar o Linksy';

  @override
  String get onboardingBack => 'Voltar';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageDone => 'Concluído';

  @override
  String get ctlClipboardFileTooBig =>
      'Só cabe na área de transferência um arquivo de até 10 MB.';

  @override
  String get ctlClipboardCopyFailed =>
      'Não foi possível colocar na área de transferência';

  @override
  String get ctlLocateOff =>
      'A localização está desativada no Linksy deste celular';

  @override
  String get ctlYourComputer => 'seu computador';

  @override
  String get ctlAnd => 'e';

  @override
  String ctlKeepingLocked(String names) {
    return 'Mantendo $names bloqueado quando você sair';
  }

  @override
  String get ctlStayingConnected => 'Mantendo a conexão com seus computadores';

  @override
  String ctlTransferRequest(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name quer enviar $count arquivos para você',
      one: '$name quer enviar um arquivo para você',
    );
    return '$_temp0';
  }

  @override
  String get ctlClipboardEmpty => 'A área de transferência está vazia.';

  @override
  String get ctlClipboardTooMuch =>
      'A área de transferência tem texto demais para enviar.';

  @override
  String get ctlPing => 'Ping';

  @override
  String ctlPingFrom(String name) {
    return 'De $name';
  }

  @override
  String get ctlTextTooMuch => 'É texto demais para enviar.';

  @override
  String get ctlDeclined => 'Recusado';

  @override
  String get ctlScreenPermission =>
      'Compartilhar a tela precisa da permissão do Android para capturá-la.';

  @override
  String get ctlCameraPermission =>
      'O Linksy precisa da permissão da câmera para funcionar como webcam.';

  @override
  String get ctlMicrophonePermission =>
      'O Linksy precisa da permissão do microfone para ser um microfone.';

  @override
  String get ctlTerminalTitle => 'Terminal';

  @override
  String get errorThatDevice => 'Esse dispositivo';

  @override
  String get errorOtherDevice => 'O outro dispositivo';

  @override
  String get errorComputerOnCable => 'O computador no cabo';

  @override
  String errorDeviceAt(String address) {
    return 'O dispositivo em $address';
  }

  @override
  String errorUnreachable(String name) {
    return '$name não está acessível. Verifique se está ligado e nesta rede.';
  }

  @override
  String errorDeclined(String name) {
    return '$name recusou.';
  }

  @override
  String errorTimeout(String name) {
    return '$name não respondeu a tempo.';
  }

  @override
  String errorNotPaired(String name) {
    return '$name não está mais pareado. Pareie de novo para compartilhar.';
  }

  @override
  String errorUnsupported(String name) {
    return '$name ainda não consegue fazer isso.';
  }

  @override
  String errorNotFromAway(String name) {
    return '$name só permite isso na mesma rede. O dono pode permitir tudo fora de casa para este celular.';
  }

  @override
  String get errorInvalid => 'Não deu certo.';

  @override
  String get errorSomethingWrong => 'Algo deu errado.';

  @override
  String errorSomethingWrongDetail(String detail) {
    return 'Algo deu errado: $detail';
  }

  @override
  String get terminalRefusedComputer => 'O computador';

  @override
  String get terminalRefusedCode => 'Código errado.';

  @override
  String terminalRefusedCodeTries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Código errado, restam $count tentativas.',
      one: 'Código errado, resta $count tentativa.',
    );
    return '$_temp0';
  }

  @override
  String terminalRefusedLocked(String name) {
    return 'Códigos errados demais. Desbloqueie o terminal em $name.';
  }

  @override
  String terminalRefusedOff(String name) {
    return 'Em $name, abra a página deste celular e permita o terminal lá.';
  }

  @override
  String terminalRefusedAway(String name) {
    return '$name só permite um terminal na mesma rede, a menos que “Permitir tudo fora de casa” esteja ativado lá.';
  }

  @override
  String terminalRefusedUnsupported(String name) {
    return '$name não consegue abrir um terminal.';
  }

  @override
  String terminalRefusedLimit(String name) {
    return 'Já há 8 terminais rodando em $name para este celular. Feche um primeiro.';
  }

  @override
  String terminalRefusedDeclined(String name) {
    return '$name não permitiu.';
  }

  @override
  String modelDescription(String os, String kind) {
    return '$kind $os';
  }

  @override
  String get modelKindDesktop => 'Desktop';

  @override
  String get modelKindLaptop => 'Notebook';

  @override
  String get modelKindPhone => 'Celular';

  @override
  String get modelKindTablet => 'Tablet';

  @override
  String get modelOsUnknown => 'desconhecido';

  @override
  String get deviceNothingOfKind => 'Nada desse tipo ainda.';

  @override
  String deviceBattery(int level) {
    return '$level%';
  }

  @override
  String deviceBatteryCharging(int level) {
    return '$level%, carregando';
  }

  @override
  String deviceReachableUntil(String day) {
    return 'Acessível fora de casa até $day';
  }

  @override
  String get deviceLocksWhenLeave =>
      'Bloqueia quando você sai com este celular';

  @override
  String get deviceBack => 'Voltar';

  @override
  String get deviceMore => 'Mais';

  @override
  String deviceShortId(String id) {
    return 'ID $id';
  }

  @override
  String get deviceChangePicture => 'Trocar imagem';

  @override
  String get deviceAddPicture => 'Adicionar imagem';

  @override
  String get deviceRemovePicture => 'Remover imagem';

  @override
  String get deviceForgetThis => 'Esquecer este dispositivo';

  @override
  String deviceForgetTitle(String name) {
    return 'Esquecer $name?';
  }

  @override
  String get deviceForgetBody =>
      'Você vai precisar parear de novo para compartilhar com ele. A atividade dele neste celular também é apagada.';

  @override
  String get deviceForget => 'Esquecer';

  @override
  String get deviceCancel => 'Cancelar';

  @override
  String get deviceSendFiles => 'Enviar arquivos';

  @override
  String get deviceSendFilesCaption => 'Fotos, documentos, qualquer coisa';

  @override
  String get deviceClipboard => 'Área de transferência';

  @override
  String get deviceClipboardCaption => 'Envie o que você copiou';

  @override
  String get devicePing => 'Ping';

  @override
  String get devicePingCaption => 'Fazer soar';

  @override
  String get deviceRemote => 'Controle';

  @override
  String get deviceRemoteCaption => 'Touchpad e slides';

  @override
  String get deviceRinging => 'Tocando…';

  @override
  String get deviceFindIt => 'Encontrar';

  @override
  String get deviceTapToStop => 'Toque para parar';

  @override
  String get deviceFindItCaption => 'Fazer tocar bem alto';

  @override
  String get devicePrevious => 'Anterior';

  @override
  String get devicePause => 'Pausar';

  @override
  String get devicePlay => 'Reproduzir';

  @override
  String get deviceNext => 'Próxima';

  @override
  String deviceAllowOn(String name) {
    return 'Permita em $name…';
  }

  @override
  String get deviceSeeScreen => 'Ver a tela dele';

  @override
  String get deviceSeeScreenCaption => 'Assista aqui ou controle com o toque';

  @override
  String get deviceWatch => 'Assistir';

  @override
  String get deviceControl => 'Controlar';

  @override
  String get deviceTerminal => 'Terminal';

  @override
  String deviceTerminalShell(String name) {
    return 'Um shell em $name, protegido pelo código dele';
  }

  @override
  String deviceTerminalsOpen(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terminais abertos',
      one: '$count terminal aberto',
    );
    return '$_temp0';
  }

  @override
  String get deviceFilterAll => 'Tudo';

  @override
  String get deviceFilterFiles => 'Arquivos';

  @override
  String get deviceFilterClipboard => 'Área de transferência';

  @override
  String get deviceFilterLinks => 'Links';

  @override
  String get deviceFilterShowAll => 'Mostrar tudo';

  @override
  String get deviceFilterShowFiles => 'Mostrar arquivos';

  @override
  String get deviceFilterShowClipboard => 'Mostrar área de transferência';

  @override
  String get deviceFilterShowLinks => 'Mostrar links';

  @override
  String get deviceActivity => 'Atividade';

  @override
  String deviceReadyWhenAsks(String name) {
    return 'Pronto quando $name pedir';
  }

  @override
  String get deviceWebcam => 'Webcam';

  @override
  String get deviceInUseNow => 'Em uso agora';

  @override
  String get deviceControls => 'Controles';

  @override
  String get deviceMicrophone => 'Microfone';

  @override
  String get deviceStop => 'Parar';

  @override
  String get deviceSecondDisplay => 'Segunda tela';

  @override
  String get deviceShowingNow => 'Exibindo agora';

  @override
  String deviceReadySize(int width, int height) {
    return 'Pronto · $width × $height';
  }

  @override
  String get devicePhoneAs => 'Este celular como';

  @override
  String deviceStartedOn(String name) {
    return 'Iniciado em $name';
  }

  @override
  String get deviceFasterOverUsb => 'Mais rápido e estável com um cabo USB.';

  @override
  String get deviceBackUpPhotos => 'Fazer backup de fotos';

  @override
  String devicePhotosGoTo(String name) {
    return 'As fotos novas vão para a pasta Imagens de $name';
  }

  @override
  String devicePhotosDeclined(String name) {
    return '$name não aceita fotos. Ative “Importar fotos dos celulares” lá.';
  }

  @override
  String devicePhotosFrom(String folder) {
    return 'De $folder';
  }

  @override
  String get devicePhotosFromCamera => 'Da pasta da câmera';

  @override
  String devicePhotosLast(String time) {
    return 'último $time';
  }

  @override
  String get deviceGetClipboard => 'Receber a área de transferência dele';

  @override
  String deviceGetClipboardDetail(String name) {
    return 'O texto copiado em $name chega aqui enquanto estiver conectado';
  }

  @override
  String get deviceAwayAll => 'Permitir tudo fora de casa';

  @override
  String get deviceAwayAllOn =>
      'Fora de casa também: esta tela, webcam, microfone e arquivos';

  @override
  String get deviceAwayAllOff =>
      'Fora de casa: só área de transferência, links, arquivos e toque';

  @override
  String get deviceNothingShared => 'Nada compartilhado ainda';

  @override
  String deviceNothingSharedBody(String name) {
    return 'Arquivos, textos copiados e pings entre este celular e $name aparecem aqui.';
  }

  @override
  String activityItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '$count item',
    );
    return '$_temp0';
  }

  @override
  String activityQuoted(String text) {
    return '“$text”';
  }

  @override
  String get activityClipboardText => 'Texto copiado';

  @override
  String get activityPing => 'Ping';

  @override
  String get activityYourScreen => 'Sua tela';

  @override
  String get activityYourCamera => 'Sua câmera';

  @override
  String get activitySecondDisplay => 'Segunda tela';

  @override
  String get activityLink => 'Link';

  @override
  String get activityRangThisPhone => 'Fez este celular tocar';

  @override
  String get activityRangIt => 'Fez tocar';

  @override
  String get activityTouchpadKeyboard => 'Touchpad e teclado';

  @override
  String get activityItsScreen => 'A tela dele';

  @override
  String get activityYourMicrophone => 'Seu microfone';

  @override
  String get activityWhereThisPhone => 'Onde este celular está';

  @override
  String get activityWatchingNow => 'Assistindo agora';

  @override
  String get activityWatched => 'Assistida';

  @override
  String get activityInUseWebcam => 'Em uso como webcam';

  @override
  String get activityUsedWebcam => 'Usada como webcam';

  @override
  String get activityBeingControlled => 'Sendo controlada agora';

  @override
  String get activityWatchedControlled => 'Assistida e controlada';

  @override
  String get activityWatchedFromPhone => 'Assistida deste celular';

  @override
  String get activityInUseNow => 'Em uso agora';

  @override
  String get activityWasTouchpad => 'Este celular foi o touchpad dele';

  @override
  String get activityWasSecondDisplay => 'Este celular foi a segunda tela dele';

  @override
  String get activityLinkReceived => 'Link recebido';

  @override
  String get activityOpenedOnComputer => 'Aberto no computador';

  @override
  String get activityInUseMicrophone => 'Em uso como microfone';

  @override
  String get activityUsedMicrophone => 'Usado como microfone';

  @override
  String get activityNotTold => 'Não informado';

  @override
  String get activityToldWhere => 'Informou onde este celular está';

  @override
  String get activityAskedToFind => 'Pediu para encontrar este celular';

  @override
  String get activityToFindIt => 'Para encontrá-lo';

  @override
  String get activityDeclined => 'Recusado';

  @override
  String get activityFailed => 'Falhou';

  @override
  String get activityInProgress => 'Em andamento';

  @override
  String get activityCopiedHere => 'Copiado aqui';

  @override
  String get activityReceived => 'Recebido';

  @override
  String get activitySent => 'Enviado';

  @override
  String get activityStop => 'Parar';

  @override
  String get activityCancel => 'Cancelar';

  @override
  String get activityCopyAgain => 'Copiar de novo';

  @override
  String get activityCopied => 'Copiado';

  @override
  String get activityCopyLink => 'Copiar link';

  @override
  String get activityLinkCopied => 'Link copiado';

  @override
  String get activityNoAppForLink => 'Nenhum app aqui abre esse link.';

  @override
  String activityFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '$count arquivo',
    );
    return '$_temp0';
  }

  @override
  String activityFileMissing(String name) {
    return '$name não está mais lá.';
  }

  @override
  String activityNoAppForFile(String name) {
    return 'Nenhum app neste celular abre $name.';
  }

  @override
  String get activityWaitingForYou => 'Esperando você aceitar…';

  @override
  String get activityWaitingForDevice => 'Esperando o dispositivo aceitar…';

  @override
  String activityWaitingFor(String name) {
    return 'Esperando $name aceitar…';
  }

  @override
  String activityProgress(String done, String total) {
    return '$done de $total';
  }

  @override
  String get homeSettings => 'Configurações';

  @override
  String get homeYourDevices => 'Seus dispositivos';

  @override
  String get homeNearbyNotPaired => 'Por perto, não pareados';

  @override
  String get homeAddDevice => 'Adicionar dispositivo';

  @override
  String homeVisible(String name) {
    return '$name está visível neste Wi-Fi';
  }

  @override
  String get homeUpdateTitle => 'Atualize o Linksy para continuar conectando';

  @override
  String get homeUpdateBody =>
      'Seus computadores agora usam um Linksy mais novo que este app.';

  @override
  String get homeGetUpdate => 'Obter a atualização';

  @override
  String get homeSendFiles => 'Enviar arquivos';

  @override
  String get homePair => 'Parear';

  @override
  String get homeStepOpen => 'Abra o Linksy no seu computador';

  @override
  String get homeStepChoose => 'Escolha “Adicionar dispositivo”';

  @override
  String get homeStepScan => 'Escaneie com este celular';

  @override
  String get homeConnectTitle => 'Conecte seu\nprimeiro dispositivo';

  @override
  String get homeConnectSubtitle =>
      'Direto pelo seu Wi-Fi. Sem conta, sem nuvem.';

  @override
  String get homeScanQr => 'Escanear código QR';

  @override
  String get homePairByAddress => 'Parear por endereço';

  @override
  String get pairingAddDevice => 'Adicionar dispositivo';

  @override
  String get pairingAddDeviceHint =>
      'No outro dispositivo, abra o Linksy e escolha “Adicionar dispositivo”.';

  @override
  String get pairingScanQr => 'Escanear código QR';

  @override
  String get pairingScanQrCaption => 'Mais rápido. Nada para digitar.';

  @override
  String get pairingByAddress => 'Parear por endereço';

  @override
  String get pairingByAddressCaption =>
      'Quando o outro dispositivo não é encontrado.';

  @override
  String pairingWith(String name) {
    return 'Pareando com $name…';
  }

  @override
  String get pairingWithOtherDevice => 'Pareando com o outro dispositivo…';

  @override
  String get pairingAddressHint =>
      'Está nas Preferências do Linksy no outro dispositivo.';

  @override
  String pairingPortHint(String port) {
    return 'Porta $port, a menos que você informe outra.';
  }

  @override
  String get pairingPair => 'Parear';

  @override
  String pairingWantsToPair(String name) {
    return '$name quer parear';
  }

  @override
  String pairingPairWith(String name) {
    return 'Parear com $name';
  }

  @override
  String get pairingCodeHint => 'As duas telas devem mostrar este código.';

  @override
  String pairingCodeLabel(String code) {
    return 'Código $code';
  }

  @override
  String get pairingCodesMatch => 'Os códigos batem';

  @override
  String get scanNeedsCamera =>
      'O Linksy precisa da câmera para ler o código de pareamento. Permita ou pareie por endereço.';

  @override
  String get scanCameraUnavailable => 'A câmera não está disponível.';

  @override
  String get scanFlashlight => 'Lanterna';

  @override
  String get scanTitle => 'Escaneie o código';

  @override
  String get scanWrongCode =>
      'Esse não é um código do Linksy. No computador, abra Linksy → Parear com código QR.';

  @override
  String get scanHint =>
      'No computador, abra o Linksy e escolha “Adicionar dispositivo”.';

  @override
  String get shareSheetPutOnClipboard => 'Colocar em uma área de transferência';

  @override
  String shareSheetSendFiles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Enviar $count arquivos',
      one: 'Enviar $count arquivo',
    );
    return '$_temp0';
  }

  @override
  String get shareSheetOpenOnComputer => 'Abrir em um computador';

  @override
  String get shareSheetSendToClipboard =>
      'Enviar para uma área de transferência';

  @override
  String get shareSheetNoClipboardFiles =>
      'Nenhum dos seus computadores aceita arquivos na área de transferência ainda. Atualize o Linksy neles.';

  @override
  String get shareSheetNoComputers =>
      'Pareie um computador primeiro e depois compartilhe com ele de qualquer app.';

  @override
  String get shareSheetSendFileInstead => 'Enviar o arquivo';

  @override
  String get shareSheetClipboardInstead =>
      'Colocar na área de transferência do computador';

  @override
  String get shareSheetOpenLinkInstead => 'Abrir o link';

  @override
  String get shareSheetSendAsTextInstead =>
      'Enviar como texto para a área de transferência';

  @override
  String shareSheetPuttingOnClipboard(String name) {
    return 'Colocando na área de transferência de $name';
  }

  @override
  String get shareSheetPuttingOnClipboardUnnamed =>
      'Colocando na área de transferência do computador';

  @override
  String shareSheetOpened(String name) {
    return 'Aberto em $name';
  }

  @override
  String get shareSheetOpenedUnnamed => 'Aberto no computador';

  @override
  String shareSheetSentToClipboard(String name) {
    return 'Enviado para a área de transferência de $name';
  }

  @override
  String get shareSheetSentToClipboardUnnamed =>
      'Enviado para a área de transferência do computador';

  @override
  String shareSheetSentALink(String name) {
    return '$name enviou um link';
  }

  @override
  String get shareSheetOpen => 'Abrir';

  @override
  String get shareSheetCopyLink => 'Copiar link';

  @override
  String get shareSheetLinkCopied => 'Link copiado';

  @override
  String incomingSendingYou(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count arquivos',
      one: '$count arquivo',
    );
    return '$name está enviando $_temp0 para você';
  }

  @override
  String incomingTotal(String size) {
    return '$size no total';
  }

  @override
  String incomingMore(int count) {
    return '+ $count a mais';
  }

  @override
  String get incomingAccept => 'Aceitar';

  @override
  String get appInvalidPairingLink => 'Esse link de pareamento não é válido.';

  @override
  String appPairingFailed(String reason) {
    return 'O pareamento falhou: $reason';
  }

  @override
  String appCouldntPair(String name, String reason) {
    return 'Não foi possível parear com $name: $reason';
  }

  @override
  String appPairedWith(String name) {
    return 'Pareado com $name';
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
  String get appCouldntStart => 'O Linksy não conseguiu iniciar';

  @override
  String get commonDismiss => 'Dispensar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDecline => 'Recusar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonNotNow => 'Agora não';

  @override
  String get commonConnected => 'Conectado';

  @override
  String get commonNearby => 'Por perto';

  @override
  String get commonNotNearby => 'Longe';

  @override
  String get commonUsbCable => 'Cabo USB';

  @override
  String get commonAwayFromHome => 'Fora de casa';

  @override
  String get commonSameWifi => 'Mesmo Wi-Fi';

  @override
  String get commonConnectedByUsb => 'Conectado por USB';

  @override
  String get commonConnectedAway => 'Conectado fora de casa';

  @override
  String commonBattery(int level) {
    return 'Bateria em $level por cento';
  }

  @override
  String commonBatteryCharging(int level) {
    return 'Bateria em $level por cento, carregando';
  }

  @override
  String formatBytesSmall(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bytes',
      one: '$count byte',
    );
    return '$_temp0';
  }

  @override
  String formatSecondsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'faltam $count segundos',
      one: 'falta $count segundo',
    );
    return '$_temp0';
  }

  @override
  String formatMinutesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'faltam $count minutos',
      one: 'falta $count minuto',
    );
    return '$_temp0';
  }

  @override
  String formatHoursLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'faltam cerca de $count horas',
      one: 'falta cerca de $count hora',
    );
    return '$_temp0';
  }

  @override
  String get formatToday => 'Hoje';

  @override
  String get formatYesterday => 'Ontem';

  @override
  String get formatPhone => 'Celular';

  @override
  String get settingsBack => 'Voltar';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsReceiving => 'Recebimento';

  @override
  String get settingsSaveLocation => 'Local de salvamento';

  @override
  String get settingsSaveLocationPath => 'Downloads › Linksy';

  @override
  String get settingsAcceptFromMyDevices => 'Aceitar dos meus dispositivos';

  @override
  String get settingsAcceptFromMyDevicesCaption =>
      'Arquivos de dispositivos pareados chegam sem perguntar.';

  @override
  String get settingsConnection => 'Conexão';

  @override
  String get settingsStayConnected => 'Manter conectado';

  @override
  String get settingsStayConnectedCaption =>
      'Compartilhamento mais rápido com dispositivos por perto. Usa mais bateria.';

  @override
  String get settingsKeepRunning => 'Continuar em segundo plano';

  @override
  String get settingsKeepRunningCaption =>
      'Arquivos, backup de fotos e chamadas continuam funcionando com o Linksy fechado. Mostra uma notificação discreta.';

  @override
  String get settingsAwayFromHome => 'Fora de casa';

  @override
  String get settingsAwayFromHomeCaption =>
      'Acesse seus computadores pela internet quando não estiver na mesma rede, por uma semana depois da última vez que esteve. Criptografado de ponta a ponta.';

  @override
  String get settingsRelay => 'Servidor de relay';

  @override
  String get settingsRelayDefault => 'O do Linksy';

  @override
  String get settingsRelayCaption =>
      'O endereço de um relay hospedado por você, como https://relay.example.com. Deixe vazio para usar o do Linksy. Defina o mesmo relay em todos os dispositivos.';

  @override
  String get settingsWithYourComputers => 'Com seus computadores';

  @override
  String get settingsPauseMusic => 'Pausar música durante chamadas';

  @override
  String get settingsPauseMusicCaption =>
      'Seus computadores pausam o que está tocando enquanto uma chamada toca ou está em andamento, e retomam depois.';

  @override
  String get settingsBrowseFiles =>
      'Deixar computadores navegarem nos arquivos';

  @override
  String get settingsBrowseFilesChoose =>
      'Escolha uma pasta que seus computadores podem abrir no app Arquivos deles, como Documentos (o Android não permite Download).';

  @override
  String settingsSharesFolder(String folder) {
    return 'Compartilha “$folder”. Toque para escolher outra pasta.';
  }

  @override
  String get settingsPicture => 'Imagem deste celular';

  @override
  String get settingsPictureChoose =>
      'Seus computadores a mostram para este celular. Toque para escolher uma.';

  @override
  String get settingsPictureChange =>
      'Seus computadores a mostram para este celular. Toque para trocar.';

  @override
  String get settingsPictureRemove => 'Remover';

  @override
  String get settingsLocate => 'Deixar computadores localizarem este celular';

  @override
  String get settingsLocateCaption =>
      'Um computador pode perguntar onde este celular está, uma vez, para encontrá-lo. Nada é guardado nem rastreado. Funciona com o Linksy aberto.';

  @override
  String get settingsLocatePermission =>
      'O Linksy precisa da permissão de localização para isso.';

  @override
  String get settingsPhotoFolder => 'Pasta de fotos';

  @override
  String get settingsPhotoFolderChoose =>
      'Escolha a pasta da câmera (DCIM › Camera) para fazer backup das fotos em um computador.';

  @override
  String settingsPhotoFolderBacksUp(String folder) {
    return 'Faz backup de “$folder”. Ative por computador, na página dele.';
  }

  @override
  String get settingsThisApp => 'Este app';

  @override
  String get settingsPermissions => 'Permissões';

  @override
  String get settingsDemo => 'Demonstração';

  @override
  String get settingsDemoCaption =>
      'Dispositivos simulados até o núcleo do Linksy ser conectado. Eles iniciam o que outro dispositivo iniciaria.';

  @override
  String get settingsDemoReceiveFiles => 'Receber arquivos';

  @override
  String get settingsDemoReceivePairing => 'Receber um pedido de pareamento';

  @override
  String get settingsDemoReceiveClipboard => 'Receber texto copiado';

  @override
  String get settingsTagline =>
      'Seus dispositivos, conectados.\nSem conta, sem nuvem.';

  @override
  String get settingsNameTitle => 'Dê um nome a este celular';

  @override
  String get settingsNameCaption => 'Seus outros dispositivos veem este nome.';

  @override
  String get settingsSave => 'Salvar';

  @override
  String get settingsCancel => 'Cancelar';

  @override
  String settingsRename(String name) {
    return 'Renomear $name';
  }

  @override
  String settingsThisPhone(String shortId) {
    return 'Este celular · $shortId';
  }

  @override
  String get settingsPermissionsRow => 'Notificações e câmera';

  @override
  String get settingsPermissionsWhat =>
      'O que o Linksy pede ao Android, e por quê.';

  @override
  String get settingsPermissionsBoth => 'Ambas permitidas.';

  @override
  String settingsPermissionsSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de 2 permitidas. Toque para permitir o resto.',
      one: '$count de 2 permitida. Toque para permitir o resto.',
    );
    return '$_temp0';
  }

  @override
  String get permissionsTitle => 'Permissões';

  @override
  String get permissionsIntro =>
      'O Linksy pede só o que precisa, e você pode mudar qualquer uma depois em Configurações.';

  @override
  String get permissionsNotifications => 'Notificações';

  @override
  String get permissionsNotificationsWhy =>
      'Mostra quando um computador vê sua tela ou usa sua câmera, com um botão para parar.';

  @override
  String get permissionsCamera => 'Câmera';

  @override
  String get permissionsCameraWhy =>
      'Lê o código QR de pareamento e deixa um computador usar este celular como webcam quando você permitir.';

  @override
  String get permissionsAllow => 'Permitir';

  @override
  String get permissionsAllowed => 'Permitido';

  @override
  String get permissionsDone => 'Concluído';

  @override
  String get remoteBack => 'Voltar';

  @override
  String get remoteTitle => 'Controle';

  @override
  String remoteAllowOn(String name) {
    return 'Permita em $name';
  }

  @override
  String remoteAsks(String name) {
    return 'O Linksy em $name pergunta se este celular pode mover o ponteiro e digitar.';
  }

  @override
  String get remoteFailed => 'Não deu certo';

  @override
  String get remoteStopped => 'O controle parou';

  @override
  String remoteEndedBy(String name) {
    return '$name encerrou.';
  }

  @override
  String get remoteTryAgain => 'Tentar de novo';

  @override
  String get remoteTouchpad => 'Touchpad';

  @override
  String get remoteSlides => 'Slides';

  @override
  String get remoteTouchpadHint =>
      'Mova com um dedo, toque para clicar\nDois dedos rolam, toque com dois dedos clica com o botão direito';

  @override
  String get remoteLeftClick => 'Clique esquerdo';

  @override
  String get remoteRightClick => 'Clique direito';

  @override
  String get remoteKeyboard => 'Teclado';

  @override
  String get remoteNextSlide => 'Próximo slide';

  @override
  String get remoteNext => 'Próximo';

  @override
  String get remotePreviousSlide => 'Slide anterior';

  @override
  String get remoteSlideBack => 'Voltar';

  @override
  String get remoteStartShow => 'Iniciar (F5)';

  @override
  String get remoteEndShow => 'Encerrar (Esc)';

  @override
  String get remoteVolumeHint =>
      'Volume baixo: próximo · Volume alto: voltar. A tela fica ligada.';

  @override
  String get ringTitle => 'Estou aqui!';

  @override
  String ringLookingFor(String name) {
    return '$name está procurando este celular.';
  }

  @override
  String get ringFoundIt => 'Achei';

  @override
  String get webcamBack => 'Voltar';

  @override
  String get webcamTitle => 'Webcam';

  @override
  String webcamLiveOn(String name) {
    return 'Ao vivo em $name';
  }

  @override
  String get webcamStopSemantic => 'Parar a webcam';

  @override
  String get webcamStop => 'Parar';

  @override
  String get webcamBadgeLive => 'AO VIVO';

  @override
  String get webcamBadgeLock => 'AE/AF TRAVADO';

  @override
  String get webcamBadgeManualFocus => 'MF';

  @override
  String get webcamBadgeTorch => 'LANTERNA';

  @override
  String get webcamFacingFront => 'Frontal';

  @override
  String get webcamFacingBack => 'Traseira';

  @override
  String get webcamTorch => 'Lanterna';

  @override
  String get webcamPortrait => 'Retrato';

  @override
  String get webcamLandscape => 'Paisagem';

  @override
  String get webcamLocked => 'Travado';

  @override
  String get webcamLock => 'Travar';

  @override
  String get webcamTabLight => 'Luz';

  @override
  String get webcamTabFocus => 'Foco';

  @override
  String get webcamTabColor => 'Cor';

  @override
  String get webcamTabStream => 'Transmissão';

  @override
  String get webcamBrightness => 'Brilho';

  @override
  String webcamExposureValue(String value) {
    return '$value EV';
  }

  @override
  String get webcamExposureAuto => 'Esta câmera ajusta a exposição sozinha.';

  @override
  String get webcamLockExposure => 'Travar exposição';

  @override
  String get webcamLockExposureDetail =>
      'Mantém o brilho como está agora. Segure a imagem para travar em um ponto.';

  @override
  String get webcamFocus => 'Foco';

  @override
  String get webcamFocusFixed => 'Esta câmera tem foco fixo.';

  @override
  String get webcamFocusSpotDetail =>
      'Fixo onde você tocou. Toque duas vezes na imagem para o automático.';

  @override
  String get webcamFocusManualDetail => 'Ajustado à mão abaixo.';

  @override
  String get webcamFocusAutoDetail =>
      'Acompanha a imagem. Toque nela para focar em um ponto.';

  @override
  String get webcamFocusAuto => 'Auto';

  @override
  String get webcamFocusSpot => 'Ponto';

  @override
  String get webcamFocusManual => 'Manual';

  @override
  String get webcamDistance => 'Distância';

  @override
  String get webcamFar => 'Longe';

  @override
  String get webcamNear => 'Perto';

  @override
  String get webcamWbAuto => 'Auto';

  @override
  String get webcamWbDaylight => 'Luz do dia';

  @override
  String get webcamWbCloudy => 'Nublado';

  @override
  String get webcamWbShade => 'Sombra';

  @override
  String get webcamWbIncandescent => 'Luz quente';

  @override
  String get webcamWbFluorescent => 'Luz de escritório';

  @override
  String get webcamWhiteBalance => 'Balanço de branco';

  @override
  String get webcamLockColors => 'Travar cores';

  @override
  String get webcamLockColorsDetail =>
      'Impede que as cores mudem quando a luz muda.';

  @override
  String get webcamOrientation => 'Orientação';

  @override
  String get webcamOrientationPortraitDetail =>
      'Segure o celular em pé; barras nas laterais.';

  @override
  String get webcamOrientationLandscapeDetail =>
      'Segure o celular deitado; preenche o quadro.';

  @override
  String get webcamFrameRate => 'Taxa de quadros';

  @override
  String get webcamFps60Detail =>
      'Movimento mais suave; usa mais dados e bateria.';

  @override
  String get webcamFps30Detail => 'Estável para videochamadas.';

  @override
  String get webcamFpsOnly30 => 'Esta câmera vai até 30 fps.';

  @override
  String webcamFps(String fps) {
    return '$fps fps';
  }

  @override
  String get webcamResolution => 'Resolução';

  @override
  String get webcamResolution1080Detail =>
      'Full HD, para uma tela grande; mais dados.';

  @override
  String get webcamResolution720Detail => 'HD, ideal para videochamadas.';

  @override
  String get webcamResolutionOnly720 => 'Esta câmera transmite em 720p.';

  @override
  String get webcamQuality => 'Qualidade';

  @override
  String webcamQualitySaverDetail(String mbps) {
    return '$mbps Mbps, para um Wi-Fi congestionado.';
  }

  @override
  String webcamQualityHighDetail(String mbps) {
    return '$mbps Mbps, o máximo de detalhes.';
  }

  @override
  String webcamQualityStandardDetail(String mbps) {
    return '$mbps Mbps, nítido para videochamadas.';
  }

  @override
  String get webcamQualitySaver => 'Econômica';

  @override
  String get webcamQualityStandard => 'Padrão';

  @override
  String get webcamQualityHigh => 'Alta';

  @override
  String get webcamStabilization => 'Estabilização';

  @override
  String get webcamStabilizationDetail => 'Suaviza a tremedeira da mão.';

  @override
  String get webcamMirror => 'Espelhar a prévia';

  @override
  String get webcamMirrorDetail =>
      'Só neste celular; o computador recebe sem espelhar.';

  @override
  String get webcamFormat => 'Formato';

  @override
  String webcamFormatValue(String width, String height, String fps) {
    return '$width×$height · $fps fps · H.264';
  }

  @override
  String get webcamReset => 'Redefinir';

  @override
  String webcamResetSetting(String setting) {
    return 'Redefinir $setting';
  }

  @override
  String webcamZoomTo(String zoom) {
    return 'Zoom $zoom';
  }

  @override
  String sharingScreenRequestTitle(String name) {
    return '$name quer ver sua tela';
  }

  @override
  String sharingScreenRequestDetail(String name) {
    return 'Tudo na tela deste celular aparece em $name até você parar. O Android pede sua confirmação em seguida.';
  }

  @override
  String sharingControlRequestTitle(String name) {
    return '$name quer controlar sua tela';
  }

  @override
  String sharingControlRequestDetail(String name) {
    return '$name vê a tela deste celular e pode tocar, deslizar e digitar nela até você parar. O Android pede sua confirmação em seguida.';
  }

  @override
  String sharingCameraRequestTitle(String name) {
    return '$name quer usar sua câmera';
  }

  @override
  String sharingCameraRequestDetail(String name) {
    return '$name recebe a câmera deste celular como webcam até você parar. Zoom, foco, luz, lentes e rotação ficam no Linksy enquanto ela estiver ativa.';
  }

  @override
  String sharingInputRequestTitle(String name) {
    return '$name quer usar este celular como touchpad';
  }

  @override
  String get sharingInputRequestDetail =>
      'Inesperado: computadores não pedem isso. Não permita.';

  @override
  String sharingMicrophoneRequestTitle(String name) {
    return '$name quer usar seu microfone';
  }

  @override
  String sharingMicrophoneRequestDetail(String name) {
    return '$name ouve o microfone deste celular até você parar, como um microfone que qualquer app dele pode usar. O Android pede sua confirmação em seguida.';
  }

  @override
  String sharingDisplayRequestTitle(String name) {
    return '$name quer usar esta tela como segunda tela';
  }

  @override
  String sharingDisplayRequestDetail(String name) {
    return 'Este celular mostra uma tela de $name em tela cheia. Toque para clicar e arrastar; role com dois dedos. Volte para parar.';
  }

  @override
  String get sharingAllow => 'Permitir';

  @override
  String get sharingDontAllow => 'Não permitir';

  @override
  String get sharingProtectionHint =>
      'Barra superior ou notificações pretas no computador? A proteção de compartilhamento de tela do Android as esconde. Ative “Desativar proteções de compartilhamento de tela” nas Opções do desenvolvedor e compartilhe de novo.';

  @override
  String get sharingGotIt => 'Entendi';

  @override
  String get sharingDeveloperOptions => 'Opções do desenvolvedor';

  @override
  String sharingControlling(String name) {
    return '$name está controlando sua tela';
  }

  @override
  String sharingUsingCamera(String name) {
    return '$name está usando sua câmera';
  }

  @override
  String sharingUsingMicrophone(String name) {
    return '$name está usando seu microfone';
  }

  @override
  String sharingScreenWith(String name) {
    return 'Compartilhando sua tela com $name';
  }

  @override
  String get sharingTapForCameraControls => 'Toque para os controles da câmera';

  @override
  String get sharingSwitchCamera => 'Trocar câmera';

  @override
  String get sharingStopSharing => 'Parar de compartilhar';

  @override
  String get sharingStop => 'Parar';

  @override
  String get sharingCameraControls => 'Controles da câmera';

  @override
  String displaySecondHint(String name) {
    return 'Segunda tela de $name · volte para parar';
  }

  @override
  String displayControlHint(String name) {
    return 'Tela de $name · toque para clicar · volte para parar';
  }

  @override
  String displayWatchHint(String name) {
    return 'Tela de $name · volte para parar';
  }

  @override
  String terminalTabClosed(String title) {
    return '“$title” fechado';
  }

  @override
  String terminalTabEnded(String title, String name) {
    return '“$title” terminou em $name';
  }

  @override
  String get terminalCloseTitle => 'Fechar este terminal?';

  @override
  String terminalCloseDetail(String name) {
    return 'O shell termina em $name, com tudo o que ainda estiver rodando nele. Para voltar a ele depois, deixe-o rodando.';
  }

  @override
  String get terminalKeepRunning => 'Deixar rodando';

  @override
  String get terminalClose => 'Fechar';

  @override
  String get terminalTheComputer => 'o computador';

  @override
  String get terminalDetached => 'Desanexado';

  @override
  String terminalDetachedDetail(String name) {
    return 'Ainda rodando em $name. Reanexe para vê-lo de novo; o código será pedido outra vez.';
  }

  @override
  String get terminalReattach => 'Reanexar';

  @override
  String terminalOn(String name) {
    return 'Terminal em $name';
  }

  @override
  String terminalDetachedOn(String name) {
    return 'Desanexado · ainda rodando em $name';
  }

  @override
  String terminalOpeningOn(String name) {
    return 'Abrindo em $name…';
  }

  @override
  String get terminalWaitingForCode => 'Esperando o código';

  @override
  String get terminalEnded => 'Encerrado';

  @override
  String get terminalBack => 'Voltar';

  @override
  String get terminalTitle => 'Terminal';

  @override
  String get terminalMenu => 'Menu do terminal';

  @override
  String get terminalDetachMenu => 'Deixar rodando (desanexar)';

  @override
  String terminalCloseTab(String title) {
    return 'Fechar $title';
  }

  @override
  String get terminalNew => 'Novo terminal';

  @override
  String terminalShellOn(String name) {
    return 'Um shell em $name';
  }

  @override
  String get terminalShellDetail =>
      'Roda como você no computador, na sua pasta pessoal. Cada vez que abre, pede o código do terminal definido lá.';

  @override
  String get terminalStillRunning => 'AINDA RODANDO';

  @override
  String terminalReattachTab(String title) {
    return 'Reanexar $title';
  }

  @override
  String terminalStarted(String time) {
    return 'Iniciado às $time';
  }

  @override
  String get terminalKeyLeft => 'Esquerda';

  @override
  String get terminalKeyUp => 'Cima';

  @override
  String get terminalKeyDown => 'Baixo';

  @override
  String get terminalKeyRight => 'Direita';

  @override
  String get terminalCodeTitle => 'Código do terminal';

  @override
  String terminalCodeDetail(String name) {
    return 'O código definido em $name em Preferências › Terminal. O Linksy nunca o guarda.';
  }

  @override
  String get terminalCodePassphrase => 'Frase secreta';

  @override
  String get terminalCodeDigitsHint => '6 ou mais dígitos';

  @override
  String get terminalCodeUseDigits => 'Usar números';

  @override
  String get terminalCodeUseLetters => 'Usar letras';

  @override
  String get terminalOpening => 'Abrindo…';

  @override
  String get terminalOpen => 'Abrir terminal';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String usbConnectedTo(String name) {
    return 'Conectado a $name por cabo USB';
  }

  @override
  String get usbPairTitle => 'Há um computador no cabo';

  @override
  String get usbPairBody =>
      'Ele ainda não está pareado com este celular. Parear pelo cabo? As duas telas mostram um código para comparar.';

  @override
  String get usbPairAction => 'Parear';
}
