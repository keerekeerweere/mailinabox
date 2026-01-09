FROM nginx:alpine

# Install additional packages if needed
RUN apk add --no-cache certbot certbot-nginx

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Create necessary directories
RUN mkdir -p /var/www/html /var/cache/nginx /var/log/nginx

# Set proper permissions
RUN chown -R nginx:nginx /var/cache/nginx /var/log/nginx /var/www/html

# Expose ports
EXPOSE 80 443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]