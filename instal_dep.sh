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
locale-gen
source ~/.bashrc

apt-get update && apt-get -y upgrade
# Do not be too fast to upgrade to more recent firmware and kernel than 4.38
# Firmware 4.44 seems to prevent the LED mechanism from working

PKGS_TO_INSTALL="
    console-data \
    cups \
    cups-ipp-utils \
    dbus \
    dnsmasq \
    fswebcam \
    git \
    iw \
    kpartx \
    libcups2-dev \
    libpq-dev \
    localepurge \
    nginx-full \
    printer-driver-all \
    python3-cups \
    python3 \
    python3-babel \
    python3-dateutil \
    python3-decorator \
    python3-dev \
    python3-docutils \
    python3-jinja2 \
    python3-ldap \
    python3-libsass \
    python3-lxml \
    python3-mako \
    python3-mock \
    python3-netifaces \
    python3-passlib \
    python3-pil \
    python3-pip \
    python3-psutil \
    python3-psycopg2 \
    python3-pydot \
    python3-pypdf2 \
    python3-qrcode \
    python3-reportlab \
    python3-requests \
    python3-serial \
    python3-tz \
    python3-urllib3 \
    python3-werkzeug \
    rsync \
    nano"

# KEEP OWN CONFIG FILES DURING PACKAGE CONFIGURATION
# http://serverfault.com/questions/259226/automatically-keep-current-version-of-config-files-when-apt-get-install
sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ${PKGS_TO_INSTALL}

sudo apt-get clean
#localepurge
sudo rm -rfv /usr/share/doc

# python-usb in wheezy is too old
# the latest pyusb from pip does not work either, usb.core.find() never returns
# this may be fixed with libusb>2:1.0.11-1, but that's the most recent one in raspios
# so we install the latest pyusb that works with this libusb.
# Even in stretch, we had an error with langid (but worked otherwise)
# We fixe the version of evdev to 1.2.0 because in 1.3.0 we have a RuntimeError in 'get_event_loop()'
PIP_TO_INSTALL="
    evdev==1.2.0 \
    gatt \
    polib \
    pycups \
    pyusb \
    v4l2 \
    pysmb==1.2.9.1 \
    cryptocode==0.1"

sudo pip3 install ${PIP_TO_INSTALL}

sudo mkdir -pv /var/log/odoo
sudo chown pi:pi /var/log/odoo

mkdir -pv /var/run/odoo
chown pi:pi /var/run/odoo

sudo usermod -a -G lp pi

sudo groupadd usbusers
sudo usermod -a -G usbusers pi


sudo sh -c  "systemctl enable --now nginx"
