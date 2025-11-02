#!/bin/sh

echo "Setting up Headset as system default"
/etc/ccs/setup_headset.sh >> /tmp/thisthing

echo "Setting up SIP profile"
mkdir -p /root/.config/linphone
#cp /etc/ccs/linphonerc  /root/.config/linphone/
echo "Overwriting jwm"
rm -rf /root/.jwm
cp -r /etc/ccs/.jwm /root
cp /etc/ccs/xdg/templates/_root_.jwmrc /root/.jwmrc
echo "Overwriting jwm tray"
cp /etc/ccs/jwm* /root/.jwm/
echo "Setting wallpaper"
set_bg /etc/ccs/wall.svg
echo "Configuring SIP extentions..."
/etc/ccs/sipconfig.sh
echo "Configuring Firefox"
mkdir -p /etc/firefox/policies
cp /etc/ccs/firefox/policies/* /etc/firefox/policies
set_bg /etc/ccs/wall.svg
