FROM ghcr.io/home-assistant/amd64-base-debian:latest

# Install required packages
RUN apt-get update && apt-get install -y \
    chromium \
    xvfb \
    x11vnc \
    python3 \
    python3-pip \
    openbox \
    wget \
    && pip3 install websockify \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and setup noVNC
RUN wget -qO- https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar xz \
    && mv noVNC-1.3.0 /opt/novnc \
    && chmod +x /opt/novnc/utils/novnc_proxy

# Copy startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 6080

CMD ["/start.sh"]
