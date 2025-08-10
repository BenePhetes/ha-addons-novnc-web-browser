ARG BUILD_FROM
FROM $BUILD_FROM

# Install required packages
RUN apk add --no-cache \
    chromium \
    xvfb \
    x11vnc \
    websockify \
    openbox \
    ttf-liberation \
    supervisor

# Create necessary directories
RUN mkdir -p /etc/supervisor/conf.d

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY run.sh /

# Make run script executable
RUN chmod +x /run.sh

# Expose the VNC web port
EXPOSE 6080

CMD ["/run.sh"]
