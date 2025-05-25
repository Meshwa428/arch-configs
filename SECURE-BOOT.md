# Install Grub
 - Install grub along with other modules

```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --modules="tpm all_video cat ls boot chain echo configfile efifwsetup gettext gfxmenu gfxterm gzio linux loopback lsefi lsefimmap lsefisystab lssal memdisk minicmd normal ntfs search reboot regexp password_pbkdf2 png probe search_fs_uuid search_fs_file search_label sleep smbios video keyboard" --disable-shim-lock
```

 - ensure that `tpm` is present in the modules list.
 - Make sure to `--disable-shim-lock`.


# Sign all the bootable files
## Before signing files
 - Go to Bios -> Security and make sure you are in setup mode
 - Disable secure boot

## Install `sbctl`

```bash
sudo pacman -Sy sbctl
```

## Create and enroll keys

### Create keys
```bash
sudo sbctl create-keys
```

### Enroll keys
```bash
sudo sbctl enroll-keys -m
```

## Signing .efi files
```bash
sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi
sudo sbctl sign -s /boot/vmlinuz-linux
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
```


