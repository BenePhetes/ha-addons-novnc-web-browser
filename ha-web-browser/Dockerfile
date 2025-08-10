FROM ghcr.io/home-assistant/amd64-base-debian:latest

# Install base packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    x11vnc \
    openbox \
    python3 \
    python3-pip \
    firefox-esr \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Force install websockify
RUN pip3 install --break-system-packages --no-cache-dir websockify

# Download noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | \
    tar -xz -C /tmp && \
    mv /tmp/noVNC-1.3.0 /opt/novnc && \
    rm -rf /tmp/*

# Copy startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 6080

CMD ["/run.sh"]
