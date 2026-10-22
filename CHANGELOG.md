# Changelog

All notable changes to Linksy for Android. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow [SemVer](https://semver.org/).

## [Unreleased]

### Added
- **Your own relay**: Settings › Connection › Relay server takes the address of a relay you host (`linksy-server`), like `https://relay.example.com`; empty means Linksy's own. Set the same one on your computers.

## [0.2.2] - 2026-10-22

### Added
- **Pair over the USB cable**: when a computer that isn't paired yet is on the cable, Linksy offers to pair with it there. Both screens show a code to compare.
- "Connected to … by USB cable" when the cable connects.

### Fixed
- **USB cable on phones that never show the "open with Linksy" prompt** (realme, ColorOS…): with Linksy open, the cable is found within a second or two, and Linksy asks for permission to use it.
- A cable plugged in while Linksy was starting is no longer missed.
- Text that names something on the computer uses the computer's own words, in every language ("Add Device", Preferences › Terminal, "Allow Everything From Away", "Import Photos From Phones").

## [0.2.1] - 2026-10-22

### Added
- **10 languages**: English, Français, Malagasy, Español, Português, Deutsch, Italiano, Русский, 中文 and 日本語, for the whole app and its notifications. Pick one on a scrolling wheel; it changes as you scroll. Settings › Language changes it later.
- **First-run setup**: after the language, one page with what Linksy may do (notifications, camera, away from home, keep running in the background, let computers locate the phone, a shared folder, the photo folder), each explained. Everything can be turned on or off later in Settings.
- **Appearance**: System, Light or Dark, in Settings.
- **Terminal**: prompt icons from Nerd Fonts show properly (starship, powerline, oh-my-posh…), in JetBrains Mono. Pinch with two fingers to make the text smaller or bigger, for wide output like fastfetch; the size is kept.

### Removed
- The push token row in Settings (news from Linksy still arrives as notifications).

### Fixed
- After a wrong terminal code, the field is ready to type again.
- The share sheet says how each computer is reached ("Same Wi-Fi"), like home.

## [0.2.0] - 2026-10-22

### Added
- **Terminal works**: with Linksy 0.7 on your computer (not its Flatpak), open a shell on it from the phone. Turn on Allow Terminal for this phone and set a terminal code on the computer, then tap Terminal on its page here. Wrong codes say how many tries are left; up to 8 terminals at once; leave and come back to reattach.

### Changed
- On a computer's page, how it's connected is a small line under its kind, without the pill.
- After a wrong terminal code, the field is ready to type again straight away.
- Up to date with Linksy 0.7.0 on the computer.

### Fixed
- Closing a terminal could stop at "Ended" without ending the shell on the computer.

## [0.1.20] - 2026-10-22

### Changed
- **Closing a terminal is obvious**: a Close button at the top and a × on each tab. It asks first, and offers to keep it running instead. Closing ends the shell on the computer and the connection behind it, so nothing is left hanging; a detached terminal is reopened (with the code) to end it.
- **Typing `exit`** (or anything that ends the shell) closes its tab here too, and says so.
- If the connection drops, a terminal shows as detached (still running on the computer) instead of ended.

## [0.1.19] - 2026-10-22

### Added
- **Terminal, ready for Linksy 0.7 on the computer**: a shell on your computer from the phone. It asks for the terminal code set on the computer every time (never kept), says plainly why it can't open (wrong code and tries left, locked, not allowed), shows colours, follows the window title, has a key bar (Esc, Ctrl, Alt, Tab, arrows, `| ~ / -`), several tabs, and detaches when you leave: the shell keeps running on the computer and you reattach later. It appears on computers that offer it, so not before their Linksy 0.7.

### Changed
- Up to date with Linksy 0.6.4 on the computer.

## [0.1.18] - 2026-10-22

### Fixed
- In a computer's activity, the time and the dot on the timeline now line up with each entry's icon.

## [0.1.17] - 2026-10-21

### Changed
- **Clearer computer pages**, in the spirit of the new desktop design:
  - How it's connected sits above the name ("Same Wi-Fi", "Away from home", "USB cable"), with its battery and kind on one line below.
  - **This phone as**: one card shows the webcam, microphone and second display, what's in use (with Controls or Stop) and what's ready.
  - Photo backup, "Get its clipboard" and "Allow everything from away" share one card instead of three.
  - **Activity** has filters (All, Files, Clipboard, Links); files and what's running keep their card, small things (pings, links, copied text) are plain lines.
- **Home**: each computer's battery is a ring around its picture, and the list says how it's connected ("Same Wi-Fi · 82%").

## [0.1.16] - 2026-10-21

### Added
- **Black top bar or notifications on the computer while sharing the screen?** On some phones (realme, for one) Android's screen share protection hides them from every app. While it's on, Linksy now says so under the sharing banner, with a button to Developer options, where "Disable screen share protections" brings them back.

## [0.1.15] - 2026-10-21

### Added
- **Up to date with Linksy 0.6 on the computer** (new core).
- **Away from home**: reach your computers over the internet when you're not on the same Wi-Fi, encrypted end to end through Linksy's relay. A switch in Settings; per computer, "Allow everything from away" (screen, webcam, microphone and files from away too); "Connected away from home" and "Reachable from away until …" on its page.
- **Phone as microphone**: a computer can use this phone as its microphone once you allow it. Keeps going with the screen off; Stop from the banner or the notification.
- **1080p webcam** where the camera does it (Webcam › Stream › Resolution, or from the computer), and lower webcam latency.
- **Picture of this phone** (Settings): your computers show it for this phone. Computers' own pictures now show here too, unless you chose one.
- **Files and images on the clipboard**: a file a computer puts on this phone's clipboard is ready to paste; share one file (up to 10 MB) and choose "Put it on the computer's clipboard".
- **Get its clipboard**: text copied on a computer arrives here automatically while connected, where the computer allows it.
- **Let computers locate this phone** (Settings, off by default): a computer can ask where the phone is, once; nothing is kept.
- **USB cable**: plug the phone into a computer running Linksy to connect over the cable, no Wi-Fi needed ("Connected by USB").
- News and update notices from Linksy on the home screen.

### Changed
- A second display now takes this phone's shape, and the screen stays on while it shows (or while you watch a computer's screen).

