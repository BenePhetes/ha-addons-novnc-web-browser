# /rootfs/etc/services.d/xvfb.sh
#!/command/with-contenv bashio
exec Xvfb :1 -screen 0 "$(bashio::config 'resolution')"x24 -ac +extension GLX +render -noreset -nolisten tcp