ARG BUILD_FROM
FROM $BUILD_FROM

# First, let's see what we're working with
RUN echo "=== DEBUG INFO ===" && \
    cat /etc/os-release && \
    echo "=== AVAILABLE PACKAGES ===" && \
    apk search chromium | head -5 && \
    apk search websockify | head -5 && \
    apk search novnc | head -5

# Install packages one by one to see which fails
RUN apk update && \
    apk add --no-cache chromium || echo "CHROMIUM FAILED" && \
    apk add --no-cache xvfb || echo "XVFB FAILED" && \
    apk add --no-cache x11vnc || echo "X11VNC FAILED" && \
    apk add --no-cache supervisor || echo "SUPERVISOR FAILED"

# Try alternative packages for websockify and novnc
RUN apk add --no-cache python3 py3-pip && \
    pip3 install websockify || echo "WEBSOCKIFY PIP FAILED"

# Copy our script
COPY run.sh /run.sh

# Make it executable and debug
RUN chmod +x /run.sh && \
    echo "=== SCRIPT DEBUG ===" && \
    ls -la /run.sh && \
    file /run.sh && \
    head -3 /run.sh

# Simple test script instead
RUN echo '#!/bin/bash' > /test.sh && \
    echo 'echo "Test script works"' >> /test.sh && \
    echo 'sleep infinity' >> /test.sh && \
    chmod +x /test.sh

# Try both scripts
CMD ["/test.sh"]
