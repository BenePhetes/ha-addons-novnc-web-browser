```bash
#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

bashio::log.info "Checking dependencies..."

# Check if Xpra is installed
if ! command -v xpra &> /dev/null; then
    bashio::log.error "Xpra is not installed!"
    exit 1
fi

# Check browser selection
BROWSER=$(bashio::config 'browser')
bashio::log.info "Selected browser: ${BROWSER}"

if [ "$BROWSER" = "brave" ]; then
    if ! command -v brave-browser &> /dev/null; then
        bashio::log.error "Brave browser is not installed!"
        exit 1
    fi
    bashio::log.info "Brave browser found at: $(which brave-browser)"
elif [ "$BROWSER" = "opera" ]; then
    if ! command -v opera &> /dev/null; then
        bashio::log.error "Opera browser is not installed!"
        exit 1
    fi
    bashio::log.info "Opera browser found at: $(which opera)"
else
    bashio::log.error "Unknown browser: ${BROWSER}"
    exit 1
fi

# Check URL
URL=$(bashio::config 'url')
bashio::log.info "Target URL: ${URL}"

# Create runtime directory
export XDG_RUNTIME_DIR="/run/user/0"
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

bashio::log.info "All dependencies checked successfully!"
```