import sys
from pathlib import Path
sys.path.insert(0, str(Path(sys.executable).parent.parent.parent))
from daimon_runtime import setup_plot
setup_plot()

import pandas as pd
import matplotlib.pyplot as plt

rtcm = pd.read_csv("rtcm_b1_metrics.csv").dropna(subset=["val_loss"])
vits = pd.read_csv("vits_metrics.csv").dropna(subset=["val_loss"])
den = pd.read_csv("densenet121_metrics.csv").dropna(subset=["val_loss"])

models = [
    (rtcm, "RTCMNetB1", "#d62728", "-o"),
    (vits, "ViT-S", "#1f77b4", "-s"),
    (den, "DenseNet-121", "#2ca02c", "-^"),
]

fig, axes = plt.subplots(1, 3, figsize=(10.5, 3.2))

panels = [
    ("val_loss", "(a) 验证损失", "验证损失", 0, None),
    ("de_val_acc", "(b) 脱叶率验证准确率", "验证准确率", 0, 1),
    ("ba_val_acc", "(c) 吐絮率验证准确率", "验证准确率", 0, 1),
]

for ax, (col, title, ylabel, ymin, ymax) in zip(axes, panels):
    for df, name, color, style in models:
        ax.plot(df["step"], df[col], style, color=color, ms=4, lw=1.5, label=name)
    ax.set_xlabel("训练步数 (step)")
    ax.set_ylabel(ylabel)
    ax.set_title(title)
    ax.set_ylim(ymin, ymax)
    ax.legend(frameon=False, fontsize=9, loc="best")
    ax.grid(alpha=0.3, lw=0.5)
    ax.spines[["top", "right"]].set_visible(False)

fig.tight_layout()
fig.savefig("chapters/基于深度学习/training_curves.png", dpi=300, bbox_inches="tight")
print("saved")
