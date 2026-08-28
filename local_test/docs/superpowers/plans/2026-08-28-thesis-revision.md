# 大论文全面修订实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将学位论文初稿全面修订为与小论文期刊版一致、术语符合开题评议意见、摘要与结论完整、数值无矛盾的版本。

**Architecture:** 四批推进（批次 1：第 6 章重写对齐期刊版；批次 2：全文术语替换；批次 3：绪论/摘要/结论联动；批次 4：一致性修复）。每批结束编译验证 + 用户确认 + git 提交。

**Tech Stack:** Typst 0.14.2，模板在上级目录（`../template.typ`），编译命令 `typst compile --root .. main.typ /tmp/main_check.pdf`（缺字体警告可忽略，error 必须为零）。

## Global Constraints

- 论文语言为中文；术语遵守开题评议三意见：① 不用"端测"等不严谨表述；② 禁用"成熟度"代替"脱叶率与吐絮率"（"成熟期棉花""成熟状态/成熟进程"等描述性用法允许）；③ 研究内容与研究方法分开叙述。
- RTCMNet 英文全称统一为 **Real-Time Cotton Monitoring Network**（缩写不变），中文名"棉花脱叶率与吐絮率实时监测网络"；全文统一写 RTCMNet（不写 RTCM）。
- 第 6 章全部方法描述与实验数值以期刊版 `assets/main_zh.pdf` 为准（本计划已内嵌全部所需数值）。
- 第 5 章（`chapters/低光合成/index.typ`，退化建模与数据构建）原则上不动内容，仅批次 2 做术语检查。
- 表格用 `#figure(three-line-table(table(...)), caption: [...], kind: table) <label>`；图片用 `#figure(image(...), caption: [...]) <label>`；章节引用用 `@label`。
- 图片替换等用户提供原图后进行；本计划中第 6 章沿用现有图片路径，caption 末尾加"[图待更新为期刊版]"标注。
- 编译验证只允许 warning（字体缺失），不允许 error。
- 每批的 git commit 前必须暂停等用户确认（用户明确要求 git 操作需逐次确认）。

## 参考资料速查（实施者零上下文必读）

- 当前论文入口：`main.typ`；章节在 `chapters/<章名>/index.typ`。
- 小论文 A 期刊版数值来源：`assets/main_zh.pdf`（PDF 中文字体无 ToUnicode，直接提取文本困难，所需数值已全部内嵌在本计划中）。
- 小论文 A 旧版源码：`assets/ch.tex`（仅用于参考两版共有的退化模型、数据集、损失函数表述）。
- 开题报告文本：`assets/kaiti-extracted-clean.txt`。
- 文献库：`ref.bib`（167 条），新增引用前先 grep 确认 key 不存在。

---

## 批次 1：第 6 章重写（对齐期刊版）

### Task 1: 第 6 章方法部分重写

**Files:**
- Modify: `chapters/多光照/index.typ`（第 1–75 行：标题、引言、"自适应低光图像增强模型构建"整节）

**Interfaces:**
- Consumes: 第 5 章 label（在 `chapters/低光合成/index.typ` 中 grep `^= ` 和 `<...>` 确认实际 label 名，用于交叉引用退化建模与数据集）。
- Produces: 重写后的第 6 章前半；保留 `<fig:backbone>` label（正文有 `@fig:backbone` 引用）。

- [ ] **Step 1: 确认第 5 章 label 与现有引用**

```bash
grep -n '<[a-z:_-]*>' chapters/低光合成/index.typ | head -20
grep -n '@' chapters/多光照/index.typ
```

记录第 5 章可引用的 label（如章 label、退化模型图 label），供 Step 2 使用。

- [ ] **Step 2: 重写"引言"节（第 4–10 行）**

保留现有引言的整体逻辑（承接第 5 章 → 增强前端纳入全天候链路 → 指出数据见第 5 章/@chap:dataset），仅需微调：明确本章增强模型为期刊版结构，删除任何暗示旧版 L-RFDB/SCSA 的表述。篇幅保持 3 段左右。

- [ ] **Step 3: 重写"自适应低光图像增强模型构建"节（第 12–75 行）**

按以下期刊版结构重写（图片保留 `image("../低光合成/network.png", width: 100%)` 与 `<fig:backbone>` label，caption 改写为期刊版结构描述并在末尾加"[图待更新为期刊版]"）：

