#!/bin/bash

configFile="jet.cfg"
logFile="log.txt"
stagingFolder="staging"
backupFolder="backup"
#repositories - array of repository names, initialised during config reading
#repositoryPaths - array of repository paths from home folder, initialised during config reading

loadConfig () {
	cd $HOME
	if [ -f "$configFile" ]; then
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
		if [ "${repositories[$i]}" != "" ]; then
			echo "${repositories[$i]}" >> $configFile
		fi
		if [ "${repositoryPaths[$i]}" != "" ]; then
			echo "${repositoryPaths[$i]}" >> $configFile
		fi
	done
}

createRepository () {
	#assumptions: $1 is a path to the repository, $2 is a repository name
	cd $HOME
	if [ -d ${1} ]; then
		cd $1
		mkdir .${2}
	else
		echo "The path to the new Repository is invalid. Creating new pathway..."
		mkdir -p $1/.$2
		cd $1
	fi
	mkdir .${2}/${stagingFolder}
	repositories[${#repositories[@]}]="$2"
	repositoryPaths[${#repositoryPaths[@]}]="$1"
}

deleteRepository () {
	#assumptions: $1 is a repository name, $2 is a repository index
	cd $HOME
	if [ -d "${repositoryPaths[$2]}" ]; then
		rm -r "${repositoryPaths[$2]}"
		repositories[$2]=""
		repositoryPaths[$2]=""
	else
		echo "The repository you're trying to delete doesn't exist"
	fi
}

createLogFile () {
	#assumptions: $1 is a repository index
	cd $HOME
	cd "./${repositoryPaths[$1]}/.${repositories[$1]}"
	touch ${logFile}
}

createNewFile () {
	#assumptions: $1 is a filename, $2 repository index
	cd $HOME
	cd "./${repositoryPaths[$2]}"
	if [[ "$1" == *"/"* ]]; then
		mkdir -p "${1%/*}" && touch "$1"
	else 
		touch "$1"
	fi
	moveToStagingFolder $1 $2
}

deleteFile () {
	#assumptions: $1 is a filename, $2 repository index
	cd $HOME
	cd "./${repositoryPaths[$2]}"
	rm -r "$1"
	moveFromStagingFolder $1 $2
}

addCommitToLogFile () {
	#assumptions: $1 is a repository index, $2 is a commit message, $3 is date, $4 is commit timestamp (optional), log file exists
	cd $HOME
	cd ./${repositoryPaths[$1]}/.${repositories[$1]}
	echo -e "${3}\t${2}\t$(whoami)\t${4}" >> ${logFile}
}

listFiles () {
  	#assumptions: $1 is a repository index
	cd $HOME
  	if [ -d "${repositoryPaths[$1]}" ]; then
		cd "./${repositoryPaths[$1]}"
		ls
	else
		echo "The repository you're trying to list files from doesn't exist"
	fi
}

zipRep () {
	#assumptions: $1 is a repository index
	cd $HOME
	if [ -d ${repositoryPaths[$1]} ]; then
		zip -r ./${repositoryPaths[$1]}/${repositories[$1]}.zip ./${repositoryPaths[$1]}
	else
		echo "The repository you're trying to compress doesn't exist"
	fi
}

editFile () {
	#assumptions: $1 is a filename, $2 repository index
	cd $HOME
	if [ -d "${repositoryPaths[$2]}" ]; then
		cd "./${repositoryPaths[$2]}"
		if [ -f $1 ]; then
			xdg-open $1
		else
			echo "The file you're trying to open doesn't exist"
		fi
	else
		echo "The repository you're trying to access a file from doesn't exist"
	fi
}

moveToStagingFolder () {
	#assumptions: $1 is a file name, $2 rep index
	cd $HOME
	if [ -d "${repositoryPaths[$2]}" ]; then
		cd "./${repositoryPaths[$2]}"
		if [ -f "$1" ]; then
			cp -r ${1} ./.${repositories[$2]}/${stagingFolder}/
		else
			echo "The file you're trying to stage doesn't exist"
		fi
		if [ $? -ne 0 ]; then
			echo "Cannot move to the staging folder."
		fi	
	else
		echo "The repository you're trying to stage a file from doesn't exist"
	fi
}	

moveAllToStagingFolder () {
	#assumptions: $1 rep index
	cd $HOME
	cd "./${repositoryPaths[$1]}"
	for i in *; do
		if [ "$i" != "*" ]; then
			cp -r "$i" "./.${repositories[$1]}/${stagingFolder}/"
		fi
	done
}

moveFromStagingFolder () {
	#$1 filename, $2 rep index
	cd $HOME
	if [ -d ${repositoryPaths[$2]} ]; then
		cd ./${repositoryPaths[$2]}/.${repositories[$2]}/${stagingFolder}
		if [ -f $1 ]; then
			rm -r $1
		else
			echo "The file you're trying to remove from the staging area doesn't exist"
		fi
		if [ $? -ne 0 ]; then
			echo "Cannot move from the staging folder."
		fi
	else
		echo "The repository you're trying move a file to doesn't exist"
	fi
}

clearStagingFolder () {
	#$1 rep index
	cd $HOME
	if [ -d ${repositoryPaths[$1]} ]; then
		cd ./${repositoryPaths[$1]}/.${repositories[$1]}/${stagingFolder}
		for i in *; do
			if [ "$i" != "*" ]; then
				rm -r "$i"
			fi
		done
	else
		echo "The staging area you're trying to clear doesn't exist"
	fi
}

printRepos () {
	for i in ${!repositories[@]}; do
		echo -e "${repositories[$i]}\t${repositoryPaths[$i]}"
  	done
}

printCommits () {
	#$1 rep index
	cd $HOME
	if [ -d $1 ]; then
		cd ./${repositoryPaths[$1]}/.${repositories[$1]}/
		for i in *; do
			if [ "$i" != $stagingFolder ] && [ "$i" != $logFile ] && [ "$i" != "*" ]; then
				echo "$i"
			fi
		done
	else
		echo "The repository you're trying to print commits from doesn't exist"
	fi
}

printMenu () {
	echo -e "\n\t\tJet Version Control"
	echo -e "Enter \"./main.sh\" followed by any command below to get started."
	echo -e "\n--help\t\tprints this help menu again"
	echo -e "make\t\tcreates a new repository"
	echo -e "delete\t\tdeletes a repository"
	echo -e "repos\t\tprint all repositories"
	echo -e "list\t\tlists all files in the current working directory"
	echo -e "edit\t\tedit a file in an external editor"
	echo -e "stage\t\tmoves file to staging folder"
	echo -e "unstaget\tmoves a file from the staging folder"
	echo -e "stageclear\tclears out the staging folder"
	echo -e "commit\t\tmake a commit"
	echo -e "revert\t\trevert a commit"
	echo -e "commits\t\tprints a list of existing commits"
	echo -e "zip\t\tzip a repository"
	echo -e "exit\t\texits Jet\n"
}

doAction () {
	case $1 in
		--help) 
			printMenu;;
		make)
			createRepository "$3" $2
			createLogFile $(findRepoIndex $2);;
		delete)
			deleteRepository "$3" $(findRepoIndex $2);;
		repos)
			printRepos;;
		createfile)
			createNewFile "$3" $(findRepoIndex $2);;
		deletefile)
			deleteFile "$3" $(findRepoIndex $2);;
		list)
			listFiles $(findRepoIndex $2);;
		edit)
			editFile $3 $(findRepoIndex $2);;
		stage)
			if [ "$3" = "-a" ]; then
				moveAllToStagingFolder $(findRepoIndex $2)
			else
				moveToStagingFolder $3 $(findRepoIndex $2)
			fi;;
		unstage)
			if [ "$3" = "-a" ]; then
				clearStagingFolder $(findRepoIndex $2)
			else
				moveFromStagingFolder $3 $(findRepoIndex $2)
			fi;;
		stageclear)
			clearStagingFolder $(findRepoIndex $2);;
		stageall)
			moveAllToStagingFolder $(findRepoIndex $2);;
		commit)
			makeCommit $3 $(findRepoIndex $2);;
		revert)
			revertCommit $3 $(findRepoIndex $2);;
		commits)
			printCommits $(findRepoIndex $2);;
		zip)
			zipRep $(findRepoIndex $2);;
		aautobackup)
			automaticBackups $(findRepoIndex $2) &
			echo -e "Automatically backing up all repository files. To stop enter \"kill $!\"";;
		autostaging)
			automaticStaging $(findRepoIndex $2) &
			echo -e "Automatically staging changed repository files. To stop enter \"kill $!\"";;
		permissionprotect)
			createUserGroup $(findRepoIndex $2)
			lockToUserGroup $(findRepoIndex $2);;
		allowuser)
			createUserGroup $(findRepoIndex $2)
			addUsersToGroup $3 $(findRepoIndex $2);;
		*)
			echo "Error, unknown command";;
	esac
}

