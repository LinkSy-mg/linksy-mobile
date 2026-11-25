#!/usr/bin/env bash
# Puts linksy-core in rust/core: linksy-desktop at the commit the app is built
# against, with this repo's patches (rust/patches) on it. Runs again only when
# the commit or a patch changes. Called by tool/build_rust.sh.
set -euo pipefail
cd "$(dirname "$0")/.."

REV=$(cat rust/core.rev)
STAMP=$(cat rust/core.rev rust/patches/*.patch | shasum -a 256 | cut -d' ' -f1)
[ -f rust/core/.stamp ] && [ "$(cat rust/core/.stamp)" = "$STAMP" ] && exit 0

rm -rf rust/core
git init -q rust/core
git -C rust/core fetch -q --depth 1 ssh://git@github.com/LinkSy-mg/linksy-desktop.git "$REV"
git -C rust/core checkout -q FETCH_HEAD
for p in rust/patches/*.patch; do
  git -C rust/core apply "../../$p"
  echo "core: $(basename "$p")"
done
echo "$STAMP" > rust/core/.stamp
