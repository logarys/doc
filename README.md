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
│   └── release
├── scripts/lib/
│   └── env.sh
├── docker/
│   └── nginx.conf
├── deploy/helm/logarys-documentation/
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

The repository includes initialized `.env` and `.env.example` files. Both `bin/release` and `bin/deploy` load `.env` automatically. The deployment variables intentionally use the same names and defaults as the working Small Project deployment process.

Configure the Harbor credentials before deployment:

```dotenv
HARBOR_REGISTRY=containers.locafire.shop
HARBOR_PROJECT=small-project
HARBOR_REPOSITORY=logarys-docs
HARBOR_USERNAME=
HARBOR_PASSWORD=
HARBOR_EMAIL=sebastien.kus@gmail.com
HARBOR_LOGIN=true
```

The Kubernetes defaults target the production cluster and the existing Small Project certificate issuer:

```dotenv
KUBE_CONFIG=/home/seb/.kube/prod-1.yml
KUBE_NAMESPACE=logarys
HELM_RELEASE=logarys-documentation
HELM_CHART=deploy/helm/logarys-documentation
DEPLOY_HOST=docs.logarys.dev
DEPLOY_APISIX_INGRESS_CLASS=apisix
DEPLOY_CERTIFICATE_ISSUER=letsencrypt-prod
```

`ClusterIssuer/letsencrypt-prod` is a cluster prerequisite. The Logarys deployment does not create or modify it. This is the same behavior as the Small Project deployment.

## Docker image release

Stable Git tags are the sole version source. The release script calculates the next semantic version, builds and pushes the Harbor image, deploys it, then publishes the Git tag only after deployment succeeds. A failed deployment therefore does not consume a release number.

```bash
bin/release --patch
bin/release --minor
bin/release --major
```

When no stable tag exists, the first version is `0.1.0`. The image repository is derived from:

```txt
HARBOR_REGISTRY/HARBOR_PROJECT/HARBOR_REPOSITORY
```

Inspect a release without changing anything:

```bash
bin/release --minor --dry-run
```

## Kubernetes deployment with Helm and APISIX

The chart is located in `deploy/helm/logarys-documentation`. The deployment uses the same single-pass workflow as Small Project:

1. validate the canonical APISIX and cert-manager CRDs;
2. validate `IngressClass/apisix` and the configured issuer;
3. create or update the namespace and Harbor image pull secret;
4. render the chart with `helm template`;
5. run one `helm upgrade --install --wait`, with `--atomic` enabled by default;
6. wait for the Deployment rollout and Certificate readiness;
7. verify the HTTPS endpoint and HTTP-to-HTTPS redirect.

The chart creates the `Deployment`, `Service`, `PodDisruptionBudget`, `ApisixRoute`, `ApisixTls`, and cert-manager `Certificate` together. It does not use a custom TLS bootstrap or create a `ClusterIssuer`.

The release script invokes deployment automatically. A published image can also be deployed directly:

```bash
bin/deploy 1.2.3
```

See [Releases and Kubernetes deployment](docs/maintenance/releases.md) for the complete reference.

