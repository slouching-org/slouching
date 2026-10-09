# Current frontend slice

**Status:** eleven design-board views plus a native MLS group screen. Direct
LAN chat uses pinned Ed25519 device identities and persistent Iroh/QUIC
sessions. MLS group setup supports manual KeyPackage, Welcome, and ratchet-tree
exchange over a trusted channel. For an already joined group, MLS application
messages are encrypted with OpenMLS and sent over the active direct session.
The receiver validates the sender binding and event metadata, advances the
ratchet, stores ciphertext and the local transcript in SQLCipher, then ACKs.
The sender marks the outbox event held by the peer after receiving that ACK.
Queued events can be retried from the MLS screen after reconnecting. When a
pinned peer connects, the client automatically checks and sends the eligible
Commit chain for that device, waiting for each durable ACK before advancing;
the manual send control remains available. Every member still uses a separate
peer session.

Before applying each next-epoch Commit, the client saves the prior OpenMLS
state in SQLCipher. A different, valid Commit for an already accepted
predecessor epoch is checked against that snapshot, including its MLS
signature, group, epoch, designated committer, and device binding. Authenticated
equivocation stores both Commit values and quarantines that group locally while
preserving its accepted epoch. The UI restores a security alert when reopening
the group and blocks MLS sends, retries, member admission, Commit distribution,
and manual Commit application. Invalid conflicts do not quarantine. There is
no recovery or rekey flow yet.

The native Iced gallery reaches each source-board view. The MLS screen creates
groups, prepares and admits device-bound KeyPackages, processes Welcome and
ratchet-tree data, loads a bounded local transcript, sends application
messages, and retries queued outbox events for the selected group. Both devices
must join the same group, select its ID, and establish a direct LAN session.
Group invitations still require a separately trusted channel.
Groups saved on the device are listed with their current epoch and quarantine
state. Opening one restores its ID, transcript, pending Commits, and security
alert from SQLCipher after an app restart.
Members can prepare signed self-update proposals and transfer them to the
designated committer through a separately trusted channel. The committer
authenticates and stores the proposal, then creates an atomic Commit for the
existing per-member delivery flow. Other proposal types and network proposal
delivery remain unimplemented.

The direct-LAN text screen manually pins the peer's Ed25519 device key. One
side listens and shares its announced LAN address; the other connects. Both can
send multiple messages. The receiver stores inbound text before ACK; the sender
stores sent text after ACK. It reloads the newest 200 messages for the peer and
supports confirmed history deletion. This pairwise text path is separate from
MLS. Neither path provides relay, address discovery, NAT traversal, or offline
delivery. The MLS ACK confirms durable local acceptance by the other client,
not that a person read the message.

The familiar screen stores the display name and familiar in encrypted SQLite;
the database key and Ed25519 device seed use the operating system credential
store. The public device key is shown as unverified. A device-signed binding
connects that identity to the MLS signing key and is carried in KeyPackages.
This does not establish contact trust or pairing. Linux needs Secret Service
available in the user session. The settings **Rede & P2P** screen separately
shows local Elixir HTTP/WebSocket diagnostics; it does not carry chat traffic.

Character scenes and call views remain visual previews. Camera, microphone,
screen capture, contact discovery, verified pairing, automatic multi-peer
group fan-out,
relay, and offline delivery are not implemented. The older web UI under
`prototypes/web/` is a design benchmark, not the product runtime.

See the [v5 direct peer transport contract](https://github.com/slouching-org/slouching-frontend/blob/main/docs/fichas/transport/lan-peer-v5.md),
the [screen specification](screens.md), and the
[technology plan](../architecture/frontend-tech-stack.md).
