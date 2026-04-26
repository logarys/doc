# Maintenance best practices

## Use fixed image tags

```yaml
image: logarys/query-api:0.1.0
```

Avoid `latest` in production.

## Back up persistent data

Back up MongoDB data, NATS JetStream data when replay is required, configuration files, and secrets references.

## Monitor disk usage

Monitor MongoDB volume size, NATS volume size, Docker overlay size, and backup size.

## Define retention policies

| Log type | Suggested retention |
|---|---:|
| Debug logs | 3 to 7 days |
| Application logs | 15 to 30 days |
| Security/audit logs | 90 days or more |
| Compliance logs | According to legal requirements |

## Monitor broker lag

A growing broker backlog can indicate slow storage consumers, slow MongoDB writes, oversized messages, or unexpected pipeline volume.

## Index carefully

Recommended indexes: timestamp, pipeline id, level, service name, request id or correlation id.

Avoid indexing every dynamic field.

## Validate pipeline changes

Test sample payloads, validate parser output, check routing, verify query behavior, and test performance before enabling production pipelines.

## Secure the deployment

Use HTTPS, keep MongoDB and NATS on private networks, rotate secrets, disable unused users, and protect admin routes.

## Useful commands

```bash
docker compose ps
docker compose logs -f
docker compose pull
docker compose up -d
docker system df
```