1. **总体架构段**：网络输入先经 **HVI 色彩空间变换**（Horizontal/Vertical-Intensity，引自 CIDNet@yan2025cidnet）：RGB 映射到 HV 极坐标表示（色相 $h = "atan2"(\u2026)/(2pi)$，强度 $v$），采用可微的 HSV–RGB 往返映射，使增强在低色偏敏感的空间中进行；增强结果经逆变换回到 RGB。
2. **主干 RFDN-S 段**：RFDN 小型化主干，深度 $N = 2$ 个 RFDB（残差特征蒸馏块），宽度 $C = 48$，蒸馏率 0.25（每块蒸馏出 $d = 12$ 通道，剩余 $R = 36$ 通道继续提炼），块末端接 **ESA**（Enhanced Spatial Attention）。另设 DWConv 变体 L³-AgriUAVNet-DW（0.07M 参数）供极端受限平台选用。
3. **GMod 全局调制段**：GAP 将浅层特征压缩为通道描述向量，经 MLP（48→64→96）预测仿射参数增量 $Delta g, b$，输出 $F = F_("deep") dot.circle (1 + Delta g) + b$；恒等初始化（$g approx 1, b approx 0$）稳定训练初期。保留现有的 GMod 动机论述（全局曝光漂移与白平衡波动）。
4. **特征融合与重建段**：HVI 变换分支融合浅层特征 $F_0$ 与深层特征后重建，最后逆 HVI 变换输出 RGB。
5. **小节划分**：将原 `=== L-RFDB`、`=== 轻量空间注意力` 两小节改为 `=== HVI 色彩空间变换`、`=== RFDN-S 主干与 ESA`、`=== 全局调制模块` 三小节。
6. **"损失函数设计"小节（第 49–75 行）**：公式与三项损失（Charbonnier、Sobel 梯度 L1、RGB 通道比例 L1）两版一致，**保留**；在 LLLoss 公式后补充权重句："本研究取 $w_("char") = 1.0$、$w_("grad") = 0.2$、$w_("color") = 0.05$，Charbonnier 中 $epsilon = 10^(-6)$。"

- [ ] **Step 4: 检查 ref.bib 并补 CIDNet 引用**

```bash
grep -in 'cidnet\|yan.*2025\|hvi' ref.bib
```

若不存在，用 WebSearch 查 CIDNet（Yan et al., 2025, "HVI: A New Color Space for Low-light Image Enhancement", CVPR 2025）的准确书目信息，按 ref.bib 现有条目的格式添加 `@yan2025cidnet`（key 风格与现有条目一致，如 `zamir2022restormer`）。

- [ ] **Step 5: 编译验证**

```bash
typst compile --root .. main.typ /tmp/main_check.pdf 2>&1 | grep -c '^error'
```

Expected: `0`（warning 可忽略）。

### Task 2: 第 6 章实验部分重写

**Files:**
- Modify: `chapters/多光照/index.typ`（"增强模块实验验证"整节，约第 77–196 行）

**Interfaces:**
- Consumes: Task 1 的方法节；ref.bib 中需新增基线文献 key（Step 1）。
- Produces: `<tab:overall>`、`<tab:ablation>`、`<tab:downstream>` 等表 label（下游章节/结论引用时核对）。

- [ ] **Step 1: 补齐基线文献到 ref.bib**

需要的 key（先 grep 确认不存在，再用 WebSearch 核实书目后按现有格式添加）：

| key | 文献 |
|---|---|
| `wang2023llformer` | LLFormer, Wang et al., AAAI 2023 |
| `zamir2022restormer` | Restormer, Zamir et al., CVPR 2022 |
| `cai2023retinexformer` | Retinexformer, Cai et al., ICCV 2023 |
| `wang2022uformer` | Uformer, Wang et al., CVPR 2022 |
| `ma2022sci` | SCI (Self-Calibrated Illumination), Ma et al., CVPR 2022 |
| `jocher2023yolov8` | YOLOv8, Jocher et al., Ultralytics, 2023 |

（`liu2020residual`=RFDN、`yan2025cidnet` 已在此前确认。）

- [ ] **Step 2: 改写实验设置段（约第 79 行）**

