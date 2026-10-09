# Technology stack and maturity

**Status:** Elixir backend and Rust/Iced client direction retained; local
storage and optional deployment reaffirmed by [ADR 0006](adr-0006-local-storage-optional-helper.md).

| Layer | Direction | Current state |
| --- | --- | --- |
| Desktop UI and local client core | Rust/Iced and Tokio | Eleven native screens; direct-LAN text works with manual device-key pinning and local per-peer history |
| Local persistence | Encrypted SQLite using SQLCipher; OS credential store holds the DB key | Frontend persists profile, up to 1,000 direct messages per peer, opaque event journal, OpenMLS signer/private KeyPackage bundle, and local MLS group state; outbound and inbound MLS application events update the ratchet and journal atomically |
| Client cryptography and P2P | Rust; OpenMLS for MLS, iroh and SFrame candidates | Device binding, KeyPackage, group admission, and Welcome processing; authenticated MLS application encryption/decryption, durable deduplication, local chat UI, and direct-session delivery exist |
| Backend service components | Elixir/OTP | Supervised Bandit loopback scaffold |
| Gateway | Versioned binary WebSocket/protobuf | Handshake v1 and Ping/Pong only; no authenticated product traffic |
| Optional helper storage | SQLite supported by the plan; Postgres optional for larger deployments | Elixir helper defaults to a local SQLite Repo; PostgreSQL is selectable by URL; device table has no enrollment or lookup |
| Delivery | Direct peer delivery and optional delegated ciphertext copies | Direct-LAN pairwise ACK and local transcript persistence work; MLS events are sent over a pinned direct session, ACKed after durable receiver persistence, and queued events can be retried; replication, offline delivery, and expiry enforcement remain unimplemented |
| MLS ordering | Designated member device per group; other members validate | Member admission enforces the indexed designated committer and persists Commit bytes atomically; a pending Commit can be sent to one authenticated member over QUIC and applied before ACK, with epoch ordering and deduplication; automatic multi-member fan-out, concurrent proposals, and signed equivocation quarantine remain unimplemented |
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
