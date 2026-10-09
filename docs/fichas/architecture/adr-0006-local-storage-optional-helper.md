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
  inbox, and outbox. The first native persistence slice stores only the
  display name and familiar in SQLCipher encrypted SQLite; its random key is
  kept in the operating system credential store. A separate explicit action
  can create an Ed25519 signing seed in that store. Authentication, pairing,
  product inbox, outbox, history, and MLS state remain unimplemented.
  The Rust core can sign a local binding from that device key to a separate
  MLS signing key, but the binding is not connected to peer verification or
  product credentials.
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

The current loopback Elixir/Rust handshake is a development slice, not the
implemented LAN peer mode. The Elixir helper now uses SQLite by default for
local development, with PostgreSQL available through explicit deployment
configuration. Its device-key migration does not establish a required
directory or enrollment service. The local profile database is not the
product inbox, history, or peer delivery layer.

Messages wait when no authorized holder can reach the recipient. A helper
receipt proves that a copy was stored, not that the recipient received it.
If every holder loses or discards its copy, availability is not guaranteed.
Release checks must demonstrate local persistence, LAN operation without
PostgreSQL, helper loss, and honest delivery and reachability states.
