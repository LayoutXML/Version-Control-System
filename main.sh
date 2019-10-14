#!/bin/bash

currentDir=$HOME
configFile="jet.cfg"
logFile="log.txt"
stagingFolder="staging"


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

printMenu() {
	echo "Jet Version Control"
	echo "jethelp - prints this menu"
	echo "access [x]- change your current working directory to x"
	echo "list - lists all files in the current working directory"
	echo "Enter a command to get started."
	echo "-------------------------------------------------------" 
}

readMenuOptions() {
	local option
	read option
	case $option in
		jethelp)
			printMenu ;;
		access)
			doAction access ;;
		list)
			doAction list ;;
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

moveToStagingFolder () {
	#assumptions: in the rep folder , $1 is a file name
	cp $1 /.$repositories[$openRepoIndex]/$stagingFolder/$1
	if [ $? -ne 0 ]; then
		echo "Cannot move to the staging folder."
	fi		
}	

moveFromStagingFolder () {
	cd /.$repositories[$openRepoIndex]/$stagingFolder
	rm $1
	if [ $? -ne 0 ]; then
		echo "Cannot move from the staging folder."
	fi
	cd ../..
}

clearStagingFolder () {
	cd /.$repositories[$openRepoIndex]/$stagingFolder
	for i in $(ls); do
		moveFromStagingFolder $i 
	done
}
