---
title: hexo博客docker部署——主题美化
date: 2022-01-23 11:24:56
id: 1643513096
tags:
  - docker
  - hexo
categories:
  - 教程
keywords: hexo,docker
description: hexo个人博客docker搭建(2)
---

#### 主题介绍

这里使用的是DIYgod的hexo-theme-sagiri主题

github: [https://github.com/DIYgod/hexo-theme-sagiri](https://github.com/DIYgod/hexo-theme-sagiri)

DIYgod: [https://diygod.me/2020/#more](https://diygod.me/2020/#more)


#### 需要补充的包
```bash
npm install hexo-renderer-swig \
&& npm install nprogress \
&& npm install hexo-tag-aplayer \
&& npm install zoom-image \
&& npm install disqusjs \
```

#### 配置主题
克隆主题
```bash
cd themes
git clone https://github.com/DIYgod/hexo-theme-sagiri.git

cd hexo-theme-sagiri
```
修改sagiri的小bug

修改**hexo-theme-sagiri/source/css/main.styl**文件
```bash
// Custom Layer
// --------------------------------------------------
@import "_custom/custom";
         
// @import "../../node_modules/nprogress/nprogress.css"
@import "../../../node_modules/nprogress/nprogress.css"
```
回到hexo目录
```bash
# 清理
hexo clean
# 编译
hexo g
# 查看效果
hexo s
```