#!/bin/sh

# Before X, and again in case a savefile still has quick_exec=0.
[ -x /etc/ccs/quick_exec.sh ] && /etc/ccs/quick_exec.sh

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
sleep 1
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
# init spothome
cd -
run-as-spot ls
run-as-spot touch blah
#
chown -R spot:spot /home/spot/.bash*
chown -R spot:spot /etc/ccs
chmod +x /etc/ccs/chrome.sh
set_bg /etc/ccs/wall.svg
sleep 2
# Leave these non-executable. Mode 755 makes the fast mime path treat a
# .desktop file as application/x-executable, which brings the script prompt back.
mkdir -p /root/Desktop
cp /etc/ccs/linphone.desktop /root/Desktop/linphone.desktop
cp /etc/ccs/chrome.desktop /root/Desktop/chrome.desktop
chmod 644 /root/Desktop/linphone.desktop /root/Desktop/chrome.desktop
/etc/ccs/quick_exec.sh

# Cover pcmanfm even when a savefile still has an older .xinitrc.
# Never copy the wrapper onto itself: pcmanfm.real must stay the ELF.
if [ -x /usr/local/lib/libccs-quick-exec.so ] && [ -x /usr/bin/pcmanfm ]; then
	if [ ! -x /usr/bin/pcmanfm.real ] && ! grep -q libccs-quick-exec.so /usr/bin/pcmanfm 2>/dev/null; then
		cp -a /usr/bin/pcmanfm /usr/bin/pcmanfm.real
	fi
	if [ -x /usr/bin/pcmanfm.real ]; then
		cat > /usr/bin/pcmanfm << 'EOF'
#!/bin/sh
export LD_PRELOAD="/usr/local/lib/libccs-quick-exec.so${LD_PRELOAD:+:$LD_PRELOAD}"
exec /usr/bin/pcmanfm.real "$@"
EOF
		chmod 755 /usr/bin/pcmanfm
	fi
fi
