#!/bin/bash
#
# auto_linphone_usb_switch.sh
# Detects USB headset via PipeWire (wpctl) and updates ~/.linphonerc accordingly
#

LINPHONE_RC="/home/spot/.config/linphone/linphonerc"
TMP_RC="/tmp/.linphonerc.$$"

# === CONFIGURE YOUR DEVICE NAMES ===
DEFAULT_PLAYBACK="ALSA Unknown: Intel 82801AA-ICH"
DEFAULT_RINGER="ALSA Unknown: Intel 82801AA-ICH"
DEFAULT_CAPTURE="ALSA Unknown: Intel 82801AA-ICH"
DEFAULT_MEDIA="PulseAudio Unknown: Built-in Audio Analog Stereo"

USB_PLAYBACK="ALSA Unknown: USB Headset"
USB_RINGER="ALSA Unknown: USB Headset"
USB_CAPTURE="ALSA Unknown: USB Headset"
USB_MEDIA="PulseAudio Unknown: USB Headset Analog Stereo"

# === FUNCTION: detect if USB audio device exists ===
detect_usb_audio() {
    wpctl status | grep -Eqi 'usb.*(headset|audio|stereo)'
}

# === FUNCTION: update linphonerc ===
update_linphonerc() {
    local mode="$1"   # "usb" or "default"

    cp "$LINPHONE_RC" "$TMP_RC" || exit 1

    if [[ "$mode" == "usb" ]]; then
        sed -i "
            s|^playback_dev_id=.*|playback_dev_id=${USB_PLAYBACK}|
            s|^ringer_dev_id=.*|ringer_dev_id=${USB_RINGER}|
            s|^capture_dev_id=.*|capture_dev_id=${USB_CAPTURE}|
            s|^media_dev_id=.*|media_dev_id=${USB_MEDIA}|
        " "$TMP_RC"
        echo "[INFO] Switched Linphone sound devices → USB headset"
    else
        sed -i "
            s|^playback_dev_id=.*|playback_dev_id=${DEFAULT_PLAYBACK}|
            s|^ringer_dev_id=.*|ringer_dev_id=${DEFAULT_RINGER}|
            s|^capture_dev_id=.*|capture_dev_id=${DEFAULT_CAPTURE}|
            s|^media_dev_id=.*|media_dev_id=${DEFAULT_MEDIA}|
        " "$TMP_RC"
        echo "[INFO] Reverted Linphone sound devices → default audio"
    fi

    mv "$TMP_RC" "$LINPHONE_RC"
}

# === MAIN LOOP ===
last_state=""

while true; do
    if detect_usb_audio; then
        state="usb"
    else
        state="default"
    fi

    if [[ "$state" != "$last_state" ]]; then
        update_linphonerc "$state"
        last_state="$state"
    fi

    sleep 5
done
