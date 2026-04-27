# Install on Kubernetes

Kubernetes is recommended when Logarys must scale horizontally, support rolling updates, or run on multiple nodes.

This guide uses the current public Logarys application images:

- `logarys/ui`
- `logarys/console-manager`
- `logarys/storage-manager`
- `logarys/ingestor`

There is no separate `logarys/query-api` image in the current Docker Hub namespace. Query and UI API traffic should be routed to `console-manager`.

## Recommended objects

| Component | Kubernetes object |
|---|---|
| UI | Deployment + Service |
| Console Manager | Deployment + Service |
| Ingestor | Deployment + Service |
| Storage Manager | Deployment |
| MongoDB | Managed service, operator, or StatefulSet |
| NATS JetStream | Helm chart, operator, or StatefulSet |

## Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: logarys
```

## ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: logarys-config
  namespace: logarys
data:
  NATS_URL: "nats://nats.logarys.svc.cluster.local:4222"
  MONGODB_URL: "mongodb://mongodb.logarys.svc.cluster.local:27017/logarys"
  LOGS_DB_NAME: "logarys"
  APP_HOST: "0.0.0.0"
```

## Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: logarys-secrets
  namespace: logarys
type: Opaque
stringData:
  JWT_SECRET: "change-me"
  ADMIN_PASSWORD: "change-me"
```

## UI deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ui
  namespace: logarys
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ui
  template:
    metadata:
      labels:
        app: ui
    spec:
      containers:
        - name: ui
          image: logarys/ui:latest
          ports:
            - containerPort: 4173
          env:
            - name: PUBLIC_CONSOLE_API_URL
              value: "https://logarys.example.com/api"
```

## UI service

```yaml
## UI service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ui
  namespace: logarys
spec:
  selector:
    app: ui
  ports:
    - name: http
      port: 4173
      targetPort: 4173
```

## Console Manager deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: console-manager
  namespace: logarys
spec:
  replicas: 2
  selector:
    matchLabels:
      app: console-manager
  template:
    metadata:
      labels:
        app: console-manager
    spec:
      containers:
        - name: console-manager
          image: logarys/console-manager:latest
          ports:
            - containerPort: 3002
          env:
            - name: APP_PORT
              value: "3002"
          envFrom:
            - configMapRef:
                name: logarys-config
            - secretRef:
                name: logarys-secrets
```

## Console Manager service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: console-manager
  namespace: logarys
spec:
  selector:
    app: console-manager
  ports:
    - name: http
      port: 3002
      targetPort: 3002
```

## Ingestor deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingestor
  namespace: logarys
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ingestor
  template:
    metadata:
      labels:
        app: ingestor
    spec:
      containers:
        - name: ingestor
          image: logarys/ingestor:latest
          ports:
            - containerPort: 3000
          env:
            - name: APP_PORT
              value: "3000"
            - name: CONF_FILE
              value: "/conf/pipelines.json"
            - name: CONF_PIPELINES_DIR
              value: "/conf/pipelines.d"
          envFrom:
            - configMapRef:
                name: logarys-config
```

## Ingestor service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingestor
  namespace: logarys
spec:
  selector:
    app: ingestor
  ports:
    - name: http
      port: 3000
      targetPort: 3000
```

## Storage Manager deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storage-manager
  namespace: logarys
spec:
  replicas: 1
  selector:
    matchLabels:
      app: storage-manager
  template:
    metadata:
      labels:
        app: storage-manager
    spec:
      containers:
        - name: storage-manager
          image: logarys/storage-manager:latest
          envFrom:
            - configMapRef:
                name: logarys-config
```

## Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: logarys
  namespace: logarys
spec:
  ingressClassName: nginx
  rules:
    - host: logarys.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ui
                port:
                  number: 4173
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: console-manager
                port:
                  number: 3002
          - path: /ingest
            pathType: Prefix
            backend:
              service:
                name: ingestor
                port:
                  number: 3000
```

## Scaling recommendations

- Scale `ingestor` based on incoming traffic, CPU usage, and HTTP latency.
- Scale `storage-manager` based on JetStream backlog, consumer lag, and MongoDB write latency.
- Scale `console-manager` based on UI/API traffic and query latency.
- Scale `ui` based on concurrent users and frontend traffic.

## Production recommendations

- Use fixed image tags instead of `latest`.
- Use a managed or operator-backed MongoDB deployment.
- Use the official NATS Helm chart or an operator-backed NATS deployment.
- Add readiness and liveness probes for all HTTP services.
- Keep secrets in Kubernetes Secrets or an external secret manager.
- Expose only UI, Console Manager, and Ingestor through the ingress.
