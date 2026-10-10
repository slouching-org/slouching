#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
server_root="${project_root}/repositories/backend/server"
frontend_manifest="${project_root}/repositories/frontend/Cargo.toml"
temp_dir="$(mktemp -d)"
server_pid=""

cleanup() {
  if [[ -n "${server_pid}" ]] && kill -0 "${server_pid}" 2>/dev/null; then
    kill "${server_pid}" 2>/dev/null || true
    wait "${server_pid}" 2>/dev/null || true
  fi
  rm -rf -- "${temp_dir}"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

database_path="${temp_dir}/pairing.sqlite3"
port="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')"
database_log="${temp_dir}/database.log"

cd "${server_root}"
if ! env -u SLOUCHING_DATABASE_URL MIX_ENV=dev \
  SLOUCHING_SQLITE_PATH="${database_path}" \
  mix ecto.create >"${database_log}" 2>&1; then
  cat "${database_log}" >&2
  exit 1
fi
if ! env -u SLOUCHING_DATABASE_URL MIX_ENV=dev \
  SLOUCHING_SQLITE_PATH="${database_path}" \
  mix ecto.migrate --pool-size 1 >>"${database_log}" 2>&1; then
  cat "${database_log}" >&2
  exit 1
fi

(exec env -u SLOUCHING_DATABASE_URL MIX_ENV=dev \
  SLOUCHING_SQLITE_PATH="${database_path}" \
  SLOUCHING_PORT="${port}" \
  SLOUCHING_BIND_IP=127.0.0.1 \
  mix run --no-halt) >"${temp_dir}/server.log" 2>&1 &
server_pid=$!

base_url="http://127.0.0.1:${port}"
ready=0
for _attempt in $(seq 1 40); do
  if curl --fail --silent "${base_url}/health" >/dev/null; then
    ready=1
    break
  fi
  if ! kill -0 "${server_pid}" 2>/dev/null; then
    break
  fi
  sleep 0.25
done

if [[ "${ready}" != 1 ]]; then
  cat "${server.log}" >&2
  printf 'Elixir pairing helper did not become healthy on port %s.\n' "${port}" >&2
  exit 1
fi

SLOUCHING_PAIRING_TEST_URL="${base_url}" \
  cargo test --manifest-path "${frontend_manifest}" \
  pairing_client::tests::two_clients_pair_through_the_live_elixir_helper \
  -- --ignored --exact --nocapture
