#!/bin/sh
set -e

# Set timezone if specified
if [ -n "$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

# Default schedule: Daily at 8 AM
SCHEDULE=${CRON_SCHEDULE:-"0 8 * * *"}

# Create cron job
echo "$SCHEDULE umami-alerts --config /config/config.toml" > /etc/cron.d/umami-alerts
chmod 0644 /etc/cron.d/umami-alerts

# Apply cron job
crontab /etc/cron.d/umami-alerts

# Start cron in foreground
echo "Starting cron with schedule: $SCHEDULE"
cron -f