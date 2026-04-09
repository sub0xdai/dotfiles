#!/bin/bash

# Melbourne Coordinates
LAT="-37.814"
LON="144.9633"

# Fetch data from Open-Meteo
WEATHER_JSON=$(curl -sL "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m")

# Verify curl succeeded and the response contains the temperature
if [ $? -eq 0 ] && echo "$WEATHER_JSON" | grep -q "temperature_2m"; then
    # Extract the temperature using jq
    TEMP=$(echo "$WEATHER_JSON" | jq '.current.temperature_2m')

    # Optional: Round the number (removes decimals for a cleaner look)
    TEMP_ROUNDED=$(printf "%.0f" "$TEMP")

    echo "${TEMP_ROUNDED}°C"
else
    echo "Offline"
fi
