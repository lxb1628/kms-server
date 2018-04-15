#!/bin/sh

#description: Install Docker script by lxb1628 <lxb1628@163.com>

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
do_start(){
	yum install -y yum-utils device-mapper-persistent-data lvm2 curl
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install -y docker-ce
	systemctl enable docker
	systemctl start docker
	curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	clear
	echo "Succeeded."
}
echo "This script will automatically download and compile Docker program for you."
echo "For more information, please visit https://github.com/docker"
echo "Scrpit written by lxb1628 <lxb1628@163.com>"
echo "READY TO START?"
read -p "y/n:" choice
case $choice in
	"y")
	do_start
	;;
	"n")
	exit 0;
	;;
	*)
	echo "Please enter y or n!"
	;;
esac
