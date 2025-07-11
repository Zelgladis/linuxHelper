### KDE
```bash
sudo pacman -S --needed xorg sddm
sudo pacman -S --needed plasma
sudo pacman -S --needed qt6
sudo pacman -S --needed networkmanager-openvpn --noconfirm
sudo pacman -S networkmanager-openconnect --noconfirm


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

# delete kmix for plasma 6
```bash
sudo pacman -R kmix --noconfirm
```

# games **need chek**
```bash
yay -R khangman --noconfirm
yay -R kanagram --noconfirm
yay -R blinken --noconfirm
yay -R bomber --noconfirm
yay -R bovo --noconfirm
yay -R granatier --noconfirm
yay -R kajongg --noconfirm
yay -R kapman --noconfirm
yay -R katomic --noconfirm
yay -R kblackbox --noconfirm
yay -R kblocks --noconfirm
yay -R kbounce --noconfirm
yay -R kbreakout --noconfirm
yay -R kdiamond --noconfirm
yay -R kfourinline --noconfirm
yay -R kgoldrunner --noconfirm
yay -R kigo --noconfirm
yay -R killbots --noconfirm
yay -R kiriki --noconfirm
yay -R kjumpingcube --noconfirm
yay -R klickety --noconfirm
yay -R klines --noconfirm
yay -R kmahjongg --noconfirm
yay -R kmines --noconfirm
yay -R knavalbattle --noconfirm
yay -R knetwalk --noconfirm
yay -R knights --noconfirm
yay -R kolf --noconfirm
yay -R kollision --noconfirm
yay -R konquest --noconfirm
yay -R kpat --noconfirm
yay -R kreversi --noconfirm
yay -R kshisen --noconfirm
yay -R ksirk --noconfirm
yay -R ksnakeduel --noconfirm
yay -R kspaceduel --noconfirm
yay -R ksquares --noconfirm
yay -R ksudoku --noconfirm
yay -R ktuberling --noconfirm
yay -R kubrick --noconfirm
yay -R lskat --noconfirm
yay -R palapeli --noconfirm
yay -R picmi --noconfirm
yay -R skladnik --noconfirm
```
