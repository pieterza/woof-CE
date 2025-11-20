#!/bin/bash

LINPHONE_RC="/home/spot/.config/linphone/linphonerc"

detect_usb_audio() {      # Stereo playback
  wpctl status | grep -iE 'USB|headset' | grep -i stereo | grep vol | grep -oP '^\s*\K\d+(?=\.)' | head -n1
}

detect_usb_audio_mic() {  # Mono input
  wpctl status | grep -iE 'USB|headset' | grep -i mono | grep vol | grep -oP '^\s*\K\d+(?=\.)' | head -n1
}

USB_DEV_ID=$(detect_usb_audio)
USB_DEV_MIC_ID=$(detect_usb_audio_mic)

# Fallback if nothing found (optional but recommended)
[ -z "$USB_DEV_ID" ]     && USB_DEV_ID=$(wpctl inspect @DEFAULT_AUDIO_SINK@   | grep -oP 'id \K\d+')
[ -z "$USB_DEV_MIC_ID" ] && USB_DEV_MIC_ID=$(wpctl inspect @DEFAULT_AUDIO_SOURCE@ | grep -oP 'id \K\d+')

# Linphone still expects PulseAudio-style names with PipeWire-Pulse
USB_DEV="PulseAudio: $USB_DEV_ID"
USB_DEV_MIC="PulseAudio: $USB_DEV_MIC_ID"

sed -i "
  s|^playback_dev_id=.*|playback_dev_id=$USB_DEV|;
  s|^ringer_dev_id=.*|ringer_dev_id=$USB_DEV|;
  s|^capture_dev_id=.*|capture_dev_id=$USB_DEV_MIC|;
  s|^media_dev_id=.*|media_dev_id=$USB_DEV|;
" "$LINPHONE_RC"

echo "[INFO] Switched Linphone to USB headset"
echo "      Output (playback/ringer): $USB_DEV"
echo "      Input  (capture):        $USB_DEV_MIC"
