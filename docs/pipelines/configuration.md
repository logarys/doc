# Pipeline configuration parameters

This page documents the pipeline configuration currently used by the **Logarys Ingestor** source code.

The ingestor loads:

- a global configuration file from `CONF_FILE`
- one JSON file per pipeline from `CONF_PIPELINES_DIR`

By default:

```txt
CONF_FILE=/conf/pipelines.json
CONF_PIPELINES_DIR=/conf/pipelines.d
```

## Configuration loading model

The global file contains shared defaults:

```json
{
  "defaults": {
    "enabled": true,
    "parser": {
      "type": "raw"
    },
    "defaults": {
      "env": "prod"
    },
    "publish": {
      "subject": "logs.normalized"
    },
    "security": {
      "mode": "none"
    }
  }
}
```

Each pipeline is stored as a dedicated JSON file in `CONF_PIPELINES_DIR`.

Example:

```txt
/conf/pipelines.d/php-app.json
```

When a pipeline is loaded, it is merged with global defaults.

Merge behavior:

- top-level pipeline values override global defaults
- `parser` is merged object-by-object
- `defaults` is merged object-by-object
- `publish` is merged object-by-object
- `security` is merged object-by-object
- if no security mode is provided, `none` is used

## Complete pipeline example

```json
{
  "id": "php-app",
  "source": "php-app",
  "enabled": true,
  "parser": {
    "type": "regex",
    "pattern": "^(?<timestamp>\\S+\\s+\\S+)\\s+\\[(?<level>[A-Z]+)\\]\\s+(?<message>.*)$"
  },
  "mapping": {
    "timestamp": "timestamp",
    "level": "level",
    "message": "message"
  },
  "defaults": {
    "source": "php-app",
    "host": "app-01",
    "service": "booking-api",
    "env": "prod"
  },
  "publish": {
    "subject": "logs.php.normalized"
  },
  "security": {
    "mode": "header",
    "token": "my-secret-token"
  }
}
```

## Real schema

```ts
export type PipelineSecurityMode = "none" | "header" | "query";
export type ParserType = "raw" | "json" | "regex";

export interface PipelineConfig {
  id: string;
  source: string;
  enabled: boolean;
  parser: {
    type: ParserType;
    pattern?: string;
  };
  mapping?: {
    timestamp?: string;
    level?: string;
    message?: string;
    source?: string;
    host?: string;
    service?: string;
    env?: string;
  };
  defaults?: {
    source?: string;
    host?: string;
    service?: string;
    env?: string;
  };
  publish: {
    subject: string;
  };
  security?: {
    mode: PipelineSecurityMode;
    token?: string;
  };
}
```

## Top-level fields

| Field | Type | Required | Description |
|---|---|---:|---|
| `id` | string | Yes | Unique pipeline identifier. Also used as the file name when saved through the API: `<id>.json`. |
| `source` | string | Yes | Source name used by the ingestion endpoint. A request to `/injest/:source` selects the pipeline with this source. |
| `enabled` | boolean | Yes | Enables or disables ingestion for this pipeline. Disabled pipelines return an error. |
| `parser` | object | Yes | Parser configuration. |
| `mapping` | object | No | Field mapping used by the regex parser. |
| `defaults` | object | No | Default values injected when the incoming payload does not provide them. |
| `publish` | object | Yes | NATS JetStream publication configuration. |
| `security` | object | No | Pipeline-level token validation configuration. Defaults to `none`. |

!!! warning
    Older documentation may mention `input`, `routing`, `storage`, `indexing`, `transforms`, `access`, `name`, or `description` fields. These fields are **not part of the current ingestor pipeline schema**.

## `id`

The `id` is the stable technical identifier of the pipeline.

Example:

```json
{
  "id": "nginx-access"
}
```

When a pipeline is saved through the API, it is written to:

```txt
CONF_PIPELINES_DIR/<id>.json
```

## `source`

The `source` links an HTTP ingestion request to a pipeline.

The ingestor controller exposes:

