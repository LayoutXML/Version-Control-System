#!/bin/bash

configFile="jet.cfg"
logFile="log.txt"
stagingFolder="staging"

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
	cd .${repositoryPaths[$1]}/${repositories[$1]}
	ls
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

printMenu () {
	echo "Jet Version Control"
	echo "jethelp - prints this menu"
	echo "create - creates a new repository"
	echo "access [x]- change your current working directory to x"
	echo "list - lists all files in the current working directory"
	echo "loadconfig - loads configuration file"
	echo "saveconfig - saves configuration file"
	echo "log - creates a new log file"
	echo "stage - moves file to staging folder"
	echo "unstage - moves a file from the staging folder"
	echo "stageclear - clears out the staging folder"

	echo "exit - exits Jet"
	echo "-------------------------------------------------------"

	PS3 = "Enter a command:"
	select option in jethelp create access list loadconfig saveconfig log stage unstage stageclear exit
	do
		case $option in
			jethelp) 
				printMenu ;;
			create)
				createRepository ;;
			access)
				doAction ;;
			list)
				listFiles ;;
			loadconfig)
				loadConfig ;;
			saveconfig)
				saveConfig ;;
			log)
				createLogFile ;;
			stage)
				moveToStagingFolder ;;
			unstage)
				moveFromStagingFolder ;;
			stageclear)
				clearStagingFolder ;;
			exit)
				exit ;;
		esac
	done
}
