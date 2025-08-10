ARG BUILD_FROM
FROM $BUILD_FROM

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    x11vnc \
    openbox \
    python3-websockify \
    firefox-esr \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download noVNC
RUN curl -L https://github.com/novnc/noVNC/archive/v1.3.0.tar.gz | \
    tar -xz -C /tmp && \
    mv /tmp/noVNC-1.3.0 /opt/novnc && \
    rm -rf /tmp/*

# Copy rootfs
COPY rootfs/ /

EXPOSE 6080
