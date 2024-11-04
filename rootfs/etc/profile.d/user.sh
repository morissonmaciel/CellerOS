#!/bin/sh

usermod -aG wheel $(whoami)
sed -i "s/^User=.*/User=$(whoami)/" /etc/sddm.conf.d/steamos.conf