#!/bin/bash

# 设置脚本在遇到错误时立即退出，未设置的变量会报错，管道中的任何命令失败都会导致整个管道失败。
set -euo pipefail

# 定义颜色变量，用于终端输出美化
GREEN='\033[0;32m' # 绿色
BLUE='\033[0;34m'  # 蓝色
YELLOW='\033[0;33m' # 黄色
RED='\033[0;31m'   # 红色
PURPLE='\033[0;35m' # 紫色
CYAN='\033[0;36m'   # 青色
NC='\033[0m'       # 恢复默认颜色

# Ladefree 仓库信息
LADEFREE_REPO_URL_BASE="https://github.com/byJoey/ladefree"
LADEFREE_REPO_BRANCH="main"

# Lade CLI 相关配置
LADE_CLI_NAME="lade"
LADE_INSTALL_PATH="/usr/local/bin/${LADE_CLI_NAME}"

# 函数：显示欢迎界面
display_welcome() {
    clear # 清屏
    echo -e "${CYAN}#############################################################${NC}"
    echo -e "${CYAN}#${NC}                                                           ${CYAN}#${NC}"
    echo -e "${CYAN}#${NC}        ${BLUE}欢迎使用 Lade CLI 多功能管理脚本 v1.0.0${NC}        ${CYAN}#${NC}"
    echo -e "${CYAN}#${NC}                                                           ${CYAN}#${NC}"
    echo -e "${CYAN}#############################################################${NC}"
    echo -e "${GREEN}"
    echo "  >> 作者: Joey"
    echo "  >> 博客: joeyblog.net"
    echo "  >> Telegram 群: https://t.me/+ft-zI76oovgwNmRh"
    echo -e "${NC}"
    echo -e "${YELLOW}这是一个自动化 Lade 应用部署和管理工具，旨在简化操作。${NC}"
    echo ""
    read -p "按 Enter 键开始..." # 等待用户按 Enter 键
}

# 函数：显示章节标题
# 参数：$1 - 章节名称
display_section_header() {
    echo ""
    echo -e "${PURPLE}--- ${1} ---${NC}"
    echo -e "${PURPLE}-----------------------------------${NC}"
}

# 函数：检查命令是否存在
# 参数：$1 - 要检查的命令名
command_exists() {
    command -v "$1" &> /dev/null
}

# 函数：检查 Lade CLI 是否已安装
check_lade_cli() {
    command_exists "$LADE_CLI_NAME"
}

# 函数：确保 Lade CLI 已登录
ensure_lade_login() {
    echo ""
    echo -e "${PURPLE}--- 检查 Lade 登录状态 ---${NC}"
    # 尝试列出应用，如果失败则表示未登录或会话过期
    if ! lade apps list 
        echo -e "${YELLOW}Lade 登录会话已过期或未登录。${NC}请根据提示输入您的 Lade 登录凭据。"
        lade login # 提示用户登录
        if [ $? -ne 0 ]; then
            echo -e "${RED}错误：Lade 登录失败。请检查用户名/密码或网络连接。${NC}"
            exit 1 # 登录失败，退出脚本
        fi
        echo -e "${GREEN}Lade 登录成功！${NC}"
    else
        echo -e "${GREEN}Lade 已登录。${NC}"
    fi
}

