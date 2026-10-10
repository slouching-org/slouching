# Rust client and Elixir server integration

**Status:** the Rust/Iced frontend and Elixir/OTP backend communicate across
processes for local diagnostics, experimental SPAKE2 rendezvous, and optional
signed-ciphertext mailbox delivery. Direct chat, MLS groups, and calls use
peer-to-peer transports. Remote helper deployment and physical-device
cross-repository validation remain open. The diagnostic WebSocket is not part
of peer traffic.

## Boundary

- `slouching-backend/server` owns the Elixir service, `GET /api/status`, binary
  WebSocket `/ws`, and process `/health` endpoint. Its optional helper APIs
  include SPAKE2 rendezvous and a signed-ciphertext mailbox. Bandit defaults to
  loopback and requires TLS for a non-loopback bind.
- `slouching-frontend` requests status and performs the WebSocket handshake
  asynchronously so the UI remains responsive. It must distinguish backend
  unavailable, unsupported contract, and the reported scaffold capabilities.
- The response reports `contract_version: 1`, `backend: "elixir_scaffold"`,
  `not_implemented` for identity, messaging, and calls, and zero peer
  connections. Controls for unavailable capabilities stay disabled.

The shared [protobuf schema](../../../proto/slouching/v1/handshake.proto)
defines the first binary frame as `ClientFrame.hello(protocol_version = 1)`.
The server replies with `ServerFrame.hello` (`server_role = "elixir"`, all
capabilities unavailable) or `ServerFrame.version_error` with its supported
version. A compatible socket stays open for WebSocket control Ping/Pong only;
a version error closes the socket. The client sends Ping every 5 seconds and
requires a matching Pong within 10 seconds. The server closes after 15
seconds without Ping; a missing hello closes after 5 seconds. The client
retries unavailable transport with bounded 1/2/4/8-second backoff.

These checks prove local transport liveness and wire compatibility only. The
HTTP status route is a separate diagnostic.

## Direct LAN messaging in the Iced client

