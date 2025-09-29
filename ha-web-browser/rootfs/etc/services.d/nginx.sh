#!/command/with-contenv bashio

# Generate the nginx config from the tempio template using the ingress port
bashio::var.json \
    port "$(bashio::addon.ingress_port)" \
    | tempio \
        -template /etc/nginx.conf.tempio \
        -out /etc/nginx.conf

# Start Nginx with the generated config file
exec nginx -c /etc/nginx.conf