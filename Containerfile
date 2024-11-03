FROM ghcr.io/ublue-os/silverblue-main:41 AS base

RUN rpm-ostree override remove \
    ublue-os-update-services \
    htop && \
    ostree container commit

RUN rpm-ostree install \
        pulseaudio-utils \
        mesa-vulkan-drivers \
        mangohud \
        pipewire-alsa \
        steam && \
    ostree container commit

RUN rpm-ostree install \
        gamescope \
        rsms-inter-fonts && \
    ostree container commit

RUN rpm-ostree install \
        gnome-shell-extension-appindicator \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-blur-my-shell && \
    ostree container commit

RUN rpm-ostree override remove \
        gnome-classic-session \
        gnome-tour \
        gnome-shell-extension-background-logo \
        gnome-shell-extension-apps-menu && \
    ostree container commit

RUN rm -f /etc/environment && \
    echo "STEAM_FORCE_DESKTOPUI_SCALING=2" >> /etc/environment && \
    ostree container commit

RUN sed -i 's@PrefersNonDefaultGPU=true@PrefersNonDefaultGPU=false@g' /usr/share/applications/steam.desktop && \
    ostree container commit

# Cleanup & Finalize
RUN mkdir -p "/etc/xdg/autostart" && \
    mv "/usr/share/applications/steam.desktop" "/etc/xdg/autostart/steam.desktop" && \
    [ -f /usr/share/applications/nvtop.desktop ] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/nvtop.desktop || true && \
    [ -f /usr/share/applications/btop.desktop ] && sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nNoDisplay=true@g' /usr/share/applications/btop.desktop || true && \
    ostree container commit
