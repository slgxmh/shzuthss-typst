#import "../template.typ": *

#show: doc => conf(
  cauthor: "夏明辉",
  eauthor: "Xia Minghui",
  studentid: "20232309205",
  blindid: "L2023XXXXX",
  cthesisname: "博士研究生学位论文",
  cheader: "石河子大学博士学位论文",
  ctitle: "基于无人机遥感的成熟期棉花脱叶率与吐絮率检测方法研究",
  etitle: "Research on Detection Methods for Defoliation and Boll Opening Rates of Mature Cotton Based on UAV Remote Sensing",
  school: "机械电气工程学院",
  cfirstmajor: "农业工程",
  cmajor: "农业工程",
  emajor: "Agricultural Engineering",
  direction: "农业电气自动化",
  csupervisor: "陈学庚",
  esupervisor: "Prof. Xuegeng Chen",
  date: (year: 2026, month: 6),
  degree-type: "academic",
  cabstract: include "cabstract.typ",
  ckeywords: ("棉花", "无人机遥感", "脱叶率", "吐絮率", "轻量级模型", "全天候识别"),
  eabstract: include "eabstract.typ",
  ekeywords: (
    "Cotton",
    "UAV Remote Sensing",
    "Defoliation Rate",
    "Boll Opening Rate",
    "Lightweight Model",
    "All-Weather Recognition",
  ),
  acknowledgements: include "acknowledgements.typ",
  outlinedepth: 3,
  blind: false,
  listofimage: true,
  listoftable: true,
  listofcode: true,
  alwaysstartodd: false,
  preview: false,
  cleandeclaration: true,
  bibcontent: read("ref.bib"),
  bibstyle: "numeric",
  bibversion: "2015",
  doc,
)

#include "chapters/绪论/index.typ"

#include "chapters/数据集/index.typ"

= 基于可见光图像与传统机器学习的棉花双指标识别

#include "chapters/光谱指数/index.typ"

= 基于深度学习的实时检测方法

#include "chapters/基于深度学习/index.typ"

== 小结

本研究提出了面向正常光照条件的轻量级实时识别模型 RTCMNet，并完成了与多种基线模型的系统比较。实验结果表明，在统一数据集与评测协议下，该模型能够在较低参数量和较快推理速度条件下实现较好的双指标识别性能，为后续端侧部署提供了方法基础。

从模型机制看，RTCMNet 通过共享骨干、多尺度卷积注意力和双任务分类头实现了对脱叶率与吐絮率的联合建模。对比实验、消融实验与特征可视化表明，模型性能提升主要来源于对冠层细粒度结构和多尺度上下文关系的有效表征，而非单纯依赖参数规模扩张。

本研究同时构成了后续全天候识别研究的正常光照基线。尽管 RTCMNet 在常规光照条件下已表现出较好的识别能力，但真实大田作业仍会受到弱光、逆光和局部阴影等因素影响。因而，下一阶段的低光增强与多光照鲁棒性研究，将在本研究结果基础上进一步讨论复杂成像条件下识别性能的保持与恢复问题。

#include "chapters/低光合成/index.typ"

#include "chapters/多光照/index.typ"

#include "chapters/大田验证/index.typ"

= 结论与展望

== 结论

本研究围绕成熟期棉花脱叶率与吐絮率的快速、准确与可部署检测需求，针对真实大田场景中背景复杂、光照多变、算力受限和应用验证不足等约束，构建了涵盖数据集建立、传统工程基线与结构化特征方案分析、端侧轻量深度学习、低光与多光照鲁棒性增强以及大田作业实验的完整研究链路。全文工作旨在将成熟期棉花双指标状态由经验判断对象转化为可计算、可验证并可服务田间作业的遥感表型信息。结合全文研究内容，可得到以下结论。

