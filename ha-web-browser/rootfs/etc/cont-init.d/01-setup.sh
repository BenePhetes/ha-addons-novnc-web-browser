#!/command/with-contenv bashio

# Create directories for the X server
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Clone noVNC repository only if it doesn't already exist
if [ ! -d /opt/novnc ]; then
    bashio::log.info "Cloning noVNC repository..."
    git clone https://github.com/novnc/noVNC.git /opt/novnc
    git clone https://github.com/novnc/websockify.git /opt/novnc/utils/websockify
fi