# Local storage contract

**Status:** product requirements restored from the backup specification;
local persistence is not implemented. See [ADR 0006](adr-0006-local-storage-optional-helper.md).

Each device owns its identity, MLS state, conversation history, inbox, and
outbox. The persistence plan uses encrypted SQLite, with SQLCipher as the
planned integration. The database encryption key must remain under device
control; its generation, OS protection, unlocking, backup, and recovery
still require explicit implementation and review. A profile name or avatar
is not a cryptographic identity.

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

The schema, migration strategy, event envelope, transaction boundaries,
and key lifecycle remain implementation work. Neither the web prototype's
`localStorage` nor the native UI's in-memory profile satisfies these rules.

## Helper storage and implementation sequence

A helper is optional and may also use SQLite. Postgres is an operational
choice for a larger helper deployment. A directory record does not replace
a device's local identity, prove key ownership, or authorize group membership.
The experimental PostgreSQL table already in the backend is not the local
persistence implementation.

The next persistence slice should establish device-controlled storage and
restart/crash behavior before relying on remote enrollment or a central
inbox. Verify two isolated LAN peers without Postgres or a hosted helper,
then verify optional ciphertext delegation and helper loss separately.
These are acceptance requirements, not claims that the current scaffold
already supports them.
