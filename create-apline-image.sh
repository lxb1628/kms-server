
#!/bin/sh
set -e
#description: Build Docker Container script by lxb1628 <lxb1628@163.com>

# git clone vlmcsd
cd /tmp/ && wget 
cd vlmcsd && make
mkdir /tmp/docker-kms
cd bin && mv vlmcsd /tmp/docker-kms
cd /tmp/docker-kms && rm -rf /tmp/vlmcsd

# create Dockerfile Script
if [ ! -e Dockerfile ]; then 
  cat >Dockerfile <<-'EOF'
  FROM centos:latest
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
