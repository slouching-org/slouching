# Local storage contract

**Status:** the native client now stores its display name and familiar in
SQLCipher encrypted SQLite, with a random key held in the operating system
credential store. The Ed25519 signing seed is stored separately in that
credential store. The encrypted database now has an initial opaque event
journal schema and storage operations with ID/digest deduplication. MLS
application encryption and inbound event processing now update OpenMLS state
and the journal transactionally. The MLS screen exposes manual group admission and application-message chat over the active direct peer session.
The device identity can now
sign a versioned binding from its long-term Ed25519 public key to a separate
MLS signing public key. Verification of this binding proves only that the
device key authorized that MLS key; it is not peer verification or a product
credential. The client core can create or reload an MLS signature key for a
caller-selected ciphersuite, persist it in this database, and return the
binding. A missing indexed key fails closed instead of silently rotating the
device's MLS signing identity. The client core now creates a one-use OpenMLS
KeyPackage whose BasicCredential contains the device-signed binding. OpenMLS
stores the corresponding private bundle in SQLCipher while the caller receives
only the public bytes. The setup screen exposes public KeyPackage exchange. The core
also creates and persists a local single-member MLS group and indexes the
creator as designated committer. Member admission validates the device-bound
KeyPackage, enforces the designated committer, merges the Commit locally, and
returns Commit, Welcome, and ratchet-tree bytes. The exact Commit bytes and digest plus a snapshot of predecessor-epoch member devices are stored in the same SQLCipher transaction as the group epoch update. The pending Commit reloads after restart and can be sent to one snapshotted device over the active session; a new invitee is excluded, and a removed device can receive its removal Commit. On each pinned peer connection, the UI automatically drains that device's eligible chain in epoch order, waiting for each durable ACK; a manual send action remains available. The committer can fan out queued Commit batches sequentially to every eligible member with a saved route; each durable ACK advances that peer's queue, and an unavailable peer does not stop the others. A regression test covers ordered per-peer eligibility and retry after database reopen. Each device applies a Commit durably before ACK, which the sender stores per recipient and shows in the MLS screen. Exact redelivery is deduplicated. Offline delivery and concurrent proposal races remain open. Members can send signed self-update proposals to the committer over the pinned session or transfer them manually. The receiver binds the MLS author to the transport peer, verifies the device-bound member credential, journals exact delivery IDs, and ACKs only after durable storage. The committer reviews each proposal individually and can atomically commit only approved proposal references into the normal recipient-snapshotted outbox. Decisions persist in SQLCipher; rejected and pending proposals are excluded, and the remaining OpenMLS queue is consumed on epoch advancement. Existing proposals without saved references default to rejected during schema migration. Other proposal types remain unsupported. Forced outbox and recipient-ledger failures verify group state rolls back atomically. The Welcome and ratchet tree are now stored in an encrypted outbox in the same admission transaction. Reconnecting to the pinned invitee retries the exact bundle until ACK; the invitee writes a content-bound receipt in the same transaction as joining, so a retry after a lost ACK returns the existing group. SQLCipher tests cover outbox persistence after reopen and duplicate Welcome handling. Direct QUIC sessions record the active IP route Iroh reports for the authenticated pinned peer on inbound and outbound sessions. Relay paths stay separate; learned LAN routes can become stale.
Group creation and admission are exposed in the local setup UI. Outbound MLS
application messages are saved as queued ciphertext with the ratchet update and
a snapshot of the current peer devices in one SQLCipher transaction. Each
recipient ACK is stored separately; the global outbox state closes after every
snapshot member accepts the event. The sender can retry to one pinned member or
fan out over saved routes in bounded order after confirming that member has no
pending Commits. Inbound processing authenticates sender and event metadata,
persists ciphertext before releasing plaintext, and deduplicates exact
redelivery alongside the ratchet update. New MLS chat events expire after 30
days. Expired queued events are marked and omitted from fan-out; recipients
reject new expired events before processing MLS ciphertext, and a late ACK
cannot revive an expired event. The UI lists locally stored
groups with their current epoch and quarantine state; opening one reloads its
transcript, pending Commits, and security alert from SQLCipher. Opening the
database composes OpenMLS RustCrypto with its
SQLite storage provider and initializes the versioned schema on the same
SQLCipher connection. See
[ADR 0006](adr-0006-local-storage-optional-helper.md).
Automated tests reopen a temporary SQLCipher database, check that the OpenMLS
schema remains available, reload an MLS signing key, and validate an exported
KeyPackage plus its device binding while confirming the private bundle was
stored. Group tests reload the one-member state and exercise member admission
and Welcome processing across two isolated encrypted databases, including
rejection of a non-designated committer. Two-database application tests cover
queued outbound persistence, authenticated inbound decrypt, deduplication, and
rollback of forged envelopes. Separate-process tests cover opaque MLS event transport, ACK, and unknown delivery on disconnect; the Iced screen presents the local MLS transcript.
The MLS admission test also exercises a three-device chain: it rejects a valid
noncommitter Commit and altered bytes, applies a designated Commit, deduplicates
exact redelivery, and forces an inbound journal failure to verify that group
epoch changes roll back atomically. It also generates two different valid
Commits for the same predecessor from the designated device, applies one,
authenticates the other against a saved OpenMLS snapshot, records both as
equivocation evidence, and verifies quarantine survives database reopen without
changing the accepted epoch. A concurrent exact redelivery and conflicting
Commit over separate SQLite connections preserves that same result. Quarantined groups reject new application events;
the frontend restores the alert and disables sends, retries, member admission,
Commit delivery, and manual application.

