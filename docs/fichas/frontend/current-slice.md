# Current frontend slice

**Status:** eleven design-board views plus a native MLS group screen. Direct
LAN chat uses pinned Ed25519 device identities and persistent Iroh/QUIC
sessions. Direct sessions save the active IP route Iroh reports for the
authenticated pinned device on either side of the connection, refreshing the
encrypted local route book. Relay sessions are never recorded as direct socket
addresses; the explicitly configured relay route stays separate. Routes can
still become stale. The MLS screen uses these routes for sequential
multi-member Commit fan-out. MLS group setup sends a device-bound KeyPackage over the active
pinned session. The committer reviews and admits it after matching the package
identity to the transport peer. Admission saves the exact Welcome and ratchet
tree in the encrypted outbox with the membership Commit. The committer sends
the bundle over the pinned session and marks it delivered after ACK. The
invitee validates the target device, group, local KeyPackage and pinned
committer, saves the joined group and content-bound Welcome receipt atomically,
then ACKs. Reconnecting retries queued Welcomes; duplicate delivery after a
lost ACK returns the existing group. Copy/paste remains available when direct
delivery is unavailable. For an existing group, a pinned member connection
starts its eligible Commit chain automatically, one at a time with a durable
ACK before advancing; manual distribution remains available. The separate
fan-out control walks queued recipients with saved routes, sends bounded
ordered batches, and leaves missing or stale routes queued. Each member still
uses a separate peer session.

MLS application messages are encrypted with OpenMLS and sent over the active
direct session. Each message atomically snapshots current peer devices with
the ciphertext and ratchet update. The receiver validates the sender binding
and event metadata, advances the ratchet, stores ciphertext and the local
transcript in SQLCipher, then ACKs. Per-device ACKs keep other recipients
queued, and the global outbox entry closes only after all snapshot members
confirm. Direct send checks the pinned peer against that snapshot; queued
messages can be retried to that peer or fanned out over saved routes. A peer
with pending Commits is skipped until its epoch is current. An unavailable
peer does not block other recipients.

Before applying each next-epoch Commit, the client saves the prior OpenMLS
state in SQLCipher. A different, valid Commit for an already accepted
predecessor epoch is checked against that snapshot, including its MLS
signature, group, epoch, designated committer, and device binding. Authenticated
equivocation stores both Commit values and quarantines that group locally while
preserving its accepted epoch. The UI restores a security alert when reopening
the group and blocks MLS sends, retries, member admission, Commit distribution,
and manual Commit application. Invalid conflicts do not quarantine. A confirmed
recovery action can create a new MLS group while preserving the quarantined
group and its local transcript. The new group starts without members or copied
history; users must invite devices again. Local verification remains bound to
each exact device key and does not add group members automatically. There is no
same-group rekey or automatic membership recovery.

The native Iced gallery reaches each source-board view. The MLS screen creates
groups, prepares and admits device-bound KeyPackages over the active pinned
session, processes Welcome and ratchet-tree data, loads a bounded local
transcript, sends application messages, and retries queued outbox events for
the selected group. Copy/paste remains available when a direct session cannot
be established. Both devices must join the same group, select its ID, and
establish a reachable direct session.
Groups saved on the device are listed with their current epoch and quarantine
state. Opening one restores its ID, transcript, pending Commits, and security
alert from SQLCipher after an app restart.
Members can prepare signed self-update proposals and send them to the designated
committer over the active pinned session, with copy/paste as a fallback. The
committer authenticates and stores the proposal before ACK, then creates an
atomic Commit for the existing per-member delivery flow. Other proposal types
remain unimplemented.

The designated committer can also remove a selected device from the group after
an explicit UI confirmation. The removal Commit, next epoch, and delivery
snapshot of the prior membership are committed atomically. The removed device
can apply the Commit, after which OpenMLS marks that local group inactive,
excludes the device from membership, and rejects further MLS application
messages. The group transcript stays visible while MLS sends and attachments
are disabled. The UI lists devices by key prefix because human contact names
are not bound to MLS credentials.

The MLS composer can attach a local file. It encrypts the file into the local
blob store, sends the key-bearing offer as an MLS application event, then
streams ciphertext to each connected, snapshotted peer after the offer ACK.
The receiver authenticates membership and the exact offer before storing the
ciphertext, then confirms storage on the stream. Its transcript card decrypts
to a user-selected path after digest verification. Directly routed recipients
can be retried after restart from the persisted outbox and blob store. Helpers
and the optional Elixir mailbox carry the MLS offer but not its attachment
blob, so that recipient stays pending until a direct route is available. The
two-machine database-authorized flow has not yet been runtime-validated.

