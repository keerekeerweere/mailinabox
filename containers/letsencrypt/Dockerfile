FROM certbot/certbot:latest

# Install additional packages if needed
RUN apk add --no-cache curl

# Create necessary directories
RUN mkdir -p /var/log/letsencrypt /etc/letsencrypt

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set environment variables
ENV DOMAINS=mailinabox.lan
ENV EMAIL=admin@mailinabox.lan

# Run certbot
ENTRYPOINT ["/entrypoint.sh"]