#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace

#__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
#__base="$(basename ${__file} .sh)"

# Recommends: antiword, graphviz, ghostscript, python-gevent, poppler-utils
#export DEBIAN_FRONTEND=noninteractive

# set locale to en_US
#echo "set locale to en_US"
#echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc
#echo "export LANG=en_US.UTF-8" >> ~/.bashrc
#echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
#sudo sh -c "echo -e 'en_US.UTF-8 UTF-8\n' > /etc/locale.gen"
#sudo /sbin/locale-gen

#source ~/.bashrc


#!/usr/bin/env bash
sudo sh -c "echo 'pi ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"

sudo apt-get update && sudo apt-get -y upgrade
# Do not be too fast to upgrade to more recent firmware and kernel than 4.38
# Firmware 4.44 seems to prevent the LED mechanism from working

sudo apt-get remove gnome-shell ubuntu-session
sudo apt-get-autoremove

sudo /sbin/reboot now
