# Contributing

Contributions are welcome for documentation, code, tests, deployment examples, and UI improvements.

## Workflow

1. Create a branch.
2. Implement your change.
3. Add or update tests.
4. Update documentation.
5. Open a pull request.

## Branch names

```txt
feature/add-pipeline-validator
fix/rsql-date-filter
docs/update-kubernetes-install
```

## Commit style

```txt
feat: add pipeline validation
fix: handle invalid RSQL operators
docs: update Docker Compose guide
```

## Code quality

Before opening a pull request, run tests, run linting, run build, check generated documentation, remove debug logs, and ensure no secret is committed.

## Documentation rule

Update documentation when changing environment variables, Docker images, Compose files, Kubernetes manifests, public APIs, pipeline configuration schema, user management behavior, or security behavior.

## Pull request checklist

- [ ] Build passes
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Configuration examples updated
- [ ] Backward compatibility considered
- [ ] No secrets committed

## Local docs preview

```bash
docker compose up -d
```

Open `http://localhost:8000`.
