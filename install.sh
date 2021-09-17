#!/bin/sh
#
echo "Installing Dependency"
apt-get -qq update
apt-get -qq install -y tightvncserver xfce4 xfce4-goodies docker.io docker-compose
echo "Configuring tightVNC"
echo "Enter a Password for VNC"
vncserver
if [ $? -eq 0]; then
	echo "VNC password set";
else
	echo "VNC password failed to set. Must be 8 characters"
	exit 1
vncserver -kill :1
echo "Setting vnc desktop as xfce4"
echo 'startxfce4 &' >> $HOME/.vnc/xstartup
echo "Moving dirs"
mkdir /opt/guac_services/
cp docker-compose.yml /opt/guac_services/
cp -r nginx/ /opt/guac_services/.
echo "Preparing folder init and creating /opt/guac_services/init/initdb.sql"
mkdir /opt/guac_services/init >/dev/null 2>&1
mkdir -p /opt/guac_services/nginx/ssl >/dev/null 2>&1
chmod -R +x /opt/guac_services/init
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > /opt/guac_services/init/initdb.sql
echo "Creating SSL certificates"
openssl req -nodes -newkey rsa:2048 -new -x509 -keyout /opt/guac_services/nginx/ssl/self-ssl.key -out /opt/guac_services/nginx/ssl/self.cert -subj '/C=US/ST=MD/L=Baltimore/O=Company/OU=IT/CN=www.custom.domain'
echo "Setting Up Guacamole Service"
cp guacamole.service /etc/systemd/system/.
chown root:root /etc/systemd/system/guacamole.service
chmod 0644 /etc/systemd/system/guacamole.service
echo "Setting Up VNC Service"
sed -i "s|USER_HOME|$HOME|g" vncserver.service
cp vncserver.service /etc/systemd/system/.
chown root:root /etc/systemd/system/vncserver.service
chmod 0644 /etc/systemd/system/vncserver.service
systemctl daemon-reload
echo "enabling Services"
systemctl enable guacamole.service
systemctl enable vncserver.service
echo "Starting Services"
systemctl start vncserver.service
systemctl start guacamole.service
echo "IMPORTANT: Navigate to your guacamole at https://<url or IP>/guac and change the Default User"
echo "Default user credentials: guacadmin/guacadmin"
echo "You can use your own certificates by placing the private key in /opt/guac_services/nginx/ssl/self-ssl.key and the cert in /opt/guac_services/nginx/ssl/self.cert"
echo "You can customize your Webpage by changing the index.html in /opt/guac_services/nginx/data/www/ and by editing /opt/guac_services/nginx/mysite.template"
echo "done"
