#import "../../../template.typ": three-line-table

= 低光增强模型与下游任务适用性评价

== 引言

本章以第 5 章的低光图像对训练轻量增强网络 $L^3$-AgriUAVNet，并从图像恢复、设备效率和下游检测三个方面评价其效果。合成配对测试用于衡量恢复质量，真实低光影像用于观察场景适应性，YOLOv8n 与 YOLOv8s 实验则用于判断增强输入是否有利于检测。6.2 节介绍方法与实验设置，6.3—6.5 节给出结果、讨论和小结。

== 材料与方法

=== 数据集构建

本章采用合成图像对训练，并以真实低光影像补充评价。数据包括正常曝光源影像、真实低光标定影像和评价图像块，三者的数量及用途分别说明如下。退化算子与参数见@fig:lowlight_stats。

合成配对数据来源于在研究区域内邻近采集日期的航线飞行任务中选取的 1306 张正常曝光 UAV 原始影像，覆盖小麦、棉花和玉米的多时相冠层形态、行结构、土壤背景与光照变化。多尺度裁剪、随机旋转和翻转用于生成正常曝光目标图像块并扩展飞行高度、航向和视角变化；随后依据第 5 章所述流程生成对应的低光输入（见@fig:lowlight_pairgen），构成低光/正常曝光配对样本 $(x, t)$。配对数据以图像块为抽样单位，在固定随机种子 42 下按 0.8/0.1/0.1 划分为训练集、验证集和测试集，固定测试集包含 3265 个图像块。所有对比模型与消融变体使用同一组划分索引，因此 3265 表示由 1306 张源影像构建的测试样本数量，而非额外采集的原始航片数量。由于图像块采样自共享的源影像，图像块级划分可能使同一场景的图像块进入不同子集，因此绝对分数应视为偏乐观的域内估计，而共享的划分索引保证了所有方法间比较的内部公平性。

连续航测影像保留了相邻田间区域的结构相似性。统一图像块划分便于在相同输入条件下比较模型，但共享源影像带来的相关性仍然存在，不能将方法比较的内部一致性等同于测试场景的独立性。

退化参数标定采用另外采集的 26 张真实低光棉花 UAV 原始影像，依据亮度、饱和度、RGB 通道比例分布和视觉观感人工调整采样范围。这 26 张影像仅用于标定，不参与模型训练及后续玉米苗评价。@fig:lowlight_stats 显示，合成样本覆盖了真实低光影像的暗强度与通道比例区间，表明校准参数能够刻画当前农业场景的主要低光统计特征。

真实场景评价采用玉米苗低光 UAV 影像，与 26 张棉花标定影像相互独立。308 个图像块缺少严格配对的正常曝光参考，用于视觉比较和无参考质量评价；幼苗中心点标注则转换为检测框，用于训练检测器，并在固定的 139 个测试图像块上评价检测性能。两类评价分别考察图像外观变化和任务效果。

下游输入统一缩放至 $512 times 512$。Raw 与各增强方法使用相同的训练、验证和测试索引，检测器分别在对应输入分布上训练和测试。这样比较的是经相应数据适配后的增强器—检测器组合，避免仅在测试阶段增强图像造成额外的训练—测试分布差异。

=== 网络架构

#figure(
  image("fig3_architecture.png", width: 100%),
  caption: [
    $L^3$-AgriUAVNet 及其核心模块。(a) 总体增强路径：RGB 输入经 HVI 变换、$3 times 3$ 头部卷积、两个 RFDN-S、全局调制和 HVI 空间残差重建后转回 RGB。(b) RFDN-S 通过三级逐步特征蒸馏获得 $d_1, d_2, d_3$，再将最后变换特征 $r_4$ 与其拼接，经 $1 times 1$ 融合、ESA 和局部残差输出。(c) ESA 通过通道压缩、下采样空间编码和上采样生成像素级注意力。(d) GMod 使用全局平均池化与 MLP 预测逐通道增益和偏置。$L^3$-AgriUAVNet 使用两个块、48 通道、0.25 蒸馏比和标准卷积，共 0.139 M 参数。
  ],
) <fig:l3_network>

*设计目标与总体流程。*$L^3$-AgriUAVNet 用于提高暗区可见度，保留幼苗边界与作物行纹理，并减轻低照度和白平衡变化引起的通道比例偏移。网络以较浅主干和有限通道数控制端侧开销，整体结构见@fig:l3_network (a)。设归一化低光输入为 $bold(I)_("rgb") in [0, 1]^(B times 3 times H times W)$，前向过程为

$
bold(Z) & = cal(T)_("HVI")(bold(I)_("rgb")), quad & bold(F)_0 & = phi_h (bold(Z)), \
bold(F)_2 & = cal(B)_2 (cal(B)_1 (bold(F)_0)), quad & bold(F)_m & = cal(G)(bold(F)_2), \
bold(R)_("hvi") & = phi_t ([bold(F)_0, bold(F)_m]), quad & hat(bold(I))_("rgb") & = op("clip")(cal(T)_("HVI")^(-1)(bold(Z) + bold(R)_("hvi")), 0, 1),
$

其中，$cal(T)_("HVI")$ 和 $cal(T)_("HVI")^(-1)$ 分别表示 HVI 正变换与逆变换，$phi_h$ 和 $phi_t$ 表示头部与尾部映射，$cal(B)_i$ 表示 RFDN-S，$cal(G)$ 表示 Global Modulation（GMod）。网络设置两类跳跃连接：$bold(Z)$ 参与 HVI 空间残差重建，$bold(F)_0$ 在尾部与深层调制特征融合。

*面向强度与色彩比例建模的 HVI 表征。*网络首先将 RGB 转换为 Horizontal/Vertical-Intensity（HVI）表征@yan2025cidnet。对单个像素的归一化通道值 $R, G, B in [0, 1]$，定义强度 $I$、最小通道值 $m$ 和饱和度 $S$ 为

$ I = max(R, G, B), quad m = min(R, G, B), quad S = frac(I - m, I + epsilon), $

其中 $I = 0$ 时令 $S = 0$，$epsilon = 10^(-8)$ 用于数值稳定。记 $h in [0, 1)$ 为按 HSV 分段规则计算并归一化后的色相。HVI 使用强度相关的色彩敏感度

