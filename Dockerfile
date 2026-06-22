# syntax=docker/dockerfile:1.7

FROM squidfunk/mkdocs-material:latest AS builder

ARG VERSION=dev
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown

WORKDIR /workspace
COPY . .
RUN mkdocs build --strict --clean --site-dir /workspace/site \
    && printf '{"version":"%s","revision":"%s","builtAt":"%s"}\n' \
      "$VERSION" "$VCS_REF" "$BUILD_DATE" \
      > /workspace/site/version.json

FROM nginxinc/nginx-unprivileged:1.29-alpine AS runtime

ARG VERSION=dev
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="Logarys Documentation" \
      org.opencontainers.image.description="Static documentation website for Logarys" \
      org.opencontainers.image.version="$VERSION" \
      org.opencontainers.image.revision="$VCS_REF" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.source="https://github.com/logarys"

COPY --chown=101:101 docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=101:101 --from=builder /workspace/site /usr/share/nginx/html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

# Bypass the image entrypoint scripts so the container starts cleanly with a
# read-only root filesystem. Runtime write paths are mounted as emptyDir volumes.
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
