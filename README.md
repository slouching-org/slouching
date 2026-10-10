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

**Conceived by Rodrigo and Vitchola**, Slouching is an early native desktop app for a small crew to chat, call, and share a screen. The Rust/Iced client owns local keys, cryptography, direct peer paths, and per-peer chat history and pinned peer routes in encrypted SQLite. Elixir remains the backend language. A member may optionally host a helper on a PC or VPS for ciphertext delivery, discovery, relay, or group media. Pinned-device text works over manually addressed reachable UDP routes without a hosted helper or PostgreSQL.

> [!IMPORTANT]
> This is an early build, **not a secure messenger**. Direct pinned-device text and MLS application messaging work over Iroh/QUIC when a manually supplied UDP route is reachable. The MLS screen can send a device-bound KeyPackage through a pinned session, where the committer reviews and admits it. The committer saves the Welcome and ratchet tree in an encrypted retry queue and resends them when the pinned invitee reconnects. The invitee records a content-bound receipt with group admission, so duplicate delivery after a lost ACK returns the existing group. The receiver validates and persists ciphertext, ratchet state, and transcript in SQLCipher before ACK. Each application event snapshots eligible member devices; per-device ACKs keep other recipients queued, and the MLS screen can retry one pinned member or fan out over saved routes. If direct delivery fails, the client can try a reachable opted-in group peer or an explicitly configured Elixir HTTPS mailbox. A mailbox recipient manually fetches copies addressed to its device, verifies the author grant, persists the event, then ACKs deletion to the helper. That ACK confirms helper removal only; delivery remains pending until the recipient device confirms MLS processing. Mailbox retention is best-effort and does not provide NAT traversal or live P2P connectivity. Membership Commits are stored atomically with the committer's new group epoch. When a pinned group member connects, its eligible pending Commits start sending automatically, one at a time with a durable ACK before advancing. The committer can also distribute queued Commits sequentially to all eligible members with saved routes; unavailable peers remain queued. Exact redelivery is harmless. Clients detect authenticated committer equivocation against saved historical OpenMLS state, preserve both conflicting Commits, and quarantine the affected group without changing its accepted epoch. The client now supports an explicitly configured, token-protected Iroh Relay 1.3 route, covered by a local end-to-end message/ACK test; remote TLS deployment and cross-network VPN use have not been verified. Signed QR invitations now exchange device keys and announced addresses, but imported images do not automatically establish human trust. SFrame frame protection now has a dedicated MLS call-group purpose and a guarded, zeroizing MLS exporter. Sender and receiver member indexes resolve from authenticated call-group device bindings, with two-profile frame-encryption coverage. The call screen can create a call-only MLS group, invite members, and negotiate a WebRTC offer/answer over the pinned QUIC session after checking the sender against the current MLS epoch and membership; incoming offers wait for explicit acceptance or refusal. A local host-candidate ICE/DTLS test passes. Opus/SFrame voice now connects CPAL capture and device playback to WebRTC RTP. A local two-peer test sends a protected frame and verifies decoded samples at the receiver; real-device calls and a two-machine VPN call remain unverified. The screen chooser enumerates monitors and captures an on-demand local still preview. During an active call, the UI can now capture the selected monitor continuously, encode bounded H.264 frames, protect them with the call group SFrame key, fragment them below WebRTC’s message limit, and render authenticated frames received from the peer. Local tests cover codec protection/replay rejection and fragmented WebRTC DataChannel delivery/stop signaling; a real two-device call, screen capture permissions, and VPN delivery are not yet validated. The connection screen can search the LAN for active Slouching listeners with mDNS and fill a discovered route into direct chat. These untrusted hints expose no device key; users still enter and authenticate the peer key. The identity screen now supports experimental SPAKE2 code pairing through the optional Elixir helper, including transcript-bound signed device identities; the live-helper two-client test passes, while the rendered GUI and physical-device flow remain to be validated. Authenticated remote contact discovery remains open. The identity screen also derives a full 256-bit BLAKE3 fingerprint from both device keys for out-of-band comparison. The Elixir backend uses SQLite locally; PostgreSQL is an optional deployment choice. The older Rust `slouching-peer` crate is an experiment, not the service backend.

