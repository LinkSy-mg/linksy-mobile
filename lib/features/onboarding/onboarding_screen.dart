import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/platform.dart';
import '../../app/scope.dart';
import '../../ui/components.dart';
import '../../ui/l10n.dart';
import '../../ui/sig.dart';
import '../settings/turn_on.dart';
import 'language_wheel.dart';

/// The first run: the language, then what Linksy may do, each with a word on
/// why. Everything here can be changed later in Settings.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;

  void _go(int page) {
    setState(() => _page = page);
    _pages.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await LinksyScope.read(context).finishOnboarding();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back goes to the language, not out of setup.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _page > 0) _go(0);
      },
      child: Scaffold(
        body: SafeArea(
          child: PageView(
            controller: _pages,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _LanguagePage(onContinue: () => _go(1)),
              _SetUpPage(onBack: () => _go(0), onDone: _finish),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 2; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == page ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == page ? Sig.blue : s.line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final t = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: LinksyMark(size: 52)),
          const SizedBox(height: 20),
          // Each language crossfades into the next as the wheel turns.
          AnimatedSwitcher(
            duration: motion(context, 150),
            child: Column(
              key: ValueKey(t.localeName),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.onboardingWelcome,
                  textAlign: TextAlign.center,
                  style: sora(30, weight: FontWeight.w700, color: s.ink),
                ),
                const SizedBox(height: 8),
                Text(
                  t.onboardingChooseLanguage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: s.muted),
                ),
              ],
            ),
          ),
          const Spacer(),
          LanguageWheel(
            selected: c.locale.value.languageCode,
            onChanged: c.setLanguage,
          ),
          const Spacer(),
          Text(
            t.onboardingLanguageHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: s.muted),
          ),
          const SizedBox(height: 14),
          SigButton(
            label: t.onboardingContinue,
            expand: true,
            onTap: onContinue,
          ),
          const SizedBox(height: 16),
          const _Dots(page: 0),
        ],
      ),
    );
  }
}

class _SetUpPage extends StatefulWidget {
  const _SetUpPage({required this.onBack, required this.onDone});

  final VoidCallback onBack;
  final VoidCallback onDone;

  @override
  State<_SetUpPage> createState() => _SetUpPageState();
}

