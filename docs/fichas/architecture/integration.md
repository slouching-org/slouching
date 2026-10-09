# Rust client and Elixir server integration

**Status:** local development status exchange and persistent binary WebSocket
transport after a version 1 handshake. The Rust/Iced frontend and Elixir/OTP
backend communicate across processes.
This does not implement identity, messages, calls, or peer networking.

## Boundary

- `slouching-backend/server` owns the Elixir service and
  `GET http://127.0.0.1:3707/api/status`, plus binary WebSocket `/ws`. It also
  exposes `/health` for process availability. Bandit listens on loopback only.
- `slouching-frontend` requests status and performs the WebSocket handshake
  asynchronously so the UI remains responsive. It must distinguish backend
  unavailable, unsupported contract, and the reported scaffold capabilities.
- The response reports `contract_version: 1`, `backend: "elixir_scaffold"`,
  `not_implemented` for identity, messaging, and calls, and zero peer
  connections. Controls for unavailable capabilities stay disabled.

The shared [protobuf schema](../../../proto/slouching/v1/handshake.proto)
defines the first binary frame as `ClientFrame.hello(protocol_version = 1)`.
The server replies with `ServerFrame.hello` (`server_role = "elixir"`, all
capabilities unavailable) or `ServerFrame.version_error` with its supported
version. A compatible socket stays open for WebSocket control Ping/Pong only;
a version error closes the socket. The client sends Ping every 5 seconds and
requires a matching Pong within 10 seconds. The server closes after 15
seconds without Ping; a missing hello closes after 5 seconds. The client
retries unavailable transport with bounded 1/2/4/8-second backoff.

These checks prove local transport liveness and wire compatibility only. The
HTTP status route is a separate diagnostic.

The transport authenticates no device, carries no encrypted event, and has no
application command or subscription channel. [ADR 0005](adr-0005-elixir-server-core.md)
defines the language division: Rust client plus Elixir backend.
[ADR 0006](adr-0006-local-storage-optional-helper.md) retains local SQLite
and optional helpers. This loopback development slice does not implement
the required LAN peer mode or make PostgreSQL a startup dependency. Product traffic
still needs identity, authorization, ordering, retry, and error contracts.

## Local checkout and validation

Keep the frontend, backend, and project repositories side by side under one
directory. Run `scripts/check-integration.sh` from this repository to test
the Elixir server, smoke-test its optional SQLite Repo without PostgreSQL,
and compile/test the Rust frontend. The backend test suite exercises the
status route and protobuf handshake contracts.
The old Rust `peer/` crate is preserved in the backend repository as a
historical scaffold and must not be started on the same port.

Before release, pin compatible frontend/backend commits, test the product
protocol end to end, and document which service features remain available
without a reachable self-hosted server. Current status checks do not prove
MLS, P2P, media, or offline delivery.
