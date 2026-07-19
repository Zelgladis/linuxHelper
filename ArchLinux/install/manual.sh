#!/bin/bash
# BTRFS GURU
mkfs.fat -F32 -n EFI /dev/sda2
mkfs.btrfs -L ROOT /dev/sda1
mkswap -L SWAP /dev/sda3

mount /dev/sda1 /mnt
btrfs subvolume create /mnt/@          # для корня
btrfs subvolume create /mnt/@home      # для /home
btrfs subvolume create /mnt/@snapshots # для снапшотов
btrfs subvolume create /mnt/@var       # для /var
umount /mnt

mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/sda1 /mnt
mkdir -p /mnt/{home,.snapshots,var,boot}
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home /dev/sda1 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/sda1 /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,subvol=@var /dev/sda1 /mnt/var
mount /dev/sda2 /mnt/boot
swapon /dev/sda3

### Установка ArchLinux в /mnt
pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
# Предварительная настройка ArchLinux
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF\-8 UTF\-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#ru_RU.UTF\-8 UTF\-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
# Генерация локали в систему
locale-gen
echo 'LANG=ru_RU.UTF-8' >  /etc/locale.conf
echo 'KEYMAP=ru
FONT=cyr-sun16' > /etc/vconsole.conf

echo 'amiko' > /etc/hostname
echo '127.0.0.1 localhost
::1 localhost
127.0.1.1 ariko.localdomain amiko' >> /etc/hosts

sed -i '/^#\[\s*multilib\s*\]/, /^#\[/ {
  s/^#\(\[multilib\]\)/\1/
  s/^#\(Include\s*=\s*\/etc\/pacman.d\/mirrorlist\)/\1/
}' /etc/pacman.conf
pacman -Syu
pacman -S sudo networkmanager vi nano reflector gcc perl make openssh \
       btrfs-progs e2fsprogs grub efibootmgr os-prober hwinfo bash-completion \
       chafa libsixel imagemagick ntfs-3g dosfstools exfatprogs gparted ntfsprogs \
       alsa-utils alsa-plugins xf86-video-vesa mesa \
       pipewire pipewire-alsa pipewire-pulse pipewire-jack easyeffects \
       xorg xorg-server xorg-drivers noto-fonts-cjk otf-ipafont wayland \
       wget yajl git base-devel linux-headers dkms go \
       ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family noto-fonts-emoji --noconfirm
useradd -m -g users -G wheel -s /bin/bash mio
echo "mio:123" | sudo chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable sshd
systemctl enable NetworkManager
systemctl --user enable pipewire pipewire-pulse

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux --recheck
grub-mkconfig -o /boot/grub/grub.cfg


reboot


#nano
git clone https://github.com/scopatz/nanorc.git ~/.nano
echo 'include "~/.nano/*.nanorc"' >> ~/.nanorc

echo "VB?"
read VB
if [[ "$VB" == 'Yes' ]];then
    echo "VirtualBox"
    sudo pacman -S linux-headers virtualbox-guest-utils --noconfirm
    sudo systemctl enable --now vboxservice.service
    # sudo modprobe -a vboxguest vboxsf vboxvideo
fi

# paru aur
mkdir ~/OTB/gits -p
cd ~/OTB/gits
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si && cd ~

# Hyperland
sudo pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk kitty waybar mako swaybg swayidle fuzzel sddm
sudo pacman -S qt6-svg qt6-declarative qt5-quickcontrols2
sudo systemctl enable sddm
paru catppuccin-sddm-theme-mocha

systemctl --user enable mako.service

## Niri
sudo pacman -S niri xwayland-satellite xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal-wlr xdg-desktop-portal-kde alacritty matugen cava qt6-multimedia-ffmpeg waybar swaybg swayidle fuzzel kitty
# systemctl --user add-wants niri.service
# systemctl --user add-wants niri.service mako.service
# systemctl --user add-wants niri.service waybar.service


