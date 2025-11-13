#!/bin/bash
#
# auto_linphone_usb_switch.sh
# Detects Axtel USB headset via PipeWire (wpctl) and updates ~/.linphonerc
#

LINPHONE_RC="/home/spot/.config/linphone/linphonerc"
TMP_RC="/tmp/.linphonerc.$$"

# === CONFIGURE YOUR ACTUAL DEVICE NAMES FROM `wpctl status` ===
DEFAULT_PLAYBACK="Built-in Audio Analog Stereo"
DEFAULT_RINGER="Built-in Audio Analog Stereo"
DEFAULT_CAPTURE="Built-in Audio Analog Stereo"

USB_PLAYBACK="Axtel USB Analog Stereo"
USB_RINGER="Axtel USB Analog Stereo"
USB_CAPTURE="Axtel USB Mono"

# Optional: media_dev_id (rarely used, but safe to set)
DEFAULT_MEDIA="$DEFAULT_PLAYBACK"
USB_MEDIA="$USB_PLAYBACK"

# === FUNCTION: detect if Axtel USB is present and active ===
detect_usb_audio() {
    wpctl status | grep -q "Axtel USB"
}

# === FUNCTION: update linphonerc ===
update_linphonerc() {
    local mode="$1"  # "usb" or "default"
    local p_dev r_dev c_dev m_dev

    if [[ "$mode" == "usb" ]]; then
        p_dev="$USB_PLAYBACK"
        r_dev="$USB_RINGER"
        c_dev="$USB_CAPTURE"
        m_dev="$USB_MEDIA"
        echo "[INFO] Switching Linphone → Axtel USB Headset"
    else
        p_dev="$DEFAULT_PLAYBACK"
        r_dev="$DEFAULT_RINGER"
        c_dev="$DEFAULT_CAPTURE"
        m_dev="$DEFAULT_MEDIA"
        echo "[INFO] Switching Linphone → Built-in Audio"
    fi

    # Backup and edit
    cp "$LINPHONE_RC" "$TMP_RC" || { echo "[ERROR] Failed to copy linphonerc"; return 1; }

    sed -i "
        s|^playback_dev_id=.*|playback_dev_id=$p_dev|
        s|^ringer_dev_id=.*|ringer_dev_id=$r_dev|
        s|^capture_dev_id=.*|capture_dev_id=$c_dev|
        s|^media_dev_id=.*|media_dev_id=$m_dev|
    " "$TMP_RC"

    mv "$TMP_RC" "$LINPHONE_RC"
    echo "[SUCCESS] Updated $LINPHONE_RC"
}

# === MAIN LOOP ===
last_state=""

echo "[START] Linphone USB auto-switch daemon started."

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
