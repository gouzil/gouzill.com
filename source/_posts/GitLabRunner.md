---
title: GitLabRunner
date: 2022-06-13 23:19:15
tags:
  - gitlab
  - gitlab-runner
keywords: gitlab-runner,gitlab
description: 使用docker搭建hexo博客cicd环境实现自动部署
---

#### docker 部署

```dockerfile
FROM node:15.7.0-alpine3.10

WORKDIR /usr/blog

RUN chmod 777 /usr/blog
# 切换中科大源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
# 安装bash git openssh 以及c的编译工具
RUN apk add bash git openssh curl openrc

# 安装gitrunner
RUN curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
RUN chmod +x /usr/local/bin/gitlab-runner
RUN adduser -D -h /home/gitlab-runner -s /bin/sh gitlab
RUN gitlab-runner install --user=gitlab --working-directory=/home/gitlab-runner
RUN echo "#!/bin/sh" >> /start.sh
RUN echo "gitlab-runner start" >> /start.sh

# 设置容器时区为上海，不然发布文章的时间是国际时间，也就是比我们晚8个小时
RUN apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone \
&& apk del tzdata

# 升级npm
RUN npm install -g npm@8.12.1
```

#### 启动gitlab-runner
REGISTRATION_TOKEN 根据 gitlab后台的来填写
```bash
#!/bin/bash
docker stop hexo-gitlab-runner
docker rm hexo-gitlab-runner

docker run -dit \
    --name hexo-gitlab-runner \
    -e REGISTRATION_TOKEN='******' \
    -v /docker/hexo-build/data/www:/usr/blog \
    -v /docker/hexo-build/data/config:/etc/gitlab-runner \
    --privileged=true \
    hexo-runner:latest
```

#### 注册runner
```bash
gitlab-runner register --url http://gitlab.gouzill.com/ --registration-token $REGISTRATION_TOKEN

# 一路回车
# 提示这个的时候写shell, 根据你的需求来
 Please enter the executor: ssh, docker+machine, docker-ssh+machine, kubernetes, docker, parallels, virtualbox, docker-ssh, shell:
shell
```

#### 运行runner
```bash
cd /
sh start.sh
```

#### 常见问题
如果出现信息提示`runner`但是网页提示没连接大概率是出现假死了

如果服务出现假死请删除`/var/run`下的`gitlab-runner.pid`文件