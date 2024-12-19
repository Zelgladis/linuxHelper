### Network
```bash
sudo mkdir /run/network
sudo touch /run/network/ifstate
sudo nano /etc/network/interfaces

nmcli dev status
nmcli con add type ethernet ifname <интерфейс>
sudo systemctl restart NetworkManager
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

### btrfs
```bash
sudo apt install btrfs-progs
```