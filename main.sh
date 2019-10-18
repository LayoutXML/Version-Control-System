#!/bin/bash

#####################################
#	AC21009 Assignment 1			#
#	Version Control System in bash  #
#									#
#	Written by:						#
#	Rokas Jankunas - 180017115		#
#	Emilija Budryte - 180003228		#
#	Calum Logan - 180013466			#
#									#
#####################################

#	We have named our Version Control System Jet (similar to Git) - Immediately below variable declarations
#	are two functions which control and display a menu - below are definitions of the functions within the
#	menu, followed by other functions which do more behind-the-scenes work.

configFile="jet.cfg"	#Declaring variables to hold names of files and folders used by Jet
passwordsFile="jet-passwords.txt"
passwordsFileEncrypted="jet-passwords.txt.gpg"
logFile="log.txt"
stagingFolder="staging"
backupFolder="backup"

#repositories - array of repository names, initialised during config reading
#repositoryPaths - array of repository paths from home folder, initialised during config reading
#passwordsFile - array of password
#passwordRepos	- array of password repos

doAction () {	#Main function used to control the program
	case $1 in  #Looks for user input and compares it to keywords below
		--help) #Prints all input commands
			printMenu;;	
		make)	#Creates a new repository as well as its relevant log file
			if [ $# -eq 3 ]; then 	#Needs to take 3 parameters etc
				createRepository "$3" "$2"
				createLogFile $(findRepoIndex "$2")
			else 
				echo "3 parameters needed."
			fi;;
		delete)	#Deletes an existing repository
			if [ $# -eq 2 ]; then
				deleteRepository $(findRepoIndex "$2")
			else 
				echo "2 parameters needed."
			fi;;
		repos)	#Prints available repositories to the console
			if [ $# -eq 1 ]; then
				printRepos
			else 
				echo "1 parameter needed."
			fi;;
		createfile)	#Creates a new file
			if [ $# -eq 3 ]; then
				createNewFile "$3" $(findRepoIndex "$2")
			else 
				echo "3 parameters needed."
			fi;;
		deletefile)	#Deletes an existing file
			if [ $# -eq 3 ]; then
				deleteFile "$3" $(findRepoIndex "$2")
			else 
				echo "3 parameters needed."
			fi;;
		list)		#Lists all files in the current repository
			if [ $# -eq 2 ]; then
				listFiles $(findRepoIndex "$2")
			else 
				echo "2 parameters needed."
			fi;;
		edit)		#Opens a file externally for editing
			if [ $# -eq 3 ]; then
				editFile "$3" $(findRepoIndex "$2")
			else 
				echo "3 parameters needed."
			fi;;
		stage)		#Moves a file (or all files if -a is used) to the staging area of the repository
			if [ $# -eq 3 ]; then
				if [ "$3" = "-a" ]; then
					moveAllToStagingFolder $(findRepoIndex "$2")
				else
					moveToStagingFolder $3 $(findRepoIndex "$2")
				fi
			else 
				echo "3 parameters needed."
			fi;;
		unstage)	#Removes a file (or all files if -a is used) from the staging area of the repository
			if [ $# -eq 3 ]; then
				if [ "$3" = "-a" ]; then
					clearStagingFolder $(findRepoIndex "$2")
				else
					moveFromStagingFolder $3 $(findRepoIndex "$2")
				fi
			else 
				echo "3 parameters needed."
			fi;;
		stageclear)	#Does the same as does the same as unstage -a
			if [ $# -eq 2 ]; then
				clearStagingFolder $(findRepoIndex "$2")
			else 
				echo "2 parameters needed."
			fi;;
		stageall)	#Does the same as stage -a
			if [ $# -eq 2 ]; then
				moveAllToStagingFolder $(findRepoIndex "$2")
			else 
				echo "2 parameters needed."
			fi;;
		commit)		#Commits a file from the staging area of the current repository
			if [ $# -eq 3 ] || [ $# -eq 2 ] ; then
				makeCommit "$3" $(findRepoIndex "$2")
			else 
				echo "2 or 3 parameters needed."
			fi;;
		revert)		#Reverts a specific commit
			if [ $# -eq 3 ]; then
				revertCommit "$3" $(findRepoIndex "$2")
			else 
				echo "3 parameters needed."
			fi;;
		commits)	#Prints all commits made in the current repository
			if [ $# -eq 2 ]; then
				printCommits $(findRepoIndex "$2")
			else 
				echo "2 parameters needed."
			fi;;
		zip)		#Compresses a repository into a .zip file
			if [ $# -eq 2 ]; then
				zipRep $(findRepoIndex "$2")
			else 
				echo "2 parameters needed."
			fi;;
		setpassword)	#Sets a password for a repository
			if [ $# -eq 3 ]; then
				setPassword "$3" "$2"
			else 
				echo "3 parameters needed."
			fi;;
		autobackup)		#Automatically backs up files being worked on
			if [ $# -eq 2 ]; then
				automaticBackups $(findRepoIndex "$2") &
				echo -e "Automatically backing up all repository files. To stop enter \"kill $!\""
			else 
				echo "2 parameters needed."
			fi;;
		autostaging)	#Automatically stages files being worked on
			if [ $# -eq 2 ]; then
				automaticStaging $(findRepoIndex "$2") &
				echo -e "Automatically staging changed repository files. To stop enter \"kill $!\""
			else 
				echo "2 parameters needed."
			fi;;
		permission)		#Sets permissions to a specific user group
			if [ $# -eq 2 ]; then
				createUserGroup $(findRepoIndex "$2")
				lockToUserGroup $(findRepoIndex "$2")
			else 
				echo "2 parameters needed."
			fi;;
		allowuser)		#Allows a user to join a user group
			if [ $# -eq 3 ]; then
				createUserGroup $(findRepoIndex "$2")
				addUsersToGroup $3 $(findRepoIndex "$2")
			else 
				echo "3 parameters needed."
			fi;;
		*)		#Incorrect command entered
			echo "Error, unknown command"
	esac
}

