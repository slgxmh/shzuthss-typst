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
  school: "机械电器工程学院",
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
  cleandeclaration: true,
  bibcontent: read("ref.bib"),
  bibstyle: "numeric",
  bibversion: "2015",
  doc,
)

#include "chapters/绪论/index.typ"

#include "chapters/数据集/index.typ"

= 基于光谱指数的脱叶率吐絮率识别研究

#include "chapters/光谱指数/index.typ"

= 基于深度学习的实时检测方法

#include "chapters/基于深度学习/index.typ"

== 本章小结

本章构建了面向光照充足条件的轻量级实时识别模型。相较传统回归方案，深度模型在复杂背景下具有更强特征表达能力；相较直接使用基准网络，改进方案在精度与速度之间取得更优平衡，为全天候识别奠定了模型基础。

#include "chapters/低光合成/index.typ"

#include "chapters/多光照/index.typ"

#include "chapters/大田验证/index.typ"

// ========== 附录 ==========
#appendix()

= 附录

== 主要符号说明

#booktab(
  columns: (1.5fr, 2.7fr, 2.3fr),
  outlined: false,
  align: (left, left, left),
  [缩写],
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
  [$L_"total"$],
  [Total Training Loss of Generative Model],
  [生成模型训练总损失],
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
  [Real-Time Cotton Maturity Network],
  [棉花成熟度实时识别网络],
  [MSCA],
  [Multi-Scale Convolutional Attention],
  [多尺度卷积注意力],
  [SCSA],
  [Strided Context Spatial Attention],
  [步长上下文空间注意力],
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

本文实验数据、模型代码与大田作业实验流程均按照“可复现实验”原则管理。后续可在完成数据脱敏和项目验收后，逐步公开可共享部分，促进相关研究复现与应用推广。
