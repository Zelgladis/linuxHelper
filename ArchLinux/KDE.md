### KDE
```bash
sudo pacman -S --needed xorg sddm
sudo pacman -S --needed plasma
sudo pacman -S --needed qt6


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
sudo yay -R khangman --noconfirm
sudo yay -R kanagram --noconfirm
sudo yay -R blinken --noconfirm
sudo yay -R bomber --noconfirm
sudo yay -R bovo --noconfirm
sudo yay -R granatier --noconfirm
sudo yay -R kajongg --noconfirm
sudo yay -R kapman --noconfirm
sudo yay -R katomic --noconfirm
sudo yay -R kblackbox --noconfirm
sudo yay -R kblocks --noconfirm
sudo yay -R kbounce --noconfirm
sudo yay -R kbreakout --noconfirm
sudo yay -R kdiamond --noconfirm
sudo yay -R kfourinline --noconfirm
sudo yay -R kgoldrunner --noconfirm
sudo yay -R kigo --noconfirm
sudo yay -R killbots --noconfirm
sudo yay -R kiriki --noconfirm
sudo yay -R kjumpingcube --noconfirm
sudo yay -R klickety --noconfirm
sudo yay -R klines --noconfirm
sudo yay -R kmahjongg --noconfirm
sudo yay -R kmines --noconfirm
sudo yay -R knavalbattle --noconfirm
sudo yay -R knetwalk --noconfirm
sudo yay -R knights --noconfirm
sudo yay -R kolf --noconfirm
sudo yay -R kollision --noconfirm
sudo yay -R konquest --noconfirm
sudo yay -R kpat --noconfirm
sudo yay -R kreversi --noconfirm
sudo yay -R kshisen --noconfirm
sudo yay -R ksirk --noconfirm
sudo yay -R ksnakeduel --noconfirm
sudo yay -R kspaceduel --noconfirm
sudo yay -R ksquares --noconfirm
sudo yay -R ksudoku --noconfirm
sudo yay -R ktuberling --noconfirm
sudo yay -R kubrick --noconfirm
sudo yay -R lskat --noconfirm
sudo yay -R palapeli --noconfirm
sudo yay -R picmi --noconfirm
sudo yay -R skladnik --noconfirm
```