
# Lade CLI 多功能管理脚本

这是一个跨平台的 Bash 和 PowerShell 脚本，旨在简化 Lade 应用的部署和日常管理。它自动化了 Lade CLI 的安装、应用部署、查看、删除和日志管理等常用操作，让你的开发和运维工作更加高效。

-----

## 主要功能

  * **Lade CLI 自动安装：** 自动检测并安装最新版本的 Lade CLI 工具（支持 Linux、macOS 和 Windows）。
  * **应用部署：** 快速部署 Ladefree 应用到 Lade 平台，支持创建新应用或更新现有应用。此过程不依赖本地 Git，直接通过 ZIP 包下载部署。
  * **应用管理：**
      * 查看所有已部署的 Lade 应用。
      * **删除**指定的 Lade 应用 (`lade apps remove`)。
      * 查看应用实时日志。
  * **登录状态刷新：** 检查并提示你刷新 Lade 登录会话。
  * **跨平台支持：** 提供 Bash 和 PowerShell 两个版本，兼容主流操作系统。

-----

## 如何使用

你可以根据你的操作系统选择使用 Bash 或 PowerShell 脚本。

### Bash 版本 (Linux / macOS)

1.  **一行命令运行脚本：**
    直接在终端中运行以下命令即可自动下载并执行脚本。

    ```bash
    bash <(curl -l -s https://raw.githubusercontent.com/byJoey/ladefree/refs/heads/main/install.sh)
    ```
## 第一次运行安装完依赖后要重启终端输入     lade login


2.  **脚本运行步骤：**

      * 脚本会首先检查并安装 **Lade CLI**。你可能需要输入 `sudo` 密码来完成安装。
      * 安装完成后，将显示主菜单，你可以根据提示选择相应操作。

### PowerShell 版本 (Windows)

1.  **以管理员身份运行 PowerShell：**
    为了确保 Lade CLI 能够正确安装到系统路径，并执行其他需要权限的操作，**强烈建议以管理员身份运行 PowerShell**。

2.  **一行命令运行脚本：**
    **重要安全提示：** 以下命令使用了 `-ExecutionPolicy Bypass` 参数，它会绕过 PowerShell 的执行策略，允许运行任何脚本。**请确保你完全信任此脚本的来源，否则可能存在安全风险。**

    打开 PowerShell 并运行以下命令：

    ```powershell
    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/byJoey/ladefree/main/install.ps1" -OutFile "$env:TEMP\install.ps1"; PowerShell -ExecutionPolicy Bypass -File "$env:TEMP\install.ps1"; Remove-Item "$env:TEMP\install.ps1" -ErrorAction SilentlyContinue
    ```
## 第一次运行安装完依赖后要重启终端输入     lade login

      * 此命令将脚本下载到临时文件夹。
      * 然后使用 `-ExecutionPolicy Bypass` 参数执行该脚本。
      * 最后，它会清理临时下载的脚本文件。

3.  **脚本运行步骤：**

      * 脚本会首先检查并安装 **Lade CLI**。在安装过程中，你可能会看到权限提升请求，请允许。
      * 安装完成后，将显示主菜单，你可以根据提示选择相应操作。

-----

## 贡献

如果你有任何改进建议或发现 Bug，欢迎通过 GitHub Issues 或 Pull Requests 提交。

-----
## 感谢老王的notejs https://github.com/eooce

## 作者

  * **Joey**
      * 博客: [joeyblog.net](https://joeyblog.net)
      * Telegram 群: [https://t.me/+ft-zI76oovgwNmRh](https://t.me/+ft-zI76oovgwNmRh)

-----

## 许可

此项目根据 MIT 许可证发布 - 详情请参阅 [LICENSE](https://www.google.com/search?q=LICENSE) 文件。

-----
