#!/bin/bash

# Code is poetry

# Script to setup a custom laravel development host on your machine
# Written by black.dragon74(Nick) for personal use.

# Declare varaibles (macOS relative)
author='black-dragon74'
sVersion='1.0';
wwwDir='/Applications/XAMPP/xamppfiles/htdocs'
vHosts='/Applications/XAMPP/xamppfiles/etc/extra/httpd-vhosts.conf'
sHosts='/etc/hosts'
xCTL='/Applications/XAMPP/xamppfiles/xampp'

# Declare custom functions to use
function print_version(){
	echo $sVersion;
	exit
}

function constructVhost(){
	# Store in local vars
	websiteAddr="$1"
	websiteDir="$2"

	if [[ -z $websiteAddr || -z $websiteDir ]]; then
		echo "Insufficient params supplied to the constructor. Exit."
		exit
	else
		# Construct the vhost
		echo
		echo "
<VirtualHost *:80>
	ServerAdmin $websiteAddr
	DocumentRoot \"$websiteDir\"
	ServerName $websiteAddr
</VirtualHost>" > ~/tmp.txt
	fi
}

clear

# Here we go!
echo "Welcome to laravel virtual host deployer."
echo "Created by Nick for personal use."
# Host name
read -p "Enter the name of the dev server (like, web.site): " customDev
if [[ ! -z $customDev ]]; then
	echo "Virtual host will be created as: $customDev"
else
	echo "Empty hostnames not allowed. Exit."
	exit
fi

# Website DIR
read -p "Enter the name of the directory to map to in htdocs folder: " hostDir
echo "$wwwDir/$hostDir"
if [[ ! -e "$wwwDir/$hostDir" ]]; then
	echo "Directory not found. Make sure the name is right."
	exit
else
	echo "Folder exists as: $wwwDir/$hostDir"
fi

# We have the info, now create the custom mappings and restart the apache server
# If this is a laravel project, some special steps are required
read -p "Is this a Laravel deploy?[yY/nN]: " laravelAns
case $laravelAns in
	yY* )
		constructVhost "$customDev" "$wwwDir/$hostDir/public" &>/dev/null
		echo "Special steps applied for laravel project."
		;;
	nN* )
		constructVhost "$customDev" "$wwwDir/$hostDir" &>/dev/null
		;;
	*)
		echo "Invalid input. Exit."
		exit
		;;		
esac

# Host Data
hostData="$(cat ~/tmp.txt)"
rm -f ~/tmp.txt

echo "Host data is ready to be injected."

# Request superuser permissions now
sudo something &>/dev/null

# Write Virtaul hosts
echo "$hostData" >> $vHosts

# Update System hosts
echo "127.0.0.1 $customDev" | sudo tee -a $sHosts

# Set special permissions required by laravel
case $laravelAns in
	yY* )
		sudo chown -R daemon:daemon $wwwDir/$hostDir
		;;
	*)
		:
		;;	
esac

# Restart server
sudo $xCTL restart

# Done
echo -e "All done! Your project would be live at: \033[31mhttp://$customDev\033[0m"
exit

#EOF
