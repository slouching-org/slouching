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

**Conceived by Rodrigo and Vitchola**, Slouching is a planned private place for a small crew to chat, call, and share a screen. The Rust/Iced client owns local keys, cryptography, history, and direct peer paths. Each device is planned to retain its own encrypted SQLite history, inbox, outbox, and MLS state. Elixir remains the backend language. A member may optionally host a helper on a PC or VPS for ciphertext delivery, discovery, relay, or group media. A one-shot pinned-device text transport now works directly between reachable LAN peers without a hosted helper or PostgreSQL.

> [!IMPORTANT]
> This is an early build, **not a secure messenger**. The Rust/Iced frontend has eleven navigable preview views, local encrypted profile/event storage, OpenMLS provider tables inside SQLCipher, explicit Ed25519 device-key creation, and a core API that creates/loads a distinct MLS signing key and signs its binding to the device key. A separate CLI experiment can exchange one text frame with a manually pinned device over direct LAN Iroh/QUIC. No MLS credential, KeyPackage, contact roster, MLS group, chat UI delivery, media calls, or screen sharing is implemented. The Elixir backend has local SQLite development storage plus status and a development WebSocket handshake with Ping/Pong; PostgreSQL is optional for deployment. The older Rust `slouching-peer` crate is preserved as an experiment, not the service backend.

![Native Rust/Iced home with the supplied night scenery and icon-based feature strip, without the frog mage or gnome cutouts](docs/design/readme/native-vhs-home.png)

![Actual Native Rust/Iced familiar screen showing local profile and keyring status after adding the device-to-MLS binding core](docs/design/readme/native-vhs-profile.png)

![Native Rust/Iced group-call preview with illustrative characters and chat; no media is connected](docs/design/readme/native-vhs-call.png)

The earlier local web preview remains available for design comparison. These are captures of that preview, with illustrative people and video tiles; they show no live peers or media.

| Web home preview | Web call layout preview |
| --- | --- |
| ![Old web home preview](docs/design/readme/home-preview.png) | ![Old web call preview](docs/design/readme/call-preview.png) |

## Repositories and documentation

This repository holds the project overview, design sources, and a reconciled documentation set. Product code lives in separate repositories, also listed as Git submodules here:

| Repository | Owns | Current state |
| --- | --- | --- |
| [slouching-frontend](https://github.com/slouching-org/slouching-frontend) | Native Rust/Iced desktop UI and web visual prototype | Eleven native previews; encrypted local profile/event journal and OpenMLS storage; Ed25519 identity plus persisted device-bound MLS signer; local diagnostic transport |
| [slouching-backend](https://github.com/slouching-org/slouching-backend) | Elixir service backend | Local SQLite Repo, no-PostgreSQL smoke check, and transport diagnostics; PostgreSQL deployment option; no enrollment or product traffic |

Start with the [fichas index](docs/fichas/README.md). The [product specification](docs/fichas/architecture/backend.md), [Elixir backend boundary](docs/fichas/architecture/elixir-backend.md), [frontend screen specification](docs/fichas/frontend/screens.md), [technology plan](docs/fichas/architecture/tech-stack.md), and [ADRs](docs/fichas/README.md#accepted-decisions) describe the target and distinguish it from working code. The [owner's 11-page architecture PDF](docs/fichas/architecture/sources/architecture-p2p-v0.1.pdf) and [page-by-page transcript](docs/fichas/architecture/sources/README.md) are preserved. [ADR 0005](docs/fichas/architecture/adr-0005-elixir-server-core.md) defines the Rust-client/Elixir-backend division. [ADR 0006](docs/fichas/architecture/adr-0006-local-storage-optional-helper.md) reaffirms the backup specification: local SQLite, optional helpers, and PostgreSQL only as a deployment option.

The [client/server integration contract](docs/fichas/architecture/integration.md) describes both the local Elixir diagnostics and the separate experimental direct-LAN text path. The diagnostics establish reachability and wire compatibility only; the LAN path authenticates pinned device keys but is not MLS product messaging.

The Elixir helper uses SQLite for local development and can select PostgreSQL for a deployment with `SLOUCHING_DATABASE_URL`. Its device-key table has no enrollment or lookup route and does not establish a required directory service. The desktop product stores its own encrypted local data in SQLCipher SQLite.

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

To try the direct-LAN text experiment with a friend, create a device identity
on both clients from the Familiar screen and exchange each displayed public
key over a trusted channel. On the receiving computer, run:

```sh
PEER_KEY='REPLACE_WITH_FRIEND_64_CHAR_PUBLIC_KEY_HEX'
cargo run -- --lan-listen 45873 --expect-peer "$PEER_KEY"
```

On the sending computer, replace the address with the receiver's LAN IPv4
address and use the receiver's public key:

```sh
PEER_KEY='REPLACE_WITH_RECEIVER_64_CHAR_PUBLIC_KEY_HEX'
cargo run -- --lan-send 192.168.1.20:45873 --expect-peer "$PEER_KEY" --text 'hello from the crew'
```

Both devices must be on a reachable LAN, with inbound UDP allowed on port
45873. The receiving terminal prints the message and the sender prints an
acknowledgement. This is a one-shot transport test; chat in the app remains a
visual preview, and this path does not support different networks or NAT
traversal.
