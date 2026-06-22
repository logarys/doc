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
- Multi-stage Docker image with unprivileged Nginx for production serving

## Project structure

```txt
.
├── .env
├── .env.example
├── bin/
│   ├── deploy
│   ├── release
│   └── lib/environment.sh
├── docker/
│   └── nginx.conf
├── helm/logarys-documentation/
├── Dockerfile
├── docker-compose.yml
├── docker-compose.prod.yml
├── mkdocs.yml
├── README.md
├── CONTRIBUTE.md
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

The production Compose file uses the same immutable image produced by the release process. It builds the MkDocs site in a multi-stage Docker build and serves it with unprivileged Nginx on container port `8080`.

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

Then open:

```txt
http://localhost:8080
```

In Kubernetes, use the included Helm chart so the site is exposed through HTTPS with APISIX and cert-manager.

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

## Environment configuration

The repository includes an initialized `.env` file with local, Harbor, and Kubernetes defaults. Both `bin/release` and `bin/deploy` load this file automatically; deployment and registry settings are not read from ad-hoc shell exports.

Edit at least the Harbor credentials and deployment target before the first production release:

```dotenv
HARBOR_REGISTRY=containers.locafire.shop
HARBOR_PROJECT=logarys
HARBOR_IMAGE_NAME=documentation
HARBOR_USERNAME=
HARBOR_PASSWORD=
HARBOR_IMAGE_PULL_SECRET=harbor-registry-credentials

DEPLOY_KUBE_CONFIG=${HOME}/.kube/config
DEPLOY_NAMESPACE=logarys
DEPLOY_HOST=docs.logarys.dev
DEPLOY_CLUSTER_ISSUER=letsencrypt-production
```

`HARBOR_USERNAME` and `HARBOR_PASSWORD` may both remain empty when Docker is already authenticated. If one is set, both are required. The `.env` file is ignored by Git so credentials remain local; `.env.example` contains the same safe defaults as a reference.

## Docker image release

Stable Git tags are the sole version source. The release script loads `.env`, calculates the next version, authenticates to Harbor when credentials are configured, builds and pushes the image, pushes the Git tag, and invokes the Helm deployment script.

```bash
bin/release --patch
bin/release --minor
bin/release --major
```

When no stable tag exists, the first version is `0.1.0`. The image repository is derived from:

```txt
HARBOR_REGISTRY/HARBOR_PROJECT/HARBOR_IMAGE_NAME
```

Inspect a release without changing anything:

```bash
bin/release --minor --dry-run
```

## Kubernetes deployment with Helm and APISIX

The chart is available in `helm/logarys-documentation`. It deploys two replicas with rolling updates, readiness/liveness probes, an APISIX route, APISIX TLS binding, and a cert-manager certificate.

The release script calls this command automatically:

```bash
bin/deploy 1.2.3
```

The deployment command reads `DEPLOY_*` values and `HARBOR_IMAGE_PULL_SECRET` exclusively from `.env`. It uses `--atomic`, `--wait`, and the configured timeout.

See [Releases and Kubernetes deployment](docs/maintenance/releases.md) for the complete reference.
