#!/usr/bin/env bash

load_env_file() {
  local env_file="${1:-.env}"
  if [[ ! -f "$env_file" ]]; then
    printf 'Environment file not found: %s\n' "$env_file" >&2
    return 1
  fi

  set -a
  # shellcheck disable=SC1090
  source "$env_file"
  set +a
}

require_env() {
  local missing=()
  local variable
  for variable in "$@"; do
    if [[ -z "${!variable:-}" ]]; then
      missing+=("$variable")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    printf 'Missing required variables in .env: %s\n' "${missing[*]}" >&2
    return 1
  fi
}

is_true() {
  case "${1,,}" in
    1|true|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

require_command() {
  local command_name="$1"
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$command_name" >&2
    return 1
  fi
}
