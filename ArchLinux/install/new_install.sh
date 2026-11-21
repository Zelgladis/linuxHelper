#!/bin/bash
# Разметка и настройка диска
fdisk /dev/sdb
# Создаем 2 партиции EFI и LinuxSystem

mkfs.fat -F32 -n EFI /dev/sdb1
mkfs.btrfs -f -L ARCHROOT /dev/sdb2

mount /dev/sdb2 /mnt

btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_cache

umount /mnt

mount -o noatime,compress=zstd:1,subvol=@ /dev/sdb2 /mnt
mkdir -p /mnt/{home,.snapshots,var/log,var/cache,boot}
mount -o noatime,compress=zstd:1,subvol=@home /dev/sdb2 /mnt/home
mount -o noatime,compress=zstd:1,subvol=@snapshots /dev/sdb2 /mnt/.snapshots
mount -o noatime,compress=zstd:1,subvol=@var_log /dev/sdb2 /mnt/var/log
mount -o noatime,compress=zstd:1,subvol=@var_cache /dev/sdb2 /mnt/var/cache

mount /dev/sdb1 /mnt/boot
# Начинаем устаноаку
pacstrap -K /mnt base linux linux-headers linux-firmware amd-ucode btrfs-progs sudo nano vim neovim networkmanager git
genfstab -U /mnt >>/mnt/etc/fstab

# Базовая настройка оосновных компонентов системы
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime
arch-chroot /mnt hwclock --systohc

sed -i \
  -e 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
  -e 's/^#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' \
  /mnt/etc/locale.gen
grep -E '^(en_US|ru_RU)\.UTF-8' /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

echo 'LANG=ru_RU.UTF-8' >/mnt/etc/locale.conf

echo 'iliko' >/mnt/etc/hostname

cat >/mnt/etc/hosts <<'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   iliko.localdomain iliko
EOF

echo 'KEYMAP=us' >/mnt/etc/vconsole.conf

arch-chroot /mnt passwd
arch-chroot /mnt useradd -m -G wheel -s /bin/bash ilinium
arch-chroot /mnt passwd ilinium
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers
grep -n '^%wheel' /mnt/etc/sudoers
arch-chroot /mnt visudo -c

#Установка и Включение основных компонентов
arch-chroot /mnt systemctl enable NetworkManager
arch-chroot /mnt pacman -S limine

EFI_UUID=$(blkid -s UUID -o value /dev/sdb1)
ROOT_UUID=$(blkid -s UUID -o value /dev/sdb2)
echo "EFI UUID:  $EFI_UUID"
echo "ROOT UUID: $ROOT_UUID"

mkdir -p /mnt/boot/EFI/limine
cp /mnt/usr/share/limine/BOOTX64.EFI /mnt/boot/EFI/limine/BOOTX64.EFI

cat >/mnt/boot/EFI/limine/limine.conf <<EOF
timeout: 5
default_entry: 1

/Arch Linux
    protocol: linux
    path: boot():/vmlinuz-linux
    cmdline: root=UUID=${ROOT_UUID} rw rootflags=subvol=@
    module_path: boot():/amd-ucode.img
    module_path: boot():/initramfs-linux.img
EOF

arch-chroot /mnt pacman -S efibootmgr

arch-chroot /mnt efibootmgr \
  --create \
  --disk /dev/sdb \
  --part 1 \
  --label "Arch Linux Limine" \
  --loader '\EFI\limine\BOOTX64.EFI' \
  --unicode

arch-chroot /mnt efibootmgr -v
arch-chroot /mnt mkinitcpio -P

# Железо зависимое ПО
# AMD radeon
arch-chroot /mnt pacman -S mesa vulkan-radeon vulkan-icd-loader

# Звук
arch-chroot /mnt pacman -S \
  pipewire pipewire-audio pipewire-alsa \
  pipewire-pulse wireplumber alsa-utils

arch-chroot /mnt systemctl --global enable \
  pipewire.socket \
  pipewire-pulse.socket \
  wireplumber.service

# Базовое ПО графики
arch-chroot /mnt pacman -S \
  wayland wayland-protocols \
  xdg-utils xdg-user-dirs \
  wl-clipboard cliphist \
  grim slurp \
  brightnessctl

# ПО порталов
# pipewire-jack
arch-chroot /mnt pacman -S \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  xdg-desktop-portal-gnome \
  xdg-desktop-portal-hyprland

# Установка окружения hyprland
arch-chroot /mnt pacman -S hyprland
arch-chroot /mnt pacman -S greetd greetd-tuigreet
cat >/mnt/etc/greetd/config.toml <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = "greeter"
EOF

arch-chroot /mnt id greeter
arch-chroot /mnt getent group render
arch-chroot /mnt id ilinium

arch-chroot /mnt usermod -aG video,render ilinium

arch-chroot /mnt systemctl enable greetd.service

# Доп ПО
arch-chroot /mnt pacman -S foot
arch-chroot /mnt pacman -S \
  fuzzel \
  waybar \
  mako \
  thunar \
  thunar-archive-plugin \
  file-roller \
  pavucontrol \
  network-manager-applet \
  polkit-gnome

arch-chroot /mnt pacman -S \
  noto-fonts \
  noto-fonts-emoji \
  ttf-jetbrains-mono-nerd

sed -i \
  -e 's/local terminal    = "kitty"/local terminal    = "foot"/' \
  -e 's/local fileManager = "dolphin"/local fileManager = "thunar"/' \
  -e 's/local menu        = "hyprlauncher"/local menu        = "fuzzel"/' \
  /mnt/home/ilinium/.config/hypr/hyprland.lua

sed -i \
  -e 's/kb_layout  = "us"/kb_layout  = "us,ru"/' \
  -e 's/kb_options = ""/kb_options = "grp:win_space_toggle"/' \
  /mnt/home/ilinium/.config/hypr/hyprland.lua

python - <<'PY'
from pathlib import Path

p = Path("/mnt/home/ilinium/.config/hypr/hyprland.lua")
s = p.read_text()

old = '''-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)'''

new = '''hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
end)'''

if old not in s:
    raise SystemExit("Исходный шаблон не найден — файл не изменён")

p.write_text(s.replace(old, new, 1))
print("Автозапуск добавлен.")
PY

mkdir -p /mnt/home/ilinium/.config/xdg-desktop-portal

cat >/mnt/home/ilinium/.config/xdg-desktop-portal/hyprland-portals.conf <<'EOF'
[preferred]
default=gtk
org.freedesktop.impl.portal.Screenshot=hyprland
org.freedesktop.impl.portal.ScreenCast=hyprland
org.freedesktop.impl.portal.RemoteDesktop=hyprland
EOF

chown -R 1000:1000 /mnt/home/ilinium/.config/xdg-desktop-portal

sed -i \
  -e 's/mainMod .. " + Q", hl.dsp.exec_cmd(terminal)/mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal)/' \
  -e 's/mainMod .. " + C", hl.dsp.window.close()/mainMod .. " + Q", hl.dsp.window.close()/' \
  /mnt/home/ilinium/.config/hypr/hyprland.lua
sed -i '/hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))$/a hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))' \
  /mnt/home/ilinium/.config/hypr/hyprland.lua

sync && umount -R /mnt && reboot
