#set page(width: 170mm, height: auto, margin: 3mm, fill: white)
#set text(font: ("Times New Roman", "STSong", "Songti SC"), size: 9pt, fill: rgb("222222"), top-edge: 0.8em, bottom-edge: -0.2em)
#set par(leading: 3pt, spacing: 0pt)
#let ink = rgb("344B55")
#let muted = rgb("52616A")
#let border = rgb("AAB6BB")
#let cell(body, fill: white, stroke: border, height: 12mm) = block(
 width: 100%, height: height, inset: (x: 1.5mm, y: 1.5mm),
 fill: fill, stroke: 0.5pt + stroke, radius: 1mm,
)[#align(center + horizon, body)]
#let stage(body) = cell(text(font: ("Times New Roman", "STHeiti", "Heiti SC"), size: 10pt, fill: white, body), fill: ink, stroke: ink)
#let options(..items) = grid(columns: (1fr,) * items.pos().len(), column-gutter: 2mm, ..items.pos().map(x => cell(x)))
#let right = align(center + horizon, text(size: 14pt, fill: ink)[→])
#let down = align(center + horizon, text(size: 12pt, fill: ink)[↓])
#grid(
 columns: (29mm, 7mm, 1fr), row-gutter: 0mm,
 stage[图像获取], right, options([可见光图像], [红外图像], [多／高光谱图像], [其他影像]),
 block(width: 100%, height: 4mm, down), [], [],
 stage[图像预处理], right, options([统一尺寸], [归一化], [图像去噪], [按需增强]),
 block(width: 100%, height: 4mm, down), [], [],
 stage[数据集划分], right, options([训练集\ 参数学习], [验证集\ 模型选择], [测试集\ 最终评价]),
 block(width: 100%, height: 4mm, down), [], [],
 stage[模型设计], right, cell([根据表型任务、数据特征与部署需求\ 选择模型架构、损失函数和训练参数], fill: rgb("F2F5F6")),
 block(width: 100%, height: 4mm, down), [], [],
 stage[模型训练], right, cell([训练集用于更新模型参数，验证集用于监测性能\ 按预设训练轮次或停止条件结束训练], fill: rgb("F2F5F6")),
 block(width: 100%, height: 4mm, down), [], [],
 stage[模型评价], right, options([任务评价指标], [混淆矩阵\ 与错误分析], [交叉验证\ 按研究设计选用]),
 block(width: 100%, height: 4mm, down), [], [],
 stage[模型预测], right, cell([固定模型与预处理流程\ 输入待测影像，预测未知表型信息], fill: rgb("F2F5F6")),
 block(width: 100%, height: 4mm, down), [], [],
 stage[输出预测结果], right, options([表型指标 1], [表型指标 2], [表型指标 3], [其他指标]),
 block(width: 100%, height: 4mm, down), [], [],
 stage[结果处理], right, options([结果可视化], [统计汇总], [结果解释]),
)
#v(3mm)
#block(width: 100%, inset: 2mm, stroke: (top: 0.5pt + border))[
 #set text(size: 8pt, fill: muted)
 #align(center)[训练样本扩增在数据划分后实施，预处理中的统计参数仅由训练数据确定。\ 测试集不参与参数学习或模型选择；输出形式随分类、检测、分割或回归任务而定。]
]
