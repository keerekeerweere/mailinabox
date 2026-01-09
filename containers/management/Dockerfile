FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy management code
COPY management/ .

# Install Python dependencies
RUN pip install --no-cache-dir \
    flask \
    flask-cors \
    psycopg2-binary \
    expiringdict \
    email-validator \
    dnspython \
    requests \
    bcrypt

# Create necessary directories
RUN mkdir -p /app/data /var/mail

# Expose port
EXPOSE 8080

# Set environment variables
ENV PYTHONPATH=/app
ENV FLASK_APP=daemon.py
ENV FLASK_ENV=development

# Run the management daemon
CMD ["python", "daemon.py"]