#let all_metrics = table(
  columns: 9,
  table.header([], [Backbone], [Accuracy], [F1], [Precision], [Recall], [Params(M)], [Macs(G)], [InferenceTime(ms)]),
  table.cell(rowspan: 4, align: horizon, rotate(-90deg, reflow: true)[
    经典模型
  ]),

  [InceptionV3 @szegedy2016rethinking], [0.79], [0.78], [0.81], [0.79], [22.77], [2.64], [385],
  [Resnet18@he2016deep], [0.87], [0.88], [0.91], [0.87], [10.66], [1.69], [629],
  [Densenet121@huang2017densely], [0.94], [0.94], [0.95], [0.94], [6.63], [2.63], [1084],
  [ViT_S@dosovitskiy2020image], [0.77], [0.77], [0.79], [0.77], [20.67], [0.07], [603],

  [], [], [], [], [], [], [], [], [],

  table.cell(rowspan: 8, align: horizon, rotate(-90deg, reflow: true)[
    轻量模型
  ]),
  [LeViT128@graham2021levit], [0.86], [0.86], [0.87], [0.86], [6.68], [0.54], [49],
  [EfficientNet@tan2019efficientnet], [0.88], [0.87], [0.90], [0.89], [3.82], [0.36], [114],
  [MobileNetV2@sandler2018mobilenetv2], [0.87], [0.87], [0.87], [0.87], [2.12], [0.28], [62],
  [MobileNetV3S@howard2019searching], [0.15], [0.08], [0.06], [0.15], [0.88], [0.05], [22],
  [SqueezeNet@iandola2016squeezenet], [0.74], [0.73], [0.76], [0.73], [0.69], [0.25], [40],
  [ShuffleNetV2@ma2018shufflenet], [0.92], [0.92], [0.93], [1.00], [5.10], [0.54], [10],
  [SCTNet@xu2024sctnet], [0.90], [0.90], [0.91], [0.90], [0.75], [0.37], [65],
  [RTCMNet], [0.94], [0.94], [0.95], [0.94], [0.35], [0.10], [32],
)

#let ablation_study = table(
  columns: 6,
  [layer nums], [Attn], [head_num], [Accuracy], [Inference Time(ms)], [Macs(G)],
  [1,1,1], [CF], [8], [0.89], [22], [0.37],
  [1,2,2], [CF], [16], [0.90], [205], [6.75],
  [1,1,1], [MSCA], [8], [0.91], [29], [0.7],
  [1,2,2], [MSCA], [8], [0.942], [31], [0.9],
  [1,2,2], [MSCA], [16], [0.92], [113], [4.31],
)
