# Technology stack and maturity

**Status:** Elixir backend and Rust/Iced client direction retained; local
storage and optional deployment reaffirmed by [ADR 0006](adr-0006-local-storage-optional-helper.md).

| Layer | Direction | Current state |
| --- | --- | --- |
| Desktop UI and local client core | Rust/Iced and Tokio | Twelve native design-board screens plus MLS group flows; direct pinned-device chat, settings, and experimental calls are available |
| Local persistence | Encrypted SQLite using SQLCipher; OS credential store holds the DB key | Frontend persists profile, up to 1,000 direct messages per peer, opaque event journal, OpenMLS signer/private KeyPackage bundle, local MLS group state, and outbound pinned peer socket routes; outbound and inbound MLS application events update the ratchet and journal atomically |
| Client cryptography and P2P | Rust; OpenMLS, Iroh/QUIC, WebRTC, and SFrame | Device-bound MLS credentials, pinned-session group admission and Welcome retries, authenticated MLS events, per-device ACKs, ordered Commit delivery, saved-route fan-out, signed QR invitations, LAN mDNS hints, and opt-in Iroh relay routes are implemented; remote discovery and cross-network routes remain unverified |
| Backend service components | Elixir/OTP | Supervised Bandit diagnostics, experimental SPAKE2 rendezvous, optional signed-ciphertext mailbox, and experimental SFU call coordinator |
| Gateway | Versioned binary WebSocket/protobuf | Protocol v2 Ed25519 device challenge, Ping/Pong, and authenticated SFU signaling; proof establishes device-key possession but does not grant MLS membership |
| Optional helper storage | SQLite supported by the plan; Postgres optional for larger deployments | Elixir helper defaults to local SQLite Repo; PostgreSQL is selectable by URL; mailbox quota, expiry, recipient authentication, and deduplication are implemented without device enrollment |
| Delivery | Direct peer delivery and optional delegated ciphertext copies | Manually addressed direct UDP pairwise ACK and local per-peer transcript work; MLS events snapshot epoch members and support per-device ACKs, sequential saved-route fan-out, and enforced 30-day expiry; ordered Commits support per-device ACK and authenticated predecessor recovery; peer-operated helper copies work over a reachable route; optional Elixir HTTP mailbox now has a Rust opt-in, fallback upload, and manual fetch, with remote cross-device validation still open |
| MLS ordering | Designated member device per group; other members validate | Member admission enforces the indexed designated committer and atomically snapshots predecessor members with Commit bytes; delivery ACKs persist per recipient, missing epochs can be requested over the pinned session, and replay requires a matching snapshot; authenticated signed equivocation is checked against historical OpenMLS state and quarantined locally; sequential multi-member fan-out uses saved pinned routes; concurrent proposal processing remains unimplemented |
| Group media | Direct WebRTC and optional Elixir `ex_webrtc` SFU | CPAL Opus/SFrame audio and H.264/SFrame camera, screen, and window sharing are wired to bounded RTP/DataChannels; direct signaling uses pinned QUIC, while the experimental SFU supports two-device calls and passes a live local audio-forwarding test; physical-device and cross-network calls remain unverified |
| Relay | Optional member-operated Iroh relay; SFU for calls | Iroh relay URL/token settings and local message/ACK coverage exist; the SFU has saved WSS settings and an authenticated connectivity check, while remote deployment and cross-network behavior remain unverified |

The PDF preserves the original language and feature proposals. The backup
specification and accepted ADRs determine local storage, optional helpers,
and availability: no PostgreSQL service is a normal app startup dependency.
Choosing Elixir does not select a central deployment or a required directory.

See the [product specification](backend.md), [backend boundary](elixir-backend.md),
and [current transport contract](local-status-api.md). A successful loopback
handshake proves only device-key possession and transport liveness; product
flows rely on their separate protocol and integration tests. Remote deployment,
physical-device media, release packaging, and cross-network validation remain
open.
