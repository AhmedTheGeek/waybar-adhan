#!/bin/bash

# Simple version without jq for JSON generation

# Configuration
CONFIG_FILE="${HOME}/.config/waybar-adhan/config.json"

# Load config or use defaults
if [[ -f "$CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
    LAT=$(jq -r '.latitude // 30.0053' "$CONFIG_FILE" 2>/dev/null)
    LON=$(jq -r '.longitude // 31.1018' "$CONFIG_FILE" 2>/dev/null)
    METHOD=$(jq -r '.calculation_method // 5' "$CONFIG_FILE" 2>/dev/null)
else
    LAT="30.0053"
    LON="31.1018"
    METHOD="5"
fi

# Get current date
DATE=$(date +"%d-%m-%Y")

# Fetch prayer times
URL="http://api.aladhan.com/v1/timings/${DATE}?latitude=${LAT}&longitude=${LON}&method=${METHOD}"
RESPONSE=$(curl -s --connect-timeout 5 --max-time 10 "$URL" 2>/dev/null)

if [[ -z "$RESPONSE" ]]; then
    echo '{"text": "No data", "tooltip": "Unable to fetch prayer times", "class": "error"}'
    exit 0
fi

# Extract prayer times using jq
if ! command -v jq >/dev/null 2>&1; then
    echo '{"text": "jq required", "tooltip": "Please install jq", "class": "error"}'
    exit 0
fi

# Check if response is valid
CODE=$(echo "$RESPONSE" | jq -r '.code // empty' 2>/dev/null)
if [[ "$CODE" != "200" ]]; then
    echo '{"text": "API error", "tooltip": "Invalid API response", "class": "error"}'
    exit 0
fi

# Get current time in minutes
CURRENT_HOUR=$(date +"%H")
CURRENT_MIN=$(date +"%M")
CURRENT_MINS=$((10#$CURRENT_HOUR * 60 + 10#$CURRENT_MIN))

# Find next prayer
PRAYERS=("Fajr" "Dhuhr" "Asr" "Maghrib" "Isha")
NEXT_PRAYER=""
NEXT_TIME=""
MIN_DIFF=1440

for PRAYER in "${PRAYERS[@]}"; do
    PRAYER_TIME=$(echo "$RESPONSE" | jq -r ".data.timings.${PRAYER}" 2>/dev/null)
    if [[ -z "$PRAYER_TIME" ]]; then
        continue
    fi
    
    # Parse prayer time
    PRAYER_HOUR=$(echo "$PRAYER_TIME" | cut -d: -f1)
    PRAYER_MIN=$(echo "$PRAYER_TIME" | cut -d: -f2)
    PRAYER_MINS=$((10#$PRAYER_HOUR * 60 + 10#$PRAYER_MIN))
    
    # Calculate difference
    if [[ $PRAYER_MINS -gt $CURRENT_MINS ]]; then
        DIFF=$((PRAYER_MINS - CURRENT_MINS))
    else
        DIFF=$((1440 - CURRENT_MINS + PRAYER_MINS))
    fi
    
    if [[ $DIFF -lt $MIN_DIFF ]]; then
        MIN_DIFF=$DIFF
        NEXT_PRAYER="$PRAYER"
        NEXT_TIME="$PRAYER_TIME"
    fi
done

# Format time remaining
HOURS=$((MIN_DIFF / 60))
MINS=$((MIN_DIFF % 60))

if [[ $HOURS -gt 0 ]]; then
    TIME_STR="${HOURS}h ${MINS}m"
else
    TIME_STR="${MINS}m"
fi

# Output simple JSON without using jq for generation
TEXT="${NEXT_PRAYER} in ${TIME_STR}"
TOOLTIP="Next prayer: ${NEXT_PRAYER} at ${NEXT_TIME}"

# Manually create JSON to avoid encoding issues
cat <<EOF
{"text": "${TEXT}", "tooltip": "${TOOLTIP}", "class": "prayer-time"}
EOF