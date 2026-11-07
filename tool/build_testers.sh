#!/usr/bin/env bash
# بيبني APKين تجريبيين (زبون + مهني) بأسماء حزم مختلفة مشان ينثبّتوا سوا على نفس الموبايل.
# اختياري: APPSYNC_API_KEY=<المفتاح> (مطلوب لتسجيل SNS endpoint للإشعارات؛ ما بينكتب بالريبو).
# الاستعمال: TEST_LOGIN_PASSWORD=<كلمة السر> bash tool/build_testers.sh <مجلد_بناء_مؤقت> <مجلد_خرج>
set -euo pipefail
: "${TEST_LOGIN_PASSWORD:?حط TEST_LOGIN_PASSWORD}"
SRC="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${1:?مجلد بناء مؤقت}"; OUT="${2:?مجلد خرج}"
mkdir -p "$WORK" "$OUT"
cp -r "$SRC"/. "$WORK"/
cd "$WORK"
GRADLE=android/app/build.gradle.kts; MANIFEST=android/app/src/main/AndroidManifest.xml
ensure_firebase_client() { # package — بيكرّر عميل Firebase للحزمة التجريبية إذا مش مضافة بالمشروع (اختبار فقط)
  GS=android/app/google-services.json
  [ -f "$GS" ] || return 0
  python3 -I - "$GS" "$1" <<'PY'
import json, sys, copy
path, pkg = sys.argv[1], sys.argv[2]
d = json.load(open(path))
if not any(c["client_info"]["android_client_info"]["package_name"] == pkg for c in d["client"]):
    c = copy.deepcopy(d["client"][0]); c["client_info"]["android_client_info"]["package_name"] = pkg
    d["client"].append(c); json.dump(d, open(path, "w"), indent=2)
PY
}
build() { # who phone id label
  ensure_firebase_client "$3"
  sed -i "s|applicationId = \".*\"|applicationId = \"$3\"|" "$GRADLE"
  sed -i "s|android:label=\"[^\"]*\"|android:label=\"$4\"|" "$MANIFEST"
  flutter build apk --release --target-platform android-arm64 \
    --dart-define=BACKEND=amplify --dart-define=APP_ENV=devqa \
    ${APPSYNC_API_KEY:+--dart-define=APPSYNC_API_KEY=$APPSYNC_API_KEY} \
    --dart-define=ENABLE_TEST_LOGIN=true "--dart-define=TEST_LOGIN_PASSWORD=$TEST_LOGIN_PASSWORD" \
    --dart-define=TEST_LOGIN_PHONE="$2"
  cp build/app/outputs/flutter-apk/app-release.apk "$OUT/salehli-tester-$1.apk"
}
build customer +963111111111 com.salehli.customer "صلّحلي زبون"
build craftsman +963222222222 com.salehli.craftsman "صلّحلي حرفي"