# 函数：部署 Lade 应用
deploy_app() {
    display_section_header "部署 Lade 应用"

    ensure_lade_login # 确保已登录

    read -p "请输入您要部署的 Lade 应用名称 (例如: my-ladefree-app): " LADE_APP_NAME
    if [ -z "$LADE_APP_NAME" ]; then
        echo -e "${YELLOW}应用名称不能为空。取消部署。${NC}"
        return # 返回主菜单
    fi

    echo "正在检查应用 '${LADE_APP_NAME}' 是否存在..."
    local app_exists="false"
    # 检查应用是否已存在
    if lade apps list | grep -qw "${LADE_APP_NAME}"; then
        app_exists="true"
    fi

    if [ "${app_exists}" == "true" ]; then
        echo -e "${GREEN}应用 '${LADE_APP_NAME}' 已存在，将直接部署更新。${NC}"
    else
        echo -e "${YELLOW}应用 '${LADE_APP_NAME}' 不存在，将尝试创建新应用。${NC}"
        echo -e "${CYAN}注意：创建应用将交互式询问 'Plan' 和 'Region'，请手动选择。${NC}"
        lade apps create "${LADE_APP_NAME}" # 创建新应用
        if [ $? -ne 0 ]; then
            echo -e "${RED}错误：Lade 应用创建失败。请检查输入或应用名称是否可用。${NC}"
            return # 返回主菜单
        fi
        echo -e "${GREEN}Lade 应用创建命令已发送。${NC}"
    fi

    echo ""
    echo -e "${BLUE}--- 正在下载 ZIP 并部署 Ladefree 应用 (不依赖 Git) ---${NC}"
    # 创建临时目录用于下载和解压
    local ladefree_temp_download_dir="/tmp/ladefree_repo_download_$$"
    mkdir -p "${ladefree_temp_download_dir}"

    local ladefree_download_url="${LADEFREE_REPO_URL_BASE}/archive/refs/heads/${LADEFREE_REPO_BRANCH}.zip"
    local temp_ladefree_archive="${ladefree_temp_download_dir}/ladefree.zip"

    echo "正在下载 ${LADEFREE_REPO_URL_BASE} (${LADEFREE_REPO_BRANCH} 分支) 为 ZIP 包..."
    echo "下载 URL: ${ladefree_download_url}"

    # 下载 Ladefree 仓库的 ZIP 包
    if ! curl -L --fail -o "${temp_ladefree_archive}" "${ladefree_download_url}"; then
        echo -e "${RED}错误：下载 Ladefree 仓库 ZIP 包失败。请检查 URL 或网络连接。${NC}"
        rm -rf "${ladefree_temp_download_dir}" || true # 清理临时目录
        return
    fi

    echo "下载完成，正在解压..."
    # 解压 ZIP 包
    if ! unzip "${temp_ladefree_archive}" -d "${ladefree_temp_download_dir}"; then
        echo -e "${RED}错误：解压 Ladefree ZIP 包失败。${NC}"
        rm -rf "${ladefree_temp_download_dir}" || true
        return
    fi

    # 查找解压后的 Ladefree 应用程序目录
    local extracted_app_path=$(find "${ladefree_temp_download_dir}" -maxdepth 1 -type d -name "ladefree-*" -print -quit)

    if [ -z "${extracted_app_path}" ]; then
        echo -e "${RED}错误：未在临时下载目录中找到解压后的 Ladefree 应用程序目录。${NC}"
        rm -rf "${ladefree_temp_download_dir}" || true
        return
    fi

    echo -e "${BLUE}正在从本地解压路径 ${extracted_app_path} 部署到 Lade：${LADE_APP_NAME} ...${NC}"
    # 进入解压目录并执行部署命令
    (cd "${extracted_app_path}" && lade deploy --app "${LADE_APP_NAME}")

    local deploy_status=$?

    echo "清理临时下载目录 ${ladefree_temp_download_dir}..."
    rm -rf "${ladefree_temp_download_dir}" || true # 清理临时目录

    if [ ${deploy_status} -ne 0 ]; then
        echo -e "${RED}错误：Lade 应用部署失败。请检查 Ladefree 代码本身的问题或 Lade 平台日志。${NC}"
        return
    fi
    echo -e "${GREEN}Lade 应用部署成功！${NC}"

    echo ""
    echo -e "${CYAN}--- 部署完成 ---${NC}"
}

# 函数：查看所有 Lade 应用
view_apps() {
    display_section_header "查看所有 Lade 应用"

    ensure_lade_login # 确保已登录

    lade apps list # 列出所有应用
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误：无法获取应用列表。请检查网络或 Lade CLI 状态。${NC}"
    fi
}

# 函数：删除 Lade 应用
delete_app() {
    display_section_header "删除 Lade 应用"

    ensure_lade_login # 确保已登录

    read -p "请输入您要删除的 Lade 应用名称: " APP_TO_DELETE
    if [ -z "${APP_TO_DELETE}" ]; then
        echo -e "${YELLOW}应用名称不能为空。取消删除。${NC}"
        return
    fi

    echo -e "${RED}警告：您即将删除应用 '${APP_TO_DELETE}'。此操作不可撤销！${NC}"
    read -p "确定要删除吗？ (y/N): " CONFIRM_DELETE
    CONFIRM_DELETE=$(echo "${CONFIRM_DELETE}" | tr '[:upper:]' '[:lower:]') # 转换为小写

    if [ "${CONFIRM_DELETE}" == "y" ]; then
        lade apps remove "${APP_TO_DELETE}" # 执行删除命令
        if [ $? -ne 0 ]; then
            echo -e "${RED}错误：删除应用 '${APP_TO_DELETE}' 失败。请检查应用名称是否正确或您是否有权限。${NC}"
        else
            echo -e "${GREEN}应用 '${APP_TO_DELETE}' 已成功删除。${NC}"
        fi
    else
        echo -e "${YELLOW}取消删除操作。${NC}"
    fi
}

