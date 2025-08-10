FROM ghcr.io/home-assistant/amd64-base-debian:latest

# Install packages in stages to avoid timeouts
RUN apt-get update

# Install X11 and VNC packages first
RUN apt-get install -y --no-install-recommends \
    xvfb \
    x11vnc \
    openbox \
    && apt-get clean

# Install Python and networking tools
RUN apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    curl \
    wget \
    && apt-get clean

# Install websockify
RUN pip3 install --no-cache-dir websockify

# Try Firefox ESR instead of Chromium (lighter and more reliable)
RUN apt-get install -y --no-install-recommends \
    firefox-esr \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | \
    tar -xz -C /tmp && \
    mv /tmp/noVNC-1.3.0 /opt/novnc && \
    rm -rf /tmp/*

# Copy and setup startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 6080

CMD ["/run.sh"]
