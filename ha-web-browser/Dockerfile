FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0
ENV VNC_PORT=5900
ENV NO_VNC_PORT=6080

# Install packages (minimal set)
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    xvfb \
    x11vnc \
    websockify \
    novnc \
    chromium \
    nginx-light \
    curl \
    openbox \
    fonts-liberation \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create directories
RUN mkdir -p ~/.vnc /var/log/supervisor

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY run.sh /run.sh

# Make run script executable
RUN chmod +x /run.sh

# Create web directory and set up noVNC
RUN mkdir -p /usr/share/novnc && \
    ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Expose port
EXPOSE 6080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:6080/ || exit 1

# Start services
CMD ["/run.sh"]