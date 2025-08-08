# disklayouts/nvme-zfs-encrypted-root.nix
#
# nix-shell -p nvme-cli --command 'nvme format --lbaf=1 /dev/nvme0n1'
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --yes-wipe-all-disks /tmp/disko-zfs-encrypted-root.nix
#
# Node               Generic            SN                Model                                 Namespace  Usage                      Format           FW Rev
# ------------------ ------------------ ----------------- ------------------------------------- ---------- -------------------------- ---------------- --------
# /dev/nvme0n1       /dev/ng0n1         24500K800639      WD Red SN700 4000GB                   0x1          4.00  TB /   4.00  TB      4 KiB +  0 B   11C120WD#
#
# Model: WD Red SN700 4000GB (nvme)
# Disk /dev/nvme0n1: 4001GB
# Sector size (logical/physical): 4096B/4096B
# Partition Table: gpt
# Disk Flags:
#
# Number  Start   End     Size    File system  Name           Flags
# 1      1049kB  4296MB  4295MB  fat32        disk-root-ESP  boot, esp
# 2      4296MB  4001GB  3996GB               disk-root-zfs
#
# NAME                  USED  AVAIL  REFER  MOUNTPOINT
# build1.os            2.01M  3.51T    96K  none
# build1.os/root       1.07M  3.51T   328K  /mnt
# build1.os/root/home   192K  3.51T   192K  /mnt/home
# build1.os/root/nix    192K  3.51T   192K  /mnt/nix
# build1.os/root/srv    192K  3.51T   192K  /mnt/srv
# build1.os/root/var    192K  3.51T   192K  /mnt/var
#
# NAME        SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
# build1.os  3.62T  2.01M  3.62T        -         -     0%     0%  1.00x    ONLINE  /mnt
#
#   pool: build1.os
#  state: ONLINE
# config:
#
# NAME             STATE     READ WRITE CKSUM
# build1.os        ONLINE       0     0     0
#   disk-root-zfs  ONLINE       0     0     0
#
# errors: No known data errors
#
# Filesystem           Size  Used Avail Use% Mounted on
# build1.os/root       3.6T  384K  3.6T   1% /mnt
# /dev/nvme0n1p1       4.0G   32K  4.0G   1% /mnt/boot
# build1.os/root/home  3.6T  256K  3.6T   1% /mnt/home
# build1.os/root/nix   3.6T  256K  3.6T   1% /mnt/nix
# build1.os/root/srv   3.6T  256K  3.6T   1% /mnt/srv
# build1.os/root/var   3.6T  256K  3.6T   1% /mnt/var
#
{
  hostname ? "nixos",
  ...
}:
{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # boot = {
            #   size = "1M";
            #   type = "EF02"; # grub legacy bios boot partition
            # };
            ESP = {
              size = "4G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "nofail" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "${hostname}.os";
              };
            };
          };
        };
      };
    };
    zpool = {
      "${hostname}.os" = {
        type = "zpool";
        # mode = "mirror"; # "mirror|raidz|raidz2|raidz3"
        rootFsOptions = {
          mountpoint = "none";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          "com.sun:auto-snapshot" = "true";
        };
        options.ashift = "12"; # 0: auto, 9: 512b, 12: 4k block-size
        datasets = {
          "root" = {
            type = "zfs_fs";
            options = {
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              #keylocation = "file:///tmp/secret.key";
              keylocation = "prompt";
            };
            mountpoint = "/";
          };
          "root/home" = {
            type = "zfs_fs";
            options.mountpoint = "/home";
            mountpoint = "/home";
          };
          "root/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
            mountpoint = "/nix";
          };
          "root/srv" = {
            type = "zfs_fs";
            options.mountpoint = "/srv";
            mountpoint = "/srv";
          };
          "root/var" = {
            type = "zfs_fs";
            options.mountpoint = "/var";
            mountpoint = "/var";
          };
          "root/var/lib/docker" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/docker";
            mountpoint = "/var/lib/docker";
          };
          "root/var/lib/libvirt" = {
            type = "zfs_fs";
            options.mountpoint = "/var/lib/libvirt";
            mountpoint = "/var/lib/libvirt";
          };
        };
      };
    };
  };
}
