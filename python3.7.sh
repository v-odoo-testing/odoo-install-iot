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

sudo /sbin/ldconfig

sudo ln -sf /usr/local/bin/python3 /usr/bin/python3

python3 --version

sudo apt-get install libsasl2-dev libldap2-dev libssl-dev

#wget https://bootstrap.pypa.io/get-pip.py
#python3.7 get-pip.py
#python3.7 -m pip install --upgrade pip

PIP_TO_INSTALL=" pycups \
    Babel \
    python-dateutil \
    decorator \
    docutils \
    jinja2 \
    python-ldap \
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
    pyserial \
    pytz \
    urllib3 \
    cryptography==2.6.1 \
    pyopenssl==19.0.0 \
    werkzeug \
    dbus-python \
    num2words"

sudo pip3 install ${PIP_TO_INSTALL}

# odoo info....
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

