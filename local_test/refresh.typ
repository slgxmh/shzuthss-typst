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
  cabstract: "",
  ckeywords: ("棉花", "无人机遥感", "脱叶率", "吐絮率", "轻量级模型", "全天候识别"),
  eabstract: "",
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


#include "绪论.typ"
#include "数据与表型.typ"
