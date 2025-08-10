#!/usr/bin/with-contenv bashio

# Get configuration options
RESOLUTION=$(bashio::config 'resolution' '1920x1080')
HOMEPAGE=$(bashio::config 'homepage' 'https://google.com')

bashio::log.info "Starting Web Browser addon..."
bashio::log.info "Resolution: ${RESOLUTION}"
bashio::log.info "Homepage: ${HOMEPAGE}"

# Export display settings
export DISPLAY=:0
export RESOLUTION
export HOMEPAGE

# Start supervisor to manage all processes
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