class _SetUpPageState extends State<_SetUpPage> with WidgetsBindingObserver {
  ({bool notifications, bool camera})? _granted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _read();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from Android's settings: read again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _read();
  }

  Future<void> _read() async {
    final granted = await LinksyPlatform.permissions();
    if (mounted) setState(() => _granted = granted);
  }

  Future<void> _ask(String name) async {
    await LinksyPlatform.requestPermission(name);
    await _read();
  }

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    final c = LinksyScope.of(context);
    final t = context.l10n;
    final st = c.settings;

    Widget allow(bool? granted, String name) => granted == true
        ? _Granted(label: t.onboardingAllowed)
        : _SmallButton(label: t.onboardingAllow, onTap: () => _ask(name));

    // For the computer's tabs: on, or the way to turn them on.
    Widget turnOnRow(bool on, String feature) => on
        ? _Granted(label: t.onboardingAllowed)
        : _SmallButton(
            label: t.onboardingAllow,
            onTap: () => turnOn(context, feature),
          );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
          child: Row(
            children: [
              RoundButton(
                icon: Ph.arrowLeft,
                tooltip: t.onboardingBack,
                onTap: widget.onBack,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Text(
                  t.onboardingSetUpTitle,
                  style: sora(30, weight: FontWeight.w700, color: s.ink),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 18),
                child: Text(
                  t.onboardingSetUpSubtitle,
                  style: TextStyle(fontSize: 15, color: s.muted, height: 1.4),
                ),
              ),
              _Group(
                children: [
                  _Item(
                    icon: Ph.bellRinging,
                    title: t.onboardingNotifications,
                    detail: t.onboardingNotificationsDetail,
                    trailing: allow(_granted?.notifications, 'notifications'),
                  ),
                  _Item(
                    icon: Ph.videoCamera,
                    title: t.onboardingCamera,
                    detail: t.onboardingCameraDetail,
                    trailing: allow(_granted?.camera, 'camera'),
                  ),
                  _Item(
                    icon: Ph.chatCircleText,
                    title: t.onboardingMessages,
                    detail: t.onboardingMessagesDetail,
                    trailing: turnOnRow(c.mirroring, 'notifications'),
                  ),
                  _Item(
                    icon: Ph.imagesSquare,
                    title: t.settingsGallery,
                    detail: t.onboardingGalleryDetail,
                    trailing: turnOnRow(c.gallery, 'gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Group(
                children: [
                  _Item(
                    icon: Ph.globeHemisphereWest,
                    title: t.onboardingAway,
                    detail: t.onboardingAwayDetail,
                    trailing: Switch(
                      value: st?.away ?? true,
                      onChanged: st == null
                          ? null
                          : (v) => c.updateSettings(st.copyWith(away: v)),
                    ),
                  ),
                  _Item(
                    icon: Ph.deviceMobile,
                    title: t.onboardingBackground,
                    detail: t.onboardingBackgroundDetail,
                    trailing: Switch(
                      value: c.stayRunning,
                      onChanged: c.setStayRunning,
                    ),
                  ),
                  _Item(
                    icon: Ph.mapPin,
                    title: t.onboardingLocate,
                    detail: t.onboardingLocateDetail,
                    trailing: Switch(
                      value: c.locatable,
                      onChanged: (v) => c.setLocatable(v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Group(
                children: [
                  _Item(
                    icon: Ph.folderOpen,
                    title: t.onboardingFolder,
                    detail: c.filesFolder == null
                        ? t.onboardingFolderDetail
                        : t.onboardingFolderChosen(c.filesFolder!),
                    trailing: c.filesFolder == null
                        ? _SmallButton(
                            label: t.onboardingChooseFolder,
                            onTap: c.pickFilesFolder,
                          )
                        : _Granted(label: t.onboardingAllowed),
                  ),
                  _Item(
                    icon: Ph.images,
                    title: t.onboardingPhotos,
                    detail: c.photosFolder == null
                        ? t.onboardingPhotosDetail
                        : t.onboardingFolderChosen(c.photosFolder!),
                    trailing: c.photosFolder == null
                        ? _SmallButton(
                            label: t.onboardingChooseFolder,
                            onTap: c.pickPhotosFolder,
                          )
                        : _Granted(label: t.onboardingAllowed),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Sig.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Row(
                  children: [
                    const Icon(Ph.gearSix, color: Sig.blue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.onboardingAnytime,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: s.ink,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
          child: Column(
            children: [
              SigButton(
                label: t.onboardingStart,
                expand: true,
                onTap: widget.onDone,
              ),
              const SizedBox(height: 16),
              const _Dots(page: 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    return SigCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: s.line),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.title,
    required this.detail,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final s = Sig.of(context);
    // A switch row toggles from anywhere on it, and clicks like a tap.
    var trailing = this.trailing;
    VoidCallback? onTap;
    if (trailing case Switch(:final value, onChanged: final changed?)) {
      trailing = Switch(
        value: value,
        onChanged: (v) {
          HapticFeedback.selectionClick();
          changed(v);
        },
      );
      onTap = () => changed(!value);
    }
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          Icon(icon, color: Sig.blue, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: s.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: TextStyle(fontSize: 13, color: s.muted, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Allow turns into Allowed.
          AnimatedSwitcher(
            duration: motion(context),
            transitionBuilder: popIn,
            child: KeyedSubtree(
              key: ValueKey(trailing.runtimeType),
              child: trailing,
            ),
          ),
        ],
      ),
    );
    return onTap == null ? row : Pressable(onTap: onTap, child: row);
  }
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SmallAction(
    label: label,
    onTap: onTap,
    color: Colors.white,
    fill: Sig.blue,
  );
}

class _Granted extends StatelessWidget {
  const _Granted({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(PhBold.check, color: Sig.cyan, size: 18),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          color: Sig.cyan,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
      ),
    ],
  );
}
