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

# Copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# Create necessary directories
RUN mkdir -p /tmp/.X11-unix \
    && chmod 1777 /tmp/.X11-unix

# Set environment variables
ENV DISPLAY=:1

# Expose port
EXPOSE 6080

CMD [ "/run.sh" ]