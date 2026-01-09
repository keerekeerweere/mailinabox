FROM ubuntu:22.04

# Install dovecot and required packages
RUN apt-get update && apt-get install -y \
    dovecot-core \
    dovecot-imapd \
    dovecot-pop3d \
    dovecot-lmtpd \
    dovecot-mysql \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/mail /var/run/dovecot

# Copy dovecot configuration
COPY dovecot.conf /etc/dovecot/dovecot.conf
COPY dovecot-sql.conf /etc/dovecot/dovecot-sql.conf

# Set proper permissions
RUN chown -R dovecot:dovecot /var/mail /var/run/dovecot

# Expose ports
EXPOSE 143 993 110 995 24

# Set environment variables
ENV MYSQL_HOST=database
ENV MYSQL_USER=mailinabox
ENV MYSQL_PASSWORD=mailinabox_password
ENV MYSQL_DATABASE=mailinabox

# Start dovecot
CMD ["dovecot", "-F"]