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

echo "======================================"
echo "Setting up cron job"
echo "Timezone: $(date +%Z)"
echo "Schedule: $SCHEDULE"
echo "Current time: $(date)"
echo "======================================"

# Create the cron job
echo "$SCHEDULE timeout 300 umami-alerts --config /config/config.toml >> /var/log/cron.log 2>&1" > /etc/cron.d/umami-alerts
chmod 0644 /etc/cron.d/umami-alerts

# Create log file
touch /var/log/cron.log

# Start cron in the foreground
cron -f &

# Tail the logs so we can see what's happening
exec tail -f /var/log/cron.log