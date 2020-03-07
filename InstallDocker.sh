#!/bin/sh
set -e
function echogr {
	echo -e \\033[32m$@\\033[0m
}
function echoye {
	echo -e \\033[33m$@\\033[0m
}

#description: Install Docker script by lxb1628 <lxb1628@163.com>

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear
do_Install(){
    yum install -y yum-utils
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
	yum install -y device-mapper-persistent-data lvm2 curl docker-ce
	systemctl enable docker
	systemctl start docker
	curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	clear
	echogr "Succeeded."
}
echogr "This script will automatically download and compile Docker program for you."
echogr "For more information, please visit https://github.com/docker"
echogr "Scrpit written by lxb1628 <lxb1628@163.com>"
echogr "READY TO START?"
read -p "y/n:" choice
case $choice in
	"y")
	do_Install
	;;
	"n")
	exit 0;
	;;
	*)
	echoye "Please enter y or n!"
	;;
esac
