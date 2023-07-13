#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

VERSION=16.0
VERSION_IOTBOX=22.11
REPO=https://github.com/odoo/odoo.git

CLONE_DIR="/home/pi/odoo"

rm -rf /home/pi/iot-helpers
cp -rv iot-helpers /home/pi/

sudo chown -R pi:pi /home/pi/iot-helpers

# put configs in place
sudo cp -frv install/cups/ /etc/cups/

rm -rfv "${CLONE_DIR}"

if [ ! -d $CLONE_DIR ]; then
    echo "Clone Github repo"
    mkdir -pv "${CLONE_DIR}"
    git clone -b ${VERSION} --no-local --no-checkout --depth 1 ${REPO} "${CLONE_DIR}"
    cd "${CLONE_DIR}"
    git config core.sparsecheckout true
    echo "addons/web
addons/hw_*
addons/point_of_sale/tools/posbox/
odoo/
odoo-bin" | tee --append .git/info/sparse-checkout > /dev/null
    git read-tree -mu HEAD
fi

#echo "addons/hw_drivers/iot_devices/" > /home/pi/odoo/.git/info/exclude
echo "addons/hw_drivers/tools/helpers.py" >> /home/pi/odoo/.git/info/exclude

cp -fv /home/pi/iot-helpers/helpers.py addons/hw_drivers/tools/helpers.py

sudo chown pi:pi -R /home/pi/odoo/

# put our new helper in place => uncomment if above does not match
#cp -fv "../iot-helpers/helpers.py" "${CLONE_DIR}/addons/hw_drivers/tools/helpers.py"

# set 

sudo sh -c "echo '%pi ALL=NOPASSWD: /bin/systemctl restart odoo' >> /etc/sudoers"
sudo sh -c "echo '%pi ALL=NOPASSWD: /bin/systemctl restart nginx' >> /etc/sudoers"
sudo sh -c "echo '%pi ALL=NOPASSWD: /bin/systemctl restart led-status' >> /etc/sudoers"
sudo sh -c "echo '%pi ALL=NOPASSWD: /sbin/nginx -s reload' >> /etc/sudoers"
# ap = subprocess.call(['systemctl', 'is-active', '--quiet', 'hostapd'])

sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/nginx" /etc/
sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/ssl" /etc/

sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/network" /etc/
sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_before_init/etc/udev/rules.d/" /etc/udev/rules.d/
#sudo cp -frv  "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_before_init/etc/locale.gen" /etc/
sudo cp -frv  "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/lightdm" /etc/
sudo cp -frv  "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/X11" /etc/
sudo cp -frv  ${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/var/www/iot.jpg /var/www/iot.jpg

sudo cp -frv addons/point_of_sale/tools/posbox/overwrite_after_init/etc/cron.daily/odoo /etc/cron.daily/odoo

# don't want this module to load, need it for some stuff!
cp -frv  "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/home/pi/odoo/addons/point_of_sale/__manifest__.py" /home/pi/odoo/addons/point_of_sale/__manifest__.py

echo "* setting iot box version"
sudo mkdir -pv /var/odoo
sudo chown pi:pi /var/odoo
sudo sh -c "echo ${VERSION_IOTBOX} > /var/odoo/iotbox_version"
sudo chown -R pi:pi /var/odoo


# Check if the service unit file already exists
if [[ -e /etc/systemd/system/odoo.service ]]; then
    echo "Service 'odoo' already exists."
    sudo systemctl is-active --quiet service && sudo systemctl stop odoo
    sudo rm -v /etc/systemd/system/odoo.service
fi

MODULES=$(ls /home/pi/odoo/addons/ -m -w0 | tr -d ' ')

echo -e "* Create ODOO service file"
cat <<EOF >temp_service
# /etc/systemd/system/odoo.service
[Unit]
Description=Odoo-iot
After=network.target

[Service]
Type=simple
SyslogIdentifier=odoo_idpl
PermissionsStartOnly=true
User=pi
Group=pi
Environment="PATH=/home/pi/.local/bin:/usr/share/Modules/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
ExecStart=/home/pi/.venv37/bin/python3 /home/pi/odoo/odoo-bin --load hw_drivers,hw_escpos,hw_posbox_homepage,point_of_sale,web -c /home/pi/iot-helpers/odoo.conf --max-cron-threads=0
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

sudo mv temp_service /etc/systemd/system/odoo.service
# Reload systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable --now odoo

echo "* Create LED service"

# Check if the service unit file already exists
if [[ -e /etc/systemd/system/led-status.service ]]; then
    echo "Service 'led-status' already exists."
    sudo systemctl is-active --quiet led-status && sudo systemctl stop led-status
    sudo rm -fv /etc/systemd/system/led-status.service
fi

echo -e "* Create service file"
cat <<EOF >temp_service
[Unit]
Description=Led Status
After=sysinit.target local-fs.target

[Service]
Type=simple
ExecStart=/home/pi/iot-helpers/led_status.sh

[Install]
WantedBy=basic.target
EOF

sudo mv temp_service /etc/systemd/system/led-status.service

# Reload systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable --now led-status

echo reload nginx
sudo nginx -s reload

sudo /sbin/reboot

