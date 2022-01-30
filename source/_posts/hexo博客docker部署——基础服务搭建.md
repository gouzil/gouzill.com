---
title: hexo博客docker部署——基础服务搭建
date: 2022-01-20 19:56:07
id: 1643457367
tags:
  - docker
  - hexo
categories:
  - 博客
keywords: hexo,docker
description: hexo个人博客docker搭建(1)
---

### 使用dockerfile构建镜像

```Dockerfile
FROM node:15.7.0-alpine3.10

WORKDIR /usr/blog

# 切换中科大源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
# 安装bash git openssh 以及c的编译工具
RUN apk add bash git openssh

# 设置容器时区为上海，不然发布文章的时间是国际时间，也就是比我们晚8个小时
RUN apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& apk del tzdata

# 安装hexo和一些扩展
RUN \ 
npm config set registry https://registry.npm.taobao.org \
&& npm install \
&& npm install hexo-cli -g \
&& npm install hexo-server --save \
&& npm install hexo-asset-image --save \
&& npm install hexo-wordcount --save \
&& npm install hexo-generator-sitemap --save \
&& npm install hexo-generator-baidu-sitemap --save \
&& npm install hexo-deployer-git --save \
&& npm install hexo-renderer-swig --save \
&& npm install nprogress --save \
&& npm install hexo-tag-aplayer --save \
&& npm install zoom-image --save \
&& npm install disqusjs --save \
&& npm install pm2 -g

EXPOSE 4000
```

### 构建镜像

```bash
docker build -t hexo-local:latest .
```

### 启动镜像
将容器内的/usr/blog映射到本地/docker/hexo/data
```bash
docker run --name hexo -d -ti -p 4000:4000 -v /docker/hexo/data:/usr/blog/ hexo-local:latest 
```

### 编译静态文件
```bash
hexo g -d
```

### 启动服务
```bash
hexo s
```

### 后台启动
```bash
# 在博客根目录下编辑run.js
vi run.js

const { exec } = require('child_process')
exec('hexo server -p 4000 >> /usr/blog/log/hexo/hexo`date +\%Y\%m\%d\%H\%M\%S`.log',(error, stdout, stderr) => {
if(error){
        console.log('exec error: ${error}')
        return
}
console.log('stdout: ${stdout}');
console.log('stderr: ${stderr}');
})
```
运行脚本
```bash
pm2 start run.js
```

### 停止hexo
```bash
# 此命令会停止所有pm2后台服务
pm2 stop all
```

可能会遇到停止后服务依旧启动, 使用kill命令杀进程

```bash
bash-5.0# top

Mem: 7830572K used, 158948K free, 23836K shrd, 128K buff, 3165012K cached
CPU:   0% usr   0% sys   0% nic  50% idle  43% io   0% irq   6% sirq
Load average: 2.29 1.34 0.93 2/927 1526
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
 1505  1494 root     S     341m   4%   0   0% {node} hexo
  447     0 root     S     288m   4%   0   0% {node} PM2 v5.1.2: God Daemon (/root/.pm2)
 1494   447 root     S     280m   4%   1   0% node /usr/blog/run.js
    1     0 root     S     275m   3%   0   0% node
 1521     0 root     S     2404   0%   1   0% bash
  331     0 root     S     2392   0%   1   0% bash
 1526  1521 root     R     1548   0%   1   0% top

bash-5.0# kill 1505
```


Hexo的源文件说明：

1、_config.yml站点的配置文件，需要拷贝；

2、themes/主题文件夹，需要拷贝；

3、source博客文章的.md文件，需要拷贝；

4、scaffolds/文章的模板，需要拷贝；

5、package.json安装包的名称，需要拷贝；

6、.gitignore限定在push时哪些文件可以忽略，需要拷贝；

7、.git/主题和站点都有，标志这是一个git项目，不需要拷贝；

8、node_modules/是安装包的目录，在执行npm install的时候会重新生成，不需要拷贝；

9、public是hexo g生成的静态网页，不需要拷贝；

10、.deploy_git同上，hexo g也会生成，不需要拷贝；

11、db.json文件，不需要拷贝。
