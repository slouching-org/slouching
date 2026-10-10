# SPAKE2 pairing foundation (experimental)

**Status:** the native Rust client contains an isolated, tested cryptographic
building block, and the optional Elixir helper has a volatile rendezvous API.
The Iced client does not connect them yet; this is not a user-facing pairing
flow.

## Implemented in the frontend

- Generates a one-time Crockford Base32 code from 100 random bits supplied by
  the operating system CSPRNG. The displayed form is four groups of five
  symbols.
- Runs one symmetric SPAKE2 exchange using the RustCrypto `spake2` crate and
  rejects malformed messages before handing them to the crate.
- Binds a key-confirmation tag and purpose-derived key to both exchanged
  messages and a Slouching-specific protocol context. Application key use is
  only exposed after a matching confirmation tag is supplied.
- Tests matching and mismatching codes, key confirmation, purpose separation,
  transcript freshness, code parsing, and malformed messages.

Implementation: `repositories/frontend/src/pairing_spake2.rs`.

## Still required before product use

The Iced interface does not generate, transfer, or accept these codes, or call
the rendezvous API. The client has no session expiry, cancellation, retry
state, or identity-key exchange bound to the resulting session. The module
itself does not mark a contact verified. Users must continue to use the signed
QR flow or compare the full device-key fingerprint out of band.

The [Elixir rendezvous API](pairing-rendezvous-v1.md) relays bounded opaque
SPAKE2 messages, permits one attempt per session, expires state, and does not
act as an identity authority. The client must exchange and bind the signed
device identities to the SPAKE2 transcript, require confirmation on both
devices, and leave a clear user confirmation before saving trust. The helper's
absence must not break QR or direct LAN use.

## Security boundary

The 100-bit code size and one-message-per-side exchange are explicit initial
engineering choices, not a completed protocol review. The selected upstream
crate documents that it has not received an independent security audit. The
crate's password and internal exchange state also do not promise complete
memory zeroization. Do not use this experimental module as a release-grade
contact-pairing guarantee before protocol review, dependency review, attempt
limit testing, and a real two-client rendezvous test.

See the [upstream crate documentation](https://docs.rs/spake2/0.4.0/spake2/)
and the [identity trust model](identity.md).
