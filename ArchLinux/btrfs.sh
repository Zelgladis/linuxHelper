mount /dev/sda2 /mnt
btrfs subvolume create /mnt/@          # для корня
btrfs subvolume create /mnt/@home      # для /home
btrfs subvolume create /mnt/@snapshots # для снапшотов
btrfs subvolume create /mnt/@var       # для /var
umount /mnt


mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/sda2 /mnt
mkdir -p /mnt/{home,.snapshots,var,boot}
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home /dev/sda2 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/sda2 /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,subvol=@var /dev/sda2 /mnt/var
mount /dev/sda1 /mnt/boot
swapon /dev/sda3
