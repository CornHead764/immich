#!/usr/bin/env bash
# Cut a sideload release: stamp the version, tag, and push. CI (.github/workflows/build-ipa.yml)
# builds the unsigned IPA on a macOS runner, publishes the GitHub release with the asset, then
# nudges the Cory/sidestore repo to rebuild its SideStore source from those releases.
#
# The tag namespace is `ipa-v*` rather than `v*` so this fork's releases never get confused with
# upstream Immich's.
#
# Usage: mobile/scripts/release-ipa.sh <version> [remote...]   e.g. mobile/scripts/release-ipa.sh 3.2.0
set -euo pipefail

VERSION="${1:?usage: mobile/scripts/release-ipa.sh <version> [remote...]}"
shift
# The build runs on GitHub, but the repo of record is the Forgejo one, so both need the tag.
REMOTES=("$@")
[ ${#REMOTES[@]} -eq 0 ] && REMOTES=(github forgejo)

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PLIST="mobile/ios/Runner/Info.plist"

# Stamp the version SideStore compares against. Info.plist holds a literal rather than
# $(FLUTTER_BUILD_NAME), so pubspec's version never reaches the built app — this is the only
# place that matters. Rewritten in place instead of through plistlib, which would reformat the
# whole file and bury the one-line change in every release diff.
python3 - "$VERSION" "$PLIST" <<'PY'
import re, sys

version, path = sys.argv[1], sys.argv[2]
with open(path) as f:
    plist = f.read()

pattern = r"(<key>CFBundleShortVersionString</key>\s*\n(\s*)<string>)[^<]*(</string>)"
plist, count = re.subn(pattern, rf"\g<1>{version}\g<3>", plist, count=1)
if count != 1:
    sys.exit(f"CFBundleShortVersionString not found in {path}")

with open(path, "w") as f:
    f.write(plist)
PY

git add "$PLIST"
git commit -m "Release ipa-v$VERSION"
git tag "ipa-v$VERSION"

for remote in "${REMOTES[@]}"; do
  git push "$remote" "$BRANCH" "ipa-v$VERSION"
done

echo "Pushed ipa-v$VERSION — CI will build the IPA, publish the release, and refresh the SideStore source."
