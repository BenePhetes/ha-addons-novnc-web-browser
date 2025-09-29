FROM debian:bookworm-slim

# Install xz-utils FIRST (needed for extracting s6-overlay)
RUN apt-get update && apt-get install -y xz-utils ca-certificates && rm -rf /var/lib/apt/lists/*

# Install S6 overlay for Home Assistant compatibility
ARG S6_OVERLAY_VERSION=3.1.5.0
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && rm /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp/s6-overlay-x86_64.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && rm /tmp/s6-overlay-x86_64.tar.xz

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

# Install noVNC
WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git novnc \
    && git clone https://github.com/novnc/websockify.git novnc/utils/websockify

# Create run script using printf (more reliable than heredoc)
RUN printf '%s\n' \
'#!/usr/bin/with-contenv bashio' \
'' \
'# Get configuration options' \
'RESOLUTION=$(bashio::config '\''resolution'\'' '\''1920x1080'\'')' \
'HOMEPAGE=$(bashio::config '\''homepage'\'' '\''https://google.com'\'')' \
'PASSWORD=$(bashio::config '\''password'\'')' \
'BROWSER=$(bashio::config '\''browser'\'' '\''brave'\'')' \
'KIOSK_MODE=$(bashio::config '\''kiosk_mode'\'' '\''false'\'')' \
'SCALING=$(bashio::config '\''scaling'\'' '\''remote'\'')' \
'COMPRESSION=$(bashio::config '\''compression'\'' '\''6'\'')' \
'QUALITY=$(bashio::config '\''quality'\'' '\''6'\'')' \
'' \
'bashio::log.info "Starting Web Browser with noVNC..."' \
'bashio::log.info "Resolution: $RESOLUTION"' \
'bashio::log.info "Homepage: $HOMEPAGE"' \
'bashio::log.info "Browser: $BROWSER"' \
'' \
'# Parse resolution' \
'IFS='\''x'\'' read -ra RES <<< "$RESOLUTION"' \
'WIDTH=${RES[0]}' \
'HEIGHT=${RES[1]}' \
'DEPTH=${RES[2]:-24}' \
'' \
'mkdir -p /tmp/.X11-unix /var/run/dbus' \
'chmod 1777 /tmp/.X11-unix' \
'' \
'export DISPLAY=:1' \
'export CHROME_LOG_FILE=/dev/null' \
'' \
'bashio::log.info "Starting Xvfb..."' \
'Xvfb :1 -screen 0 ${WIDTH}x${HEIGHT}x${DEPTH} -ac +extension GLX +render -noreset -nolisten tcp &' \
'XVFB_PID=$!' \
'sleep 3' \
'' \
'if ! kill -0 $XVFB_PID 2>/dev/null; then' \
'    bashio::log.error "Failed to start Xvfb"' \
'    exit 1' \
'fi' \
'' \
'bashio::log.info "Starting window manager..."' \
'openbox --sm-disable &' \
'sleep 1' \
'' \
'bashio::log.info "Starting VNC server..."' \
'if bashio::config.has_value '\''password'\'' && [ -n "$PASSWORD" ]; then' \
'    x11vnc -display :1 -listen localhost -xkb -forever -shared -passwd "$PASSWORD" -quiet &' \
'else' \
'    x11vnc -display :1 -listen localhost -xkb -forever -shared -nopw -quiet &' \
'fi' \
'VNC_PID=$!' \
'sleep 3' \
'' \
'if ! kill -0 $VNC_PID 2>/dev/null; then' \
'    bashio::log.error "Failed to start VNC"' \
'    exit 1' \
'fi' \
'' \
'bashio::log.info "Starting noVNC..."' \
'cd /opt/novnc' \
'python3 -m websockify --web . 6080 localhost:5900 &' \
'NOVNC_PID=$!' \
'sleep 3' \
'' \
'if ! kill -0 $NOVNC_PID 2>/dev/null; then' \
'    bashio::log.error "Failed to start noVNC"' \
'    exit 1' \
'fi' \
'' \
'COMMON_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --no-first-run --no-default-browser-check --window-size=${WIDTH},${HEIGHT}"' \
'' \
'if [ "$KIOSK_MODE" = "true" ]; then' \
'    COMMON_FLAGS="$COMMON_FLAGS --kiosk"' \
'else' \
'    COMMON_FLAGS="$COMMON_FLAGS --start-maximized"' \
'fi' \
'' \
'start_browser() {' \
'    case "$BROWSER" in' \
'        brave)' \
'            bashio::log.info "Starting Brave browser"' \
'            brave-browser $COMMON_FLAGS "$HOMEPAGE" &' \
'            ;;' \
'        opera)' \
'            bashio::log.info "Starting Opera browser"' \
'            opera $COMMON_FLAGS "$HOMEPAGE" &' \
'            ;;' \
'        *)' \
'            bashio::log.error "Unknown browser: $BROWSER"' \
'            exit 1' \
'            ;;' \
'    esac' \
'    BROWSER_PID=$!' \
'}' \
'' \
'start_browser' \
'sleep 2' \
'' \
'if ! kill -0 $BROWSER_PID 2>/dev/null; then' \
'    bashio::log.error "Failed to start browser"' \
'    exit 1' \
'fi' \
'' \
'bashio::log.info "All services started!"' \
'' \
'cleanup() {' \
'    bashio::log.info "Shutting down..."' \
'    kill $BROWSER_PID $NOVNC_PID $VNC_PID $XVFB_PID 2>/dev/null' \
'    exit 0' \
'}' \
'' \
'trap cleanup SIGTERM SIGINT' \
'' \
'while true; do' \
'    if ! kill -0 $XVFB_PID 2>/dev/null || ! kill -0 $VNC_PID 2>/dev/null || ! kill -0 $NOVNC_PID 2>/dev/null; then' \
'        bashio::log.error "Service died, restarting container..."' \
'        exit 1' \
'    fi' \
'    if ! kill -0 $BROWSER_PID 2>/dev/null; then' \
'        bashio::log.warning "Browser died, restarting..."' \
'        start_browser' \
'    fi' \
'    sleep 10' \
'done' \
> /run.sh && chmod +x /run.sh

# Verify script was created
RUN ls -la /run.sh && echo "=== First 10 lines of run.sh ===" && head -10 /run.sh

# Create necessary directories
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Set environment
ENV DISPLAY=:1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Expose port
EXPOSE 6080

ENTRYPOINT ["/init"]
CMD [ "/run.sh" ]