# 函数：查看 Lade 应用日志
view_app_logs() {
    display_section_header "查看 Lade 应用日志"

    ensure_lade_login # 确保已登录

    read -p "请输入您要查看日志的 Lade 应用名称: " APP_FOR_LOGS
    if [ -z "$APP_FOR_LOGS" ]; then
        echo -e "${YELLOW}应用名称不能为空。取消查看日志。${NC}"
        return
    fi

    echo -e "${CYAN}正在查看应用 '${APP_FOR_LOGS}' 的实时日志 (按 Ctrl+C 停止)...${NC}"
    lade logs -a "$APP_FOR_LOGS" -f # 查看实时日志
    if [ $? -ne 0 ]; then
        echo -e "${RED}错误：无法获取应用 '${APP_FOR_LOGS}' 的日志。请检查应用名称是否正确或应用是否正在运行。${NC}"
    fi
}

# 函数：安装 Lade CLI
install_lade_cli() {
    display_section_header "检查或安装 Lade CLI"

    if check_lade_cli; then
        echo -e "${GREEN}Lade CLI 已安装：$(which "$LADE_CLI_NAME")${NC}"
        return 0 # 已安装，直接返回
    fi

    echo -e "${YELLOW}Lade CLI 未安装。正在尝试自动安装 Lade CLI...${NC}"

    local lade_release_url="https://github.com/lade-io/lade/releases"
    local lade_temp_dir="/tmp/lade_cli_download_temp_$$"
    mkdir -p "${lade_temp_dir}"

    # 检测操作系统和架构
    local os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch_type=$(uname -m)

    local arch_suffix=""
    local file_extension=""
    case "${os_type}" in
        darwin) # macOS
            if [ "${arch_type}" == "x86_64" ]; then
                arch_suffix="-amd64"
                echo -e "${BLUE}检测到 macOS Intel (x86_64) 架构。${NC}"
            elif [ "${arch_type}" == "arm64" ]; then
                arch_suffix="-arm64"
                echo -e "${BLUE}检测到 macOS ARM (arm64) 架构。${NC}"
            else
                echo -e "${RED}错误：不支持的 macOS 架构：${arch_type}${NC}"
                rm -rf "${lade_temp_dir}" || true
                exit 1
            fi
            file_extension=".tar.gz" ;;
        linux) # Linux
            if [ "${arch_type}" == "x86_64" ]; then
                arch_suffix="-amd64"
                echo -e "${BLUE}检测到 Linux AMD64 (x86_64) 架构。${NC}"
            elif [ "${arch_type}" == "aarch64" ]; then
                arch_suffix="-arm64"
                echo -e "${BLUE}检测到 Linux ARM (aarch64) 架构。${NC}"
            else
                echo -e "${RED}错误：不支持的 Linux 架构：${arch_type}${NC}"
                rm -rf "${lade_temp_dir}" || true
                exit 1
            fi
            file_extension=".tar.gz" ;;
        windows) # Windows (WSL 或 Cygwin 环境下可能检测到)
            if [ "${arch_type}" == "x86_64" ]; then
                arch_suffix="-amd64"
                echo -e "${BLUE}检测到 Windows AMD64 (x86_64) 架构。${NC}"
            elif [ "${arch_type}" == "aarch64" ]; then
                arch_suffix="-arm64"
                echo -e "${BLUE}检测到 Windows ARM (aarch64) 架构。${NC}"
            else
                echo -e "${RED}错误：不支持的 Windows 架构：${arch_type}${NC}"
                rm -rf "${lade_temp_dir}" || true
                exit 1
            fi
            file_extension=".zip" ;;
        *) # 不支持的操作系统
            echo -e "${RED}错误：不支持的操作系统：${os_type}${NC}"
            rm -rf "${lade_temp_dir}" || true
            exit 1 ;;
    esac

    # 检查必要的命令是否存在
    if ! command_exists curl; then echo -e "${RED}错误：'curl' 命令未找到。请安装 curl 后再运行此脚本。${NC}"; rm -rf "${lade_temp_dir}" || true; exit 1; fi
    if [ "${file_extension}" == ".tar.gz" ] && ! command_exists tar; then echo -e "${RED}错误：'tar' 命令未找到。请安装 tar 后再运行此脚本。${NC}"; rm -rf "${lade_temp_dir}" || true; exit 1; fi
    if [ "${file_extension}" == ".zip" ] && ! command_exists unzip; then echo -e "${RED}错误：'unzip' 命令未找到。请安装 unzip 后再运行此脚本。${NC}"; rm -rf "${lade_temp_dir}" || true; exit 1; fi
    if ! command_exists awk; then echo -e "${RED}错误：'awk' 命令未找到。请安装 awk 后再运行此脚本。${NC}"; rm -rf "${lade_temp_dir}" || true; exit 1; fi

    echo "正在获取最新版本的 Lade CLI..."
    # 从 GitHub API 获取最新发布版本标签
    local latest_release_tag=$(curl -s "https://api.github.com/repos/lade-io/lade/releases/latest" | awk -F'"' '/"tag_name":/{print $4}')
    if [ -z "${latest_release_tag}" ]; then
        echo -e "${RED}错误：无法获取最新版本的 Lade CLI。请检查网络或 GitHub API 限制。${NC}"
        rm -rf "${lade_temp_dir}" || true
        exit 1
    fi
    local lade_version="${latest_release_tag}"
    echo -e "${GREEN}检测到最新版本：${lade_version}${NC}"

    # 构造下载文件名和 URL
    local filename_to_download="lade-${os_type}${arch_suffix}${file_extension}"
    local download_url="${lade_release_url}/download/${lade_version}/${filename_to_download}"
    local temp_archive="${lade_temp_dir}/${filename_to_download}"

    echo "下载 URL: ${download_url}"
    echo "正在下载 ${filename_to_download} 到 ${temp_archive}..."
    # 下载 Lade CLI 可执行文件
    if ! curl -L --fail -o "${temp_archive}" "${download_url}"; then
        echo -e "${RED}错误：下载 Lade CLI 失败。请检查网络连接或 URL 是否正确。${NC}"
        rm -rf "${lade_temp_dir}" || true
        exit 1
    fi

    echo "下载完成，正在解压..."
    # 解压下载的文件
    if [ "${file_extension}" == ".tar.gz" ]; then
        if ! tar -xzf "${temp_archive}" -C "${lade_temp_dir}"; then
            echo -e "${RED}错误：解压 .tar.gz 文件失败。${NC}"
            rm -rf "${lade_temp_dir}" || true
            exit 1
        fi
    elif [ "${file_extension}" == ".zip" ]; then
        if ! unzip "${temp_archive}" -d "${lade_temp_dir}"; then
            echo -e "${RED}错误：解压 .zip 文件失败。${NC}"
            rm -rf "${lade_temp_dir}" || true
            exit 1
        fi
    else
        echo -e "${RED}错误：不支持的压缩文件格式：${file_extension}${NC}"
        rm -rf "${lade_temp_dir}" || true
        exit 1
    fi

    # 查找解压后的 Lade CLI 可执行文件
    local extracted_lade_path=$(find "${lade_temp_dir}" -type f -name "${LADE_CLI_NAME}" -perm +111 2>/dev/null | head -n 1)
    if [ -z "${extracted_lade_path}" ]; then
        echo -e "${RED}错误：在解压后的临时目录中未找到 '${LADE_CLI_NAME}' 可执行文件。请检查压缩包内容。${NC}"
        rm -rf "${lade_temp_dir}" || true
        exit 1
    fi

    echo "正在将 Lade CLI 移动到 ${LADE_INSTALL_PATH}..."
    # 将 Lade CLI 移动到安装路径并添加执行权限
    if ! sudo mv "${extracted_lade_path}" "${LADE_INSTALL_PATH}"; then
        echo -e "${RED}错误：移动 Lade CLI 文件失败。可能需要管理员权限或目录不存在。${NC}"
        rm -rf "${lade_temp_dir}" || true
        exit 1
    fi
    sudo chmod +x "${LADE_INSTALL_PATH}"

    echo -e "${GREEN}Lade CLI 已成功下载、解压并安装到 ${LADE_INSTALL_PATH}${NC}"
    rm -rf "${lade_temp_dir}" || true # 清理临时目录
    return 0
}

