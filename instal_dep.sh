#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

# Recommends: antiword, graphviz, ghostscript, python-gevent, poppler-utils
export DEBIAN_FRONTEND=noninteractive

# set locale to en_US
echo "set locale to en_US"
echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
sudo sh -c "echo -e 'en_US.UTF-8 UTF-8\n' > /ect/locale.gen"
sudo /sbin/locale-gen

source ~/.bashrc

sudo apt-get update && sudo apt-get -y upgrade
# Do not be too fast to upgrade to more recent firmware and kernel than 4.38
# Firmware 4.44 seems to prevent the LED mechanism from working


PKGS_TO_INSTALL="
    console-data \
    cups \
    cups-ipp-utils \
    dbus \
    dbus-x11 \
    dnsmasq \
    firefox-esr \
    fswebcam \
    git \
    hostapd \
    iw \
    kpartx \
    libcups2-dev \
    libpq-dev \
    lightdm \
    localepurge \
    nginx-full \
    openbox \
    printer-driver-all \
    rsync \
    screen \
    unclutter \
    vim \
    nano \
    x11-utils \
    xdotool \
    xserver-xorg-input-evdev \
    xserver-xorg-video-dummy \
    xserver-xorg-video-fbdev"
    
# KEEP OWN CONFIG FILES DURING PACKAGE CONFIGURATION
# http://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install
sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ${PKGS_TO_INSTALL}

sudo apt-get clean
#localepurge
sudo rm -rfv /usr/share/doc

sudo ln -s /bin/true /bin/tvservice

sudo mkdir -pv /var/log/odoo
sudo chown pi:pi /var/log/odoo

sudo mkdir -pv /var/run/odoo
sudo chown pi:pi /var/run/odoo

sudo usermod -a -G lp pi

sudo groupadd usbusers
sudo usermod -a -G usbusers pi
sudo usermod -a -G lp pi
sudo usermod -a -G input lightdm

sudo  systemctl enable --now nginx


cat <<EOF >temp_rule
SUBSYSTEM=="usb", GROUP="usbusers", MODE="0660"
SUBSYSTEMS=="usb", GROUP="usbusers", MODE="0660"
EOF

sudo rm -fvr /etc/udev/rules.d/99-usb.rules
sudo mv temp_rule /etc/udev/rules.d/99-usb.rules

sudo /sbin/reboot
