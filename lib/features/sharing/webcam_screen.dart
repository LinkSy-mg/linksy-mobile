import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/linksy_controller.dart';
import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../core/models.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';

/// The phone as a webcam, laid out like a camera app: the picture the
/// computer gets (tap to focus there, pinch to zoom, hold to lock), zoom
/// chips over it, four main actions under it, and the finer settings in
/// tabs. Changes apply live; the computer can change them too (docs/android-app.md),
/// and this screen follows.
class WebcamScreen extends StatefulWidget {
  const WebcamScreen({super.key, required this.share});

  final SessionStarted share;

  @override
  State<WebcamScreen> createState() => _WebcamScreenState();
}

enum _Tab { light, focus, color, stream }

class _WebcamScreenState extends State<WebcamScreen> {
  Map<String, Object?> _state = const {};
  int? _texture;
  StreamSubscription<(String, Map<String, Object?>)>? _changes;
  _Tab _tab = _Tab.light;
  bool _mirror = true;

  /// Where the last tap landed (0..1 of the preview), for the focus mark.
  Offset? _mark;
  int _markKey = 0;
  double _pinchStart = 1;
  bool _closing = false;

  String get _id => widget.share.session;

  @override
  void initState() {
    super.initState();
    _changes = LinksyPlatform.webcamChanges.listen((change) {
      if (change.$1 != _id || !mounted) return;
      setState(() => _state = change.$2);
      // The camera came up after this screen opened: show it now.
      if (_texture == null) _attach();
    });
    _attach();
  }

  /// The camera's state and preview. The screen can open a moment before
  /// Android's service has the camera running; it reports in then.
  bool _attaching = false;

