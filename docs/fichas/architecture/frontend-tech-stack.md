# Frontend technology plan

**Accepted client direction:** native Rust/Iced. This comes from the
[owner's complete source PDF](sources/architecture-p2p-v0.1.pdf).
Its Elixir server/backend core and Rust/Iced client direction are retained.

| Layer | Choice | Current state |
| --- | --- | --- |
| Desktop UI | Rust 2024 + pinned Iced 0.14.0 | Twelve native design-board views, MLS group flows, and settings for optional helpers |
| Rendering | Iced/wgpu | Native views with images, SVG icons, canvas textures, decoded remote video frames, and explicit capture previews |
| Local audio devices | CPAL 0.18.2 | Real device enumeration and selection; Opus/SFrame audio is connected to local capture and playback for direct and experimental SFU calls |
| Local client core | Rust identity, cryptography, encrypted SQLite storage, transport, media | Device-bound OpenMLS credentials and group admission; application events are encrypted/decrypted with authenticated envelope metadata and ratchet changes committed with journal writes |
| Local persistence | SQLCipher encrypted SQLite plus OS credential store for keys | Persists profile, direct chat history, MLS state, and opaque application ciphertext atomically with OpenMLS ratchet updates; membership Commits are stored with group epochs and inbound Commits apply atomically with deduplication |
| Server/backend | Elixir, separately versioned backend repo | Optional pairing, signed ciphertext mailbox, and experimental SFU services; remote deployment remains unverified |
| State boundary | Versioned protocol | Binary protobuf WebSocket v2 proves Ed25519 device-key possession; product endpoints separately enforce their request or call-roster proofs, while MLS membership is derived and checked by clients |
| Browser UI | HTML/CSS/JavaScript | Historical visual prototype in `prototypes/web/`; not product runtime |
| Identity, MLS, storage, transport, calls | Client and server responsibilities per source PDF | Device-bound MLS credentials, pinned-session admission and durable Welcome/Commit delivery, authenticated MLS events with per-device ACKs, QR invitations, LAN mDNS hints, experimental SPAKE2 pairing, best-effort peer/mailbox copies, and direct WebRTC media are implemented; SFU signaling accepts call groups of 2–16 devices and protected audio passes a local three-client live-helper test. Multiparty chat/video integration and authenticated remote contact discovery remain unverified; remote helper deployment, physical media, and cross-network calls remain unverified |

Under [ADR 0006](adr-0006-local-storage-optional-helper.md), the installed
client has no PostgreSQL startup requirement. An optional helper may use
SQLite or choose Postgres for a larger deployment. Direct LAN operation and
explicit participant-relay settings are implemented in the Iced client. Remote
cross-network behavior, physical-device media, and release packaging remain to
be verified.

The frontend must render authoritative implemented state. It must not generate
security claims, route badges, presence, or capture status independently.

The frontend requests `GET http://127.0.0.1:3707/api/status` as a local
development diagnostic. It checks status contract v1 and the Elixir backend
marker. The separate binary protobuf WebSocket uses protocol v2, proves
possession of the device Ed25519 key, and stays open with Ping/Pong heartbeats.
The authenticated socket can carry signed SFU call signaling; that proof does
not itself authorize MLS membership. The client derives call rosters from its
local MLS state, and the helper validates each member's roster signature.

See [ADR 0003](adr-0003-rust-iced-client.md) and the
[backend stack ficha](tech-stack.md).