（1）数据集构建与评测协议是脱叶率与吐絮率识别研究开展的基础。第 2 章围绕真实生产场景建立了多时相、多光照和复杂背景条件下的棉花脱叶率与吐絮率数据集，并统一了采集、人工真值统计、位置信息解析、图像增强、边缘样本剔除和数据组织流程。上述工作为后续深度模型训练、传统基线比较、低光数据构建和大田作业实验提供了统一的数据基础，也保证了不同章节结果之间的可比性。

（2）基于 RGB 像素向量的传统机器学习实验能够为双指标识别提供工程基线，并暴露背景干扰与类别不均衡带来的局限。第 3 章以 RGB 像素向量为输入，比较 PCA+Logistic Regression 与 Random Forest 系列模型，并使用 Accuracy 和 Macro-F1 分析两项多等级任务。实验结果表明，在当前一次固定切分设置下，PCA+Logistic Regression 的测试集 Macro-F1 高于 Random Forest 系列，而 Accuracy 与 Macro-F1 的明显差异反映出长尾等级条件下的多数类偏置。在此基础上，本章进一步从光谱指数、前景分割、形态和纹理三个方面分析结构化特征方案，作为后续可解释建模与实验验证的改进方向，而不将其作为本章已完成定量实验的组成部分。

（3）面向端侧部署的双指标识别问题，需要采用与任务相匹配的轻量结构设计。第 4 章提出了 RTCMNet，通过共享骨干、多尺度卷积注意力和双分类头实现脱叶率与吐絮率的联合建模，并在统一数据与协议下与多种经典模型开展比较。实验结果表明，RTCMNet 在保持较低参数量和较快推理速度的同时，取得了较好的综合识别性能；消融实验和特征可视化进一步说明，其性能收益主要来自与双指标任务相适配的结构设计。该结果表明，农业端侧场景中的轻量化设计应综合考虑精度、速度和部署成本，而不能仅以压缩模型规模为目标。

（4）全天候识别需要围绕“退化建模—增强前端—下游识别”建立协同的数据与方法体系。第 5 章构建了面向农业 UAV 夜间场景的低光成对数据集，通过物理与 ISP 启发的退化模型生成可控监督样本，并利用真实夜间图像进行统计一致性校验；第 6 章进一步提出增强前端与识别模型协同工作的多光照鲁棒识别链路。实验结果表明，所提轻量增强前端 $L^3$-AgriUAVNet 参数量仅为 0.139 M，SSIM 达 0.893 并在全表比较中为最优，LPIPS 为 0.119，与最优方法（LLFormer 0.103）处于同一水平；在 iPad 级平板设备上单张推理耗时 202 ms，验证了其在边缘设备上的软件端推理效率。增强前端能够改善亮度分布、结构恢复与颜色稳定性；在真实日落棉田影像上，增强前后的双指标预测呈现出与任务类型和催熟阶段相关的分布调整，验证了增强—识别串联流程的可行性，但由于缺少同步人工真值，尚不能据此量化识别精度增益。下游案例研究进一步表明，增强前端对轻量检测器收益显著（YOLOv8n 幼苗检测 mAP\@0.5 相对提升 14.6%），而对强检测器的边际效用有限，说明增强前端的收益集中于端侧轻量链路。

（5）大田作业实验表明，识别结果能够在真实田间场景中形成具有空间连续性和农艺解释性的成熟状态分布。第 7 章将前述模型链路嵌入真实大田场景，通过多时相 UAV 采集、在线识别、地理映射与人工复核，对脱叶率和吐絮率的空间分布与时序演化进行了分析。结果表明，模型输出能够反映整体成熟推进趋势，并识别边界滞后区、灌溉异常区和局部结构异常区。研究同时说明，田间应用效果不仅依赖于网络本身，还依赖于“成像—识别—映射—复核”整条链路的协同稳定性。

