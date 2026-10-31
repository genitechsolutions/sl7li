#!/usr/bin/env bash
# فحص RTL بصري تلقائي: بيرسم الشاشات المعرّفة بـ rtl_screens_test.dart ويقارنها مع design/*.png.
# الاستعمال: bash tool/design_check/run_rtl.sh   (بيمسح test/ بالآخر)
set -u
cd "$(dirname "$0")/../.."
mkdir -p test/_tmp
cp tool/design_check/rtl_screens_test.dart test/_tmp/rtl_screens_test.dart
flutter test test/_tmp/rtl_screens_test.dart --update-goldens >/tmp/rtl_run.log 2>&1 || { tail -30 /tmp/rtl_run.log; rm -rf test; exit 2; }
fail=0
for f in test/_tmp/rtl/*.png; do
  n=$(basename "$f" .png)
  echo "== $n"
  python3 -I tool/design_check/rtl_diff.py "$f" "design/$n.png" || fail=1
  python3 -I tool/design_check/rtl_order.py "$f" "design/$n.png" || fail=1
done
rm -rf test
exit $fail
