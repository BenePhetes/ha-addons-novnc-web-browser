#!/usr/bin/with-contenv bashio

# Get configuration options
RESOLUTION=$(bashio::config 'resolution' '1920x1080')
HOMEPAGE=$(bashio::config 'homepage' 'https://google.com')
PASSWORD=$(bashio::config 'password')
BROWSER=$(bashio::config 'browser' 'brave')
KIOSK_MODE=$(bashio::config 'kiosk_mode' 'false')
SCALING=$(bashio::config 'scaling' 'remote')
COMPRESSION=$(bashio::config 'compression' '6')
QUALITY=$(bashio::config 'quality' '6')

bashio::log.info "Starting Web Browser with noVNC..."
bashio::log.info "Resolution: $RESOLUTION"
bashio::log.info "Homepage: $HOMEPAGE"
bashio::log.info "Browser: $BROWSER"
bashio::log.info "Kiosk Mode: $KIOSK_MODE"
bashio::log.info "Scaling: $SCALING"
bashio::log.info "Compression: $COMPRESSION"
bashio::log.info "Quality: $QUALITY"

# Parse resolution
IFS='x' read -ra RES <<< "$RESOLUTION"
WIDTH=${RES[0]}
HEIGHT=${RES[1]}
DEPTH=${RES[2]:-24}

# Create necessary directories
mkdir -p /tmp/.X11-unix /var/run/dbus
chmod 1777 /tmp/.X11-unix

# Set environment variables
export DISPLAY=:1
export CHROME_LOG_FILE=/dev/null

bashio::log.info "Starting virtual display ${WIDTH}x${HEIGHT}x${DEPTH}"

# Start virtual display
Xvfb :1 -screen 0 ${WIDTH}x${HEIGHT}x${DEPTH} -ac +extension GLX +render -noreset -nolisten tcp &
XVFB_PID=$!
sleep 3

if ! kill -0 $XVFB_PID 2>/dev/null; then
    bashio::log.error "Failed to start Xvfb"
    exit 1
fi

bashio::log.info "Xvfb started successfully (PID: $XVFB_PID)"

# Start window manager
openbox --sm-disable &
sleep 1

# Start VNC server
bashio::log.info "Starting VNC server..."

if bashio::config.has_value 'password' && [ -n "$PASSWORD" ]; then
    bashio::log.info "Setting up VNC password protection"
    x11vnc -display :1 -listen localhost -xkb -forever -shared -passwd "$PASSWORD" -quiet &
else
    bashio::log.info "No VNC password set"
    x11vnc -display :1 -listen localhost -xkb -forever -shared -nopw -quiet &
fi

VNC_PID=$!
sleep 3

if ! kill -0 $VNC_PID 2>/dev/null; then
    bashio::log.error "Failed to start VNC server"
    exit 1
fi

bashio::log.info "VNC server started successfully (PID: $VNC_PID)"

# Start noVNC web server with scaling settings
bashio::log.info "Starting noVNC web server on port 6080"
cd /opt/novnc

# Build websockify command with compression and quality settings
WEBSOCKIFY_CMD="python3 -m websockify --web . 6080 localhost:5900"

# Add compression level
if [ "$COMPRESSION" != "0" ]; then
    WEBSOCKIFY_CMD="$WEBSOCKIFY_CMD --prefer-compression=$COMPRESSION"
fi

# Start websockify
eval $WEBSOCKIFY_CMD &
NOVNC_PID=$!
sleep 3

if ! kill -0 $NOVNC_PID 2>/dev/null; then
    bashio::log.error "Failed to start noVNC"
    exit 1
fi

bashio::log.info "noVNC started successfully (PID: $NOVNC_PID)"

# Common browser flags
COMMON_FLAGS="--no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-gpu-sandbox \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI,VizDisplayCompositor \
    --disable-infobars \
    --no-first-run \
    --no-default-browser-check \
    --window-size=${WIDTH},${HEIGHT} \
    --disable-logging \
    --log-level=3"

# Add kiosk mode if enabled
if [ "$KIOSK_MODE" = "true" ]; then
    bashio::log.info "Enabling kiosk mode"
    COMMON_FLAGS="$COMMON_FLAGS --kiosk"
else
    COMMON_FLAGS="$COMMON_FLAGS --start-maximized"
fi

# Function to start browser
start_browser() {
    case "$BROWSER" in
        brave)
            if command -v brave-browser &> /dev/null; then
                bashio::log.info "Starting Brave browser"
                brave-browser $COMMON_FLAGS "$HOMEPAGE" &
            else
                bashio::log.error "Brave browser not found!"
                exit 1
            fi
            ;;
        opera)
            if command -v opera &> /dev/null; then
                bashio::log.info "Starting Opera browser"
                opera $COMMON_FLAGS "$HOMEPAGE" &
            else
                bashio::log.error "Opera browser not found!"
                exit 1
            fi
            ;;
        *)
            bashio::log.error "Unknown browser: $BROWSER. Please choose 'brave' or 'opera'"
            exit 1
            ;;
    esac
    BROWSER_PID=$!
}

# Start browser
start_browser
sleep 2

if ! kill -0 $BROWSER_PID 2>/dev/null; then
    bashio::log.error "Failed to start browser"
    exit 1
fi

bashio::log.info "Browser started successfully (PID: $BROWSER_PID)"
bashio::log.info "All services started successfully!"
bashio::log.info "Access via Home Assistant UI or http://YOUR_HA_IP:6080/vnc.html"

# Cleanup function
cleanup() {
    bashio::log.info "Shutting down services..."
    kill $BROWSER_PID $NOVNC_PID $VNC_PID $XVFB_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Monitor services
while true; do
    if ! kill -0 $XVFB_PID 2>/dev/null; then
        bashio::log.error "Xvfb died, restarting container..."
        exit 1
    fi
    if ! kill -0 $VNC_PID 2>/dev/null; then
        bashio::log.error "VNC died, restarting container..."
        exit 1
    fi
    if ! kill -0 $NOVNC_PID 2>/dev/null; then
        bashio::log.error "noVNC died, restarting container..."
        exit 1
    fi
    if ! kill -0 $BROWSER_PID 2>/dev/null; then
        bashio::log.warning "Browser died, restarting..."
        start_browser
    fi
    sleep 10
done