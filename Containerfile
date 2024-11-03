FROM ghcr.io/ublue-os/silverblue-main:41 AS base

RUN rpm-ostree override remove ublue-os-update-services && \
    ostree container commit

RUN rpm-ostree install \
        pulseaudio-utils \
        mesa-vulkan-drivers \
        mangohud \
        pipewire-alsa \
        steam && \
    ostree container commit

RUN rpm-ostree install gamescope && \
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
