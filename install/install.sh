#!/bin/bash
set -eu

####### configuration
readonly GITHUB_REPO='https://github.com/tangpool/TangAgent/archive/latest.tar.gz'
#################

if [[ `id -u` -ne 0 ]]; then
  echo '请以 root 身份运行安装脚本' >&2; exit
fi

usage() {
    cat <<EOF

Usage: `basename $0` [OPTION] install_dest_dir

安装 TangAgent

OPTIONS
    -b, --binary
        指定安装包位置；如果不指定，则默认从 github 拉取

ARGUMENTS
    install_dest_dir
        安装目的路径
EOF
    exit
}

# 安装依赖库
install_dep() {
    apt-get update
    apt-get install -y build-essential autotools-dev libtool openssl libssl-dev supervisor ntp
}

# 下载主程序
download_binary() {
    local binary_dir=/tmp/TangAgentWeb.`date +%s`
    local binary_file=latest.tar.gz
    mkdir -p "$binary_dir" && cd $_
    wget --no-check-certificate  "$GITHUB_REPO" -O "$binary_file"
    binary_path="$binary_dir"/"$binary_file"
}

# 安装主程序
install_binary() {
    local binary_dir=`dirname "$binary_path"`
    cd "$binary_dir"
    tar xaf "$binary_path"
    cp -r ./TangAgent-latest/install/tangagent/* "$dest_dir"
}

# 检查动态库
check_ldd() {
    cd "$dest_dir"
    if [[ `ldd ./tangagent | grep 'not found' | wc -l` -ne 0 ]]; then
        echo '动态库检测失败，安装中止' >&2
        exit
    fi
}

#优化内核参数
optimize_kernel() {
    # 检测是否修改过参数
    if grep -Fq 'fs.file-max = 2097152' /etc/sysctl.conf; then
        return 0
    fi

    local SYSCTL='
net.ipv4.tcp_max_syn_backlog = 65536
net.core.netdev_max_backlog =  32768
net.core.somaxconn = 32768

net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800

fs.file-max = 2097152'

    echo "$SYSCTL" >> /etc/sysctl.conf
    /sbin/sysctl -p >/dev/null

    local ILMITS='
*         hard    nofile      500000
*         soft    nofile      500000
root      hard    nofile      500000
root      soft    nofile      500000'
    echo "$ILMITS" >> /etc/security/limits.conf

    local SESSION='
session required pam_limits.so'
    echo "$SESSION" >> /etc/pam.d/common-session
}

#添加计划任务
install_crontab() {
    local CRON_PATH=/etc/cron.d/TangAgent_${program_name}
    local crontab_content="0 0 * * * bash "$dest_dir"/backup_log.sh
* * * * * bash "$dest_dir"/check_share_time.sh"
    echo "$crontab_content" > "$CRON_PATH"
}

# 生成 supervisor 配置文件
supervisor_conf() {
    local agent_conf_path="$dest_dir"/agent.conf
    local agent_log_path="$dest_dir"/agent.log
    local supervisor_conf="[program:${program_name}]
autostart=true
autorestart=true
command=${dest_dir}/tangagent -c '${agent_conf_path}' -l '${agent_log_path}'
stopasgroup=true"
    echo "$supervisor_conf" > /etc/supervisor/conf.d/"$program_name".conf
    supervisorctl reread
    supervisorctl update
    supervisorctl stop "$program_name"
}

# 完成并提示用户
done_and_exit() {
    clear
    echo "安装完成，需要手动启动服务。

# 启动服务

以 root 身份运行： supervisorctl start ${program_name}

# 关闭服务

以 root 身份运行： supervisorctl stop ${program_name}

# 重启

以 root 身份运行： supervisorctl restart ${program_name}

# 升级

直接覆盖可执行程序 ${dest_dir}/tangagent，完成后**重启**进程
"

    exit 0
}

ARGS=`getopt -o b: -l binary: -- "$@"` || usage
eval set -- "${ARGS}"

binary_path=

while true; do
    case "$1" in
    -b|--binary)
        binary_path="$2"
        shift
        ;;
    --)
        shift
        break
        ;;
    esac
shift
done

[[ $# != 1 ]] && usage
dest_dir="$1"
mkdir -p "$dest_dir"
dest_dir=$(cd "$1"; pwd)

[[ -z "$binary_path" ]] && download_binary
binary_path=$(readlink -m "$binary_path");
[[ ! -f "$binary_path" ]] && {
    echo '指定的安装包不存在，请检查。' >&2;
    exit
}

# supervisor program name
program_name=agent_`basename "$dest_dir" | tr -d ' '`

install_dep
install_binary
check_ldd
install_crontab
optimize_kernel
supervisor_conf
done_and_exit
