#!/bin/bash

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
}

saveConfig() {
	cd $HOME
	echo $currentDir >> $configFile
	if [ -z "$repos" ]
		for i in "$repos"; do
			$repos[i] > $configFile 
		done
	fi
}

#repositories - array of repository names, initialised during config reading
#repositoryPaths - array of repostiroy paths from home folder, initialised during config reading
#openRepoIndex - index of currently open repository

if [ $# -eq 0 ]; then
	echo "Invalid number of arguments"
fi

createRepository () {
	#assumptions: $1 is a path to the repository, $2 is a repository name
	cd $1
	mkdir .${2}
	mkdir .${2}/${stagingFolder}
	repositories[${#repositories[@]}]=$2
	repositoryPaths[${#repositoryPaths[@]}]=$1
}

createLogFile () {
	#assumptions: $1 is a repository index
	cd $HOME
	cd .${repositoryPaths[$1]}/${repositories[$1]}
	touch ${logFile}
}
