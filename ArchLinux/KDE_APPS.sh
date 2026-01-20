#!/bin/bash
# Pacman-s sys
sudo pacman -S gvim \
  cmake \
  go \
  git \
  corectrl \
  pavucontrol \
  meld \
  kdf \
  htop \
  psensor \
  lm_sensors \
  xsensors \
  yakuake \
  blueman \
  partitionmanager \
  flatseal \
  filelight \
  kcalc \
  openrgb \
  dolphin \
  koko

# Pacman-s
sudo pacman -S steam \
  lutris \
  telegram-desktop \
  inkscape \
  kate \
  blender \
  firefox \
  elisa \
  obs-studio \
  rhythmbox \
  krecorder \
  vlc \
  virtualbox \
  ark \
  keepassxc \
  kleopatra \
  protontricks \
  wine wine-mono vkd3d \
  winetricks \
  krita \
  winetricks --noconfirm

# Flatpak-s
flatpak install flathub com.heroicgameslauncher.hgl \
  ru.linux_gaming.PortProton \
  nl.hjdskes.gcolor3 \
  com.visualstudio.code \
  com.vysp3r.ProtonPlus \
  net.davidotek.pupgui2 \
  org.gimp.GIMP \
  org.DolphinEmu.dolphin-emu \
  io.mgba.mGBA \
  net.pcsx2.PCSX2 \
  net.kuribo64.melonDS \
  net.rpcs3.RPCS3 \
  io.github.ryubing.Ryujinx \
  org.ppsspp.PPSSPP \
  io.github.xyproto.zsnes

# AUR-s
yay -S octopi \
  bottles \
  epsxe --noconfirm
