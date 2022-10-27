#!/bin/sh

# args
CADDYIndexPage="https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html

# configs
mkdir -p /etc/caddy/ /etc/xray/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
#wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget $CADDYIndexPage -O /usr/share/caddy/index.html 
cp -f /conf/Caddyfile /etc/caddy/Caddyfile
cp -f /conf/config.json /etc/xray/config.json

# start
tor &
xray -config /etc/xray/config.json &
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
