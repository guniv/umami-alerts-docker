#!/bin/bash
set -e

# Set timezone if specified
if [ -n "$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
    export TZ
fi

# Default schedule: Daily at 8 AM
SCHEDULE=${CRON_SCHEDULE:-"0 8 * * *"}

# Parse schedule
minute=$(echo "$SCHEDULE" | awk '{print $1}')
hour=$(echo "$SCHEDULE" | awk '{print $2}')

# Validate time format
re='^[0-9*]+$'
if ! [[ $minute =~ $re ]] || ! [[ $hour =~ $re ]]; then
    echo "ERROR: Invalid cron schedule format. Use standard cron syntax."
    exit 1
fi

echo "======================================"
echo "Scheduler started"
echo "Timezone: $(date +%Z)"
echo "Schedule: $hour:$minute * * *"
echo "Current time: $(date)"
echo "First run in 60 seconds..."
echo "======================================"

# Wait for initial startup
sleep 60

while true; do
    current_minute=$(date +%M)
    current_hour=$(date +%H)
    
    # Check if we should run now
    if [[ ("$minute" == "$current_minute" || "$minute" == "*") && \
          ("$hour" == "$current_hour" || "$hour" == "*") ]]; then
        echo "======================================"
        echo "$(date) - Running umami-alerts"
        
        # Run with timeout to prevent hangs
        timeout 300 umami-alerts --config /config/config.toml
        
        echo "$(date) - Completed"
        echo "======================================"
        
        # Sleep to avoid duplicate runs
        sleep 60
    fi
    
    # Check every minute
    sleep 55
done