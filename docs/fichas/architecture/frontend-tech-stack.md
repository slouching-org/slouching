# Frontend technology plan

**Accepted client direction:** native Rust/Iced. This comes from the
[owner's complete source PDF](sources/architecture-p2p-v0.1.pdf).
Its Elixir server/backend core and Rust/Iced client direction are retained.

| Layer | Choice | Current state |
| --- | --- | --- |
| Desktop UI | Rust 2024 + pinned Iced 0.14.0 | Native state in `src/main.rs`; eleven design-board views plus an MLS group setup screen |
| Rendering | Iced/wgpu | Native views with images, SVG icons, and canvas texture; live video unbuilt |
| Local audio devices | CPAL 0.18.2 | Real device enumeration and in-memory selection; an explicit microphone test reports RMS locally, with no saved samples, playback, persistent selection, or call transport yet |
| Local client core | Rust identity, cryptography, encrypted SQLite storage, transport, media | Device-bound OpenMLS credentials and group admission; application events are encrypted/decrypted with authenticated envelope metadata and ratchet changes committed with journal writes |
| Local persistence | SQLCipher encrypted SQLite plus OS credential store for keys | Persists profile, direct chat history, MLS state, and opaque application ciphertext atomically with OpenMLS ratchet updates; membership Commits are stored with group epochs and inbound Commits apply atomically with deduplication |
| Server/backend | Elixir, separately versioned backend repo | Development status and protobuf handshake implemented |
| State boundary | Versioned protocol | Asynchronous loopback HTTP status and binary protobuf WebSocket handshake v1 integrated; production boundary pending |
| Browser UI | HTML/CSS/JavaScript | Historical visual prototype in `prototypes/web/`; not product runtime |
| Identity, MLS, storage, transport, calls | Client and server responsibilities per source PDF | Device binding, KeyPackages, local groups, designated-committer admission, durable Welcome retry with duplicate receipts, authenticated application messages with epoch member snapshots and per-device ACKs, and Commit delivery with predecessor snapshots, missing-epoch recovery, and saved-route multi-member fan-out exist; direct text accepts an explicitly configured participant Iroh relay and has a local end-to-end test; signed 10-minute QR invitations bind a device key to up to eight address choices and can be imported from PNG, but do not automatically establish human trust; remote relay deployment and MLS relay fan-out remain unverified; camera scanning, group discovery, offline delivery, and calls remain unimplemented |

Under [ADR 0006](adr-0006-local-storage-optional-helper.md), the installed
client has no PostgreSQL startup requirement. An optional helper may use
SQLite or choose Postgres for a larger deployment. Direct LAN operation and
explicit participant-relay settings are implemented in the Iced client;
remote cross-network behavior and release packaging remain to be verified.

The frontend must render authoritative implemented state. It must not generate
security claims, route badges, presence, or capture status independently.

The frontend currently requests `GET http://127.0.0.1:3707/api/status`
as a development diagnostic. It checks status contract v1 and the Elixir
backend marker, then renders the reported capabilities. It also sends a
single binary protobuf ClientHello v1 to `/ws` and validates the response;
the development transport stays open with Ping/Pong heartbeats. Before a release, define an
authenticated production boundary and integration tests for identity,
routing, MLS transitions, and capture state.

See [ADR 0003](adr-0003-rust-iced-client.md) and the
[backend stack ficha](tech-stack.md).
