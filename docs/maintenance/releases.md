# Releases and Kubernetes deployment

The repository contains a release pipeline built around stable Git tags. The same semantic version is used for the Git tag, Harbor image tag, and Helm deployment.

## Required `.env` file

`bin/release` and `bin/deploy` automatically load the project-root `.env`. The repository already contains an initialized file with defaults, and `.env.example` mirrors the available settings.

Do not configure Harbor or deployment values with temporary shell exports. Update `.env` instead:

```dotenv
# Docker build
DOCKER_BUILD_ARGS=

# Harbor registry
HARBOR_REGISTRY=containers.locafire.shop
HARBOR_PROJECT=logarys
HARBOR_IMAGE_NAME=documentation
HARBOR_USERNAME=
HARBOR_PASSWORD=
HARBOR_IMAGE_PULL_SECRET=harbor-registry-credentials

# Kubernetes / Helm deployment
DEPLOY_KUBE_CONFIG=${HOME}/.kube/config
DEPLOY_RELEASE_NAME=logarys-documentation
DEPLOY_NAMESPACE=logarys
DEPLOY_HOST=docs.logarys.dev
DEPLOY_CLUSTER_ISSUER=letsencrypt-production
DEPLOY_TLS_SECRET_NAME=logarys-documentation-tls
DEPLOY_REPLICAS=2
DEPLOY_TIMEOUT=5m
DEPLOY_CERTIFICATE_TIMEOUT=10m
DEPLOY_VALUES_FILE=
DEPLOY_APISIX_INGRESS_CLASS=apisix
DEPLOY_APISIX_PRIORITY=10
DEPLOY_APISIX_BOOTSTRAP_PRIORITY=-100
```

The `.env` file is ignored by Git. Keep production credentials only in that local file or inject them securely when provisioning the working copy.

## Release commands

Choose exactly one increment:

```bash
bin/release --patch
bin/release --minor
bin/release --major
```

Stable tags must use `x.y.z` or `vx.y.z`. Pre-release tags are ignored when the next version is calculated. When the repository has no stable tag, the first release is `0.1.0` regardless of the requested increment.

The Git remote is not configured in `.env`. The script uses `origin` when available, otherwise the current branch tracking remote, otherwise the repository's only configured remote.

The release command performs these operations:

1. loads and validates `.env`
2. verifies that the Git worktree is clean
3. detects the Git remote automatically and fetches its tags
4. calculates the next stable semantic version
5. authenticates to Harbor when both credentials are configured
6. creates an annotated local Git tag
7. builds the static MkDocs site inside the Docker image
8. pushes `<Harbor repository>:<version>` and `<Harbor repository>:latest`
9. pushes the Git tag
10. invokes `bin/deploy <version>`

Use a dry run to inspect the calculated version and actions:

```bash
bin/release --minor --dry-run
```

## Harbor behavior

The image repository is always derived from:

```txt
HARBOR_REGISTRY/HARBOR_PROJECT/HARBOR_IMAGE_NAME
```

For the default configuration, this resolves to:

```txt
containers.locafire.shop/logarys/documentation
```

When both `HARBOR_USERNAME` and `HARBOR_PASSWORD` are empty, the release relies on the current Docker credential store. When one is populated, both must be populated, and the script runs `docker login` using `--password-stdin`.

The image exposes HTTP on port `8080` and provides:

- `/healthz` for Kubernetes probes
- `/version.json` for release metadata

## Helm deployment

The chart is located in:

```txt
helm/logarys-documentation
```

It creates:

- a rolling-update `Deployment` with zero unavailable replicas
- a `ClusterIP` service
- an HTTPS-only APISIX route
- an `ApisixTls` resource
- a cert-manager `Certificate`

The deployment script can also be run independently for an image that has already been pushed:

```bash
bin/deploy 1.2.3
```

It reads the kubeconfig, namespace, host, certificate issuer, APISIX class, replica count, timeouts, optional values file, and Harbor image pull secret from `.env`.

### First-deployment TLS bootstrap

An `ApisixTls` resource requires its referenced Kubernetes Secret to already contain the certificate and private key. On a new namespace, cert-manager has not created that Secret yet. To avoid applying an invalid TLS reference and to keep the ACME HTTP challenge reachable, `bin/deploy` uses two phases when the Secret is absent:

1. Helm deploys the application, Service, HTTP `ApisixRoute`, and `Certificate`; `ApisixTls` and HTTP-to-HTTPS redirection remain disabled.
2. The script waits up to `DEPLOY_CERTIFICATE_TIMEOUT` for `certificate/<release-name>` to become `Ready`, then verifies the TLS Secret.
3. A final Helm upgrade enables `ApisixTls` and the HTTPS redirect with `--atomic` and `--wait`.

When the TLS Secret already exists, only the final atomic upgrade is required. The `Certificate` explicitly uses `privateKey.rotationPolicy: Always`, avoiding the cert-manager 1.18 default-change warning.

If certificate issuance fails, the script prints the current `Certificate`, `CertificateRequest`, ACME `Order`, and `Challenge` resources. Correct the DNS, issuer, or solver configuration, then rerun the same published version:

```bash
bin/deploy 0.1.0
```

Do not run `bin/release` again solely to retry a deployment after its Git tag and image have already been pushed.

## Optional release controls

Skip the mutable `latest` image:

```bash
bin/release --patch --skip-latest
```

Publish without deploying:

```bash
bin/release --patch --skip-deploy
```

To use an additional Helm values file, set its path in `.env`:

```dotenv
DEPLOY_VALUES_FILE=/absolute/path/to/production.values.yaml
```
