#!/bin/sh

echo "Setting up SIP profile"
mkdir -p /root/.config/jami
cp /etc/ccs/dring.yml  /root/.config/jami/
echo "Overwriting jwm"
rm -rf /root/.jwm
cp -r /etc/ccs/.jwm /root
cp /etc/ccs/xdg/templates/_root_.jwmrc /root/.jwmrc
echo "Overwriting jwm tray"
cp /etc/ccs/jwm* /root/.jwm/
#echo "Setting wallpaper"
#set_wallpaper /usr/share/bliss.svg
