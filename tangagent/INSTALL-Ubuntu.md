# TangAgent
本文档为`TangAgent`的安装文档。

* 适用操作系统：`Ubuntu 64Bit`
  * 版本：`12.04`/`13.10`/`14.04`  
  * GCC version >= `4.6`
* 技术支持
  * _Web_: [http://bbs.tangpool.com](http://bbs.tangpool.com)
  * _Email_: `techsupport@tangpool.com`


## 安装步骤

### 安装依赖库

````
$ apt-get install build-essential autotools-dev libtool openssl libssl-dev daemontools
````

### 安装主程序

* 主程序目录为`/root/supervise_tangagent`

````
$ mkdir /root/supervise_tangagent
$ wget https://codeload.github.com/tangpool/TangAgent/tar.gz/v0.1.0 -O TangAgent-0.1.0.tar.gz
$ tar zxvf TangAgent-0.1.0.tar.gz
$ cd TangAgent-0.1.0
$ cp -r tangagent/supervise_tangagent/* /root/supervise_tangagent/
````

* 查看程序目录： `ls -lh /root/supervise_tangagent/`，会有如下文件：

````
-rw-r--r--  1 kevin  wheel   5.0K  8 22 16:59 agent.conf
-rwxr-xr-x  1 kevin  wheel   207B  8 22 16:59 backup_log.sh
-rwxr-xr-x  1 kevin  wheel   592B  8 22 16:59 check_share_time.sh
-rw-r--r--  1 kevin  wheel   128B  8 22 16:59 crontab.example
-rwxr-xr-x  1 kevin  wheel   128B  8 22 16:59 run
-rwxr-xr-x  1 kevin  wheel   2.1M  8 22 16:59 tangagent
````

* 检测动态库

````
$ cd /root/supervise_tangagent
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

* 若出现`not found`字样，说明缺少相关依赖库


### 设置计划任务

* 执行命令：`crontab -e`，添加如下内容：

````
#
# TangAgent
#
0 0 * * * sh /root/supervise_tangagent/backup_log.sh
* * * * * sh /root/supervise_tangagent/check_share_time.sh
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

fs.file-max = 2097152
````
* 执行命令：`/sbin/sysctl -p`，生效之

### 增大文件数限制

默认文件句柄限制为1024，而TangAgent需要建立成千上万的Tcp连接，故必须调整文件句柄限制。

* 编辑：`/etc/security/limits.conf`，设置如下：

````
*         hard    nofile      500000
*         soft    nofile      500000
root      hard    nofile      500000
root      soft    nofile      500000
````
保存后请重新登录。

* 编辑：`/etc/pam.d/common-session`，新增如下：

````
session required pam_limits.so
````

* 验证之：

````
$ cat /proc/sys/fs/file-max
2097152
$ ulimit -Hn
500000
$ ulimit -Sn
500000
````

若有限制数为1024，请重新检查。

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
````

* 查看时钟同步状态，成功同步状态：

````
$ ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 gus.buptnet.edu .INIT.          16 u    - 1024    0    0.000    0.000   0.000
 news.neu.edu.cn .INIT.          16 u    - 1024    0    0.000    0.000   0.000
 dns2.synet.edu. .INIT.          16 u    - 1024    0    0.000    0.000   0.000
*golem.canonical 131.188.3.220    2 u  314 1024  377  287.850    0.151   0.522
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

### 升级
直接覆盖可执行程序`tangagent`，完成后重启`TangAgent`进程即可

````
cp -f new/tangagent old/tangagent
````


## 其他注意事项

* 若您安装目录非`/root/supervise_tangagent`，请注意变更路径
* 若`kill`进程出现故障，可用`kill -9 <id>`强制退出

