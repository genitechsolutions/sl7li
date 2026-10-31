#!/usr/bin/env python3
"""كشف ترتيب العناصر الغلط بصف (أيقونة/نص مبدّلين، صف معكوس) بدون مرجع بشري.

الفكرة: كل شريط أفقي بنطلّع منه تسلسل "بقع الحبر" (عرض كل بقعة: أيقونة، كلمة، حد زر...) من اليمين لليسار.
إذا نفس البقع (نفس العرض) موجودة بالتصميم والـ render بس بترتيب مختلف = ترتيب غلط.
  python3 -I tool/design_check/rtl_order.py <render.png> <design.png> [--scale 2]
exit 1 إذا في ملاحظات."""
import argparse, itertools, sys
import numpy as np
from PIL import Image

def edges(path, scale):
    im = Image.open(path).convert('RGB')
    if scale != 1:
        im = im.resize((im.width // scale, im.height // scale), Image.LANCZOS)
    g = np.asarray(im).astype(np.float32).sum(axis=2)
    e = np.abs(np.diff(g, axis=1, prepend=g[:, :1])) + np.abs(np.diff(g, axis=0, prepend=g[:1]))
    return e

def runs(mask_cols, gap):
    """مقاطع الأعمدة اللي فيها حبر، ودمج الفجوات الأصغر من gap."""
    xs = np.flatnonzero(mask_cols)
    if xs.size == 0:
        return []
    out = [[xs[0], xs[0]]]
    for x in xs[1:]:
        if x - out[-1][1] <= gap:
            out[-1][1] = x
        else:
            out.append([x, x])
    return [(a, b - a + 1) for a, b in out]  # (بداية، عرض)

def band_runs(E, y, hgt, thr, gap, minw):
    cols = (E[y:y + hgt] > thr).any(axis=0)
    return [r for r in runs(cols, gap) if r[1] >= minw]

def mismatch(wa, wb):
    return sum(abs(p - q) for p, q in zip(wa, wb))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('render'); ap.add_argument('design')
    ap.add_argument('--scale', type=int, default=2)
    ap.add_argument('--hgt', type=int, default=14)
    ap.add_argument('--step', type=int, default=7)
    ap.add_argument('--thr', type=float, default=60)
    ap.add_argument('--gap', type=int, default=6)
    ap.add_argument('--minw', type=int, default=7)
    ap.add_argument('--photo', type=float, default=0.22)  # كثافة حواف = صورة، تجاهل
    ap.add_argument('--dy', type=int, default=16)
    ap.add_argument('--tol', type=int, default=14)    # فرق أعراض مقبول (px) للتطابق
    ap.add_argument('--maxn', type=int, default=6)
    a = ap.parse_args()

    R = edges(a.render, a.scale); D = edges(a.design, 1)
    H = min(R.shape[0], D.shape[0]); W = min(R.shape[1], D.shape[1])
    R, D = R[:H, :W], D[:H, :W]

    flagged = []
    for y in range(32, H - a.hgt, a.step):
        if (D[y:y + a.hgt] > a.thr).mean() > a.photo:
            continue
        db = band_runs(D, y, a.hgt, a.thr, a.gap, a.minw)
        n = len(db)
        if n < 2 or n > a.maxn:
            continue
        wd = [int(w) for _, w in db]
        fine = False
        best = None
        for dy in range(-a.dy, a.dy + 1):
            yy = y + dy
            if yy < 32 or yy + a.hgt > H:
                continue
            if (R[yy:yy + a.hgt] > a.thr).mean() > a.photo:
                continue
            rb = band_runs(R, yy, a.hgt, a.thr, a.gap, a.minw)
            if len(rb) != n:
                continue
            wr = [int(w) for _, w in rb]
            direct = mismatch(wr, wd)
            if direct <= a.tol:
                fine = True
                break
            if direct < 2 * a.tol:
                fine = True  # فرق صغير = ضجيج خطوط، مش ترتيب
                break
            # أحسن ترتيب بيطابق (n ≤ 6 → حتى 720 احتمال)
            for perm in itertools.permutations(range(n)):
                if perm == tuple(range(n)):
                    continue
                m = mismatch([wr[i] for i in perm], wd)
                if m <= a.tol and m * 3 <= direct and (best is None or m < best[0]):
                    best = (m, dy, perm, wr)
        if not fine and best:
            flagged.append((y, n, best, wd))

    # دمج الأشرطة المتجاورة
    out = []
    for f in flagged:
        if out and f[0] - out[-1][0] <= a.hgt:
            continue
        out.append(f)
    for y, n, (m, dy, perm, wr), wd in out:
        print(f'  y={y}: {n} عناصر بترتيب مختلف عن التصميم  (عرض render={wr} ← تصميم={wd})')
    print(f'  صفوف ترتيبها مختلف: {len(out)}')
    sys.exit(1 if out else 0)

main()
