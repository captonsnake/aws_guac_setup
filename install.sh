#!/bin/bash
#
echo "Installing Dependency"
sudo apt-get -qq update
sudo apt-get -qq install -y tightvncserver xfce4 xfce4-goodies docker.io docker-compose
echo "Configuring tightVNC"
echo "Enter a Password for VNC if not already ran"
vncserver
if [[ $? -eq 0 ]]; then
	echo "VNC password set";
else
	echo "VNC password failed to set. Must be 8 characters"
	vncserver -kill :1
	exit 1
fi
vncserver -kill :1
echo "Setting vnc desktop as xfce4"
echo 'startxfce4 &' >> $HOME/.vnc/xstartup
echo "Moving dirs"
sudo mkdir /opt/guac_services/
sudo cp docker-compose.yml /opt/guac_services/
sudo cp -r nginx/ /opt/guac_services/.
echo "Preparing folder init and creating /opt/guac_services/init/initdb.sql"
sudo mkdir /opt/guac_services/init >/dev/null 2>&1
sudo docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > ./init/initdb.sql
sudo cp ./init/initdb.sql /opt/guac_services/init
sudo chmod -R +x /opt/guac_services/init
echo "Creating SSL certificates"
sudo mkdir -p /opt/guac_services/nginx/ssl >/dev/null 2>&1
sudo openssl req -nodes -newkey rsa:2048 -new -x509 -keyout /opt/guac_services/nginx/ssl/self-ssl.key -out /opt/guac_services/nginx/ssl/self.cert -subj '/C=US/ST=MD/L=Baltimore/O=Company/OU=IT/CN=www.custom.domain'
echo "Setting Up Guacamole Service"
sudo cp guacamole.service /etc/systemd/system/.
chown root:root /etc/systemd/system/guacamole.service
sudo chmod 0644 /etc/systemd/system/guacamole.service
echo "Setting Up VNC Service"
sed -i "s|USER_HOME|$HOME|g" vncserver.service
sudo cp vncserver.service /etc/systemd/system/.
sudo chown root:root /etc/systemd/system/vncserver.service
sudo chmod 0644 /etc/systemd/system/vncserver.service
sudo systemctl daemon-reload
echo "enabling Services"
sudo systemctl enable guacamole.service
sudo systemctl enable vncserver.service
echo "Starting Services"
sudo systemctl start vncserver.service
sudo systemctl start guacamole.service
echo "IMPORTANT: Navigate to your guacamole at https://<url or IP>/guac and change the Default User"
echo "Default user credentials: guacadmin/guacadmin"
echo "You can use your own certificates by placing the private key in /opt/guac_services/nginx/ssl/self-ssl.key and the cert in /opt/guac_services/nginx/ssl/self.cert"
echo "You can customize your Webpage by changing the index.html in /opt/guac_services/nginx/data/www/ and by editing /opt/guac_services/nginx/mysite.template"
echo "done"
