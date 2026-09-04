#!/usr/bin/env python3
"""Generate the Chapter 3 visible-index and candidate-mask figure.

The three source images are real 224 x 224 UAV image patches.  ExG, VARI,
and NGRDI are computed deterministically from RGB values in [0, 1].  Each
index uses one shared robust display range across all maturity stages.  The
candidate green-leaf mask is obtained from ExG using image-wise Otsu
thresholding, followed by 3 x 3 opening/closing and small-component removal.
"""

from pathlib import Path

import cv2
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm
import numpy as np
from PIL import Image

plt.rcParams["font.family"] = ["Songti SC", "STSong", "Hiragino Sans GB", "Arial Unicode MS", "sans-serif"]
plt.rcParams["axes.unicode_minus"] = False


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "chapters" / "光谱指数" / "fig3_indices_stages.png"

SAMPLES = (
    ("早期", "DE 0 / BA 4", Path("/Volumes/ttt/research/de_ba/000000_de0_ba4.png")),
    ("中期", "DE 2 / BA 8", Path("/Volumes/ttt/research/de_ba/002723_de2_ba8.png")),
    ("后期", "DE 7 / BA 9", Path("/Volumes/ttt/research/de_ba/006534_de7_ba9.png")),
)


def load_rgb(path: Path) -> np.ndarray:
    if not path.exists():
        raise FileNotFoundError(f"Source image not found: {path}")
    return np.asarray(Image.open(path).convert("RGB"), dtype=np.float32) / 255.0


def visible_indices(rgb: np.ndarray) -> dict[str, np.ndarray]:
    red, green, blue = np.moveaxis(rgb, -1, 0)
    eps = 1.0e-6
    return {
        "ExG": 2.0 * green - red - blue,
        "VARI": (green - red) / (green + red - blue + eps),
        "NGRDI": (green - red) / (green + red + eps),
    }


def shared_robust_norm(values: list[np.ndarray]) -> TwoSlopeNorm:
    merged = np.concatenate([value.ravel() for value in values])
    low, high = np.nanpercentile(merged, (1.0, 99.0))
    extent = max(abs(float(low)), abs(float(high)), 1.0e-6)
    return TwoSlopeNorm(vmin=-extent, vcenter=0.0, vmax=extent)


def candidate_green_mask(exg: np.ndarray) -> np.ndarray:
    finite = np.nan_to_num(exg, nan=0.0, posinf=0.0, neginf=0.0)
    lo, hi = float(finite.min()), float(finite.max())
    scaled = np.zeros_like(finite, dtype=np.uint8)
    if hi > lo:
        scaled = np.clip((finite - lo) / (hi - lo) * 255.0, 0, 255).astype(np.uint8)

    _, mask = cv2.threshold(scaled, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel)

    count, labels, stats, _ = cv2.connectedComponentsWithStats(mask, connectivity=8)
    cleaned = np.zeros_like(mask)
    for component in range(1, count):
        if stats[component, cv2.CC_STAT_AREA] >= 20:
            cleaned[labels == component] = 255
    return cleaned


def main() -> None:
    rgb_images = [load_rgb(path) for _, _, path in SAMPLES]
    index_maps = [visible_indices(rgb) for rgb in rgb_images]
    norms = {
        name: shared_robust_norm([maps[name] for maps in index_maps])
        for name in ("ExG", "VARI", "NGRDI")
    }

    fig, axes = plt.subplots(3, 5, figsize=(11.2, 7.35), constrained_layout=True)
    column_titles = ("RGB", "ExG", "VARI", "NGRDI", "绿叶掩膜")
    images_for_colorbar = {}

    for row, ((stage, label, _), rgb, maps) in enumerate(zip(SAMPLES, rgb_images, index_maps)):
        axes[row, 0].imshow(rgb)
        for col, name in enumerate(("ExG", "VARI", "NGRDI"), start=1):
            shown = axes[row, col].imshow(maps[name], cmap="RdYlGn", norm=norms[name])
            images_for_colorbar[name] = shown
        axes[row, 4].imshow(candidate_green_mask(maps["ExG"]), cmap="gray", vmin=0, vmax=255)

        axes[row, 0].set_ylabel(f"{stage}\n{label}", fontsize=13.5, fontweight="bold", labelpad=9)
        for ax in axes[row]:
            ax.set_xticks([])
            ax.set_yticks([])
            for spine in ax.spines.values():
                spine.set_linewidth(0.6)
                spine.set_edgecolor("0.45")

    for col, title in enumerate(column_titles):
        axes[0, col].set_title(title, fontsize=14, fontweight="bold", pad=7)

    for col, name in enumerate(("ExG", "VARI", "NGRDI"), start=1):
        colorbar = fig.colorbar(
            images_for_colorbar[name],
            ax=axes[:, col],
            orientation="horizontal",
            fraction=0.035,
            pad=0.025,
            aspect=25,
        )
        colorbar.ax.tick_params(labelsize=10, length=2)

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUTPUT, dpi=360, facecolor="white", bbox_inches="tight")
    plt.close(fig)
    print(f"Wrote {OUTPUT}")
    for name, norm in norms.items():
        print(f"{name} shared display range: [{norm.vmin:.4f}, {norm.vmax:.4f}]")


if __name__ == "__main__":
    main()
