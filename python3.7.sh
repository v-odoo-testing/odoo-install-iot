#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

sudo apt update && sudo apt upgrade
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev -y

wget https://www.python.org/ftp/python/3.7.13/Python-3.7.13.tar.xz
tar -xf Python-3.7.13.tar.xz


cd Python-3.7.13
./configure --enable-optimizations --enable-shared
make -j8 build_all
sudo make install

python --version


wget https://bootstrap.pypa.io/get-pip.py
python3.7 get-pip.py
python3.7 -m pip install --upgrade pip

PIP_TO_INSTALL=" pycups \
    babel \
    dateutil \
    decorator \
    docutils \
    jinja2 \
    ldap \
    libsass \
    lxml \
    mako \
    mock \
    netifaces \
    passlib \
    pillow \
    psutil
    psycopg2 \
    pydot \
    pypdf2 \
    qrcode \
    reportlab \
    requests \
    serial \
    python3-tz \
    urllib3 \
    werkzeug"

sudo pip3 install ${PIP_TO_INSTALL}

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
    pysmb==1.2.9.1 \
    cryptocode==0.1"

sudo pip3 install ${PIP_TO_INSTALL}

sudo ln -s /bin/true /bib/tvservice

sudo mkdir -pv /var/log/odoo
sudo chown pi:pi /var/log/odoo

mkdir -pv /var/run/odoo
chown pi:pi /var/run/odoo

sudo usermod -a -G lp pi

sudo groupadd usbusers
sudo usermod -a -G usbusers pi

sudo  systemctl enable --now nginx
