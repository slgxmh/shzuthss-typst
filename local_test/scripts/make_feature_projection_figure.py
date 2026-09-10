#!/usr/bin/env python3
"""Generate the PCA-vs-LDA projection-direction schematic for Section 2.4.4.

The figure is built from a *synthetic* two-class two-dimensional sample, not
from experimental data.  Its only purpose is didactic: the within-class
elongation direction and the between-class separation direction are made
perpendicular, so PCA (maximising total variance) selects the elongation axis
while LDA (maximising the between/within scatter ratio) selects the separation
axis.  PCA is computed from the pooled covariance, LDA from the pooled
within-class covariance, and the Fisher criterion J of both projected
directions is printed and reported in the figure.

Generated file: chapters/数据集/feature_projection.typ
Then compile:
    typst compile --format svg chapters/数据集/feature_projection.typ
    typst compile --format png --ppi 170 chapters/数据集/feature_projection.typ
"""

import math
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "chapters" / "数据集" / "feature_projection.typ"

SEED = 30
N_PER_CLASS = 18
SIGMA_ALONG_U = 1.60      # within-class spread along the elongation axis
SIGMA_ALONG_V = 0.45      # within-class spread along the separation axis
SEPARATION = 0.90         # class means sit at +/- SEPARATION along the v axis

# panel geometry, in mm
PW, GAP = 79.0, 6.0
OX, OY = 10.0, 17.0
SW, SH = 60.0, 60.0
DY, DH = 88.0, 19.0
PH = 117.0


# --------------------------------------------------------------- helpers ----

def mm(v):
    return ("%.3f" % v).rstrip("0").rstrip(".") + "mm"


def sample_points():
    rng = random.Random(SEED)
    c = math.cos(math.pi / 4.0)
    u = (c, c)             # elongation direction
    v = (-c, c)            # separation direction (orthogonal to u)
    classes = []
    for sign in (+1.0, -1.0):
        mx, my = sign * SEPARATION * v[0], sign * SEPARATION * v[1]
        pts = []
        for _ in range(N_PER_CLASS):
            a, b = rng.gauss(0, SIGMA_ALONG_U), rng.gauss(0, SIGMA_ALONG_V)
            pts.append((mx + a * u[0] + b * v[0], my + a * u[1] + b * v[1]))
        classes.append(pts)
    return classes


def mean(pts):
    n = float(len(pts))
    return (sum(p[0] for p in pts) / n, sum(p[1] for p in pts) / n)


def covariance(pts, m):
    n = float(len(pts) - 1)
    return (
        sum((p[0] - m[0]) ** 2 for p in pts) / n,
        sum((p[0] - m[0]) * (p[1] - m[1]) for p in pts) / n,
        sum((p[1] - m[1]) ** 2 for p in pts) / n,
    )


def unit(x, y):
    n = math.hypot(x, y)
    return (x / n, y / n)


def principal_axis(cov):
    sxx, sxy, syy = cov
    tr, det = sxx + syy, sxx * syy - sxy * sxy
    lam = tr / 2.0 + math.sqrt(max(tr * tr / 4.0 - det, 0.0))
    if abs(sxy) > 1e-12:
        return unit(lam - syy, sxy)
    return (1.0, 0.0) if sxx >= syy else (0.0, 1.0)


def lda_axis(c1, c2):
    m1, m2 = mean(c1), mean(c2)
    a1, a2 = covariance(c1, m1), covariance(c2, m2)
    sxx, sxy, syy = (a1[0] + a2[0]) / 2, (a1[1] + a2[1]) / 2, (a1[2] + a2[2]) / 2
    dx, dy = m1[0] - m2[0], m1[1] - m2[1]
    det = sxx * syy - sxy * sxy
    return unit((syy * dx - sxy * dy) / det, (-sxy * dx + sxx * dy) / det)


def project(pts, w):
    return [p[0] * w[0] + p[1] * w[1] for p in pts]


def fisher_j(pa, pb):
    ma, mb = sum(pa) / len(pa), sum(pb) / len(pb)
    va = sum((v - ma) ** 2 for v in pa) / (len(pa) - 1)
    vb = sum((v - mb) ** 2 for v in pb) / (len(pb) - 1)
    return (ma - mb) ** 2 / (va + vb)


def kde(values, grid, bw):
    out = []
    for g in grid:
        s = sum(math.exp(-0.5 * ((g - v) / bw) ** 2) for v in values)
        out.append(s / (len(values) * bw * math.sqrt(2 * math.pi)))
    return out


# ----------------------------------------------------------- generation -----

