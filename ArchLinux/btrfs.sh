#USERNAME: MIO
#HOOSTBANE: MIKO
fdisk /dev/sda
n +2GiB
n +120GiB
n

t 1 1
t 2 23
t 3 19

w


mkfs.fat -F32 -n EFI /dev/sda1
mkfs.btrfs -L ROOT /dev/sda2
mkswap -L SWAP /dev/sda3

mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@          # для корня
btrfs subvolume create /mnt/@home      # для /home
btrfs subvolume create /mnt/@snapshots # для снапшотов
btrfs subvolume create /mnt/@var       # для /var
umount /mnt


mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{home,.snapshots,var,boot}
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,subvol=@var /dev/sda2 /mnt/var
mount /dev/sda1 /mnt/boot
swapon /dev/sda3


pacstrap -K /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt

usern='mio'
myhostname='miko'


ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime
hwclock --systohc
# Локализация
sed -i 's/#en_US.UTF\-8 UTF\-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#ru_RU.UTF\-8 UTF\-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
# Генерация локали в систему
locale-gen
echo 'LANG=ru_RU.UTF-8' >  /etc/locale.conf
echo 'KEYMAP=ru
FONT=cyr-sun16' > /etc/vconsole.conf
# Настройка сети
echo "$myhostname" > /etc/hostname
echo "127.0.0.1 localhost
::1 localhost
127.0.1.1 $myhostname.localdomain $myhostname" >> /etc/hosts

pacman -Syu --noconfirm
pacman -S vi nano reflector gcc perl make dhcpcd openssh sudo \
       btrfs-progs e2fsprogs grub efibootmgr os-prober hwinfo bash-completion \
       chafa libsixel imagemagick ntfs-3g dosfstools exfatprogs gparted libnewt --noconfirm
systemctl enable sshd
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
reflector --country Russia --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux --recheck
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -p linux

useradd -m -g users -G wheel -s /bin/bash $usern
echo "$usern:123" | sudo chpasswd
echo "root:123" | sudo chpasswd
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

pacman -S xf86-video-vesa mesa \
    alsa-utils alsa-plugins \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack easyeffects --noconfirm
systemctl --user enable pipewire pipewire-pulse
# xorg dop and fonts
pacman -S xorg xorg-server xorg-drivers noto-fonts-cjk otf-ipafont --noconfirm

sudo sed -i '/^#\[\s*multilib\s*\]/, /^#\[/ {
  s/^#\(\[multilib\]\)/\1/
  s/^#\(Include\s*=\s*\/etc\/pacman.d\/mirrorlist\)/\1/
}' /etc/pacman.conf

sudo pacman -Syu --noconfirm
pacman -S networkmanager
systemctl enable NetworkManager




reboot
#mio



sudo pacman -S wget \
    yajl \
    git \
    base-devel \
    linux-headers \
    dkms \
    go \
    ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family noto-fonts-emoji --noconfirm
git clone https://github.com/scopatz/nanorc.git ~/.nano
echo 'include "~/.nano/*.nanorc"' >> ~/.nanorc

mkdir ~/OTB/gits -p
cd ~/OTB/gits
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si && cd ~


if [[ "VB" == 'Yes' ]];then
    echo "VirtualBox"
    sudo pacman -S linux-headers virtualbox-guest-utils --noconfirm
    sudo systemctl enable --now vboxservice.service
    sudo modprobe -a vboxguest vboxsf vboxvideo
    echo -e "vboxguest\nvboxsf\nvboxvideo" | sudo tee /etc/modules-load.d/virtualbox.conf
fi


