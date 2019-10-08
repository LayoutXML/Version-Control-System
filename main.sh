#!/bin/bash

#consts - case names
doAction() {
	case $1 in
		access)
			cd $filename
			pwd
			;;
		list)
			ls
			;;
	esac 
}

loadConfig() {
	cd $HOME
	if [ -f "$configFile" ]
	cd $currentDir
}

saveConfig() {
	cd $HOME
	echo $currentDir >> $configFile
	if [ -z "$repos" ]
		for i in "$repos"; do
			$repos[i] > $configFile 
		done
	fi
	cd $currentDir
}

currentDir=$HOME
configFile="jet.cfg"

if [ $# -eq 0 ]; then
	echo "Invalid number of arguments"
fi
