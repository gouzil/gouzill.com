#!/bin/bash

# dev
# docker build -t hexo-test:latest .

# build online
docker build -f Dockerfile-runner -t hexo-runner:latest .