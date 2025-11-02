#!/bin/bash

# Get full status
STATUS=$(wpctl status)

# Extract Sinks (playback) section
SINKS_SECTION=$(echo "$STATUS" | sed -n '/Sinks:/,/Sources:/p' | sed '$d')
SOURCES_SECTION=$(echo "$STATUS" | sed -n '/Sources:/,/Input Devices:/p' | sed '$d')

# Function to extract node ID by name pattern
get_node_id() {
    local section="$1"
    local pattern="$2"
    echo "$section" | grep -i "$pattern" | grep -o '│.*[0-9]' | grep -o '[0-9]*' | head -n 1
}

# Priority: USB → Bluetooth → Headset → fallback to default
HEADSET_SINK_ID=""
HEADSET_SOURCE_ID=""

# Try USB
HEADSET_SINK_ID=$(get_node_id "$SINKS_SECTION" "usb")
HEADSET_SOURCE_ID=$(get_node_id "$SOURCES_SECTION" "usb")

# If no USB, try Bluetooth
if [ -z "$HEADSET_SINK_ID" ]; then
    HEADSET_SINK_ID=$(get_node_id "$SINKS_SECTION" "bluez")
    HEADSET_SOURCE_ID=$(get_node_id "$SOURCES_SECTION" "bluez")
fi

# If still nothing, try "headset"
if [ -z "$HEADSET_SINK_ID" ]; then
    HEADSET_SINK_ID=$(get_node_id "$SINKS_SECTION" "headset")
    HEADSET_SOURCE_ID=$(get_node_id "$SOURCES_SECTION" "headset")
fi

# Fallback: use current default (marked with *)
if [ -z "$HEADSET_SINK_ID" ]; then
    HEADSET_SINK_ID=$(echo "$STATUS" | grep -A 10 'Sinks:' | grep '^*' | grep -o '[0-9]*' | head -n 1)
fi
if [ -z "$HEADSET_SOURCE_ID" ]; then
    HEADSET_SOURCE_ID=$(echo "$STATUS" | grep -A 10 'Sources:' | grep '^*' | grep -o '[0-9]*' | head -n 1)
fi

# Set defaults
[ -n "$HEADSET_SINK_ID" ] && wpctl set-default "$HEADSET_SINK_ID"
[ -n "$HEADSET_SOURCE_ID" ] && wpctl set-default "$HEADSET_SOURCE_ID"

# Optional: log for debugging
echo "Default sink: $HEADSET_SINK_ID, source: $HEADSET_SOURCE_ID" > /tmp/headset-default.log
