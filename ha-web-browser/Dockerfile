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

bashio::log.info "Starting virtual display ${WIDTH}x${HEIGHT}x${DEPTH}"

# Start virtual display
Xvfb :1 -screen 0 ${WIDTH}x${HEIGHT}x${DEPTH} -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for X server
sleep 3

# Start window manager
DISPLAY=:1 openbox &

# Prepare VNC command
VNC_CMD="x11vnc -display :1 -listen localhost -xkb -ncache 10 -forever -shared"

# Add password if configured
if bashio::config.has_value 'password'; then
    bashio::log.info "Setting up VNC password protection"
    echo "$PASSWORD" | x11vnc -storepasswd /tmp/vncpass
    VNC_CMD="$VNC_CMD -rfbauth /tmp/vncpass"
else
    bashio::log.info "No VNC password set"
    VNC_CMD="$VNC_CMD -nopw"
fi

# Start VNC server
$VNC_CMD &
VNC_PID=$!

# Wait for VNC
sleep 3

# Start noVNC web server
bashio::log.info "Starting noVNC web server on port 6080"
cd /opt/novnc && python3 -m websockify --web . 6080 localhost:5900 &
NOVNC_PID=$!

# Wait for noVNC
sleep 3

# Start Chromium browser
bashio::log.info "Starting Chromium browser"
DISPLAY=:1 chromium --no-sandbox --disable-dev-shm-usage --disable-gpu --no-first-run --start-maximized --disable-infobars --disable-web-security --disable-features=VizDisplayCompositor "$HOMEPAGE" &
BROWSER_PID=$!

bashio::log.info "All services started successfully!"

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
        DISPLAY=:1 chromium --no-sandbox --disable-dev-shm-usage --disable-gpu --no-first-run --start-maximized --disable-infobars --disable-web-security --disable-features=VizDisplayCompositor "$HOMEPAGE" &
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