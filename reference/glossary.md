# A small glossary

## R and project files

| Term | Meaning here | 中文提示 |
|---|---|---|
| R | The language that runs the calculations | R 语言与运行环境 |
| RStudio | The app where you edit scripts and inspect results | 编写和运行 R 的界面 |
| Console | Where R accepts commands and prints messages and results | 控制台 |
| Script | A saved file of instructions, usually ending in `.R` | 脚本 |
| Comment / `#` | Outside quotes, `#` starts a note for the reader | 注释 |
| Block marker / `# %%` | A comment marking the start of a named code block | 本教程的代码区块标签 |
| **Run** in RStudio | Runs your selected code, or the current line if nothing is selected | 运行所选代码或当前行 |
| **Source** button in RStudio | Runs the entire script | 执行整个脚本 |
| **Source** panel on the textbook page | Shows the supplied code so you can read it | 网页上的代码展示区 |
| Object | A value with a name in the current R session | 当前会话中的对象 |
| Working directory | The folder R starts from when you give it a path like `data/practice_counts.csv` | 工作目录 |
| Checkpoint | A saved file that a later chapter reads, such as `tree-fit.rds` | 供后续章节读取的检查点文件 |
| RDS | An R file format that preserves saved objects and their types | R 对象保存格式 |
| Package | A collection of functions. This book uses `rpart` to fit trees. | R 扩展包 |
| Function | An operation you can call by name, such as `mean()` | 函数 |
| Argument | A value or setting you pass to a function | 参数 |
| Check / assertion | A test of an expected condition. `stopifnot()` stops when the condition fails. | 检查／断言 |
| Checksum | A value calculated from a file that helps check whether it matches the expected copy | 文件校验值 |
| Reproducible | The same inputs and settings let someone recreate the result | 可复现 |

## Milk data

| Term | Meaning here | 中文提示 |
|---|---|---|
| Data frame | An R table with rows and columns. Columns can hold different types of values. | 数据框 |
| Factor | R's representation of a set of categories | 分类变量 |
| `NA` | R's marker for a missing value | 缺失值 |
| MSC | Mesophilic spore count, the measurement we predict | 嗜温芽孢计数 |
| CFU/mL | Colony-forming units per millilitre | 每毫升菌落形成单位 |
| Sampling round | A visit when the study collected a farm's sample. Farm R4 has a record from round A. | 采样轮次 |
| Detection limit | The lowest concentration the assay can reliably detect | 检出限 |
| Left-censored | The result falls below a known limit and its exact value is unknown | 左删失 |
| Log10 | The power you raise 10 to in order to get a value. For example, `log10(100)` is 2. | 以 10 为底的对数 |

## Models and evaluation

| Term | Meaning here | 中文提示 |
|---|---|---|
| Outcome / target | The value to predict, `log10_msc` in the study analysis | 预测目标 |
| Predictor | An input available when making a prediction, such as the farm's cow count | 预测变量 |
| Fit | Learn a prediction rule from a set of records | 拟合 |
| Formula | `target ~ input1 + input2` names the answer and the inputs for an R model | 模型公式 |
| Baseline | A simple prediction rule used for comparison. Here it predicts the training mean for every record. | 基线模型 |
| Leaf | A final group in a tree. This tree predicts the training mean of that group. | 叶节点 |
| Depth | The number of questions on the longest path from the first question to a prediction. Maximum depth sets the limit. | 树深度 |
| Train / validation / test | Learn the rule from training data, choose settings using validation, and check the final rule on test data | 训练／验证／测试 |
| Group | Records that stay together when we split the data. Here the group is a farm. | 分组，本例为农场 |
| Validation fold | One batch of training farms. Each batch takes a turn checking predictions from a model fitted on the other batches. | 训练集内部的验证分组 |
| Out-of-fold prediction / OOF | A prediction made while that record's fold is held out. In Chapter 9, R4/A gets its prediction in the round that holds out fold 1. | 折外预测 |
| Median filling | Use a median learned from the fitting records in place of a missing input | 用拟合记录的中位数填补 |
| Residual | Observed value minus predicted value | 残差 |
| MAE | The average size of a prediction error, regardless of its sign | 平均绝对误差 |
| RMSE | Square the residuals, average them, and take the square root. Larger errors have more influence. | 均方根误差 |
| Data leakage | Information reaches a step too early. For example, test lab results help set the rule that those same results will score. | 数据泄漏 |

See the worked example in [Chapter 9’s fold rotation](../chapters/09-choose-tree.ipynb#id-9-3-combine-the-predictions-from-five-rounds).
