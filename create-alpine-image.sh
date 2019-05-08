
#!/bin/sh
set -e
#description: Build Docker Container script by lxb1628 <lxb1628@163.com>
#
#Some Scripts Copyed by Wind4
#

TMP_DIR=`mktemp -d`
GIT_TAG=svn1112
cd ${TMP_DIR}

echo 'Downloading vlmcsd ...'
wget -q https://github.com/Wind4/vlmcsd/releases/download/${GIT_TAG}/binaries.tar.gz -O binaries.tar.gz
check_result $? 'Download vlmcsd failed.'

echo 'Extract vlmcsd ...'
tar -xzvf binaries.tar.gz
mkdir /tmp/docker-kms
Work_DIR=`mktemp -d`
cp binaries/Linux/intel/musl/vlmcsdmulti-x64-musl ${Work_DIR}/vlmcsd

echo 'Create Docker Image ...'
cd ${Work_DIR}
# create Dockerfile Script
if [ ! -e Dockerfile ]; then 
  cat >Dockerfile <<-'EOF'
  # base image
  FROM alpine:latest
  
  # MAINTAINER
  MAINTAINER yygfml<yygfml@163.com>
  
  # put vlmcsd into /usr/local/bin
  ADD vlmcsd /usr/local/bin
  
  # execute command to compile vlmcsd
  CMD vlmcsd -L 0.0.0.0:1688 -e -D
  EXPOSE 1688
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

echo 'Installed successfully.'
