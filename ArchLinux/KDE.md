### KDE
```bash
pacman -S --needed xorg sddm
pacman -S --needed plasma kde-applications

sudo systemctl enable sddm
sudo systemctl enable NetworkManager
```

### Theme sddm
``` bash
sudo nano /usr/lib/sddm/sddm.conf.d/default.conf
```
```
[Theme]
# current theme name
 Current=breeze
```