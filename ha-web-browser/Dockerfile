ARG BUILD_FROM
FROM $BUILD_FROM

# Create the script directly in Dockerfile
RUN echo '#!/usr/bin/with-contenv bashio' > /run.sh && \
    echo '' >> /run.sh && \
    echo 'bashio::log.info "Starting Web Browser Add-on..."' >> /run.sh && \
    echo 'bashio::log.info "Test message - addon is working!"' >> /run.sh && \
    echo '' >> /run.sh && \
    echo 'while true; do' >> /run.sh && \
    echo '    sleep 30' >> /run.sh && \
    echo 'done' >> /run.sh && \
    chmod +x /run.sh

# Debug what we created
RUN ls -la /run.sh && cat /run.sh

CMD ["/run.sh"]
