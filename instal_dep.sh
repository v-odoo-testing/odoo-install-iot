#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"

# Recommends: antiword, graphviz, ghostscript, python-gevent, poppler-utils
#export DEBIAN_FRONTEND=noninteractive

# set locale to en_US
echo "set locale to en_US"
echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
echo "export LANG=en_US.UTF-8" >> ~/.bashrc
echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc

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
    xserver-xorg-video-fbdev \
    libusb"
    
# KEEP OWN CONFIG FILES DURING PACKAGE CONFIGURATION
# http://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install
sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ${PKGS_TO_INSTALL}

sudo apt-get clean
#localepurge
sudo rm -rfv /usr/share/doc

