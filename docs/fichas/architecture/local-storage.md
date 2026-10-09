# Local storage contract

**Status:** the native client now stores its display name and familiar in
SQLCipher encrypted SQLite, with a random key held in the operating system
credential store. The Ed25519 signing seed is stored separately in that
credential store. Inbox, outbox, conversation history, and MLS state remain
unimplemented. See [ADR 0006](adr-0006-local-storage-optional-helper.md).

Each device owns its identity, MLS state, conversation history, inbox, and
outbox. SQLCipher is now used for the local display profile; the app generates
a random 32-byte database key and stores it in the operating system credential
store. The app can also explicitly create an Ed25519 device signing seed and
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

The event envelope, history schema, transaction boundaries, recovery, and
key lifecycle beyond local profile/key creation remains implementation work. Neither
the web prototype's `localStorage` nor the profile table satisfies these
conversation-storage rules.

## Helper storage and implementation sequence

A helper is optional and may also use SQLite. Postgres is an operational
choice for a larger helper deployment. A directory record does not replace
a device's local identity, prove key ownership, or authorize group membership.
The experimental PostgreSQL table already in the backend is not the local
persistence implementation.

The next persistence slice should add the local inbox/outbox and history to
the encrypted store and define their event envelope and recovery behavior
before relying on remote enrollment or a central inbox. Verify two isolated LAN peers without Postgres or a hosted helper,
then verify optional ciphertext delegation and helper loss separately.
These are acceptance requirements, not claims that the current scaffold
already supports them.
