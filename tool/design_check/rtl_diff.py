#!/usr/bin/env python3
"""كشف أخطاء RTL بدون تدخل بشري: بيقارن الـ render مع صورة التصميم وبيدوّر على "شرايط" أفقية
شكلها بالـ render أقرب لانعكاس التصميم من التصميم نفسه (= ترتيب عناصر أو سهم معكوس).

  python3 -I tool/design_check/rtl_diff.py <render.png> <design.png> [--scale 2] [--band 28] [--margin 0.12]
exit 1 إذا في شرايط مشبوهة. الخط مختلف شوي بين الاتنين، فالمقارنة على "خريطة الحبر" مطموسة مش بالبكسل.
"""
import argparse, sys
import numpy as np
from PIL import Image, ImageFilter

def ink(path, scale, width=412):
    im = Image.open(path).convert('RGB')
    if scale != 1:
        im = im.resize((im.width // scale, im.height // scale), Image.LANCZOS)
    a = np.asarray(im).astype(np.float32)
    bg = np.median(a.reshape(-1, 3), axis=0)  # لون الخلفية الغالب
    d = np.abs(a - bg).sum(axis=2)
    return d

def blur(v, k=9):
    kern = np.ones(k) / k
    return np.convolve(v, kern, mode='same')

def corr(a, b):
    a = a - a.mean(); b = b - b.mean()
    den = np.sqrt((a * a).sum() * (b * b).sum())
    return float((a * b).sum() / den) if den > 1e-6 else 0.0

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('render'); ap.add_argument('design')
    ap.add_argument('--scale', type=int, default=2)
    ap.add_argument('--band', type=int, default=28)
    ap.add_argument('--margin', type=float, default=0.12)
    ap.add_argument('--skip-top', type=int, default=32, help='شريط الحالة')
    args = ap.parse_args()

    r = ink(args.render, args.scale)
    d = ink(args.design, 1)
    h = min(r.shape[0], d.shape[0]); w = min(r.shape[1], d.shape[1])
    r, d = r[:h, :w], d[:h, :w]

    bad = 0
    for y in range(args.skip_top, h - args.band, args.band):
        rb = blur(r[y:y + args.band].sum(axis=0))
        db = blur(d[y:y + args.band].sum(axis=0))
        if rb.sum() < 2000 or db.sum() < 2000:  # شريط فاضي
            continue
        # شريط صورة (حبر كتير تقريباً بكل العرض): الصور مختلفة بالتصميم عن الـ placeholder، تجاهله.
        if (r[y:y + args.band] > 60).mean() > 0.45 or (d[y:y + args.band] > 60).mean() > 0.45:
            continue
        same = corr(rb, db)
        flip = corr(rb, db[::-1])
        # الشريط المتناظر طبيعي ما بيفرق بين الاتنين؛ نحن بنلاقي اللي الانعكاس أحسن بوضوح.
        if flip > same + args.margin and flip > 0.5:
            print(f'  y={y}-{y + args.band}: مطابقة={same:.2f} مطابقة-منعكسة={flip:.2f}  ← مشبوه (ترتيب/اتجاه)')
            bad += 1
    whole = corr(blur(r.sum(axis=0)), blur(d.sum(axis=0)))
    print(f'  تطابق عام (توزيع أفقي): {whole:.2f}  | شرايط مشبوهة: {bad}')
    sys.exit(1 if bad else 0)

main()
