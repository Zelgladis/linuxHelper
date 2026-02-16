### Бесконечно крутит октлючить plymouth
# В буут меню E добавить и удалить splash
plymouth.enable=0 disablehooks=plymouth

Limine
Temporary

You can temporarily edit (add, remove, or change) boot options during boot if you hit E at selection.

Options are on the cmdline line.
Permanent

You can also apply parameters persistently by editing the boot loader configuration.

Edit limine.conf ( ex: $ESP/EFI/limine/limine.conf ) on the cmdline or kernel_cmdline line.
OR
Edit /etc/default/limine and place options on the KERNEL_CMDLINE[default]+= line, creating it if necessary.
Afterwards to update limine:
sudo limine-update




### Grub
Temporary

You can temporarily edit (add, remove, or change) boot options during boot if you hit E at selection.

Find the line beginning with linux that should appear similar to this:
linux /boot/vmlinuz-6.12-x86_64 root=UUID=0a01099a-1e33-489a-a2de-10104e8492f5 rw quiet
Permanent

You can also apply parameters persistently by editing the boot loader configuration.

Edit /etc/default/grub on the GRUB_CMDLINE_LINUX line between quotes.
Afterwards to update grub:
sudo grub-mkconfig -o /boot/grub/grub.cfg

### To remove Plymouth completely
Remove the packages

sudo pacman -Rns plymouth-git plymouth-kcm cachyos-plymouth-theme cachyos-plymouth-bootanimation 

(the above is the common minimum, but you may have extra packages such as for themes)
Remove from initram

Edit /etc/mkinitcpio.conf and remove plymouth from HOOKS.
Afterwards to rebuild initram run:

sudo mkinitcpio -P

(after rebuilding initram refresh the bootloader, as in the following section, even if bootloader options remain unchanged)
Remove the boot options

Please consult the previous section for how to remove the splash option from your boot loader.

And reboot of course.