#!/bin/bash
# Desktop clicks pass no URI. tel:/sip: handlers pass the clicked URI.
uri="$1"
if [ -z "$uri" ]; then
  exec linphone --config=/home/spot/.config/linphone/linphonerc
fi
echo "$uri" >> /tmp/lol
# Append ?method=call if not already present
if [[ "$uri" != *"?method="* ]]; then
  uri="${uri}@192.168.0.126?method=call"
fi
# Change to +27 format
# Hacky, but should work fine and keep other +27 or +xx existing as is
#uri=$(echo $uri | sed 's/^tel:0/tel:+27/g')
echo "$uri" >> /tmp/lol
# Launch Linphone with the transformed URI
exec linphone --config=/home/spot/.config/linphone/linphonerc "$uri"
