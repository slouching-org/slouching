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

**Conceived by Rodrigo and Vitchola**, Slouching is an early native desktop app for a small crew to chat, call, and share a screen. The Rust/Iced client owns local keys, cryptography, direct peer paths, and per-peer chat history in encrypted SQLite. Elixir remains the backend language. A member may optionally host a helper on a PC or VPS for ciphertext delivery, discovery, relay, or group media. Pinned-device text works between reachable LAN peers without a hosted helper or PostgreSQL.

> [!IMPORTANT]
> This is an early build, **not a secure messenger**. The Rust/Iced frontend has the eleven design-board screens plus a local MLS group setup screen, encrypted profile and per-peer direct-chat history, and OpenMLS group/application-message core APIs. Outbound MLS ciphertext enters the SQLCipher outbox atomically with the ratchet update; inbound events are authenticated, persisted before plaintext is returned, and deduplicated. The MLS setup screen exchanges KeyPackage, Welcome, and ratchet tree manually over a trusted channel. MLS messages are not sent over a network or shown in chat. Direct-LAN chat uses Iroh/QUIC with manually pinned device keys; each device retains up to 1,000 messages per peer and offers confirmed deletion. Contact pairing, MLS event transport, offline delivery, calls, and screen sharing remain unimplemented. The Elixir backend uses SQLite locally and exposes development diagnostics; PostgreSQL is an optional deployment choice. The older Rust `slouching-peer` crate is an experiment, not the service backend.

![Native Rust/Iced home with the supplied night scenery and icon-based feature strip, without the frog mage or gnome cutouts](docs/design/readme/native-vhs-home.png)

![Actual Native Rust/Iced familiar screen showing local profile and keyring status after adding the device-to-MLS binding core](docs/design/readme/native-vhs-profile.png)

![Actual native direct-LAN chat UI showing its local-history label; this capture has no peer data and Secret Service is unavailable, so identity-gated controls are disabled](repositories/frontend/docs/design/runtime/native-vhs/06-chat.png)

![Actual native MLS group setup screen, captured before creating a group](repositories/frontend/docs/design/runtime/native-vhs/11-mls.png)

![Native Rust/Iced group-call preview with illustrative characters and chat; no media is connected](docs/design/readme/native-vhs-call.png)

The earlier local web preview remains available for design comparison. These are captures of that preview, with illustrative people and video tiles; they show no live peers or media.

| Web home preview | Web call layout preview |
| --- | --- |
| ![Old web home preview](docs/design/readme/home-preview.png) | ![Old web call preview](docs/design/readme/call-preview.png) |

## Repositories and documentation

This repository holds the project overview, design sources, and a reconciled documentation set. Product code lives in separate repositories, also listed as Git submodules here:

| Repository | Owns | Current state |
| --- | --- | --- |
| [slouching-frontend](https://github.com/slouching-org/slouching-frontend) | Native Rust/Iced desktop UI and web visual prototype | Eleven design-board views plus MLS group setup; bidirectional direct-LAN chat with per-peer SQLCipher history; atomic MLS application event journal; no network delivery |
| [slouching-backend](https://github.com/slouching-org/slouching-backend) | Elixir service backend | Local SQLite Repo, no-PostgreSQL smoke check, and transport diagnostics; PostgreSQL deployment option; no enrollment or product traffic |

Start with the [fichas index](docs/fichas/README.md). The [product specification](docs/fichas/architecture/backend.md), [Elixir backend boundary](docs/fichas/architecture/elixir-backend.md), [frontend screen specification](docs/fichas/frontend/screens.md), [technology plan](docs/fichas/architecture/tech-stack.md), and [ADRs](docs/fichas/README.md#accepted-decisions) describe the target and distinguish it from working code. The [owner's 11-page architecture PDF](docs/fichas/architecture/sources/architecture-p2p-v0.1.pdf) and [page-by-page transcript](docs/fichas/architecture/sources/README.md) are preserved. [ADR 0005](docs/fichas/architecture/adr-0005-elixir-server-core.md) defines the Rust-client/Elixir-backend division. [ADR 0006](docs/fichas/architecture/adr-0006-local-storage-optional-helper.md) reaffirms the backup specification: local SQLite, optional helpers, and PostgreSQL only as a deployment option.

The [client/server integration contract](docs/fichas/architecture/integration.md) describes both the local Elixir diagnostics and the separate direct-LAN text path. The diagnostics establish reachability and wire compatibility only; the LAN path authenticates pinned device keys but is not MLS product messaging.

The Elixir helper uses SQLite for local development and can select PostgreSQL for a deployment with `SLOUCHING_DATABASE_URL`. Its device-key table has no enrollment or lookup route and does not establish a required directory service. The desktop product stores its own encrypted local data in SQLCipher SQLite.

ADR 0004 changed the original single-workspace plan to [separate repositories](docs/fichas/architecture/adr-0004-separate-repositories.md). Its old Rust-backend wording is corrected by ADR 0005. The [old workspace ADR](docs/fichas/architecture/archive/adr-0004-workspace-superseded.md) is retained only as history.

## Design sources

The [source bank](docs/fichas/brand/source-bank.md) includes the original HTML board, all eleven exported screens, original scene and avatar JPEGs, and five earlier visual references. The [visual style](docs/fichas/brand/visual-style.md) documents the palette and treatment. The two walking wizards are the primary pictorial logo; the hat is a provisional small icon. Screen exports are design targets, not working app states.

| Home reference | Group call reference |
| --- | --- |
| ![Static home design](docs/design/screens/09-home.png) | ![Static group call design](docs/design/screens/10-group-call.png) |

## Run the app and local backend

Initialize the two code submodules, then run the service and desktop client in
separate terminals from this repository:

```sh
git submodule update --init --recursive
cd repositories/backend/server
mix deps.get
mix ecto.create
mix ecto.migrate --pool-size 1
mix test
mix run --no-halt
```

In a second terminal, from the project root, run the client. Its Rust build
requires `protoc` for protobuf code generation. The Elixir process is only
needed for local status/WebSocket diagnostics; direct LAN messages and their
local history do not use it.

```sh
cd repositories/frontend
cargo check
cargo run
```

The development status uses `127.0.0.1:3707/api/status`; the binary handshake
uses `ws://127.0.0.1:3707/ws`. Neither is authenticated product traffic. Run
`./scripts/check-integration.sh` from the project root for cross-repository
checks. The submodules pin the published backend and frontend commits,
including native runtime screenshots.

To use direct-LAN messaging, open the **chat** screen in both clients. Create
an identity in **Familiar** if needed, then use **Copiar minha chave pública**
and exchange the two keys over a trusted channel. Each person pastes the
other's key into **Chave pública do peer**. The receiving device selects a UDP
port and clicks **Aguardar peer**; share its displayed LAN address and port
with the sender. The sender enters that address, writes a message, and clicks
**Conectar e enviar**. Once connected, either side can send multiple messages
over that session; use **Desconectar sessão** to close it. **Apagar histórico
local deste peer** removes only this peer's local transcript after confirmation.
Both devices need to
be on a reachable LAN, with the chosen UDP port allowed by the local firewall.
On Linux, Secret Service must be available for device identity storage. Each
device keeps its own encrypted transcript for that pinned peer after the app
closes; history is not synchronized. Cross-network connections, NAT traversal,
MLS group messaging, and offline delivery are not implemented.
