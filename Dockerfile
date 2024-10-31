# Build a clean system in /mnt to avoid missing files from NoExtract option in upstream
FROM docker.io/archlinux/archlinux:latest AS rootfs

# Build in chroot to correctly execute hooks, this uses host's Pacman
RUN curl https://raw.githubusercontent.com/archlinux/svntogit-packages/packages/pacman/trunk/pacman.conf -o /etc/pacman.conf
RUN pacman --noconfirm --sync --needed --refresh archlinux-keyring

# Enabling multilib repository
RUN sed -i 's/^#Color/Color/' /etc/pacman.conf
RUN sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
RUN echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
RUN pacman --noconfirm --sync --refresh --sysupgrade

# Perform a clean system installation with latest Arch Linux packages in chroot to correctly execute hooks, this uses host's Pacman
RUN pacman --noconfirm --sync --needed base base-devel sudo
RUN pacman --noconfirm --sync git nano bash-completion
RUN pacman --noconfirm --sync plymouth

# Clock
ARG SYSTEM_OPT_TIMEZONE=Etc/UTC
RUN ln --symbolic --force /usr/share/zoneinfo/${SYSTEM_OPT_TIMEZONE} /etc/localtime
RUN systemctl enable systemd-timesyncd.service

# Keymap hook
ARG SYSTEM_OPT_KEYMAP=us
RUN echo "KEYMAP=${SYSTEM_OPT_KEYMAP}" > /etc/vconsole.conf

# Language
RUN echo 'LANG=en_US.UTF-8' > /etc/locale.conf
RUN echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
RUN locale-gen

# Prepre OSTree integration (https://wiki.archlinux.org/title/Mkinitcpio#Common_hooks)
RUN mkdir -p /etc/mkinitcpio.conf.d
RUN echo "HOOKS=(base systemd plymouth kms autodetect modconf kms keyboard sd-vconsole block filesystems fsck)" > /etc/mkinitcpio.conf.d/gamer-archos.conf

# Install kernel, firmware, microcode, filesystem tools, bootloader and run hooks once:
RUN pacman --noconfirm --sync linux linux-headers linux-firmware amd-ucode dosfstools xfsprogs grub mkinitcpio which

# Networking
RUN pacman --noconfirm --sync networkmanager
RUN systemctl enable NetworkManager.service
RUN systemctl mask systemd-networkd-wait-online.service

# Bluetooth
RUN pacman --noconfirm --sync bluez bluez-utils bluez-tools
RUN systemctl enable bluetooth.service

# Audio
RUN pacman --noconfirm --sync pipewire pipewire-alsa pipewire-jack

# Power management
RUN pacman --noconfirm --sync power-profiles-daemon

# Root password
RUN echo "root:root" | chpasswd

# SSHD
RUN pacman --noconfirm -S openssh
RUN systemctl enable sshd
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# User gamer
RUN useradd -m gamer

# Build AUR packages: Build
USER gamer
RUN mkdir -p /home/gamer/.local/repos
RUN git clone https://aur.archlinux.org/yay-bin.git /home/gamer/.local/repos/yay-bin
RUN cd /home/gamer/.local/repos/yay-bin && makepkg -s --noconfirm
USER root

# Set user gamer password
RUN echo "gamer:gamer" | chpasswd
