#!/bin/sh
set -e
#description: Build Docker Container script by lxb1628 <lxb1628@163.com>
#
#Some Scripts Copyed by Wind4
#

check_result() {
  if [ $1 -ne 0 ]; then
    echo "Error: $2" >&2
    exit $1
  fi
}

if [ "x$(id -u)" != 'x0' ]; then
  echo 'Error: This script can only be executed by root'
  exit 1
fi

if [ ! -f '/bin/tar' ]; then
  echo 'Installing tar ...'
  yum -q -y install tar
  check_result $? "Can't install tar."
  echo 'Install tar succeed.'
fi

if [ ! -f '/usr/bin/wget' ]; then
  echo 'Installing wget ...'
  yum -q -y install wget
  check_result $? "Can't install wget."
  echo 'Install wget succeed.'
fi

if [ ! -f '/sbin/service' ]; then
  echo 'Installing initscripts ...'
  yum -q -y install initscripts
  check_result $? "Can't install initscripts."
  echo 'Install initscripts succeed.'
fi
# prepare the download URL
GIT_TAG=$(curl -L -s -H 'Accept: application/json' https://github.com/Wind4/vlmcsd/releases/latest | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
TMP_DIR=`mktemp -d`
cd ${TMP_DIR}
echo 'Downloading vlmcsd ...'
curl -sSL https://github.com/Wind4/vlmcsd/releases/download/${GIT_TAG}/binaries.tar.gz -o binaries.tar.gz
check_result $? 'Download vlmcsd failed.'

echo 'Extract vlmcsd ...'
tar -xzvf binaries.tar.gz
Work_DIR=/tmp/docker-kms
mkdir ${Work_DIR}
cp binaries/Linux/intel/musl/vlmcsdmulti-x64-musl ${Work_DIR}/vlmcsd

echo 'Create Docker Image ...'
cd ${Work_DIR}
# create Dockerfile Script
if [ ! -e Dockerfile ]; then 
  cat >Dockerfile <<-'EOF'
  # base image
  FROM alpine:latest as builder
  # MAINTAINER
  MAINTAINER yygfml<yygfml@163.com>
  WORKDIR /root
  RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
  RUN apk update && apk upgrade
  RUN apk add --no-cache git make build-base && \
    git clone --branch master --single-branch https://github.com/Wind4/vlmcsd.git && \
    cd vlmcsd/ && \
    make
  
  FROM alpine:latest
  WORKDIR /root/
  # put vlmcsd into /usr/local/bin
  COPY --from=builder /root/vlmcsd/bin/vlmcsd /usr/bin/vlmcsd
  EXPOSE 1688/tcp
  # execute command to compile vlmcsd
  CMD [ "/usr/bin/vlmcsd", "-D", "-d" ]
EOF
fi

# build kms-server:latest container
docker build -t kms-server:latest .

#docker run -d kms-server:latest
docker run -d -p 1688:1688 --restart=always --name kms kms-server

echo 'Cleaning ...'
cd ~
rm -rf ${TMP_DIR}
rm -rf ${Work_DIR}
docker rmi $(docker images | grep "^<none>" | awk "{print $3}") 

echo 'Installed successfully.'
