#!/bin/bash
# OpenEEF Installer
# by: Ari Stehney
#
# Prepare and install the OpenEEF SDK and interpreter

echo "OpenEEF Installer v1.0"
echo
printf "Install files? [y/n] "

read installnow
if [ "$installnow" = "y" ]; then
	printf "Creating config dir...\n"
	sudo mkdir -p /etc/eef/bin
	USER=$(whoami)
	sudo chown -R $USER /etc/eef

	printf "Creating config files...\n"
	touch /etc/eef/knownpkgs

	printf "Loading and linking binaries...\n"
	chmod +x bin/*
	cp bin/* /etc/eef/bin/
	for file in $(ls /etc/eef/bin/); do sudo rm /usr/bin/$file 2> /dev/null; sudo ln -s /etc/eef/bin/$file /usr/bin/$file; done

	printf "\nInstallation complete!\n"
fi
