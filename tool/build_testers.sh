#!/usr/bin/env bash
# بيبني APKين تجريبيين (زبون + مهني) بأسماء حزم مختلفة مشان ينثبّتوا سوا على نفس الموبايل.
# الاستعمال: TEST_LOGIN_PASSWORD=<كلمة السر> bash tool/build_testers.sh <مجلد_بناء_مؤقت> <مجلد_خرج>
set -euo pipefail
: "${TEST_LOGIN_PASSWORD:?حط TEST_LOGIN_PASSWORD}"
SRC="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${1:?مجلد بناء مؤقت}"; OUT="${2:?مجلد خرج}"
mkdir -p "$WORK" "$OUT"
cp -r "$SRC"/. "$WORK"/
cd "$WORK"
GRADLE=android/app/build.gradle.kts; MANIFEST=android/app/src/main/AndroidManifest.xml
build() { # who phone id label
  sed -i "s|applicationId = \".*\"|applicationId = \"$3\"|" "$GRADLE"
  sed -i "s|android:label=\"[^\"]*\"|android:label=\"$4\"|" "$MANIFEST"
  flutter build apk --release --target-platform android-arm64 \
    --dart-define=BACKEND=amplify --dart-define=APP_ENV=devqa \
    --dart-define=ENABLE_TEST_LOGIN=true "--dart-define=TEST_LOGIN_PASSWORD=$TEST_LOGIN_PASSWORD" \
    --dart-define=TEST_LOGIN_PHONE="$2"
  cp build/app/outputs/flutter-apk/app-release.apk "$OUT/salehli-tester-$1.apk"
}
build customer +963111111111 com.salehli.customer "صلّحلي زبون"
build craftsman +963222222222 com.salehli.craftsman "صلّحلي حرفي"
