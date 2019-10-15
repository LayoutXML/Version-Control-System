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
	cd ./${repositoryPaths[$1]}/.${repositories[$1]}
	touch ${logFile}
}

addCommitToLogFile () {
	#assumptions: $1 is a repository index, $2 is a commit message, $3 is timestamp, log file exists
	cd $HOME
	cd ./${repositoryPaths[$1]}/.${repositories[$1]}
	echo "${3} ${2}" > ${logFile}
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

findRepo () {
	echo "Enter the name of repository you'd like to find:"
	read repo
	if[ -d $repo ]
		echo "Repository $repo exists"
	else
		echo "Repository $repo wasn't found in the current directory"
	fi
}

reverseCommit () {
	#assumptions: $1 is a repository index, $2 is a commit timestamp
	local timestamp=$(date +%s)
	addCommitToLogFile "$1" "Reversed commit $2" "$timestamp"
	cd $HOME
	cd ./${repositoryPaths[$1]}
	for i in $(ls); do
		if [ i -ne ${repositories[$1]} ]
			rm i
		fi
	done
	mv ./.${repositories[$1]}/$2 ./
	rm -r ./.${repositories[$1]}/$2
}

makeCommit () {
	#assumptions: $1 is a repository index, $2 is a commit message
	local timestamp=$(date +%s)
	addCommitToLogFile "$1" "$2" "$timestamp"
	cd $HOME
	cd ./${repositoryPaths[$1]}/.${repositories[$1]}
	mkdir $timestamp
	mv ./${stagingFolder}/* ./$timestamp
}
