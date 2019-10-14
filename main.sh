#!/bin/bash


currentDir=$HOME
configFile="jet.cfg"
logFile="log.txt"

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

#repositories - array, initialised in config reading
#openRepoIndex - index of currently open repository

if [ $# -eq 0 ]; then
	echo "Invalid number of arguments"
fi