The optional Elixir SFU now has authenticated WebSocket signaling and an
experimental Rust client route configured in **Configurações → Rede & P2P**
(`SLOUCHING_SFU_WS_URL` remains a development override). Its
**Testar conexão com o helper** checks the authenticated WSS endpoint and SFU
capability; media UDP still requires a real call. The live-helper smoke test
verifies signed roster admission, SDP negotiation, ICE/DTLS, and protected
audio forwarded between two software clients. Physical devices and calls across
different networks remain unverified; the normal direct call path continues to
use the pinned peer connection.

Members can also send a signed MLS self-update proposal to the designated
committer over the active pinned peer session, with copy/paste over a separately
trusted channel as a fallback. The committer binds the MLS author to the pinned
device and saves the authenticated proposal before ACK or Commit generation.
The committer explicitly approves or rejects each current-epoch proposal;
only approved proposal references enter the Commit. Decisions persist in the
encrypted local profile. Other MLS proposal types remain unsupported.

The MLS screen lists group members by device-key prefix. The designated
committer can remove a selected device after explicit confirmation. Its signed
removal Commit, new group epoch, and delivery recipients from the preceding
epoch are persisted atomically. The removed device can apply the Commit, after
which OpenMLS marks its local group inactive, excludes it from membership, and
rejects further MLS messages. Its local transcript remains visible, with MLS
sends and attachments disabled for that inactive group.

The identity screen signs a 10-minute QR invite containing the device key and,
when a listener is active, its announced addresses. Import from PNG or scan
with the camera verifies the signature and labels each address by IP range.
Select the VPN address (Tailscale usually assigns `100.64.0.0/10`; other VPNs
may use a private address) when the devices are on different networks. Keep the receiver's
listener open and allow its UDP port through the device firewall and VPN ACL.
Camera access is explicit and local to the scan; captured frames are
not stored or sent. Neither import path identifies the person behind an image
or marks the key trusted; users must authenticate the QR source or compare the
complete key independently. The identity screen also derives a symmetric
full 256-bit BLAKE3 pair fingerprint for live comparison. The connection
screen can search the LAN for active listeners with mDNS and fill a route into
direct chat; the discovery hint never authenticates a device. The Iced
identity screen now supports experimental SPAKE2 code pairing through the
Elixir rendezvous helper, exchanging transcript-bound signed
device identities without marking contacts trusted automatically.
`scripts/smoke-pairing-e2e.sh` validates both Rust client roles against a live
local Elixir server and rejects mismatched codes; physical-device GUI use and
remote helper deployment remain unverified. Authenticated remote contact discovery remains open.
See the [SPAKE2 client boundary](docs/fichas/identity/spake2-prototype.md) and
[rendezvous API](docs/fichas/identity/pairing-rendezvous-v1.md).
See the [invite format and trust boundary](docs/fichas/identity/pairing-invite-v1.md).
Manually verified device keys also appear in a local SQLCipher-backed contacts
list with optional local labels and saved-route hints. Selecting a contact opens
direct chat with that exact key; this local roster does not provide remote
discovery or guarantee reachability.

The native client now contains an internal file-transfer crypto foundation:
random per-file keys, authenticated 48 KiB chunks, a 100 MiB bound, ciphertext
digests, bounded streaming encryption/decryption, a filename-only offer format,
and an encrypted persistent iroh-blobs store with an explicit peer-authorization
gate. The desktop app has a private per-user store location and a bounded
ciphertext import that checks length and digest before adding a persistent
reference. Stored ciphertext can be decrypted chunk by chunk and published to
a destination only after AEAD and ciphertext-digest validation, without
replacing an existing file; Unix staging files use mode 0600. A local
two-endpoint QUIC test covers authorized retrieval and rejects an
unauthorized peer. The peer layer also has a separate bidirectional QUIC
stream for sending ciphertext against a group-bound offer. The receiver sends
an ACK only after validating and persisting the ciphertext; the two-endpoint
transfer-and-save test covers that receipt. The bounded receive-store path stages ciphertext in a
private temporary file and rejects streams whose size or digest differs from
the MLS offer before adding a blob reference. Its plaintext receive core
stages data and publishes it only after digest validation, without replacing
an existing destination. The MLS composer imports and encrypts a chosen file,
sends its offer as an MLS event, and starts a separate QUIC ciphertext stream
after the receiver ACKs that event. The receiver checks active membership in
that MLS group and the exact stored offer before importing the bounded stream;
it then confirms storage on that same stream. Group fan-out sends each
attachment over a direct member route and leaves that recipient queued until
the blob ACK. The outbox and encrypted blob store allow retries after restart.
Helpers and the Elixir mailbox carry MLS events but not attachment blobs, so
attachments stay queued until a direct route is available. The attachment card
can save by decrypting to a chosen path after integrity checks. The full
database-authorized desktop flow and cross-machine file transfer still need
runtime validation. Offer persistence in SQLCipher has
group-state checks, idempotent retries, member-device validation, transfer-ID
conflict checks, and a 200 MiB per-profile quota. The pinned iroh-blobs
0.103.1 release is marked by its maintainers as not production quality, so
this remains experimental.

