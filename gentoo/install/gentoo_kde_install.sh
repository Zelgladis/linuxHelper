#!/bin/bash
nano /etc/portage/make.conf
eselect profile set 8
eselect profile list

emerge --sync
emerge --ask --update --deep --newuse @world

# Но нам нужно KDE так-что продолжаем
emerge --ask kde-plasma/plasma-meta
emerge --ask x11-misc/sddm
emerge --ask media-video/wireplumber
emerge --ask media-video/pipewire
emerge --ask kde-plasma/plasma-systemmonitor
emerge --ask sys-apps/xdg-desktop-portal kde-plasma/xdg-desktop-portal-kde
emerge --ask app-portage/gentoolkit
emerge --ask media-libs/mesa x11-apps/mesa-progs

systemctl enable sddm
systemctl enable NetworkManager
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl enable bluetooth

# dop po
emerge --ask kde-apps/konsole
emerge --ask app-misc/fastfetch
emerge --ask kde-plasma/discover
emerge --ask app-eselect/eselect-repository
emerge --ask sys-apps/flatpak