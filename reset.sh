#!/bin/bash
echo "This will delete your existing database (./data/)"
echo "          delete your recordings        (./record/)"
echo "          delete your drive files       (./drive/)"
echo "          delete your certs files       (./nginx/ssl/)"
echo ""
read -p "Are you sure? " -n 1 -r
echo ""   # (optional) move to a new line
WD="/opt/guac_services"
if [[ $REPLY =~ ^[Yy]$ ]]; then # do dangerous stuff
 chmod -R +x -- $WD/init
 sudo rm -r -f $WD/data/ $WD/drive/ $WD/record/ $WD/nginx/ssl/
fi

