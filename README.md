<p align="center">
  <img src="docs/design/references/05-two-wizards-primary-logo.png" width="156" alt="Two wizards walking side by side, the Slouching pictorial logo" />
</p>

<h1 align="center">slouching</h1>

<p align="center"><em>Pull up a chair. The internet can wait outside.</em></p>

<p align="center">
  <img src="docs/design/readme/badges/peer-first.svg" alt="Peer first" />
  <img src="docs/design/readme/badges/crew-owned.svg" alt="Crew owned" />
  <img src="docs/design/readme/badges/vhs-fantasy.svg" alt="VHS fantasy" />
  <img src="docs/design/readme/badges/early-build.svg" alt="Early build" />
</p>

**Conceived by Rodrigo and Vitchola**, Slouching is a planned private place for a small crew to chat, call, and share a screen. The Rust/Iced client owns local keys, cryptography, history, and direct peer paths. Each device is planned to retain its own encrypted SQLite history, inbox, outbox, and MLS state. Elixir remains the backend language. A member may optionally host a helper on a PC or VPS for ciphertext delivery, discovery, relay, or group media. Reachable LAN peers must work without a hosted helper or PostgreSQL; that mode is not implemented yet.

> [!IMPORTANT]
> This is an early build, **not a secure messenger**. The Rust/Iced frontend has eleven navigable preview views. The Elixir backend has local status and a persistent development WebSocket transport with a binary protobuf handshake and Ping/Pong heartbeat. There is no working cryptographic identity, MLS, peer transport, encrypted chat, media call, or screen sharing. The older Rust `slouching-peer` crate is preserved as an experiment, not the service backend.

![Native Rust/Iced home using the supplied scenery, characters, fonts, and icons; first visual pass](docs/design/readme/native-vhs-home.png)

![Native Rust/Iced group-call preview with illustrative characters and chat; no media is connected](docs/design/readme/native-vhs-call.png)

The earlier local web preview remains available for design comparison. These are captures of that preview, with illustrative people and video tiles; they show no live peers or media.

| Web home preview | Web call layout preview |
| --- | --- |
| ![Old web home preview](docs/design/readme/home-preview.png) | ![Old web call preview](docs/design/readme/call-preview.png) |

## Repositories and documentation

This repository holds the project overview, design sources, and a reconciled documentation set. Product code lives in separate repositories, also listed as Git submodules here:

| Repository | Owns | Current state |
| --- | --- | --- |
| [slouching-frontend](https://github.com/slouching-org/slouching-frontend) | Native Rust/Iced desktop UI and web visual prototype | Eleven native design previews with supplied art and icons; local diagnostic transport |
| [slouching-backend](https://github.com/slouching-org/slouching-backend) | Elixir service backend | Local transport plus optional PostgreSQL device-key schema; no enrollment or product traffic |

Start with the [fichas index](docs/fichas/README.md). The [product specification](docs/fichas/architecture/backend.md), [Elixir backend boundary](docs/fichas/architecture/elixir-backend.md), [frontend screen specification](docs/fichas/frontend/screens.md), [technology plan](docs/fichas/architecture/tech-stack.md), and [ADRs](docs/fichas/README.md#accepted-decisions) describe the target and distinguish it from working code. The [owner's 11-page architecture PDF](docs/fichas/architecture/sources/architecture-p2p-v0.1.pdf) and [page-by-page transcript](docs/fichas/architecture/sources/README.md) are preserved. [ADR 0005](docs/fichas/architecture/adr-0005-elixir-server-core.md) defines the Rust-client/Elixir-backend division. [ADR 0006](docs/fichas/architecture/adr-0006-local-storage-optional-helper.md) reaffirms the backup specification: local SQLite, optional helpers, and PostgreSQL only as a deployment option.

The [client/server integration contract](docs/fichas/architecture/integration.md) describes the local status exchange and persistent binary WebSocket transport after a protobuf v1 handshake. They establish reachability and wire compatibility only; there is no authenticated messaging or call API.

The backend contains an experimental optional PostgreSQL device-key schema. It has no enrollment or lookup route and does not establish a required directory service. The product storage plan is encrypted SQLite on each device; a helper may also use SQLite or choose PostgreSQL for a larger deployment.

ADR 0004 changed the original single-workspace plan to [separate repositories](docs/fichas/architecture/adr-0004-separate-repositories.md). Its old Rust-backend wording is corrected by ADR 0005. The [old workspace ADR](docs/fichas/architecture/archive/adr-0004-workspace-superseded.md) is retained only as history.

## Design sources

The [source bank](docs/fichas/brand/source-bank.md) includes the original HTML board, all eleven exported screens, original scene and avatar JPEGs, and five earlier visual references. The [visual style](docs/fichas/brand/visual-style.md) documents the palette and treatment. The two walking wizards are the primary pictorial logo; the hat is a provisional small icon. Screen exports are design targets, not working app states.

| Home reference | Group call reference |
| --- | --- |
| ![Static home design](docs/design/screens/09-home.png) | ![Static group call design](docs/design/screens/10-group-call.png) |

## Run the current scaffolds

Clone each code repository at its latest revision, then follow its README. With
the three repositories side by side, run the service in one terminal:

```sh
cd ../slouching-backend/server
mix deps.get
mix test
mix run --no-halt
```

From the project directory, run the client in another terminal. Its Rust build
requires `protoc` for protobuf code generation:

```sh
cd ../slouching-frontend
cargo check
cargo run
```

The development status uses `127.0.0.1:3707/api/status`; the binary handshake
uses `ws://127.0.0.1:3707/ws`. Neither is authenticated product traffic. Run
`scripts/check-integration.sh` for the local
cross-repository checks. The submodules pin the published backend and
frontend commits; the frontend snapshot includes all eleven native visual
previews and their runtime screenshots.
