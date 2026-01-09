# Mail-in-a-Box Multi-Container Setup

This directory contains Docker configurations for running Mail-in-a-Box as a multi-container application using Docker Compose.

## Architecture

The setup consists of the following containers:

- **database**: PostgreSQL database for storing configuration and user data
- **management**: Python Flask application providing the web management interface
- **postfix**: SMTP server for sending/receiving email
- **dovecot**: IMAP/POP3 server for mail access
- **nginx**: Web server and reverse proxy
- **letsencrypt**: SSL certificate management with Let's Encrypt

## Quick Start

1. **Build and start all services:**
   ```bash
   docker-compose up --build -d
   ```

2. **Initialize the database:**
   ```bash
   # The management container will create necessary tables on first run
   docker-compose logs management
   ```

3. **Access the web interface:**
   - Management interface: http://localhost:8080
   - Mail web interface: https://localhost (after SSL setup)

4. **Check service status:**
   ```bash
   docker-compose ps
   docker-compose logs [service_name]
   ```

## Configuration

### Environment Variables

- `POSTGRES_DB=mailinabox`
- `POSTGRES_USER=mailinabox`
- `POSTGRES_PASSWORD=mailinabox_password`
- `SECRET_KEY=development_secret_key_change_in_production`
- `DOMAINS=mailinabox.lan`
- `EMAIL=admin@mailinabox.lan`

### Volumes

- `db_data`: PostgreSQL database files
- `config_data`: Application configuration
- `mail_data`: User mailboxes
- `mail_queue`: Postfix mail queue
- `nginx_logs`: Web server logs
- `letsencrypt_certs`: SSL certificates
- `letsencrypt_logs`: Certificate request logs
- `static_files`: Static web content

### Networks

- `mailinabox_internal`: Internal communication between services
- `mailinabox_external`: External access to services

## Development Workflow

### Building Individual Services

```bash
# Build specific service
docker-compose build [service_name]

# Build all services
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f [service_name]
```

### Database Setup

The management container will automatically create the necessary database tables on first run. The database schema includes:

- `virtual_domains`: Email domains
- `virtual_users`: Email users and passwords
- `virtual_aliases`: Email aliases

### SSL Certificates

The letsencrypt container will automatically:
1. Wait for nginx to be ready
2. Request SSL certificates from Let's Encrypt
3. Store certificates in the shared volume
4. Periodically renew certificates

## Testing

### Mail Testing

1. **Create a test user through the management interface**
2. **Send test email:**
   ```bash
   docker-compose exec postfix mail -s "Test Subject" user@domain.com < /dev/null
   ```

3. **Check mail delivery:**
   ```bash
   docker-compose exec dovecot doveadm mailbox status -u user@domain.com all
   ```

### Service Connectivity

```bash
# Test SMTP
telnet localhost 25

# Test IMAP
telnet localhost 143

# Test web interface
curl http://localhost:8080
```

## Troubleshooting

### Common Issues

1. **Database connection errors:**
   - Ensure database container is running: `docker-compose ps database`
   - Check database logs: `docker-compose logs database`

2. **Mail delivery issues:**
   - Check postfix logs: `docker-compose logs postfix`
   - Verify dovecot is running: `docker-compose ps dovecot`

3. **SSL certificate issues:**
   - Check letsencrypt logs: `docker-compose logs letsencrypt`
   - Ensure domain DNS points to the server

4. **Web interface not accessible:**
   - Check nginx logs: `docker-compose logs nginx`
   - Verify management service is running: `docker-compose ps management`

### Logs

```bash
# All service logs
docker-compose logs

# Specific service logs
docker-compose logs [service_name]

# Follow logs in real-time
docker-compose logs -f [service_name]
```

### Container Shell Access

```bash
# Access container shell
docker-compose exec [service_name] /bin/bash

# Access database
docker-compose exec database psql -U mailinabox -d mailinabox
```

## Production Deployment

For production deployment:

1. **Change default passwords** in docker-compose.yml
2. **Configure proper domain names** in environment variables
3. **Set up DNS records** pointing to your server
4. **Enable firewall rules** for required ports
5. **Configure backups** for persistent volumes
6. **Set up monitoring** and log aggregation

## Port Mapping

- **25**: SMTP (postfix)
- **80**: HTTP (nginx)
- **143**: IMAP (dovecot)
- **443**: HTTPS (nginx)
- **587**: SMTP Submission (postfix)
- **993**: IMAPS (dovecot)
- **995**: POP3S (dovecot)
- **8080**: Management interface (management)

## Security Considerations

- Change default database passwords
- Use strong secret keys
- Restrict network access where possible
- Keep containers updated
- Monitor logs for suspicious activity
- Use proper SSL/TLS configuration