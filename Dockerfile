FROM debian:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y nginx apache2-utils nginx-extras gosu && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /data /etc/nginx/webdav /var/lib/nginx /var/log/nginx /var/run

# Copy configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/sites-available/default
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Environment variables (no default values)
ENV USERNAME=username
ENV PASSWORD=password
ENV UID=33
ENV GID=33

# Entry point to run nginx
ENTRYPOINT ["/entrypoint.sh"]
