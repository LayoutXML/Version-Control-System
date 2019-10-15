#!/bin/bash

configFile="jet.cfg"
logFile="log.txt"
stagingFolder="staging"
#repositories - array of repository names, initialised during config reading
#repositoryPaths - array of repostiroy paths from home folder, initialised during config reading

loadConfig () {
	cd $HOME
	if [ -f "$configFile" ]; then
		#repositoryName
		#repositoryPath (relative path, from $HOME)
		odd=true
		while read line; do
			if [ $odd = true ]; then
				repositories[${#repositories[@]}]=$line
				odd=false
			else
				repositoryPaths[${#repositoryPaths[@]}]=$line
				odd=true
			fi
		done < $configFile
	fi
}

saveConfig () {
	cd $HOME
	rm $configFile
		touch $configFile 
		for i in ${!repositories[@]}; do
		# if [[ $repositories[$i] == $1 ]]; then
			echo ${repositories[$i]} >> $configFile
			echo ${repositoryPaths[$i]} >> $configFile
		done
}

createRepository () {
	#assumptions: $1 is a path to the repository, $2 is a repository name
	cd $HOME
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
	echo "${3} ${2}" >> ${logFile}
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
	zip -r ./${repositoryPaths[$1]}/${repositories[$1]}.zip ./${repositoryPaths[$1]}
}

moveToStagingFolder () {
	#assumptions: in the rep folder , $1 is a file name, $2 rep index
	cd $HOME
	cd ./${repositoryPaths[$2]}
	cp ${1} ./.${repositories[$2]}/${stagingFolder}/${1}
	if [ $? -ne 0 ]; then
		echo "Cannot move to the staging folder."
	fi		
}	

moveFromStagingFolder () {
	#$1 filename, $2 rep index
	cd $HOME
	cd ./${repositoryPaths[$2]}/.${repositories[$2]}/${stagingFolder}
	rm $1
	if [ $? -ne 0 ]; then
		echo "Cannot move from the staging folder."
	fi
	cd ../..
}

clearStagingFolder () {
	#$1 rep index
	cd /.$repositories[$1]/$stagingFolder
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
	#echo "-------------------------------------------------------"

	#PS3 = "Enter a command:"
	
}

doAction () {
		case $1 in
			--help) 
				printMenu ;;
			create|make)
				createRepository $3 $2
				createLogFile $(findRepoIndex $2) ;;
			list)
				listFiles $(findRepoIndex $2) ;;
			stage|add)
				moveToStagingFolder $3 $(findRepoIndex $2) ;;
			unstage|reset)
				moveFromStagingFolder $3 $(findRepoIndex $2) ;;
			stageclear|resetall)
				clearStagingFolder $(findRepoIndex $2) ;;
			commit)
				makeCommit $3 $(findRepoIndex $2) ;;
			revert)
				revertCommit $3 $(findRepoIndex $2) ;;
			zip)
				zipRep $(findRepoIndex $2);;
			*)
				echo "Unknown command" ;;
		esac
}

#findRepo () {
#	echo "Enter the name of repository you'd like to find:"
#	read repo
#	if[ -d $repo ]
#		echo "Repository $repo exists"
#	else
#		echo "Repository $repo wasn't found in the current directory"
#	fi
#}

findRepoIndex () {
	# shopt -s nocasematch
	for i in ${!repositories[@]}; do
		# if [[ $repositories[$i] == $1 ]]; then
		if [ ${repositories[$i]} = $1 ]; then
			echo $i
		fi
	done
}

revertCommit () {
	#assumptions: $2 is a repository index, $1 is a commit timestamp
	local timestamp=$(date +%s)
	addCommitToLogFile $2 "Reverted commit $1" $timestamp
	cd $HOME
	cd ./${repositoryPaths[$2]}
	for i in $(ls); do
		rm $i
	done
	cd ./.${repositories[$2]}/$1
	for i in $(ls); do
		mv $i ../..
	done
	cd ../..
	rm -r ./.${repositories[$2]}/$1
}

makeCommit () {
	#assumptions: $2 is a repository index, $1 is a commit message
	local timestamp=$(date +%s)
	addCommitToLogFile $2 $1 $timestamp
	cd $HOME
	cd ./${repositoryPaths[$2]}/.${repositories[$2]}
	mkdir $timestamp
	mv ./${stagingFolder}/* ./$timestamp
}

if [ $# -eq 0 ]; then
	echo "Invalid number of arguments"
fi

#$1 - command name
#$2 - repository name (not case sensitive)
#$3... - function arguments
loadConfig
doAction "$@"
saveConfig
