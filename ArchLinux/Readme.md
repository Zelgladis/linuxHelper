# 🌸Установка ArchLinux
---
#### Установка раскладки клавиатуры и шрифта и Шрифт с русским языком
```bash
loadkeys ru
setfont cyr-sun16 # small
setfont ter-c32b # big
```

#### Синхронизация системных часов
```bash
timedatectl
```

#### Разметка дисков

```bash
fdisk -l
fdisk /dev/диск_для_разметки 
# или этой
cfdisk /dev/sda
```
###### Нажимает n для создания необходимых раздлв(личное предпочтения)
```bash
/dev/sda1 # ROOT
/dev/sda2 # Efi 1G нужен только для efi
/dev/sda3 # SWAP 5+G
# w для записи и выхода
```

###### Форматируем диски в нужный формат -L просто метка ничего не делает
```bash
mkfs.ext4 -L ROOT /dev/sda1 # ext4 для root или
mkfs.btrfs -L ROOT /dev/sda1 # btrfs для root Использовать только для SSD
```

###### SWAP раздел
```bash
mkswap -L SWAP /dev/sda3
```

###### EFI раздел
```bash
mkfs.fat -F32 -n EFI /dev/sda2
```

#### Монтируем диски
```bash
mount /dev/sda1 /mnt
mount --mkdir /dev/sda2 /mnt/efi
swapon /dev/sda3
```

#### Установка ArchLinux в /mnt
```bash
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
```
---

# Предварительная настройка ArchLinux
---
```bash
arch-chroot /mnt
```
##### Пароль суперпользователя
```bash
passwd
```
#### **Europe/Saratov** ваш регион/город Синхронизация часов
```bash
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime 
hwclock --systohc
```

### Локализация
###### Найти и раскоментить строки **en_US.UTF-8 UTF-8** и **ru_RU.UTF-8 UTF-8**
```bash
sed -i 's/#en_US.UTF\-8 UTF\-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/#ru_RU.UTF\-8 UTF\-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen
# Генерация локали в систему
locale-gen
echo 'LANG=ru_RU.UTF-8' >  /etc/locale.conf
echo 'KEYMAP=ru
FONT=cyr-sun16' > /etc/vconsole.conf
# vim /etc/locale.gen
```

--- ---
### Настройка сети
###### Создайте файл hostname: 
```bash
echo 'ariko' > /etc/hostname
echo '127.0.0.1 localhost
::1 localhost
127.0.1.1 ariko.localdomain ariko' >> /etc/hosts
```
###### Отредактируйте файл hoss:

##### Доп по(необходимое):
```bash
pacman -Suy
pacman -S gvim vi nano micro --noconfirm
# Для автоматического получения сетевых настроек установите dhcpcd и добавить в автозапуск
pacman -S dhcpcd --noconfirm
pacman -S openssh --noconfirm
systemctl enable sshd
systemctl enable dhcpcd
# Установите пакет grub и efibootmgr
pacman -S btrfs-progs --noconfirm
pacman -S e2fsprogs --noconfirm
pacman -S grub efibootmgr os-prober hwinfo --noconfirm
```

### Установка загрузчика GRUB
Для настройки конфигуратора используйте файл **/etc/default/grub** и файлы в каталоге **/etc/grub.d/**

Если Вы хотите добавить свои пункты в меню GRUB, настроить их можно в файле **/etc/grub.d/40_custom**, либо в **/boot/grub/custom.cfg**
Дефолтный файл /etc/default/grub содержит параметры конфигуратора с настройками по-умолчанию, снабженные комментариями на английском языке. Ниже перечислены некоторые наиболее общие из них:

- GRUB_DEFAULT Номер или заголовок пункта меню, выбранного по-умолчанию
- GRUB_TIMEOUT Время, после которого будет автоматически загружаться пункт по-умолчанию
- GRUB_CMDLINE_LINUX Параметры ядра Linux, добавляемые во все пункты меню.
- GRUB_CMDLINE_LINUX_DEFAULT Параметры ядра Linux,      добавляемые только в пункты меню, сгенерированные без "recovery". В Arch Linux настройки автоконфигуратора по-умолчанию содержат GRUB_DISABLE_RECOVERY=true, поэтому фактически в каждый пункт меню добавляются параметры из обех упомянутых строк.


