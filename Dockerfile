FROM debian:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y nginx apache2-utils nginx-extras gosu && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /data /etc/nginx/webdav

# Add a simple WebDAV configuration
RUN echo 'server { \
    listen 80; \
    server_name _; \
    location / { \
        dav_methods PUT DELETE MKCOL COPY MOVE; \
        dav_ext_methods PROPFIND OPTIONS; \
        dav_access user:rw group:rw all:r; \
        auth_basic "Restricted"; \
        auth_basic_user_file /etc/nginx/webdav/webdav.passwd; \
        autoindex on; \
        allow all; \
        client_max_body_size 512m; \
    } \
}' > /etc/nginx/sites-available/default

# Environment variables
ENV USERNAME=username
ENV PASSWORD=password
ENV UID=33
ENV GID=33

# Entry point to run nginx
CMD useradd -u $UID -g $GID -d /data $USERNAME && \
    echo "$USERNAME:$PASSWORD" | chpasswd && \
    htpasswd -cb /etc/nginx/webdav/webdav.passwd $USERNAME $PASSWORD && \
    chown -R $UID:$GID /data && \
    exec gosu $UID:$GID nginx -g "daemon off;"
