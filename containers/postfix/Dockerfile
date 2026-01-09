FROM ubuntu:22.04

# Install postfix and required packages
RUN apt-get update && apt-get install -y \
    postfix \
    postfix-pcre \
    postfix-sqlite \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/spool/postfix /var/mail /etc/postfix/sql

# Copy postfix configuration
COPY postfix-main.cf /etc/postfix/main.cf
COPY postfix-master.cf /etc/postfix/master.cf

# Copy SQL configuration for virtual users
COPY mysql-virtual-mailbox-domains.cf /etc/postfix/sql/mysql-virtual-mailbox-domains.cf
COPY mysql-virtual-mailbox-maps.cf /etc/postfix/sql/mysql-virtual-mailbox-maps.cf
COPY mysql-virtual-alias-maps.cf /etc/postfix/sql/mysql-virtual-alias-maps.cf

# Set proper permissions
RUN chown -R postfix:postfix /var/spool/postfix /var/mail
RUN chmod 755 /etc/postfix/sql/*.cf

# Expose ports
EXPOSE 25 587

# Set environment variables
ENV MYSQL_HOST=database
ENV MYSQL_USER=mailinabox
ENV MYSQL_PASSWORD=mailinabox_password
ENV MYSQL_DATABASE=mailinabox

# Start postfix
CMD ["postfix", "start-fg"]