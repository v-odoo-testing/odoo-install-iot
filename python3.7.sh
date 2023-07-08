#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

sudo apt update && sudo apt upgrade
wget https://www.python.org/ftp/python/3.7.13/Python-3.7.13.tar.xz
tar -xf Python-3.7.13.tar.xz
sudo mv Python3.7.13 /opt/Python3.7
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev -y
cd /opt/Python3.7/
./configure --enable-optimizations --enable-shared
make -j
sudo make install

wget https://bootstrap.pypa.io/get-pip.py
python3.7 get-pip.py
python3.7 -m pip install --upgrade pip
