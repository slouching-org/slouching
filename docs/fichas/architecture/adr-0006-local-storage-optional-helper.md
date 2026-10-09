# ADR 0006 — Local storage and optional helper deployment

**Status:** accepted by the owner on 2026-10-09; restores the deployment and
storage decisions recorded in the backup specification.

## Context

ADR 0001 selected local state and direct peer communication. The backup
specification explicitly chose encrypted SQLite per device and made any
crew-operated helper optional. PostgreSQL was an operational option for a
larger helper. Restoring Elixir as the backend in ADR 0005 was incorrectly
interpreted as restoring the original PDF's central storage requirements.
The owner reaffirmed the backup decisions.

## Decision

- Each device owns its identity keys, MLS state, encrypted local history,
  inbox, and outbox. The native client stores the profile, device identity,
  MLS state, per-peer direct history, MLS transcript, and retryable event
  outbox in SQLCipher encrypted SQLite; the random database key and device
  seed use the operating system credential store. A device-signed MLS key
  binding is carried in KeyPackages and checked during group messaging, but
  it does not establish user-verified contact pairing. Delegated inboxes,
  synchronized history, and recovery remain unimplemented.
- Reachable peers must be able to communicate on a LAN without PostgreSQL,
  a hosted service, or an internet route. Direct internet communication
  depends on a permitted reachable route.
- A member may optionally operate a helper on a PC or private VPS for
  ciphertext mailbox storage, discovery, relay, or SFU. A helper may use
  SQLite. PostgreSQL is an optional choice for a larger deployment.
- Elixir/OTP remains the backend implementation direction; Rust/Iced and
  the local cryptography, storage, network, and media components remain on
  the client. Language choice does not make a hosted helper mandatory.
- A helper holds no member's private keys and cannot create MLS Commits or
  decide cryptographic group state. ADR 0002's designated member device
  remains the committer.

## Consequences

The PDF is preserved as source material. Its mandatory central database,
server enrollment, and authoritative server-log assumptions do not override
these decisions. ADR 0005 continues to define the language boundary, with
its deployment interpretation corrected here.

The loopback Elixir/Rust handshake is a development diagnostic, separate from
the implemented pinned-device LAN text and MLS paths. The Elixir helper uses SQLite by default for
local development, with PostgreSQL available through explicit deployment
configuration. Its device-key migration does not establish a required
directory or enrollment service. The backend repository includes a repeatable
SQLite startup smoke check in the integration script. The local profile
database contains the client's profile, history, and outbox; it is not a
delegated mailbox or synchronization service.

Messages wait when no authorized holder can reach the recipient. A helper
receipt proves that a copy was stored, not that the recipient received it.
If every holder loses or discards its copy, availability is not guaranteed.
Release checks must demonstrate local persistence, LAN operation without
PostgreSQL, helper loss, and honest delivery and reachability states.
