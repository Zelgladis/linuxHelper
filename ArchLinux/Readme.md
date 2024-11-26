# Установка ArchLinux
---
#### Установка раскладки клавиатуры и шрифта
```bash
loadkeys ru
```
#### Шрифт с русским языком
```bash
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
mkfs.fat -F32 /dev/sda2
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
#### **Europe/Saratov** ваш регион/город
```bash
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime 
```
#### Синхронизация часов
```bash
hwclock --systohc
```
### Локализация
###### Найти и раскоментить строки **en_US.UTF-8 UTF-8** и **ru_RU.UTF-8 UTF-8**
```bash
pacman -S vim vi nano micro --noconfirm
vim /etc/locale.gen
```
###### Генерация локали в систему
```bash
locale-gen
```
###### Создайте файл **/etc/locale.conf** и задайте переменной LANG необходимое значение
```bash
vim /etc/locale.conf
```
``` 
LANG=ru_RU.UTF-8 
```

###### Если вы меняли раскладку клавиатуры или шрифт, сделайте эти изменения постоянными, прописав их в файле **vconsole.conf**: 
```bash
vim /etc/vconsole.conf
``` 
``` 
KEYMAP=ru
FONT=ter-c32b 
```
--- ---
### Настройка сети
###### Создайте файл hostname: 
```bash
vim /etc/hostname
```
```text
ariko
```
###### Отредактируйте файл hoss:
 ```bash
vim /etc/hosts
```
```text
127.0.0.1 localhost
::1 localhot
127.0.1.1 ariko.mydomain ariko
```
---
##### Пароль суперпользователя
```bash
passwd
```

##### Доп по(необходимое):
```bash
pacman -Suy
# Для автоматического получения сетевых настроек установите dhcpcd и добавить в автозапуск
pacman -S dhcpcd --noconfirm
systemctl enable dhcpcd
# Установите пакет grub и efibootmgr
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

### LEGACY
Автоматическая настройка
```bash
# grub-install /dev/sda --efi-dir=/efi/
grub-install /dev/sda --efi-directory=/efi --bootloader-id=ArchLinux

# Перегенерируйте initramfs
mkinitcpio -p linux
# Запустите автоматическую настройку grub
grub-mkconfig -o /boot/grub/grub.cfg
```

ручная настройка
```bash
grub-install /dev/sda --efi-directory=/efi --bootloader-id=ArchLinux
mkinitcpio -p linux
```
создаём меню
```bash
vim /boot/grub/menu.cfg
```

(hd0,gpt1) необходимо найти эти разделы в grub(перезагрузившись в grub)
вбив ls
и ls (hd0,msdos1)/
Ищем файлы загрузки
```
set default=0
set timeout=5

# Название пункта меню
menuentry "Arch Linux" {
    set root=(hd0,msdos1)
    linux /boot/vmlinuz-linux root=/dev/sda1 rw quiet
    initrd /boot/initramfs-linux.img
}

menuentry "Arch Linux (Fallback)" {
    set root=(hd0,msdos1)
    linux /boot/vmlinuz-linux root=/dev/sda1 rw
    initrd /boot/initramfs-linux-fallback.img
}

# Для Windows legacy
menuentry "Windows 10 (Legacy)" {
    set root='hd0,msdos2'
    chainloader +1
}
```
```bash
vim /boot/grub/grub.cfg
```
$prefix пересенная grub внутри путь к (раздел)boot/grub
```
source $prefix/menu.cfg
```

### EFI
```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=ArchLinux --recheck
mkinitcpio -p linux

vim /boot/grub/grub.cfg
'source $prefix/menu.cfg'

vim /boot/grub/menu.cfg
```
##### MenuEFI
```text
menuentry "Arch Linux" {
    set root=(hd1,gpt1)
    linux /boot/vmlinuz-linux root=/dev/sdb1 rw quiet
    initrd /boot//initramfs-linux.img
}

menuentry "Arch Linux (Fallback)" {
    set root=(hd1,gpt1)
    linux /boot//vmlinuz-linux root=/dev/sdb1 rw
    initrd /boot//initramfs-linux-fallback.img
}
menuentry "Windows 10 (EFI)" {
    set root=(hd0,gpt1)
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
}
```

### Для обоих версий ручной настройки
защищаем от перезаписи grub.cfg
```
chattr +i /boot/grub/grub.cfg
```
Чтобы избежать конфликта с файлом из пакета, добавьте его имя в строку NoUpgrade в /etc/pacman.conf
```bash
vim /etc/pacman.conf
```
Добавить строку в блоке [Options]
```
NoUpgrade = boot/grub/grub.cfg
```