  Future<void> _attach() async {
    if (_attaching || _texture != null) return;
    _attaching = true;
    final state = await LinksyPlatform.webcamState(_id);
    if (state != null && mounted) setState(() => _state = state);
    final texture = state == null
        ? null
        : await LinksyPlatform.webcamPreview(_id, on: true);
    _attaching = false;
    if (texture != null && mounted) setState(() => _texture = texture);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stopped from the computer or the notification.
    if (!LinksyScope.of(context).sharing.containsKey(_id) && !_closing) {
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
  }

  @override
  void dispose() {
    _changes?.cancel();
    LinksyPlatform.webcamPreview(_id, on: false);
    super.dispose();
  }

  // State, as CameraShare reports it.

  T _get<T>(String key, T fallback) {
    final v = _state[key];
    if (v is T) return v;
    if (T == double && v is num) return v.toDouble() as T;
    if (T == int && v is num) return v.toInt() as T;
    return fallback;
  }

  List<T> _list<T>(String key) =>
      (_state[key] as List? ?? const []).whereType<T>().toList();

  Iterable<Map<Object?, Object?>> get _lenses =>
      (_state['lenses'] as List? ?? const [])
          .whereType<Map<Object?, Object?>>();

  bool get _front => _get('facing', 'back') == 'front';
  bool get _portrait => _get('orientation', 'landscape') == 'portrait';
  bool get _locked => _get('exposure_lock', false);

  void _set(Map<String, Object?> controls) {
    // Show it at once; the camera's report follows.
    setState(() => _state = {..._state, ...controls});
    LinksyPlatform.webcamSet(_id, controls);
  }

  // Gestures on the picture.

  void _tap(Offset local, Size size, {bool lock = false}) {
    var x = (local.dx / size.width).clamp(0.0, 1.0);
    final y = (local.dy / size.height).clamp(0.0, 1.0);
    // The phone shows the front camera mirrored; the computer gets it as is.
    if (_front && _mirror) x = 1 - x;
    HapticFeedback.selectionClick();
    setState(() {
      _mark = Offset(local.dx / size.width, local.dy / size.height);
      _markKey++;
    });
    _set({
      'focus_point': [x, y],
      if (_list<String>('focus_modes').contains('point')) 'focus': 'point',
      'exposure_lock': lock,
    });
  }

  void _autoFocus() {
    setState(() => _mark = null);
    _set({'focus': 'auto', 'focus_point': null, 'exposure_lock': false});
  }

  @override
  Widget build(BuildContext context) {
    final c = LinksyScope.of(context);
    return Theme(
      data: buildTheme(Brightness.dark),
      child: Builder(
        builder: (context) {
          final s = Sig.of(context);
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: overlayFor(Brightness.dark),
            child: Scaffold(
              backgroundColor: s.bg,
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _header(s, c),
                    const SizedBox(height: 14),
                    _preview(),
                    const SizedBox(height: 18),
                    _actions(),
                    const SizedBox(height: 22),
                    _tabs(s),
                    const SizedBox(height: 12),
                    _tabBody(s),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Header: back, where the picture goes, Stop.

  Widget _header(Sig s, LinksyController c) => Row(
    children: [
      RoundButton(
        icon: Ph.arrowLeft,
        tooltip: context.l10n.webcamBack,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.webcamTitle, style: sora(20, color: s.ink)),
            Text(
              context.l10n.webcamLiveOn(widget.share.peer.name),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: s.muted, fontSize: 13),
            ),
          ],
        ),
      ),
      Pressable(
        onTap: () {
          _closing = true;
          c.stopSharing(_id);
          Navigator.of(context).maybePop();
        },
        semanticLabel: context.l10n.webcamStopSemantic,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: s.red,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            context.l10n.webcamStop,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ],
  );

  // The picture, as the computer gets it, with its overlays.

  Widget _preview() {
    final w = _get('width', 1280).toDouble();
    final h = _get('height', 720).toDouble();
    final texture = _texture;
    final zoom = _get('zoom', 1.0);
    return AspectRatio(
      aspectRatio: w / h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: LayoutBuilder(
          builder: (context, box) {
            final size = box.biggest;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _tap(d.localPosition, size),
              onLongPressStart: (d) {
                HapticFeedback.mediumImpact();
                _tap(d.localPosition, size, lock: true);
              },
              onDoubleTap: _autoFocus,
              onScaleStart: (_) => _pinchStart = zoom,
              onScaleUpdate: (d) {
                if (d.pointerCount < 2) return;
                final z = (_pinchStart * d.scale).clamp(
                  _get('zoom_min', 1.0),
                  _get('zoom_max', 1.0),
                );
                _set({'zoom': (z * 10).round() / 10});
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Colors.black),
                  if (texture != null)
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                        _front && _mirror ? -1 : 1,
                        1,
                        1,
                      ),
                      child: Texture(textureId: texture),
                    ),
                  if (_mark case final mark?)
                    _FocusMark(
                      key: ValueKey(_markKey),
                      at: Offset(mark.dx * size.width, mark.dy * size.height),
                      locked: _locked,
                    ),
                  // Status, top left.
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Wrap(
                      spacing: 6,
                      children: [
                        _Badge(label: context.l10n.webcamBadgeLive, live: true),
                        if (_locked)
                          _Badge(label: context.l10n.webcamBadgeLock),
                        if (_get('focus', 'auto') == 'manual')
                          _Badge(label: context.l10n.webcamBadgeManualFocus),
                        if (_get('torch', false))
                          _Badge(label: context.l10n.webcamBadgeTorch),
                      ],
                    ),
                  ),
                  // Zoom, bottom center, like a camera app.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Center(child: _zoomChips()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// The camera's zoom presets, and the phone's other lenses of this facing
  /// that the zoom doesn't reach, in one pill.
  Widget _zoomChips() {
    final zoom = _get('zoom', 1.0);
    final presets = _list<num>('zoom_presets')
        .map((n) => n.toDouble())
        .toList();
    final facing = _get('facing', 'back');
    final current = _get('lens', '');
    final others = _lenses
        .where((l) => l['facing'] == facing && l['id'] != current)
        .where(
          (l) => !presets.any(
            (p) => (p - (l['zoom'] as num).toDouble()).abs() < 0.15,
          ),
        )
        .toList();
    if (presets.length + others.length <= 1) return const SizedBox.shrink();
    // The active chip shows the exact zoom while pinching between presets.
    final nearest = presets.isEmpty
        ? null
        : presets.reduce(
            (a, b) => (a - zoom).abs() <= (b - zoom).abs() ? a : b,
          );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x990A1024),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final p in presets)
            _ZoomChip(
              label: p == nearest ? _zoomLabel(zoom) : _zoomLabel(p),
              selected: p == nearest,
              onTap: () => _set({'zoom': p}),
            ),
          for (final l in others)
            _ZoomChip(
              label: _zoomLabel((l['zoom'] as num).toDouble()),
              selected: false,
              onTap: () => _set({'lens': l['id']}),
            ),
        ],
      ),
    );
  }

  static String _zoomLabel(double z) {
    final r = (z * 10).round() / 10;
    return r == r.roundToDouble() ? '${r.round()}×' : '$r×';
  }

  // The four main actions.

  Widget _actions() {
    final l = context.l10n;
    final canFlip =
        _lenses.any((l) => l['facing'] == 'front') &&
        _lenses.any((l) => l['facing'] == 'back');
    return Row(
      children: [
        Expanded(
          child: _Action(
            icon: Ph.cameraRotate,
            label: _front ? l.webcamFacingFront : l.webcamFacingBack,
            enabled: canFlip,
            onTap: () => _set({'facing': _front ? 'back' : 'front'}),
          ),
        ),
        Expanded(
          child: _Action(
            icon: Ph.flashlight,
            label: l.webcamTorch,
            on: _get('torch', false),
            enabled: _get('has_torch', false),
            onTap: () => _set({'torch': !_get('torch', false)}),
          ),
        ),
        Expanded(
          child: _Action(
            icon: _portrait ? Ph.deviceMobile : Ph.monitor,
            label: _portrait ? l.webcamPortrait : l.webcamLandscape,
            onTap: () =>
                _set({'orientation': _portrait ? 'landscape' : 'portrait'}),
          ),
        ),
        Expanded(
          child: _Action(
            icon: Ph.lockSimple,
            label: _locked ? l.webcamLocked : l.webcamLock,
            on: _locked,
            onTap: () => _set({
              'exposure_lock': !_locked,
              'white_balance_lock': !_locked,
            }),
          ),
        ),
      ],
    );
  }

  // Settings, in tabs.

  Widget _tabs(Sig s) {
    final labels = [
      context.l10n.webcamTabLight,
      context.l10n.webcamTabFocus,
      context.l10n.webcamTabColor,
      context.l10n.webcamTabStream,
    ];
    return Segments(
      labels: labels,
      selected: _tab.index,
      onChanged: (i) => setState(() => _tab = _Tab.values[i]),
      pill: s.raised,
      height: 38,
      builder: (context, i, on) => Text(
        labels[i],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: Color.lerp(s.muted, s.ink, on),
        ),
      ),
    );
  }

  Widget _tabBody(Sig s) {
    final rows = switch (_tab) {
      _Tab.light => _light(),
      _Tab.focus => _focus(s),
      _Tab.color => _color(),
      _Tab.stream => _stream(),
    };
    return SigCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AnimatedSize(
        duration: motion(context, 180),
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: motion(context, 150),
          layoutBuilder: (current, previous) => Stack(
            alignment: Alignment.topCenter,
            children: [...previous, ?current],
          ),
          child: Column(
            key: ValueKey(_tab),
            children: [
              for (var i = 0; i < rows.length; i++)
                _Divided(last: i == rows.length - 1, child: rows[i]),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _light() {
    final l = context.l10n;
    final min = _get('exposure_min', 0);
    final max = _get('exposure_max', 0);
    final step = _get('exposure_step', 0.0);
    final ev = _get('exposure', 0);
    final value = ev * step;
    return [
      if (max > min)
        _Setting(
          title: l.webcamBrightness,
          value: l.webcamExposureValue(
            '${value >= 0 ? '+' : '−'}${value.abs().toStringAsFixed(1)}',
          ),
          onReset: ev == 0 ? null : () => _set({'exposure': 0}),
          below: Slider(
            value: ev.toDouble().clamp(min.toDouble(), max.toDouble()),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => _set({'exposure': v.round()}),
          ),
        )
      else
        _Setting(title: l.webcamBrightness, detail: l.webcamExposureAuto),
      _Setting(
        title: l.webcamLockExposure,
        detail: l.webcamLockExposureDetail,
        trailing: Switch(
          value: _locked,
          onChanged: (v) => _set({'exposure_lock': v}),
        ),
      ),
    ];
  }

  List<Widget> _focus(Sig s) {
    final l = context.l10n;
    final modes = _list<String>('focus_modes');
    final focus = _get('focus', 'auto');
    if (modes.length <= 1) {
      return [_Setting(title: l.webcamFocus, detail: l.webcamFocusFixed)];
    }
    return [
      _Setting(
        title: l.webcamFocus,
        detail: switch (focus) {
          'point' => l.webcamFocusSpotDetail,
          'manual' => l.webcamFocusManualDetail,
          _ => l.webcamFocusAutoDetail,
        },
        below: _Segmented(
          options: [
            ('auto', l.webcamFocusAuto),
            if (modes.contains('point')) ('point', l.webcamFocusSpot),
            if (modes.contains('manual')) ('manual', l.webcamFocusManual),
          ],
          selected: focus,
          onChanged: (m) => m == 'auto'
              ? _autoFocus()
              : _set({
                  'focus': m,
                  if (m == 'point' && _state['focus_point'] == null)
                    'focus_point': [0.5, 0.5],
                }),
        ),
      ),
      if (focus == 'manual')
        _Setting(
          title: l.webcamDistance,
          below: Row(
            children: [
              Text(
                l.webcamFar,
                style: TextStyle(color: s.muted, fontSize: 12.5),
              ),
              Expanded(
                child: Slider(
                  value: _get('focus_distance', 0.0).clamp(0.0, 1.0),
                  onChanged: (v) => _set({'focus_distance': v}),
                ),
              ),
              Text(
                l.webcamNear,
                style: TextStyle(color: s.muted, fontSize: 12.5),
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _color() {
    final l = context.l10n;
    final names = {
      'auto': l.webcamWbAuto,
      'daylight': l.webcamWbDaylight,
      'cloudy': l.webcamWbCloudy,
      'shade': l.webcamWbShade,
      'incandescent': l.webcamWbIncandescent,
      'fluorescent': l.webcamWbFluorescent,
    };
    final modes = _list<String>('white_balances');
    final wb = _get('white_balance', 'auto');
    return [
      _Setting(
        title: l.webcamWhiteBalance,
        below: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in modes)
              _Pill(
                label: names[m] ?? m,
                selected: wb == m,
                onTap: () => _set({'white_balance': m}),
              ),
          ],
        ),
      ),
      _Setting(
        title: l.webcamLockColors,
        detail: l.webcamLockColorsDetail,
        trailing: Switch(
          value: _get('white_balance_lock', false),
          onChanged: (v) => _set({'white_balance_lock': v}),
        ),
      ),
    ];
  }

  /// The bitrate a quality gets at the current frame rate and size (more at
  /// 60 fps and at 1080p).
  String _mbps(int base) {
    var v = _get('fps', 30) >= 60 ? base * 1.5 : base.toDouble();
    if (_get('width', 1280) >= 1920) v *= 1.5;
    return v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
  }

  /// The camera lists 1920×1080 in `size_options`.
  bool get _can1080 =>
      _list<Object?>('size_options')
          .any((o) => o is List && o.isNotEmpty && (o.first as num) >= 1920);

  List<Widget> _stream() {
    final l = context.l10n;
    final w = _get('width', 1280);
    final h = _get('height', 720);
    return [
      _Setting(
        title: l.webcamOrientation,
        detail: _portrait
            ? l.webcamOrientationPortraitDetail
            : l.webcamOrientationLandscapeDetail,
        below: _Segmented(
          options: [
            ('landscape', l.webcamLandscape),
            ('portrait', l.webcamPortrait),
          ],
          selected: _portrait ? 'portrait' : 'landscape',
          onChanged: (o) => _set({'orientation': o}),
        ),
      ),
      _Setting(
        title: l.webcamFrameRate,
        detail: _list<num>('fps_options').contains(60)
            ? (_get('fps', 30) >= 60
                  ? l.webcamFps60Detail
                  : l.webcamFps30Detail)
            : l.webcamFpsOnly30,
        below: _list<num>('fps_options').contains(60)
            ? _Segmented(
                options: [('30', l.webcamFps('30')), ('60', l.webcamFps('60'))],
                selected: '${_get('fps', 30)}',
                onChanged: (f) => _set({'fps': int.parse(f)}),
              )
            : null,
      ),
      _Setting(
        title: l.webcamResolution,
        detail: _can1080
            ? (w >= 1920
                  ? l.webcamResolution1080Detail
                  : l.webcamResolution720Detail)
            : l.webcamResolutionOnly720,
        below: _can1080
            ? _Segmented(
                options: const [('720', '720p'), ('1080', '1080p')],
                selected: w >= 1920 ? '1080' : '720',
                onChanged: (r) => _set({
                  'size': r == '1080' ? [1920, 1080] : [1280, 720],
                }),
              )
            : null,
      ),
      _Setting(
        title: l.webcamQuality,
        detail: switch (_get('quality', 'standard')) {
          'saver' => l.webcamQualitySaverDetail(_mbps(2)),
          'high' => l.webcamQualityHighDetail(_mbps(8)),
          _ => l.webcamQualityStandardDetail(_mbps(4)),
        },
        below: _Segmented(
          options: [
            ('saver', l.webcamQualitySaver),
            ('standard', l.webcamQualityStandard),
            ('high', l.webcamQualityHigh),
          ],
          selected: _get('quality', 'standard'),
          onChanged: (q) => _set({'quality': q}),
        ),
      ),
      if (_get('has_stabilization', false))
        _Setting(
          title: l.webcamStabilization,
          detail: l.webcamStabilizationDetail,
          trailing: Switch(
            value: _get('stabilization', false),
            onChanged: (v) => _set({'stabilization': v}),
          ),
        ),
      if (_front)
        _Setting(
          title: l.webcamMirror,
          detail: l.webcamMirrorDetail,
          trailing: Switch(
            value: _mirror,
            onChanged: (v) => setState(() => _mirror = v),
          ),
        ),
      _Setting(
        title: l.webcamFormat,
        value: l.webcamFormatValue('$w', '$h', '${_get('fps', 30)}'),
      ),
    ];
  }
}

/// A row of the settings card, with a thin line under all but the last.
class _Divided extends StatelessWidget {
  const _Divided({required this.child, required this.last});

  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: last
          ? null
          : Border(bottom: BorderSide(color: Sig.of(context).line)),
    ),
    child: child,
  );
}

/// One setting: its title (with a value, Reset or a switch) on the first
/// line, an explanation under it, and its control below.
class _Setting extends StatelessWidget {
  const _Setting({
    required this.title,
    this.detail,
    this.value,
    this.trailing,
    this.below,
    this.onReset,
  });

  final String title;
  final String? detail;
  final String? value;
  final Widget? trailing;
  final Widget? below;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: s.ink,
                      ),
                    ),
                    if (detail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail!,
                        style: TextStyle(
                          color: s.muted,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onReset != null)
                Pressable(
                  onTap: onReset,
                  semanticLabel: context.l10n.webcamResetSetting(title),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      context.l10n.webcamReset,
                      style: const TextStyle(
                        color: Sig.cyan,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: s.muted,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ?trailing,
            ],
          ),
          if (below != null) ...[const SizedBox(height: 10), below!],
        ],
      ),
    );
  }
}

