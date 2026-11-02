# 进口询价与方案辅助系统

辅助整理进口业务案卷、材料和方案草稿，面向内部试点使用。当前版本为 **0.13.0 候选审核包**，不是正式上线批准；实际报价、税率、汇率及费用依据须由业务人员核实，按流程复核。

## 下载安装

| 使用环境 | 下载 | 适用说明 |
| --- | --- | --- |
| Windows x64 | [下载 Windows 完整候选审核包](https://github.com/chensirrrrrrrr/freight-import-assistant-0.13.0/releases/download/v0.13.0/freight-windows-review-0.13.0.zip) | 包含 Windows 启动脚本、主程序和离线镜像 |
| Linux x86_64 | [下载 Linux/amd64 交付包](https://github.com/chensirrrrrrrr/freight-import-assistant-0.13.0/releases/download/v0.13.0/freight-import-assistant-0.13.0-linux-amd64.tar.gz) | 面向熟悉 Linux 和 Docker 的部署人员 |

也可以打开 [v0.13.0 发行版](https://github.com/chensirrrrrrrr/freight-import-assistant-0.13.0/releases/tag/v0.13.0) 查看附件。GitHub 自动生成的 **Source code** 压缩包是仓库快照，不是 Windows 完整交付包。

### Windows 快速开始

1. 准备 Windows x64、Python 3.11 或以上，以及启用 WSL2 后端和 Linux 容器的 Docker Desktop。请先确认 Docker Desktop 的 Linux 引擎可以启动。
2. 下载上表中的 **Windows 完整候选审核包**，解压到本地磁盘固定目录，例如 `C:\FreightReview`。不要直接在压缩包中运行。
3. 阅读包里的 [先读我](先读我.md)，然后双击 `Start.cmd`。首次启动会校验文件、导入离线镜像并生成本地账号和证书。
4. 按提示完成本机证书信任。启动成功后，浏览器访问 `https://127.0.0.1:28443/`，初始登录信息只在本机显示。不要分享密码、私钥、配置或客户数据。
5. 日常使用 `Stop.cmd` 停止、`Status.cmd` 查看状态；备份与恢复步骤请参考包内说明。

**验收状态：**Windows 首次启动、证书信任、登录、重启保留和备份恢复的端到端测试尚未完成。请先作为候选审核包试装，发现问题请附错误信息提交反馈，切勿上传密码、密钥、私钥或客户原始资料。

### Linux 部署

Linux 包面向 x86_64、Docker Engine、Docker Compose 插件及 Python 3.11 以上的环境。下载并解压后，先阅读包内的 `README.md`、`DEPLOYMENT.md` 和 `OPERATIONS.md`；按目标服务器的实际环境完成部署和验收。

## 反馈问题

通过 [Issues](https://github.com/chensirrrrrrrr/freight-import-assistant-0.13.0/issues) 提交问题时，请说明使用的系统、下载的包、复现步骤、预期结果及错误信息。提交前请移除账号密码、密钥、证书私钥和客户原始资料。

## 项目边界

本版本用于内部试点和审核。报价和业务结论仍需核对依据并由人员复核；安装成功不代表已经具备正式报价或正式上线条件。

