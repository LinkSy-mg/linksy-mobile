#!/usr/bin/env bash
# Proves the release-signing guard: packaging a release without
# android/key.properties must fail with the guard's message instead of signing
# with the debug key. Run by hand before touching android/app/build.gradle.kts
# (there is no CI). Needs a gradle on PATH or GRADLE=/path/to/gradle.
#
#   tool/check_release_guard.sh
set -uo pipefail
cd "$(dirname "$0")/../android"
GRADLE=${GRADLE:-gradle}
[ -f key.properties ] && { echo "SKIP: android/key.properties exists; move it away to run this check"; exit 2; }
out=$("$GRADLE" --console=plain :app:packageRelease 2>&1); rc=$?
if [ $rc -ne 0 ] && printf "%s\n" "$out" | grep -q "Refusing to sign a release with the debug key"; then
  echo "OK: release packaging refused without key.properties"
else
  echo "FAIL: guard did not fire (exit $rc)"; printf "%s\n" "$out" | tail -20; exit 1
fi
