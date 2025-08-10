#!/bin/bash

echo "Starting Web Browser with noVNC..."

# Start virtual display
Xvfb :1 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!

# Wait for X server
sleep 2

# Start window manager
DISPLAY=:1 openbox &

# Start VNC server
x11vnc -display :1 -nopw -listen localhost -xkb -ncache 10 -forever -shared &
VNC_PID=$!

# Wait for VNC
sleep 2

# Start noVNC web server
cd /opt/novnc && python3 -m websockify --web . 6080 localhost:5900 &
NOVNC_PID=$!

# Wait a bit more
sleep 3

# Start Chromium browser
DISPLAY=:1 chromium --no-sandbox --disable-dev-shm-usage --disable-gpu --no-first-run --start-maximized --disable-infobars https://google.com &
BROWSER_PID=$!

echo "All services started. Access via http://YOUR_HA_IP:6080/vnc.html"

# Keep container running and monitor services
while true; do
    if ! kill -0 $XVFB_PID 2>/dev/null; then
        echo "Xvfb died, restarting container..."
        exit 1
    fi
    if ! kill -0 $VNC_PID 2>/dev/null; then
        echo "VNC died, restarting container..."
        exit 1
    fi
    if ! kill -0 $NOVNC_PID 2>/dev/null; then
        echo "noVNC died, restarting container..."
        exit 1
    fi
    sleep 10
done
