#!/bin/bash
uri="$1"
echo $uri >> /tmp/lol
# Append ?method=call if not already present
if [[ "$uri" != *"?method="* ]]; then
  uri="${uri}?method=call"
fi
# Change to +27 format
# Hacky, but should work fine and keep other +27 or +xx existing as is
uri=$(echo $uri | sed 's/^tel:0/tell:+27/g')
echo $uri >> /tmp/lol
# Launch Linphone with the transformed URI
exec linphone "$uri"
