#!/usr/bin/env python3
"""فحص أخطاء RTL بالكود: بيطلّع الأماكن اللي فيها اتجاه ثابت (left/right) بدل start/end.
الاستعمال: python3 -I tool/rtl_check.py   (exit 1 إذا في ملاحظات)
بيتجاهل السطر إذا فيه التعليق  // rtl-ok  (للحالات اللي التصميم بيفرضها فعلاً)."""
import re, sys, pathlib

RULES = [
    (r'\bPositioned\(', 'Positioned → PositionedDirectional'),
    (r'EdgeInsets\.only\([^)]*\b(left|right)\s*:', 'EdgeInsets.only(left/right) → EdgeInsetsDirectional.only(start/end)'),
    (r'Alignment\.(centerLeft|centerRight|topLeft|topRight|bottomLeft|bottomRight)\b', 'Alignment.x → AlignmentDirectional'),
    (r'TextAlign\.(left|right)\b', 'TextAlign.left/right → start/end'),
    (r'BorderRadius\.only\([^)]*\b(topLeft|topRight|bottomLeft|bottomRight)\s*:', 'BorderRadius.only → BorderRadiusDirectional'),
    (r'Icons\.(arrow_back|arrow_forward|chevron_left|chevron_right|arrow_left|arrow_right|arrow_back_ios|arrow_forward_ios|open_in_new|history|north_east)\b', 'أيقونة اتجاهية: تأكد من الانعكاس'),
    (r'\b(left|right)\s*:\s*[-\d.]', 'left:/right: بالأرقام → start/end'),
]

def asym_ltrb(line):
    m = re.search(r'EdgeInsets\.fromLTRB\(\s*([-\d.]+)\s*,\s*[-\d.]+\s*,\s*([-\d.]+)\s*,', line)
    return bool(m) and m.group(1) != m.group(2)

bad = 0
for f in sorted(pathlib.Path('lib').rglob('*.dart')):
    for n, line in enumerate(f.read_text().splitlines(), 1):
        if 'rtl-ok' in line or line.strip().startswith('//'):
            continue
        if 'Directional' in line and 'Positioned(' not in line:
            continue
        hits = [msg for pat, msg in RULES if re.search(pat, line)]
        if asym_ltrb(line):
            hits.append('fromLTRB غير متناظر (يسار≠يمين) → EdgeInsetsDirectional.fromSTEB')
        for h in hits:
            print(f'{f}:{n}: {h}\n    {line.strip()}')
            bad += 1
print(f'\n{bad} ملاحظة')
sys.exit(1 if bad else 0)
