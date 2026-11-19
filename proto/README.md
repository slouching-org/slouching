# Shared protocol source

`slouching/v1/handshake.proto` defines the first binary client/server
handshake. This repository keeps the canonical source; byte-identical copies
live in the frontend and backend repositories so each can build on its own.
`scripts/check-integration.sh` checks that all three copies match.
`scripts/check-proto-sync.sh` makes the same comparison against the pinned
submodule commits without initializing them; CI runs it.

The first WebSocket binary frame is `ClientFrame` with `hello` and
`protocol_version = 2` and a 32-byte device public key. The server replies with a binary `ServerFrame`:

- `hello` reports version 2, a fresh authentication nonce, `server_role = "elixir"`, and capability flags
  reflecting implemented service features; or
- `version_error` reports the supported version and ends the exchange.

After `hello`, the client signs the version-bound device-key challenge and sends
`auth_proof`; the server verifies it and returns `authenticated`. The WebSocket then remains open for
standard WebSocket Ping/Pong control frames. No new protobuf payload is added
for heartbeats. The client checks liveness and reconnects after a lost
connection; the server closes an idle connection. Authenticated SFU signaling
frames are implemented; direct peer messaging uses a separate protocol.

This handshake proves possession of the device key; the heartbeat checks
transport liveness. Neither establishes human trust or MLS membership. SFU
admission separately checks device-signed roster consistency. The gateway does
not carry direct MLS messages or create a secure conversation by itself.