printMenu () {	#Prints menu
	echo -e "\n\t\tJet Version Control"
	echo -e "Enter \"./main.sh\" followed by any command below to get started."
	echo -e "\n--help\t\tprints this help menu again"
	echo -e "make\t\tcreates a new repository"
	echo -e "delete\t\tdeletes a repository"
	echo -e "repos\t\tprint all repositories"
	echo -e "createfile\tcreates a new file"
	echo -e "deletefile\tdeletes a file"
	echo -e "list\t\tlists all files in the current working directory"
	echo -e "edit\t\tedit a file in an external editor"
	echo -e "stage\t\tmoves file to staging folder"
	echo -e "unstage\t\tmoves a file from the staging folder"
	echo -e "stageclear\tclears out the staging folder"
	echo -e "stageall\tmoves all files to staging folder"
	echo -e "commit\t\tmake a commit"
	echo -e "revert\t\trevert a commit"
	echo -e "commits\t\tprints a list of existing commits"
	echo -e "zip\t\tzip a repository"
	echo -e "setpassword\tsetting a password for a repository"
	echo -e "autobackup\tautomatically backing up files"
	echo -e "autostaging\tautomatically staging edited files"
	echo -e "permission\tpermission protection"
	echo -e "allowuser\tassigning users and groups"
	echo
}

