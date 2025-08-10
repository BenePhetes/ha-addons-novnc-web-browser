#!/usr/bin/with-contenv bashio

# Get configuration
RESOLUTION=$(bashio::config 'resolution')
HOMEPAGE=$(bashio::config 'homepage')
PASSWORD=$(bashio::config 'password')
SCALING=$(bashio::config 'scaling')
COMPRESSION=$(bashio::config 'compression')
QUALITY=$(bashio::config 'quality')

# Define ports
VNC_PORT=5900
NO_VNC_PORT=6080

bashio::log.info "Starting Web Browser Add-on..."
bashio::log.info "Resolution: ${RESOLUTION}"
bashio::log.info "Homepage: ${HOMEPAGE}"

# Set up display
export DISPLAY=:0
export GEOMETRY="${RESOLUTION}x24"

# Create VNC password if specified
if [[ ! -z "${PASSWORD}" ]]; then
    bashio::log.info "Setting VNC password..."
    mkdir -p ~/.vnc
    echo "${PASSWORD}" | vncpasswd -f > ~/.vnc/passwd
    chmod 600 ~/.vnc/passwd
    VNC_ARGS="-rfbauth ~/.vnc/passwd"
else
    bashio::log.info "Starting without password (local network only)"
    VNC_ARGS="-nopw"
fi

# Start Xvfb (Virtual Display)
bashio::log.info "Starting virtual display..."
Xvfb :0 -screen 0 ${GEOMETRY} -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for X server to start
sleep 2

# Start window manager (lightweight)
fluxbox &

# Start VNC Server
bashio::log.info "Starting VNC server..."
x11vnc -display :0 -xkb -rfbport ${VNC_PORT} -shared -forever -o /var/log/x11vnc.log ${VNC_ARGS} &
VNC_PID=$!

# Start websockify (VNC to WebSocket bridge)
bashio::log.info "Starting websockify..."
websockify --web /usr/share/novnc ${NO_VNC_PORT} localhost:${VNC_PORT} &
WEBSOCKIFY_PID=$!

# Wait for VNC to be ready
sleep 3

# Start Chromium browser
bashio::log.info "Starting Chromium browser..."
chromium-browser \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --no-first-run \
    --disable-default-browser-check \
    --disable-infobars \
    --disable-extensions \
    --start-maximized \
    --homepage="${HOMEPAGE}" \
    "${HOMEPAGE}" &
BROWSER_PID=$!

# Start nginx (proxy for better integration)
bashio::log.info "Starting nginx..."
nginx -g 'daemon off;' &
NGINX_PID=$!

# Function to cleanup on exit
cleanup() {
    bashio::log.info "Shutting down services..."
    kill $BROWSER_PID $WEBSOCKIFY_PID $VNC_PID $XVFB_PID $NGINX_PID 2>/dev/null
    exit 0
}

# Set trap for cleanup
trap cleanup SIGTERM SIGINT

# Keep the container running and monitor services
while true; do  # Fixed: added semicolon
    # Check if services are still running
    if ! kill -0 $XVFB_PID 2>/dev/null; then
        bashio::log.error "Xvfb died, restarting..."
        exit 1
    fi
    
    if ! kill -0 $VNC_PID 2>/dev/null; then
        bashio::log.error "VNC server died, restarting..."
        exit 1
    fi
    
    if ! kill -0 $WEBSOCKIFY_PID 2>/dev/null; then
        bashio::log.error "Websockify died, restarting..."
        exit 1
    fi
    
    sleep 30
done