#!/bin/bash
uri="$1"
echo $uri >> /tmp/lol
# Append ?method=call if not already present
if [[ "$uri" != *"?method="* ]]; then
  uri="${uri}?method=call"
fi
echo $uri >> /tmp/lol
# Launch Linphone with the transformed URI
exec linphone "$uri"
