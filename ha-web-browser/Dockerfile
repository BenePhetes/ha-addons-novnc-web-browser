FROM debian:bookworm-slim

# Install S6 overlay for Home Assistant compatibility
ARG S6_OVERLAY_VERSION=3.1.5.0
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# Install bashio
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    && curl -J -L -o /tmp/bashio.tar.gz \
    "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir /tmp/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp/bashio \
    && mv /tmp/bashio/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    && rm -rf /tmp/bashio /tmp/bashio.tar.gz

# Install required packages
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    openbox \
    python3 \
    python3-pip \
    python3-websockify \
    git \
    bash \
    wget \
    gnupg \
    apt-transport-https \
    ca-certificates \
    dbus-x11 \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Install Brave Browser
RUN curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list \
    && apt-get update \
    && apt-get install -y brave-browser \
    && rm -rf /var/lib/apt/lists/*

# Install Opera Browser
RUN wget -qO- https://deb.opera.com/archive.key | gpg --dearmor -o /usr/share/keyrings/opera-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/opera-archive-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" > /etc/apt/sources.list.d/opera-archive.list \
    && apt-get update \
    && apt-get install -y opera-stable \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium as fallback
RUN apt-get update && apt-get install -y chromium \
    && rm -rf /var/lib/apt/lists/*

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
                bashio::log.warning "Brave not found, falling back to Chromium"
                chromium $COMMON_FLAGS "$HOMEPAGE" &
            fi
            ;;
        opera)
            if command -v opera &> /dev/null; then
                bashio::log.info "Starting Opera browser"
                opera $COMMON_FLAGS "$HOMEPAGE" &
            else
                bashio::log.warning "Opera not found, falling back to Chromium"
                chromium $COMMON_FLAGS "$HOMEPAGE" &
            fi
            ;;
        chromium)
            bashio::log.info "Starting Chromium browser"
            chromium $COMMON_FLAGS "$HOMEPAGE" &
            ;;
        *)
            bashio::log.warning "Unknown browser: $BROWSER, using Brave"
            brave-browser $COMMON_FLAGS "$HOMEPAGE" &
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
EOF

RUN chmod a+x /run.sh

# Create necessary directories
RUN mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Set environment
ENV DISPLAY=:1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Expose port
EXPOSE 6080

ENTRYPOINT ["/init"]
CMD [ "/run.sh" ]