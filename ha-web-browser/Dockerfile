FROM ghcr.io/home-assistant/amd64-base-debian:latest

# Install packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        chromium \
        xvfb \
        x11vnc \
        python3-pip \
        openbox \
        curl \
        supervisor && \
    pip3 install websockify && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download noVNC
RUN mkdir -p /opt/novnc && \
    curl -L https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | \
    tar xz --strip-components=1 -C /opt/novnc

# Create supervisor config
RUN mkdir -p /etc/supervisor/conf.d
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy and make executable our startup script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

EXPOSE 6080

CMD ["/usr/local/bin/run.sh"]
