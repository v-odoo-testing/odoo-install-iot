#!/usr/bin/env bash

sudo systemctl stop led-status

cd /home/pi/odoo
localbranch=$(git symbolic-ref -q --short HEAD)
localremote=$(git config branch.$localbranch.remote)


git fetch "${localremote}" "${localbranch}" --depth=1
git reset "${localremote}"/"${localbranch}" --hard

git clean -dfx

#cp -fv /home/pi/odoo-install-iot/iot-helpers/helpers.py addons/hw_drivers/tools/helpers.py

# helpers.py
# this script, lets try first
sudo find /home/pi/iotpatch/ -type f -name "*.iotpatch" 2> /dev/null | while read iotpatch; do
    DIR=$(dirname "${iotpatch}")
    BASE=$(basename "${iotpatch%.iotpatch}")
    sudo find "${DIR}" -type f -name "${BASE}" ! -name "*.iotpatch" | while read file; do
        sudo patch -f "${file}" < "${iotpatch}"
    done
done

sudo systemctl start led-status

(sleep 5 && sudo systemctl restart odoo) &
