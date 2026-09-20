"""生成第 3 章 71 维多源结构化特征提取与融合流程图。

输出到 chapters/光谱指数/ms_feature_flow.png。
"""

from __future__ import annotations

from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch

plt.rcParams["font.sans-serif"] = [
    "PingFang SC",
    "Hiragino Sans GB",
    "Arial Unicode MS",
    "Heiti SC",
    "Songti SC",
    "DejaVu Sans",
]
plt.rcParams["axes.unicode_minus"] = False

_FILL = "#eef3fb"
_EDGE = "#3b6fb6"
_GROUP_FILL = "#eaf6ee"
_GROUP_EDGE = "#4a9e6b"
_OUT_FILL = "#f2f2f2"
_OUT_EDGE = "#666666"


def _box(ax, x0, y0, x1, y1, text, *, fill=_FILL, edge=_EDGE, fontsize=10):
    box = FancyBboxPatch(
        (x0, y0),
        x1 - x0,
        y1 - y0,
        boxstyle="round,pad=0.02,rounding_size=0.12",
        linewidth=1.2,
        edgecolor=edge,
        facecolor=fill,
    )
    ax.add_patch(box)
    ax.text(
        (x0 + x1) / 2,
        (y0 + y1) / 2,
        text,
        ha="center",
        va="center",
        fontsize=fontsize,
        linespacing=1.5,
    )


def _arrow(ax, x0, y0, x1, y1, *, color="#444444"):
    ax.add_patch(
        FancyArrowPatch(
            (x0, y0),
            (x1, y1),
            arrowstyle="-|>",
            mutation_scale=14,
            linewidth=1.1,
            color=color,
            shrinkA=0,
            shrinkB=0,
        )
    )


def main() -> None:
    figure, ax = plt.subplots(figsize=(9.2, 9.6))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis("off")

    _box(ax, 2.4, 9.0, 7.6, 9.9, "多光谱与可见光航点影像\nRGB 与 G / R / RE / NIR 波段")
    _arrow(ax, 5.0, 9.0, 5.0, 8.75)
    _box(ax, 2.4, 7.9, 7.6, 8.7, "多光谱反射率定标\n反射率板手工定标为 [0, 1] 反射率")
    _arrow(ax, 5.0, 7.9, 5.0, 7.65)
    _box(ax, 2.4, 6.8, 7.6, 7.6, "中心裁剪 224 × 224 像素")

    # 分支总线
    ax.plot([5.0, 5.0], [6.8, 6.35], color="#444444", linewidth=1.1)
    ax.plot([1.2, 8.8], [6.35, 6.35], color="#444444", linewidth=1.1)
    centers = [1.2, 3.75, 6.25, 8.8]
    for center in centers:
        _arrow(ax, center, 6.35, center, 6.05)

    _box(
        ax,
        0.05,
        4.55,
        2.35,
        6.05,
        "波段统计\n（20 维）\nG / R / RE / NIR\n均值 · 标准差\n10 / 50 / 90 分位",
        fill=_GROUP_FILL,
        edge=_GROUP_EDGE,
        fontsize=8.5,
    )
    _box(
        ax,
        2.55,
        4.55,
        4.85,
        6.05,
        "光谱指数\n（20 维）\nNDVI / GNDVI\nNDRE / RVI\n同类统计量",
        fill=_GROUP_FILL,
        edge=_GROUP_EDGE,
        fontsize=8.5,
    )
    _box(
        ax,
        5.05,
        4.55,
        7.35,
        6.05,
        "可见光特征\n（27 维）\nRGB / HSV 均值 · 标准差\nExG / VARI / NGRDI\n均值 · 标准差 · 分位数",
        fill=_GROUP_FILL,
        edge=_GROUP_EDGE,
        fontsize=8.5,
    )
    _box(
        ax,
        7.55,
        4.55,
        9.85,
        6.05,
        "NIR 纹理\n（4 维）\nGLCM 对比度\n同质性 · 能量\n相关性（4 方向均值）",
        fill=_GROUP_FILL,
        edge=_GROUP_EDGE,
        fontsize=8.5,
    )

    for center in centers:
        _arrow(ax, center, 4.55, center, 4.2)

    ax.plot([1.2, 8.8], [4.2, 4.2], color="#444444", linewidth=1.1)
    _arrow(ax, 5.0, 4.2, 5.0, 3.95)
    _box(ax, 2.6, 3.05, 7.4, 3.95, "特征标准化与拼接")
    _arrow(ax, 5.0, 3.05, 5.0, 2.8)
    _box(
        ax,
        2.2,
        1.9,
        7.8,
        2.8,
        "71 维结构化特征向量",
        fill=_OUT_FILL,
        edge=_OUT_EDGE,
        fontsize=11,
    )
    _arrow(ax, 5.0, 1.9, 5.0, 1.65)
    _box(
        ax,
        2.2,
        0.75,
        7.8,
        1.65,
        "分类器比较 · 信息源对比 · 消融验证",
        fill=_OUT_FILL,
        edge=_OUT_EDGE,
        fontsize=10,
    )

    output = (
        Path(__file__).resolve().parents[1]
        / "chapters"
        / "光谱指数"
        / "ms_feature_flow.png"
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    figure.tight_layout()
    figure.savefig(output, dpi=200, bbox_inches="tight")
    plt.close(figure)
    print(f"saved: {output}")


if __name__ == "__main__":
    main()
