#!/bin/bash

docker stop hexo
docker rm hexo

docker run --name hexo -d -ti -p 4000:4000 -v /Volumes/data/git/gouzi-hexo:/usr/blog/ hexo-test:latest 