改为期刊版口径：训练在 NVIDIA RTX 4090（24 GB）完成，推理与部署测试在 RTX 5090（AutoDL 平台）；Adam 优化器初始学习率 $10^(-4)$；batch size 按模型显存占用设定（Restormer 为 4，LLFormer/Retinexformer/Uformer/L³-AgriUAVNet 为 16，HVI-CIDNet 为 32，RFDN/SCI 为 64）；HVI-CIDNet 与 RFDN 训练 100 epoch，其余 200 epoch，验证集早停；随机种子 42；训练 patch $224 times 224$；测试集 3265 个 patch；真实夜间外部验证 308 个 patch（源自 26 张真实夜间图像）。数据构建细节引用第 5 章，不重复描述。

- [ ] **Step 3: 替换"综合性能分析"表（`<tab:overall>`）**

新表 8 行（`columns: 7`，表头：[方法], [参数量(M)], [MACs(G)], [PSNR(dB)↑], [SSIM↑], [MAE↓], [LPIPS↓]）：

```
[LLFormer], [5.807], [15.507], [26.54], [0.888], [0.0441], [0.103],
[Restormer], [25.872], [71.820], [26.16], [0.866], [0.0452], [0.105],
[Retinexformer], [2.028], [15.747], [26.10], [0.891], [0.0450], [0.125],
[Uformer], [6.192], [18.475], [24.66], [0.817], [0.0522], [0.222],
[HVI-CIDNet], [1.976], [6.227], [24.30], [0.795], [0.0533], [0.252],
[RFDN], [0.371], [17.593], [22.53], [0.800], [0.0649], [0.360],
[SCI], [0.022], [1.493], [21.86], [0.773], [0.0731], [0.289],
[$L^3$-AgriUAVNet], [0.139], [6.252], [26.24], [0.893], [0.0452], [0.119],
```

分析文字要点（重写，保留原有"指标含义""工程部署"两段论述框架但更新数字与基线）：

- L³-AgriUAVNet 的 SSIM 0.893 为全表最优；PSNR 26.24 dB 比 Restormer 高 0.09 dB（paired bootstrap 95% CI [0.047, 0.130]，Holm 校正 $p = 0.0105$），比 LLFormer 低 0.30 dB，处于重型 Transformer 同档水平。
- 参数量 0.139M，为 LLFormer 的 1/42、Retinexformer 的 1/15、RFDN 的 1/2.7；MACs 6.252 G，约为 LLFormer/Retinexformer/RFDN 的 40%/40%/36%。
- 对比基线改为重型 Transformer 与轻量方法混合的 8 方法比较，说明比较从"轻量方法之间"升级为"跨复杂度全谱系"。

- [ ] **Step 4: 改写"运行消耗"小节**

保留气泡图（`inference_time.png`，caption 末尾加"[图待更新为期刊版]"）与整链路预算论述，新增部署数据段：

- ONNX 导出体积 0.79 MiB（LLFormer 22.62、Retinexformer 8.30、RFDN 1.45 MiB）。
- iPad Air 实测（ONNXRuntime Web 1.23.2 + WebGPU，$224 times 224$ 输入）：L³-AgriUAVNet 202 ms / 4.95 FPS，比 LLFormer（569 ms / 1.76 FPS）、RFDN（1281 ms / 0.78 FPS）、Retinexformer（2712 ms / 0.37 FPS）分别快 2.8×、6.3×、13.4×。

- [ ] **Step 5: 替换"消融实验"表（`<tab:ablation>`）与分析**

新表（`columns: 3`：[变体], [PSNR(dB)↑], [ΔPSNR(dB)]；完整模型 26.24 为基准 0）：

```
[$L^3$-AgriUAVNet（完整）], [26.24], [0],
[w/o GMod], [23.63], [-2.62],
[w/o HVI], [24.52], [-1.73],
[w/o ESA], [25.59], [-0.65],
[w/ DWConv 变体], [25.70], [-0.54],
[depth = 1], [24.48], [-1.76],
[depth = 3], [25.70], [-0.54],
[depth = 4], [24.43], [-1.81],
[width = 32], [25.54], [-0.70],
[width = 64], [24.66], [-1.58],
```

分析文字要点：GMod 贡献最大（−2.62 dB），对应全局曝光/白平衡漂移建模；HVI 次之（−1.73 dB），验证色彩空间变换对低色偏增强的作用；ESA 贡献 −0.65 dB；深度与宽度扫描表明 depth=2 / width=48 为精度-复杂度最优点。保留原有 GMod 机理分析段（与新版结论一致），删除 SCSA 相关段落。

