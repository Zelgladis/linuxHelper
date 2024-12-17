```bash
sudo pacman -S base-devel
sudo pacman -S lxqt
sudo pacman -S breeze-icons
sudo pacman -S libstatgrab 
sudo pacman -S libsysstat
sudo pacman -S featherpad

sudo pacman -S sddm
sudo pacman -S sddm-breeze
sudo systemctl enable sddm
# или
sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
sudo pacman -S lightdm-gtk-greeter-settings --noconfirm
sudo pacman -S lightdm-webkit2-greeter --noconfirm
sudo systemctl enable lightdm

```

### Theme sddm
``` bash
sudo vim /usr/lib/sddm/sddm.conf.d/default.conf
```
```
[Theme]
# current theme name
 Current=breeze
```