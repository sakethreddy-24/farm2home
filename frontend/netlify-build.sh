#!/usr/bin/env bash
# Netlify build script: installs the Flutter SDK (not preinstalled on Netlify) and builds the web app.
set -euo pipefail

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
BASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"

# Look up the current release for the channel (archive path, version, commit, Dart version).
RELEASE_JSON="$(curl -fsSL "$BASE_URL/releases_linux.json" | node -e '
  let d = "";
  process.stdin.on("data", c => (d += c)).on("end", () => {
    const j = JSON.parse(d);
    const hash = j.current_release[process.argv[1]];
    const r = j.releases.find(x => x.hash === hash);
    if (!r) { console.error("No current release found for channel"); process.exit(1); }
    process.stdout.write(JSON.stringify(r));
  });
' "$FLUTTER_CHANNEL")"
release_field() { node -e 'process.stdout.write(String(JSON.parse(process.argv[1])[process.argv[2]] ?? ""))' "$RELEASE_JSON" "$1"; }
FLUTTER_VERSION="$(release_field version)"

# (Re)install if Flutter is missing or a different version is present.
INSTALLED_VERSION=""
if [ -f "$FLUTTER_DIR/version.netlify" ]; then INSTALLED_VERSION="$(cat "$FLUTTER_DIR/version.netlify")"; fi
if [ ! -x "$FLUTTER_DIR/bin/flutter" ] || [ "$INSTALLED_VERSION" != "$FLUTTER_VERSION" ]; then
  echo "Installing Flutter $FLUTTER_VERSION ($FLUTTER_CHANNEL) into $FLUTTER_DIR"
  rm -rf "$FLUTTER_DIR"
  PARENT_DIR="$(dirname "$FLUTTER_DIR")"
  mkdir -p "$PARENT_DIR"
  TMP_DIR="$(mktemp -d)"
  curl -fsSL "$BASE_URL/$(release_field archive)" -o "$TMP_DIR/flutter.tar.xz"
  tar -xJf "$TMP_DIR/flutter.tar.xz" -C "$TMP_DIR"
  rm -f "$TMP_DIR/flutter.tar.xz"
  mv "$TMP_DIR/flutter" "$FLUTTER_DIR"
  rm -rf "$TMP_DIR"
  echo "$FLUTTER_VERSION" > "$FLUTTER_DIR/version.netlify"
fi

# Flutter normally derives its version from git. Some build environments only allow
# read-only git commands, which makes Flutter report "0.0.0-unknown" and breaks package
# resolution. Write the version file from the official release metadata; Flutter trusts
# it as long as it names a real version and the official repository.
mkdir -p "$FLUTTER_DIR/bin/cache"
node -e '
  const fs = require("fs");
  const [file, relJson] = process.argv.slice(1);
  const r = JSON.parse(relJson);
  let prev = {};
  try { prev = JSON.parse(fs.readFileSync(file, "utf8")); } catch {}
  const ok = (v) => typeof v === "string" && v && !v.includes("disabled in this environment");
  const out = {
    frameworkVersion: r.version,
    channel: r.channel,
    repositoryUrl: "https://github.com/flutter/flutter.git",
    frameworkRevision: r.hash,
    frameworkCommitDate: r.release_date || "1970-01-01 00:00:00.000",
    engineRevision: ok(prev.engineRevision) ? prev.engineRevision : r.hash,
    dartSdkVersion: r.dart_sdk_version ? String(r.dart_sdk_version).split(" ")[0] : (prev.dartSdkVersion || "0.0.0"),
    devToolsVersion: ok(prev.devToolsVersion) ? prev.devToolsVersion : "0.0.0",
    flutterVersion: r.version,
  };
  for (const k of ["engineCommitDate", "engineContentHash", "engineBuildDate"]) {
    if (ok(prev[k])) out[k] = prev[k];
  }
  fs.writeFileSync(file, JSON.stringify(out, null, 2));
' "$FLUTTER_DIR/bin/cache/flutter.version.json" "$RELEASE_JSON"

export PATH="$FLUTTER_DIR/bin:$PATH"

flutter config --no-analytics --enable-web >/dev/null
flutter --version

# The repo doesn't include the web/ platform folder; generate it if missing
# (flutter create does not overwrite existing files such as lib/main.dart).
if [ ! -f web/index.html ]; then
  flutter create --platforms=web --project-name farm2home .
fi

flutter pub get
flutter build web --release
