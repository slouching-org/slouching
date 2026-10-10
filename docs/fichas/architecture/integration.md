# Rust client and Elixir server integration

**Status:** local development status exchange and persistent binary WebSocket
transport after a version 1 handshake, plus a separate persistent bidirectional
direct-LAN text session in the Rust client. The Rust/Iced frontend and Elixir/OTP backend
communicate across processes. The Elixir diagnostics are not part of peer
traffic.

## Boundary

- `slouching-backend/server` owns the Elixir service and
  `GET http://127.0.0.1:3707/api/status`, plus binary WebSocket `/ws`. It also
  exposes `/health` for process availability. Bandit listens on loopback only.
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
session. It uses the normal sequenced ACK/REJECT flow; the app must verify the
call MLS group ID, epoch, and sender membership before accepting a signal. The
current UI rejects these frames until its WebRTC controller is implemented.

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
each recipient ACK. Stale or unreachable peers remain queued. Offline delivery
remains open. The ACK confirms durable client acceptance, not reading.

Members can send signed self-update proposals through the same pinned session.
The receiver verifies that the envelope author is the pinned transport device,
then authenticates and persists the proposal with OpenMLS before ACK. Exact
redelivery is deduplicated; if the ACK is lost, the member can resend the same
proposal. The designated committer still creates the Commit and uses the
recipient-snapshotted delivery path. Its UI lists the current-epoch proposals
by member and proposal ID prefixes; the explicit Commit action includes all
listed proposals together. Individual approval/rejection controls and other
proposal types remain unimplemented.

The invitee can also send its device-bound KeyPackage through that session.
The committer UI holds the inbound frame for explicit admission; it verifies
the package's device binding against the pinned peer and ACKs only after the
membership Commit and Welcome are stored locally. After KeyPackage admission, the committer sends the Welcome and ratchet tree over the same pinned session. The invitee validates the device binding, group ID, local KeyPackage and pinned committer, stores the joined group, then ACKs. Copy/paste remains an explicit fallback when delivery is unknown.

The v8 protocol adds signed delegated ciphertext copies, holder opt-in, and a
bounded recipient fetch. The UI fan-out action tries an available group helper
after a direct target failure; helper ACK remains distinct from recipient
delivery. Retention is best-effort, with no relay or NAT traversal. There is no
verified contact roster, group discovery, guaranteed offline delivery, or
cross-device history. Automated integration
tests launch two separate client processes and exchange text, MLS messages,
Commits, predecessor requests, proposals, KeyPackages, Welcome bundles, and a call offer over pinned QUIC,
verify wrong-key rejection, and check unknown pending delivery on disconnect
for text, MLS events, Commits, and proposals. A separate direct-session test exchanges a call offer and checks its transport ACK. A successful outbound peer handshake stores its pinned device key and socket
address in the encrypted local route book. The MLS UI uses those routes for
multi-member Commit and application-event fan-out. Real multi-member operation
still needs a manual test with two or more app instances on a reachable LAN and
firewall access to the chosen UDP ports. Linux requires an available Secret
Service for local device identity.

The Elixir diagnostic transport authenticates no device, carries no encrypted
event, and has no application command or subscription channel. The optional
backend also exposes an experimental SPAKE2 rendezvous HTTP API; it stores
bounded opaque messages in memory, expires them after two minutes, and permits
one exchange attempt per session. The Iced client does not yet integrate this
API or bind signed device identities to its transcript. See the
[rendezvous contract](../identity/pairing-rendezvous-v1.md). [ADR 0005](adr-0005-elixir-server-core.md)
defines the language division: Rust client plus Elixir backend.
[ADR 0006](adr-0006-local-storage-optional-helper.md) retains local SQLite
and optional helpers. The loopback Elixir diagnostics do not implement the
LAN path or make PostgreSQL a startup dependency. Product messaging still
needs automated trusted group provisioning, concurrent proposal handling,
helper delivery, and offline synchronization.

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
