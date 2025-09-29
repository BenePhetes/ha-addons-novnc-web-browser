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

# Parse resolution
IFS='x' read -ra RES <<< "$RESOLUTION"
WIDTH=${RES[0]}
HEIGHT=${RES[1]}
DEPTH=${RES[2]:-24}

mkdir -p /tmp/.X11-unix /var/run/dbus
chmod 1777 /tmp/.X11-unix

export DISPLAY=:1
export CHROME_LOG_FILE=/dev/null

bashio::log.info "Starting Xvfb..."
Xvfb :1 -screen 0 ${WIDTH}x${HEIGHT}x${DEPTH} -ac +extension GLX +render -noreset -nolisten tcp &
XVFB_PID=$!
sleep 3

if ! kill -0 $XVFB_PID 2>/dev/null; then
    bashio::log.error "Failed to start Xvfb"
    exit 1
fi

bashio::log.info "Starting window manager..."
openbox --sm-disable &
sleep 1

bashio::log.info "Starting VNC server..."
if bashio::config.has_value 'password' && [ -n "$PASSWORD" ]; then
    x11vnc -display :1 -listen localhost -xkb -forever -shared -passwd "$PASSWORD" -quiet &
else
    x11vnc -display :1 -listen localhost -xkb -forever -shared -nopw -quiet &
fi
VNC_PID=$!
sleep 3

if ! kill -0 $VNC_PID 2>/dev/null; then
    bashio::log.error "Failed to start VNC"
    exit 1
fi

bashio::log.info "Starting noVNC..."
cd /opt/novnc
python3 -m websockify --web . 6080 localhost:5900 &
NOVNC_PID=$!
sleep 3

if ! kill -0 $NOVNC_PID 2>/dev/null; then
    bashio::log.error "Failed to start noVNC"
    exit 1
fi

COMMON_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --no-first-run --no-default-browser-check --window-size=${WIDTH},${HEIGHT}"

if [ "$KIOSK_MODE" = "true" ]; then
    COMMON_FLAGS="$COMMON_FLAGS --kiosk"
else
    COMMON_FLAGS="$COMMON_FLAGS --start-maximized"
fi

start_browser() {
    case "$BROWSER" in
        brave)
            bashio::log.info "Starting Brave browser"
            brave-browser $COMMON_FLAGS "$HOMEPAGE" &
            ;;
        opera)
            bashio::log.info "Starting Opera browser"
            opera $COMMON_FLAGS "$HOMEPAGE" &
            ;;
        *)
            bashio::log.error "Unknown browser: $BROWSER"
            exit 1
            ;;
    esac
    BROWSER_PID=$!
}

start_browser
sleep 2

if ! kill -0 $BROWSER_PID 2>/dev/null; then
    bashio::log.error "Failed to start browser"
    exit 1
fi

bashio::log.info "All services started! 🚀"

cleanup() {
    bashio::log.info "Shutting down..."
    kill $BROWSER_PID $NOVNC_PID $VNC_PID $XVFB_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

while true; do
    if ! kill -0 $XVFB_PID 2>/dev/null || ! kill -0 $VNC_PID 2>/dev/null || ! kill -0 $NOVNC_PID 2>/dev/null; then
        bashio::log.error "Service died, restarting container..."
        exit 1
    fi
    if ! kill -0 $BROWSER_PID 2>/dev/null; then
        bashio::log.warning "Browser died, restarting..."
        start_browser
    fi
    sleep 10
done