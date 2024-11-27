### Bluetooth
```bash
sudo pacman -S bluez bluez-utils

# Если отстуствует btusb
sudo modprobe btusb

sudo systemctl enable bluetooth.service
```
