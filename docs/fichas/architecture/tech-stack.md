# Technology stack and maturity

**Status:** Elixir backend and Rust/Iced client direction retained; local
storage and optional deployment reaffirmed by [ADR 0006](adr-0006-local-storage-optional-helper.md).

| Layer | Direction | Current state |
| --- | --- | --- |
| Desktop UI and local client core | Rust/Iced and Tokio | Eleven native preview views; local backend diagnostics only |
| Local persistence | Encrypted SQLite using SQLCipher; OS credential store holds the DB key | Frontend persists profile and opaque event journal, initializes OpenMLS provider schema, and tests MLS signing-key persistence; product history, inbox, outbox, and group state remain unimplemented |
| Client cryptography and P2P | Rust; OpenMLS for MLS, iroh and SFrame candidates | Device identity can sign a binding to a separate MLS signing key; no product credentials, groups, peer auth, or transport |
| Backend service components | Elixir/OTP | Supervised Bandit loopback scaffold |
| Gateway | Versioned binary WebSocket/protobuf | Handshake v1 and Ping/Pong only; no authenticated product traffic |
| Optional helper storage | SQLite supported by the plan; Postgres optional for larger deployments | Elixir helper defaults to a local SQLite Repo; PostgreSQL is selectable by URL; device table has no enrollment or lookup |
| Delivery | Direct peer delivery and optional delegated ciphertext copies | No inbox, outbox, ACK, replication, or expiry implementation |
| MLS ordering | Designated member device per group; other members validate | OpenMLS storage and signer persistence are integrated, but product credentials, groups, Commits, and protected messages remain unimplemented |
| Group media | Direct WebRTC/mesh and optional Elixir `ex_webrtc` SFU | Not implemented |
| Relay | Optional member-operated TURN/iroh relay | Not implemented |

The PDF preserves the original language and feature proposals. The backup
specification and accepted ADRs determine local storage, optional helpers,
and availability: no PostgreSQL service is a normal app startup dependency.
Choosing Elixir does not select a central deployment or a required directory.

See the [product specification](backend.md), [backend boundary](elixir-backend.md),
and [current transport contract](local-status-api.md). None of the planned
local SQLite, MLS, P2P, delivery, or media behavior is proved by a successful
loopback handshake.
