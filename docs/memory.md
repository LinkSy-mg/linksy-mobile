# Memory

Measured with `adb shell dumpsys meminfo app.linksy.mg` (release build, arm64), so later
releases can compare. Steps: force-stop, open, idle 20 s on home, then Home and wait 30 s.

## 2026-10-23, 0.2.2+ (emulator, Android 15, arm64, 2.5 GB)

| | Open, idle | Background 30 s |
|---|---|---|
| Total PSS | 92-95 MB | 94-97 MB |
| Total RSS | 195-199 MB | 200-204 MB |
| Private dirty | 44-49 MB | 44 MB |
| Native heap (PSS) | 29 MB | 25 MB |
| Code (PSS, clean) | 34 MB | 34 MB |

RSS is the "about 200 MB" in issue #3. It counts the shared system libraries every app maps
(framework `.jar`, `.oat`, `.art`: about 70 MB RSS), so PSS and private dirty are the
numbers to watch.

Native heap, from a heapprofd profile (`<profileable android:shell="true"/>` in a local
build only):

- 21 MB: the emulator's GL pipe (`libOpenglSystemCommon`, `libOpenglCodecCommon`). On a
  phone that is the GPU driver's and shows under Graphics instead.
- 7 MB: the Rust core (`liblinksy_bridge.so`). Two 2.9 MB of it are QUIC receive buffers,
  allocated zeroed and almost never touched (4 KB dirty each).
- 2 MB: Flutter's engine.

Dart heap: about 13 MB. Code: libflutter 11.7 MB, libapp 7.5 MB, liblinksy_bridge 9.4 MB
(clean, shared with the file cache).

What the app does about it: the image cache is capped at 24 MB and emptied when the app
is hidden, and covers decode at the size shown. Device pictures are stored downscaled
(`Pictures.kt`).

Still to measure on a real phone (Graphics, which the emulator doesn't report).

## 2026-11-05, before 0.3.5 (emulator, demo build, arm64)

| | Open, idle 20 s | Background 30 s |
|---|---|---|
| Total PSS | 81 MB | 84 MB |
| Total RSS | 188 MB | 192 MB |

Under the 100 MB target on the emulator. Still to measure on a real phone.