Код скрипта конфигурации, генерируемый **grub-mkconfig**, обычно пригоден для загрузки в типовых случаях, но слишком громоздок, избыточен, непригоден для изучения, ограничен в возможностях, и создаёт ложное впечатление о "сложном конфиге GRUB2". 

В Arch Linux не используется версионное обновление ядер – имена образов ядра и initramfs для каждого пакета с ядром не меняются при обновлении, и файл конфигурации загрузчика не обновляется при обновлении ядра. 

Более того, возможности скриптов GRUB2 позволяют средствами самого загрузчика, прямо перед загрузкой ОС, генерировать меню с переменным количеством строк, для поиска и загрузки всех установленных ядер Arch Linux

### GRUB
```bash
# LEGACY
grub-install /dev/sda
# Перегенерируйте initramfs
mkinitcpio -p linux

```

```bash
# EFI Должен быть создан раздел FAT 32 и монитрован в /efi
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=ArchLinux --recheck
mkinitcpio -p linux
```

##### Автоматическая настрйока
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

##### ручная настройка
создаём меню
```bash
vim /boot/grub/menu.cfg
```

(hd0,gpt1) необходимо найти эти разделы в grub(перезагрузившись в grub)
вбив ls
и ls (hd0,msdos1)

# $prefix пересенная grub внутри путь к (раздел)boot/grub
```bash
#vim /boot/grub/grub.cfg
echo 'source $prefix/menu.cfg' > /boot/grub/grub.cfg
```

##### Через lsblk -f найдите UUID нужных дисков для Windows это диск с EFI(FAT) для linux диск с ROOT
##### Или если windows legacy путь к диску windows
```bash
set timeout=5
set default=0

menuentry "Arch Linux" {
    search --no-floppy --fs-uuid --set=root e66ce8ef-66cf-4b2a-a36c-7bd61b9c4c51
    linux /boot/vmlinuz-linux root=UUID=e66ce8ef-66cf-4b2a-a36c-7bd61b9c4c51 rw quiet
    initrd /boot//initramfs-linux.img
}

menuentry "Arch Linux (Fallback)" {
    search --no-floppy --fs-uuid --set=root e66ce8ef-66cf-4b2a-a36c-7bd61b9c4c51
    linux /boot//vmlinuz-linux root=UIID=e66ce8ef-66cf-4b2a-a36c-7bd61b9c4c51 rw
    initrd /boot//initramfs-linux-fallback.img
}
menuentry "Windows 10 (EFI)" {
    search --no-floppy --fs-uuid --set=root e66ce8ef-66cf-4b2a-a36c-7bd61b9c4c51
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
# Для Windows legacy
menuentry "Windows 10 (Legacy)" {
    set root='hd0,msdos2'
    chainloader +1
}
```

### Для обоих версий ручной настройки
защищаем от перезаписи grub.cfg
```bash
chattr +i /boot/grub/grub.cfg
```
Чтобы избежать конфликта с файлом из пакета, добавьте его имя в строку NoUpgrade в /etc/pacman.conf
```bash
vim /etc/pacman.conf
```
Добавить строку в блоке [Options]
```conf
NoUpgrade = boot/grub/grub.cfg
```


### Создание пользователя и настройка sudo
```bash
useradd -m -g users -G wheel -s /bin/bash mio
echo "mio:123" | sudo chpasswd
# Предоставить членам группы wheel доступ к sudo: 
# в файле /etc/sudoers разкоментить %wheel      ALL=(ALL:ALL) ALL
pacman -S sudo --noconfirm
vim /etc/sudoers
```

### Перезагружаемся
```bash
# Выходим из arch-chroot
exit
```
```bash
# Перезагрузка(не забудь вынуть диск)
reboot
```
---

### Terminal Visual
```bash
export PS1="\[\e[91m\]\$(if [[ \$? -eq 0 ]]; then echo '✔️'; else echo '❌'; fi) \[\e[92m\]\u@\h\[\e[0m\] \[\e[94m\]🌸 \[\e[33m\]\w\[\e[0m\]\[\e[95m\]\$(git branch 2>/dev/null | grep '^*' | colrm 1 2 | awk '{printf \" (%s)\", \$1}') \[\e[0m\]💫 $ "
vim ~/.bashrc
```

### Доп по(на выбор):
###### Лучше установить
```bash
sudo pacman -S wget --noconfirm
sudo pacman -S yajl --noconfirm
sudo pacman -S git --noconfirm
sudo pacman -S base-devel --noconfirm
sudo pacman -S linux-headers --noconfirm
sudo pacman -S dkms --noconfirm
sudo pacman -S openconnect --noconfirm
```