Each device owns its identity, MLS state, conversation history, inbox, and
outbox. SQLCipher is now used for the local display profile; the app generates
a random 32-byte database key and stores it in the operating system credential
store. The OpenMLS provider tables share that encrypted database. The app can
also explicitly create an Ed25519 device signing seed and
store it in a separate credential. User-facing unlock behavior, cross-device
backup, recovery, and using the key to authenticate protocol messages still
require implementation and review. A profile name or avatar is not a
cryptographic identity.

The direct-LAN text screen stores sent and received message text in a separate
`local_direct_messages` table in the same SQLCipher database, indexed by the
other device's pinned public key. The receiver writes each inbound message
before sending its transport ACK; the sender writes it after receiving that
ACK. The UI reloads the newest 200 rows for the selected peer and retains at
most 1,000 per peer. This is local
pairwise chat history, not MLS ciphertext, group history, or cross-device
replication. The UI can delete one peer's transcript after explicit
confirmation; a storage test verifies that another peer's history remains.

## Required behavior

- Save an outbound encrypted event locally before attempting delivery.
  Retries preserve its event ID and bytes.
- Persist inbound data before acknowledging durable receipt. Deduplicate
  matching IDs and digests; reject the same ID with different content.
- Distinguish saved locally, held by another peer/helper, received by a
  recipient device, read with consent, expired, and failed.
- Persist MLS state and corresponding outbound Commit bytes atomically
  before distribution. Only the designated member device creates Commits;
  database access gives a helper no such authority.
- Preserve local personal conversation history after leaving a call or
  restarting the application. Temporary call-room chat remains bounded in
  memory and may disappear when all holders leave.
- Apply explicit quotas and expiry to delegated ciphertext copies and
  attachment chunks. A holder's absence or data loss may make them unavailable.

The client now persists a group-bound file offer, content key, author device,
ciphertext digest, and declared size in SQLCipher. Per-profile declared
attachment size is capped at 200 MiB; validated MLS device credentials bind
the offer author to active group membership, and a transaction rechecks the
group epoch before insertion. The v21-to-v22 migration backfills sizes from
existing offers. The encrypted iroh-blobs store remains separately tagged by
transfer ID. Offer storage and blob lifecycle are not yet wired into MLS authorization or a user
send/accept flow, so this is persistence groundwork rather than usable file
sharing. A bounded, versioned text codec can represent the ciphertext hash and
key-bearing offer inside an MLS application payload; the composer does not yet
create or render this payload.

The schema stores event ID, author device, group ID, epoch, optional
checkpoint, ciphertext digest, opaque ciphertext, expiry, and an outbound
state. MLS processing rejects reused IDs with changed ciphertext or envelope
metadata, verifies metadata through MLS authenticated data, and commits ratchet
updates with journal writes. Inbox and outbox reads use bounded pages with a
stable local sequence cursor. The direct pinned peer transport carries MLS
application events; its ACK follows durable receiver processing, and the UI
can retry queued events after reconnecting. QUIC v8 also carries signed
delegated-copy grants and one bounded recipient fetch per connection. Helper
storage ACK follows the local SQLCipher commit; recipient ACK follows MLS
application and transcript persistence. The explicit MLS fan-out action tries
a reachable routed group peer when the target route fails. Helper retention is
best-effort, limited to the holder's quota and expiry; group-wide availability
and read receipts are not implemented. MLS conversation
history, recovery, and key lifecycle beyond local identity creation remain
implementation work. The direct
text transcript table does not satisfy the event journal's encrypted-envelope,
deduplication, expiry, or offline-delivery contract. Neither
the web prototype's `localStorage` nor the profile table satisfies these
conversation-storage rules.

The SQLCipher profile also includes a disabled-by-default delegated MLS-copy
store. An Ed25519 grant from the authenticated event author binds opaque
ciphertext, event digest, group epoch, finite expiry and one recipient device.
The holder enforces a 64 MiB / 4,096-event quota, a 32 KiB item cap and a
30-day maximum TTL; it retains deduplication tombstones and clears ciphertext
after recipient ACK, expiry or the holder disabling consent. Network transfer,
recipient retrieval and fallback helper fan-out from the MLS distribution
action are implemented in QUIC v8; Settings exposes opt-in. End-to-end offline
delivery is best-effort, not guaranteed.

## Helper storage and implementation sequence

A helper is optional and may also use SQLite. Postgres is an operational
choice for a larger helper deployment. A directory record does not replace
a device's local identity, prove key ownership, or authorize group membership.
The optional Elixir helper has its own SQLite database by default and may use
PostgreSQL through explicit deployment configuration. That helper database is
not the local client persistence implementation.

Self-update proposals now travel over the active pinned session and are
persisted before ACK. The committer reviews each current-epoch proposal by
member and proposal ID, then explicitly approves or rejects it. Commits include
only approved references; other proposal types remain open. Commit and
application-message fan-out now use saved pinned routes with per-recipient
durable ACKs. Next, verify multi-member messaging between real app instances on
a LAN without Postgres or a hosted helper, then verify optional ciphertext
delegation and helper loss separately.
These are acceptance requirements, not claims that the current scaffold
already supports them.
