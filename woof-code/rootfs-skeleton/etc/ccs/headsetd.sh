#!/bin/bash
#
# Detects USB headset via PipeWire (wpctl) and updates ~/.linphonerc accordingly
#

LINPHONE_RC="/home/spot/.config/linphone/linphonerc"

detect_usb_audio() {
    wpctl status | grep USB | grep vol | grep -oP '\d+\.\s*\K[^[]*' | head -n1 | xargs
}

USB_DEV="PulseAudio Unknown: $(detect_usb_audio)"

sed -i "
  s|^playback_dev_id=.*|playback_dev_id=${USB_DEV}|
  s|^ringer_dev_id=.*|ringer_dev_id=${USB_DEV}|
  s|^capture_dev_id=.*|capture_dev_id=${USB_DEV}|
  s|^media_dev_id=.*|media_dev_id=${USB_DEV}|
"  $LINPHONE_RC

echo "[INFO] Switched Linphone sound devices to: $USB_DEV"
