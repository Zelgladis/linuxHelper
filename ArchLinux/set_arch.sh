#!/bin/bash

# Visual Console start
sudo sed 's/PS1=/#PS1=/' ~/.bashrc -i
sudo echo 'PS1="\[\e[96m\]\u@\h\[\e[0m\]~\[\e[33m\]\w\[\e[0m\]$ "' >> ~/.bashrc
#sudo sed s/PS1=.*$/'PS1="\[\e[96m\]\u@\h\[\e[0m\]~\[\e[33m\]\w\[\e[0m\]$ "'/ ~/.bashrc -i

# PO
sudo pacman -S wget --noconfirm
sudo pacman -S yajl --noconfirm
sudo pacman -S git --noconfirm

# drivers
sudo pacman -S xf86-video-vesa --noconfirm
sudo pacman -S alsa-utils alsa-plugins --noconfirm

# Xorg
sudo pacman -S xorg --noconfirm
sudo pacman -S xorg-server xorg-apps --noconfirm
sudo pacman -S xorg-xinit xterm xorg-xclock --noconfirm
# sudo pacman -S xorg-drivers
#xorg-drivers # Ниже есть драйвера но это вроде тоже
#Xorg :0 -configure # После драверов
#sudo cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов

# AUR
mkdir ~/OTB
mkdir ~/OTB/gits
cd ~/OTB/gits
git clone https://aur.archlinux.org/package-query.git
git clone https://aur.archlinux.org/yaourt.git
cd package-query/
makepkg -si && cd ../yaourt
makepkg -si && cd ~


# DOP PO
sudo sed s/#\\[multilib\\]/[multilib]/ /etc/pacman.conf -i
sudo sed -z 's/\(\[multilib\]\n\)\(#\)/\1/' /etc/pacman.conf -i
sudo pacman -Syu

sudo pacman -S base-devel --noconfirm
sudo pacman -S ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family --noconfirm
sudo pacman -S gcc perl make --noconfirm
sudo pacman -S firefox --noconfirm
yaourt -S visual-studio-code-bin
yaourt -S intellij-idea-community-edition
yaourt -S kate --noconfirm
yaourt -S keepassxc --noconfirm
yaourt -S telegram-desktop --noconfirm
yaourt -S dbeaver --noconfirm
yaourt -S docker --noconfirm
yaourt -S docker-compose --noconfirm
sudo usermod -aG docker ilinium

# Enable multilib and install wine
sudo pacman -S wine wine-mono wine-gecko
yaourt -S bottles