```txt
POST /injest/:source
```

Example:

```txt
POST /injest/php-app
```

This request uses the pipeline where:

```json
{
  "source": "php-app"
}
```

!!! note
    The current endpoint is spelled `/injest` in the source code.

## `enabled`

Controls whether the pipeline accepts logs.

```json
{
  "enabled": true
}
```

If `enabled` is `false`, the ingestor rejects requests for this pipeline.

## `parser`

The parser defines how `raw` log content is interpreted.

| Field | Type | Required | Description |
|---|---|---:|---|
| `type` | string | Yes | One of `raw`, `json`, or `regex`. |
| `pattern` | string | Required for `regex` | JavaScript regular expression pattern. Named capture groups are used for mapped fields. |

### Parser type: `raw`

The `raw` parser keeps the incoming raw message and lets the normalizer create a normalized log from it.

```json
{
  "parser": {
    "type": "raw"
  }
}
```

### Parser type: `json`

The `json` parser parses `raw` as JSON.

```json
{
  "parser": {
    "type": "json"
  }
}
```

The exact normalized fields are handled by `small-log-normalizer`.

### Parser type: `regex`

The `regex` parser uses a JavaScript regular expression with named capture groups.

```json
{
  "parser": {
    "type": "regex",
    "pattern": "^(?<timestamp>\\S+\\s+\\S+)\\s+\\[(?<level>[A-Z]+)\\]\\s+(?<message>.*)$"
  }
}
```

The regex parser expects named groups. Common group names are:

- `timestamp`
- `level`
- `message`
- `source`
- `host`
- `service`
- `env`

Groups that are not mapped to known fields are added to `extra`.

## `mapping`

The `mapping` object is mainly used with the `regex` parser.

It tells the parser which named capture group should be used for each normalized field.

| Field | Type | Description |
|---|---|---|
| `timestamp` | string | Capture group used as timestamp. |
| `level` | string | Capture group used as log level. |
| `message` | string | Capture group used as message. |
| `source` | string | Capture group used as source. |
| `host` | string | Capture group used as host. |
| `service` | string | Capture group used as service. |
| `env` | string | Capture group used as environment. |

Example using default group names:

```json
{
  "mapping": {
    "timestamp": "timestamp",
    "level": "level",
    "message": "message"
  }
}
```

Example using custom group names:

```json
{
  "parser": {
    "type": "regex",
    "pattern": "^(?<date>\\S+\\s+\\S+) (?<severity>[A-Z]+) (?<text>.*)$"
  },
  "mapping": {
    "timestamp": "date",
    "level": "severity",
    "message": "text"
  }
}
```

## `defaults`

Default values are used when the incoming payload does not provide the value.

| Field | Type | Description |
|---|---|---|
| `source` | string | Default source. |
| `host` | string | Default host. |
| `service` | string | Default service. |
| `env` | string | Default environment. |

Example:

```json
{
  "defaults": {
    "source": "php-app",
    "host": "app-01",
    "service": "booking-api",
    "env": "prod"
  }
}
```

Incoming request values have priority over defaults.

For example, if the request body contains `host`, it overrides `defaults.host`.

## `publish`

The `publish` object defines where the normalized log is published in NATS JetStream.

| Field | Type | Required | Description |
|---|---|---:|---|
| `subject` | string | Yes | NATS subject used to publish the normalized log. |

Example:

```json
{
  "publish": {
    "subject": "logs.php.normalized"
  }
}
```

Published messages contain:

```json
{
  "pipelineId": "php-app",
  "source": "php-app",
  "receivedAt": "2026-04-23T10:15:30.000Z",
  "normalizedLog": {}
}
```

The ingestor also publishes these headers:

| Header | Value |
|---|---|
| `x-pipeline-id` | Pipeline ID |
| `x-source` | Pipeline source |
| `x-log-level` | Normalized log level |

## `security`

Pipeline security controls token validation.

