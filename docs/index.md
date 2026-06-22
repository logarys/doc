---
title: Home
hide:
  - toc
---

<div class="logarys-hero">
  <div class="logarys-hero__content">
    <span class="logarys-kicker">Realtime observability platform</span>
    <h1><span>Logs made operational.</span></h1>
    <p>Logarys provides a modular path from log ingestion to durable storage, structured queries, pipeline administration, and production operations.</p>
    <div class="logarys-actions">
      <a class="logarys-button primary" href="install/docker-compose/">Start with Docker Compose</a>
      <a class="logarys-button" href="architecture/overview/">Explore the architecture</a>
      <a class="logarys-button" href="https://hub.docker.com/repositories/logarys">View Docker images</a>
    </div>
  </div>
  <div class="logarys-hero__visual" aria-hidden="true">
    <div class="logarys-hero__orbit"></div>
    <img class="logarys-hero__logo" src="assets/logo.svg" alt="" />
  </div>
</div>

<div class="logarys-section-intro">
  <div>
    <span class="logarys-pill">Platform model</span>
    <h2>One focused service for every operational responsibility</h2>
  </div>
  <p>Logarys separates ingestion, transport, persistence, querying, and administration. This keeps each component easier to scale, secure, replace, and operate independently.</p>
</div>

<div class="logarys-grid">
  <div class="logarys-card">
    <span class="logarys-card__index">01</span>
    <h3>Ingest consistently</h3>
    <p>Receive logs through HTTP or internal endpoints, then normalize heterogeneous payloads before publication.</p>
  </div>
  <div class="logarys-card">
    <span class="logarys-card__index">02</span>
    <h3>Control pipelines</h3>
    <p>Configure parsing, transformation, routing, security, publication, indexing, and retention behavior.</p>
  </div>
  <div class="logarys-card">
    <span class="logarys-card__index">03</span>
    <h3>Query operational data</h3>
    <p>Search stored events through a dedicated API using expressive RSQL-style filters.</p>
  </div>
  <div class="logarys-card">
    <span class="logarys-card__index">04</span>
    <h3>Administer safely</h3>
    <p>Manage users, pipelines, permissions, and global configuration from the Logarys console.</p>
  </div>
</div>

## From event to searchable record

<div class="logarys-flow" aria-label="Log processing flow">
  <div class="logarys-flow__item"><strong>Applications</strong><span>Emit events</span></div>
  <div class="logarys-flow__item"><strong>Ingestor</strong><span>Parse and normalize</span></div>
  <div class="logarys-flow__item"><strong>JetStream</strong><span>Transport durably</span></div>
  <div class="logarys-flow__item"><strong>Storage Manager</strong><span>Persist records</span></div>
  <div class="logarys-flow__item"><strong>Console</strong><span>Query and operate</span></div>
</div>

## Choose your path

<div class="logarys-paths">
  <a class="logarys-path" href="install/docker-compose/">
    <small>Deploy</small>
    <strong>Install on one server</strong>
    <span>Launch a complete stack with Docker Compose for evaluation or smaller installations.</span>
  </a>
  <a class="logarys-path" href="install/kubernetes/">
    <small>Scale</small>
    <strong>Deploy on Kubernetes</strong>
    <span>Prepare a resilient production deployment with independent service scaling.</span>
  </a>
  <a class="logarys-path" href="pipelines/configuration/">
    <small>Configure</small>
    <strong>Define a pipeline</strong>
    <span>Review every supported parser, mapping, publication, and security parameter.</span>
  </a>
</div>

## Deployment options

Logarys supports two primary deployment models:

- **Docker Compose** for mono-server, development, evaluation, and small-to-medium installations.
- **Kubernetes** for scalable, resilient, and independently operated production services.

<div class="logarys-link-panel">
  <p><strong>Need the complete system view?</strong>See how the UI, Console Manager, Ingestor, Storage Manager, NATS JetStream, and MongoDB cooperate.</p>
  <a class="logarys-button" href="architecture/containers/">Review all components</a>
</div>
