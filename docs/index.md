---
title: Home
---

<div class="logarys-hero">
  <div>
    <span class="logarys-pill">Realtime logs and pipeline management</span>
    <h1>Logarys</h1>
    <p>Logarys is a modular platform for ingesting, normalizing, storing, querying, and administrating logs at scale.</p>
    <div class="logarys-actions">
      <a class="logarys-button primary" href="install/docker-compose/">Install with Docker Compose</a>
      <a class="logarys-button" href="https://hub.docker.com/repositories/logarys">Docker Hub</a>
      <a class="logarys-button" href="https://github.com/logarys">GitHub</a>
    </div>
  </div>
  <img src="assets/logo.svg" alt="Logarys logo" />
</div>

## Introduction

Logarys is organized as a set of focused containers. Each service has one responsibility: receive logs, transport them, persist them, query them, or administrate the platform.

The project is designed for two deployment modes:

- **Mono-server deployment** with Docker Compose for small and medium installations.
- **Kubernetes deployment** for scalable and resilient production platforms.

## Main capabilities

<div class="logarys-grid">
  <div class="logarys-card"><h3>Ingestion</h3><p>Expose HTTP or internal endpoints to collect logs and normalize them before publication.</p></div>
  <div class="logarys-card"><h3>Pipelines</h3><p>Define how payloads are parsed, transformed, routed, indexed, and retained.</p></div>
  <div class="logarys-card"><h3>Queries</h3><p>Search logs through a dedicated API using an RSQL-style filter syntax.</p></div>
  <div class="logarys-card"><h3>Administration</h3><p>Use the Logarys console to manage users, pipelines, and global configuration.</p></div>
</div>

## Official links

| Resource | Link |
|---|---|
| Docker Hub | [https://hub.docker.com/repositories/logarys](https://hub.docker.com/repositories/logarys) |
| GitHub | [https://github.com/logarys](https://github.com/logarys) |

!!! note
    Replace the GitHub URL with your real repository URL in `mkdocs.yml` and in this page.

## Components

A complete Logarys stack usually contains the UI, Console Manager, Ingestor, Storage Manager, NATS JetStream, and MongoDB.
