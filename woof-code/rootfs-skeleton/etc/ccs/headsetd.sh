#!/bin/bash
#
# Detects USB headset via PipeWire (wpctl) and updates ~/.linphonerc accordingly
#

LINPHONE_RC="/home/spot/.config/linphone/linphonerc"


detect_usb_audio() {
  for i in USB headset Headset; do
    if wpctl status | grep $i | grep vol | grep -i stereo | grep -oP '\d+\.\s*\K[^[]*' | head -n1 | xargs | grep $i >/dev/null; then
      wpctl status | grep $i | grep vol | grep -i stereo | grep -oP '\d+\.\s*\K[^[]*' | head -n1 | xargs
      break
    fi
  done
}

detect_usb_audio_mic() {
   for i in USB headset Headset; do
     if wpctl status | grep $i | grep vol | grep -i mono | grep -oP '\d+\.\s*\K[^[]*' | head -n1 | xargs | grep $i >/dev/null; then
       wpctl status | grep $i | grep vol | grep -i mono  | grep -oP '\d+\.\s*\K[^[]*' | head -n1 | xargs
       break
     fi
   done
}

USB_DEV="PulseAudio Unknown: $(detect_usb_audio)"
USB_DEV_MIC="PulseAudio Unknown: $(detect_usb_audio_mic)"
sed -i "
  s|^playback_dev_id=.*|playback_dev_id=${USB_DEV}|
  s|^ringer_dev_id=.*|ringer_dev_id=${USB_DEV}|
  s|^capture_dev_id=.*|capture_dev_id=${USB_DEV_MIC}|
  s|^media_dev_id=.*|media_dev_id=${USB_MEDIA}|
"  $LINPHONE_RC

echo "[INFO] Switched Linphone sound devices to OUTPUT: $USB_DEV"
echo "[INFO] Switched Linphone sound devices to INPUT: $USB_DEV_MIC"
