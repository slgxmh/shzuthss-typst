#set page(width: 170mm, height: auto, margin: 3mm, fill: white)
#set text(font: ("Times New Roman", "STSong", "Songti SC"), size: 9pt, fill: rgb("222222"), top-edge: 0.8em, bottom-edge: -0.2em)
#set par(leading: 3pt, spacing: 0pt)
#let ink = rgb("344B55")
#let muted = rgb("52616A")
#let border = rgb("AAB6BB")
#let cell(body, height: 24mm, fill: white, stroke: border) = block(width: 100%, height: height, inset: 1.5mm, fill: fill, stroke: 0.5pt + stroke, radius: 1mm)[#align(center + horizon, body)]
#let stage(body) = cell(text(font: ("Times New Roman", "STHeiti", "Heiti SC"), size: 9.5pt, fill: white, body), height: 12mm, fill: ink, stroke: ink)
#let arrow = align(center + horizon, text(size: 12pt, fill: ink)[→])
#grid(
 columns: (1fr, 5mm, 1fr, 5mm, 1fr, 5mm, 1fr, 5mm, 1fr), row-gutter: 2mm,
 stage[农作物\ 图像采集], arrow,
 stage[图像\ 预处理], arrow,
 stage[特征提取\ 与选择], arrow,
 stage[分类器\ 训练与选择], arrow,
 stage[分类决策\ 与结果输出],
 cell([地面或无人机\ 影像采集\ 样本类别标注]), [],
 cell([尺寸统一\ 校正与去噪\ 按需提取前景]), [],
 cell([颜色与光谱指数\ 纹理与形态\ 特征筛选或降维]), [],
 cell([SVM、RF、LR 等\ 训练集拟合\ 验证集选择]), [],
 cell([固定特征流程\ 输入待测样本\ 输出类别或等级]),
)
#v(3mm)
#cell([图像信息 → 人工设计的特征向量 → 分类模型 → 预测结果], height: 9mm, fill: rgb("F2F5F6"))
#v(2mm)
#block(width: 100%, inset: 2mm, stroke: (top: 0.5pt + border))[
 #set text(size: 8pt, fill: muted)
 #align(center)[预处理与特征类型按任务选择；由数据拟合的处理参数仅在训练集上估计。\ 独立测试集用于最终评价，不参与特征或分类器选择。]
]