addUsersToGroup () {
	#assumptions: $2 rep index, $1 is username
	sudo usermod -a -G "${repositories[$2]}" "$1"
}

lockToUserGroup () {
	#assumptions: $1 rep index
	echo "Your password:"
	chmod -R o-rwx "./${repositoryPaths[$1]}"
	chown -R :"${repositories[$1]}" "./${repositoryPaths[$1]}"
}

createUserGroup () {
	#assumptions: $1 rep index
	if ! [ grep -q "${repositories[$1]}" /etc/group ]; then
		sudo groupadd "${repositories[$1]}"
	fi
}

findRepoIndex () {
	# shopt -s nocasematch
	for i in ${!repositories[@]}; do
		if [ "${repositories[$i]}" = "$1" ]; then
			echo $i
		fi
	done
}

revertCommit () {
	#assumptions: $2 is a repository index, $1 is a commit timestamp
	cd $HOME
	if [ -d ${repositoryPaths[$2]} ]; then
	  local date=$(date +'%Y-%m-%d %H:%M:%S')
		addCommitToLogFile $2 "Reverted commit $1" $timestamp
		cd $HOME
		cd ./${repositoryPaths[$2]}
		for i in *; do
			if [ "$i" != .$repositories[$2] ] && [ "$i" != "*" ]; then
				rm -r "$i"
			fi
		done
		cd ./.${repositories[$2]}/$1
		for i in *; do
			if [ "$i" != "*" ]; then
				cp -r "$i" ../..
			fi
		done
	else
		echo "The commit you're trying to revert hasn't been made"
	fi
}

