
#!/bin/sh
set -e
#description: Build Docker Container script by lxb1628 <lxb1628@163.com>

# git clone vlmcsd
cd /tmp/ && wget https://github.com/Wind4/vlmcsd/releases/download/svn1112/binaries.tar.gz
tar -xzvf binaries.tar.gz
mkdir /tmp/docker-kms
cd /tmp/binaries/Linux/intel/musl && mv vlmcsdmulti-x64-musl /tmp/docker-kms/vlmcsd
cd /tmp/docker-kms && rm -rf /tmp/vlmcsd/binaries

# create Dockerfile Script
if [ ! -e Dockerfile ]; then 
  tee >Dockerfile <<EOF
  FROM alpine:latest
  ADD vlmcsd /usr/local/bin/
  EXPOSE 1688
  CMD vlmcsd -L 0.0.0.0:1688 -e -D
EOF
fi

# build kms-server:latest container
docker build -t kms-server:latest .

#docker run -d kms-server:latest
docker run -d -p 1688:1688 --restart=always --name kms kms-server

#clear tmp file
cd ~ && rm -rf /tmp/docker-kms