- [ ] **Step 6: 改写"真实数据测试"小节**

保留两张现有图（`res_dis.png`、`res_detail.png`，caption 末尾加"[图待更新为期刊版]"）及统计分布分析框架，更新/新增定量内容：真实夜间 308 patch 无参考指标——暗像素比例 23.74% → 0（所有增强方法均降至 0）；RGB 通道残差 Raw 0.0346 → L³-AgriUAVNet 0.0233（RFDN 0.0611 最差）；Tenengrad 33.16 → 102.87；边缘密度 0.0792 → 0.2990；局部对比度 6.48 → 19.89；NIQE Raw 8.15 / 本方法 8.43；BRISQUE 52.21 → 48.58。对比方法从 Zero-DCE++/IMDN 改为期刊版基线口径。

- [ ] **Step 7: 重写"下游任务增强实验"小节**

下游任务由 SimpleNet 作物分类改为 **YOLOv8n 幼苗检测**（@jocher2023yolov8）：

- 实验设置：LabelMe 标注，$512 times 512$ 输入，训练 75 epoch，139 个测试 patch。
- 新表 `<tab:downstream>`（`columns: 4`：[输入], [mAP\@0.5], [Precision], [Recall]；以 Raw 与两个代表性方法对比）：

```
[Raw low-light], [0.1393], [0.2984], [0.2257],
[LLFormer 增强], [0.0601], [--], [--],
[RFDN 增强], [0.1646], [--], [--],
[$L^3$-AgriUAVNet 增强], [0.1596], [0.3139], [0.2065],
```

（LLFormer/RFDN 行的 Precision/Recall 期刊版未报告，表中写"--"并在文内说明。）

- 分析要点：增强后 mAP\@0.5 提升 14.6%（0.1393 → 0.1596）；RFDN 绝对值略高（0.1646）但参数量与 MACs 为本方法的 2.7×/2.8×；LLFormer 增强反而降至 0.0601，说明增强质量与下游收益并非单调相关。
- 保留期刊版讨论：在更强的 YOLOv8s 上增强无收益（Raw 0.3574 vs 增强后 0.3328–0.3382），说明增强前端对强检测器边际效用有限，收益集中于轻量端侧模型——这与本研究"端侧部署"定位一致。
- 图 `res_task.png` 保留，caption 改为幼苗检测下游验证描述并加"[图待更新为期刊版]"。

- [ ] **Step 8: 编译验证 + 数值核对**

```bash
typst compile --root .. main.typ /tmp/main_check.pdf 2>&1 | grep -c '^error'
grep -n 'SCSA\|L-RFDB\|Zero-DCE\|IMDN\|SimpleNet\|24.71\|138k\|11.94' chapters/多光照/index.typ
```

Expected: error 数为 0；grep 无输出（旧版方法与数值全部清除）。若引用第 4 章结论需要 IMDN 等词出现，逐处人工判断。

### Task 3: 批次 1 收尾——衔接检查与用户确认

**Files:**
- Modify: `chapters/多光照/index.typ`（后半部分第 198–218 行仅在必要时微调）

- [ ] **Step 1: 检查后半章衔接**

"低光条件下的脱叶率吐絮率实时识别模型训练""实验结果评估""小结"三节**保留**，仅检查：① 不再有旧版模块名残留；② "小结"中如有具体数值与新版冲突则更新；③ 引言中"本章重点介绍增强模型结构、损失设计与整链路效果评估"的表述与新结构一致。

- [ ] **Step 2: 全文编译 + 交叉引用检查**

```bash
typst compile --root .. main.typ /tmp/main_check.pdf 2>&1 | grep -E '^error' 
```

Expected: 无输出。重点确认 `@tab:overall`、`@tab:ablation`、`@fig:backbone` 等 label 引用无断链。

- [ ] **Step 3: 暂停，向用户汇报批次 1 diff 摘要，等待确认后提交**

```bash
git add chapters/多光照/index.typ ref.bib
git commit -m "revise(ch6): 第6章对齐 L3-AgriUAVNet 期刊版（方法+实验数值）"
```

（commit 前必须获得用户确认。）

---

## 批次 2：全文术语替换

### Task 4: main.typ 与附录术语替换

**Files:**
- Modify: `main.typ`（结论、创新点、局限性、附录符号表）

**Interfaces:**
- Produces: RTCMNet 新全称 "Real-Time Cotton Monitoring Network" 的标准写法，Task 5–8 沿用。

