#!/bin/bash

configFile="jet.cfg"
logFile="log.txt"
stagingFolder="staging"

printMenu () {
	echo "Jet Version Control"
	echo "jethelp - prints this menu"
	echo "access [x]- change your current working directory to x"
	echo "list - lists all files in the current working directory"
	echo "Enter a command to get started."
	echo "-------------------------------------------------------" 
}

readMenuOptions () {
	local option
	read option
	case $option in
		jethelp)
			printMenu ;;
		access)
			doAction access ;;
		list)
			listFiles ;;
        	zip)
            		zipRep ;;
        	archive)
            		archiveRep ;;
	esac
}

loadConfig () {
	cd $HOME
	if [ -f "$configFile" ]
}

saveConfig () {
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

listFiles () {
    #assumptions: $1 is a repository index
	cd $HOME
	cd ./${repositoryPaths[$1]}
	ls
}

zipRep () {
	#assumptions: $1 is a repository index
	cd $HOME
	zip -r ${repositories[$1]}.zip ./${repositoryPaths[$1]}
}

archiveRep () {
	#assumptions: $1 is a repository index
	cd $HOME
	tar -cvf ${repositories[$1]}.tar ./${repositoryPaths[$1]}
}

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
