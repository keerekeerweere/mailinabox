# AGENTS.md - Development Guidelines for Mail-in-a-Box

This file contains development guidelines and commands for agentic coding assistants working on the Mail-in-a-Box codebase.

## Build, Lint, and Test Commands

### Linting and Formatting
```bash
# Install ruff (Python linter/formatter)
pip install ruff

# Lint all Python files
ruff check .

# Format all Python files
ruff format .

# Lint and format a single file
ruff check management/mailconfig.py
ruff format management/mailconfig.py

# Fix auto-fixable linting issues
ruff check --fix .
```

### Testing
Tests are standalone Python scripts in the `tests/` directory. Each test requires specific command-line arguments:

```bash
# Test mail sending/receiving (requires running Mail-in-a-Box instance)
python3 tests/test_mail.py hostname email@example.com password

# Test SMTP server connectivity
python3 tests/test_smtp_server.py host to@example.com from@example.com

# Test DNS configuration
python3 tests/test_dns.py hostname

# Test TLS/SSL configuration
python3 tests/test_smtp_server.py hostname

# Install test dependencies (if needed)
pip install -r tests/pip-requirements.txt
```

### Development Setup
```bash
# Clone repository
git clone https://github.com/mail-in-a-box/mailinabox
cd mailinabox

# Install Python dependencies (if any)
pip install ruff dnspython3

# Run with Vagrant (recommended for development)
vagrant up --provision

# Or run setup directly on Ubuntu 22.04
sudo setup/start.sh
```

## Code Style Guidelines

### Python Style
- **Indentation**: Use tabs (not spaces) for Python files
- **Line Length**: 320 characters maximum (configured in pyproject.toml)
- **Target Python Version**: Python 3.10+
- **Function Naming**: snake_case (e.g., `validate_email()`, `get_services()`)
- **Class Naming**: PascalCase (e.g., `AuthService`, `EmailNotValidError`)
- **Variable Naming**: snake_case (e.g., `email_address`, `config_file`)
- **Constants**: UPPER_CASE (e.g., `DEFAULT_KEY_PATH`)

### Imports
```python
# Standard library imports first
import os, sys, json
from datetime import datetime

# Third-party imports
import requests
from expiringdict import ExpiringDict

# Local imports (alphabetized)
import utils
from mailconfig import validate_email
```

### Error Handling
```python
# Use specific exceptions, not bare except
try:
    result = risky_operation()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
    return False
except OSError as e:
    logger.error(f"System error: {e}")
    raise

# Handle expected exceptions gracefully
try:
    config = load_config()
except FileNotFoundError:
    config = get_default_config()
```

### Comments and Documentation
```python
def validate_email(email, mode=None):
    """Checks that an email address is syntactically valid.

    Args:
        email (str): The email address to validate
        mode (str, optional): Validation mode ('user' or 'alias')

    Returns:
        bool: True if valid, False otherwise
    """
    # Implementation comments for complex logic
    if mode == 'user':
        # Additional user-specific validation
        pass
```

### File Structure
```
mailinabox/
├── setup/          # Installation scripts (bash)
├── management/     # Python management interface
├── tests/          # Test scripts
├── conf/           # Configuration templates
├── tools/          # Utility scripts
└── api/            # API definitions
```

### Bash Scripting Style
- Use `#!/bin/bash` shebang
- Set shell options: `set -euo pipefail`
- Use descriptive variable names
- Include error handling
- Comment complex operations

```bash
#!/bin/bash
set -euo pipefail

# Function to validate input
validate_input() {
    local domain="$1"
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo "Invalid domain format: $domain" >&2
        return 1
    fi
}
```

### Configuration Files
- Nginx configs: Use consistent indentation and comments
- Systemd services: Follow standard service file format
- DNS zone files: Use proper record formatting

### Security Considerations
- Never log sensitive information (passwords, keys, tokens)
- Use secure file permissions for configuration files
- Validate all user inputs
- Follow principle of least privilege

### Docker Containerization
Mail-in-a-Box should be containerized as a multi-container application for better scalability and maintainability.

#### Multi-Container Architecture
Recommended container breakdown:

