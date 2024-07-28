FROM debian:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y nginx apache2-utils nginx-extras gosu && \
    rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /data /etc/nginx/webdav /var/lib/nginx /var/log/nginx /var/run

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

# Environment variables (no default values)
ENV USERNAME
ENV PASSWORD
ENV UID
ENV GID

# Entry point to run nginx
CMD set -e; \
    if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$UID" ] || [ -z "$GID" ]; then \
        echo "Environment variables USERNAME, PASSWORD, UID, and GID must be set"; \
        exit 1; \
    fi; \
    if ! id -u $USERNAME >/dev/null 2>&1; then \
        if getent passwd $UID >/dev/null 2>&1; then \
            EXISTING_USER=$(getent passwd $UID | cut -d: -f1); \
            EXISTING_GROUP=$(getent passwd $UID | cut -d: -f4); \
            echo "Using existing user: $EXISTING_USER and group: $EXISTING_GROUP"; \
            usermod -l $USERNAME $EXISTING_USER; \
            groupmod -n $USERNAME $EXISTING_GROUP; \
        else \
            groupadd -g $GID $USERNAME; \
            useradd -u $UID -g $USERNAME -d /data $USERNAME; \
        fi; \
        echo "$USERNAME:$PASSWORD" | chpasswd; \
        htpasswd -cb /etc/nginx/webdav/webdav.passwd $USERNAME $PASSWORD; \
    fi; \
    chown -R $UID:$GID /data /var/lib/nginx /var/log/nginx /var/run /etc/nginx; \
    exec gosu $UID:$GID nginx -g "daemon off;"
