# Shared protocol source

`slouching/v1/handshake.proto` defines the first binary client/server
handshake. This repository keeps the canonical source; byte-identical copies
live in the frontend and backend repositories so each can build on its own.
`scripts/check-integration.sh` checks that all three copies match.

The first WebSocket binary frame is `ClientFrame` with `hello` and
`protocol_version = 1`. The server replies with a binary `ServerFrame`:

- `hello` reports version 1, `server_role = "elixir"`, and capability flags
  reflecting implemented service features; or
- `version_error` reports the supported version and ends the exchange.

After a successful `hello`, the local development WebSocket remains open for
standard WebSocket Ping/Pong control frames. No new protobuf payload is added
for heartbeats. The client checks liveness and reconnects after a lost
connection; the server closes an idle connection. Application events remain
undefined.

This handshake and heartbeat establish only wire compatibility and local
transport liveness. They do not authenticate a device, authorize an action, carry
an MLS event, or create a secure conversation. Product traffic requires
separate reviewed schemas and security contracts.
