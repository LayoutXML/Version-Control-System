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
	echo -e "${3}\t${2}" >> ${logFile}
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

editFile () {
	#assumptions: $1 is a filename, $2 repository index
	cd $HOME
	cd ./${repositoryPaths[$2]}
	xdg-open $1
}

moveToStagingFolder () {
	#assumptions: in the rep folder , $1 is a file name, $2 rep index
	cd $HOME
	cd ./${repositoryPaths[$2]}
	cp -r ${1} ./.${repositories[$2]}/${stagingFolder}/
	if [ $? -ne 0 ]; then
		echo "Cannot move to the staging folder."
	fi		
}	

moveFromStagingFolder () {
	#$1 filename, $2 rep index
	cd $HOME
	cd ./${repositoryPaths[$2]}/.${repositories[$2]}/${stagingFolder}
	rm -r $1
	if [ $? -ne 0 ]; then
		echo "Cannot move from the staging folder."
	fi
}

clearStagingFolder () {
	#$1 rep index
	cd $HOME
	cd ./${repositoryPaths[$1]}/.${repositories[$1]}/${stagingFolder}
	for i in *; do
		rm -r $i
	done
}

printRepos () {
	for i in ${!repositories[@]}; do
		echo -e "${repositories[$i]}\t${repositoryPaths[$i]}"
  	done
}

printCommits () {
	#$1 rep index
	cd $HOME
	cd ./${repositoryPaths[$1]}/.${repositories[$1]}/
	for i in *; do
		if [ "$i" != $stagingFolder ] && [ "$i" != $logFile ]; then
			echo "$i"
		fi
	done
}

test () {
}

printMenu () {
	echo -e "Jet Version Control"
	echo -e "--help\t\tprints this menu"
	echo -e "make\t\tcreates a new repository"
	echo -e "repos\t\tprint all repositories"
	echo -e "list\t\tlists all files in the current working directory"
	echo -e "edit\t\tedit a file in an external editor"
	echo -e "stage\t\tmoves file to staging folder"
	echo -e "unstaget\tmoves a file from the staging folder"
	echo -e "stageclear\tclears out the staging folder"
	echo -e "commit\t\tmake a commit"
	echo -e "revert\trevert a commit"
	echo -e "commits\t\tprints a list of existing commits"
	echo -e "zip\t\zip a repository"
	echo -e "exit\t\texits Jet"
}

doAction () {
	case $1 in
		--help) 
			printMenu ;;
		make)
			createRepository $3 $2
			createLogFile $(findRepoIndex $2) ;;
		repos)
			printRepos ;;
		list)
			listFiles $(findRepoIndex $2) ;;
		edit)
			editFile $3 $(findRepoIndex $2) ;;
		stage)
			moveToStagingFolder $3 $(findRepoIndex $2) ;;
		unstage)
			moveFromStagingFolder $3 $(findRepoIndex $2) ;;
		stageclear)
			clearStagingFolder $(findRepoIndex $2) ;;
		commit)
			makeCommit $3 $(findRepoIndex $2) ;;
		revert)
			revertCommit $3 $(findRepoIndex $2) ;;
		commits)
			printCommits $(findRepoIndex $2) ;;
		zip)
			zipRep $(findRepoIndex $2) ;;
		test)
			test ;;
		*)
			echo "Error, unknown command" ;;
	esac
}

findRepoIndex () {
	# shopt -s nocasematch
	for i in ${!repositories[@]}; do
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
	for i in *; do
		if [ "$i" != .$repositories[$2] ]; then
			rm -r "$i"
		fi
	done
	cd ./.${repositories[$2]}/$1
	for i in *; do
		cp -r "$i" ../..
	done
}

makeCommit () {
	#assumptions: $2 is a repository index, $1 is a commit message
	local timestamp=$(date +%s)
	cd $HOME
	cd ./${repositoryPaths[$2]}/.${repositories[$2]}
	if [ $(ls -1q ./${stagingFolder} | wc -l) -gt 0 ]; then
		addCommitToLogFile $2 $1 $timestamp
		mkdir $timestamp
		mv ./${stagingFolder}/* ./$timestamp
	else
		echo "No files have been staged yet."
	fi
}

# Validation
if [ $# -eq 0 ]; then
	echo "Invalid number of arguments"
fi

#$1 - command name
#$2 - repository name (not case sensitive)
#$3... - function arguments

loadConfig
doAction "$@"
saveConfig
if ! [ -z $2 ] && [ $1 != "list" ]; then
	echo Files:
	listFiles $(findRepoIndex $2)
fi
