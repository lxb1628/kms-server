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

  #******************更换Alpine源为阿里云******************
  RUN echo "https://mirrors.aliyuncs.com/alpine/v3.8/main" /etc/apk/repositories && \
	  echo "https://mirrors.aliyuncs.com/alpine/v3.8/community" >> /etc/apk/repositories
  RUN apk update && apk upgrade
  #********Alpine安装 Glibc https://github.com/sgerrand/alpine-pkg-glibc **********
  RUN apk --no-cache add ca-certificates && \
      wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
	  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk && \
	  apk add glibc-2.28-r0.apk

  WORKDIR /vlmcsd
  ONBUILD COPY vlmcsd /vlmcsd/
  EXPOSE 1688
  CMD /vlmcsd/vlmcsd -L 0.0.0.0:1688 -e -D
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