The Iced chat screen can exchange multiple bounded UTF-8 text messages in both
directions over one session with a manually pinned device on a reachable LAN.
Both endpoints use the durable Ed25519 device identity as their Iroh EndpointId;
QUIC authenticates and encrypts the connection. Users manually exchange public
keys; the sender supplies the receiver's LAN IP and UDP port. A participant
relay is available only when configured with its URL and token; automatic
address discovery remains disabled. The receiver stores inbound text in its local SQLCipher
history before ACK, and the sender stores it after receiving ACK. ACK does not
mean the user read it. On disconnect, an unacknowledged
send is reported as delivery unknown and is not replayed. See the frontend's
[direct peer transport v10 contract](https://github.com/slouching-org/slouching-frontend/blob/main/docs/fichas/transport/lan-peer-v10.md)
for the screen flow and protocol. The v10 `CALL_SIGNAL` frame carries bounded
WebRTC offer, answer, ICE candidate, and end payloads through that pinned
session. It uses the normal sequenced ACK/REJECT flow; the app verifies the
call MLS group ID, epoch, and sender membership before accepting a signal. The
Iced call screen connects signaling to the local WebRTC controller and asks
before accepting an incoming call; physical multi-device calls remain untested.

The frontend can also send MLS application events through that direct session
once both devices have joined the same manually provisioned group. The receiver
validates event metadata and the sender's device-bound MLS credential, then
persists the ciphertext, ratchet update, and local plaintext transcript in one
SQLCipher transaction before ACK. Exact event redelivery is deduplicated. The
sender advances its outbox state only after the peer ACK and exposes a control
to retry queued events after reconnecting. Membership Commits are journaled
atomically with the committer epoch. A pending Commit can be sent over the
active pinned session to one device in the predecessor-epoch roster at a time,
checking that the Iroh pin matches the snapshotted device key. This excludes
the new invitee while allowing a removed device to receive its removal Commit.
The receiver authenticates and persists the
Commit before ACK; the sender records ACK per recipient, exposes the durable
adoption state in the UI, deduplicates exact redelivery, and drains each
recipient's eligible Commit chain in order. A recipient that is missing an
epoch requests that predecessor over the pinned session; the committer replays
it only when that device is in the saved recipient snapshot, including after a
prior ACK. The v7 predecessor request is bounded per session. The UI can fan out
queued Commits and application events sequentially over saved routes, persisting
each recipient ACK. Stale or unreachable peers remain queued. Best-effort
offline copies can use an authorized peer helper or the optional Elixir
mailbox; delivery still depends on a holder reaching the recipient. The ACK
confirms durable client acceptance, not reading.

Members can send signed self-update proposals through the same pinned session.
The receiver verifies that the envelope author is the pinned transport device,
then authenticates and persists the proposal with OpenMLS before ACK. Exact
redelivery is deduplicated; if the ACK is lost, the member can resend the same
proposal. The designated committer still creates the Commit and uses the
recipient-snapshotted delivery path. Its UI lists current-epoch proposals by
member and proposal ID prefix, with explicit per-proposal approval or
rejection. Only approved proposal references enter the Commit; other proposal
types remain unsupported.

The invitee can also send its device-bound KeyPackage through that session.
The committer UI holds the inbound frame for explicit admission; it verifies
the package's device binding against the pinned peer and ACKs only after the
membership Commit and Welcome are stored locally. After KeyPackage admission, the committer sends the Welcome and ratchet tree over the same pinned session. The invitee validates the device binding, group ID, local KeyPackage and pinned committer, stores the joined group, then ACKs. Copy/paste remains an explicit fallback when delivery is unknown.

The v10 peer protocol adds signed delegated ciphertext copies, holder opt-in,
and a bounded recipient fetch. The UI fan-out action tries an available group
helper after a direct target failure; helper ACK remains distinct from
recipient delivery. The optional Elixir HTTP mailbox adds configured HTTPS
upload fallback and manual fetch; the recipient persists the event locally
before its helper ACK. Neither helper path implements NAT traversal. LAN mDNS
provides untrusted listener hints, while the Iced identity screen maintains a
local roster of manually verified keys. There is no remote authenticated
directory, authenticated group discovery, guaranteed offline delivery, or
cross-device history. Automated integration
tests launch two separate client processes and exchange text, MLS messages,
Commits, predecessor requests, proposals, KeyPackages, Welcome bundles, and a call offer over pinned QUIC,
verify wrong-key rejection, and check unknown pending delivery on disconnect
for text, MLS events, Commits, and proposals. A separate direct-session test exchanges a call offer and checks its transport ACK. Direct QUIC sessions record the active IP route Iroh observes for the authenticated pinned device, whether the local device initiated or accepted the session. Relay paths remain distinct and are not saved as IP routes. The MLS UI uses those routes for
multi-member Commit and application-event fan-out. Real multi-member operation
still needs a manual test with two or more app instances on a reachable LAN and
firewall access to the chosen UDP ports. Linux requires an available Secret
Service for local device identity.

The Elixir diagnostic WebSocket authenticates no device, carries no encrypted
event, and has no application command or subscription channel. The optional
backend also exposes an experimental SPAKE2 rendezvous HTTP API; it stores
bounded messages in memory, expires them after two minutes, and permits one
exchange attempt per session. It relays encrypted signed device identity
statements only after both key confirmations. The experimental Iced identity
screen exchanges a transcript-bound signed device proof through the helper
and fills in the peer key after verification; it does not mark a person trusted
automatically. The two-client protocol test runs against a live helper through
`scripts/smoke-pairing-e2e.sh`; the rendered GUI and physical-device exchange
still need runtime validation. See the
[rendezvous contract](../identity/pairing-rendezvous-v1.md). The optional HTTP
mailbox stores opaque signed copies, supports cursor pagination, and requires
the recipient to persist an accepted MLS event before ACK; a live local
cross-repository test covers two pages. See the
[mailbox contract](../delivery/mailbox-http-v1.md). [ADR 0005](adr-0005-elixir-server-core.md)
defines the language division: Rust client plus Elixir backend.
[ADR 0006](adr-0006-local-storage-optional-helper.md) retains local SQLite
and optional helpers. The loopback Elixir diagnostics do not implement the
LAN path or make PostgreSQL a startup dependency. Product messaging still
needs automated trusted group provisioning, concurrent proposal handling,
and cross-device validation of the remote mailbox flow. Offline delivery is
opportunistic and depends on a reachable authorized holder.

## Local checkout and validation

Keep the frontend, backend, and project repositories side by side under one
directory. Run `scripts/check-integration.sh` from this repository to test
the Elixir server, smoke-test its optional SQLite Repo without PostgreSQL,
and compile/test the Rust frontend, including the separate-process direct-LAN
peer integration tests. The backend test suite exercises the status route and
protobuf handshake contracts.
The old Rust `peer/` crate is preserved in the backend repository as a
historical scaffold and must not be started on the same port.

Before release, test the product MLS protocol end to end and document which
service features remain available without a reachable self-hosted server.
Neither status checks nor the direct-LAN experiment prove product MLS
messaging, media, or offline delivery.