$ C_k (I) = [sin(frac(pi I, 2)) + epsilon]^k $

缩放色相–饱和度平面，并将三个输出通道定义为

$ H = C_k (I) S cos(2 pi h), quad V = C_k (I) S sin(2 pi h), quad I = max(R, G, B). $

指数 $k$ 为可学习参数，初始值为 0.2。强度相关缩放能够抑制暗区不稳定的色彩幅值，同时以二维方向保留相对色相，为植被、土壤及其边界处的通道比例校正提供结构化表征。

逆变换将 $H, V$ 裁剪至 $[-1, 1]$，将 $I$ 裁剪至 $[0, 1]$，并计算 $bar(H) = H / (C_k (I) + epsilon)$ 与 $bar(V) = V / (C_k (I) + epsilon)$。随后由 $h = op("atan2")(bar(V), bar(H)) / (2 pi) mod 1$ 和 $S = op("clip")(sqrt(bar(H)^2 + bar(V)^2 + epsilon), 0, 1)$ 恢复 HSV 参数，经标准 HSV–RGB 分段映射获得 RGB 输出。

*浅层单流特征提取。*头部映射 $phi_h$ 采用保持空间尺寸的 $3 times 3$ 卷积，将 $bold(Z) in RR^(B times 3 times H times W)$ 投影为

$ bold(F)_0 = phi_h (bold(Z)) in RR^(B times 48 times H times W). $

主干串联两个 RFDN-S，块内卷积通过填充保持 $H times W$ 分辨率，减少下采样对幼苗边界和细窄作物行的压缩。三个 HVI 通道在同一特征流中处理，使强度与色彩信息在卷积中共同参与计算。两个块、48 通道的配置用于控制参数规模，其效果通过后续深度与宽度消融比较。

*RFDN-S 残差特征蒸馏块。*主干中的浅层残差特征蒸馏块记为 RFDN-S，完整 RFDN 专指对比实验中的基线网络。每个 RFDN-S 围绕两条非对称路径组织：低成本的蒸馏路径用于保留早期局部响应，收窄至 $C - d$ 通道的细化路径则继续积累邻域上下文。块内不逐级累加残差，而是在注意力加权后以一次块级局部残差维持浅层主干中的直接梯度通路；空间加权则由下一小节所述的精简 ESA 完成。这些选择将 RFDN 的逐级特征蒸馏思想@liu2020residual 适配到浅层农业主干上，其与原始 RFDB 的结构差异汇总于@tab:l3_arch_relation。网络层面，特征融合在各块内部完成，因此两个顺序连接的 RFDN-S 即可满足需求，无需多块输出拼接；由于表征始终保持全分辨率，也不需要上采样恢复头。对于输入 $bold(X) in RR^(B times C times H times W)$，本章取 $C = 48$、蒸馏比 $rho = 0.25$，因此每级蒸馏通道数 $d = floor(rho C) = 12$，连续细化通道数 $r = C - d = 36$。

如@fig:l3_network (b) 所示，前三个阶段各自包含蒸馏路径和细化路径。蒸馏路径用 $1 times 1$ 卷积提取 12 通道特征，细化路径用标准 $3 times 3$ 卷积和 LeakyReLU 生成 36 通道特征：

$
bold(D)_1 & = phi_(1 times 1)^(d, 1)(bold(X)), quad & bold(R)_1 & = sigma(phi_(3 times 3)^(r, 1)(bold(X))), \
bold(D)_i & = phi_(1 times 1)^(d, i)(bold(R)_(i - 1)), quad & bold(R)_i & = sigma(phi_(3 times 3)^(r, i)(bold(R)_(i - 1))), quad i = 2, 3,
$

其中 $sigma$ 为负斜率 0.1 的 LeakyReLU。第四阶段不再拆分通道，而是将 $bold(R)_3$ 映射为最后一组蒸馏宽度特征：

$ bold(R)_4 = sigma(phi_(3 times 3)^(d, 4)(bold(R)_3)). $

随后在通道维拼接 $[bold(D)_1, bold(D)_2, bold(D)_3, bold(R)_4]$，得到 48 通道特征，并通过 $1 times 1$ 卷积完成融合：

$ bold(F)_d = phi_(1 times 1)^f ([bold(D)_1, bold(D)_2, bold(D)_3, bold(R)_4]). $

蒸馏路径保留较早阶段的局部响应，细化路径通过连续卷积扩大上下文范围。两者融合后用于描述幼苗轮廓、作物行纹理和低纹理冠层。融合结果经 ESA 加权，再与块输入相加：

$ cal(B)(bold(X)) = bold(X) + cal(E)(bold(F)_d), $

其中 $cal(E)$ 表示 ESA。局部残差连接保留块输入，并为两个连续 RFDN-S 提供直接的梯度传播路径。

*增强空间注意力。*Enhanced Spatial Attention（ESA）位于每个 RFDN-S 的特征融合之后（@fig:l3_network (c)）。该模块依次执行通道压缩、步幅卷积、局部细化和双线性上采样，以较低分辨率估计注意力。相较 RFDN 中的 ESA@liu2020residual，本章省去最大池化分支和一个卷积层（@tab:l3_arch_relation）。对输入 $bold(F)_d in RR^(B times 48 times H times W)$，先以 $1 times 1$ 卷积将通道压缩至 $C_("mid") = 12$，再用步长为 2 的 $3 times 3$ 卷积编码空间上下文，并用另一个 $3 times 3$ 卷积细化响应：

$
bold(F)_c & = sigma(phi_(1 times 1)^(e 1)(bold(F)_d)), \
bold(F)_s & = sigma(phi_(3 times 3)^(e 2)(sigma(phi_(3 times 3, s = 2)^(e 1)(bold(F)_c)))).
$

编码特征通过双线性插值恢复至 $H times W$，再由 $1 times 1$ 卷积恢复为 48 通道。sigmoid 函数生成逐通道、逐位置注意力掩码：

$ bold(A) = op("sigmoid")(phi_(1 times 1)^(e 3)(op("Up")(bold(F)_s))), quad cal(E)(bold(F)_d) = bold(F)_d dot.o bold(A). $

