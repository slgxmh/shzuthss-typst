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

1. $"DR"_t$：第 $t$ 天脱叶率。
2. $"BR"_t$：第 $t$ 天吐絮率。
3. $L_0, L_t$：施药初始叶片数与第 $t$ 天叶片数。
4. $B_0, B_t$：施药初始棉铃总数与第 $t$ 天开裂棉铃数。
5. $L_"total"$：生成模型训练总损失。

== 研究过程补充说明

本文实验数据、模型代码与处方图生成流程均按照“可复现实验”原则管理。后续可在完成数据脱敏和项目验收后，逐步公开可共享部分，促进相关研究复现与应用推广。