createRepository () {	#Creates a new repository - can be password protected
	#assumptions: $1 is a path to the repository, $2 is a repository name
	cd $HOME
	if [ -d "${1}" ]; then
		cd "$1"
		mkdir ".${2}"
	else
		echo "The path to the new Repository is invalid. Creating new pathway..."
		mkdir -p "$1/.$2"
		cd "$1"
	fi
	mkdir ".${2}/${stagingFolder}"
	repositories[${#repositories[@]}]="$2"
	repositoryPaths[${#repositoryPaths[@]}]="$1"
}

createLogFile () {	#Creates a log file for a repository
	#assumptions: $1 is a repository index
	cd $HOME
	cd "./${repositoryPaths[$1]}/.${repositories[$1]}"
	touch ${logFile}
}

deleteRepository () {	#Deletes a respository - can be password protected
	#assumptions: $1 is a repository index
	if [ "$1" != "-1" ]; then
		if [ "$(validatePassword "$(findPasswordIndex ${repositories["$2"]})")" = 0 ]; then
			cd $HOME
			if [ -d "${repositoryPaths[$1]}" ]; then
				rm -r "${repositoryPaths[$1]}"
				repositories[$1]=""
				repositoryPaths[$1]=""
			else
				echo "The repository you're trying to delete doesn't exist"
			fi
		fi
	else
		echo "No repository with this name found"
	fi
}

printRepos () {	#Prints all repositories to console
	if [ ${#repositories[@]} -gt 0 ]; then
		for i in ${!repositories[@]}; do
			echo -e "${repositories[$i]}\t${repositoryPaths[$i]}"
	  	done
	else
		echo "No repositories found"
	fi 
}

createNewFile () {	#Creates a new file in the given repository - can be password protected
	#assumptions: $1 is a filename, $2 repository index
	if [ "$(validatePassword "$(findPasswordIndex ${repositories["$2"]})")" = 0 ]; then
		cd $HOME
		cd "./${repositoryPaths[$2]}"
		if [[ "$1" == *"/"* ]]; then
			mkdir -p "${1%/*}" && touch "$1"
		else 
			touch "$1"
		fi
		moveToStagingFolder "$1" $2
	fi
}

deleteFile () {	#Deletes a file in a repository - can be password protected
	#assumptions: $1 is a filename, $2 repository index
	if [ "$2" != "-1" ]; then
		if [ "$(validatePassword "$(findPasswordIndex ${repositories["$2"]})")" = 0 ]; then
			cd $HOME
			cd "./${repositoryPaths[$2]}"
			rm -r "$1"
			moveFromStagingFolder "$1" $2
		fi
	fi
}

listFiles () {	#Lists files in a repository
  	#assumptions: $1 is a repository index
	cd $HOME
  	if [ $1 -ge 0 ] && [ -d "${repositoryPaths[$1]}" ]; then
		cd "./${repositoryPaths[$1]}"
  		if [ $(ls -1q | wc -l) -gt 0 ]; then
			ls
		else
			echo "No files found"
		fi
	else
		echo "The repository you're trying to list files from doesn't exist"
	fi
}

editFile () {	#Opens a file externally to allow editing - can be password protected
	#assumptions: $1 is a filename, $2 repository index
	cd $HOME
	if [ -d "${repositoryPaths[$2]}" ]; then
		cd "./${repositoryPaths[$2]}"
		if [ -f "$1" ]; then
			if [ "$(validatePassword "$(findPasswordIndex ${repositories["$2"]})")" = 0 ]; then
				xdg-open "$1"
			fi
		else
			echo "The file you're trying to open doesn't exist"
		fi
	else
		echo "The repository you're trying to access a file from doesn't exist"
	fi
}

moveToStagingFolder () {	#Moves a file (or files when called with -a) to the staging folder
	#assumptions: $1 is a file name, $2 rep index
	cd $HOME
	if [ -d "${repositoryPaths[$2]}" ]; then
		cd "./${repositoryPaths[$2]}"
		if [ -f "$1" ]; then
			cp -r "${1}" "./.${repositories[$2]}/${stagingFolder}/"
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

moveFromStagingFolder () {	#Takes a file (or fies when called with -a) from the staging folder
	#$1 filename, $2 rep index
	cd $HOME
	if [ -d "${repositoryPaths[$2]}" ]; then
		cd "./${repositoryPaths[$2]}/.${repositories[$2]}/${stagingFolder}"
		if [ -f "$1" ]; then
			rm -r "$1"
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

moveAllToStagingFolder () {	#Moves all files in a repository to its staging folder
	#assumptions: $1 rep index
	cd $HOME
	cd "./${repositoryPaths[$1]}"
	for i in *; do
		if [ "$i" != "*" ]; then
			cp -r "$i" "./.${repositories[$1]}/${stagingFolder}/"
		fi
	done
}	

clearStagingFolder () {	#Moves all files in a repository's staging folder out of it
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

makeCommit () {	#Makes a commit of the repository
	#assumptions: $2 is a repository index, $1 is a commit message
	cd $HOME
	if [ -d "${repositoryPaths[$2]}" ] && [ -n "$1" ]; then
	  local date=$(date +'%Y-%m-%d %H:%M:%S')
		local timestamp=$(date +%s)
		cd $HOME
		cd "./${repositoryPaths[$2]}/.${repositories[$2]}"
		if [ $(ls -1q ./${stagingFolder} | wc -l) -gt 0 ]; then
	  	addCommitToLogFile "$2" "$1" "$date" $timestamp
			mkdir $timestamp
			mv ./${stagingFolder}/* ./$timestamp
		else
			echo "No files have been staged yet."
		fi
		moveAllToStagingFolder "$2"
	elif [ -d $2 ]; then
		echo "The repository you're trying to commit doesn't exist."
	else
		echo "No commit message was given."
  fi
}

revertCommit () {	#Reverts a commit of a repository - can be password protected
	#assumptions: $2 is a repository index, $1 is a commit timestamp
	cd $HOME
	if [ -d "./${repositoryPaths[$2]}/.${repositories[$2]}/$1" ]; then
		if [ "$(validatePassword "$(findPasswordIndex ${repositories["$2"]})")" = 0 ]; then
		  	local date=$(date +'%Y-%m-%d %H:%M:%S')
			addCommitToLogFile "$2" "Reverted commit $1" "$date" $timestamp
			cd $HOME
			cd "./${repositoryPaths[$2]}"
			for i in *; do
				if [ "$i" != ".$repositories[$2]" ] && [ "$i" != "*" ]; then
					rm -r "$i"
				fi
			done
			cd "./.${repositories[$2]}/$1"
			for i in *; do
				if [ "$i" != "*" ]; then
					cp -r "$i" ../..
				fi
			done
			moveAllToStagingFolder "$2"
		fi
	else
		echo "The commit you're trying to revert hasn't been made"
	fi
}

printCommits () {	#Prints all commits that have been made
	#$1 rep index
	cd $HOME
	if [ -d "./${repositoryPaths[$1]}/.${repositories[$1]}/" ]; then
		cd "./${repositoryPaths[$1]}/.${repositories[$1]}/"
		for i in *; do
			if [ "$i" != $stagingFolder ] && [ "$i" != $logFile ] && [ "$i" != "*" ]; then
				echo "$i"
			fi
		done
	else
		echo "The repository you're trying to print commits from doesn't exist"
	fi
}

zipRep () {	#Compresses a repository into a .zip folder
	#assumptions: $1 is a repository index
	cd $HOME
	if [ -d "${repositoryPaths[$1]}" ]; then
		zip -r "./${repositoryPaths[$1]}/${repositories[$1]}.zip" "./${repositoryPaths[$1]}"
	else
		echo "The repository you're trying to compress doesn't exist"
	fi
}

setPassword () {	#Sets a password that can be used for making and deleting files/repositories and editing files
	#assumptions: $1 is a password, $2 is a repository name
	passwordRepos[${#passwordRepos[@]}]="$2"
	passwords[${#passwords[@]}]="$1"
}

automaticBackups () {	#Automatically backs up any files that are being worked on every minute
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

automaticStaging () {	#Automatically copies all files being worked on to the staging area every minute
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

createUserGroup () {	#Creates a new user group that users can be added to for security
	#assumptions: $1 rep index
	if ! [ grep -q "${repositories[$1]}" /etc/group ]; then
		sudo groupadd "${repositories[$1]}"
	fi
}

lockToUserGroup () {	#Locks any files so that only users in the permitted user group can access them
	#assumptions: $1 rep index
	echo "Your password:"
	chmod -R o-rwx "./${repositoryPaths[$1]}"
	chown -R :"${repositories[$1]}" "./${repositoryPaths[$1]}"
}

addUsersToGroup () {	#Adds a user to a user group
	#assumptions: $2 rep index, $1 is username
	sudo usermod -a -G "${repositories[$2]}" "$1"
}

#####################

findRepoIndex () {	#Being called with a repository name, finds the index of that repository
	found=false
	for i in ${!repositories[@]}; do
		if [ "${repositories[$i]}" = "$1" ]; then
			found=true
			echo $i
		fi
	done
	if [ $found = false ]; then
		echo -1
	fi
}

#####################

addCommitToLogFile () {	#Adds a commit to the repository's log file, with information of the message, date, and timestamp
	#assumptions: $1 is a repository index, $2 is a commit message, $3 is date, $4 is commit timestamp (optional), log file exists
	cd $HOME
	cd "./${repositoryPaths[$1]}/.${repositories[$1]}"
	echo -e "${3}\t${2}\t$(whoami)\t${4}" >> ${logFile}
}

#####################

saveConfig () {	#Saves the config file which contains repository/password array information
	cd $HOME
	rm $configFile 2> /dev/null
	touch $configFile 
	for i in ${!repositories[@]}; do
		if [ "${repositories[$i]}" != "" ]; then
			echo "${repositories[$i]}" >> $configFile
		fi
		if [ "${repositoryPaths[$i]}" != "" ]; then
			echo "${repositoryPaths[$i]}" >> $configFile
		fi
	done
	if [ "${#passwordRepos[@]}" -gt 0 ]; then
		rm $passwordsFile 2> /dev/null
		rm $passwordsFileEncrypted 2> /dev/null
		touch $passwordsFile
		for i in ${!passwordRepos[@]}; do
			echo ${passwordRepos[$i]} >> $passwordsFile
			echo ${passwords[$i]} >> $passwordsFile
		done
		# echo "Set an ecnryption password"
		gpg --passphrase "test" --batch -c $passwordsFile
		rm $passwordsFile
	fi
}

loadConfig () {	#Loads up the config file to be edited with new information
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
	if [ -f "$passwordsFileEncrypted" ]; then
		# echo "Enter an ecnryption password"
		gpg --passphrase "test" --batch -d $passwordsFileEncrypted > $passwordsFile 2> /dev/null
		odd=true
		while read line; do
			if [ $odd = true ]; then
				passwordRepos[${#passwordRepos[@]}]=$line
				odd=false
			else
				passwords[${#passwords[@]}]=$line
				odd=true
			fi
		done < $passwordsFile
		rm $passwordsFile
	fi
}

###############

findPasswordIndex () {	#Similar to findRepositoryIndex - finds an index for a password
	found=false
	for i in ${!passwordRepos[@]}; do
		if [ "${passwordRepos[$i]}" = "$1" ]; then
			found=true
			echo $i
		fi
	done
	if [ $found = false ]; then
		echo -1
	fi
}

validatePassword () {	#Validated an encrypted password
	#assumptions: $1 is a repository index
	if [ "$1" != "-1" ]; then
		echo "Enter repository password: " > $(tty)
		read -s input
		if [ "$input" = "${passwords[$1]}" ]; then
			echo 0
		else
			echo "Password is incorrect" > $(tty)
			echo 1
		fi
	else
		echo 0
	fi
}

#################
#$1 - command name
#$2 - repository name (not case sensitive)
#$3... - function arguments


# Validation for general 
if [ $# -eq 0 ]; then
	#printMenu	-	leave commented until finished for ease of testing purposes
	echo "No arguments were given."
else
	loadConfig
	doAction "$@"
	if [ "$1" != "autoBackup" ]; then
		saveConfig
	fi
	if ! [ -z "$2" ] && [ "$1" != "list" ] && [ "$1" != "--help" ]; then
		echo Files:
		listFiles $(findRepoIndex "$2")
	fi
fi