ESA 在压缩通道和降采样空间上估计注意力，降低了直接处理完整特征张量的空间开销。所得掩码在保持特征分辨率的同时，自适应调节幼苗边缘、作物行纹理和土壤细节等局部响应。

*全局仿射调制。*两个 RFDN-S 主要在有限邻域内提取和筛选局部结构，而整幅无人机图像还可能受到统一欠曝或通道增益偏移的影响。Global Modulation（GMod）因此在第二个块之后执行样本级通道调节（@fig:l3_network (d)）。对 $bold(F)_2 in RR^(B times 48 times H times W)$，自适应全局平均池化得到 $bold(z) in RR^(B times 48)$，两层 MLP 按 $48 arrow.r 64 arrow.r 96$ 映射通道描述子：

$ bold(z) = op("GAP")(bold(F)_2), quad [Delta bold(g), bold(b)] = op("MLP")(bold(z)). $

MLP 中间层使用负斜率 0.1 的 LeakyReLU。其 96 维输出均分为增益残差 $Delta bold(g)$ 和偏置 $bold(b)$，二者重塑为 $B times 48 times 1 times 1$ 后广播至所有空间位置：

$ bold(F)_m = bold(F)_2 dot.o (bold(1) + Delta bold(g)) + bold(b). $

最后一个线性层的权重和偏置均初始化为 0，因而训练开始时 $Delta bold(g) = bold(0)$、$bold(b) = bold(0)$，GMod 接近恒等映射。随着训练进行，GMod 学习针对每幅输入的通道级增益与偏置，用于补充 RFDN-S 和 ESA 的局部结构建模，校正全局曝光与色彩比例变化。

从操作形式看，GMod 与 Squeeze-and-Excitation（SE）通道重标定@hu2018senet 和 Feature-wise Linear Modulation（FiLM）@perez2018film 均相关，但三者作用方式不同。SE 通常由全局描述子生成 sigmoid 通道权重，只执行乘性重标定；FiLM 使用条件信息生成特征级尺度与偏置，条件通常来自另一输入或网络分支。本章 GMod 直接以当前增强特征的 GAP 描述子作为自条件，同时预测增益残差和加性偏置，仅在第二个 RFDN-S 后执行一次，并通过零初始化保持训练初期的恒等映射。这一配置以较低开销为浅层增强主干提供了全局曝光和通道比例调节能力。

*HVI 空间残差重建与模型配置。*尾部将浅层特征 $bold(F)_0$ 与调制特征 $bold(F)_m$ 在通道维拼接，形成 $B times 96 times H times W$ 的融合输入。$phi_t$ 依次使用 $1 times 1$ 卷积将通道数由 96 降至 48、LeakyReLU、$3 times 3$ 卷积、LeakyReLU 和最终的 $3 times 3$ 卷积，预测三通道 HVI 空间残差：

$ bold(R)_("hvi") = phi_t ([bold(F)_0, bold(F)_m]), quad hat(bold(Z)) = bold(Z) + bold(R)_("hvi"). $

原始 HVI 表征到 $hat(bold(Z))$ 的长残差连接将学习目标限定为从低光输入到参考曝光的增量校正；$bold(F)_0$ 到尾部的浅层跳跃连接则重新引入未经连续块变换的高分辨率局部特征。增强后的 HVI 表征经 $cal(T)_("HVI")^(-1)$ 转回 RGB，并裁剪到 $[0, 1]$ 作为最终输出。

本章将标准卷积配置统一记为 $L^3$-AgriUAVNet：深度 $D = 2$、宽度 $C = 48$、蒸馏比为 0.25，启用 ESA 和 GMod，参数量约为 0.139 M。其 DWConv 变体统一记为 $L^3$-AgriUAVNet-DW，使用相同的深度、宽度和模块配置，但以深度可分离卷积替换 RFDN-S 细化路径中的标准卷积，参数量约为 0.07 M。两种卷积配置的定量比较在结果部分单独报告。

*与相关架构的关系。*@tab:l3_arch_relation 比较了 $L^3$-AgriUAVNet 的组件来源与结构调整。HVI-CIDNet 提供 HVI 表征，原网络使用强度—色彩双分支和跨注意力；RFDN/RFDB 提供逐级特征蒸馏与 ESA，原结构包含较宽的细化路径、多块输出融合和恢复头；SCI 则采用更轻量的照明估计。本文将 HVI 与特征蒸馏组织为单流主干，使用两个浅层块、一次自条件全局调制和 HVI 残差重建，以适应农业 UAV 的参数预算。

#figure(
  three-line-table(table(
    columns: 5,
    table.header([方法], [表征与路径], [局部主干], [全局调节], [与本章架构的关系]),
    [HVI-CIDNet@yan2025cidnet], [HVI；强度/色彩双分支], [CIDNet 与跨注意力交互], [无本章的自条件 GMod], [HVI 表征的直接来源；本章移除双分支和跨注意力，改用浅层的单流 HVI 表征路径],
    [RFDN/RFDB@liu2020residual], [RGB 单流], [4 个 RFDB、全宽细化路径、多块拼接融合与 ESA], [无 GMod], [蒸馏与 ESA 的直接来源；RFDN-S 缩减细化宽度，主干减为 2 块并取消多块拼接恢复],
    [SCI@ma2022sci], [RGB 单流], [推理时使用单个照明增强块], [无 HVI、ESA 或 GMod], [极轻量直接对照；侧重自校准照明估计，与本章的单流 HVI 表征路径和蒸馏主干不同],
    [$L^3$-AgriUAVNet], [单流 HVI 表征路径与 HVI 空间残差重建], [2 个 RFDN-S，$C = 48$、$d \/ r = 12 \/ 36$，精简 ESA 与块级残差], [单次 GAP–MLP 预测逐通道增益和偏置，零初始化], [面向农业 UAV 参数预算的轻量配置与任务导向集成],
  )),
  caption: [
    $L^3$-AgriUAVNet 与最邻近架构的结构关系。比较旨在区分既有组件来源与本章的任务导向配置。
  ],
  kind: table,
) <tab:l3_arch_relation>

=== 损失函数

网络采用端到端训练，复合低光恢复损失 LLLoss 同时约束像素重建、梯度一致性和色彩比例稳定性：

