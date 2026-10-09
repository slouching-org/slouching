# Local storage contract

**Status:** the native client now stores its display name and familiar in
SQLCipher encrypted SQLite, with a random key held in the operating system
credential store. The Ed25519 signing seed is stored separately in that
credential store. The encrypted database now has an initial opaque event
journal schema and storage operations with ID/digest deduplication. The UI,
MLS client state, transport, delivery receipts, and product
inbox/outbox/history are not connected to it. The device identity can now
sign a versioned binding from its long-term Ed25519 public key to a separate
MLS signing public key. Verification of this binding proves only that the
device key authorized that MLS key; it is not peer verification or a product
credential. The client core can create or reload an MLS signature key for a
caller-selected ciphersuite, persist it in this database, and return the
binding. A missing indexed key fails closed instead of silently rotating the
device's MLS signing identity. The client core now creates a one-use OpenMLS
KeyPackage whose BasicCredential contains the device-signed binding. OpenMLS
stores the corresponding private bundle in SQLCipher while the caller receives
only the public bytes. No UI flow publishes or consumes this package, and no
group is created. Opening the database composes OpenMLS RustCrypto with its
SQLite storage provider and initializes the versioned schema on the same
SQLCipher connection. See
[ADR 0006](adr-0006-local-storage-optional-helper.md).
Automated tests reopen a temporary SQLCipher database, check that the OpenMLS
schema remains available, reload an MLS signing key, and validate an exported
KeyPackage plus its device binding while confirming the private bundle was
stored. These tests do not create a product group or messaging flow.

Each device owns its identity, MLS state, conversation history, inbox, and
outbox. SQLCipher is now used for the local display profile; the app generates
a random 32-byte database key and stores it in the operating system credential
store. The OpenMLS provider tables share that encrypted database. The app can
also explicitly create an Ed25519 device signing seed and
store it in a separate credential. User-facing unlock behavior, cross-device
backup, recovery, and using the key to authenticate protocol messages still
require implementation and review. A profile name or avatar is not a
cryptographic identity.

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

The schema stores event ID, author device, group ID, epoch, optional
checkpoint, ciphertext digest, opaque ciphertext, expiry, and an outbound
state. The storage operations reject reused IDs with changed ciphertext or
envelope metadata, list bounded batches, and guard local queued/held/received/
expired/failed transitions. Only trusted protocol code may record a real
receipt; no such transport integration exists yet. Inbox and outbox reads use
bounded pages with a stable local sequence cursor. MLS validation, history
presentation, recovery, and key lifecycle beyond local profile/key creation
remain implementation work. OpenMLS schema initialization does not yet
persist live MLS state. Neither
the web prototype's `localStorage` nor the profile table satisfies these
conversation-storage rules.

## Helper storage and implementation sequence

A helper is optional and may also use SQLite. Postgres is an operational
choice for a larger helper deployment. A directory record does not replace
a device's local identity, prove key ownership, or authorize group membership.
The optional Elixir helper has its own SQLite database by default and may use
PostgreSQL through explicit deployment configuration. That helper database is
not the local client persistence implementation.

The next persistence slice should connect this event journal to local inbox,
outbox, history, and a reviewed event envelope before relying on remote
enrollment or a central inbox. Verify two isolated LAN peers without Postgres
or a hosted helper, then verify optional ciphertext delegation and helper
loss separately.
These are acceptance requirements, not claims that the current scaffold
already supports them.
