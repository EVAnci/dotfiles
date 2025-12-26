#!/bin/bash

# This file is intended to be a fast way to config
# my daily distro (Desktop)

confirm() {
  local msg="$1"
  local response

  while true; do
    # -p prints message, -r avoid \ escapes
    read -rp "$msg [Y/n]: " response
    
    # Converts lowercase
    case "${response,,}" in
      y|yes|"") return 0 ;; # "" makes default option (no need to press intro)
      n|no)     return 1 ;;
      *)        echo "[!] Invalid answer: valid options are 'y' or 'n'." ;;
    esac
  done
}

# After a fresh install

# AUR Helper
aur_helper() {
  if paru &> /dev/null ; then
    echo '[+] paru already installed.'
  else
    echo '[+] Installing paru'
    sudo pacman -S git nvim base-devel --needed
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    echo '[+] paru: Installation finish'
    cd .. 
    rm -rf paru 
  fi
}
if confirm "[?] Install paru?"; then
  aur_helper
else
  echo "[+] paru not installed. Continuing..."
fi

# Update mirrors
echo "[+] Updating mirrorlist"
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sudo reflector --latest 60 --sort rate --fastest 15 --threads 12 --save /etc/pacman.d/mirrorlist

# As my GPU is an NVIDIA GTX 1050Ti, I need pascal 
# drivers. They are provided on the nvidia-580xx-dkms 
# package.

# First install dkms packege
sudo pacman -S dkms linux-headers --needed
paru -S nvidia-580xx-dkms nvidia-580xx-utils nvidia-580xx-settings opencl-nvidia-580xx

# Configure GRUB timeout and dkms start
grub_timeout=120
kernel_parameters="quiet loglevel=3 nvidia_drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1"
sed -i.bkp "s/^GRUB_TIMEOUT=[^\"]*/GRUB_TIMEOUT=$grub_timeout/" /etc/default/grub
sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=[^\"]*/GRUB_CMDLINE_LINUX_DEFAULT=$kernel_parameters/" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Configure mkinitcpio modules
modules="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
sed -i.bkp "s/^MODULES=*/MODULES=($modules)/" /etc/mkinitcpio.conf
sudo sed -i '/^HOOKS=/s/ kms//' /etc/mkinitcpio.conf

sudo mkinitcpio -P

sudo mkdir -p /etc/pacman.d/hooks/ && sudo mv ./hooks/nvidia.hook /etc/pacman.d/hooks/

# Preserve video memory (suspension)
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

# Use NVENC and NVDEC for multimedia and power profiles 
# to save energy
sudo pacman -S libva-nvidia-driver libva-utils tuned tuned-ppd acpid
sudo systemctl enable tuned.service 
sudo systemctl enable tuned-ppd.service 
sudo systemctl enable dbus.service
sudo systemctl enable acpid.service