makeCommit () {
	#assumptions: $2 is a repository index, $1 is a commit message
	#--------------if [ repo doesnt exist ] then print error, if [ no commit message given ] then print error, else print code below
	cd $HOME
	if [ -d ${repositoryPaths[$2]} ] && [ -n $1 ]; then
	  local date=$(date +'%Y-%m-%d %H:%M:%S')
		local timestamp=$(date +%s)
		cd $HOME
		cd ./${repositoryPaths[$2]}/.${repositories[$2]}
		if [ $(ls -1q ./${stagingFolder} | wc -l) -gt 0 ]; then
	  	addCommitToLogFile $2 $1 "$date" $timestamp
			mkdir $timestamp
			mv ./${stagingFolder}/* ./$timestamp
		else
			echo "No files have been staged yet."
		fi
	elif [ -d $2 ]; then
		echo "The repository you're trying to commit doesn't exist."
	else
		echo "No commit message was given."
  fi
}

automaticBackups () {
	#assumptions: $1 is a repository index
	cd $HOME
	cd "./${repositoryPaths[$1]}"
	mkdir -p "./.${repositories[$1]}/${backupFolder}"
	while true; do
		cd $HOME
		cd "./${repositoryPaths[$1]}"
		for i in *; do
			if [ "$i" != "*" ]; then
				cp -r "$i" "./.${repositories[$1]}/${backupFolder}/$i"
			fi
		done
		sleep 1m
	done
}

automaticStaging () {
	#assumptions: $1 is a repository index
	while true; do
		cd $HOME
		cd "./${repositoryPaths[$1]}"
		for i in *; do
			if [ "$i" != "*" ]; then
				difference=$(diff "$i" "./.${repositories[$1]}/${stagingFolder}/$i")
				if [ $? -ne 0 ] || [ "$difference" ]; then
					cp -r "$i" "./.${repositories[$1]}/${stagingFolder}/$i"
				fi
			fi
		done
		sleep 1m
	done
}

# Validation for general 
if [ $# -eq 0 ]; then
	#printMenu	-	leave commented until finished for ease of testing purposes
	echo "No arguments were given."
fi

#$1 - command name
#$2 - repository name (not case sensitive)
#$3... - function arguments

loadConfig
doAction "$@"
if [ "$1" != "autoBackup" ]; then
	saveConfig
fi
if ! [ -z $2 ] && [ $1 != "list" ]; then
	echo Files:
	listFiles $(findRepoIndex $2)
fi
