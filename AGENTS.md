# AGENTS.md - Mail-in-a-Box Development Guidelines

This document provides development guidelines and commands for agentic coding assistants working on the Mail-in-a-Box codebase.

## Build/Lint/Test Commands

### Python Linting and Formatting
```bash
# Lint Python code with Ruff
ruff check .

# Format Python code with Ruff
ruff format .

# Fix auto-fixable linting issues
ruff check --fix .
```

### Testing
The project uses integration tests rather than unit tests. Tests are located in the `tests/` directory.

```bash
# Run a specific test (requires external mail server setup)
# Example: test mail functionality
python3 tests/test_mail.py <hostname> <email> <password>

# Run DNS configuration test
python3 tests/test_dns.py <ip_address> <hostname>

# Run TLS certificate test
python3 tests/tls.py <hostname>
```

**Note:** Most tests require a fully configured Mail-in-a-Box instance with external network access and valid certificates. They are integration tests rather than unit tests.

### Development Environment Setup
```bash
# Using Vagrant (recommended for development)
vagrant up --provision

# SSH into development VM
vagrant ssh

# Re-run specific setup scripts during development
cd /vagrant
sudo setup/<script_name>.sh
```

### Manual Testing
```bash
# Test mail sending/receiving manually
python3 tests/test_mail.py hostname user@domain.com password

# Test DNS configuration
python3 tests/test_dns.py 192.168.56.4 mailinabox.lan

# Test TLS certificates
python3 tests/tls.py mailinabox.lan
```

## Code Style Guidelines

### Python Code Style
- **Indentation**: Use tabs (not spaces) for indentation
- **Line Length**: Maximum 320 characters per line
- **Target Version**: Python 3.10+
- **Imports**: Standard library imports first, then third-party, then local imports
- **Naming Conventions**:
  - Functions and variables: `snake_case`
  - Classes: `PascalCase`
  - Constants: `UPPER_CASE`
  - Private members: `_leading_underscore`
- **Error Handling**: Use specific exception types, avoid bare `except:` clauses
- **Type Hints**: Use type hints for function parameters and return values when clarity benefits
- **Docstrings**: Use triple-quoted docstrings for module-level and function documentation

```python
# Good Python example
def send_welcome_email(user_email: str, username: str) -> bool:
    """
    Send a welcome email to a new user.

    Args:
        user_email: The email address to send to
        username: The user's display name

    Returns:
        True if email was sent successfully
    """
    try:
        # Implementation here
        return True
    except SMTPException as e:
        logger.error(f"Failed to send welcome email to {user_email}: {e}")
        return False
```

### Bash Script Style
- **Shebang**: Use `#!/bin/bash`
- **Strict Mode**: Always include `set -euo pipefail` at the top
- **Functions**: Use `function name() { ... }` syntax
- **Error Handling**: Use `hide_output` function for commands that should be quiet unless they fail
- **Variable Naming**: Use `UPPER_CASE` for global variables, `lower_case` for local variables
- **Quotes**: Always quote variables: `"$variable"`
- **Comments**: Use `#` for comments, explain complex logic

```bash
#!/bin/bash
set -euo pipefail

function setup_mail_server() {
    local domain="$1"

    # Install required packages quietly
    hide_output apt_install postfix dovecot-core

    # Configure services
    if ! systemctl is-active --quiet postfix; then
        restart_service postfix
    fi
}
```

### General Guidelines
- **Security**: Never log or expose sensitive information (passwords, API keys, certificates)
- **Logging**: Use appropriate log levels (DEBUG, INFO, WARNING, ERROR)
- **Configuration**: Use environment variables for configurable values
- **Idempotency**: Scripts should be safe to run multiple times
- **Comments**: Explain why, not just what the code does
- **Testing**: Add tests for new functionality when possible

### File Organization
- **Python modules**: Place in appropriate directories under `management/`
- **Setup scripts**: Place in `setup/` directory
- **Configuration files**: Place in `conf/` directory
- **Tests**: Place in `tests/` directory

### Git Commit Guidelines
- **Message Format**: `type(scope): description`
- **Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- **Scope**: Optional, use module name or component
- **Description**: Start with lowercase, be descriptive

```bash
# Good commit messages
feat(dns): add support for DNSSEC validation
fix(ssl): resolve certificate renewal timing issue
docs(api): update management API documentation
```

### Code Review Checklist
- [ ] Python code passes Ruff linting (`ruff check .`)
- [ ] Code follows style guidelines (tabs, line length, naming)
- [ ] Error handling is appropriate and secure
- [ ] No sensitive data is logged or exposed
- [ ] Functions have appropriate docstrings
- [ ] Bash scripts use strict mode and proper quoting
- [ ] Changes include tests if applicable
- [ ] Documentation is updated for user-facing changes

### Common Patterns
- **API Responses**: Use JSON for structured data, plain text for simple messages
- **Configuration**: Store in `/etc/mailinabox/` or `/var/lib/mailinabox/`
- **Services**: Use systemd for service management
- **Firewall**: Use `ufw_allow` and `ufw_limit` functions
- **Package Installation**: Use `apt_install` function for consistent installation

### Security Considerations
- **Input Validation**: Always validate and sanitize user input
- **File Permissions**: Set appropriate permissions on configuration files
- **Network Security**: Use TLS for all external communications
- **Authentication**: Use secure authentication mechanisms
- **Logging**: Avoid logging sensitive information like passwords

### Performance Guidelines
- **Resource Usage**: Be mindful of memory and CPU usage on resource-constrained systems
- **Database Queries**: Optimize queries and use appropriate indexes
- **Caching**: Implement caching where appropriate for frequently accessed data
- **Async Operations**: Use appropriate async patterns for long-running operations

This document should be updated as development practices evolve. When making changes that affect these guidelines, update this file accordingly.</content>
<parameter name="filePath">/mnt/c/work/mailinabox/AGENTS.md