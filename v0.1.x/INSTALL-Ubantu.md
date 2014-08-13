# TangAgent
本文档为`TangAgent`的安装文档。

* 适用操作系统：`Ubuntu 64Bit`
  * 版本：`12.04`/`13.10`/`14.04`

## 安装步骤

### 安装依赖库

````
$ apt-get install build-essential autotools-dev libtool
$ apt-get install libboost-dev libboost-thread-dev libboost-system-dev libboost-regex-dev libboost-filesystem-dev openssl libssl-dev libmysqlclient-dev daemontools
````

### 安装主程序

* 主程序目录为`/root/supervise_tangagent`

````
mkdir -p /root/supervise_tangagent
wget https://github.com/tangpool/TangAgent/blob/master/v0.1.x/supervise_tangagent/backup_log.sh -O backup_log.sh
wget https://github.com/tangpool/TangAgent/blob/master/v0.1.x/supervise_tangagent/run -O run
wget https://github.com/tangpool/TangAgent/blob/master/v0.1.x/supervise_tangagent/tangagent -O tangagent
chmod +x backup_log.sh
chmod +x run
chmod +x tangagent
````

* 检测动态库

````
$ ldd tangagent
	linux-vdso.so.1 =>  (0x00007fff22b84000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f3de7542000)
	librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f3de733a000)
	libssl.so.1.0.0 => /lib/x86_64-linux-gnu/libssl.so.1.0.0 (0x00007f3de70db000)
	libcrypto.so.1.0.0 => /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 (0x00007f3de6d00000)
	libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f3de6a00000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f3de6703000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f3de64ed000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f3de612d000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f3de7768000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f3de5f28000)
	libz.so.1 => /lib/x86_64-linux-gnu/libz.so.1 (0x00007f3de5d11000)
````

* 若出现`Not Found`字样，说明缺少相关依赖库


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
#
# start up tangagent
#
nohup supervise /root/supervise_tangagent/ &
````

### 开启服务器时钟同步

````
$ apt-get install sysv-rc-conf ntp
$ service ntp reload
$ sysv-rc-conf ntp on

# show status
$ ntpq -p
````

## 程序的启动、停止与重启
### 启动服务

````
$ nohup supervise /root/supervise_tangagent/ &
````

### 关闭服务

* 关闭对应的`supervise`进程，找出其进程号，并结束之

````
$ ps aux | grep supervise
$ kill xxxxx
````

* 关闭`tangagent`进程，找出其进程号，并结束之

````
$ ps aux | grep tangagent
$ kill xxxxx
````

### 重启

* 关闭`tangagent`进程，找出其进程号，并结束之。`supervise`会自动启动新的`tangagent`进程。

````
$ ps aux | grep tangagent
$ kill xxxxx
````



## 其他注意事项

* 若您安装目录非`/root/supervise_tangagent`，请注意变更路径
* 若`kill`进程出现故障，可用`kill -9 <id>`强制退出

