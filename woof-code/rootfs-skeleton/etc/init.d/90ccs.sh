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
#echo "Configuring Firefox"
#mkdir -p /etc/firefox/policies
#cp /etc/ccs/firefox/policies/* /etc/firefox/policies
#cp /etc/ccs/homefirefox/firefox/j1pg8r1a.default-esr/prefs.js /home/spot/.mozilla/firefox/j1pg8r1a.default-esr/prefs.js
#cp /etc/ccs/homefirefox/firefox/j1pg8r1a.default-esr/logins* /home/spot/.mozilla/firefox/j1pg8r1a.default-esr/
#
#echo 'export no_proxy="localhost,127.0.0.1,192.168.0.0/16,.customercaresolutions.local,ag,ag.customercaresolutions.local,dc,dco"' >> /home/spot/.bashrc 
#echo 'export NO_PROXY=$no_proxy' >> /home/spot/.bashrc
#echo 'export no_proxy="localhost,127.0.0.1,192.168.0.0/16,.customercaresolutions.local,ag,ag.customercaresolutions.local,dc,dco"' >> /home/spot/.bash_profile
#echo 'export NO_PROXY=$no_proxy' >> /home/spot/.bash_profile
cp -r /etc/ccs/chrome-iso-profile/ /tmp/
chown -R spot:spot /tmp/chrome-iso-profile
chown -R spot:spot /home/spot/.bash*
set_bg /etc/ccs/wall.svg
