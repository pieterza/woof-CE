#!/bin/bash

echo "started from $0" >> /tmp/sipconf
while ! ifconfig | grep 192.168 > /dev/null; do
  echo "Waiting for IP to show: $(ifconfig)" >> /tmp/sipconf
  sleep 1
done
IP=$(ifconfig | grep 192.168 | sed 's/.*inet addr:\(.*\) Bcast.*/\1/g')
FINAL_DIGIT=$(echo $IP | awk -F . {'print $NF'})
EXTENTION=$(expr $FINAL_DIGIT + 6000)
echo $FINAL_DIGIT
echo $EXTENTION

echo $FINAL_DIGIT >> /tmp/sipconf
echo $EXTENTION >> /tmp/sipconf
# TODO:

cd /etc/ccs/
echo "Changing extention to $EXTENTION"
rm -rf /home/spot/.config/liphone
rm -rf /root/.config/linphone
sed -i "s/9987/$EXTENTION/g" linphonerc
mkdir -p /home/spot/.config/linphone
cp linphonerc /home/spot/.config/linphone
mkdir -p /root/.config/linphone
chown spot:spot /home/spot/.config
ln -s /home/spot/.config/linphone/linphonerc /root/.config/linphone/
chown spot:spot /root/.config/linphone/linphonerc
