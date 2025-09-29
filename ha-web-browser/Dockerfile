# Use Debian Bookworm Slim as the base image
FROM debian:bookworm-slim

# Set frontend to noninteractive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install S6 overlay for Home Assistant compatibility
ARG S6_OVERLAY_VERSION=3.1.5.0
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/s6-overlay-noarch.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && rm /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp/s6-overlay-x86_64.tar.xz
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && rm /tmp/s6-overlay-x86_64.tar.xz

# Install all required packages, bashio, and browsers in a single layer for efficiency
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        # For bashio & browsers
        curl \
        gnupg \
        wget \
        jq \
        # For VNC and virtual display
        xvfb \
        x11vnc \
        openbox \
        # For noVNC
        python3 \
        python3-pip \
        python3-websockify \
        git \
        # Browser dependencies
        dbus-x11 \
        fonts-liberation \
        libasound2 \
        libatk-bridge2.0-0 \
        libatspi2.0-0 \
        libgtk-3-0 \
        libnss3 \
        libxss1 \
        libappindicator3-1 \
        xdg-utils \
    # Install bashio
    && curl -J -L -o /tmp/bashio.tar.gz "https://github.com/hassio-addons/bashio/archive/v0.16.2.tar.gz" \
    && mkdir -p /usr/lib/bashio \
    && tar zxvf /tmp/bashio.tar.gz --strip 1 -C /tmp \
    && mv /tmp/lib /usr/lib/bashio \
    && ln -s /usr/lib/bashio/bashio /usr/bin/bashio \
    # Install Brave Browser
    && curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list \
    # Install Opera Browser
    && wget -qO- https://deb.opera.com/archive.key | gpg --dearmor -o /usr/share/keyrings/opera-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/opera-archive-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" > /etc/apt/sources.list.d/opera-archive.list \
    # Install from new sources
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        brave-browser \
        opera-stable \
    # Clean up
    && rm -rf /tmp/* /var/lib/apt/lists/*

# Install noVNC
WORKDIR /opt
RUN git clone https://github.com/novnc/noVNC.git novnc \
    && git clone https://github.com/novnc/websockify.git novnc/utils/websockify

# --- BEST PRACTICE FIX ---
# Copy the run script into the container instead of building it with printf
COPY run.sh /
RUN chmod +x /run.sh

# Create necessary directories
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Set environment
ENV DISPLAY=:1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Expose port for noVNC
EXPOSE 6080

# --- PRIMARY FIX ---
# The CMD is removed. S6 overlay will automatically execute /run.sh by default.
ENTRYPOINT ["/init"]