$ cal(L)_("LL") = w_("char") cal(L)_("char") + w_("grad") cal(L)_("grad") + w_("color") cal(L)_("color"), $

其中，经验权重设置为 $w_("char") = 1.0$、$w_("grad") = 0.2$ 和 $w_("color") = 0.05$。

Charbonnier 损失@charbonnier1994two 提供鲁棒像素重建项，对小误差近似 L2、对大误差近似 L1，相比纯 L2 对异常值更不敏感：

$ cal(L)_("char") = sqrt((hat(bold(y)) - bold(y))^2 + epsilon^2), quad epsilon = 10^(-6), $

其中 $hat(bold(y))$ 和 $bold(y)$ 分别为预测的正常曝光图像和目标图像。

梯度损失通过比较预测图像与目标图像的 Sobel 水平和垂直梯度来强化结构一致性：

$ cal(L)_("grad") = norm(nabla hat(bold(y)) - nabla bold(y))_1, $

其中，$nabla$ 表示 Sobel 梯度算子。该项强化预测结果与目标图像在叶片边缘和作物行结构上的一致性。

色彩一致性损失计算预测与目标图像的归一化平均颜色向量之间的 L1 距离，约束通道间相对比例：

$ cal(L)_("color") = norm(frac(bar(bold(c))(hat(bold(y))), sum_d bar(bold(c))_d (hat(bold(y)))) - frac(bar(bold(c))(bold(y)), sum_d bar(bold(c))_d (bold(y))))_1, $

其中 $bar(bold(c))(dot.op) in RR^3$ 为平均 RGB 向量，$d$ 索引三个通道。通过比较前先归一化平均向量，损失关注相对色彩比例而非绝对亮度，从而减少全局色彩偏移。

=== 实验设置

上游低光增强实验在配备 NVIDIA GeForce RTX 4090（24 GB 显存；NVIDIA Corp., Santa Clara, CA, USA）的工作站上完成，下游检测实验运行于配备 NVIDIA GeForce RTX 5090 的 AutoDL 云服务器。软件环境为 Ubuntu 22.04、Python 3.12、PyTorch 2.8.0 和 CUDA 12.8。所有模型使用相同的配对数据与训练、验证和测试索引，输入和输出均为归一化至 $[0, 1]$ 的 RGB 图像；随机种子固定为 42。

上游模型在 $224 times 224$ 配对图像块上训练，使用 Adam 优化器@kingma2014adam，恒定学习率 $10^(-4)$，$beta_1 = 0.9$，$beta_2 = 0.999$，$epsilon = 10^(-8)$，不使用权重衰减。批量大小按模型显存需求选取：Restormer 为 4；LLFormer、Retinexformer、Uformer 和 $L^3$-AgriUAVNet 为 16；HVI-CIDNet 为 32；RFDN 和 SCI 为 64。最大 epoch 设置为 HVI-CIDNet 和 RFDN 各 10 个、其余模型 200 个。由于训练数据由大量同域图像块构成，单个 epoch 包含较多优化步骤，而图像块之间的场景多样性相对有限，本研究采用 epoch 内多次验证，以及时监测验证损失并减少同质样本上的继续拟合。所有模型每 0.2 个 epoch 验证一次，并以连续 3 次验证未改善作为早停条件，同时保留验证损失最小的检查点；早停均在两个完整 epoch 之前触发，因此最大 epoch 设置未构成实际约束。

下游检测采用 Ultralytics 8.4.82 实现的 YOLOv8n 和 YOLOv8s@jocher2023yolov8，分别作为轻量和均衡检测器的代表。图像缩放至 $512 times 512$，每个 LabelMe 点标注表示一株玉米苗的中心。YOLO 训练前，每个点被转换为以该点为中心的固定正方形边界框，归一化宽度和高度均为 0.04（在 $512 times 512$ 分辨率下约为 $20.5 times 20.5$ 像素）；与图像边界相交的框裁剪至有效图像范围。Raw 与各增强方法对应的输入分布使用相同的转换后标注。每个检测器训练 75 个 epoch，早停耐心为 20；YOLOv8n 批量大小 256，YOLOv8s 批量大小 128。所有送入检测器的输入遵循相同训练安排，以减少检测器训练协议差异造成的混杂并提高方法间比较的一致性。

=== 评价指标

低光增强质量采用四项标准指标评价。PSNR 和 SSIM@wang2004ssim 分别度量像素保真度与结构相似度，MAE 反映平均像素误差，LPIPS@zhang2018unreasonable 衡量感知距离。每项指标先在每个测试图像块上独立计算，再在固定测试集上取算术均值。

真实低光图像缺少严格配对的正常曝光参考，因此采用无参考自然度、曝光与通道关系以及结构响应三类互补指标。输入 RGB 图像归一化至 $[0, 1]$，并按 Rec. 601 系数转换为灰度亮度：

$ Y(p) = 0.299 R(p) + 0.587 G(p) + 0.114 B(p). $

NIQE@mittal2013niqe 按官方 MATLAB/BasicSR 实现的自然场景统计流程计算，使用预训练高质量图像多元高斯参数、$96 times 96$ 图像块和两个尺度；BRISQUE@mittal2012brisque 使用 pybrisque 1.0 的 36 维空间统计特征及其预训练支持向量回归模型。两者得分越低，表示图像统计越接近其各自模型中的高质量自然图像先验。

欠曝像素比例定义为亮度低于 $10 \/ 255$ 的像素占比：

$ U = frac(1, |Omega|) sum_(p in Omega) op("I")[Y(p) < frac(10, 255)]. $

设 $mu_R, mu_G, mu_B$ 为单幅图像的 RGB 通道均值，$bar(mu) = (mu_R + mu_G + mu_B) / 3$，RGB 通道均衡偏差定义为

$ D_("RGB") = frac(|mu_R - bar(mu)| + |mu_G - bar(mu)| + |mu_B - bar(mu)|, 3 bar(mu)). $

$D_("RGB")$ 越低表示三个通道的全局均值越均衡；该指标刻画相对通道偏置，不等同于相对于正常曝光参考的色差。

