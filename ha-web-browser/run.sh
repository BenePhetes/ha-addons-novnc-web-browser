#!/bin/bash
set -e

echo "Starting Web Browser Addon..."

# Start supervisor in the background
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# Keep the container running
tail -f /var/log/supervisor/supervisord.log
