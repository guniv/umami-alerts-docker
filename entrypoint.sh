#!/bin/bash
set -e

# Set timezone if specified
if [ -n "$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

# Default schedule: Daily at 8 AM
SCHEDULE=${CRON_SCHEDULE:-"0 8 * * *"}

# Create cron job
echo "$SCHEDULE umami-alerts --config /config/config.toml >> /var/log/cron.log 2>&1" > /etc/cron.d/umami-alerts
chmod 0644 /etc/cron.d/umami-alerts

# Load environment variables
printenv | grep -v "no_proxy" > /etc/environment

# Start cron in foreground
echo "Starting cron with schedule: $SCHEDULE"
echo "Timezone: $(cat /etc/timezone)"
echo "Current time: $(date)"

# Start cron and tail logs
cron && tail -f /var/log/cron.log