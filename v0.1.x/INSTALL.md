# TangAgent
本文档为`TangAgent`的安装文档。

* 适用操作系统：`Ubuntu 64Bit`
  * 版本：`12.04`/`13.10`/`14.04`

## 安装步骤

### 安装依赖库

````
apt-get install libboost-dev libboost-thread-dev libboost-system-dev libboost-regex-dev libboost-filesystem-dev openssl libssl-dev  libmysqlclient-dev daemontools
````

### 设置计划任务
* 执行命令：`crontab -e`，添加如下内容：

````
#
# tangagent backup logs
#
0 0 * * * /root/supervise_tangagent/backup_log.sh
````

### 优化内核参数

* 编辑`/etc/sysctl.conf`，添加如下内容：

````
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
````
* 执行命令：`/sbin/sysctl -p`，生效之

### 设置开机自启动

* 编辑`/etc/rc.local`，添加如下内容：

````
ulimit -SHn 65535
nohup supervise /root/supervise_tangagent/ &
````

