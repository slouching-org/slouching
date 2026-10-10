#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
backend_root="${project_root}/repositories/backend/server"
frontend_root="${project_root}/repositories/frontend"
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

database_path="${temp_dir}/mailbox.sqlite3"
port="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')"
database_log="${temp_dir}/database.log"

cd "${backend_root}"
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
  mix run --no-halt) >"${temp_dir}/server.log" 2>&1 &
server_pid=$!

base_url="http://127.0.0.1:${port}"
ready=0
for _attempt in $(seq 1 40); do
  if curl --fail --silent "${base_url}/health" >"${temp_dir}/health.txt"; then
    ready=1
    break
  fi
  if ! kill -0 "${server_pid}" 2>/dev/null; then
    break
  fi
  sleep 0.25
done

if [[ "${ready}" != 1 ]] || [[ "$(cat "${temp_dir}/health.txt")" != "ok" ]]; then
  cat "${temp_dir}/server.log" >&2
  echo "Elixir mailbox helper did not become healthy on port ${port}." >&2
  exit 1
fi

SLOUCHING_DELIVERY_MAILBOX_URL="${base_url}" \
  cargo test --manifest-path "${frontend_root}/Cargo.toml" \
    --bin slouching-frontend signed_mailbox_client_round_trips_against_live_helper \
    -- --ignored --nocapture

echo "Rust client uploaded, listed, decoded, and ACKed an MLS copy through the live Elixir helper."
