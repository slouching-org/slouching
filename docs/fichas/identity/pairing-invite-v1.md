# Signed peer invitation QR v1

The desktop client can display and import a short-lived QR invitation for a
device identity. It carries no private key, profile name, message, MLS secret,
or relay token. When a listener is active, it also carries that listener's
selected IP socket addresses so the inviter can choose a LAN or VPN route.

## Encoding

The QR text is `slouching-invite-v1:` followed by lowercase hexadecimal bytes.
The signed bytes are, in order:

1. Eight-byte magic `SLOUCH01`.
2. Issued-at Unix timestamp as unsigned 64-bit big-endian seconds.
3. The 32-byte Iroh/Ed25519 device public key.
4. Address count as one byte, limited to eight.
5. Each address: family byte (`4` or `6`), raw IP octets, then UDP port as
   unsigned 16-bit big-endian.
6. Ed25519 signature (64 bytes) over items 1–5 using the device identity key.

The importer accepts one QR from a PNG image no larger than 8 MiB or 4096 by
4096 pixels. It bounds the text before decoding and rejects unsupported
versions, malformed addresses, invalid signatures, and timestamps older than
10 minutes or more than 60 seconds in the future. Unspecified, loopback,
multicast, scoped IPv6, and zero-port socket addresses are excluded. A QR with
no addresses is a valid identity-only invitation.

## Trust boundary

The signature proves that the device key signed the included address list. It
does not prove that the device belongs to a particular person, nor that an
image came from the intended contact. Importing a QR fills the peer key and
offers its addresses, but does not silently mark that peer verified. A user
may mark the exact key verified after importing a QR shown directly by the
intended contact or after comparing the key through another trusted channel.
Changing the key clears any address choices from that invitation.

The current desktop importer reads PNG files; live camera scanning, QR
rendezvous, contact discovery, key recovery, and short verification codes are
outside this slice. The binary format and trust flow still require security
review before public release.
