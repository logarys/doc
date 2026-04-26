# Each container role

## UI

The UI is the dark web console used by administrators and users.

Responsibilities:

- display logs
- manage pipelines
- manage users
- expose configuration screens
- provide profile and authentication pages

## Console Manager

The Console Manager is the administration backend.

Responsibilities:

- create, update, delete, and list pipelines
- manage global configuration
- expose user management endpoints
- provide profile update endpoints

## Ingestor

The Ingestor is the write entrypoint.

Responsibilities:

- receive external logs
- validate payloads
- apply pipeline configuration
- normalize messages
- publish normalized messages to NATS JetStream

## Storage Manager

The Storage Manager consumes broker messages and persists them.

Responsibilities:

- subscribe to JetStream consumers
- process messages
- write documents to MongoDB
- retry transient failures

## Query API

The Query API exposes read operations.

Responsibilities:

- list logs
- filter logs with RSQL
- paginate results
- return counts or aggregations
- apply permission constraints

## NATS JetStream

NATS JetStream is the durable broker used to absorb ingestion bursts and deliver messages to consumers.

## MongoDB

MongoDB stores logs, pipeline definitions, metadata, and user-related data.
