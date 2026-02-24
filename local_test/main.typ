#import "../template.typ": *

#show: doc => conf(
  cauthor: "夏明辉",
  eauthor: "Xia Minghui",
  studentid: "20232309205",
  blindid: "L2023XXXXX",
  cthesisname: "博士研究生学位论文",
  cheader: "石河子大学博士学位论文",
  // 可以用 \n 控制中英文标题在非盲审封面 (blind=false) 中的换行点
  // 在盲审封面 (blind=true) 中，手工插入的 \n 会被忽略，以确保标题连续
  ctitle: "基于无人机遥感的成熟期棉花脱叶率与吐絮率检测方法研究",
  etitle: "User Guide for PKU Dissertation\nTypst Template (modern-pku-thesis)",
  school: "机械电器工程学院",
  cfirstmajor: "农业工程",
  cmajor: "农业工程",
  emajor: "Computer Software and Theory",
  direction: "农业电气自动化",
  csupervisor: "陈学庚 研究员",
  esupervisor: "Prof. Si Li",
  date: (year: 2026, month: 6),
  degree-type: "academic",
  cabstract: "这是摘要",
  ckeywords: ("Typst", "学位论文", "排版模板", "石河子大学"),
  eabstract: include "eabstract.typ",
  ekeywords: (
    "Typst",
    "Dissertation",
    "Template",
    "Peking University",
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

= 绪论

== 课题研究意义

== 国内外研究现状

== 研究目标与研究内容

= 基于光谱指数的脱叶率吐絮率识别研究

== 数据集采集

== 数据集处理

== 前后背景分割

== 棉花特征提取

== 使用回归法进行脱叶率吐絮率识别

= 基于深度学习的实时检测方法

== 引言

== 数据处理方法

== 基于Efficient Net的基准实验

== 改进的轻量级实时识别方法

== 本章小结

= 不同光照条件数据样本均衡化研究

== 引言

== 扩散模型相关理论

== 扩散模型模型构建

== 低光数据生成模型训练

== 数据扩充后的图像质量评价

== 本章小结

= 全天候实时脱叶率吐絮率识别方法

== 引言

== 基于样本均衡化的不同光照数据集构建

== 适应不同光照条件的实时识别模型构建

== 低光条件下的脱叶率吐絮率实时识别模型训练

== 实验结果评估

== 本章小结

= 无人机植保处方图模拟实验

== 引言

== 实验条件

== 实验设备

== 实验方法

== 结果分析

== 本章小结

= 结论与展望

== 结论

== 创新点

== 展望

// ========== 附录 ==========
#appendix()

= 附录

在此处添加附录内容...
