#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please runn sudo ./install.sh" 2>&1
  exit 1
fi
username=$(id -u -n 1000)
builddir=$(pwd)

mkdir -p /home/$username/.fonts

# install nala
apt install nala -y

# Installing esstial programs
nala install fet thunar curl unzip wget git build-essential

# Installing non esstial programs
nala install ripgrep fd-find xclip

#Install fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip
unzip CascadiaCode.zip -d /home/$username/.fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
unzip JetBrainsMono.zip -d /home/$username/.fonts
chown $username:$username /home/$username/.fonts/*

# Reload fonts
fc-cache -vf
# Remove zip files
rm ./CascadiaCode.zip ./JetBrainsMono.zip

git clone https://github.com/SyedDevop/lazynvim.conf.git ~/.config/nvim
