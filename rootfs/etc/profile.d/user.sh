#!/bin/sh

_install_decky_loader() {
    echo "Installing Decky Loader..."
    curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh
}

_post_install_helper() {
    sudo usermod -aG wheel $(whoami)
    sudo sed -i "s/^User=.*/User=$(whoami)/" /etc/sddm.conf.d/steamos.conf
    sudo systemctl disable gdm
    sudo systemctl enable sddm

    echo "Please reboot your system to apply changes."
}

alias deckysetup=_install_decky_loader
alias userps=_post_install_helper