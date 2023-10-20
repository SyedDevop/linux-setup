#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to run this script, please runn sudo ./install.sh" 2>&1
	exit 1
fi

## Check if the current directory is writable.
GITPATH="$(dirname "$(realpath "$0")")"
if [[ ! -w ${GITPATH} ]]; then
	echo -e "${RED}Can't write to ${GITPATH}${RC}"
	exit 1
fi

command_exists() {
	command -v $1 >/dev/null 2>&1
}

apt install -yq autojump bash bash-completion tar bat

linkApp() {
	if command_exists "batcat"; then
		echo -e "${YELLOW}symlink batcat to bat: ln -s /usr/bin/batcat ~/.local/bin/bat${RC}"
		ln -s /usr/bin/batcat ~/.local/bin/bat
		echo -e "${GREEN}batcat symlink to bat${RC}"
	fi

	if command_exists "autojump"; then
		echo -e "${YELLOW}sourceing autojump : . /usr/share/autojump/autojump.sh : on startup${RC}"
		echo ". /usr/share/autojump/autojump.sh" >>~/.bashrc
		echo -e "${GREEN}autojump sourced${RC}"
	fi
}

linkConfig() {
	## Get the correct user home directory.
	USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
	echo -e "${YELLOW}Linking new bash config file...${RC}"
	## Make symbolic link.
	ln -svf ${GITPATH}/kitty/kitty.conf ${USER_HOME}/.config/kitty/kitty.conf
	ln -svf ${GITPATH}/kitty/theme.conf ${USER_HOME}/.config/kitty/theme.conf
	ln -svf ${GITPATH}/starship.toml ${USER_HOME}/.config/starship.toml
}

linkApp
if linkConfig; then
	echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
	echo -e "${RED}Something went wrong!${RC}"
fi
