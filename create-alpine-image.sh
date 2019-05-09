
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

if [ -f '/etc/init.d/vlmcsd' ]; then
  echo 'VLMCSD service has been installed.'
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

GIT_TAG=svn1112
TMP_DIR=`mktemp -d`
cd ${TMP_DIR}
echo 'Downloading vlmcsd ...'
wget -q https://github.com/Wind4/vlmcsd/releases/download/${GIT_TAG}/binaries.tar.gz -O binaries.tar.gz
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
