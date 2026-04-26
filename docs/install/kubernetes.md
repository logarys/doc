# Install on Kubernetes

Kubernetes is recommended when Logarys must scale horizontally, support rolling updates, or run on multiple nodes.

## Recommended objects

| Component | Kubernetes object |
|---|---|
| UI | Deployment + Service |
| Console Manager | Deployment + Service |
| Ingestor | Deployment + Service |
| Storage Manager | Deployment |
| Query API | Deployment + Service |
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

## Query API deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: query-api
  namespace: logarys
spec:
  replicas: 2
  selector:
    matchLabels:
      app: query-api
  template:
    metadata:
      labels:
        app: query-api
    spec:
      containers:
        - name: query-api
          image: logarys/query-api:0.1.0
          ports:
            - containerPort: 3001
          envFrom:
            - configMapRef:
                name: logarys-config
            - secretRef:
                name: logarys-secrets
          resources:
            requests:
              cpu: "100m"
              memory: "256Mi"
            limits:
              cpu: "500m"
              memory: "512Mi"
```

## Query API service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: query-api
  namespace: logarys
spec:
  selector:
    app: query-api
  ports:
    - name: http
      port: 3001
      targetPort: 3001
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
                  number: 80
          - path: /api/query
            pathType: Prefix
            backend:
              service:
                name: query-api
                port:
                  number: 3001
```

## Scaling recommendations

Scale the Ingestor on incoming traffic, Storage Manager on broker backlog, and Query API on user traffic and query latency.