结构响应由 Tenengrad、边缘密度和局部对比度描述。Tenengrad 为 $3 times 3$ Sobel 水平与垂直梯度幅值的像素均值；边缘密度为 Canny 算法@canny1986edge 在低、高阈值分别为 50 和 150 时得到的边缘像素比例；局部对比度为 $7 times 7$ 邻域灰度标准差的像素均值。增强、锐化和噪声均可能提高这些响应，因此三者用于描述结构变化，不设单调的最优方向。上述指标先在每个图像块上独立计算，再对 308 个图像块取算术均值；Raw 与各增强结果按文件名一一对应。

模型复杂度以总参数量和计算量表示。计算量由 THOP 在评估模式、批量大小为 1、输入尺寸为 $1 times 3 times 224 times 224$ 时统计，以 GMACs 报告。
模型间差异使用同一测试图像块上的配对统计进行分析。文中报告以图像块为单位的 paired-bootstrap 置信区间和 Holm 校正 $p$ 值，用于量化固定域内评价协议下方法间差异的方向、幅度和稳定性。
下游玉米苗检测对两种检测器配置均报告 mAP\@0.5、Precision 和 Recall；YOLOv8n 另报告 COCO 风格的 mAP\@0.5:0.95。
文中报告的方法间差异均由未四舍五入的指标值计算；表中数值为显示用四舍五入结果。

== 实验与结果

实验从合成配对恢复质量、模型效率、组件消融、真实低光表现和下游任务响应五个方面评价 $L^3$-AgriUAVNet。

=== 整体性能对比

#figure(
  three-line-table(table(
    columns: 7,
    table.header([方法], [参数量(M)↓], [MACs(G)↓], [PSNR(dB)↑], [SSIM↑], [MAE↓], [LPIPS↓]),
    [LLFormer@wang2023llformer], [5.807], [15.507], [*26.54*], [0.888], [*0.0441*], [*0.103*],
    [Restormer@zamir2022restormer], [25.872], [71.820], [26.16], [0.866], [0.0452], [0.105],
    [Retinexformer@cai2023retinexformer], [2.028], [15.747], [26.10], [0.891], [0.0450], [0.125],
    [Uformer@wang2022uformer], [6.192], [18.475], [24.66], [0.817], [0.0522], [0.222],
    [HVI-CIDNet@yan2025cidnet], [1.976], [6.227], [24.30], [0.795], [0.0533], [0.252],
    [RFDN@liu2020residual], [0.371], [17.593], [22.53], [0.800], [0.0649], [0.360],
    [SCI@ma2022sci], [*0.022*], [*1.493*], [21.86], [0.773], [0.0731], [0.289],
    [*$L^3$-AgriUAVNet*], [0.139], [6.252], [26.24], [*0.893*], [0.0452], [0.119],
  )),
  caption: [
    合成配对测试集上的增强质量与模型复杂度。质量指标为固定划分的 3265 个测试图像块上逐块测量的算术均值，PSNR/SSIM 越高、MAE/LPIPS 越低越好。$L^3$-AgriUAVNet 指标准卷积配置；参数量为模型总参数量，MACs 使用 THOP 在 evaluation mode、batch size 为 1、$1 times 3 times 224 times 224$ 输入下统计。各数值列最优值以粗体标出，设备端延迟见@tab:l3_ipad。
  ],
  kind: table,
) <tab:l3_overall>

对比方法覆盖不同结构与复杂度层级，包括超高清低光 Transformer LLFormer@wang2023llformer、通用图像复原模型 Restormer@zamir2022restormer、单阶段 Retinex Transformer Retinexformer@cai2023retinexformer、U 形图像复原 Transformer Uformer@wang2022uformer、采用 HVI 与跨注意力的 HVI-CIDNet@yan2025cidnet，以及基于残差特征蒸馏和自校准照明的轻量模型 RFDN@liu2020residual 与 SCI@ma2022sci。该组合能够同时考察恢复质量与边缘部署效率。

@tab:l3_overall 显示，$L^3$-AgriUAVNet 以 0.139 M 参数取得 26.24 dB PSNR 和 0.893 SSIM，其中 SSIM 为所有方法最高。其 PSNR 比 Restormer 高 0.09 dB，距 LLFormer 仅 0.30 dB。统一计算量统计条件下，模型为 6.252 GMACs，ONNX 文件大小为 0.79 MiB；相比之下，LLFormer、Retinexformer 和 RFDN 的模型大小分别为 22.62、8.30 和 1.45 MiB。

$L^3$-AgriUAVNet 的参数量约为 LLFormer 的 1/42、Retinexformer 的 1/15 和 RFDN 的 1/2.7，MACs 则分别约为 LLFormer、Retinexformer 和 RFDN 的 40%、40% 和 36%。结合设备端延迟测试，该模型在保持较高结构质量的同时显著降低了存储与计算开销。

逐图像块配对统计给出了差异的幅度。相对 Restormer，$L^3$-AgriUAVNet 的 PSNR 平均提高 0.0878 dB（95% paired bootstrap CI $[0.0470, 0.1301]$，Holm 校正 $p = 0.0105$），SSIM 提高 0.0271（$p < 0.001$）。相对 LLFormer，其 PSNR 低 0.2977 dB、SSIM 高 0.00555，MAE 和 LPIPS 则由 LLFormer 占优。因此，在当前测试集上，$L^3$-AgriUAVNet 的主要特点是较小规模和较高结构相似性，像素误差与感知距离仍有改进空间。

=== 运行效率分析

#figure(
  image("fig4_quality_efficiency.png", width: 90%),
  caption: [
    合成配对测试集上的质量–参数量权衡。参数量采用对数坐标，以区分大型 Transformer 与轻量模型。$L^3$-AgriUAVNet 位于高 SSIM 与低参数量的质量–参数量前沿，但 LLFormer 仍具有更高 PSNR。计算量和设备端延迟分别见@tab:l3_overall 和@tab:l3_ipad。
  ],
) <fig:l3_quality_efficiency>

@fig:l3_quality_efficiency 与@tab:l3_overall 显示，$L^3$-AgriUAVNet 在较低参数量和 MACs 下取得了较高 SSIM。RFDN 的参数量和 MACs 分别为其约 2.7 倍和 2.8 倍；HVI-CIDNet 的参数量约为其 14.2 倍，但两者 MACs 接近。参数量描述存储规模，MACs 描述计算需求，两者需要分别报告。

