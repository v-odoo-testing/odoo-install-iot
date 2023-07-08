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

rm -rf /home/pi/iotpatch
cp -rv iotpatch /home/pi/


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

echo "addons/hw_drivers/iot_devices/" > /home/pi/odoo/.git/info/exclude
echo "addons/hw_drivers/tools/helpers.py" >> /home/pi/odoo/.git/info/exclude

for file in /home/pi/iotpatch/*.iotpatch; do 
    if [ -f "$file" ]; then 
        echo "patch $file" 
        git apply  --ignore-space-change --ignore-whitespace ${file}
    fi 
done

sudo chown pi:pi -R /home/pi/odoo/



# put our new helper in place => uncomment if above does not match
#cp -fv "../iot-helpers/helpers.py" "${CLONE_DIR}/addons/hw_drivers/tools/helpers.py"

# set 

sudo sh -c "echo '%pi ALL=NOPASSWD: /bin/systemctl restart odoo' >> /etc/sudoers"
sudo sh -c "echo '%pi ALL=NOPASSWD: /bin/systemctl restart nginx' >> /etc/sudoers"
sudo sh -c "echo '%pi ALL=NOPASSWD: /bin/systemctl restart led-status' >> /etc/sudoers"
# ap = subprocess.call(['systemctl', 'is-active', '--quiet', 'hostapd'])

# put configs in place
sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/nginx" /etc/
sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/ssl" /etc/
sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/cups" /etc/
sudo cp -frv "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/etc/network" /etc/
cp -frv  "${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/home/pi/odoo/addons/point_of_sale/__manifest__.py" /home/pi/odoo/addons/point_of_sale/__manifest__.py
sudo cp -frv  ${CLONE_DIR}/addons/point_of_sale/tools/posbox/overwrite_after_init/var/www/iot.jpg /var/www/iot.jpg

sudo cp -frv addons/point_of_sale/tools/posbox/overwrite_after_init/etc/cron.daily/odoo /etc/cron.daily/odoo

echo "* setting iot box version"
echo "$VERSION_IOTBOX" > /var/odoo/iotbox_version


# Enable and start the service
sudo systemctl enable nginx
sudo systemctl start nginx

# Check the status of the service
sudo systemctl status nginx


# Define the service name
sudo service_name="odoo"

# Define the service unit file path
service_file="/etc/systemd/system/${service_name}.service"

# Check if the service unit file already exists
if [[ -e "${service_file}" ]]; then
    echo "Service '${service_name}' already exists."
    exit 1
fi

echo -e "* Create service file"
sudo cat <<EOF >"${service_file}"
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
Environment="PATH=/home/pi/.local/bin:/usr/share/Modules/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin; MODULES=$(ls /home/pi/odoo/addons/ -m -w0 | tr -d ' ')"
ExecStart=/usr/bin/python3 /home/pi/odoo-bin --load $MODULES -c /home/pi/odoo/addons/point_of_sale/tools/posbox/configuration/odoo.conf --max-cron-threads=0
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable "${service_name}"
sudo systemctl start "${service_name}"

# Check the status of the service
sudo systemctl status "${service_name}"


echo "* Create LED service"

service_name=led-status
# Define the service unit file path
service_file="/etc/systemd/system/${service_name}.service"

# Check if the service unit file already exists
if [[ -e "${service_file}" ]]; then
    echo "Service '${service_name}' already exists."
    exit 1
fi

echo -e "* Create service file"
sudo cat <<EOF >"${service_file}"
[Unit]
Description=Led Status
After=sysinit.target local-fs.target

[Service]
Type=simple
ExecStart=/home/pi/iot-helpers/led_status.sh

[Install]
WantedBy=basic.target
EOF

# Reload systemd daemon to recognize the new service
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable "${service_name}"
sudo systemctl start "${service_name}"

# Check the status of the service
sudo systemctl status "${service_name}"