/// A few exclusive choices in one track.
class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Segments(
      labels: [for (final (_, label) in options) label],
      selected: options.indexWhere((o) => o.$1 == selected),
      onChanged: (i) => onChanged(options[i].$1),
      track: s.raised,
      height: 36,
      radius: Radii.md,
      inset: 3,
      builder: (context, i, on) => Text(
        options[i].$2,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: Color.lerp(s.muted, Colors.white, on),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: AnimatedContainer(
        duration: motion(context, 160),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Sig.blue : s.raised,
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedDefaultTextStyle(
          duration: motion(context, 160),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
            color: selected ? Colors.white : s.ink,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _ZoomChip extends StatelessWidget {
  const _ZoomChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    semanticLabel: context.l10n.webcamZoomTo(label),
    child: AnimatedContainer(
      duration: motion(context, 160),
      curve: Curves.easeOutCubic,
      width: selected ? 44 : 36,
      height: selected ? 44 : 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? Colors.white : const Color(0x33FFFFFF),
      ),
      child: AnimatedDefaultTextStyle(
        duration: motion(context, 160),
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: selected ? 12.5 : 11,
          color: selected ? Sig.deep : Colors.white,
        ),
        child: Text(label),
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.live = false});

  final String label;
  final bool live;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xB30A1024),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (live) ...[
          const PulseDot(color: Color(0xFFFF5C72), size: 6),
          const SizedBox(width: 5),
        ],
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    ),
  );
}

/// A main action: an icon in a circle, its name under it.
class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.on = false,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool on;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.35,
      duration: motion(context, 150),
      child: Pressable(
        onTap: enabled ? onTap : null,
        scale: 0.92,
        semanticLabel: label,
        child: Column(
          children: [
            AnimatedContainer(
              duration: motion(context, 180),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? Sig.blue : s.card,
              ),
              child: AnimatedSwitcher(
                duration: motion(context, 180),
                transitionBuilder: popIn,
                child: Icon(
                  icon,
                  key: ValueKey((icon, on)),
                  size: 24,
                  color: on ? Colors.white : s.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: motion(context, 180),
              child: Text(
                label,
                key: ValueKey((label, on)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: on ? s.ink : s.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the camera focuses: a square that settles, cyan while locked.
class _FocusMark extends StatelessWidget {
  const _FocusMark({super.key, required this.at, required this.locked});

  final Offset at;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    final color = locked ? Sig.cyan : Colors.white;
    return Positioned(
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.35, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          builder: (context, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Center(
              child: Transform.rotate(
                angle: math.pi / 4,
                child: Container(width: 6, height: 6, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
