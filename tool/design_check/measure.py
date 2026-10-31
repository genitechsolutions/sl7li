"""قياس صور التصميم والـ render لمقارنتهم بالبكسل (بدون مكتبات خارجية).

الاستعمال (كل الإحداثيات بالـ logical px، و --scale للصور المرسومة بـ 2x):
  python3 -I tool/design_check/measure.py spans  <png> --x 200 [--y0 0 --y1 900] [--scale 2] [--bg F9F9FB]
      أجزاء عمودية لونها مختلف عن الخلفية على عمود x (حدود كروت، صور، أزرار).
  python3 -I tool/design_check/measure.py lines  <png> --x0 20 --x1 392 [--y0 --y1] [--scale 2]
      أسطر النصوص/الأيقونات الغامقة: (أعلى، أسفل، أقصى يسار، أقصى يمين).
  python3 -I tool/design_check/measure.py colors <png> --box x0 y0 x1 y1 [--scale 2]
      أكثر الألوان تكراراً بالمربع (لأخذ الـ hex).
  python3 -I tool/design_check/measure.py size   <png>
"""
import argparse
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from png import load  # noqa: E402


def hexc(p):
    return '#%02X%02X%02X' % p[:3]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('cmd', choices=['spans', 'lines', 'colors', 'size'])
    ap.add_argument('png')
    ap.add_argument('--scale', type=int, default=1)
    ap.add_argument('--x', type=int)
    ap.add_argument('--x0', type=int, default=0)
    ap.add_argument('--x1', type=int)
    ap.add_argument('--y0', type=int, default=0)
    ap.add_argument('--y1', type=int)
    ap.add_argument('--bg', default='F9F9FB')
    ap.add_argument('--ink', type=int, default=650, help='مجموع RGB أقل منه = حبر')
    ap.add_argument('--box', type=int, nargs=4)
    a = ap.parse_args()

    w, h, px = load(a.png)
    s = a.scale
    if a.cmd == 'size':
        print(w // s, h // s)
        return
    y0, y1 = a.y0 * s, min((a.y1 or h // s) * s, h)
    bg = tuple(int(a.bg[i:i + 2], 16) for i in (0, 2, 4))

    if a.cmd == 'spans':
        x = a.x * s
        out, st = [], None
        for y in range(y0, y1):
            d = sum(abs(c - b) for c, b in zip(px(x, y)[:3], bg)) > 8
            if d and st is None:
                st = y
            if not d and st is not None:
                if y - st >= 2 * s:
                    out.append((st // s, (y - 1) // s))
                st = None
        print(out)
    elif a.cmd == 'lines':
        x0, x1 = a.x0 * s, min((a.x1 or w // s) * s, w)
        ink = lambda p: sum(p[:3]) < a.ink
        rows = [y for y in range(y0, y1) if any(ink(px(x, y)) for x in range(x0, x1, s))]
        if not rows:
            print([])
            return
        groups, st, pv = [], rows[0], rows[0]
        for y in rows[1:]:
            if y != pv + 1:
                groups.append((st, pv))
                st = y
            pv = y
        groups.append((st, pv))
        out = []
        for g0, g1 in groups:
            if g1 - g0 < 2 * s:
                continue
            xs = [x for y in range(g0, g1 + 1) for x in range(x0, x1, s) if ink(px(x, y))]
            out.append((g0 // s, g1 // s, min(xs) // s, max(xs) // s))
        print(out)
    else:
        bx0, by0, bx1, by1 = (v * s for v in a.box)
        c = Counter(hexc(px(x, y)) for y in range(by0, by1) for x in range(bx0, bx1))
        print(c.most_common(5))


if __name__ == '__main__':
    main()
