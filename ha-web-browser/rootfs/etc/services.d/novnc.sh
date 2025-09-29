# /rootfs/etc/services.d/novnc.sh
#!/command/with-contenv bashio
PORT=$(bashio::addon.port 6080)
exec python3 -m websockify --web /opt/novnc/ "${PORT}" localhost:5900