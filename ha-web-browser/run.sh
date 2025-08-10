#!/bin/bash

echo "Starting Web Browser with noVNC..."

# Start virtual display
Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for X server
sleep 3

# Start window manager
DISPLAY=:1 openbox &

# Start VNC server
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -forever -shared &
VNC_PID=$!

# Wait for VNC
sleep 3

# Start noVNC using system websockify
cd /opt/novnc && /usr/bin/websockify --web . 6080 localhost:5900 &
NOVNC_PID=$!

# Wait for websockify
sleep 3

# Start Firefox browser
DISPLAY=:1 firefox-esr --new-instance --no-remote --kiosk https://google.com &
BROWSER_PID=$!

echo "Services started successfully!"
echo "Access browser at: http://localhost:6080/vnc.html"

# Monitor services
while true; do
    if ! kill -0 $XVFB_PID 2>/dev/null || \
       ! kill -0 $VNC_PID 2>/dev/null || \
       ! kill -0 $NOVNC_PID 2>/dev/null; then
        echo "A service died, restarting container..."
        exit 1
    fi
    sleep 15
done
