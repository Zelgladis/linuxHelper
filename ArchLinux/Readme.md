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

### Разметка дисков

```bash
fdisk -l
fdisk /dev/диск_для_разметки 
# или этой
cfdisk /dev/sda
```
###### Нажимает n для создания необходимых раздлв(личное предпочтения)
```bash
/dev/sda1 # ROOT
/dev/sda2 # Efi 1G
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

### Установка ArchLinux
```bash
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
```

###### Предварительная настройка ArchLinux
```bash
arch-chroot /mnt
```
###### **Europe/Saratov** ваш регион/город
```bash
ln -sf /usr/share/zoneinfo/Europe/Saratov /etc/localtime 
```
###### Синхронизация часов
```bash
hwclock --systohc
```
### Локализация
###### Найти и раскоментить строки **en_US.UTF-8 UTF-8** и **ru_RU.UTF-8 UTF-8**
```bash
pacman -S nano
nano /etc/locale.gen
```
###### Генерация локали в систему
```bash
locale-gen
```
###### Создайте файл **/etc/locale.conf** и задайте переменной LANG необходимое значение
```bash
nano /etc/locale.conf
```
```text
LANG=ru_RU.UTF-8
```
###### Если вы меняли раскладку клавиатуры или шрифт, сделайте эти изменения постоянными, прописав их в файле **vconsole.conf**: 
```bash
nano /etc/vconsole.conf
```
```text
KEYMAP=ru
FONT=cyr-sun16
```

### Настройка сети
###### Создайте файл hostname: 
```bash
nano /etc/hostname
```
```text
ariko
```
###### Отредактируйте файл hoss:
 ```bash
nano /etc/hosts
```
```text
127.0.0.1 localhost
::1 localhot
127.0.1.1 ariko.myDomain ariko
```

### Пароль суперпользователя
```bash
passwd
```

### Доп по(необходимое):
```bash
pacman -Suy
# Для автоматического получения сетевых настроек установите dhcpcd и добавить в автозапуск
pacman -S dhcpcd
systemctl enable dhcpcd
# Установите пакет grub и efibootmgr
pacman -S grub efibootmgr os-prober hwinfo
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

```bash
grub-install /dev/sda --efi-dir=/efi/
# Перегенерируйте initramfs
mkinitcpio -p linux
# Запустите автоматическую настройку grub
grub-mkconfig -o /boot/grub/grub.cfg
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

### Установка Графической оболчки(Gnome) и менеджера(gdm)
```bash
pacman -S gnome gnome-extra
pacman -S gdm
pacman -S networkmanager
pacman -S sudo
systemctl enable gdm.service
systemctl enable NetworkManager.service
# Шрифты:
pacman -S ttf-opensans ttf-dejavu ttf-hack ttf-ubuntu-font-family
```

### Создание пользователя и настройка sudo
```bash
useradd -m -g users -G wheel -s /bin/bash ilinium
passwd ilinium
# Предоставить членам группы wheel доступ к sudo: 
# в файле /etc/sudoers разкоментить %wheel      ALL=(ALL:ALL) ALL
nano /etc/sudoers
```

### Доп по(на выбор):
###### Лучше установить
```bash
pacman -S wget 
pacman -S yajl
pacman -S git 
pacman -S base-devel
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

sudo nano /etc/pacman.conf
```

###### xorg
```bash
pacman -S xorg-server xorg-utils xorg-apps
pacman -S xorg
pacman -S xorg-xinit xterm xorg-xclock

xorg-drivers # Ниже есть драйвера но это вроде тоже
Xorg :0 -configure # После драверов
cp /root/xorg.conf.new /etc/X11/xorg.conf # После драйверов

```

###### wayland
```bash
pacman -Qi wayland
sudo pacman -S --needed wayland
pacman -S --needed xorg-xwayland xorg-xlsclients glfw-wayland
pacman -S --needed gnome gnome-tweaks nautilus-sendto gnome-nettool gnome-usage gnome-multi-writer adwaita-icon-theme xdg-user-dirs-gtk fwupd arc-gtk-theme
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
pacman -S xf86-video-vesa
```

### Драйвера audio
```bash
pacman -S alsa-utils alsa-plugins
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
