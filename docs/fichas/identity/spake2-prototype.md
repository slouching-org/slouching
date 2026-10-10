# SPAKE2 pairing foundation (experimental)

**Status:** the experimental Iced identity screen connects the Rust SPAKE2
building block to the optional Elixir rendezvous API. A live-helper test runs
two client roles through signed identity exchange and rejects a mismatched
code. This does not authenticate a human or trust the resulting key
automatically.

## Implemented in the frontend

- Generates a one-time Crockford Base32 code from 100 random bits supplied by
  the operating system CSPRNG. The displayed form is four groups of five
  symbols.
- Runs one symmetric SPAKE2 exchange using the RustCrypto `spake2` crate and
  rejects malformed messages before handing them to the crate.
- Binds a key-confirmation tag and purpose-derived key to both exchanged
  messages and a Slouching-specific protocol context. Application key use is
  only exposed after a matching confirmation tag is supplied.
- Encrypts a transcript-bound Ed25519 device identity proof for rendezvous
  relay and verifies it before exposing the peer key to the identity screen.
- Tests matching and mismatching codes, key confirmation, purpose separation,
  transcript freshness, code parsing, malformed messages, and two clients
  against a live Elixir helper.

Implementation: `repositories/frontend/src/pairing_spake2.rs`.

## Remaining validation before product use

The Iced interface generates and accepts codes, exchanges session messages,
enforces the helper deadline, exposes cancellation, and binds signed device
proofs to the confirmed transcript. It clears local code/session values after
success; the helper expires the session after at most two minutes so either
client can finish fetching the other's proof. Cancellation deletes immediately.
Failed sessions require a new invite. The module does not mark a contact verified. Users must still
authenticate the person and explicitly confirm the peer key or use the signed
QR flow or compare the full device-key fingerprint out of band.

The [Elixir rendezvous API](pairing-rendezvous-v1.md) relays bounded opaque
SPAKE2 messages, permits one attempt per session, expires state, and does not
act as an identity authority. Remaining checks include a manual GUI exchange
on physical devices, helper-loss behavior, and remote HTTPS helper deployment.
The helper's absence must not break QR or direct LAN use.

## Security boundary

The 100-bit code size and one-message-per-side exchange are explicit initial
engineering choices, not a completed protocol review. The selected upstream
crate documents that it has not received an independent security audit. The
crate's password and internal exchange state also do not promise complete
memory zeroization. Do not use this experimental module as a release-grade
contact-pairing guarantee before protocol review, dependency review,
attempt-limit testing, and a physical-device rendezvous test.

See the [upstream crate documentation](https://docs.rs/spake2/0.4.0/spake2/)
and the [identity trust model](identity.md).