#figure(
  three-line-table(table(
    columns: 3,
    table.header([方法], [平均推理时间 (ms/image)↓], [约当 FPS↑]),
    [$L^3$-AgriUAVNet], [*202*], [*4.95*],
    [LLFormer], [569], [1.76],
    [RFDN], [1281], [0.78],
    [Retinexformer], [2712], [0.37],
  )),
  caption: [
    iPad Air（第 3 代）上的软件端模型推理效率。所有方法均使用 ONNX Runtime Web 1.23.2、WebGPU execution provider，启用图优化，输入为随机 float32 $1 times 3 times 224 times 224$，batch size 为 1；5 次 warm-up 后计时 10 次并取平均。计时不含会话创建、模型加载、预处理和后处理。
  ],
  kind: table,
) <tab:l3_ipad>

在@tab:l3_ipad 的固定协议下，$L^3$-AgriUAVNet 相对 LLFormer、RFDN 和 Retinexformer 分别约快 2.8、6.3 和 13.4 倍。该结果直接验证了模型在 iPad Air（第 3 代；Apple Inc., Cupertino, CA, USA）、$224 times 224$ 输入和 ONNX Runtime Web WebGPU 后端上的软件端推理效率，为进一步集成到农业 UAV 边缘视觉管线提供了设备侧依据。

=== 架构设计依据

#figure(
  image("fig5_ablation_design.png", width: 100%),
  caption: [
    组件与配置消融的 PSNR 差异。横向条形图给出各变体相对 $L^3$-AgriUAVNet 的 PSNR 变化，颜色区分组件移除、卷积类型、网络深度和通道宽度。$L^3$-AgriUAVNet 使用标准卷积，$L^3$-AgriUAVNet-DW 为其他配置相同的 DWConv 基线。
  ],
) <fig:l3_ablation>

本章将单流 HVI、两个 RFDN-S 和一次全局仿射调制组合作为最终配置。早期原型曾同时调整结构、损失与训练设置，难以区分各项改动的作用，因此这里以@fig:l3_ablation 和@tab:l3_ablation 中的单因素消融作为结构选择的主要依据。

=== 消融研究

#figure(
  three-line-table(table(
    columns: 10,
    table.header([变体], [HVI], [GMod], [ESA], [Conv], [d/w], [PSNR↑], [SSIM↑], [MAE↓], [LPIPS↓]),
    [$L^3$-AgriUAVNet], [$checkmark$], [$checkmark$], [$checkmark$], [std], [2/48], [*26.24*], [*0.893*], [*0.0452*], [*0.119*],
    [w/ DWConv], [$checkmark$], [$checkmark$], [$checkmark$], [DW], [2/48], [25.71], [0.886], [0.0475], [0.129],
    [depth=3], [$checkmark$], [$checkmark$], [$checkmark$], [std], [3/48], [25.66], [0.888], [0.0475], [0.128],
    [w/o ESA], [$checkmark$], [$checkmark$], [--], [std], [2/48], [25.59], [0.887], [0.0475], [0.135],
    [width=32], [$checkmark$], [$checkmark$], [$checkmark$], [std], [2/32], [25.54], [0.881], [0.0477], [0.142],
    [depth=1], [$checkmark$], [$checkmark$], [$checkmark$], [std], [1/48], [24.48], [0.851], [0.0524], [0.175],
    [depth=4], [$checkmark$], [$checkmark$], [$checkmark$], [std], [4/48], [24.43], [0.852], [0.0529], [0.168],
    [width=64], [$checkmark$], [$checkmark$], [$checkmark$], [std], [2/64], [24.66], [0.861], [0.0524], [0.160],
    [w/o HVI], [--], [$checkmark$], [$checkmark$], [std], [2/48], [24.52], [0.852], [0.0528], [0.171],
    [w/o GMod], [$checkmark$], [--], [$checkmark$], [std], [2/48], [23.63], [0.849], [0.0599], [0.184],
  )),
  caption: [
    $L^3$-AgriUAVNet 的消融结果。通过一次移除或替换一个组件来评估各架构贡献。“std”表示标准卷积，“DW”表示深度可分离卷积。$checkmark$ 表示启用，“--”表示禁用。
  ],
  kind: table,
) <tab:l3_ablation>

@tab:l3_ablation 显示，全局仿射调制对当前结构贡献最大：移除 GMod 后，PSNR 下降约 2.62 dB。移除 HVI 表征和 ESA 分别带来约 1.73 和 0.65 dB 的下降，说明全局曝光调节、强度–色彩组织与局部空间响应在浅层主干中发挥互补作用。将标准卷积替换为深度可分离卷积后，PSNR 下降 0.54 dB，表明通道间充分混合对于该低深度网络仍然重要。

网络深度与宽度的实验中，depth=1、depth=4 和 width=64 的 PSNR 分别为 24.48、24.43 和 24.66 dB，均低于默认的 depth=2/width=48；depth=3 和 width=32 也未改善结果。在本次数据与训练设置下，继续增加层数或通道数没有带来更高恢复质量。

配对统计也反映了这些差异。$L^3$-AgriUAVNet 相对 DW 变体的逐图像块 PSNR 平均提高 0.5366 dB（95% bootstrap CI $[0.5102, 0.5628]$，Holm 校正 $p < 0.001$）；相对移除 ESA、HVI 和 GMod 的变体，分别提高 0.6518、1.7276 和 2.6199 dB。上述比较均基于相同测试索引，反映各配置在固定域内样本上的差异。

=== 真实低光图像测试

#figure(
  image("fig6_real_low_light.png", width: 100%),
  caption: [
    真实低光玉米苗 UAV 图像块上的定性比较。依次展示 Raw、RFDN、Retinexformer、LLFormer 和 $L^3$-AgriUAVNet。该数据与用于退化参数标定的 26 张棉花低光图像相互独立，并采用视觉观察与@tab:l3_real_no_ref 的无参考统计进行联合评价。
  ],
) <fig:l3_real>

