#!/bin/bash

set -e

echo "Starting container with UID: $UID, GID: $GID, USERNAME: $USERNAME"

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$UID" ] || [ -z "$GID" ]; then
    echo "Environment variables USERNAME, PASSWORD, UID, and GID must be set"
    exit 1
fi

if getent passwd $UID >/dev/null 2>&1; then
    EXISTING_USER=$(getent passwd $UID | cut -d: -f1)
    EXISTING_GROUP=$(getent passwd $UID | cut -d: -f4)
    echo "Using existing user: $EXISTING_USER and group: $EXISTING_GROUP"
    sed -i "s/__NGINX_USER__/$EXISTING_USER/" /etc/nginx/nginx.conf
else
    groupadd -g $GID $USERNAME
    useradd -u $UID -g $USERNAME -d /data $USERNAME
    echo "$USERNAME:$PASSWORD" | chpasswd
    sed -i "s/__NGINX_USER__/$USERNAME/" /etc/nginx/nginx.conf
fi

htpasswd -cb /etc/nginx/webdav/webdav.passwd $USERNAME $PASSWORD
chown -R $UID:$GID /data /var/lib/nginx /var/log/nginx /var/run /etc/nginx

exec nginx -g "daemon off;"