## [0.1.14] - 2026-10-21

### Fixed
- **Back to the webcam controls** after leaving them: the computer's page now shows the running webcam (and screen sharing) with its banner, and the live "Your camera" entry in its timeline opens the controls too.
- **Updates install over any earlier Linksy APK.** `linksy.apk` and `linksy-arm64.apk` used to carry different version numbers, so a phone that once had the arm64 one refused later `linksy.apk` updates as a "downgrade". All APKs of a release now share one version number, higher than any before.

### Added
- The installed version at the bottom of Settings.

## [0.1.13] - 2026-10-21

### Fixed
- **Webcam picture stretched and sideways** on real phones since 0.1.11: Android hands the camera's picture over already turned upright for a phone held upright (and mirrored for the front camera), and Linksy turned it once more. It now takes that into account: the picture keeps its true shape, upright in Landscape (phone sideways) and Portrait (phone upright), and the front camera isn't mirrored to the computer.

## [0.1.12] - 2026-10-21

### Added
- **60 fps webcam** on phones whose camera does it (Webcam › Stream › Frame rate), with more bitrate to match.

### Fixed
- **Stretched webcam picture** on phones whose camera doesn't deliver exactly 1280×720 (often the front camera): each camera now uses a size it really offers, fitted into the stream without stretching.
- If Android restarts Linksy's screen while the webcam or screen sharing runs, the app finds the running share again (banner, controls, Stop).

## [0.1.11] - 2026-10-21

