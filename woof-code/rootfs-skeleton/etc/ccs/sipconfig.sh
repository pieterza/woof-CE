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

echo "Changing extention to $EXTENTION"
sed -i "s/username=.*/username=$EXTENTION/g" ~/.config/linphone/linphonerc
