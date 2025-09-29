# /rootfs/etc/services.d/vnc.sh
#!/command/with-contenv bashio
VNC_PASSWORD=$(bashio::config 'password')

if bashio::config.has_value 'password' && [ -n "$VNC_PASSWORD" ]; then
    exec x11vnc -display :1 -xkb -forever -shared -passwd "$VNC_PASSWORD" -quiet
else
    exec x11vnc -display :1 -xkb -forever -shared -nopw -quiet
fi