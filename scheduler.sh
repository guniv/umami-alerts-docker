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

# Set up environment for cron
echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" > /etc/cron.d/umami-alerts
echo "SHELL=/bin/bash" >> /etc/cron.d/umami-alerts
if [ -n "$TZ" ]; then
    echo "TZ=$TZ" >> /etc/cron.d/umami-alerts
fi

# Create the cron job with proper newline
echo "$SCHEDULE timeout 300 umami-alerts --config /config/config.toml >> /var/log/cron.log 2>&1" >> /etc/cron.d/umami-alerts
echo "" >> /etc/cron.d/umami-alerts  # Add required newline
chmod 0644 /etc/cron.d/umami-alerts

# Create log file and set permissions
touch /var/log/cron.log
chmod 0666 /var/log/cron.log  # Ensure cron can write to the log file

# Start cron in the foreground
cron -f &

# Tail the logs so we can see what's happening
exec tail -f /var/log/cron.log