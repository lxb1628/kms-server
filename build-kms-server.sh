#!/bin/sh
set -e
#description: Build Docker Container script by lxb1628 <lxb1628@163.com>

# git clone vlmcsd
cd /tmp/ && git clone https://github.com/Wind4/vlmcsd.git
cd vlmcsd && make
mkdir /tmp/docker-kms
cd bin && mv vlmcsd /tmp/docker-kms
cd /tmp/docker-kms && rm -rf /tmp/vlmcsd

# create Dockerfile Script
if [ ! -e Dockerfile ]; then 
  cat >Dockerfile <<-'EOF'
  FROM centos:latest
  ADD vlmcsd /usr/local/bin/
  CMD vlmcsd -L 0.0.0.0:1688 -e -D
  EXPOSE 1688
EOF
fi

# build kms-server:latest container
docker build -t kms-server:latest .
# push kms-server container
#docker push kms-server:latest
docker run -d kms-server:latest
#docker run -d -p 1688:1688 --restart=always --name kms kms-server

# create docker-compose.yml Script
if [ ! -e docker-compose.yml ]; then
  cat >docker-compose.yml <<-'EOF'
  version: "3.3"
  services:
    kms:
      image: kms-server:latest
      restart: always
      ports:
        - "1688:1688"
EOF
fi

#up docker compose script
docker-compose up

#clear tmp file
cd ~ && rm -rf /tmp/docker-kms
