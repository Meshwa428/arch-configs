## 📥 1. Install GRUB

1. **Ensure TPM support**
   Make sure `tpm` appears in your module list.

2. **Run the installer**

   ```bash
   sudo grub-install \
     --target=x86_64-efi \
     --efi-directory=/boot \
     --bootloader-id=GRUB \
     --modules="tpm all_video cat ls boot chain echo \
     configfile efifwsetup gettext gfxmenu gfxterm gzio \
     linux loopback lsefi lsefimmap lsefisystab lssal \
     memdisk minicmd normal ntfs search reboot regexp \
     password_pbkdf2 png probe search_fs_uuid \
     search_fs_file search_label sleep smbios video keyboard" \
     --disable-shim-lock
   ```

   * `--disable-shim-lock` disables shim locking.
   * The long `--modules` list ensures you have all the bits GRUB needs (TPM, graphics, file-systems, search, etc.).

---

## 🔏 2. Prepare for Secure Boot Signing

### 2.1 Enter BIOS Setup Mode

1. Reboot, enter **BIOS → Security**.
2. Switch to **Setup Mode**.
3. **Disable Secure Boot** for now—this lets you enroll your own keys.

### 2.2 Install `sbctl`

```bash
sudo pacman -Sy sbctl
```

---

## 🔑 3. Create & Enroll Your Signing Keys

1. **Generate key pairs**

   ```bash
   sudo sbctl create-keys
   ```

2. **Enroll keys into firmware**

   ```bash
   sudo sbctl enroll-keys -m
   ```

   > **Note:**
   > On some systems you’ll be prompted to confirm key enrollment in a BIOS setup screen.

---

## 🖋 4. Sign Your EFI Binaries

Run one command per file:

```bash
sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi
sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/GRUB/grubx64.efi
sudo sbctl sign -s /boot/vmlinuz-linux
```

> **Tip:** Any additional EFI executables (e.g. `/boot/EFI/tools/*.efi`) should also be signed!

---

## ✅ 5. Re-enable Secure Boot

1. Reboot into BIOS → Security.
2. **Enable Secure Boot**.
3. Confirm your newly enrolled keys are active.

---

### 🎉 You’re done!

Your system will now boot GRUB under UEFI with your own keys, keeping everything signed and TPM-protected.