### Added
- **Webcam controls**, like a camera app's, with a live preview of what the computer sees:
  - Zoom with lens chips (0.6× / 1× / 2× / 5×… as the phone allows), a fine slider and pinch; every back camera the phone exposes, and front/back.
  - Tap to focus (and meter) on a spot, double-tap for auto, hold to lock exposure and focus; manual focus.
  - Torch, brightness (exposure compensation), exposure and white-balance locks, white-balance presets, stabilization.
  - **Landscape or portrait**: the picture stays upright either way round; portrait gets bars at the sides.
  - Stream quality (2, 4 or 8 Mbps), live.
  - Opens by itself when a computer starts the webcam, and from the banner or notification. The computer can drive the same controls once Linksy on the desktop supports it.

## [0.1.10] - 2026-10-21

### Added
- **Device pictures**: give each of your devices a picture (⋯ › Add a picture). It shows as its avatar, and as a large banner on its page that fades into a soft shadow under the name. Without a picture, the banner is a dark blue grid fading into the same shadow.

### Changed
- A device's page no longer shows the round avatar in its header.

## [0.1.9] - 2026-10-21

### Added
- **See your computer's screen** on the phone, from its page: just watch, or control it with touch (tap to click, drag, two fingers to scroll).
- **Switch between the front and back camera** while the phone is a webcam, from the banner or the notification.
- **Accept or decline incoming files from the notification** when Linksy isn't on screen.

### Changed
- Received files go to **Downloads › Linksy**, where every app finds them (Android 10 and later).

## [0.1.8] - 2026-10-21

### Added
- **Push notifications**: news and updates from Linksy arrive as notifications (Firebase Cloud Messaging; no analytics). Settings › News from Linksy copies this phone's push token for a test message.

### Changed
- **New app ID: `app.linksy.mg`.** Android sees this as a new app, so it doesn't update an earlier Linksy: install it, pair your computers again, then uninstall the old one. Received files now live in `Android/data/app.linksy.mg/files/Received`.

## [0.1.7] - 2026-10-20

### Added
- **Remote**: use the phone as your computer's touchpad and keyboard, or as a presentation remote (big Next/Back buttons, and the volume keys change slides).
- **Media controls**: what plays on your computer shows on its page, with play/pause and skip.
- **Lock when you walk away**: when your computer asks for it, the phone keeps telling it you're near, even with the screen off, so it locks when you leave.
- **Pause music during calls**: your computers pause while a call rings or goes on, and resume after. No phone permission needed.
- **Back up photos**: new photos from the folder you choose go to a computer's Pictures folder, per computer.
- **Browse the phone from your computer**: share one folder you choose; it shows up in the computer's Files app.
- Keep Linksy running in the background (optional), so files, backups and calls keep working with the app closed.

### Fixed
- **Screen sharing shows the whole screen again**, status bar, notifications and quick settings included. Android 14 and later offered to share "a single app" first, which left everything else black.

### Not included
- Texting from the computer and showing the phone's notifications or music there: Android blocks apps installed from outside the Play Store from asking for those permissions.

## [0.1.6] - 2026-10-20

### Added
- **Open on PC**: share a link from any app to Linksy and it opens in your computer's browser. Shared text goes to its clipboard, and shared files are sent.
- Links your computer sends open on the phone with a tap.
- **Find my phone**: your computer can make the phone ring loudly, even on silent, until you tap "Found it" (or for 30 seconds).
- **Find my computer**: a button on each computer's page makes it ring.
- Your computer shows the phone's battery level and warns you when it runs low.

### Fixed
- **Second display stays black** on some phones (realme and others): the phone now decodes whole frames, whatever way the computer slices them.

## [0.1.5] - 2026-10-19

### Fixed
- **Installs again.** Android blocked installing 0.1.3 and 0.1.4 with no way to continue: phones block apps from outside the Play Store that ask to control the phone through Accessibility. Linksy no longer asks for that.
- Linksy no longer asks for access to your photos, videos, music or storage. Sending uses Android's own file picker, and received files open without any extra permission.
- The phone could appear twice to your computer after Android restarted the app's screen.

