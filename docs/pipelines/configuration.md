# Pipeline configuration parameters

This page documents the recommended full pipeline configuration schema.

## Complete example

```json
{
  "id": "payments-api",
  "name": "Payments API",
  "description": "Pipeline for payment service logs",
  "enabled": true,
  "input": {
    "type": "http",
    "path": "/ingest/payments",
    "method": "POST",
    "authMode": "bearer",
    "authToken": "change-me",
    "maxPayloadSize": 1048576,
    "contentType": "application/json"
  },
  "parser": {
    "type": "json",
    "timestampField": "timestamp",
    "messageField": "message",
    "levelField": "level",
    "timezone": "UTC"
  },
  "transforms": [
    { "type": "add-field", "field": "service", "value": "payments-api" },
    { "type": "rename-field", "from": "reqId", "to": "requestId" }
  ],
  "routing": {
    "stream": "LOGS",
    "subject": "logs.payments",
    "collection": "logs_payments"
  },
  "storage": {
    "database": "logarys",
    "retentionDays": 30,
    "ttlField": "timestamp",
    "writeConcern": "majority"
  },
  "indexing": {
    "fields": ["timestamp", "level", "service", "requestId"],
    "compound": [["service", "timestamp"], ["level", "timestamp"]]
  },
  "access": {
    "roles": ["admin", "operator"],
    "visibleTo": ["admin", "operator", "viewer"]
  },
  "tags": ["payments", "production"]
}
```

## Top-level fields

| Field | Type | Required | Description |
|---|---|---:|---|
| `id` | string | Yes | Stable unique technical identifier |
| `name` | string | Yes | Human-readable name |
| `description` | string | No | Free text description |
| `enabled` | boolean | Yes | Whether the pipeline processes events |
| `input` | object | Yes | Input endpoint or source configuration |
| `parser` | object | Yes | Payload parser configuration |
| `transforms` | array | No | Transform rules applied after parsing |
| `routing` | object | Yes | Broker and storage routing |
| `storage` | object | No | Retention and write options |
| `indexing` | object | No | Index recommendations or definitions |
| `access` | object | No | Visibility and authorization rules |
| `tags` | array | No | Labels for filtering and organization |

## `input`

| Field | Type | Required | Description |
|---|---|---:|---|
| `type` | string | Yes | `http`, `nats`, `file`, `syslog`, or custom |
| `path` | string | For HTTP | HTTP ingestion path |
| `method` | string | For HTTP | Usually `POST` |
| `subject` | string | For broker input | Source subject |
| `authMode` | string | No | `none`, `bearer`, `basic`, `api-key` |
| `authToken` | string | No | Shared token or secret reference |
| `maxPayloadSize` | number | No | Maximum payload size in bytes |
| `contentType` | string | No | Expected content type |

## `parser`

| Field | Type | Required | Description |
|---|---|---:|---|
| `type` | string | Yes | `json`, `text`, `keyvalue`, `regex`, `custom` |
| `timestampField` | string | No | Field used as event timestamp |
| `messageField` | string | No | Field used as message |
| `levelField` | string | No | Field used as severity level |
| `pattern` | string | For regex | Regex pattern |
| `timezone` | string | No | Default timezone when timestamp has none |
| `mappings` | object | No | Field mapping table |

## Transform types

| Transform | Description |
|---|---|
| `add-field` | Adds a fixed field |
| `rename-field` | Renames one field |
| `remove-field` | Removes one field |
| `copy-field` | Copies one field to another |
| `set-if-missing` | Adds a default value only if missing |
| `map-value` | Maps source values to normalized values |
| `drop-if` | Drops events matching a condition |

## Validation checklist

Ensure that the ID is unique, the HTTP path is unique, parser type matches real payloads, routing is explicit, retention policy is defined, and high-cardinality fields are not indexed unnecessarily.
