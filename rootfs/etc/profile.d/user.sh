#!/bin/sh

_post_install_helper() {
    sudo usermod -aG wheel $(whoami)
    sudo sed -i "s/^User=.*/User=$(whoami)/" /etc/sddm.conf.d/steamos.conf
    sudo systemctl disable gdm
    sudo systemctl enable sddm

    echo "Please reboot your system to apply changes."
}

alias userps=_post_install_helper