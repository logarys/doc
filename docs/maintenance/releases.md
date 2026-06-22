# Releases and Kubernetes deployment

Logarys documentation uses the same Harbor, Helm, APISIX, cert-manager, and rollout process as the Small Project website. Stable Git tags remain the version source.

## Configuration file

`bin/release` and `bin/deploy` load the project-root `.env` automatically. `.env.example` contains the same initialized defaults.

```dotenv
# Harbor
HARBOR_REGISTRY=containers.locafire.shop
HARBOR_PROJECT=small-project
HARBOR_REPOSITORY=logarys-docs
HARBOR_USERNAME=
HARBOR_PASSWORD=
HARBOR_EMAIL=sebastien.kus@gmail.com
HARBOR_LOGIN=true
HARBOR_PUSH_LATEST=true

# Kubernetes and Helm
KUBE_CONFIG=/home/seb/.kube/prod-1.yml
KUBE_CONTEXT=
KUBE_NAMESPACE=logarys
HELM_RELEASE=logarys-documentation
HELM_CHART=deploy/helm/logarys-documentation
HELM_TIMEOUT=10m
HELM_ATOMIC=true
HELM_CREATE_NAMESPACE=true

# APISIX and cert-manager
DEPLOY_HOST=docs.logarys.dev
DEPLOY_APISIX_INGRESS_CLASS=apisix
DEPLOY_APISIX_ROUTE_NAME=logarys-documentation
DEPLOY_APISIX_TLS_NAME=logarys-documentation-tls
DEPLOY_CERTIFICATE_NAME=logarys-documentation
DEPLOY_CERTIFICATE_SECRET=logarys-documentation-tls
DEPLOY_CERTIFICATE_ISSUER=letsencrypt-prod
DEPLOY_CERTIFICATE_ISSUER_KIND=ClusterIssuer
```

The deployment requires the existing `ClusterIssuer/letsencrypt-prod`. It deliberately does not create or update cluster-scoped certificate issuers.

## Release commands

Choose one semantic increment:

```bash
bin/release --patch
bin/release --minor
bin/release --major
```

The latest stable `x.y.z` or `vx.y.z` Git tag is used as the source version. Pre-release tags are ignored. Without a stable tag, the initial release is `0.1.0`.

The script performs these operations:

1. load and validate `.env`;
2. require a clean Git worktree;
3. detect the Git remote and fetch tags;
4. calculate the next stable version;
5. lint the Helm chart;
6. log in to Harbor when `HARBOR_LOGIN=true`;
7. build and push the immutable image and optional `latest` tag;
8. deploy the image with `bin/deploy`;
9. create and push the Git tag only after deployment succeeds.

This ordering prevents a failed Kubernetes deployment from consuming a Git release number.

Use a dry run to inspect the actions:

```bash
bin/release --minor --dry-run
```

Skip the mutable image tag or deployment when required:

```bash
bin/release --patch --skip-latest
bin/release --patch --skip-deploy
```

## Harbor image

The image repository is always:

```txt
HARBOR_REGISTRY/HARBOR_PROJECT/HARBOR_REPOSITORY
```

With the default values:

```txt
containers.locafire.shop/small-project/logarys-docs
```

The image exposes port `8080` and provides `/healthz` and `/version.json`.

## Deployment process

The chart is located at:

```txt
deploy/helm/logarys-documentation
```

Deploy an existing image version with:

```bash
bin/deploy 0.2.1
```

The deployment script follows the Small Project process without custom TLS bootstrap logic:

1. check `apisixroutes.apisix.apache.org` and `apisixtlses.apisix.apache.org`;
2. check `certificates.cert-manager.io` when certificate management is enabled;
3. check `IngressClass/apisix`;
4. check and wait for `ClusterIssuer/letsencrypt-prod`;
5. create the namespace when configured;
6. create or update the Harbor `docker-registry` Secret from `.env`;
7. validate the rendered manifests with `helm template`;
8. run a single `helm upgrade --install --wait --atomic`;
9. wait for the Deployment rollout and Certificate readiness;
10. verify HTTPS and the HTTP redirect.

The chart installs these resources together:

- `Deployment` with `maxUnavailable: 0`, startup/readiness/liveness probes, and a read-only runtime filesystem;
- `Service`;
- `PodDisruptionBudget`;
- `ApisixRoute` with HTTP-to-HTTPS redirection;
- `ApisixTls` referencing the certificate Secret;
- cert-manager `Certificate` using `letsencrypt-prod`.

## Important prerequisite

Confirm the issuer before deployment:

```bash
kubectl --kubeconfig=/home/seb/.kube/prod-1.yml \
  get clusterissuer letsencrypt-prod

kubectl --kubeconfig=/home/seb/.kube/prod-1.yml \
  wait --for=condition=Ready clusterissuer/letsencrypt-prod --timeout=10m
```

If the issuer is missing, restore the same cluster-level issuer used by Small Project rather than creating a Logarys-specific issuer in the application repository.