# --- 脚本主逻辑开始 ---

display_welcome # 显示欢迎界面

# 尝试安装 Lade CLI，如果失败则退出脚本
install_lade_cli || exit 1

# 主循环菜单
while true; do
    echo ""
    echo -e "${CYAN}#############################################################${NC}"
    echo -e "${CYAN}#${NC}         ${BLUE}Lade 管理主菜单${NC}                           ${CYAN}#${NC}"
    echo -e "${CYAN}#############################################################${NC}"
    echo -e "${GREEN}1. ${NC}部署 Ladefree 应用"
    echo -e "${GREEN}2. ${NC}查看所有 Lade 应用"
    echo -e "${GREEN}3. ${NC}删除 Lade 应用"
    echo -e "${GREEN}4. ${NC}查看应用日志"
    echo -e "${GREEN}5. ${NC}刷新 Lade 登录状态"
    echo -e "${RED}6. ${NC}退出"
    echo -e "${CYAN}-------------------------------------------------------------${NC}"
    read -p "请选择一个操作 (1-6): " CHOICE # 读取用户选择

    case "$CHOICE" in
        1) deploy_app ;;
        2) view_apps ;;
        3) delete_app ;;
        4) view_app_logs ;;
        5) ensure_lade_login ;;
        6) echo -e "${CYAN}退出脚本。再见！${NC}"; break ;; # 退出循环
        *) echo -e "${RED}无效的选择，请输入 1 到 6 之间的数字。${NC}" ;; # 无效输入
    esac
    echo ""
    read -p "按 Enter 键继续..." # 等待用户按 Enter 键
done

echo -e "${BLUE}脚本执行完毕。${NC}"