1. **nginx** - Web server, reverse proxy, and static file serving
2. **postfix** - SMTP server for sending/receiving mail
3. **dovecot** - IMAP/POP3 server for mail access
4. **nextcloud** - CardDAV/CalDAV server for contacts/calendars
5. **z-push** - Exchange ActiveSync server
6. **roundcube** - Webmail interface
7. **spamassassin** - Spam filtering service
8. **nsd** - DNS server
9. **letsencrypt** - SSL certificate management
10. **management** - Python management interface and API
11. **database** - SQLite/PostgreSQL for configuration and user data
12. **monitoring** - fail2ban, munin, and system monitoring

#### Base Container (Ubuntu 22.04)
```dockerfile
FROM ubuntu:22.04

# Install common dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3 as default
RUN ln -s /usr/bin/python3 /usr/bin/python
```

#### Example Service Containers

**nginx Container:**
```dockerfile
FROM nginx:alpine
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/nginx-ssl.conf /etc/nginx/conf.d/default.conf
EXPOSE 80 443
```

**postfix Container:**
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y postfix && rm -rf /var/lib/apt/lists/*
COPY conf/postfix/main.cf /etc/postfix/main.cf
EXPOSE 25 587
```

**dovecot Container:**
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y dovecot-imapd dovecot-pop3d && rm -rf /var/lib/apt/lists/*
COPY conf/dovecot/dovecot.conf /etc/dovecot/dovecot.conf
EXPOSE 143 993 110 995
```

**Management Container:**
```dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY management/ .
RUN pip install -r requirements.txt
EXPOSE 8080
CMD ["python", "daemon.py"]
```

#### Docker Compose Configuration
```yaml
version: '3.8'
services:
  nginx:
    build: ./containers/nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - nginx_logs:/var/log/nginx
      - letsencrypt_certs:/etc/letsencrypt
    depends_on:
      - management
      - roundcube

  postfix:
    build: ./containers/postfix
    volumes:
      - mail_queue:/var/spool/postfix
      - mail_data:/var/mail
    depends_on:
      - database

  dovecot:
    build: ./containers/dovecot
    volumes:
      - mail_data:/var/mail
    depends_on:
      - postfix
      - database

  management:
    build: ./containers/management
    environment:
      - DATABASE_URL=postgresql://user:pass@database/mailinabox
    volumes:
      - config_data:/app/data
    depends_on:
      - database

  database:
    image: postgres:13
    volumes:
      - db_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: mailinabox

volumes:
  nginx_logs:
  letsencrypt_certs:
  mail_queue:
  mail_data:
  config_data:
  db_data:
```

#### Networking Considerations
- Use Docker networks for internal service communication
- Expose only necessary ports to the host (80, 443 for web, 25/587 for SMTP, etc.)
- Use internal networking for service-to-service communication
- Consider using Traefik or nginx as a reverse proxy for routing

#### Volume Mounting Strategy
- **Persistent Data**: Mail spools, databases, SSL certificates
- **Configuration**: Mount config files for easy updates
- **Logs**: Centralized logging with volume mounts or logging drivers
- **Backups**: Mount backup directories to host for external backups

#### Development Workflow
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f [service_name]

# Rebuild specific service
docker-compose build [service_name]
docker-compose up -d [service_name]

# Run tests against containers
docker-compose exec management python3 tests/test_mail.py
```

### Commit Message Style
Follow conventional commit format:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `refactor:` Code restructuring
- `test:` Testing changes
- `chore:` Maintenance tasks

Example: `fix: correct DNS validation in mailconfig.py`

### Pull Request Guidelines
- Include tests for new functionality
- Update documentation if needed
- Ensure all linting passes
- Test on Ubuntu 22.04 environment
- Follow semantic versioning for changes

### Debugging
- Use logging instead of print statements
- Include debug information in error messages
- Test edge cases thoroughly
- Use descriptive variable names for clarity

Remember: This is a mail server project. Security and reliability are paramount. Always consider the implications of changes on email delivery and system security.</content>
<parameter name="filePath">/mnt/c/work/mailinabox/AGENTS.md