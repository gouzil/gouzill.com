---
title: github国内访问慢
date: 2022-10-17 23:19:15
tags:
  - github
keywords: github, dns
description: 使用docker搭建hexo博客cicd环境实现自动部署
---

# 为什么 Github 访问失败或者缓慢 ？

主要原因是 DNS 污染. 简单来说就是 DNS 服务器错误的把域名指向不正确的 IP 地址，阻碍了网络访问. 

# 解决方案

__注：选择其中一种即可__

1. (不推荐) 修改 DNS 服务器
   * [Windows 教程](https://zhuanlan.zhihu.com/p/265364903)
   * [MacOS 教程](https://zhuanlan.zhihu.com/p/79712428)
   * [Ubuntu20.04 教程](https://zhuanlan.zhihu.com/p/348583848)
2. (推荐) 修改 hosts 文件
   * 使用 [ping 检测工具](https://ping.chinaz.com/github.com)测试访问, 我们选择一个延迟较低的就行
    ![](https://ai-studio-static-online.cdn.bcebos.com/f956c6e15f064d78b952948eca2ec08f13adac179e0a4123a17035bb1262b280)
   * 修改 hosts 前可以测试一下访问延迟
    ![](https://ai-studio-static-online.cdn.bcebos.com/e4909872bfde4bbdaf780bc6ce07ecb23a4a05fcaf1b4fb28a23b3b118ed45ba)
   * 修改 hosts 
     * Windows 
        * 打开`C:\Windows\System32\drivers\etc\hosts`文件
        * 追加写入刚刚的ip, 我这里的是`140.82.112.4` (可能会出现保存失败, 没有权限: 复制到桌面, 修改完后覆盖即可)
          ```bash
          github.com 140.82.112.4
          ```
     * MacOS
        *  写入ip, 我这里的是`140.82.112.4` (需要输入管理员密码)
          ```bash
          sudo vi /etc/hosts
          ```
          添加到末尾
          ```bash
          github.com 140.82.112.4
          ```
     * Ubuntu, centos
        * 写入ip, 我这里的是`140.82.112.4` (需要输入管理员密码)
          ```bash
          sudo echo "github.com 140.82.112.4" >> /etc/hosts
          ```
     * debian 和一些没有 `sudo` 的系统
        *  写入ip, 我这里的是`140.82.112.4` (需要输入管理员密码)
          ```bash
          su vi /etc/hosts
          ```
          添加到末尾
          ```bash
          github.com 140.82.112.4
          ```

3. (不推荐) 各类游戏加速器

   原理跟前两种差不多, 这里就不过多介绍了, 可用性玄学

4. (最推荐) 魔法上网, 科学上网
    
    自行 `baidu、google、bing`再多说一点就违规了, 参考司法解释: [最高人民法院关于审理扰乱电信市场管理秩序案件具体应用法律若干问题的解释](http://jxgy.jxfy.gov.cn/article/detail/2011/05/id/2200762.shtml)