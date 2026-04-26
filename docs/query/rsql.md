# RSQL documentation

Logarys uses an RSQL-style syntax to filter logs through the Query API.

## Basic syntax

```txt
field==value
field!=value
field>value
field>=value
field<value
field<=value
```

## Logical operators

| Operator | Meaning | Example |
|---|---|---|
| `;` | AND | `service==api;level==ERROR` |
| `,` | OR | `level==ERROR,level==WARN` |

## Examples

### All errors

```txt
level==ERROR
```

### Errors for one service

```txt
service==payment-api;level==ERROR
```

### HTTP 5xx errors

```txt
statusCode>=500;statusCode<600
```

### Logs during a time range

```txt
timestamp>=2026-04-01T00:00:00Z;timestamp<2026-04-02T00:00:00Z
```

### Logs from production or staging

```txt
env==prod,env==staging
```

## Recommended fields

| Field | Description |
|---|---|
| `timestamp` | Log event timestamp |
| `level` | Log level |
| `service` | Service or application name |
| `pipelineId` | Pipeline that processed the event |
| `message` | Log message |
| `requestId` | Request/correlation identifier |
| `statusCode` | HTTP status code |
| `env` | Environment name |

## URL encoding

Raw filter:

```txt
service==api;level==ERROR
```

Encoded filter:

```txt
service%3D%3Dapi%3Blevel%3D%3DERROR
```

## Pagination and sorting

```txt
/api/logs?filter=level%3D%3DERROR&page=1&limit=50&sort=-timestamp
```

## Best practices

Filter by date range, filter by indexed fields first, paginate results, avoid unbounded exports, and validate fields server-side.
