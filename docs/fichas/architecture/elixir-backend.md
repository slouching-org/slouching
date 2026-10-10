# Elixir backend boundary

**Status:** Elixir backend and Rust client direction accepted. Local storage
and optional helper deployment follow [ADR 0006](adr-0006-local-storage-optional-helper.md).
Working code includes a challenge-authenticated development gateway, experimental
SPAKE2 rendezvous, and an optional ciphertext mailbox API.

## Responsibilities and authority

Each device owns its private keys, MLS state, encrypted local history,
inbox, and outbox. Rust client components handle local cryptography,
SQLite storage, direct peer transport, and media. Elixir/OTP implements
backend service components. A member may optionally host helper roles on
a PC or private VPS; an ordinary user does not need a PostgreSQL instance.

| Domain | Target responsibility | Current implementation |
| --- | --- | --- |
| Gateway | Versioned binary WebSocket contracts for backend interactions | Protobuf handshake with Ed25519 challenge proof and Ping/Pong; experimental authenticated SFU join, SDP, ICE, and leave frames |
| Directory | Optional public-key and KeyPackage availability; no identity substitution authority | SQLite/Ecto device-key schema for local helper development; PostgreSQL remains an optional deployment backend; no enrollment, lookup, or KeyPackages |
| Delivery | Optional delegated ciphertext mailbox with quota, expiry, and honest receipts | HTTP v1 upload/list/ACK, author grant verification, Ed25519 recipient request authentication, replay protection, per-recipient quotas, periodic expiry; Rust Settings opt-in, fallback upload, manual fetch, and persist-before-ACK are implemented, remote runtime validation remains open |
| Group state | Carry proposals, Commits, and checkpoints without cryptographic authority | Not implemented; the designated member device remains the MLS committer |
| Storage | SQLite per device; SQLite may also serve a helper; Postgres optional for larger helper deployments | Client SQLCipher remains separate; optional Elixir helper uses SQLite by default and can select PostgreSQL with `SLOUCHING_DATABASE_URL` |
| Calls | Optional member-operated SFU and relay support | Authenticated WebSocket SFU signaling is wired to the Rust client; helper checks matching device-signed roster but cannot verify MLS membership. Two software clients exchange protected audio through a live local helper; physical devices and cross-network use remain unverified |
| Runtime | Supervision and backend process lifecycle | Mix release with a release migration task; supervised service uses loopback HTTP by default, direct HTTPS with configured PEM files, and rejects non-loopback plaintext binds |

A helper may route ciphertext and media packets but holds no member's
private keys or MLS/SFrame secrets. It cannot decide membership or create
MLS Commits. See [ADR 0002](../groups/adr-0002-designated-committer.md).
The source PDF's centralized directory and authoritative delivery log are
historical proposals, not required product boundaries.

## Deployment and availability

The installed Rust app must start and communicate among reachable LAN peers
without PostgreSQL, a hosted helper, or an internet route. The optional Elixir
helper now has a packaged Mix release and a smoke-tested start/migrate flow;
this does not package the desktop app or satisfy its local-only product gate.

When no authorized holder can reach an offline recipient, delivery waits.
Helper storage confirms a retained copy, not recipient delivery. Direct
connections continue when an optional helper disappears if their route
still works. If that helper was the only usable relay or SFU, the affected
route or call becomes unavailable. Lost copies cannot be recovered merely
because a directory entry exists.

## Current development slice

`GET /api/status` reports the implemented development capabilities. A protobuf handshake at
`/ws` checks version and verifies possession of the device Ed25519 key with a
fresh challenge, then keeps the loopback transport responsive with Ping/Pong.
It does not enroll devices or authorize messaging, groups, or peer routes. The experimental SFU route accepts a client-provided, device-signed roster but cannot verify it against MLS state. Separately, the optional delivery HTTP API
stores signed opaque MLS copies in SQLite or the configured PostgreSQL repo.
The desktop client can opt in to a remote HTTPS helper, upload fallback copies,
and manually fetch, persist, then ACK them. The helper remains optional; the
remote multi-device flow has not yet been runtime-validated. Its [HTTP v1 contract](../delivery/mailbox-http-v1.md) and the
[integration contract](integration.md) describe the current behavior.
