# Technology stack and maturity

**Status:** Elixir backend and Rust/Iced client direction retained; local
storage and optional deployment reaffirmed by [ADR 0006](adr-0006-local-storage-optional-helper.md).

| Layer | Direction | Current state |
| --- | --- | --- |
| Desktop UI and local client core | Rust/Iced and Tokio | Eleven native screens; manually addressed direct UDP text works with device-key pinning and local per-peer history |
| Local persistence | Encrypted SQLite using SQLCipher; OS credential store holds the DB key | Frontend persists profile, up to 1,000 direct messages per peer, opaque event journal, OpenMLS signer/private KeyPackage bundle, local MLS group state, and outbound pinned peer socket routes; outbound and inbound MLS application events update the ratchet and journal atomically |
| Client cryptography and P2P | Rust; OpenMLS for MLS, iroh and SFrame candidates | Device binding, pinned-session KeyPackage delivery with committer review, group admission, durable pinned-session Welcome retry with duplicate receipt handling; authenticated MLS application encryption/decryption, durable deduplication, local chat UI, direct Commit delivery and saved-route multi-member Commit fan-out exist |
| Backend service components | Elixir/OTP | Supervised Bandit loopback scaffold |
| Gateway | Versioned binary WebSocket/protobuf | Handshake v1 and Ping/Pong only; no authenticated product traffic |
| Optional helper storage | SQLite supported by the plan; Postgres optional for larger deployments | Elixir helper defaults to a local SQLite Repo; PostgreSQL is selectable by URL; device table has no enrollment or lookup |
| Delivery | Direct peer delivery and optional delegated ciphertext copies | Manually addressed direct UDP pairwise ACK and local per-peer transcript work; MLS events snapshot epoch members and support per-device ACKs, sequential saved-route fan-out, and enforced 30-day expiry; ordered Commits support per-device ACK and authenticated predecessor recovery; saved routes may use the explicitly configured participant relay, but MLS relay fan-out lacks an end-to-end test; delegated replication and offline delivery remain unimplemented |
| MLS ordering | Designated member device per group; other members validate | Member admission enforces the indexed designated committer and atomically snapshots predecessor members with Commit bytes; delivery ACKs persist per recipient, missing epochs can be requested over the pinned session, and replay requires a matching snapshot; authenticated signed equivocation is checked against historical OpenMLS state and quarantined locally; sequential multi-member fan-out uses saved pinned routes; concurrent proposal processing remains unimplemented |
| Group media | Direct WebRTC/mesh and optional Elixir `ex_webrtc` SFU | Not implemented |
| Relay | Optional member-operated TURN/iroh relay | Explicit HTTPS URL/token settings and local Iroh Relay 1.3 message/ACK test; remote deployment and cross-network behavior unverified |

The PDF preserves the original language and feature proposals. The backup
specification and accepted ADRs determine local storage, optional helpers,
and availability: no PostgreSQL service is a normal app startup dependency.
Choosing Elixir does not select a central deployment or a required directory.

See the [product specification](backend.md), [backend boundary](elixir-backend.md),
and [current transport contract](local-status-api.md). None of the planned
local SQLite, MLS, P2P, delivery, or media behavior is proved by a successful
loopback handshake.
