#!/bin/bash

action=$1
filename=$2

#consts - case names

if [ $# -eq 0 ]; then
	echo "Invalid number of arguments"
fi

case $action in
	access)
		cd $filename
		pwd
		;;
	list)
		ls
		;;
esac 
	

validate() {
}

doAction() {
}

loadConfig() {
}

saveConfig() {
}

