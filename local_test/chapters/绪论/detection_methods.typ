#set page(width: 170mm, height: auto, margin: 3mm, fill: white)
#set text(font: ("Times New Roman", "STSong", "Songti SC"), size: 9pt, fill: rgb("222222"), top-edge: 0.8em, bottom-edge: -0.2em)
#set par(leading: 3pt, spacing: 0pt)
#let ink = rgb("344B55")
#let muted = rgb("52616A")
#let cell(body, height: 15mm, fill: white, stroke: rgb("AAB6BB")) = block(
  width: 100%, height: height, inset: (x: 2mm, y: 1.5mm),
  fill: fill, stroke: 0.5pt + stroke, radius: 1mm,
)[#align(center + horizon, body)]
#let title(body) = cell(text(font: ("Times New Roman", "STHeiti", "Heiti SC"), size: 10pt, fill: white, body), height: 10mm, fill: ink, stroke: ink)
#let arrow = align(center, text(size: 13pt, fill: ink)[↓])
#let tag(body) = align(center, text(size: 8pt, fill: muted, body))
#grid(
 columns: (1fr, 1fr, 1fr), column-gutter: 3mm, row-gutter: 2mm,
 title[人工调查], title[图像处理与传统机器学习], title[深度学习],
 tag[调查对象], tag[影像来源], tag[影像来源],
 cell[样点内代表性植株\ 叶片与棉铃],
 cell[地面、无人机或卫星影像\ 可见光与多光谱信息],
 cell[地面或无人机影像\ 植株与冠层信息],
 arrow, arrow, arrow,
 tag[信息获取], tag[特征构建], tag[表征学习],
 cell[人工计数与重复调查\ 残留叶片、总铃与开放铃],
 cell[颜色与光谱指数\ 面积、覆盖度与纹理特征],
 cell[检测、分割或特征提取\ 器官信息与冠层表征],
 arrow, arrow, arrow,
 tag[指标获取路径], tag[指标获取路径], tag[指标获取路径],
 cell[依据调查基数\ 计算脱叶率与吐絮率],
 cell[经验标定、回归或分类\ 估计连续指标或等级],
 cell[器官统计后换算\ 或直接预测指标与等级],
 tag[主要限制], tag[主要限制], tag[主要限制],
 cell(text(size: 8pt)[调查费时、劳动强度大\ 有限样点难覆盖田块差异], height: 14mm, fill: rgb("F2F5F6")),
 cell(text(size: 8pt)[依赖特征与标定条件\ 易受光照、背景变化影响], height: 14mm, fill: rgb("F2F5F6")),
 cell(text(size: 8pt)[依赖标注与场景覆盖\ 需兼顾泛化与部署开销], height: 14mm, fill: rgb("F2F5F6")),
)
#v(3mm)
#block(width: 100%, inset: 2mm, stroke: (top: 0.5pt + rgb("AAB6BB")))[
 #set text(size: 8pt, fill: muted)
 #align(center)[面积、覆盖度及冠层特征是图像代理量，需经标定或建模与农艺指标建立对应。\ 图按主要信息处理方式归纳；不同方法可组合使用，观测尺度取决于数据来源。]
]
