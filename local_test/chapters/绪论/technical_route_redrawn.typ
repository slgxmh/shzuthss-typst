#set page(width: 170mm, height: auto, margin: 3mm, fill: white)
#set text(font: ("Times New Roman", "STSong", "Songti SC"), size: 9pt, fill: rgb("222222"), top-edge: 0.8em, bottom-edge: -0.2em)
#set par(leading: 3pt, spacing: 0pt)
#let ink = rgb("344B55")
#let muted = rgb("52616A")
#let border = rgb("AAB6BB")
#let cell(body, height: 17mm, fill: white) = block(width: 100%, height: height, inset: 2mm, fill: fill, stroke: 0.5pt + border, radius: 1mm)[#align(center + horizon, body)]
#let band(body) = block(width: 100%, height: 8mm, fill: ink, radius: 1mm)[#align(center + horizon, text(font: ("Times New Roman", "STHeiti", "Heiti SC"), size: 10pt, fill: white, body))]
#let down = block(width: 100%, height: 5mm)[#align(center + horizon, text(size: 13pt, fill: ink)[↓])]
#let heading(body) = cell(text(font: ("Times New Roman", "STHeiti", "Heiti SC"), size: 9.5pt, fill: ink, body), height: 9mm, fill: rgb("E8EFF1"))
#band[数据准备｜实验区域与样本构建（第 2 章）]
#v(2mm)
#grid(columns: (1fr, 1fr), column-gutter: 3mm, row-gutter: 2mm,
 heading[棉花双指标识别数据], heading[农业低光增强数据],
 cell([石河子多时相棉田无人机 RGB 影像\ 人工脱叶率与吐絮率调查\ 航点与双指标等级标签关联], height: 20mm),
 cell([沙湾多作物正常曝光无人机影像\ 真实低光校准影像\ 源影像筛选与图像块制作], height: 20mm),
)
#down
#band[方法研究｜特征比较、低光适配与轻量识别]
#v(2mm)
#grid(columns: (1fr, 1fr, 1fr), column-gutter: 3mm, row-gutter: 2mm,
 heading[传统机器学习（第 3 章）], heading[低光增强（第 4 章）], heading[联合识别（第 5 章）],
 cell([棉花双标签图像\ 像素向量基线\ 21 维颜色与指数统计], height: 19mm),
 cell([农业源影像与低光校准\ 可控退化与配对样本\ 合成—真实统计比较], height: 19mm),
 cell([棉花双标签图像\ 共享骨干与双分类头\ 多尺度卷积注意力], height: 19mm),
 down, down, down,
 cell([PCA+LR、RF 像素基线\ LR、RF、SVM 结构化分类\ 特征相关性与低光测试], height: 19mm, fill: rgb("F2F5F6")),
 cell([$L^3$-AgriUAVNet\ 恢复质量与组件消融\ 真实低光及下游检测评价], height: 19mm, fill: rgb("F2F5F6")),
 cell([RTCMNet\ 模型对比与结构消融\ 双任务性能与设备时延], height: 19mm, fill: rgb("F2F5F6")),
)
#v(2mm)
#cell([传统方法提供识别基线与特征依据；增强模型和 RTCMNet 用于田间流程。], height: 9mm)
#down
#band[田间验证｜正常光照与低光场景（第 6 章）]
#v(2mm)
#grid(columns: (1fr, 1fr), column-gutter: 3mm, row-gutter: 2mm,
 heading[正常光照路径], heading[低光路径],
 cell([多时相棉田影像 → RTCMNet\ 输出脱叶率与吐絮率等级], height: 15mm),
 cell([同位置原始与增强图像分别识别\ 比较 RTCMNet 双指标预测变化], height: 15mm),
)
#down
#cell([航点位置关联与双指标空间制图\ 时序变化、田块内部差异及与现场观察的对应], height: 15mm, fill: rgb("F2F5F6"))
#down
#cell([定位关注区域与组织现场复核\ 分析识别速度、部署代价及适用边界], height: 15mm, fill: rgb("E8EFF1"))
#v(2mm)
#block(width: 100%, inset: 2mm, stroke: (top: 0.5pt + border))[
 #set text(size: 8pt, fill: muted)
 #align(center)[方法章节评价图像块性能；田间结果主要用于时空对应分析。\ 低光棉花识别的精度增益仍需同步人工真值验证。]
]