The MLS screen lists local groups with their current epoch and quarantine state;
opening a saved group restores its transcript and security state from SQLCipher.
When authenticated committer equivocation quarantines a group, its alert offers
a confirmed path to create a replacement group. The old group and transcript
remain preserved; members and history are never copied, so devices must be
invited again. Existing local verification decisions stay bound to their exact
device keys and do not add anyone to the new group automatically.

![Native Rust/Iced home with the supplied night scenery and icon-based feature strip, without the frog mage or gnome cutouts](docs/design/readme/native-vhs-home.png)

![Actual Native Rust/Iced familiar screen showing local profile and keyring status after adding the device-to-MLS binding core](docs/design/readme/native-vhs-profile.png)

![Native Iced direct chat with explicit listener and VPN address guidance, relay settings, and copy controls for sample LAN and VPN socket addresses; addresses are illustrative and Secret Service is unavailable](repositories/frontend/docs/design/runtime/native-vhs/06-chat.png)

![Actual 934 × 1000 native MLS screen showing pending, approved, and rejected self-update proposal review controls; proposal rows are capture fixtures](repositories/frontend/docs/design/runtime/native-vhs/11-mls.png)

That MLS capture predates member removal. Refresh it from a graphical session
with `--capture-mls-member-removal`; this development environment has no
Wayland or X11 display, so it could not produce a fresh rendered image.

![Actual native Iced MLS screen with an encrypted attachment card and save action; attachment and connected state are capture fixtures](repositories/frontend/docs/design/runtime/native-vhs/12-mls-attachments.png)

![Actual native Iced audio settings with real input/output devices and local microphone test; names are machine-specific and no call is connected](repositories/frontend/docs/design/runtime/native-vhs/13-audio-devices.png)

The audio settings list real devices available to the current system session.
The selected input/output stays in memory and is used by direct voice calls. An
explicit local microphone test shows input level without saving or sending
samples. Calls use Opus/SFrame over WebRTC RTP after MLS membership and peer
signaling; video and physical two-device validation remain outstanding.
The call audio decoder now keeps an independent Opus state and SFrame replay
window for each remote member in the call MLS group, selecting by the SFrame
sender index. The current call UI still establishes one remote WebRTC peer; this
change prepares multi-source audio reception but does not implement mesh or SFU
calls.

![Actual native identity screen showing a signed peer invitation QR; the device keys and VPN address are capture fixtures](repositories/frontend/docs/design/runtime/native-vhs/08-verify.png)

![Actual native identity screen after importing a QR, with separate LAN and VPN address choices; all values are capture fixtures](repositories/frontend/docs/design/runtime/native-vhs/08-verify-invite-imported.png)

These identity screenshots predate the full pair fingerprint and verified
contacts list, and the connection screenshot predates LAN discovery. The
identity capture was attempted after the contacts update, but Iced could not
start because this session has no Wayland or X11 display. Refresh them in a graphical
Wayland or X11 session with:

```sh
cd repositories/frontend
SLOUCHING_WINDOW_SIZE=1280x800 cargo run -- --capture-dir /tmp/slouching-captures --capture-screen 08-verify --capture-peer-verification
SLOUCHING_WINDOW_SIZE=1280x800 cargo run -- --capture-dir /tmp/slouching-captures --capture-screen 04-connecting --capture-lan-discovery
```

This checkout has no display server, so it could not produce fresh screenshots.

![Native Rust/Iced call screen capture from before Opus RTP integration; the current screen shows the call controls](docs/design/readme/native-vhs-call.png)

The earlier local web preview remains available for design comparison. These are captures of that preview, with illustrative people and video tiles; they show no live peers or media.