#figure(
  three-line-table(table(
    columns: 8,
    table.header([方法], [NIQE↓], [BRISQUE↓], [欠曝像素↓], [RGB 均衡偏差↓], [Tenengrad], [边缘密度], [局部对比度]),
    [Raw], [8.15], [52.21], [23.74%], [0.0346], [33.16], [0.0792], [6.48],
    [LLFormer], [8.50], [47.96], [0.00%], [*0.0167*], [102.73], [0.3036], [19.82],
    [$L^3$-AgriUAVNet], [8.43], [48.58], [0.00%], [0.0233], [102.87], [0.2990], [19.89],
    [Retinexformer], [8.77], [*47.29*], [0.00%], [0.0222], [102.93], [0.3033], [19.95],
    [RFDN], [9.05], [52.74], [0.00%], [0.0611], [75.22], [0.2147], [15.60],
  )),
  caption: [
    真实低光玉米苗数据的无参考评价。Raw 与各增强输出按文件名一一对齐（$n = 308$ 个图像块），各数值为逐图计算后的算术均值；该评价数据独立于用于退化参数标定的 26 张棉花低光图像。NIQE、BRISQUE、欠曝像素比例和 RGB 通道均衡偏差设有明确优化方向，Tenengrad、边缘密度和局部对比度作为描述性结构响应，不进行单调优劣排序。表中的 $L^3$-AgriUAVNet 指标准卷积配置。
  ],
  kind: table,
) <tab:l3_real_no_ref>

在 308 个真实低光玉米苗图像块上，定性结果与无参考统计从互补维度刻画了增强效果（@fig:l3_real 和@tab:l3_real_no_ref）。$L^3$-AgriUAVNet 将平均欠曝像素比例从 23.74% 降至近 0，RGB 通道均衡偏差由 0.0346 降至 0.0233（降低约 32.5%），BRISQUE 也从 52.21 降至 48.58。阈值化的欠曝像素比例在所有增强输出上均接近 0，因此该指标用于验证欠曝的消除，而非对增强方法排序。RFDN 的 RGB 通道均衡偏差反而升至 0.0611，说明可见度改善并不必然伴随全局通道关系的校正。

Tenengrad 从 33.16 提高至 102.87，边缘密度和局部对比度也增大，说明增强后的梯度与纹理响应更强。由于锐化和噪声也可能提高这些值，结构保留情况仍需结合图像观察。$L^3$-AgriUAVNet 的 NIQE 为 8.43，略高于 Raw 的 8.15；LLFormer 和 Retinexformer 在部分指标上更优。NIQE 与 BRISQUE 的排序不同，宜结合@fig:l3_real 的视觉结果判断。

=== 下游应用导向评价

#figure(
  image("fig7_detection_examples.png", width: 100%),
  caption: [
    YOLOv8n 的应用示例与汇总 mAP。逐图示例展示增强对轻量检测器的不同影响，定量结果由@tab:l3_yolov8n 的聚合指标给出。
  ],
) <fig:l3_res_task>

下游检测作为同一玉米苗低光数据集上的第二种评价路径，用于考察增强表征的农业应用价值。@fig:l3_res_task 展示了有代表性的 YOLOv8n 检测示例及汇总比较。按照实验设置中的统一协议，YOLOv8n@jocher2023yolov8 分别在 Raw、$L^3$-AgriUAVNet、RFDN、LLFormer 和 Retinexformer 输入分布上训练与测试。

#figure(
  three-line-table(table(
    columns: 5,
    table.header([输入], [mAP\@0.5], [mAP\@0.5:0.95], [Precision], [Recall]),
    [Raw low-light], [0.1393], [0.0364], [0.2984], [0.2257],
    [$L^3$-AgriUAVNet], [0.1596], [0.0443], [0.3139], [0.2065],
    [LLFormer], [0.0601], [0.0147], [0.1790], [0.1285],
    [Retinexformer], [0.1413], [0.0398], [0.2929], [0.2118],
    [RFDN], [0.1646], [0.0469], [0.3285], [0.2257],
  )),
  caption: [
    YOLOv8n 应用导向评价。检测器在 Raw 或各增强方法对应的输入分布上训练和评估，测试集包含 139 个图像块。表中报告 Precision、Recall 和 mAP，以比较不同增强输入对轻量检测器的影响。
  ],
  kind: table,
) <tab:l3_yolov8n>

*YOLOv8n：轻量检测器。*@tab:l3_yolov8n 显示，$L^3$-AgriUAVNet 将 mAP\@0.5 从 Raw 的 0.1393 提高至 0.1596，相对增幅为 14.6%；Precision 由 0.2984 提高至 0.3139，Recall 则由 0.2257 变为 0.2065，呈现精度–召回率权衡。RFDN 的 mAP\@0.5 为 0.1646，略高于 $L^3$-AgriUAVNet，但其参数量和 MACs 分别约为后者的 2.7 和 2.8 倍。$L^3$-AgriUAVNet 因而在较低增强开销下保持了接近 RFDN 的下游性能。LLFormer 虽具有最高的上游 PSNR，其 YOLOv8n mAP\@0.5 仅为 0.0601，说明重建指标与下游效用并不总是同步变化。

#figure(
  three-line-table(table(
    columns: 4,
    table.header([输入], [mAP\@0.5], [Precision], [Recall]),
    [Raw low-light], [0.3574], [0.5468], [0.3478],
    [$L^3$-AgriUAVNet], [0.3338], [0.4797], [0.3472],
    [RFDN], [0.3328], [0.5159], [0.3056],
    [LLFormer], [0.3370], [0.5333], [0.3403],
    [Retinexformer], [0.3382], [0.4869], [0.3333],
  )),
  caption: [
    YOLOv8s 应用导向评价。检测器使用相同的数据划分和训练安排，分别在 Raw 输入和各增强方法的输出分布上独立训练。测试集包含 139 个图像块，表中数值为单次运行的点估计。
  ],
  kind: table,
) <tab:l3_yolov8s>

*YOLOv8s：高容量检测器。*@tab:l3_yolov8s 显示，Raw 输入的 mAP\@0.5 为 0.3574，$L^3$-AgriUAVNet、RFDN、LLFormer 和 Retinexformer 分别为 0.3338、0.3328、0.3370 和 0.3382，呈现出与 YOLOv8n 不同的响应模式。检测器容量及其特征提取能力可能改变预增强的边际收益，这一关系将在重复训练和更多检测架构中继续验证。