The direct-peer text screen manually pins the peer's Ed25519 device key. One
side listens and shares an announced LAN/VPN address; the other connects. The
connection screen can browse active Slouching listeners over local mDNS and
fill an untrusted route into chat; it never supplies or verifies the peer key.
mDNS discovery itself does not cross a VPN. Both can send multiple messages. The receiver stores inbound text before ACK; the
sender stores sent text after ACK. It reloads the newest 200 messages for the
peer and supports confirmed history deletion. A member may configure an
HTTPS/token Iroh Relay for direct-text fallback or relay-only routes; the local
authenticated relay path has an end-to-end message test. VPN between machines,
remote relay deployment, and MLS fan-out over a relay remain unverified. There
is no authenticated remote contact discovery or hole-punching. Best-effort offline
copies can be stored by an opted-in group peer or the optional remote Elixir
mailbox; delivery cannot be promised when no holder can reach the recipient.
The MLS ACK confirms durable local acceptance by the other client, not that a
person read the message.

Network & P2P settings expose the opt-in for a bounded delegated MLS-copy
queue. QUIC v10 transports a signed author grant and lets a connecting recipient
fetch up to 16 copies addressed to its device per connection. A helper ACKs
only after local SQLCipher persistence; the recipient verifies the grant, applies the MLS
event, persists its transcript, then ACKs so the helper can erase the copy.
When a direct target route fails, the explicit MLS fan-out action tries a
reachable routed group member for each queued event. The target outbox stays
queued until its own ACK. This is best-effort retention within helper quota and
expiry, not guaranteed offline availability.

The same settings page has an optional HTTPS Elixir mailbox URL. When enabled,
MLS fan-out stores signed opaque event copies there after direct routes and
opted-in peer copies leave recipients uncovered. Recipients manually fetch all
available pages per action. The client verifies the author grant, persists each
event locally, and then ACKs helper deletion. A cross-repository smoke test
covers 18 signed copies over two pages. Remote deployment and physical-device
flow remain unverified; this is asynchronous storage and does not provide a
live route across NAT.

The familiar screen stores the display name and familiar in encrypted SQLite;
it also accepts an optional PNG avatar, bounds and resizes it before storing
the bytes in the encrypted profile. A built-in familiar selection clears that
custom image.
the database key and Ed25519 device seed use the operating system credential
store. The trust screen displays a signed QR invitation with the device key and
current listener addresses, and imports one from a PNG image or a local camera
scan. The invite
signature binds its address list to that key, expires after 10 minutes, and
never contains private keys or relay tokens. Importing it fills the peer key
and lets the user choose among its addresses, but does not automatically mark
the contact verified. The user must authenticate the QR source or compare the
complete 64-character key through an independent channel before marking that
exact key verified in SQLCipher. A replacement key does not inherit trust. The
identity screen derives a symmetric full 256-bit BLAKE3 fingerprint from both
public device keys for live comparison. Experimental SPAKE2 rendezvous pairing
uses the optional Elixir helper and transcript-bound signed device proofs; it
does not verify a human or trust a contact automatically. Manually verified
device keys now appear in a SQLCipher-backed local contact list with optional
device-local labels and saved-route hints. Selecting one opens direct chat with
that pinned key; the list does not establish reachability or add any group
membership. Cross-device directory discovery remains open.
Camera QR scanning uses an explicit local camera session and applies the same signature and trust checks
as PNG import. A device-signed binding connects that identity to the MLS
signing key and is carried in
KeyPackages; the binding alone does not verify a person. Linux needs Secret
Service in the user session. The settings **Rede & P2P** screen separately
shows local Elixir HTTP/WebSocket diagnostics; it does not carry chat traffic.

The **Conexão & rotas** screen reports live local identity, listener and QUIC
send state, WebRTC connection state, and Elixir diagnostics. Its links open the
existing direct-text, MLS, call, and network settings flows. It labels text
relay separately from WebRTC TURN. LAN mDNS listener hints and configured
direct-text relay routes exist. TURN remains unimplemented; an experimental
two-device Elixir SFU route now has local live-helper authentication,
negotiation, ICE/DTLS, and protected-audio forwarding coverage. Neither route
has been validated across physical devices or different networks.

Character scenes remain illustrations rather than live participants. Dedicated
call MLS groups, authenticated member-index resolution, and bounded SFrame
protection are implemented. Pinned QUIC signaling feeds a direct WebRTC
controller with explicit incoming-call acceptance, Opus/SFrame audio, temporary
call chat, and H.264/SFrame screen or camera video over one bounded data
channel. Screen and window capture use xcap; window enumeration on Linux uses
X11/Xorg and reports the limitation in a pure Wayland session. Native Wayland
window selection and streaming use the desktop portal and PipeWire, but still
need runtime validation on supported compositors. Camera capture uses the
native V4L2, Media Foundation, or AVFoundation API, with preview only after an
explicit action.
Local loopback covers media, chat, video decode, and stop signaling; physical
capture, OS permissions, calls across machines/VPN, small-group mesh, and SFU
still need validation or implementation. Authenticated contact discovery and
cross-device validation of offline mailbox delivery remain open. QR invitation binary format and
trust flow require security review before public release.
The older web UI under
`prototypes/web/` is a design benchmark, not the product runtime.

See the [v10 direct peer transport contract](https://github.com/slouching-org/slouching-frontend/blob/main/docs/fichas/transport/lan-peer-v10.md),
the [screen specification](screens.md), and the
[technology plan](../architecture/frontend-tech-stack.md).
