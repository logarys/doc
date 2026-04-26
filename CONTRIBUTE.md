# Contributing to Logarys Documentation

Thank you for contributing to the Logarys documentation.

This document explains how to propose changes, write documentation, and keep the project consistent.

## What can be contributed?

You can contribute:

- installation guides
- Docker Compose examples
- Kubernetes manifests
- architecture documentation
- pipeline documentation
- RSQL query examples
- maintenance procedures
- troubleshooting guides
- typo fixes
- screenshots and diagrams
- translations, if the project later supports them

## Before contributing

Before opening a pull request, make sure your change is useful, accurate, and consistent with the current documentation style.

For large changes, open an issue first to discuss the proposal.

## Local setup

Start the documentation locally:

```bash
docker compose up -d
```

Open:

```txt
http://localhost:8000
```

MkDocs automatically reloads when Markdown files are changed.

## Branch naming

Use clear branch names.

Examples:

```txt
docs/add-kubernetes-guide
docs/update-pipeline-config
fix/typo-rsql-page
feature/add-maintenance-runbook
```

## Commit messages

Use concise commit messages.

Recommended examples:

```txt
docs: add Kubernetes installation guide
docs: update pipeline configuration reference
fix: correct RSQL operator example
chore: update Docker Compose documentation
```

## Pull request checklist

Before submitting a pull request:

- [ ] The documentation builds locally
- [ ] The change has been reviewed for spelling and clarity
- [ ] Commands have been tested when possible
- [ ] Docker Compose examples are valid
- [ ] Kubernetes YAML examples are valid
- [ ] Configuration parameters are documented
- [ ] No secrets or private URLs are committed
- [ ] Links are valid
- [ ] Screenshots do not expose sensitive information

## Documentation writing rules

### Use clear structure

Each page should generally follow this structure:

```md
# Page title

Short introduction.

## Main section

Explanation.

## Example

```bash
command here
```

## Best practices

Recommendations.
```

### Prefer practical examples

Good:

```md
To start the stack:

```bash
docker compose up -d
```
```

Avoid vague instructions such as:

```md
Start the app normally.
```

### Keep commands copy-paste friendly

Use full commands whenever possible.

Good:

```bash
docker compose logs -f console-manager
```

Less useful:

```bash
check logs
```

### Document environment variables

When adding or changing an environment variable, update the relevant table.

Example:

| Variable | Required | Default | Description |
|---|---:|---|---|
| `MONGODB_URL` | Yes | none | MongoDB connection string |
| `NATS_URL` | Yes | none | NATS JetStream connection string |

### Document breaking changes

If a change breaks existing deployments, mention it clearly.

Example:

```md
!!! warning
    This option replaces `OLD_ENV_NAME` starting from version `0.2.0`.
```

## Diagram updates

Architecture diagrams are stored in:

```txt
docs/architecture/assets/
```

When updating diagrams:

- keep SVG files editable
- avoid embedding external images unless necessary
- keep colors consistent with the Logarys UI
- ensure text remains readable in dark and light contexts

## UI design consistency

The documentation theme should remain close to the Logarys UI style:

- dark navy background
- cyan accent color
- rounded cards
- clean spacing
- high contrast
- readable code blocks

## Security rules

Never commit:

- passwords
- access tokens
- private keys
- production database URLs
- private hostnames
- real customer data
- screenshots exposing sensitive information

Use placeholders instead:

```txt
change-me
example.com
mongodb://mongodb:27017/logarys
```

## Review guidelines

Reviewers should check:

- technical accuracy
- consistency with existing docs
- security implications
- clarity for new users
- valid commands and configuration examples
- no accidental secrets

## Licensing

By contributing, you agree that:

- documentation content is licensed under **CC-BY-4.0**
- code examples and configuration snippets are licensed under **MIT**

## Need help?

Open an issue with:

- what you are trying to document
- what is unclear
- the current behavior
- the expected documentation result
