FROM ghcr.io/ublue-os/silverblue-main:41 AS base

COPY rootfs/usr/libexec/containerbuild/cleanup.sh /usr/libexec/containerbuild/cleanup.sh

RUN rpm-ostree override remove \
    ublue-os-update-services \
    htop && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

RUN rpm-ostree install \
    pulseaudio-utils \
    mesa-vulkan-drivers \
    mangohud \
    pipewire-alsa \
    steam && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Installing python3 and some useful packages
RUN rpm-ostree install \
    python-vdf \
    python3-pip \
    python-crcmod \
    python3-icoextract && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

RUN rpm-ostree install \
    gamescope && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Installing and configuring Inter Font as default font
RUN rpm-ostree install \
    rsms-inter-fonts && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Installing and configuring minimal default GNOME Shell extensions
RUN rpm-ostree install \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-blur-my-shell && \
    gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com && \
    gnome-extensions enable dash-to-dock@micxgx.gmail.com && \
    gnome-extensions enable blur-my-shell@aunetx && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

RUN rpm-ostree override remove \
    gnome-classic-session \
    gnome-tour \
    gnome-shell-extension-background-logo \
    gnome-shell-extension-apps-menu && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Installing and configuring sddm
RUN rpm-ostree install \
    sddm && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Homebrew
RUN touch /.dockerenv && \
    mkdir -p /var/home && \
    mkdir -p /var/roothome && \
    curl -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh && \
    chmod +x /tmp/brew-install && \
    /tmp/brew-install && \
    tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Setting Yaru as default icon and sound theme
RUN rpm-ostree install \
    yaru-icon-theme \
    yaru-sound-theme && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Apply Gnome dconf settings to all users
RUN mkdir -p /etc/dconf/db/local.d && \
    echo "[org/gnome/desktop/interface]" > /etc/dconf/db/local.d/00-interface && \
    echo "icon-theme='Yaru'" >> /etc/dconf/db/local.d/00-interface && \
    echo "cursor-theme='Yaru'" >> /etc/dconf/db/local.d/00-interface && \
    echo "[org/gnome/desktop/sound]" > /etc/dconf/db/local.d/00-sound && \
    echo "theme-name='Yaru'" >> /etc/dconf/db/local.d/00-sound && \
    ostree container commit

RUN mkdir -p /etc/dconf/db/local.d && \
    echo "[org/gnome/desktop/interface]" > /etc/dconf/db/local.d/01-fonts && \
    echo "font-name='Inter Regular 11'" >> /etc/dconf/db/local.d/01-fonts && \
    echo "document-font-name='Inter Regular 11'" >> /etc/dconf/db/local.d/01-fonts && \
    echo "text-scaling-factor=0.96" >> /etc/dconf/db/local.d/01-fonts && \
    ostree container commit

# Apply some Steam tweaks
RUN [ -f /etc/skel/.local/share/Steam/steam_dev.cfg ] && rm /etc/skel/.local/share/Steam/steam_dev.cfg || true && \
    mkdir -p /etc/skel/.local/share/Steam && \
    echo -e "@nClientDownloadEnableHTTP2PlatformLinux 0\n@fDownloadRateImprovementToAddAnotherConnection 1.0\n@cMaxInitialDownloadSources 15" >> /etc/skel/.local/share/Steam/steam_dev.cfg && \
    ostree container commit

RUN sed -i 's@PrefersNonDefaultGPU=true@PrefersNonDefaultGPU=false@g' /usr/share/applications/steam.desktop && \
    ostree container commit

# Copy system default files to root filesystem
COPY rootfs/etc /etc
COPY rootfs/usr /usr

RUN chmod 755 /usr/share/gamescope-session-plus/gamescope-session-plus && \
    chmod 644 /usr/share/wayland-sessions/gamescope-session-steam.desktop && \
    chmod 644 /usr/share/wayland-sessions/gamescope-session.desktop && \
    chmod 755 /usr/bin/steamos-polkit-helpers/jupiter-biosupdate && \
    chmod 755 /usr/bin/steamos-polkit-helpers/steamos-select-branch && \
    chmod 755 /usr/bin/steamos-polkit-helpers/steamos-set-hostname && \
    chmod 755 /usr/bin/steamos-polkit-helpers/steamos-set-timezone && \
    chmod 755 /usr/bin/steamos-polkit-helpers/steamos-update && \
    chmod 755 /usr/bin/export-gpu && \
    chmod 755 /usr/bin/gamescope-session-plus && \
    chmod 755 /usr/bin/jupiter-biosupdate && \
    chmod 755 /usr/bin/steam-http-loader && \
    chmod 755 /usr/bin/steamos-select-branch && \
    chmod 755 /usr/bin/steamos-session-select && \
    chmod 755 /usr/bin/steamos-update && \
    chmod 755 /usr/libexec/os-branch-select && \
    ostree container commit


# Set random hostname for the machine
RUN echo "DESKTOP-$(cat /dev/urandom | tr -dc 'A-Z' | head -c 4)" > /etc/hostname && \
    ostree container commit

RUN systemctl enable dconf-update.service && \
    ostree container commit

RUN echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    ostree container commit

# Cleanup & Finalize
RUN mkdir -p "/etc/xdg/autostart" && \
    mv "/usr/share/applications/steam.desktop" "/etc/xdg/autostart/steam.desktop" && \
    [ -f /usr/share/applications/nvtop.desktop ] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop || true && \
    [ -f /usr/share/applications/btop.desktop ] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop || true && \
    ostree container commit
