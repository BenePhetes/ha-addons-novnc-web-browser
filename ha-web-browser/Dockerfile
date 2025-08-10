ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages using apt (Debian base)
RUN apt-get update && apt-get install -y \
    chromium \
    xvfb \
    x11vnc \
    python3 \
    python3-pip \
    openbox \
    supervisor \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install websockify via pip
RUN pip3 install websockify

# Create directories
RUN mkdir -p /etc/supervisor/conf.d /usr/share/novnc

# Download noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | tar -xz -C /tmp && \
    mv /tmp/noVNC-1.3.0/* /usr/share/novnc/ && \
    rm -rf /tmp/noVNC-1.3.0

# Copy configuration
COPY rootfs/ /

# Expose port
EXPOSE 6080

ENTRYPOINT ["/init"]
