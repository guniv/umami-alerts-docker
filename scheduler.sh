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

# Create crontab file
CRONTAB_FILE="/etc/cron.d/umami-alerts"
cat > "$CRONTAB_FILE" << EOF
# For details see man 4 crontabs
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
MAILTO=""
${TZ:+"TZ=$TZ"}

# Run umami-alerts at scheduled time
$SCHEDULE root timeout 300 umami-alerts --config /config/config.toml >> /var/log/cron.log 2>&1

EOF

chmod 0644 "$CRONTAB_FILE"

# Create log file and set permissions
touch /var/log/cron.log
chmod 0666 /var/log/cron.log

# Stop any existing cron processes
pkill cron || true

# Start cron with debugging enabled and in the foreground
exec cron -f -L 15