### Changed
- **Smaller and lighter**: about a third smaller to download (9.6 MB on most phones), with no Google services or background reporting inside. QR codes are read on the phone itself.

### Removed
- Controlling the phone from your computer. Your computer now hears that this phone can't do it.

## [0.1.4] - 2026-10-19

### Fixed
- The permissions guide now shows on first launch as intended (in 0.1.3 it only opened from Settings → Permissions).

## [0.1.3] - 2026-10-19

### Added
- **Control your phone from your computer**: when your computer asks to control this phone, you can let it tap, swipe and type while it shows your screen. Turn on “Linksy remote control” once in Android's Accessibility settings; Linksy takes you there.
- **Use your phone as a second display**: when your computer asks, the phone shows one of its screens full screen in landscape. Touch to click and drag, scroll with two fingers, go back to stop.
- **Permissions, explained up front**: on first launch (and any time in Settings → Permissions), Linksy shows what it needs and why, and brings up Android's own prompt for each. If you said no before, it opens Linksy's app settings so you can still turn it on.

### Changed
- **A flat look**: solid colors, no gradients or shadows.
- Your computer now hears “this phone can't do that yet” instead of “declined” when it asks for something the phone doesn't support.

### Fixed
- **No more black bars** around your shared screen: the video keeps your screen's exact shape, and follows when you turn the phone.

## [0.1.2] - 2026-10-19

### Added
- **Share your screen**: “View Screen” in Linksy on your computer now works. Your phone asks first, then Android asks you to confirm (choose “Entire screen” to show everything). Your screen keeps showing on the computer while you use other apps.
- **Use your phone as a webcam**: “Use as Webcam” on your computer turns this phone's back camera into a camera every app on the computer can use. Hold the phone sideways for a wide picture.
- While sharing, a banner in Linksy and a notification show what's shared and with whom, with a **Stop** button. Stopping on either the phone or the computer ends it for both.
- Each share appears in the device's timeline.

### Known limits
- Controlling your phone from the computer and using it as a second display aren't available yet; those requests are declined.
- The webcam always uses the back camera for now.

## [0.1.1] - 2026-10-19

Linksy for Android **now works with your real devices**: it runs the same engine as Linksy on your computer, so they find each other on your Wi-Fi and share directly.

### Added
- **Pair for real**: scan the QR code from “Add Device” in Linksy on your computer, or open it with your phone's camera app, and the phone pairs straight away. Pairing by address with the 6-digit code works too.
- **Share both ways**: send files, your clipboard and pings to your computer, and receive them from it. Received files are saved in Linksy's folder on the phone (Android/data/app.linksy/files/Received) and open from the timeline.
- Files sent automatically from your devices (“Accept from my devices”) now show up in the timeline too.
- This phone is named after your phone the first time you open Linksy; change it in Settings.

### Fixed
- A forgotten device no longer stays in the list until something else happens.

### Known limits
- Keep Linksy open while sharing: transfers in the background come in a later release.
- Screen sharing and the phone-as-webcam requests from your computer are declined for now.

## [0.1.0] - 2026-10-19

First preview of Linksy for Android. **This preview runs on simulated devices**: it shows the app's design and flows, but it can't reach Linksy on your computer yet. Connecting to real devices comes in a following release.

### Added
- **Your devices** at a glance: which ones are nearby, connected or away, what you last shared with each, and a one-tap send button.
- **Device pages**: send files, send your clipboard or ping, and see everything shared with that device as a timeline, by day.
- **Pairing**: scan the QR code Linksy shows on your computer, pair by address, or confirm a 6-digit code on both screens.
- **Incoming files**: see who's sending what before you accept, follow progress, speed and time left, and open received files from the timeline.
- **Settings**: name this phone, accept files from your devices without asking, and stay connected for faster sharing.
- Light and dark themes, in Linksy's own colors.
