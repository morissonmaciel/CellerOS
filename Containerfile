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

RUN rpm-ostree install \
        gamescope && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

RUN rpm-ostree install \
        rsms-inter-fonts && \
        gsettings set org.gnome.desktop.interface font-name 'Inter Regular 11' && \
        gsettings set org.gnome.desktop.interface document-font-name 'Inter Regular 11' &&
        gsettings set org.gnome.desktop.interface text-scaling-factor 0.96 &&
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Installing and configuring minimal default GNOME Shell extensions
RUN rpm-ostree install \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-blur-my-shell && \
        gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com && \
        gnome-extensions enable dash-to-dock@micxgx.gmail.com && \
        gnome-extensions enable blur-my-shell@aunetx
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

# Setting Yaru as default icon and sound theme
RUN rpm-ostree install \
        yaru-icon-theme \
        yaru-sound-theme && \
        gsettings set org.gnome.desktop.interface icon-theme 'Yaru' && \
        gsettings set org.gnome.desktop.interface cursor-theme 'Yaru' && \
        gsettings set org.gnome.desktop.sound theme-name 'Yaru' && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

# Apply some Steam tweaks
RUN rm -f /etc/environment && \
    echo "STEAM_FORCE_DESKTOPUI_SCALING=2" >> /etc/environment && \
    [ -f ~/.steam/steam/steam_dev.cfg ] && rm ~/.steam/steam/steam_dev.cfg || true && \
    echo -e "@nClientDownloadEnableHTTP2PlatformLinux 0\n@fDownloadRateImprovementToAddAnotherConnection 1.0\n@cMaxInitialDownloadSources 15" >> ~/.steam/steam/steam_dev.cfg && \
    /usr/libexec/containerbuild/cleanup.sh && \
    ostree container commit

RUN sed -i 's@PrefersNonDefaultGPU=true@PrefersNonDefaultGPU=false@g' /usr/share/applications/steam.desktop && \
    ostree container commit

# Cleanup & Finalize
RUN mkdir -p "/etc/xdg/autostart" && \
    mv "/usr/share/applications/steam.desktop" "/etc/xdg/autostart/steam.desktop" && \
    [ -f /usr/share/applications/nvtop.desktop ] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop || true && \
    [ -f /usr/share/applications/btop.desktop ] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop || true && \
    ostree container commit
