# /Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# Install required packages and browsers
RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        # For extracting .tar.xz files
        xz-utils \
        # For VNC and virtual display
        xvfb \
        x11vnc \
        openbox \
        # For noVNC
        python3 \
        python3-websockify \
        git \
        # For adding repositories
        curl \
        gnupg \
        wget \
        # Browser dependencies
        dbus-x11 \
        fonts-liberation \
        libasound2 \
        libatk-bridge2.0-0 \
        libatspi2.0-0 \
        libgtk-3-0 \
        libnss3 \
        libxss1 \
        xdg-utils \
    # Add Brave Browser repository and key
    && curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor > /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list \
    # Add Opera Browser repository and key
    && wget -qO- https://deb.opera.com/archive.key | gpg --dearmor > /usr/share/keyrings/opera-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/opera-archive-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" > /etc/apt/sources.list.d/opera-archive.list \
    # Update package lists again and install browsers
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        brave-browser \
        opera-stable \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs /
RUN chmod +x -R /etc/services.d