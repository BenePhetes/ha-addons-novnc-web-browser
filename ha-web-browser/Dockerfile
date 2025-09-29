# /Dockerfile
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base:8.1.3
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        # Nginx for Ingress
        nginx \
        # Basic X11 tools instead of xpra initially
        xvfb \
        # For adding repositories
        curl \
        gnupg \
        wget \
        ca-certificates \
        # Browser dependencies
        dbus-x11 \
        fonts-liberation \
        libasound2 \
        libatk-bridge2.0-0 \
        libatspi2.0-0 \
        libcups2 \
        libdbus-1-3 \
        libdrm2 \
        libgbm1 \
        libgtk-3-0 \
        libnspr4 \
        libnss3 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxkbcommon0 \
        libxrandr2 \
        libxss1 \
        xdg-utils \
    # Add xpra's official repository
    && curl -fsSL https://xpra.org/repos/bookworm/xpra.asc | gpg --dearmor > /usr/share/keyrings/xpra-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/xpra-archive-keyring.gpg] https://xpra.org/repos/bookworm/ bookworm main" > /etc/apt/sources.list.d/xpra.list \
    # Add Brave Browser
    && curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg | gpg --dearmor > /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave-browser-release.list \
    # Add Opera Browser
    && wget -qO- https://deb.opera.com/archive.key | gpg --dearmor > /usr/share/keyrings/opera-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/opera-archive-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" > /etc/apt/sources.list.d/opera-archive.list \
    # Update package lists and install all packages
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        xpra \
        brave-browser \
        opera-stable \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY rootfs /

RUN chmod +x /etc/services.d/*/run \
    && chmod +x /etc/cont-init.d/*.sh