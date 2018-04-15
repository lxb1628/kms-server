#!/bin/sh
#description: Build Docker Container script by lxb1628 <lxb1628@163.com>

# create Dockerfile Script
mkdir /tmp/docker-kms/ && cd /tmp/docker-kms/
if [ ! -e Dockerfile ]; then 
  cat >Dockerfile <<-'EOF'
  #第一行必须指令基于的基础镜像
  FROM centos
  #镜像的操作指令
  RUN cd /tmp/ && curl -L https://github.com/Wind4/vlmcsd/releases/download/svn1111/binaries.tar.gz | tar -zx
  RUN mv /tmp/binaries/Linux/intel/static/vlmcsdmulti-x64-musl-static /usr/local/bin/vlmcsdmulti-x64-musl-static
  RUN cd /usr/local/bin/ && chmod +x vlmcsdmulti-x64-musl-static
  RUN rm -rf /tmp/binaries
  #容器启动时执行指令
  CMD vlmcsdmulti-x64-musl-static vlmcsd -L 0.0.0.0:1688 -e -D
  #容器暴露端口
  EXPOSE 1688
  EOF
fi

# build kms-server:latest container
cd /tmp/docker-kms/
docker build -t kms-server:latest .
docker run -d kms-server:latest

# create docker-compose.yml Script
if [ ! -e docker-compose.yml ]; then
  cat >docker-compose.yml <<-'EOF'
  version "3.3"
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