### Создание пользователя и настройка sudo
```bash
useradd -m -g users -G wheel -s /bin/bash ilinium
passwd ilinium
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
### Установка Графической оболчки(Gnome) и менеджера(gdm)
```bash
sudo pacman -S gnome gnome-extra --noconfirm
sudo pacman -S gdm --noconfirm
sudo pacman -S networkmanager --noconfirm
systemctl enable gdm.service
systemctl enable NetworkManager.service
# Шрифты:
sudo pacman -S ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family --noconfirm
```

### Доп по(на выбор):
###### Лучше установить
```bash
sudo pacman -S wget --noconfirm
sudo pacman -S yajl --noconfirm
sudo pacman -S git --noconfirm
sudo pacman -S base-devel --noconfirm
```

###### AUR
```bash
mkdir ~/OTB
mkdir ~/OTB/gits
cd ~/OTB/gits
git clone https://aur.archlinux.org/package-query.git
git clone https://aur.archlinux.org/yaourt.git
cd package-query/
makepkg -si && cd ../yaourt
makepkg -si && cd ~
```

###### xorg
```bash
sudo pacman -S xorg-server xorg-apps --noconfirm
sudo pacman -S xorg --noconfirm
sudo pacman -S xorg-xinit xterm xorg-xclock --noconfirm

xorg-drivers # Ниже есть драйвера но это вроде тоже
Xorg :0 -configure # После драверов
cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов

```

###### wayland
```bash
sudo pacman -Qi wayland --noconfirm
sudo pacman -S --needed wayland --noconfirm
sudo pacman -S --needed xorg-xwayland xorg-xlsclients glfw-wayland --noconfirm
sudo pacman -S --needed gnome gnome-tweaks nautilus-sendto gnome-nettool gnome-usage gnome-multi-writer adwaita-icon-theme xdg-user-dirs-gtk fwupd arc-gtk-theme --noconfirm
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
```

### Драйвера audio
```bash
sudo pacman -S alsa-utils alsa-plugins --noconfirm
# Настройка громкости
alsamixer
# test
speaker-test -c 2
```

### Gnome ПО
```bash
# Вернём привычные -▢X
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
```

### ПО
```bash
sudo pacman -Syu gnome-browser-connector --noconfirm
sudo pacman -S gcc perl make --noconfirm
sudo pacman -S firefox --noconfirm
yaourt -S visual-studio-code-bin
yaourt -S extension-manager
yaourt -S intellij-idea-community-edition
yaourt -S gnome-extensions-cli
yaourt -S kate --noconfirm
yaourt -S keepassxc --noconfirm
yaourt -S telegram-desktop --noconfirm
yaourt -S dbeaver --noconfirm
yaourt -S docker --noconfirm
yaourt -S docker-compose --noconfirm
usermod -aG docker ilinium
flatpak remote-add --user flathub https://flathub.org/repo/flathub.flatpakrepo
```

##### WINE
```bash
# Enable multilib
vim /etc/pacman.conf
# find [multilib] and decoment it
sudo pacman -S wine wine-mono wine-gecko
yaourt -S Bottles
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

### Terminal Visual
```bash
export PS1="\[\e[96m\]\u@\h\[\e[0m\]~\[\e[33m\]\w\[\e[0m\]$ "
vim ~/.bashrc
```


### Gnome visual
###### Шрифты
Установить в терминале шрифт Dejavu-sans-mono 14
###### Расширения Gnome
- Dash to Panel
- ArchMenu
- Tray icons: Reloaded
- AppIndicator and KStatusNotifierItem Support
- Gtk4 Desktop Icons NG (DING)
- Add to desktop


### Удаляем ненужное(для меня) предустановленное по
```bash
sudo pacman -R gitg --noconfirm
sudo pacman -R polari --noconfirm
sudo pacman -R endeavour --noconfirm
yaourt -R geary --noconfirm
```

### Удаляем игры
```bash
yaourt -R gnome-sudoku --noconfirm
yaourt -R gnome-mines --noconfirm
yaourt -R five-or-more --noconfirm
yaourt -R gnome-robots --noconfirm
yaourt -R gnome-mahjongg --noconfirm
yaourt -R gnome-2048 --noconfirm
yaourt -R gnome-tetravex --noconfirm
yaourt -R hitori --noconfirm
yaourt -R gnome-nibbles --noconfirm
yaourt -R gnome-taquin --noconfirm
yaourt -R gnome-klotski --noconfirm
yaourt -R gnome-chess --noconfirm
yaourt -R four-in-a-row --noconfirm
yaourt -R iagno --noconfirm
yaourt -R swell-foop --noconfirm
yaourt -R tali --noconfirm
yaourt -R quadrapassel --noconfirm
```