| Web home preview | Web call layout preview |
| --- | --- |
| ![Old web home preview](docs/design/readme/home-preview.png) | ![Old web call preview](docs/design/readme/call-preview.png) |

## Repositories and documentation

This repository holds the project overview, design sources, and a reconciled documentation set. Product code lives in separate repositories, also listed as Git submodules here:

| Repository | Owns | Current state |
| --- | --- | --- |
| [slouching-frontend](https://github.com/slouching-org/slouching-frontend) | Native Rust/Iced desktop UI and web visual prototype | Twelve native Iced screens; pinned Iroh/QUIC messaging; MLS groups and attachments; optional Elixir mailbox opt-in, upload fallback, and manual fetch; WebRTC call signaling with Opus/SFrame RTP and H.264/SFrame screen frames |
| [slouching-backend](https://github.com/slouching-org/slouching-backend) | Elixir service backend | Packaged Mix release, local SQLite Repo, diagnostics, experimental SPAKE2 rendezvous, and optional signed ciphertext mailbox API with periodic expiry; configurable HTTPS listener rejects non-loopback plaintext; PostgreSQL deployment option |

Start with the [fichas index](docs/fichas/README.md). The [product specification](docs/fichas/architecture/backend.md), [Elixir backend boundary](docs/fichas/architecture/elixir-backend.md), [frontend screen specification](docs/fichas/frontend/screens.md), [technology plan](docs/fichas/architecture/tech-stack.md), and [ADRs](docs/fichas/README.md#accepted-decisions) describe the target and distinguish it from working code. The [owner's 11-page architecture PDF](docs/fichas/architecture/sources/architecture-p2p-v0.1.pdf) and [page-by-page transcript](docs/fichas/architecture/sources/README.md) are preserved. [ADR 0005](docs/fichas/architecture/adr-0005-elixir-server-core.md) defines the Rust-client/Elixir-backend division. [ADR 0006](docs/fichas/architecture/adr-0006-local-storage-optional-helper.md) reaffirms the backup specification: local SQLite, optional helpers, and PostgreSQL only as a deployment option.

The [client/server integration contract](docs/fichas/architecture/integration.md) describes both the local Elixir diagnostics and the separate direct-peer text path. The diagnostics establish reachability and wire compatibility only. Direct peer text and MLS messages use the separate pinned Iroh/QUIC path.

The Elixir helper uses SQLite for local development and can select PostgreSQL for a deployment with `SLOUCHING_DATABASE_URL`. Its device-key table has no enrollment or lookup route and does not establish a required directory service. The optional mailbox API accepts signed opaque MLS copies and authenticates recipient list/ACK requests with Ed25519; its [HTTP v1 contract](docs/fichas/delivery/mailbox-http-v1.md) is implemented and tested in the backend, but the desktop client is not wired to it yet. The desktop product stores its own encrypted local data in SQLCipher SQLite.

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
requires `protoc` for protobuf code generation. The Elixir process provides
local status/WebSocket diagnostics and the optional code-pairing helper;
direct LAN messages and their local history do not use it.

```sh
cd repositories/frontend
cargo check
cargo run
```

The development status uses `127.0.0.1:3707/api/status`; the binary WebSocket
at `ws://127.0.0.1:3707/ws` proves possession of the local device key with a
fresh server challenge. It grants no product authorization and carries no
messages or media. Run
`./scripts/check-integration.sh` from the project root for cross-repository
checks. The submodules pin the published backend and frontend commits,
including native runtime screenshots.

To use direct peer messaging, open the **chat** screen in both clients. Create
an identity in **Familiar** if needed, then use **Copiar minha chave pública**
and exchange the two keys over a trusted channel. Each person pastes the
other's key into **Chave pública do peer**: the listener pins the sender's key,
and the sender pins the listener's key. The receiving device selects a UDP
port and clicks **Aguardar peer**; use the copy button beside the address for
the reachable interface and share it with the sender. For a VPN test, share
the listener's VPN IP with that same UDP port and allow inbound UDP in its
firewall. The VPN must route UDP between both devices. The sender enters the
listener's address, writes a message, and clicks
**Conectar e enviar**. Once connected, either side can send multiple messages
over that session; use **Desconectar sessão** to close it. **Apagar histórico
local deste peer** removes only this peer's local transcript after confirmation.
The familiar can be one of the supplied characters or a custom PNG saved in
the encrypted local profile.
To exchange identity keys, each person can show a signed QR on **Conferir
identidade do peer**. The other person can choose **Escanear QR** and point the
camera at it, or import a screenshot as PNG. After the listener starts, show a
fresh QR to include its active addresses; import it and choose the LAN or VPN
route. Camera scanning stays on the receiving device, runs only after the user
starts it, and stops after a valid invite or 30 seconds. QR import does not
automatically mark a contact trusted, and a displayed QR must come from a
channel you trust. See the [QR invite format and trust boundary](docs/fichas/identity/pairing-invite-v1.md).
For a LAN test, both devices need to be on a reachable LAN, with the chosen
UDP port allowed by the local firewall.
Two devices on the same VPN can try the same direct flow by using the receiver's
VPN address, provided that VPN carries UDP between them. This has not yet been
verified across machines and does not add NAT traversal to Slouching.
For voice and screen sharing, both devices also need membership in the same
dedicated call MLS group. The caller negotiates WebRTC from **Chamada**; the
recipient accepts the incoming call. The call panel's **Chat temporário** sends
SFrame-protected text and keeps up to 100 messages in memory; it is discarded
when the call ends. To share a monitor, select it in
**Escolher tela** and press **Compartilhar tela na chamada**. The local codec,
protected call DataChannel, bidirectional ephemeral chat, remote video decode,
and stop signal pass loopback tests, but physical-device capture and calls over
VPN remain unverified. See the
[frontend call trial instructions](https://github.com/slouching-org/slouching-frontend#direct-voice-call-with-another-device).
For camera video, open **Escolher tela → Câmera**, choose a device, capture a
local preview if desired, then click **Compartilhar câmera na chamada**. The
camera and monitor share one video slot; use **Parar compartilhamento** to stop.
Physical camera permissions and camera video between separate computers still
need testing.
The **Janelas** tab lists visible windows, offers an explicit local preview, and
shares H.264/SFrame frames through the same video slot. Linux X11 uses xcap;
Wayland uses the ScreenCast portal and PipeWire to select and capture one
window. Portal support still needs runtime validation with real compositors.
On Linux, Secret Service must be available for device identity storage. Each
device keeps its own encrypted transcript for that pinned peer after the app
closes; history is not synchronized. For MLS group chat, provision the same
group on both devices through **Grupo MLS**, connect them in **Texto direto ·
LAN/VPN**, select the same group ID, and send from the MLS screen. After admission, later members receive the Welcome and ratchet tree through
the pinned session, validate it, save the group and ACK. Existing members receive Commits through
the active session; the sender uses the predecessor-epoch member snapshot,
while the receiver persists the new epoch before
ACK and the sender records it per recipient; the MLS screen shows each member's
adoption status. A new invitee is excluded from that older Commit; a removed
device can still receive its removal Commit. When each member connects, the
client drains that device's eligible ordered Commits automatically; the manual
**Enviar Commits pendentes** control remains available. Connect to each other
member separately.
If a peer lacks an epoch, it requests that predecessor over the pinned session;
the committer can replay it only to a device in that Commit's saved recipient
snapshot, even after recording an earlier ACK.
Group creation and committer admission require explicit user action. The MLS
screen can fan out queued events over saved peer routes, and reconnecting peers
drain their eligible Commit chain. There is no automatic NAT traversal. A
member-operated Iroh Relay can be configured for direct-text connections when
a route needs relaying; the relay must be reachable over HTTPS and configured
with the same shared token on each peer. Remote relay and VPN behavior still
need testing. See the [frontend test flow](https://github.com/slouching-org/slouching-frontend#run-the-native-scaffold).

An opted-in peer helper can accept an author and recipient in separate
authenticated sessions; ordinary application frames still require the
manually pinned peer. A separate optional Elixir HTTPS mailbox supports
fallback uploads and manual fetches, with the recipient persisting an MLS
event before ACKing helper deletion. Both are best-effort store-and-forward,
not live connectivity or guaranteed offline delivery. Local mDNS can discover
listener routes on the same LAN, but it neither crosses VPNs nor performs
hole-punching. A VPN may provide a direct route between devices if it carries
UDP and the receiving firewall allows it; cross-network VPN behavior has not
yet been verified.
