#/bin/bash

cd /usr/blog
pm2 start run.js >> /usr/blog/log/pm2/pm2`date +\%Y\%m\%d\%H\%M\%S`.log