综合上述五点可以看出，本研究围绕成熟期棉花催熟监测这一具体农业问题，建立了由数据、方法到田间验证的完整研究路径。该路径以 RGB 像素向量传统分类结果作为工程参照，并将结构化特征作为后续待验证的改进方案；同时，通过轻量深度模型和多光照鲁棒设计提高复杂场景下的识别能力，并在大田作业实验中完成应用层验证。

== 创新点

结合全文内容，本研究的主要创新点可概括为以下三个方面。

（1）构建了面向成熟期棉花脱叶率与吐絮率双指标的统一研究框架。在同一数据组织、评测协议和模型链路下开展联合研究，使成熟状态能够作为统一表型问题进入识别与田间验证流程，为后续综合成熟状态判定研究提供了基础。

（2）提出了面向端侧部署与复杂光照场景的分层协同方法体系。本研究在正常光照条件下构建了轻量级双指标联合识别模型 RTCMNet，并进一步结合低光成对数据生成和轻量增强前端 $L^3$-AgriUAVNet（参数量仅 0.139 M，SSIM 0.893 为全表最优，在 iPad 级平板设备上单张推理 202 ms）的设计，形成“可控退化数据—轻量增强模块—端侧识别模型”协同工作的全天候识别链路。

（3）实现了从算法研究到大田作业实验的应用验证。本研究将识别输出进一步映射到真实田间空间场景中，通过多时相大田实验验证其空间连续性、时序合理性和人工复核一致性，说明所建方法具备进入真实农业场景应用的潜力。

== 局限性与不足

尽管本研究围绕成熟期棉花双指标识别与大田验证取得了阶段性成果，但仍存在以下不足。

（1）数据覆盖范围仍有限。本研究数据主要来自特定区域、特定年份与特定品种条件下的生产场景，虽然已尽量覆盖多时相和多光照条件，但跨区域、跨品种和跨年份的泛化边界仍需通过更大规模数据进一步验证。

（2）标签体系仍以人工统计与分级规则为基础。脱叶率与吐絮率属于连续变化的管理状态指标，当前采用的分级标签虽然便于建模与评测，但在边界样本和空间梯度显著区域中，仍可能存在人为离散化带来的信息损失。这意味着模型输出距离更细粒度的连续成熟状态估计仍有一定距离。

（3）低光数据构建与增强链路仍属于近似建模。本研究低光退化主要在 RGB 域完成，尚未显式建模 RAW 采集、去马赛克和完整 ISP 链路；增强前端虽然在真实夜间和复杂光照场景中表现出收益，但在极端逆光、强反光和严重运动模糊条件下仍可能存在失效风险。

（4）大田作业实验已证明模型具备田间应用潜力，但尚未与更大范围长期生产数据形成系统对照。目前的验证重点仍是空间分布、时序演化和人工复核一致性，距离形成跨年度、跨区域、长周期的作业支持系统仍有进一步拓展空间。

== 展望

围绕上述不足与后续发展方向，未来研究可从以下几个方面继续推进。

（1）构建更大范围的长期多源数据体系。未来应进一步扩展跨区域、跨品种、跨年份与跨设备的数据采集，并在统一协议下建立长期版本化管理机制，使模型训练、更新与外推评测建立在更稳健的数据基础之上。

（2）从离散分级识别走向连续成熟状态估计。后续可探索将有序分类、连续值回归与不确定性估计结合起来，使脱叶率与吐絮率不再仅以等级标签表示，而能够更细粒度地反映成熟进程与边界样本的不确定性。

（3）强化全天候链路对极端场景的适应性。针对严重弱光、逆光、风致模糊、局部遮挡等极端条件，可进一步引入更贴近真实成像机理的数据构建方法、多模态传感信息以及面向域外样本的鲁棒训练策略，以提升全天候识别链路的稳定边界。

（4）推进田间验证由“结果一致性”走向“长期应用能力”评价。后续工作应在更大范围大田场景中开展连续观测与人工复核，逐步建立识别结果、时序演化、田间调查和长期作业记录之间的对应关系，使模型评价从单次实验效果提升到长期作业支撑能力的系统评价。

