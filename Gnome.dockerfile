# Use the base image
FROM ghcr.io/morissonmaciel/gamer-archos:latest

# Assuring latest mesa and vulkan drivers
RUN pacman -S --noconfirm mesa lib32-mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver libva-utils

# Install Gnome and its dependencies
RUN pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
RUN pacman -S --noconfirm gnome gdm
RUN pacman -S --noconfirm gnome-tweaks gnome-shell-extensions

# Get rid of epiphany browser
RUN pacman -Rc --noconfirm epiphany

# Configuring flatpak
RUN pacman -S --noconfirm flatpak-xdg-utils
RUN flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install firefox using flatpak
RUN flatpak install -y flathub org.mozilla.firefox

# Set the default target to graphical
RUN systemctl set-default graphical.target
RUN systemctl enable gdm