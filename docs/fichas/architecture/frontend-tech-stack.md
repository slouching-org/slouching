# Frontend technology plan

**Accepted client direction:** native Rust/Iced. This comes from the
[owner's complete source PDF](sources/architecture-p2p-v0.1.pdf).
Its Elixir server/backend core and Rust/Iced client direction are retained.

| Layer | Choice | Current state |
| --- | --- | --- |
| Desktop UI | Rust 2024 + pinned Iced 0.14.0 | Native state in `src/main.rs`; eleven design-board views plus an MLS group setup screen |
| Rendering | Iced/wgpu | Native views with images, SVG icons, and canvas texture; live video unbuilt |
| Local client core | Rust identity, cryptography, encrypted SQLite storage, transport, media | Device-bound OpenMLS credentials and group admission; application events are encrypted/decrypted with authenticated envelope metadata and ratchet changes committed with journal writes |
| Local persistence | SQLCipher encrypted SQLite plus OS credential store for keys | Persists profile, direct chat history, MLS state, and opaque application ciphertext atomically with OpenMLS ratchet updates; MLS application messages use the active pinned Iroh/QUIC session; inbound ciphertext, ratchet update, and local transcript persist before ACK, and queued outbound events can be retried |
| Server/backend | Elixir, separately versioned backend repo | Development status and protobuf handshake implemented |
| State boundary | Versioned protocol | Asynchronous loopback HTTP status and binary protobuf WebSocket handshake v1 integrated; production boundary pending |
| Browser UI | HTML/CSS/JavaScript | Historical visual prototype in `prototypes/web/`; not product runtime |
| Identity, MLS, storage, transport, calls | Client and server responsibilities per source PDF | Device binding, KeyPackages, local groups, designated-committer admission, Welcome processing, authenticated application-message core, and group setup UI exist; fingerprint comparison, contact pairing, group discovery, relay, offline delivery, and calls remain unimplemented |

Under [ADR 0006](adr-0006-local-storage-optional-helper.md), the installed
client has no PostgreSQL startup requirement. An optional helper may use
SQLite or choose Postgres for a larger deployment. Direct LAN operation is implemented in the Iced client; release packaging remains to be implemented.

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
