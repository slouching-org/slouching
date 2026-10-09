# Rust client and Elixir server integration

**Status:** local development status exchange and persistent binary WebSocket
transport after a version 1 handshake, plus a separate direct-LAN one-shot text
exchange in the Rust client. The Rust/Iced frontend and Elixir/OTP backend
communicate across processes. The Elixir diagnostics are not part of peer
traffic.

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

## Direct LAN messaging in the Iced client

The Iced chat screen can send and receive one bounded UTF-8 text frame directly
to a manually pinned device on a reachable LAN. Both endpoints use the durable
Ed25519 device identity as their Iroh EndpointId; QUIC authenticates and
encrypts the connection. Users manually exchange public keys; the sender
supplies the receiver's LAN IP and UDP port. Relay and address lookup are
disabled. See the frontend's
[LAN text transport contract](https://github.com/slouching-org/slouching-frontend/blob/main/docs/fichas/transport/lan-text-v1.md)
for the screen flow and protocol.

This slice has no MLS credential or group, verified contact roster, durable
history, offline delivery, discovery, NAT traversal, or relay fallback. Its
transcript lasts only for the current app session. Automated integration tests
launch two separate client processes, check text and acknowledgement delivery,
and verify rejection of an unpinned identity. A manual test uses two app
instances on a reachable LAN and requires firewall access to the chosen UDP
port. Linux requires an available Secret Service for local device identity.

The Elixir diagnostic transport authenticates no device, carries no encrypted
event, and has no application command or subscription channel. [ADR 0005](adr-0005-elixir-server-core.md)
defines the language division: Rust client plus Elixir backend.
[ADR 0006](adr-0006-local-storage-optional-helper.md) retains local SQLite
and optional helpers. The loopback Elixir diagnostics do not implement the
LAN path or make PostgreSQL a startup dependency. Product messaging still
needs MLS groups, durable history, authorization policy, offline delivery, and
retries.

## Local checkout and validation

Keep the frontend, backend, and project repositories side by side under one
directory. Run `scripts/check-integration.sh` from this repository to test
the Elixir server, smoke-test its optional SQLite Repo without PostgreSQL,
and compile/test the Rust frontend, including the separate-process direct-LAN
peer integration tests. The backend test suite exercises the status route and
protobuf handshake contracts.
The old Rust `peer/` crate is preserved in the backend repository as a
historical scaffold and must not be started on the same port.

Before release, test the product MLS protocol end to end and document which
service features remain available without a reachable self-hosted server.
Neither status checks nor the direct-LAN experiment prove product MLS
messaging, media, or offline delivery.
