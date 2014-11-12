# TangAgent

本文档为`TangAgent`的安装文档。

* 适用操作系统：`Ubuntu 64Bit`
  * 版本：`12.04`/`13.10`/`14.04`  
  * GCC version >= `4.6`
* 技术支持
  * _Web_: [http://bbs.tangpool.com](http://bbs.tangpool.com)
  * _Email_: [support@tangpool.com](mailto:support@tangpool.com)

## 安装

```shell
wget https://raw.githubusercontent.com/tangpool/TangAgent/master/install/install.sh
chmod +x install.sh
```

安装到 /root/agent 目录下：

```shell
./install.sh /root/agent
```

如果同一台机器上部署多个 agent，目录**不能相同**。

## 配置

安装完成后进入安装目录，打开 agent.conf 修改 agent 配置后方可开始使用。

* 修改`stratum.server.port`为监听的端口
* 修改`tangpool.agent.id`为新创建的AgentID
* 修改矿池用户名等信息（如果需要）

### Agent.Id的获取

* 登录[dashboard.tangpool.com](http://dashboard.tangpool.com)注册账户，然后创建新的AgentId