- [ ] **Step 1: 定位全部待改处**

```bash
grep -n '成熟度\|Maturity' main.typ
```

（已知约 10 处。）

- [ ] **Step 2: 逐处替换（规则如下）**

- "成熟度识别" → "脱叶率与吐絮率识别"（或按语境"双指标识别"）。
- "成熟期棉花双指标"类表述保留；"成熟状态"作描述性名词保留，但"成熟状态识别" → "双指标识别"。
- 附录符号表 RTCMNet 行：`[Real-Time Cotton Maturity Network], [棉花成熟度实时识别网络]` → `[Real-Time Cotton Monitoring Network], [棉花脱叶率与吐絮率实时监测网络]`。
- 结论第（3）（4）（5）点、创新点（2）中涉及第 6 章增强模型的描述，数值与模块名同步期刊版（如提到 LPIPS/参数量的地方：0.139M 参数、SSIM 0.893）。

- [ ] **Step 3: 编译验证 + 残留检查**

```bash
typst compile --root .. main.typ /tmp/main_check.pdf 2>&1 | grep -c '^error'
grep -n '成熟度\|Maturity' main.typ
```

Expected: error 0；grep 无输出（"成熟期"不会被该模式匹配，无需处理）。

### Task 5: chapters 与摘要术语替换

**Files:**
- Modify: `chapters/绪论/index.typ`（约 15 处）、`chapters/基于深度学习/index.typ`（约 8 处）、`chapters/大田验证/index.typ`（约 20 处）、`chapters/光谱指数/index.typ`（约 5 处）、`chapters/数据集/index.typ`（约 3 处）、`chapters/多光照/index.typ`（约 2 处）、`cabstract.typ`（约 3 处）、`eabstract.typ`（英文 "cotton maturity" 多处）

- [ ] **Step 1: 全文定位**

```bash
grep -rn '成熟度\|Maturity\|maturity' chapters/ cabstract.typ eabstract.typ
```

- [ ] **Step 2: 逐文件替换（在 Task 4 规则基础上补充英文规则）**

- 英文："cotton maturity"（指标义）→ "defoliation rate and boll opening rate of cotton" 或 "dual indicators"；描述性 "cotton maturity status" → "cotton maturation status"；"maturity monitoring" → "maturation monitoring"。
- `eabstract.typ` 中 RTCMNet 首次出现处若给出全称，同步为 Real-Time Cotton Monitoring Network。
- `chapters/基于深度学习/index.typ` 中 RTCMNet 定义处同步新全称与中文名；统一 RTCM/RTCMNet 为 RTCMNet。

- [ ] **Step 3: 验证 + 提交（用户确认后）**

```bash
typst compile --root .. main.typ /tmp/main_check.pdf 2>&1 | grep -c '^error'
grep -rn '成熟度识别\|Cotton Maturity\|RTCM[^N]' chapters/ *.typ
git add -A chapters main.typ cabstract.typ eabstract.typ
git commit -m "revise: 全文术语规范（脱叶率与吐絮率/RTCMNet 新全称）"
```

Expected: error 0；grep 无输出。

---

## 批次 3：绪论 / 摘要 / 结论联动

### Task 6: 绪论核对

**Files:**
- Modify: `chapters/绪论/index.typ`

- [ ] **Step 1: 通读"研究目标与研究内容"节（含 研究目标 / 研究内容 / 拟解决的关键问题 / 研究方法和技术路线 四小节）**

核对开题评议③：研究内容条目只写"做什么"，方法细节只在"研究方法和技术路线"小节。若有混述（内容条目里出现具体模型结构/参数），将方法句移入技术路线小节。

- [ ] **Step 2: 核对技术路线与实际工作一致**

实际路线：RGB 数据集（第 2 章）→ 光谱指数可解释基线（第 3 章）→ RTCMNet（第 4 章）→ 退化建模与低光成对数据（第 5 章）→ 增强前端 + 全天候识别（第 6 章）→ 大田验证（第 7 章）。技术路线描述与 `technical_route.png` caption 不得出现 CycleGAN/Diff-Retinex 等未实际采用的方案。

- [ ] **Step 3: 编译验证**（同前命令，error 为 0）

### Task 7: 中英文摘要更新

**Files:**
- Modify: `cabstract.typ`、`eabstract.typ`

