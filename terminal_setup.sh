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
USER_HOME=$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)

echo -e "${GITPATH} GITPATH\n"
echo -e "${USER_HOME} USER_HOME\n"

if [[ ! -w ${GITPATH} ]]; then
  echo -e "${RED}Can't write to ${GITPATH}${RC}"
  exit 1
fi

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

nala install -y bash bash-completion tar bat lsd ncbu

linkApp() {
  if command_exists "batcat"; then
    echo -e "${YELLOW}symlink batcat to bat: ln -s /usr/bin/batcat ~/.local/bin/bat${RC}"
    ln -svf /usr/bin/batcat "${USER_HOME}/.local/bin/bat"
    echo -e "${GREEN}batcat symlink to bat${RC}"
  fi
}

linkConfigs() {
  ## Get the correct user home directory.
  echo -e "${YELLOW}Creating symlink of config file...${RC}"
  ln -svf "${GITPATH}"/starship.toml "${USER_HOME}"/.config/starship.toml
  ln -svf "${GITPATH}"/.dir_colors "${USER_HOME}"/.dir_colors
  ln -svf "${GITPATH}"/wezterm "${USER_HOME}"/.config/
}

linkApp
if linkConfigs; then
  echo -e "${GREEN}Done!\nrestart your shell to see the changes.${RC}"
else
  echo -e "${RED}Something went wrong!${RC}"
fi
