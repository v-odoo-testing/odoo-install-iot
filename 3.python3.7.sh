#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

sudo apt update && sudo apt upgrade
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev -y

sudo apt install software-properties-common -y
sudo apt update
sudo   add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.7-* -y


python3.7 --version

# 
sudo apt-get install libsasl2-dev libldap2-dev libssl-dev libxml2-dev libxslt-dev -y
sudo apt install gobject-introspection libgirepository1.0-dev libcairo2 libcairo2-dev gir1.2-gtk-4.0 -y 

sudo apt install libdbus-glib-1-dev libdbus-1-dev libpq-dev -y

sudo apt-get install libcups2-dev -y


sudo apt-get install libtiff5-dev \
                     libjpeg8-dev libopenjp2-7-dev zlib1g-dev \
                     libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev \
                     libharfbuzz-dev libfribidi-dev libxcb1-dev -y
# PyGobjectsudo apt install dbus-dev

# dependency for gobject-introspection need pycompile the python3-markdown
#sudo ln -sf /bin/true /bin/py3compile


# TODO: Work with virtual env
python3.7 -m venv /home/pi/.venv37

/home/pi/.venv37/bin/python3 -m pip install wheel

# odoo info....
# python-usb in wheezy is too old
# the latest pyusb from pip does not work either, usb.core.find() never returns
# this may be fixed with libusb>2:1.0.11-1, but that's the most recent one in raspios
# so we install the latest pyusb that works with this libusb.
# Even in stretch, we had an error with langid (but worked otherwise)
# We fixe the version of evdev to 1.2.0 because in 1.3.0 we have a RuntimeError in 'get_event_loop()'

PIP_TO_INSTALL=" \
    cryptography==2.6.1 \
    dbus-python \
    num2words \
    asn1crypto==0.24.0 \
    Babel==2.6.0 \
    beautifulsoup4==4.7.1 \
    certifi==2018.8.24 \
    chardet==3.0.4 \
    colorzero==1.1 \
    decorator==4.3.0 \
    docutils==0.14 \
    entrypoints==0.3 \
    evdev==1.2.0 \
    feedparser==5.2.1 \
    gatt==0.2.7 \
    html2text==2018.1.9 \
    html5lib==1.0.1 \
    idna==2.6 \
    Jinja2==2.10 \
    keyring==17.1.1 \
    keyrings.alt==3.1.1 \
    libsass==0.17.0 \
    lxml==4.3.2 \
    Mako==1.0.7 \
    MarkupSafe==1.1.0 \
    mock==2.0.0 \
    netifaces==0.10.4 \
    olefile==0.46 \
    passlib==1.7.1 \
    pbr==4.2.0 \
    Pillow==5.4.1 \
    polib==1.1.1 \
    psutil==5.5.1 \
    psycopg2==2.7.7 \
    pyasn1==0.4.2 \
    pyasn1-modules==0.2.1 \
    pycrypto==2.6.1 \
    pycups==2.0.1 \
    pydot==1.4.1 \
    Pygments==2.3.1 \
    pyinotify==0.9.6 \
    pyOpenSSL==19.0.0 \
    pyparsing==2.2.0 \
    PyPDF2==1.26.0 \
    pyserial==3.4 \
    python-dateutil==2.7.3 \
    python-ldap==3.1.0 \
    pytz==2019.1 \
    pyusb==1.2.1 \
    pyxdg==0.25 \
    qrcode==6.1 \
    reportlab==3.5.13 \
    requests==2.21.0 \
    roman==2.0.0 \
    SecretStorage==2.3.1 \
    six==1.12.0 \
    soupsieve==1.8 spidev==3.5 urllib3==1.24.1
    v4l2==0.2 \
    webencodings==0.5.1 \
    Werkzeug==0.14.1 \
    pysmb==1.2.9.1 \
    cryptocode==0.1"
    
/home/pi/.venv37/bin/python3 -m pip install ${PIP_TO_INSTALL}

/home/pi/.venv37/bin/python3 -m pip install  PyGObject==3.30.4 
/home/pi/.venv37/bin/python3 -m pip install cryptography

/home/pi/.venv37/bin/python3 -m pip install ssh-import-id==5.7

