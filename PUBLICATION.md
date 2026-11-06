# 教材网站的发布与更新

预期公开地址：<https://nedchen2.github.io/MicrobialML/>。
源码仓库：<https://github.com/nedchen2/MicrobialML>。

学生使用网页阅读，下载页面中的学生项目用 RStudio 运行。不要要求学生安装网页构建环境，也不要将教师完整归档包当作学生包分发。

## 第一次建立

1. 创建独立的公开仓库 `nedchen2/MicrobialML`，只提交本教材目录内经过检查的源文件。
2. 仓库 **Settings → Pages → Source** 设为 **GitHub Actions**。
3. 推送 `main`。工作流 `.github/workflows/deploy.yml` 自动运行全部 R notebooks、生成学生 ZIP、解压并从空缓存验证学生脚本、独立核对误差、严格构建网页、检查子路径链接，然后发布。
4. 等待 Actions 中 build 和 deploy 全部成功，再检查公开网址、目录、搜索、图表和下载。

本地演示的 `127.0.0.1` 地址不能作为学生访问地址。公开版本构建时使用 `BASE_URL=/MicrobialML`；仓库名称从工作流事件读取，不能直接把按本机根路径构建的 HTML 当作子目录网站发布。

## 日常修改

- 修改正文：第 0 章和参考页直接修改 Markdown；计算章节的说明修改 `authoring/*.md`。
- 修改计算：修改 `scripts/*.R` 中的 canonical 代码，然后运行 `python tools/execute_book.py` 更新 notebook。第 5–7 章脚本由整合脚本 worked-example.R 自动生成，不要单独修改生成的分步脚本。不要分别手改 notebook 与下载脚本中的计算。
- 提交修改、推送 `main`。只有新一轮检查成功才发布；失败时先看 Actions 中具体失败的步骤。
- 发给学生的始终是同一个教材主页网址。第一次使用前建议在课程平台写明：解压学生 ZIP，再双击 `.Rproj`。
- 每次正式开课前固定一个 Release，例如 `v0.2`，附上该版本验证后的学生 ZIP。网页会继续更新；Release 附件保留课堂用版本。

## 文件与环境边界

`.gitignore` 排除原始数据缓存、结果目录、作者依赖环境、验证日志和 ZIP；学生 ZIP 在每次构建时从源文件生成，因此不会因忽略 ZIP 而丢失网页下载。

`tools/check_publication.py` 使用明确允许的源文件范围，阻止 TA 文档、旧作业、完整原始数据和本机环境被误提交。教师说明仍保留在本仓库之外。普通 Pages 网站按公开材料处理。

Ubuntu CI 通过发行版软件包安装 R 和 IRkernel，Python 直接依赖固定在 `requirements-build.txt`，Node 使用 24。每次运行会保留实际 R 环境与验证报告，见 Actions 的 `textbook-checks-and-student-project` artifact。该附件同时包含学生 ZIP 和聚合结果表，不包含完整原始数据。

学生源数据从原作者固定提交下载并校验；首次运行需要联网。代码能够重跑不代表已经取得完整原始数据的再分发许可。

## 参考

- [Jupyter Book 发布说明](https://jupyterbook.org/latest/build-and-publish/publish/)
- [MyST 的 GitHub Pages 与 BASE_URL 配置](https://mystmd.org/guide/deployment-github-pages)
- [GitHub Pages 发布源设置](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