| Field | Type | Required | Description |
|---|---|---:|---|
| `mode` | string | Yes | One of `none`, `header`, or `query`. |
| `token` | string | Required for `header` and `query` | Expected token value. |

### Mode: `none`

No token is required.

```json
{
  "security": {
    "mode": "none"
  }
}
```

### Mode: `header`

The request must contain the `x-token` header.

```json
{
  "security": {
    "mode": "header",
    "token": "secret-token"
  }
}
```

Example request:

```bash
curl -X POST http://localhost:3000/injest/php-app \
  -H 'Content-Type: application/json' \
  -H 'x-token: secret-token' \
  -d '{"raw":"2026-04-23 10:15:30 [ERROR] Database connection failed"}'
```

### Mode: `query`

The request must contain a `token` query parameter.

```json
{
  "security": {
    "mode": "query",
    "token": "secret-token"
  }
}
```

Example request:

```bash
curl -X POST 'http://localhost:3000/injest/php-app?token=secret-token' \
  -H 'Content-Type: application/json' \
  -d '{"raw":"hello world"}'
```

## Ingestion request body

The ingestion endpoint receives this body:

```ts
export class IngestLogDto {
  raw!: string;
  host?: string;
  source?: string;
  service?: string;
  env?: string;
  metadata?: Record<string, unknown>;
}
```

Example:

```json
{
  "raw": "2026-04-23 10:15:30 [ERROR] Database connection failed",
  "host": "app-01",
  "source": "php-app",
  "service": "booking-api",
  "env": "prod",
  "metadata": {
    "requestId": "req-123"
  }
}
```

## Pipeline configuration API

The ingestor exposes endpoints to manage pipeline files.

| Method | Path | Description |
|---|---|---|
| `GET` | `/pipelines` | List loaded pipelines. |
| `GET` | `/pipelines/config` | Get global configuration. |
| `PUT` | `/pipelines/config` | Update global defaults. |
| `GET` | `/pipelines/:id` | Get one pipeline by ID. |
| `POST` | `/pipelines` | Create a pipeline. |
| `PUT` | `/pipelines/:id` | Update a pipeline. The URL ID overrides the body ID. |
| `POST` | `/pipelines/:id/enable` | Enable a pipeline. |
| `POST` | `/pipelines/:id/disable` | Disable a pipeline. |
| `DELETE` | `/pipelines/:id` | Delete a pipeline file. |

## Create pipeline example

```bash
curl -X POST http://localhost:3000/pipelines \
  -H 'Content-Type: application/json' \
  -d '{
    "id": "nginx-access",
    "source": "nginx-access",
    "enabled": true,
    "parser": {
      "type": "regex",
      "pattern": "^(?<message>.*)$"
    },
    "publish": {
      "subject": "logs.nginx.normalized"
    },
    "security": {
      "mode": "header",
      "token": "ingest-token"
    }
  }'
```

## Enable or disable a pipeline

```bash
curl -X POST http://localhost:3000/pipelines/nginx-access/disable
curl -X POST http://localhost:3000/pipelines/nginx-access/enable
```

## Delete a pipeline

```bash
curl -X DELETE http://localhost:3000/pipelines/nginx-access
```

## Validation rules

The API validates these constraints:

- `id` is required and must be a non-empty string
- `source` is required and must be a non-empty string
- `enabled` is required and must be a boolean
- `parser.type` must be `raw`, `json`, or `regex`
- `publish.subject` is required and must be a non-empty string
- `security.mode`, when present, must be `none`, `header`, or `query`
- optional mapping and default fields must be strings when provided

## Best practices

- Use stable `id` values.
- Keep `source` unique across all pipelines.
- Use explicit `publish.subject` values.
- Use `security.mode: "header"` for exposed HTTP ingestion endpoints.
- Do not commit real tokens in Git.
- Prefer global defaults for shared values such as `enabled`, `parser`, `publish`, and `security`.
- Test regex patterns with real log samples before enabling the pipeline.
- Keep NATS subject names consistent, for example `logs.<source>.normalized`.
