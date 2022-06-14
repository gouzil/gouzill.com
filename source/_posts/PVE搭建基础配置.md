---
title: PVE搭建——基础配置
date: 2022-06-11 22:50:15
tags:
  - PVE
  - linux
categories:
  - 教程
keywords: PVE,debian
description: pve的环境安装和基本配置
---
# 简介
本教程适用于两个或以上网卡服务器配置PVE服务器

## 安装PVE系统
## 换国内源：

PVE换源
```bash
wget https://mirrors.ustc.edu.cn/proxmox/debian/proxmox-release-bullseye.gpg -O /etc/apt/trusted.gpg.d/proxmox-release-bullseye.gpg
echo "#deb https://enterprise.proxmox.com/debian/pve bullseye pve-enterprise" > /etc/apt/sources.list.d/pve-enterprise.list
echo "deb https://mirrors.ustc.edu.cn/proxmox/debian/pve bullseye pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list
```

Debian换源
```bash
mv /etc/apt/sources.list /etc/apt/sources.list.bk
nano /etc/apt/sources.list
```
Sources.list加入源
```bash
deb http://mirrors.ustc.edu.cn/debian stable main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable main contrib non-free
deb http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable-updates main contrib non-free

# deb http://mirrors.ustc.edu.cn/debian stable-proposed-updates main contrib non-free
# deb-src http://mirrors.ustc.edu.cn/debian stable-proposed-updates main contrib non-free
```

更新&安装ethtool
```bash
apt update
apt upgrade -y
```

网卡打开自启

重启
![](./pve_eth.png)

使用`ethtool`命令进行查询网卡状态

`Link detected: yes`代表连接上了
`Link detected: on`代表没有连接
```bash
root@pve:~# ethtool enp4s0 
Settings for enp4s0:
        Supported ports: [  ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
                                2500baseT/Full
        Supported pause frame use: Symmetric
        Supports auto-negotiation: Yes
        Supported FEC modes: Not reported
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
                                2500baseT/Full
        Advertised pause frame use: Symmetric
        Advertised auto-negotiation: Yes
        Advertised FEC modes: Not reported
        Speed: Unknown!
        Duplex: Unknown! (255)
        Auto-negotiation: on
        Port: Twisted Pair
        PHYAD: 0
        Transceiver: internal
        MDI-X: off (auto)
        Supports Wake-on: pumbg
        Wake-on: g
        Current message level: 0x00000007 (7)
                               drv probe link
        Link detected: no
```

