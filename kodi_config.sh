#!/bin/bash

#Author: Andriy Marchuk
#Version: 0.0.1

YELLOW="\033[1;33m"
RED="\033[0;31m"
ENDCOLOR="\033[0m"
SCRIPT=$(readlink -f $0)
script_dir=`dirname $SCRIPT`
folder=$script_dir"/conf"


###################################################################################################
if pidof kodi.bin | grep [0-9] > /dev/null
then
	echo -e $YELLOW"Stopping Kodi..."$ENDCOLOR
	exec sudo killall -9 kodi.bin
	echo -n "Press any key to exit"
	read -n1
else 
	
	get_version() {
		COUNT=0
		Grep_CMD=
		Grep_CMD=`ls $folder -l | grep '^d' | awk '{ print $9 }' | uniq | sort -f 2>/dev/null`

		clear
		tput cup 1 28; echo " -= KODI =- "; echo "";
		if [ "$Grep_CMD" == "" ]; then
			echo "                                                               "
			echo -e "Not found any version in the folder " $RED$folder"/"$ENDCOLOR
			echo "                                                               "
			echo -e "Create folder with name of version in the "$RED$folder"/"$ENDCOLOR" folder and try again"
			echo "________________________________________________________________________________"
			echo -n "Press any key to exit"
			read -n1
			exit
		fi
		
		version=
		for version in $Grep_CMD
		do
			COUNT=$(($COUNT+1))
			Version_Array[$COUNT]=$version
			echo "[$COUNT] $version"
		done
		#
		if [ "$COUNT" -ge "10" ]; then
			N1="-n2"
		else
			N1="-n1"
		fi
		#
		echo ""
		echo ""
		echo "[X] Press an key to exit "
		echo "________________________________________________________________________________"
		echo -n "Enter the number of the KODI version: "
		read $N1 ANSWER
		echo ""
		if [ "$ANSWER" == "x" ] || [ "$ANSWER" == "X" ]; then
			exit
		elif [ "$ANSWER" == "" ]; then
			get_version
		fi

		# 
		if [ "$ANSWER" == "x" ] || [ "$ANSWER" == "X" ] || [ $ANSWER -le $COUNT ] 2>/dev/null; then
			if [ "`echo $ANSWER | sed 's/[0-9]*//'`" == "" ] || [ "$ANSWER"=="1" ]; then
				Version_Chosen=${Version_Array[$ANSWER]}
			else
				echo "Error: invalid selection"
				continue
			fi
		else
			get_version
		fi

		get_build	
	}

	get_build() {
		COUNT=0
		Grep_CMD=
		Grep_CMD=`ls $folder/$Version_Chosen -l | grep '^d' | awk '{ print $9 }' | uniq | sort -f 2>/dev/null`
		clear
		tput cup 1 28; echo " -= KODI =- "; echo "";
		
		build_name=
		for build_name in $Grep_CMD
		do
			COUNT=$(($COUNT+1))
			Build_Array[$COUNT]=$build_name
			echo "[$COUNT] $build_name"
		done

		#
		if [ "$COUNT" -ge "10" ]; then
			N1="-n2"
		else
			N1="-n1"
		fi
		#
		echo ""
		echo ""
		echo "[X] Press an key to exit         [B] Press an key to back"
		echo "________________________________________________________________________________"
		echo -n "Enter the number of the config to configurate: "
		read $N1 ANSWER
		echo ""
		if [ "$ANSWER" == "x" ] || [ "$ANSWER" == "X" ]; then
			exit	
		elif [ "$ANSWER" == "b" ] || [ "$ANSWER" == "B" ]; then
			get_version
		elif [ "$ANSWER" == "" ]; then
			get_build
		fi

		#
		if [ "$ANSWER" == "x" ] || [ "$ANSWER" == "X" ] || [ $ANSWER -le $COUNT ] 2>/dev/null; then
			if [ "`echo $ANSWER | sed 's/[0-9]*//'`" == "" ] || [ "$ANSWER"=="1" ]; then
				Build_Chosen=${Build_Array[$ANSWER]}
			else
				echo "Error: invalid selection"
				continue
			fi
		else
			get_build
		fi
		
		configure_kodi
	}

	configure_kodi () {
		echo -e $YELLOW"Starting configure Kodi..."$ENDCOLOR

		rm -rf /home/`whoami`/.kodi
		ln -s $folder/$Version_Chosen/$Build_Chosen /home/`whoami`/.kodi
		sleep 1
		exec /usr/bin/kodi &
		exit
	}

##
	get_version
fi
exit 0
