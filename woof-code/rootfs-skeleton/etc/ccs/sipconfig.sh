#!/bin/bash

echo 1 > /tmp/sipconf
IP=$(ifconfig | grep 192.168 | sed 's/.*inet addr:\(.*\) Bcast.*/\1/g')
FINAL_DIGIT=$(echo $IP | awk -F . {'print $NF'})
EXTENTION=$(expr $FINAL_DIGIT + 6000)
echo $FINAL_DIGIT
echo $EXTENTION

# TODO:

# Find ip for this mac, if not exists, store it so its locked.
# mysql/php thing for that.
# for now, set the extention to the IP + 6000 as per instruction

echo "Changing extention to $EXTENTION"
sed -i "s/username: .*/username: $EXTENTION/g" ~/.config/jami/dring.yml
