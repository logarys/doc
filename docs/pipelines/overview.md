# Pipelines overview

Pipelines define how incoming logs are received, parsed, transformed, routed, indexed, and stored.

## Pipeline lifecycle

1. Create a pipeline.
2. Configure input parameters.
3. Configure parser parameters.
4. Configure transforms.
5. Configure routing and storage.
6. Validate with sample payloads.
7. Enable the pipeline.
8. Monitor ingestion and query behavior.

## Pipeline responsibilities

A pipeline can expose an HTTP ingestion path, define authentication requirements, parse logs, add metadata fields, route documents, define indexes, and define retention.

## Example use cases

- application logs
- HTTP access logs
- audit events
- business events
- background worker logs
- security events

## Recommended pipeline states

| State | Description |
|---|---|
| Draft | Saved but not active |
| Enabled | Actively processing logs |
| Disabled | Existing but not processing logs |
| Archived | Kept for history only |
