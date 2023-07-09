#!/usr/bin/env bash

sudo systemctl stop led-status

cd /home/pi/odoo
localbranch=$(git symbolic-ref -q --short HEAD)
localremote=$(git config branch.$localbranch.remote)


git fetch "${localremote}" "${localbranch}" --depth=1
git reset "${localremote}"/"${localbranch}" --hard

git clean -dfx

cp -fv /home/pi/iot-helpers/helpers.py addons/hw_drivers/tools/helpers.py
cp -frv  "addons/point_of_sale/tools/posbox/overwrite_after_init/home/pi/odoo/addons/point_of_sale/__manifest__.py" /home/pi/odoo/addons/point_of_sale/__manifest__.py

sudo chown pi:pi -R /home/pi/odoo/

sudo systemctl start led-status

(sleep 5 && sudo systemctl restart odoo) &
