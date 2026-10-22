/// Reads linksy-core's JSON (its serde shapes, the same as the desktop IPC)
/// into the app's models. Unknown event types come back as null, so a newer
/// core never breaks the app.
library;

import 'models.dart';

typedef Json = Map<String, Object?>;

DeviceInfo deviceFromJson(Json j) => DeviceInfo(
  id: j['id'] as String,
  name: j['name'] as String,
  kind: DeviceKind.parse(j['kind'] as String? ?? ''),
  os: j['os'] as String? ?? '',
  features: (j['features'] as List? ?? const []).cast<String>(),
);

DeviceView deviceViewFromJson(Json j) => DeviceView(
  device: deviceFromJson(j['device'] as Json),
  trusted: j['trusted'] as bool? ?? false,
  connected: j['connected'] as bool? ?? false,
  nearby: j['nearby'] as bool? ?? false,
  battery: switch (j['battery']) {
    final Json b => batteryFromJson(b),
    _ => null,
  },
  usb: j['usb'] as bool? ?? false,
  away: j['away'] as bool? ?? false,
  awayAll: j['away_all'] as bool? ?? false,
  awayUntil: switch (j['away_until']) {
    final num s => DateTime.fromMillisecondsSinceEpoch(s.toInt() * 1000),
    _ => null,
  },
);

MediaState mediaStateFromJson(Json j) => MediaState(
  seq: _int(j['seq']),
  players: [
    for (final p in (j['players'] as List? ?? const []).cast<Json>())
      MediaPlayer(
        id: p['id'] as String,
        app: p['app'] as String? ?? '',
        title: p['title'] as String? ?? '',
        artist: p['artist'] as String? ?? '',
        album: p['album'] as String? ?? '',
        playing: p['playing'] as bool? ?? false,
        positionMs: (p['position_ms'] as num?)?.toInt(),
        lengthMs: (p['length_ms'] as num?)?.toInt(),
        canNext: p['can_next'] as bool? ?? false,
        canPrevious: p['can_previous'] as bool? ?? false,
        canSeek: p['can_seek'] as bool? ?? false,
        art: p['art'] as String?,
      ),
  ],
);

Battery batteryFromJson(Json j) => Battery(
  level: _int(j['level']).clamp(0, 100),
  charging: j['charging'] as bool? ?? false,
);

NodeSettings settingsFromJson(Json j) => NodeSettings(
  name: j['name'] as String,
  downloadDir: j['download_dir'] as String,
  stayConnected: j['stay_connected'] as bool? ?? false,
  autoAccept: j['auto_accept'] as bool? ?? false,
  away: j['away'] as bool? ?? true,
  relay: j['relay'] as String?,
);

Json settingsToJson(NodeSettings s) => {
  'name': s.name,
  'download_dir': s.downloadDir,
  'stay_connected': s.stayConnected,
  'auto_accept': s.autoAccept,
  'away': s.away,
  'relay': s.relay,
};

List<OfferedFile> _files(Object? list) => [
  for (final f in (list as List? ?? const []).cast<Json>())
    OfferedFile(path: f['path'] as String, size: (f['size'] as num).toInt()),
];

int _int(Object? n) => (n as num? ?? 0).toInt();

LinksyEvent? eventFromJson(Json j) {
  DeviceInfo device([String key = 'device']) => deviceFromJson(j[key] as Json);
  return switch (j['type']) {
    'device_found' => DeviceFound(device()),
    'device_lost' => DeviceLost(j['id'] as String),
    'device_updated' => DeviceUpdated(device()),
    'connected' => Connected(device().id),
    'disconnected' => Disconnected(j['id'] as String),
    'pairing_request' => PairingRequest(
      request: j['request'] as String,
      device: device(),
      code: j['code'] as String,
      incoming: j['incoming'] as bool? ?? false,
    ),
    'paired' => Paired(device()),
    'pairing_failed' => PairingFailed(
      device: device(),
      reason: j['reason'] as String? ?? '',
    ),
    'transfer_request' => TransferRequest(
      transfer: j['transfer'] as String,
      from: device('from'),
      files: _files(j['files']),
      total: _int(j['total']),
    ),
    'transfer_started' => TransferStarted(
      j['transfer'] as String,
      peer: device('peer'),
      incoming: j['direction'] == 'incoming',
      files: _files(j['files']),
      total: _int(j['total']),
    ),
    'transfer_progress' => TransferProgress(
      transfer: j['transfer'] as String,
      bytes: _int(j['bytes']),
      total: _int(j['total']),
    ),
    'transfer_complete' => TransferComplete(
      transfer: j['transfer'] as String,
      saved: (j['saved'] as List? ?? const []).cast<String>(),
    ),
    'transfer_failed' => TransferFailed(
      transfer: j['transfer'] as String,
      reason: j['reason'] as String? ?? '',
    ),
    'settings_changed' => SettingsChanged(
      settingsFromJson(j['settings'] as Json),
    ),
    'notification' => NotificationReceived(
      from: device('from'),
      title: j['title'] as String? ?? '',
      body: j['body'] as String? ?? '',
    ),
    'clipboard' => ClipboardReceived(
      from: device('from'),
      text: j['text'] as String? ?? '',
    ),
    'session_request' => switch (SessionKind.parse(j['kind'] as String)) {
      final kind? => SessionRequest(
        request: j['request'] as String,
        from: device('from'),
        kind: kind,
      ),
      null => null,
    },
    'session_started' => switch (SessionKind.parse(j['kind'] as String)) {
      final kind? => SessionStarted(
        session: j['session'] as String,
        peer: device('peer'),
        kind: kind,
        sharing: j['sharing'] as bool? ?? false,
      ),
      null => null,
    },
    'session_ended' => SessionEnded(j['session'] as String),
    'open_url' => OpenUrlReceived(
      from: device('from'),
      url: j['url'] as String,
    ),
    'battery' => BatteryReported(
      from: device('from'),
      battery: batteryFromJson(j['battery'] as Json),
    ),
    'ring' => RingRequested(from: device('from'), on: j['on'] as bool? ?? true),
    'media_state' => MediaStateReceived(
      from: device('from'),
      state: mediaStateFromJson(j['state'] as Json),
    ),
    'heartbeat_watch' => HeartbeatWatchChanged(
      from: device('from'),
      on: j['on'] as bool? ?? false,
      everyS: _int(j['every_s']),
    ),
    'picture' => PictureReceived(
      from: device('from'),
      image: j['image'] as String? ?? '',
    ),
    'locate_request' => LocateRequested(device('from')),
    'clipboard_watch' => ClipboardWatchChanged(
      from: device('from'),
      on: j['on'] as bool? ?? false,
    ),
    'clipboard_file' => ClipboardFileReceived(
      from: device('from'),
      path: j['path'] as String,
    ),
    _ => null,
  };
}
