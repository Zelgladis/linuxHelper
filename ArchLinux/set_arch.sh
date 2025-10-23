#!/bin/bash

VisMan='NONE'

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

# YAY aur
mkdir ~/OTB
mkdir ~/OTB/gits
cd ~/OTB/gits
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si && cd ~


# DOP PO
sudo sed s/#\\[multilib\\]/[multilib]/ /etc/pacman.conf -i
sudo sed -z 's/\(\[multilib\]\n\)\(#\)/\1/' /etc/pacman.conf -i
sudo pacman -Syu

sudo pacman -S base-devel --noconfirm
sudo pacman -S ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family --noconfirm
sudo pacman -S gcc perl make --noconfirm
sudo pacman -S firefox --noconfirm
yay -S visual-studio-code-bin
yay -S intellij-idea-community-edition
pacman -S kate --noconfirm
pacman -S keepassxc --noconfirm
pacman -S telegram-desktop --noconfirm
pacman -S dbeaver --noconfirm
pacman -S docker --noconfirm
pacman -S docker-compose --noconfirm
sudo usermod -aG docker ilinium

# Enable multilib and install wine
sudo pacman -S wine wine-mono wine-gecko
pacman -S bottles


# kde
if [ VisMan == 'KDE' ]; then
    sudo pacman -S --needed xorg
    #sudo pacman -S --needed plasma kde-applications

    sudo pacman -S --needed sddm
    spawn sudo pacman -S --needed plasma kde-applications
        expect "первый вопрос" { send "2\r" }
        expect "второй вопрос" { send "3\r" }
        expect "третий вопрос" { send "96\r" }
    interact

    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
    
    sudo pacman -R bomber -y
    sudo pacman -R bovo -y
    sudo pacman -R granatier -y
    sudo pacman -R kajongg -y
    sudo pacman -R kapman -y
    sudo pacman -R katomic -y
    sudo pacman -R kblackbox -y
    sudo pacman -R kblocks -y
    sudo pacman -R kbounce -y
    sudo pacman -R kbreakout -y
    sudo pacman -R kdiamond -y
    sudo pacman -R kfourinline -y
    sudo pacman -R kgoldrunner -y
    sudo pacman -R kigo -y
    sudo pacman -R killbots -y
    sudo pacman -R kiriki -y
    sudo pacman -R kjumpingcube -y
    sudo pacman -R klickety -y
    sudo pacman -R klines -y
    sudo pacman -R kmahjongg -y
    # sudo pacman -R kmines
    sudo pacman -R knavalbattle -y
    sudo pacman -R knetwalk -y
    sudo pacman -R knights -y
    sudo pacman -R kolf -y
    sudo pacman -R kollision -y
    sudo pacman -R konquest -y
    sudo pacman -R kpat -y
    sudo pacman -R kreversi -y
    sudo pacman -R kshisen -y
    sudo pacman -R ksirk -y
    sudo pacman -R ksnakeduel -y
    sudo pacman -R kspaceduel -y
    sudo pacman -R ksquares -y
    sudo pacman -R ksudoku -y
    sudo pacman -R ktuberling -y
    sudo pacman -R kubrick -y
    sudo pacman -R lskat -y
    sudo pacman -R palapeli -y
    sudo pacman -R picmi -y
    sudo pacman -R skladnik -y
    sudo pacman -R blinke -y
    sudo pacman -R kanagram -y
    sudo pacman -R khangman -y
    sudo pacman -R minuet -y
    sudo pacman -R artikulate -y

fi