# Шрифты:
```bash
sudo pacman -S ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family noto-fonts-emoji --noconfirm
```

###### ЗА AUR
```bash
mkdir ~/OTB
mkdir ~/OTB/gits
cd ~/OTB/gits
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si && cd ~
```

### Дравйвера Video

**xf86-video-amdgpu** - новый, свободный драйвер для видеокарт AMD;
**xf86-video-ati** - старый свободный драйвер для AMD;
**xf86-video-intel** - драйвер для встроенной графики Intel;
**xf86-video-nouveau** - свободный драйвер для карт NVIDIA;
**xf86-video-vesa** - свободный драйвер, поддерживающий все карты, но с очень ограниченной функциональностью;
**nvidia** - проприетарный драйвер для NVIDIA.
###### Пример:
```bash
sudo pacman -S xf86-video-vesa --noconfirm
# radeon
sudo pacman -S mesa
sudo pacman -S lib32-mesa
sudo pacman -S xf86-video-amdgpu
sudo pacman -S lib32-amdvlk
sudo pacman -S amdvlk
#sudo pacman -S vulkan-radeon
#sudo pacman -S lib32-vulkan-radeon
## performance mode
echo "performance" | sudo tee /sys/class/drm/card1/device/power_dpm_state
cat /sys/class/drm/card1/device/power_dpm_state
# back to auto
echo "auto" | sudo tee /sys/class/drm/card1/device/power_dpm_state
cat /sys/class/drm/card1/device/power_dpm_state

```

### Драйвера audio
```bash
sudo pacman -S alsa-utils alsa-plugins --noconfirm
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack --noconfirm
systemctl --user enable --now pipewire pipewire-pulse
# Настройка громкости
alsamixer
# test
speaker-test -c 2
```

---

###### xorg
```bash
sudo pacman -S xorg-server --noconfirm
sudo pacman -S xorg-drivers --noconfirm
sudo pacman -S xorg --noconfirm
# не обязательно
sudo pacman -S gcc perl make --noconfirm

xorg-drivers # Ниже есть драйвера но это вроде тоже
Xorg :0 -configure # После драверов
cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов
```

### !!! AFTER VISUAL MANAGER !!!
### ПО
```bash
sudo pacman -S firefox --noconfirm
sudo pacman -S flatpak
yay -S visual-studio-code-bin
yay -S intellij-idea-community-edition
yay -S keepassxc --noconfirm
yay -S dbeaver --noconfirm
yay -S docker --noconfirm
yay -S docker-compose --noconfirm
sudo usermod -aG docker ilinium
yay -S telegram-desktop --noconfirm
yay -S kate --noconfirm
flatpak install flathub com.getpostman.Postman
# flatpak remote-add --user flathub https://flathub.org/repo/flathub.flatpakrepo
```

##### WINE
```bash
# Enable multilib
sudo vim /etc/pacman.conf
# find [multilib] and decoment it
sudo pacman -Syu wine wine-mono wine-gecko
yay -S Bottles
winecfg # Настройка wine

# Библиотеки WineTricks
cd $HOME/Downloads
wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x winetricks
```
```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

### VPN eanbled
```bash
sudo pacman -S networkmanagerfirewalld --noconfirm
sudo pacman -S networkmanager --noconfirm
sudo pacman -S network-manager-applet --noconfirm
sudo pacman -S networkmanager-openconnect --noconfirm
sudo pacman -S networkmanager-openvpn --noconfirm
sudo pacman -S openvpn --noconfirm
sudo pacman -S openresolv --noconfirm
sudo pacman -S webkit2gtk-4.1
sudo pacman -S gcr
yay -S cisco-anyconnect
sudo systemctl enable vpnagentd --now
sudo systemctl enable NetworkManager --now
sudo systemctl enable vpnagentd.service --now
sudo firewall-cmd --permanent --zone=trusted --add-interface=tun0
sudo firewall-cmd --reload

```

# Иероглифы
```bash
sudo pacman -S noto-fonts-cjk
sudo pacman -S otf-ipafont
```

### Удаляем ненужное(для меня) предустановленное по
```bash
sudo pacman -R gitg --noconfirm
sudo pacman -R polari --noconfirm
sudo pacman -R endeavour --noconfirm
yay -R geary --noconfirm
```

### GATE

```bash
sudo systemctl start vpnagentd
```

