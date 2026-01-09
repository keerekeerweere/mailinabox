FROM postgres:13

# Install additional packages if needed
RUN apt-get update && apt-get install -y \
    postgresql-contrib \
    && rm -rf /var/lib/apt/lists/*

# Copy custom PostgreSQL configuration if needed
# COPY postgresql.conf /etc/postgresql/postgresql.conf

# Set proper permissions
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql/data

USER postgres

EXPOSE 5432