// ========== 附录 ==========
#appendix()

= 主要符号与缩略语

#booktab(
  columns: (1.5fr, 2.7fr, 2.3fr),
  outlined: false,
  align: (left, left, left),
  [符号或缩写],
  [英文全称],
  [中文],
  [$"DR"_t$],
  [Defoliation Rate on Day $t$],
  [第 $t$ 天脱叶率],
  [$"BR"_t$],
  [Boll Opening Rate on Day $t$],
  [第 $t$ 天吐絮率],
  [$L_0$],
  [Initial Leaf Count],
  [施药初始叶片数],
  [$L_t$],
  [Leaf Count on Day $t$],
  [第 $t$ 天叶片数],
  [$B_0$],
  [Initial Total Boll Count],
  [施药初始棉铃总数],
  [$B_t$],
  [Open Boll Count on Day $t$],
  [第 $t$ 天开裂棉铃数],
  [UAV],
  [Unmanned Aerial Vehicle],
  [无人机],
  [RGB],
  [Red, Green, Blue],
  [红绿蓝三通道图像],
  [RGB-D],
  [Red, Green, Blue and Depth],
  [彩色-深度多模态数据],
  [CNN],
  [Convolutional Neural Network],
  [卷积神经网络],
  [RTCMNet],
  [Real-Time Cotton Monitoring Network],
  [棉花脱叶率与吐絮率实时监测网络],
  [MSCA],
  [Multi-Scale Convolutional Attention],
  [多尺度卷积注意力],
  [ESA],
  [Enhanced Spatial Attention],
  [增强空间注意力],
  [GMod],
  [Global Modulation],
  [全局调制模块],
  [GSD],
  [Ground Sampling Distance],
  [地面分辨率],
  [RTK],
  [Real-Time Kinematic],
  [实时动态定位],
  [PPK],
  [Post-Processed Kinematic],
  [后处理动态定位],
  [GCP],
  [Ground Control Point],
  [地面控制点],
  [ROI],
  [Region of Interest],
  [感兴趣区域],
  [PCA],
  [Principal Component Analysis],
  [主成分分析],
  [LR],
  [Logistic Regression],
  [逻辑回归],
  [SVM],
  [Support Vector Machine],
  [支持向量机],
  [RF],
  [Random Forest],
  [随机森林],
  [SPAD],
  [Soil and Plant Analyzer Development],
  [叶绿素相对含量指标],
  [ExG],
  [Excess Green Index],
  [超绿指数],
  [VARI],
  [Visible Atmospherically Resistant Index],
  [可见光抗大气植被指数],
  [NGRDI],
  [Normalized Green-Red Difference Index],
  [归一化绿红差异指数],
  [ISP],
  [Image Signal Processing],
  [图像信号处理],
  [RAW],
  [Raw Sensor Data],
  [原始传感器数据],
  [LiDAR],
  [Light Detection and Ranging],
  [激光雷达],
  [PSNR],
  [Peak Signal-to-Noise Ratio],
  [峰值信噪比],
  [SSIM],
  [Structural Similarity Index Measure],
  [结构相似性指标],
  [LPIPS],
  [Learned Perceptual Image Patch Similarity],
  [学习感知图像块相似度],
  [MAE],
  [Mean Absolute Error],
  [平均绝对误差],
  [Macro-F1],
  [Macro-Averaged F1 Score],
  [宏平均 F1 值],
  [mAP],
  [mean Average Precision],
  [平均精度均值],
  [IoU],
  [Intersection over Union],
  [交并比],
)

== 研究过程补充说明

本研究的实验数据、模型代码与大田作业实验流程均按照“可复现实验”原则管理。后续可在完成数据脱敏和项目验收后，逐步公开可共享部分，促进相关研究复现与应用推广。
