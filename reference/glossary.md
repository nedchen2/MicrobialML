# A small glossary

| Term | Meaning here | 中文提示 |
|---|---|---|
| R | The language/runtime executing the calculations | 计算语言与运行环境 |
| RStudio | The interface used to write, run and inspect R code | 编写和运行 R 的界面 |
| Comment / `#` | Outside quoted text, `#` makes the rest of the line a note ignored by R | 注释，供人阅读 |
| Block marker / `# %%` | A comment labelling a section of this book's script | 本教程的代码分段标签 |
| Script | A saved file of instructions, usually `.R` | 脚本 |
| Console | Where R accepts commands and prints results | 控制台 |
| Object | A named value in the current R session | 内存中的对象 |
| Working directory | Starting folder for relative paths | 工作目录 |
| Checkpoint file | A saved input that a later chapter explicitly reloads | 章节间保存并重新载入的文件 |
| RDS | An R file format preserving saved objects and their types | R 对象保存格式 |
| Run / Source | Execute selected lines / execute a script, often with less intermediate printing | 运行选中代码／执行脚本 |
| Data frame | A table of rows and typed columns | 数据框 |
| Function | A named operation receiving arguments | 函数 |
| Argument | An input or setting supplied to a function | 参数或输入 |
| `NA` | A missing value, not necessarily zero | 缺失值 |
| Factor | A representation of categories | 分类变量 |
| Outcome / target | The value to be predicted | 结局／预测目标 |
| Predictor | Information available to make a prediction | 预测变量 |
| Package | A collection of R functions; the tree lessons use rpart | R 扩展包 |
| Formula | In R, `target ~ input1 + input2` specifies the prediction inputs | 模型公式 |
| Leaf | A final tree group; here it predicts its training mean | 叶节点 |
| Depth | Number of splits along a path from the root | 树深度 |
| Validation fold | A batch of training farms temporarily hidden for model selection | 训练内部验证分组 |
| Out-of-fold / OOF | A prediction made without fitting on that record's farm | 折外预测 |
| Median filling | Replace a missing input with a middle value learned from fitting records | 用训练部分中位数填补 |
| Group | Related observations kept together in a split | 分组，本例为牧场 |
| Baseline | A simple reference prediction procedure | 基线模型 |
| Train / validation / test | Learn / choose / evaluate using separate roles | 训练／验证／测试 |
| Residual | Observed value minus predicted value in this book | 残差 |
| RMSE | Square root of the mean squared error | 均方根误差 |
| MAE | Mean absolute error | 平均绝对误差 |
| CFU/mL | Colony-forming units per millilitre | 每毫升菌落形成单位 |
| MSC | Mesophilic spore count | 嗜温芽孢计数 |
| Detection limit | A method-specific limit on reliable detection | 检出限 |
| Left-censored | The true value is known only to lie below a limit | 左删失 |
| Log10 | Base-10 logarithm: log10(100) = 2 | 以 10 为底的对数 |
| Leakage | Information enters learning/evaluation where it should not | 数据泄漏 |
| Reproducible | Another run can reconstruct the stated result from the files/settings | 可复现 |

**A distinction to remember:** a predictor can be associated with an outcome without being its cause. A predictive score answers a different question from an intervention study.