def build():
    classes = sample_points()
    all_pts = classes[0] + classes[1]
    gm = mean(all_pts)
    w_pca = principal_axis(covariance(all_pts, gm))
    w_lda = lda_axis(classes[0], classes[1])
    if w_pca[0] < 0:
        w_pca = (-w_pca[0], -w_pca[1])
    if w_lda[0] < 0:
        w_lda = (-w_lda[0], -w_lda[1])
    j_pca = fisher_j(project(classes[0], w_pca), project(classes[1], w_pca))
    j_lda = fisher_j(project(classes[0], w_lda), project(classes[1], w_lda))

    xs = [p[0] for p in all_pts]
    ys = [p[1] for p in all_pts]
    span = max(max(xs) - min(xs), max(ys) - min(ys)) * 1.14
    cx, cy = (max(xs) + min(xs)) / 2.0, (max(ys) + min(ys)) / 2.0
    x0, x1, y0, y1 = cx - span / 2, cx + span / 2, cy - span / 2, cy + span / 2

    def px(x):
        return OX + (x - x0) / (x1 - x0) * SW

    def py(y):
        return OY + (y1 - y) / (y1 - y0) * SH

    L = []
    add = L.append
    add('#set page(width: 170mm, height: auto, margin: 3mm, fill: white)')
    add('#set text(font: ("Times New Roman", "Songti SC"), size: 8pt, '
        'fill: rgb("344B55"), top-edge: 0.8em, bottom-edge: -0.2em)')
    add('#set par(leading: 3pt, spacing: 0pt)')
    add('')
    add('#let ink = rgb("344B55")')
    add('#let muted = rgb("52616A")')
    add('#let border = rgb("AAB6BB")')
    add('#let soft = rgb("F2F5F6")')
    add('#let ca = rgb("477B91")')
    add('#let cb = rgb("BA8056")')
    add('')

    panel_names = []
    for idx, (w, title, subtitle, jval) in enumerate((
        (w_pca, "(a) PCA · 保留总体变化", "不使用类别标签 · 最大化投影方差", "J ≈ %.2f" % j_pca),
        (w_lda, "(b) LDA · 突出类别差异", "使用类别标签 · 最大化类间 / 类内散度比", "J ≈ %.2f" % j_lda),
    )):
        name = "panelA" if idx == 0 else "panelB"
        panel_names.append(name)
        add('#let %s = block(width: %s, height: %s)[' % (name, mm(PW), mm(PH)))
        add('  #place(dx: %s, dy: 0mm)[#text(size: 10.2pt, weight: "bold", fill: ink)[%s]]'
            % (mm(OX - 5.0), title))
        add('  #place(dx: %s, dy: 5.6mm)[#text(size: 7.9pt, fill: muted)[%s]]'
            % (mm(OX - 5.0), subtitle))
        add('  #place(dx: %s, dy: %s, rect(width: %s, height: %s, fill: white, '
            'stroke: (bottom: 0.5pt + border, left: 0.5pt + border)))' % (mm(OX), mm(OY), mm(SW), mm(SH)))
        add('  #place(dx: %s, dy: %s)[#text(size: 7.6pt, fill: muted)[特征 1 →]]'
            % (mm(OX + SW - 15.0), mm(OY + SH + 1.4)))
        add('  #place(dx: %s, dy: %s)[#text(size: 7.6pt, fill: muted)[↑ 特征 2]]'
            % (mm(OX), mm(OY - 3.6)))

        # dashed drop lines (drawn first, so points and axis sit on top)
        for pts in classes:
            for p in pts:
                t = (p[0] - gm[0]) * w[0] + (p[1] - gm[1]) * w[1]
                q = (gm[0] + t * w[0], gm[1] + t * w[1])
                add('  #place(dx: 0mm, dy: 0mm, line(start: (%s, %s), end: (%s, %s), '
                    'stroke: (paint: rgb("CFD8DC"), thickness: 0.35pt, dash: "dashed")))'
                    % (mm(px(p[0])), mm(py(p[1])), mm(px(q[0])), mm(py(q[1]))))

        # projection axis
        # Keep the complete projection axis inside the square plot.
        t_min, t_max = -math.inf, math.inf
        for center, direction, lower, upper in ((gm[0], w[0], x0, x1), (gm[1], w[1], y0, y1)):
            if abs(direction) > 1e-12:
                bounds = sorted(((lower - center) / direction, (upper - center) / direction))
                t_min, t_max = max(t_min, bounds[0]), min(t_max, bounds[1])
        a0 = (gm[0] + w[0] * t_min * 0.98, gm[1] + w[1] * t_min * 0.98)
        a1 = (gm[0] + w[0] * t_max * 0.98, gm[1] + w[1] * t_max * 0.98)
        add('  #place(dx: 0mm, dy: 0mm, line(start: (%s, %s), end: (%s, %s), '
            'stroke: 1.1pt + ink))' % (mm(px(a0[0])), mm(py(a0[1])),
                                       mm(px(a1[0])), mm(py(a1[1]))))

        # tick marks where the points land on the axis
        for pts, color in zip(classes, ("ca", "cb")):
            for p in pts:
                t = (p[0] - gm[0]) * w[0] + (p[1] - gm[1]) * w[1]
                q = (gm[0] + t * w[0], gm[1] + t * w[1])
                nx, ny = -w[1] * 0.12, w[0] * 0.12
                add('  #place(dx: 0mm, dy: 0mm, line(start: (%s, %s), end: (%s, %s), '
                    'stroke: 0.7pt + %s))'
                    % (mm(px(q[0] - nx)), mm(py(q[1] - ny)),
                       mm(px(q[0] + nx)), mm(py(q[1] + ny)), color))

        # scatter points
        for pts, color in zip(classes, ("ca", "cb")):
            for p in pts:
                add('  #place(dx: %s, dy: %s, circle(radius: 1.7pt, fill: %s, stroke: 0.35pt + white))'
                    % (mm(px(p[0]) - 1.7 * 25.4 / 72), mm(py(p[1]) - 1.7 * 25.4 / 72), color))

        # density strip
        add('  #place(dx: %s, dy: %s)[#text(size: 7.6pt, fill: muted)['
            '沿投影方向的分布]]' % (mm(OX), mm(DY - 5.0)))
        add('  #place(dx: %s, dy: %s, rect(width: %s, height: %s, fill: white, '
            'stroke: (bottom: 0.5pt + border, left: 0.5pt + border)))' % (mm(OX), mm(DY), mm(SW), mm(DH)))
        proj_all = project(all_pts, w)
        lo, hi = min(proj_all), max(proj_all)

        def bandwidth(vals):
            m = sum(vals) / len(vals)
            sd = math.sqrt(sum((v - m) ** 2 for v in vals) / (len(vals) - 1))
            return 1.06 * sd * len(vals) ** (-0.2)

        proj_by_class = [project(pts, w) for pts in classes]
        bw = max(bandwidth(v) for v in proj_by_class)
        # extend the range so the kernel estimate has decayed at both edges
        g0, g1 = lo - 2.6 * bw, hi + 2.6 * bw
        grid = [g0 + (g1 - g0) * i / 79.0 for i in range(80)]
        peak = 1e-12
        dens = []
        for vals, color in zip(proj_by_class, ("ca", "cb")):
            d = kde(vals, grid, bandwidth(vals))
            dens.append((color, d))
            peak = max(peak, max(d))
        base = DY + DH - 1.2
        for color, d in dens:
            comps = ['curve.move((%s, %s))' % (mm(OX), mm(base))]
            for g, v in zip(grid, d):
                comps.append('curve.line((%s, %s))' % (
                    mm(OX + (g - g0) / (g1 - g0) * SW),
                    mm(base - v / peak * (DH - 3.6))))
            comps.append('curve.line((%s, %s))' % (mm(OX + SW), mm(base)))
            comps.append('curve.close()')
            add('  #place(dx: 0mm, dy: 0mm, curve(fill: %s.transparentize(88%%), '
                'stroke: 0.9pt + %s, %s))' % (color, color, ", ".join(comps)))
        add('  #place(dx: %s, dy: %s)[#text(size: 8.4pt, fill: ink)[%s]]'
            % (mm(OX + SW - 19.0), mm(DY - 5.0), jval))
        conclusion = "投影后两类重叠较多" if idx == 0 else "投影后两类分离更明显"
        add('  #place(dx: %s, dy: 110mm)[#text(size: 8.5pt, fill: ink)[%s]]' % (mm(OX), conclusion))
        add(']')
        add('')

    add('#grid(columns: (%s, %s, %s), column-gutter: 0mm, %s, [], %s)'
        % (mm(PW), mm(GAP), mm(PW), panel_names[0], panel_names[1]))

    add('#v(1mm)')
    add('#align(center)[#box(circle(radius: 1.7pt, fill: ca)) #h(1mm) 类别 A #h(6mm) #box(circle(radius: 1.7pt, fill: cb)) #h(1mm) 类别 B #h(6mm) #text(size: 7.8pt, fill: muted)[合成样本，仅用于原理示意]]')
    return "\n".join(L) + "\n", j_pca, j_lda


def main():
    text, j_pca, j_lda = build()
    OUT.write_text(text, encoding="utf-8")
    print("wrote", OUT.relative_to(ROOT))
    print("Fisher J  PCA = %.3f   LDA = %.3f" % (j_pca, j_lda))


if __name__ == "__main__":
    main()
