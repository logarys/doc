# Each container role

## UI

The UI is the dark web console used by administrators and users.

Image:

```txt
logarys/ui
```

Responsibilities:

- display logs
- manage pipelines
- manage users
- expose configuration screens
- provide profile and authentication pages
- communicate with the Console Manager API

## Console Manager

The Console Manager is the UI API and administration backend.

Image:

```txt
logarys/console-manager
```

Responsibilities:

- create, update, delete, and list pipelines
- manage global configuration
- expose user management endpoints
- provide profile update endpoints
- expose log query endpoints used by the UI
- translate UI filters, including RSQL, into database queries

## Ingestor

The Ingestor is the write entrypoint.

Image:

```txt
logarys/ingestor
```

Responsibilities:

- receive external logs
- validate payloads
- apply pipeline configuration
- normalize messages
- publish normalized messages to NATS JetStream

## Storage Manager

The Storage Manager consumes broker messages and persists them.

Image:

```txt
logarys/storage-manager
```

Responsibilities:

- subscribe to JetStream consumers
- process messages
- write documents to MongoDB
- manage rotation, retention, indexes, and metrics
- retry transient failures

## NATS JetStream

NATS JetStream is the durable broker used to absorb ingestion bursts and deliver messages to consumers.

## MongoDB

MongoDB stores logs, pipeline definitions, metadata, and user-related data.
