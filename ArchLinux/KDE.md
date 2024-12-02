### KDE
```bash
sudo pacman -S --needed xorg sddm
sudo pacman -S --needed plasma kde-applications

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

# games **need chek**
```bash
sudo yaourt -R khangman --noconfirm
sudo yaourt -R kanagram --noconfirm
sudo yaourt -R blinken --noconfirm
sudo yaourt -R bomber --noconfirm
sudo yaourt -R bovo --noconfirm
sudo yaourt -R granatier --noconfirm
sudo yaourt -R kajongg --noconfirm
sudo yaourt -R kapman --noconfirm
sudo yaourt -R katomic --noconfirm
sudo yaourt -R kblackbox --noconfirm
sudo yaourt -R kblocks --noconfirm
sudo yaourt -R kbounce --noconfirm
sudo yaourt -R kbreakout --noconfirm
sudo yaourt -R kdiamond --noconfirm
sudo yaourt -R kfourinline --noconfirm
sudo yaourt -R kgoldrunner --noconfirm
sudo yaourt -R kigo --noconfirm
sudo yaourt -R killbots --noconfirm
sudo yaourt -R kiriki --noconfirm
sudo yaourt -R kjumpingcube --noconfirm
sudo yaourt -R klickety --noconfirm
sudo yaourt -R klines --noconfirm
sudo yaourt -R kmahjongg --noconfirm
sudo yaourt -R kmines --noconfirm
sudo yaourt -R knavalbattle --noconfirm
sudo yaourt -R knetwalk --noconfirm
sudo yaourt -R knights --noconfirm
sudo yaourt -R kolf --noconfirm
sudo yaourt -R kollision --noconfirm
sudo yaourt -R konquest --noconfirm
sudo yaourt -R kpat --noconfirm
sudo yaourt -R kreversi --noconfirm
sudo yaourt -R kshisen --noconfirm
sudo yaourt -R ksirk --noconfirm
sudo yaourt -R ksnakeduel --noconfirm
sudo yaourt -R kspaceduel --noconfirm
sudo yaourt -R ksquares --noconfirm
sudo yaourt -R ksudoku --noconfirm
sudo yaourt -R ktuberling --noconfirm
sudo yaourt -R kubrick --noconfirm
sudo yaourt -R lskat --noconfirm
sudo yaourt -R palapeli --noconfirm
sudo yaourt -R picmi --noconfirm
sudo yaourt -R skladnik --noconfirm
```