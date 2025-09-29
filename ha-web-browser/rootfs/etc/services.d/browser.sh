# /rootfs/etc/services.d/browser.sh
#!/command/with-contenv bashio

BROWSER=$(bashio::config 'browser')
HOMEPAGE=$(bashio::config 'homepage')
RESOLUTION=$(bashio::config 'resolution')
KIOSK=$(bashio::config 'kiosk_mode')

IFS='x' read -ra RES <<< "$RESOLUTION"
WIDTH=${RES[0]}
HEIGHT=${RES[1]}

COMMON_FLAGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --no-first-run --no-default-browser-check --window-size=${WIDTH},${HEIGHT}"

if ${KIOSK}; then
    COMMON_FLAGS="${COMMON_FLAGS} --kiosk"
else
    COMMON_FLAGS="${COMMON_FLAGS} --start-maximized"
fi

bashio::log.info "Starting browser: ${BROWSER}"

case "${BROWSER}" in
    brave)
        exec brave-browser ${COMMON_FLAGS} "${HOMEPAGE}"
        ;;
    opera)
        exec opera ${COMMON_FLAGS} "${HOMEPAGE}"
        ;;
    *)
        bashio::log.fatal "Unknown browser selected: ${BROWSER}"
        bashio::exit.nok
        ;;
esac