（两文件已是完整草稿，本任务做增量更新而非重写。）

- [ ] **Step 1: 更新中文摘要第 4 段（L³-AgriUAVNet 段）**

将"设计轻量低光增强前端 L³-AgriUAVNet"句补充期刊版口径：HVI 色彩空间与 RFDN-S 轻量主干、0.139M 参数、SSIM 最优（0.893）、iPad 级设备实时（202 ms）；下游收益表述与 YOLOv8n 结果一致（增强前端对轻量端侧模型收益显著）。

- [ ] **Step 2: 同步更新英文摘要对应段落**

对应改写第 4 段（L³-AgriUAVNet 段），术语遵循 Task 5 英文规则。

- [ ] **Step 3: 编译验证**（同前）

### Task 8: 结论 / 创新点 / 局限性更新与批次 3 提交

**Files:**
- Modify: `main.typ`（结论五点、创新点三条、局限性四条、展望）

- [ ] **Step 1: 更新结论第（4）点**

第 6 章相关表述更新为期刊版结论：增强前端 SSIM 最优、参数 0.139M、iPad 级实时；下游收益对轻量检测器显著、对强检测器边际有限。

- [ ] **Step 2: 检查创新点（2）与局限性（3）**

创新点（2）"可控退化数据—轻量增强模块—端侧识别模型"表述保留，如有旧模块名更新；局限性（3）"RGB 域近似、未建模 RAW/ISP 完整链路、极端逆光风险"保留（与期刊版局限一致）。

- [ ] **Step 3: 编译 + 提交（用户确认后）**

```bash
typst compile --root .. main.typ /tmp/main_check.pdf 2>&1 | grep -c '^error'
git add main.typ chapters/绪论/index.typ cabstract.typ eabstract.typ
git commit -m "revise: 摘要与结论联动更新（期刊版数值与术语）"
```

---

## 批次 4：一致性与终验

### Task 9: 数值一致性修复

**Files:**
- Modify: `chapters/基于深度学习/index.typ`、`chapters/基于深度学习/tables.typ`、`cabstract.typ`（如涉推理时间）

- [ ] **Step 1: 统一 RTCMNet 推理时间**

```bash
grep -rn '33\s*ms\|32\s*ms\|33\s*毫秒\|32\s*毫秒' chapters/ cabstract.typ main.typ
```

统一为 **32 ms**（正文对比表实测口径），摘要同步。

- [ ] **Step 2: 修正 ShuffleNetV2 Recall 排印**

```bash
grep -n 'ShuffleNet' chapters/基于深度学习/tables.typ chapters/基于深度学习/index.typ
```

Recall 列若为 `10` 改为 `1.00`（与同列小数格式一致）。

- [ ] **Step 3: 第 3 章光谱指数表述协调**

通读 `chapters/光谱指数/index.typ`，确认特征路线表述（RGB 图像 + 植被指数/纹理 + 传统机器学习）与第 2 章数据集（RGB 为主）不矛盾；如出现"多光谱"为主数据源的表述，改为以 RGB 可见光指数为主（ExG/VARI/NGRDI 等），与开题表 1 一致。

### Task 10: 全文终验与提交

- [ ] **Step 1: 交叉引用与断链检查**

```bash
typst compile --root .. main.typ /tmp/main_final.pdf 2>&1 | grep -E '^error|unknown'
```

Expected: 无 error；无 unresolved reference 类 warning。

- [ ] **Step 2: 术语终扫**

```bash
grep -rn '端测\|成熟度识别\|Cotton Maturity\|L-RFDB\|SCSA' main.typ chapters/ cabstract.typ eabstract.typ
```

Expected: 无输出（合理残留逐处人工确认）。

- [ ] **Step 3: 关键词核对**

`main.typ` 的 `ckeywords`/`ekeywords` 与摘要内容一致（"全天候识别""轻量级模型"保留）。

- [ ] **Step 4: 用户确认后提交**

```bash
git add -A
git commit -m "revise: 数值一致性修复与全文终验"
```

---

## 后续（不在本计划内，待用户确认）

- 第 6 章图片替换：用户提供期刊版原图后，替换 `chapters/低光合成/` 下对应图片或新增到 `figure/`，并删除 caption 中"[图待更新为期刊版]"标注。
- 早期清理的旧稿文件删除（工作区 `git status` 中 8 个 `D` 条目）尚未提交，可在某一批次经用户确认后一并提交。
