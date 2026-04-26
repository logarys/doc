# Install on a mono server with Docker Compose

This page describes a complete single-server Logarys deployment using Docker Compose.

## Prerequisites

- Docker Engine
- Docker Compose plugin
- 2 CPU minimum
- 4 GB RAM minimum
- SSD storage recommended
- A reverse proxy for production HTTPS

## Deployment layout

| Service | Purpose |
|---|---|
| `nats` | Durable broker with JetStream enabled |
| `mongodb` | Persistent document database |
| `ingestor` | Log entrypoint |
| `storage-manager` | Consumes broker messages and writes logs |
| `query-api` | Exposes read/query endpoints |
| `console-manager` | Exposes admin/configuration endpoints |
| `ui` | Web console |

## Example `docker-compose.yml`

```yaml
services:
  nats:
    image: nats:2.11-alpine
    command:
      - "-js"
      - "-m"
      - "8222"
      - "-sd"
      - "/data"
    ports:
      - "4222:4222"
      - "8222:8222"
    volumes:
      - nats-data:/data
    restart: unless-stopped

  mongodb:
    image: mongo:7
    ports:
      - "27017:27017"
    volumes:
      - mongodb-data:/data/db
    restart: unless-stopped

  ingestor:
    image: logarys/ingestor:latest
    environment:
      APP_HOST: "0.0.0.0"
      APP_PORT: "3000"
      NATS_URL: "nats://nats:4222"
      MONGODB_URL: "mongodb://mongodb:27017/logarys"
      CONF_FILE: "/conf/pipelines.json"
      CONF_PIPELINES_DIR: "/conf/pipelines.d"
    volumes:
      - ./conf:/conf:ro
    depends_on:
      - nats
      - mongodb
    ports:
      - "3000:3000"
    restart: unless-stopped

  storage-manager:
    image: logarys/storage-manager:latest
    environment:
      NATS_URL: "nats://nats:4222"
      MONGODB_URL: "mongodb://mongodb:27017/logarys"
      LOGS_DB_NAME: "logarys"
    depends_on:
      - nats
      - mongodb
    restart: unless-stopped

  query-api:
    image: logarys/query-api:latest
    environment:
      APP_HOST: "0.0.0.0"
      APP_PORT: "3001"
      MONGODB_URL: "mongodb://mongodb:27017/logarys"
      LOGS_DB_NAME: "logarys"
    depends_on:
      - mongodb
    ports:
      - "3001:3001"
    restart: unless-stopped

  console-manager:
    image: logarys/console-manager:latest
    environment:
      APP_HOST: "0.0.0.0"
      APP_PORT: "3002"
      MONGODB_URL: "mongodb://mongodb:27017/logarys"
      JWT_SECRET: "change-me"
    depends_on:
      - mongodb
    ports:
      - "3002:3002"
    restart: unless-stopped

  ui:
    image: logarys/ui:latest
    environment:
      PUBLIC_QUERY_API_URL: "http://localhost:3001"
      PUBLIC_CONSOLE_API_URL: "http://localhost:3002"
    depends_on:
      - query-api
      - console-manager
    ports:
      - "8080:80"
    restart: unless-stopped

volumes:
  nats-data:
  mongodb-data:
```

## Start the stack

```bash
docker compose up -d
```

## Check status

```bash
docker compose ps
docker compose logs -f
```

## Access URLs

| Component | URL |
|---|---|
| UI | `http://localhost:8080` |
| Ingestor | `http://localhost:3000` |
| Query API | `http://localhost:3001` |
| Console Manager | `http://localhost:3002` |
| NATS monitoring | `http://localhost:8222` |

## Production notes

Use fixed image tags, put the stack behind HTTPS, persist MongoDB and NATS volumes, and never commit production secrets.
