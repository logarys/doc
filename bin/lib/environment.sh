#!/usr/bin/env bash

# Shared .env loading and Harbor image resolution for release/deployment scripts.

load_project_environment() {
  local project_dir="$1"
  local env_file="${project_dir}/.env"

  [[ -f "$env_file" ]] || {
    printf 'ERROR: Required environment file not found: %s\n' "$env_file" >&2
    printf 'Create it from .env.example before running this command.\n' >&2
    return 1
  }

  set -a
  # The project-owned .env intentionally uses shell-compatible KEY=value syntax.
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
}

require_environment_value() {
  local variable_name="$1"
  local variable_value="${!variable_name:-}"

  [[ -n "$variable_value" ]] || {
    printf 'ERROR: %s must be configured in .env.\n' "$variable_name" >&2
    return 1
  }
}

harbor_image_repository() {
  require_environment_value HARBOR_REGISTRY || return 1
  require_environment_value HARBOR_PROJECT || return 1
  require_environment_value HARBOR_IMAGE_NAME || return 1

  local registry="${HARBOR_REGISTRY%/}"
  local project="${HARBOR_PROJECT#/}"
  local image_name="${HARBOR_IMAGE_NAME#/}"

  project="${project%/}"
  image_name="${image_name%/}"

  [[ "$registry" != *'://'* ]] || {
    printf 'ERROR: HARBOR_REGISTRY must not contain a URL scheme.\n' >&2
    return 1
  }
  [[ "$registry" != */* ]] || {
    printf 'ERROR: HARBOR_REGISTRY must contain only a hostname and optional port.\n' >&2
    return 1
  }
  [[ "$project" != */* ]] || {
    printf 'ERROR: HARBOR_PROJECT must be a single Harbor project name.\n' >&2
    return 1
  }
  [[ "$registry" != *[[:space:]]* && "$project" != *[[:space:]]* && "$image_name" != *[[:space:]]* ]] || {
    printf 'ERROR: Harbor image settings must not contain whitespace.\n' >&2
    return 1
  }

  printf '%s/%s/%s\n' "$registry" "$project" "$image_name"
}
