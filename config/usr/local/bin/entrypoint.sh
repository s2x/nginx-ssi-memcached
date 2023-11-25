#!/usr/bin/env sh
IP_ADDR=$(ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//')
echo "Visit http://$IP_ADDR/ to test this ssi include"
exec /usr/bin/supervisord -c /etc/supervisord.conf
