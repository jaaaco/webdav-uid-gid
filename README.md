
# wietrzyk-com/webdav-uid-gid

This Docker image sets up a WebDAV server with Nginx that runs with a specified UID and GID, ensuring that any files created by the server retain the correct ownership.

## Features

- WebDAV server based on Nginx
- Basic authentication support
- Customizable UID and GID for proper file ownership
- Configurable through environment variables

## Usage

To run the WebDAV server with the custom UID and GID, use the following Docker commands.

### Running with Docker

```sh
docker run -d \
  --name webdav \
  -e USERNAME=<your-username> \
  -e PASSWORD=<your-password> \
  -e UID=<your-uid> \
  -e GID=<your-gid> \
  -e TZ=<your-timezone> \
  -v /path/to/your/data:/data \
  -p 80:80 \
  ghcr.io/wietrzyk-com/webdav-uid-gid:latest
```

### Environment Variables

- `USERNAME`: The username for basic authentication (default: `your-username`)
- `PASSWORD`: The password for basic authentication (default: `your-password`)
- `UID`: The user ID to run the server as (default: `your-uid`)
- `GID`: The group ID to run the server as (default: `your-gid`)
- `TZ`: The timezone for the server (default: `your-timezone`)

### Volumes

- `/data`: Mount your data directory to this path to expose it via WebDAV.

### Ports

- `80`: The default port where the WebDAV server will be accessible.

## Kubernetes Deployment

The Docker image can also be used in a Kubernetes deployment. Below is a sample Kubernetes configuration:

### Sample Kubernetes Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: webdav
  namespace: <your-namespace>
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: webdav
  template:
    metadata:
      labels:
        app: webdav
    spec:
      serviceAccountName: <your-service-account>
      volumes:
        - name: <your-volume-name>
          persistentVolumeClaim:
            claimName: <your-pvc-claim-name>
      containers:
        - image: ghcr.io/wietrzyk-com/webdav-uid-gid:latest
          name: webdav
          volumeMounts:
            - name: <your-volume-name>
              mountPath: /data
          env:
            - name: TZ
              value: <your-timezone>
            - name: USERNAME
              value: <your-username>
            - name: PASSWORD
              value: <your-password>
            - name: UID
              value: "<your-uid>"
            - name: GID
              value: "<your-gid>"
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: webdav-ingress
  namespace: <your-namespace>
  annotations:
    nginx.ingress.kubernetes.io/proxy-body-size: 512m
spec:
  ingressClassName: nginx
  rules:
    - host: <your-host>
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: webdav
                port:
                  name: webdav
---
apiVersion: v1
kind: Service
metadata:
  name: webdav
  namespace: <your-namespace>
spec:
  ports:
    - port: 80
      protocol: TCP
      targetPort: 80
      name: webdav
  selector:
    app: webdav
```

### Deploying to Kubernetes

1. **Modify the Deployment Configuration:**

   Update the Kubernetes YAML configuration files with your specific values:

   - Replace `<your-namespace>` with your namespace.
   - Replace `<your-service-account>` with your service account name.
   - Replace `<your-volume-name>` with your volume name.
   - Replace `<your-pvc-claim-name>` with your PersistentVolumeClaim name.
   - Replace `<your-timezone>` with your desired timezone.
   - Replace `<your-username>`, `<your-password>`, `<your-uid>`, and `<your-gid>` with your specific values.
   - Replace `<your-host>` with your desired host.

2. **Apply the Deployment:**

   Apply the deployment configuration to your Kubernetes cluster:

   ```sh
   kubectl apply -f path/to/your/deployment.yml
   ```

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue to discuss any changes or improvements.
