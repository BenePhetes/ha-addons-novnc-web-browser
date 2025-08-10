ARG BUILD_FROM
FROM $BUILD_FROM

# Copy and set permissions
COPY run.sh /
RUN chmod +x /run.sh

CMD ["/run.sh"]