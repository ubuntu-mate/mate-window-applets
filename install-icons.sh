#!/bin/bash

usage=$()

if [[ -z "$1" ]]; then
	echo "Usage: $0 {path}(optional) install/uninstall"
	exit 1
else

	if [[ "$1" == "install" || "$1" == "uninstall" ]]; then
		DIR="/usr/share/"
		echo "Installing icons in $DIR"

		if [[ $1 == "install" ]]; then
			cp -v -r data/icons $DIR
		elif [[ $1 == "uninstall" ]]; then
			rm -v -r $DIR"icons/mate-window-applets"
		fi

	else

		DIR=$1
		echo "Installing icons in $DIR"

		if [[ -z "$2" ]]; then
			echo "Usage: $0 {path}(optional) install/uninstall"
			exit 1
		else
			
			if [[ "$2" == "install" || "$2" == uninstall ]]; then	
				if [[ $2 == "install" ]]; then
					cp -v -r data/icons $DIR
				elif [[ $2 == "uninstall" ]]; then
					rm -v -r $DIR"icons/mate-window-applets"
				else
					echo "Usage: $0 {path}(optional) install/uninstall"
				fi

			else
				echo "Usage: $0 {path}(optional) install/uninstall"
				exit 1
			fi
		fi			
	fi

	


fi
