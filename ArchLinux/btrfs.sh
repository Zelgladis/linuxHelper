mount /dev/sdb3 /mnt
btrfs subvolume create /mnt/@          # для корня
btrfs subvolume create /mnt/@home      # для /home
btrfs subvolume create /mnt/@snapshots # для снапшотов
btrfs subvolume create /mnt/@var       # для /var
umount /mnt


mount -o noatime,compress=zstd,space_cache=v2,subvol=@ /dev/sdb3 /mnt
mkdir -p /mnt/{home,.snapshots,var,boot}
mount -o noatime,compress=zstd,space_cache=v2,subvol=@home /dev/sdb3 /mnt/home
mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots /dev/sdb3 /mnt/.snapshots
mount -o noatime,compress=zstd,space_cache=v2,subvol=@var /dev/sdb3 /mnt/var
mount /dev/sdb1 /mnt/boot
swapon /dev/sdb2