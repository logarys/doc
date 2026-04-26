# Logarys Documentation

This repository contains the documentation website for **Logarys**, a modular platform for log ingestion, pipeline management, storage, querying, and administration.

The documentation is built with **MkDocs Material** and can be served locally with Docker Compose.

## Links

- Docker Hub: https://hub.docker.com/repositories/logarys
- GitHub: https://github.com/logarys
- Documentation site: https://docs.logarys.dev

> Replace the GitHub and documentation URLs with your real project URLs.

## Documentation stack

This documentation site uses:

- [MkDocs](https://www.mkdocs.org/)
- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
- Docker Compose for local preview
- Caddy for optional static production serving

## Project structure

```txt
.
├── docker-compose.yml
├── docker-compose.prod.yml
├── mkdocs.yml
├── README.md
├── CONTRIBUTING.md
└── docs/
    ├── index.md
    ├── install/
    ├── architecture/
    ├── maintenance/
    ├── security/
    ├── query/
    ├── pipelines/
    └── contributing.md
```

## Run locally with Docker Compose

```bash
docker compose up -d
```

Then open:

```txt
http://localhost:8000
```

## Stop the documentation server

```bash
docker compose down
```

## Build the static documentation

```bash
docker compose run --rm docs build
```

The generated static site will be available in:

```txt
site/
```

## Production serving

A production example is provided with Caddy:

```bash
docker compose -f docker-compose.prod.yml up -d
```

Recommended production workflow:

1. build the static documentation
2. serve the generated `site/` directory with Caddy, Nginx, or another static web server
3. deploy behind HTTPS

## Editing documentation

Documentation pages are written in Markdown inside the `docs/` directory.

Example:

```txt
docs/install/docker-compose.md
docs/architecture/overview.md
docs/query/rsql.md
```

After editing, reload the local preview page. MkDocs automatically rebuilds the site in development mode.

## Style guidelines

- Write in clear technical English.
- Prefer short paragraphs.
- Use tables for configuration references.
- Use code blocks for commands and examples.
- Keep installation instructions copy-paste friendly.
- Keep URLs and version numbers up to date.
- Document every public configuration parameter.

## License

The documentation content is licensed under:

```txt
CC-BY-4.0
```

Code examples, Docker Compose files, Kubernetes manifests, and configuration snippets are licensed under:

```txt
MIT
```

Recommended repository files:

```txt
LICENSE        # CC-BY-4.0 for documentation
LICENSE-CODE   # MIT for code snippets and configuration examples
```
