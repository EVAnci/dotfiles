# OpenCode Instructions for Dotfiles

This repository manages Arch Linux system configurations and user dotfiles.

## System Configuration (`scripts/`)
- The main entrypoint for system setup is `scripts/config.sh`.
- **WARNING:** `scripts/config.sh` modifies critical system files (e.g., `/etc/default/grub`, `/etc/mkinitcpio.conf`). Do not run this on systems that are not Arch Linux or that do not match the expected NVIDIA hardware (GTX 1050Ti/Pascal).
- It installs AUR packages using `paru`.

## Dotfiles
- This repo contains user-level configuration files in the root directory and `.config/`.
- Key files: `.bashrc`, `.zshrc`, and directory `.config/`.
- Ensure changes are safe and portable before committing.

## Setup Requirements
- The repository assumes an Arch Linux environment.
- Required packages for development/editing: `hunspell-es_ar`, `pyright`, `texlab` (as per `README.md`).
