#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
backend_root="${project_root}/repositories/backend"
frontend_root="${project_root}/repositories/frontend"

if [[ ! -f "${backend_root}/server/mix.exs" || ! -f "${frontend_root}/Cargo.toml" ]]; then
  printf 'Expected backend and frontend repositories under repositories/.\n' >&2
  exit 1
fi

if ! command -v protoc >/dev/null 2>&1; then
  printf 'protoc is required to build the Rust handshake types.\n' >&2
  exit 1
fi

schema_path="proto/slouching/v1/handshake.proto"
if ! cmp -s "${project_root}/${schema_path}" "${backend_root}/${schema_path}" ||
   ! cmp -s "${project_root}/${schema_path}" "${frontend_root}/${schema_path}"; then
  printf 'Handshake protobuf schema differs between repositories.\n' >&2
  exit 1
fi

printf 'Checking Elixir backend...\n'
(
  cd "${backend_root}/server"
  mix format --check-formatted
  mix test
  mix compile --warnings-as-errors
  ./scripts/smoke-local-sqlite.sh
)
printf 'Checking Rust/Iced client...\n'
cargo fmt --manifest-path "${frontend_root}/Cargo.toml" --check
cargo check --manifest-path "${frontend_root}/Cargo.toml"
cargo test --manifest-path "${frontend_root}/Cargo.toml"
cargo clippy --manifest-path "${frontend_root}/Cargo.toml" --all-targets -- -D warnings
printf 'Checking two-client code pairing against the live Elixir helper...\n'
"${project_root}/scripts/smoke-pairing-e2e.sh"
