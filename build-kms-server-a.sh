#!/bin/sh
set -e
#description: Build Docker Container script by yygfml <yygfml@163.com>

# git clone vlmcsd
cd /tmp/ && git clone https://github.com/Wind4/vlmcsd.git
cd vlmcsd && make
mkdir /tmp/docker-kms
cd bin && mv vlmcsd /tmp/docker-kms
cd /tmp/docker-kms && rm -rf /tmp/vlmcsd

# create Dockerfile Script
if [ ! -e Dockerfile ]; then
tee >Dockerfile << 'EOF'
  FROM alpine:latest
  MAINTAINER yygfml yygfml@163.com
  WORKDIR /docker-kms
  ONBUILD COPY vlmcsd /docker-kms
  EXPOSE 1688
  CMD /docker-kms/vlmcsd -L 0.0.0.0:1688 -e -D
EOF
fi

# build kms-server:latest container
docker build -t kms-server:latest .
# push kms-server container
#docker push kms-server:latest
#docker run -d kms-server:latest
docker run -d -p 1688:1688 --restart=always --name kms kms-server

#clear tmp file
cd ~ && rm -rf /tmp/docker-kms
