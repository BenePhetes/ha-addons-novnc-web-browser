ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:latest
FROM $BUILD_FROM

# Install required packages
RUN apk add --no-cache \
    xvfb \
    x11vnc \
    openbox \
    chromium \
    python3 \
    py3-pip \
    git \
    bash \
    curl \
    websockify \
    dbus \
    && rm -rf /var/cache/apk/*

# Install noVNC
WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git novnc \
    && git clone https://github.com/novnc/websockify.git novnc/utils/websockify

# Create run script
RUN cat > /run.sh << 'EOF'
#!/usr/bin/with-contenv bashio

# Get configuration options
RESOLUTION=$(bashio::config 'resolution' '1920x1080')
HOMEPAGE=$(bashio::config 'homepage' 'https://google.com')
PASSWORD=$(bashio::config 'password')

bashio::log.info "Starting Web Browser with noVNC..."
bashio::log.info "Resolution: $RESOLUTION"
bashio::log.info "Homepage: $HOMEPAGE"

# Parse resolution
IFS='x' read -ra RES <<< "$RESOLUTION"
WIDTH=${RES[0]}
HEIGHT=${RES[1]}
DEPTH=${RES[2]:-24}

# Create necessary directories
mkdir -p /tmp/.X11-unix /var/run/dbus
chmod 1777 /tmp/.X11-unix

# Set environment variables to suppress graphics errors
export DISPLAY=:1
export CHROME_LOG_FILE=/dev/null

bashio::log.info "Starting virtual display ${WIDTH}x${HEIGHT}x${DEPTH}"

# Start virtual display with better error handling
Xvfb :1 -screen 0 ${WIDTH}x${HEIGHT}x${DEPTH} -ac +extension GLX +render -noreset -nolisten tcp &
XVFB_PID=$!

# Wait for X server
sleep 3

# Check if X server started
if ! kill -0 $XVFB_PID 2>/dev/null; then
    bashio::log.error "Failed to start Xvfb"
    exit 1
fi

bashio::log.info "Xvfb started successfully (PID: $XVFB_PID)"

# Start window manager
openbox --sm-disable &
sleep 1

# Prepare VNC command - simplified approach
bashio::log.info "Starting VNC server..."

# Add password if configured
if bashio::config.has_value 'password' && [ -n "$PASSWORD" ]; then
    bashio::log.info "Setting up VNC password protection"
    # Use x11vnc's built-in password option instead of storing to file
    x11vnc -display :1 -listen localhost -xkb -forever -shared -passwd "$PASSWORD" -quiet &
else
    bashio::log.info "No VNC password set"
    x11vnc -display :1 -listen localhost -xkb -forever -shared -nopw -quiet &
fi

VNC_PID=$!

# Wait for VNC
sleep 3

# Check if VNC started
if ! kill -0 $VNC_PID 2>/dev/null; then
    bashio::log.error "Failed to start VNC server"
    exit 1
fi

bashio::log.info "VNC server started successfully (PID: $VNC_PID)"

# Start noVNC web server
bashio::log.info "Starting noVNC web server on port 6080"
cd /opt/novnc
python3 -m websockify --web . 6080 localhost:5900 &
NOVNC_PID=$!

# Wait for noVNC
sleep 3

# Check if noVNC started
if ! kill -0 $NOVNC_PID 2>/dev/null; then
    bashio::log.error "Failed to start noVNC"
    exit 1
fi

bashio::log.info "noVNC started successfully (PID: $NOVNC_PID)"

# Start Chromium browser with extensive compatibility flags
bashio::log.info "Starting Chromium browser"
chromium \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-gpu-sandbox \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=TranslateUI,VizDisplayCompositor \
    --disable-extensions \
    --disable-web-security \
    --disable-infobars \
    --no-first-run \
    --no-default-browser-check \
    --start-maximized \
    --window-size=${WIDTH},${HEIGHT} \
    --disable-logging \
    --log-level=3 \
    --silent \
    "$HOMEPAGE" &
BROWSER_PID=$!

sleep 2

# Check if browser started
if ! kill -0 $BROWSER_PID 2>/dev/null; then
    bashio::log.error "Failed to start Chromium browser"
    exit 1
fi

bashio::log.info "Chromium started successfully (PID: $BROWSER_PID)"
bashio::log.info "All services started successfully!"
bashio::log.info "Access via Home Assistant UI or http://YOUR_HA_IP:6080/vnc.html"

# Function to cleanup on exit
cleanup() {
    bashio::log.info "Shutting down services..."
    kill $BROWSER_PID $NOVNC_PID $VNC_PID $XVFB_PID 2>/dev/null
    exit 0
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Keep container running and monitor services
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
        chromium \
            --no-sandbox \
            --disable-dev-shm-usage \
            --disable-gpu \
            --disable-gpu-sandbox \
            --disable-software-rasterizer \
            --disable-background-timer-throttling \
            --disable-backgrounding-occluded-windows \
            --disable-renderer-backgrounding \
            --disable-features=TranslateUI,VizDisplayCompositor \
            --disable-extensions \
            --disable-web-security \
            --disable-infobars \
            --no-first-run \
            --no-default-browser-check \
            --start-maximized \
            --window-size=${WIDTH},${HEIGHT} \
            --disable-logging \
            --log-level=3 \
            --silent \
            "$HOMEPAGE" &
        BROWSER_PID=$!
    fi
    sleep 10
done
EOF

RUN chmod a+x /run.sh

# Create necessary directories
RUN mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Set environment variables
ENV DISPLAY=:1

# Expose port
EXPOSE 6080

CMD [ "/run.sh" ]