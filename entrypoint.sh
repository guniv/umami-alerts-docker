#!/bin/bash
set -e

# Set timezone if specified
if [ -n "$TZ" ]; then
    ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
    echo "$TZ" > /etc/timezone
fi

# Default schedule: Daily at 8 AM
SCHEDULE=${CRON_SCHEDULE:-"0 8 * * *"}

# Create cron job with environment preservation
echo "#!/bin/bash" > /run-cron.sh
echo "set -a" >> /run-cron.sh
echo ". /etc/environment" >> /run-cron.sh
echo "umami-alerts --config /config/config.toml" >> /run-cron.sh
chmod +x /run-cron.sh

# Add cron job
echo "$SCHEDULE /run-cron.sh >> /proc/1/fd/1 2>&1" > /etc/cron.d/umami-alerts
chmod 0644 /etc/cron.d/umami-alerts

# Load environment variables
printenv > /etc/environment

# Start services
echo "Starting cron with schedule: $SCHEDULE"
echo "Timezone: $(cat /etc/timezone)"
echo "Current time: $(date)"
service rsyslog start
cron

# Keep container running
tail -f /dev/null