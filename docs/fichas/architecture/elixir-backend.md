# Elixir backend boundary

**Status:** Elixir backend and Rust client direction accepted. Local storage
and optional helper deployment follow [ADR 0006](adr-0006-local-storage-optional-helper.md).
Working code includes a development transport scaffold, experimental SPAKE2
rendezvous, and a backend-only optional ciphertext mailbox API.

## Responsibilities and authority

Each device owns its private keys, MLS state, encrypted local history,
inbox, and outbox. Rust client components handle local cryptography,
SQLite storage, direct peer transport, and media. Elixir/OTP implements
backend service components. A member may optionally host helper roles on
a PC or private VPS; an ordinary user does not need a PostgreSQL instance.

| Domain | Target responsibility | Current implementation |
| --- | --- | --- |
| Gateway | Versioned binary WebSocket contracts for backend interactions | Loopback protobuf handshake and Ping/Pong only |
| Directory | Optional public-key and KeyPackage availability; no identity substitution authority | SQLite/Ecto device-key schema for local helper development; PostgreSQL remains an optional deployment backend; no enrollment, lookup, or KeyPackages |
| Delivery | Optional delegated ciphertext mailbox with quota, expiry, and honest receipts | HTTP v1 upload/list/ACK, author grant verification, Ed25519 recipient request authentication, replay protection, per-recipient quotas, and finite expiry; Rust client integration and user settings remain open |
| Group state | Carry proposals, Commits, and checkpoints without cryptographic authority | Not implemented; the designated member device remains the MLS committer |
| Storage | SQLite per device; SQLite may also serve a helper; Postgres optional for larger helper deployments | Client SQLCipher remains separate; optional Elixir helper uses SQLite by default and can select PostgreSQL with `SLOUCHING_DATABASE_URL` |
| Calls | Optional member-operated SFU and relay support | Not implemented |
| Runtime | Supervision and backend process lifecycle | Supervised local Elixir application only |

A helper may route ciphertext and media packets but holds no member's
private keys or MLS/SFrame secrets. It cannot decide membership or create
MLS Commits. See [ADR 0002](../groups/adr-0002-designated-committer.md).
The source PDF's centralized directory and authoritative delivery log are
historical proposals, not required product boundaries.

## Deployment and availability

The installed app must start and communicate among reachable LAN peers
without PostgreSQL, a hosted helper, or an internet route. Local process
packaging and lifecycle are still to be implemented; the current two-process
loopback demo does not satisfy that product gate.

When no authorized holder can reach an offline recipient, delivery waits.
Helper storage confirms a retained copy, not recipient delivery. Direct
connections continue when an optional helper disappears if their route
still works. If that helper was the only usable relay or SFU, the affected
route or call becomes unavailable. Lost copies cannot be recovered merely
because a directory entry exists.

## Current development slice

`GET /api/status` reports unavailable capabilities. A protobuf handshake at
`/ws` checks version and role, then keeps a loopback transport responsive
with Ping/Pong. These checks provide no identity authentication, messaging,
peer route, or media capability. Separately, the optional delivery HTTP API
stores signed opaque MLS copies in SQLite or the configured PostgreSQL repo;
it is not wired into the desktop client and does not establish a required
service. Its [HTTP v1 contract](../delivery/mailbox-http-v1.md) and the
[integration contract](integration.md) describe the current behavior.
