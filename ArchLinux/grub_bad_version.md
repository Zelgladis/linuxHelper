``` bash
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