#set page(width: 170mm, height: auto, margin: 3mm, fill: white)
#set text(font: ("Times New Roman", "STSong", "Songti SC"), size: 8pt, fill: black, top-edge: 0.8em, bottom-edge: -0.2em)
#set par(leading: 3pt, spacing: 0pt)

#let ink = black
#let border = rgb("AAB6BB")
#let soft = rgb("EDF2F5")
#let warm = rgb("C46A3F")

#let cw = 2.6mm            // 权重网格单元边长
#let gw = 6                // 网格行列数

// 单个权重单元；a 为不透明度（0~1）
#let wc(a, strokew: 0.2pt) = rect(
  width: cw, height: cw,
  fill: warm.transparentize(100% - a * 100%),
  stroke: strokew + border,
)

// 通道注意力权重：1×1×C，细长竖条
#let chan-cells = range(gw).map(i => rect(
  width: 3.4mm, height: cw,
  fill: warm.transparentize(80% - i * 10%),
  stroke: 0.2pt + border,
))
#let tensor-channel = grid(
  columns: (3.4mm,),
  row-gutter: 0mm,
  ..chan-cells,
)

// 空间注意力权重：1×H×W，中心强、边缘弱
#let spatial = (
  (0.10, 0.22, 0.34, 0.34, 0.22, 0.10),
  (0.22, 0.48, 0.70, 0.70, 0.48, 0.22),
  (0.34, 0.70, 0.94, 0.94, 0.70, 0.34),
  (0.34, 0.70, 0.94, 0.94, 0.70, 0.34),
  (0.22, 0.48, 0.70, 0.70, 0.48, 0.22),
  (0.10, 0.22, 0.34, 0.34, 0.22, 0.10),
)
#let sp-cells = spatial.flatten().map(a => wc(a, strokew: 0pt))
#let tensor-spatial = grid(
  columns: (cw,) * gw,
  row-gutter: 0mm,
  column-gutter: 0mm,
  ..sp-cells,
)

// 自注意力权重：N×N，稀疏矩阵
#let attn = (
  (0.90, 0.05, 0.02, 0.02, 0.05, 0.02),
  (0.04, 0.12, 0.76, 0.05, 0.03, 0.05),
  (0.02, 0.70, 0.10, 0.16, 0.02, 0.02),
  (0.03, 0.04, 0.80, 0.09, 0.04, 0.02),
  (0.02, 0.04, 0.05, 0.72, 0.14, 0.05),
  (0.04, 0.02, 0.02, 0.05, 0.82, 0.07),
)
#let at-cells = attn.flatten().map(a => wc(a))
#let tensor-attn = grid(
  columns: (cw,) * gw,
  row-gutter: 0mm,
  column-gutter: 0mm,
  ..at-cells,
)

// 三栏共用的面板结构
#let panel(title, gen, tensor, shape, effect, rep, cost) = [
  #align(center, text(size: 10pt)[#title])
  #v(1.8mm)
  #align(center, text(size: 7.8pt)[#gen])
  #v(2.4mm)
  #align(center, tensor)
  #v(1.4mm)
  #align(center, text(size: 9.4pt)[#shape])
  #v(2.2mm)
  #align(center, text(size: 7.8pt)[#effect])
  #v(2.4mm)
  #align(center, text(size: 7.6pt)[代表模块：#rep])
  #v(0.8mm)
  #align(center, text(size: 7.6pt)[#cost])
]

#let band(t) = block(
  width: 100%,
  inset: (x: 2mm, y: 1.8mm),
  fill: soft,
  stroke: 0.55pt + border,
  radius: 1mm,
  align(center + horizon, text(size: 9.2pt)[#t]),
)

#let arrow = align(center, text(size: 12pt, fill: ink)[↓])
#let cols = (52mm, 52mm, 52mm)

#band([输入特征图 $C times H times W$])
#v(1.6mm)
#grid(columns: cols, column-gutter: 4mm, arrow, arrow, arrow)
#v(0.4mm)
#grid(
  columns: cols,
  column-gutter: 4mm,
  panel(
    [通道注意力],
    [全局平均池化 → MLP → sigmoid],
    tensor-channel,
    [权重 $1 times 1 times C$],
    [沿通道方向逐通道缩放],
    [SE],
    [开销与通道数 $C$ 相关],
  ),
  panel(
    [空间注意力],
    [沿通道池化 → 卷积 → sigmoid],
    tensor-spatial,
    [权重 $1 times H times W$],
    [在每个空间位置逐位置缩放],
    [CBAM（空间分支）],
    [开销与像素数 $H times W$ 相关],
  ),
  panel(
    [自注意力],
    [线性映射 $bold(Q), bold(K), bold(V)$ → $bold(Q) bold(K)^top$ → softmax],
    tensor-attn,
    [权重 $N times N$],
    [以 token 对权重对 $bold(V)$ 加权求和],
    [ViT、Swin],
    [开销与 token 数平方 $N^2$ 相关],
  ),
)
#v(0.4mm)
#grid(columns: cols, column-gutter: 4mm, arrow, arrow, arrow)
#v(1.4mm)
#band([加权后输出 $C times H times W$])