两种检测器对增强输入的响应不同。$L^3$-AgriUAVNet 以小于 RFDN 的参数量和计算量获得接近的 YOLOv8n mAP，且高于 Raw 输入；YOLOv8s 则在 Raw 输入下表现最好。增强前端的选用因而需要结合下游模型验证，不能由图像恢复指标单独决定。

== 讨论

=== 农业约束如何塑造增强架构

农业 UAV 低光增强需要同时处理数据、图像结构和算力约束。夜昼影像难以严格对齐，训练依赖可控退化与真实统计校准；幼苗边界和作物行纹理易受平滑与偏色影响，模型需兼顾强度、颜色和局部结构；端侧资源又限制了网络深度与分支数量。本文据此采用校准退化数据、单流 HVI 和浅层蒸馏主干。

$L^3$-AgriUAVNet 在同一浅层路径中完成 HVI 表征、局部特征蒸馏和全局曝光调制，减少了双分支结构中的重复特征提取和交互开销。两个 RFDN-S 提取局部纹理，ESA 强化空间结构响应，GMod 根据全局描述子调节曝光与通道比例。各模块分别承担局部、空间和全局信息处理。

=== 质量–效率配置的形成

移除 GMod、HVI 和 ESA 均降低恢复指标，其中 GMod 的影响最大，支持在浅层主干中加入全局调节。标准卷积优于 DWConv，可能与更充分的跨通道混合有关。深度与宽度实验则显示，两个 48 通道块在当前训练设置下表现最好；这些结果为最终配置提供了依据，但尚不能分离所有潜在影响因素。

各方法的优势并不集中于同一指标：LLFormer 的 PSNR、MAE 和 LPIPS 更好，SCI 的参数量与 MACs 更低；$L^3$-AgriUAVNet 以 0.139 M 参数获得最高 SSIM，ONNX 文件为 0.79 MiB。iPad 上固定 ONNX Runtime Web/WebGPU 协议的测试进一步显示，该配置具有较低推理时延。因而，其应用价值需要结合结构恢复、存储、计算和设备速度共同判断。

=== 检测器容量相关的应用响应

下游结果显示，预增强的作用与检测器容量相关。在轻量 YOLOv8n 上，$L^3$-AgriUAVNet 将 mAP\@0.5 由 0.1393 提高至 0.1596，并提高 Precision，说明紧凑检测器能够利用增强后的可见度与结构响应；RFDN 获得略高的 mAP，但需要约 2.7 倍参数量和 2.8 倍 MACs，进一步体现了增强前端自身预算的重要性。另一方面，LLFormer 的上游 PSNR 最高，但其 YOLOv8n 表现较低，表明像素重建排名不能直接替代任务效用评价。

YOLOv8s 在 Raw 输入上的 mAP\@0.5 为 0.3574，各增强输入为 0.3328–0.3382。结合 YOLOv8n 的结果，检测器容量可能影响增强收益，但这一解释仍需重复训练和更多架构验证。$L^3$-AgriUAVNet（0.139 M 参数）与 YOLOv8n（约 3.2 M 参数@jocher2023yolov8）的组合，小于单独的 YOLOv8s（约 11.2 M 参数），可作为资源有限设备的候选配置。

=== 田间部署的操作启示

田间部署可先确定检测器和预处理预算，再在代表性验证样本上比较 Raw 与增强输入。对当前 YOLOv8n 任务，预算较紧时可考虑 $L^3$-AgriUAVNet；若 RFDN 略高的 mAP 能满足更重要的识别需求，也需同时承担约 2.7 倍参数量和 2.8 倍 MACs。对当前 YOLOv8s 任务，Raw 表现最好，应优先保留原始输入。其他检测器需要单独验证，并使用与部署条件一致的输入分布训练或适配。

清晨或傍晚影像是否需要增强，应由任务性能和运行成本决定。若增强改善识别且计算预算允许，可启用轻量前端；若检测器已能较好处理 Raw 输入，跳过增强可节省开销。后续田间研究还需检验这些配置对巡查覆盖、作业完成情况和管理决策的实际影响。

=== 扩展方向

当前退化参数由 26 张真实低光棉花影像的统计分布和视觉观感人工校准，评价范围主要是邻近日期航测所覆盖的生产环境。跨域研究还需补充更多品种、管理条件、传感器、天气和光源下的数据。RAW 或多光谱数据可进一步扩展现有 RGB 域退化模型。

任务评价可增加多随机种子重复训练，并扩展到 YOLOv11n、RT-DETR 和轻量分割模型，检验容量相关响应是否在其他架构中成立。增强器与检测器联合训练可探索直接面向任务的恢复目标。设备测试则需进一步覆盖 Jetson 或实际 UAV 计算单元上的端到端时延、峰值内存与能耗。

== 本章小结

本章使用第 5 章的校准退化数据训练单流 HVI 低光增强网络 $L^3$-AgriUAVNet。该模型含 0.139 M 参数，在合成配对测试集上取得 26.24 dB PSNR 和 0.893 SSIM；输入为 $1 times 3 times 224 times 224$ 时，计算量为 6.252 GMACs。与对比方法相比，其特点是以较小模型规模保持较高结构相似性。

消融与逐图像块配对分析表明，GMod、HVI 和 ESA 分别贡献约 2.62、1.73 和 0.65 dB 的 PSNR 增益，标准卷积在当前浅层配置中比 DWConv 基线高 0.54 dB。独立于 26 张棉花低光标定图像的 308 个真实低光玉米苗图像块进一步验证了模型的场景适应性：欠曝像素比例由 23.74% 降至近 0，RGB 通道均衡偏差由 0.0346 降至 0.0233。在具有检测真值的 139 个测试图像块上，增强输入使 YOLOv8n 的 mAP\@0.5 相对 Raw 提高 14.6%；但 YOLOv8s 的 Raw 输入达到 0.3574，高于各增强输入的 0.3328--0.3382。上述检测结果均为单次运行点估计，说明当前证据支持的是与检测器容量相关的任务响应，而非增强前端对所有模型的普遍增益。$L^3$-AgriUAVNet 可作为资源受限农业 UAV 视觉管线的候选低光前端，是否启用仍需依据下游模型和目标输入分布验证。
