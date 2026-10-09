# Current frontend slice

**Status:** eleven native Rust/Iced screens; the chat screen supports
persistent bidirectional direct-LAN text sessions with manually pinned device
keys and a session-only transcript. MLS and durable messaging remain open.

The frontend's `src/main.rs` owns application state and local transport;
`src/ui.rs` composes the eleven source-board views with native widgets,
original scenery, familiar portraits and cutouts, source-derived SVG icons,
embedded fonts, translucent panels, scanlines, and vignette. The **Telas**
gallery reaches every view. Home actions open the lobby preview; invitation
fields edit in-memory values. Familiar selection, settings and
share-source tabs, and the interface texture toggle work locally. In Chat,
each user manually pins the other's Ed25519 device key. One side starts a
listener; the other enters its LAN address and connects. Both sides can send
multiple messages over that connection. Received text enters the in-memory
transcript before ACK; sent text appears only after ACK. Disconnect with a
pending send is shown as delivery unknown. The
familiar screen saves only the display name and familiar in SQLCipher
encrypted SQLite; its random database key is kept in the operating system
credential store. This profile is distinct from device identity and does not
create message history. A separate explicit action creates an Ed25519 device
signing seed in the system credential store and displays its public key as
unverified. The Rust core can sign a versioned binding from that durable
device key to a separate MLS signing public key. Tampering and a different
device key are rejected. This primitive is not yet connected to an MLS
credential, peer verification, or pairing. An explicit client-core API can
create or reload a distinct MLS signing key for a caller-selected ciphersuite
in the encrypted database and return its device-signed binding. Repeated
calls reuse the key and refuse silent rotation if the indexed key material is
missing. The core can create a one-use OpenMLS KeyPackage with a BasicCredential
containing the device-signed binding; its private bundle is stored in SQLCipher.
No UI flow publishes or consumes the package, and no group is created.
Fingerprint/QR derivation remains unimplemented.

Character scenes and call views remain visual previews. The chat screen now
sends and receives actual pairwise text over direct Iroh/QUIC; it does not use
MLS or persist history. Camera/microphone actions explain their unavailable
state; verification controls cannot verify MLS membership. The app does not
enumerate contacts, join calls, or persist conversation history. The settings
**Rede & P2P** tab exposes
real backend diagnostics separately from the illustrative call routes.

The earlier HTML/CSS/JavaScript preview is retained under
`prototypes/web/` as a **design benchmark**, not the product runtime.
Its familiar name lives in browser local storage only; that is not a
verified device identity. Its call art is illustrative, never a live
camera feed.

The [eleven source screens](../../design/screens) define the visual
target. Native captures were compared at 1280 × 800 and a compact 960 × 640
window. The first visual pass covers all eleven views; exact parity,
accessibility, and permissions still need further implementation and review. See the [Iced design plan](iced-design.md) for
preserving the supplied scenery, characters, avatars, and outline icons.
Encrypted local SQLite now initializes the OpenMLS provider schema alongside
the profile and event journal, but live MLS state, usable inbox/outbox UI, and
durable conversation history remain unimplemented;
the development HTTP/WebSocket diagnostics do not satisfy those requirements.

The chat transport is separate from the Elixir diagnostics. It pins each
device's durable Ed25519 key as its Iroh endpoint identity, disables relays,
and exchanges multiple bounded UTF-8 frames with sequence ACKs over one
bidirectional QUIC stream. ACK means accepted into the peer's in-memory
transcript, not read. This is not an MLS message or a verified contact pairing.
Linux requires Secret Service to store/load the device key. See [LAN text
transport v2](../transport/lan-text-v2.md).

The native UI now requests a v1 development status snapshot from the local
Elixir backend over loopback HTTP using an asynchronous Iced task in the network settings. It shows
connecting, unavailable, incompatible-contract, and responding states; the
user can refresh manually. This only proves local process availability.
The response currently reports unimplemented identity, messaging, and calls
and zero peer connections. It is not an authenticated production boundary
or a live event stream. Functional client-core and server APIs remain open;
see the [technology plan](../architecture/frontend-tech-stack.md).

The UI also performs a binary protobuf WebSocket handshake at `/ws` using
the copied shared v1 schema. It validates the Elixir role and protocol
version, then keeps a development transport open with Ping/Pong heartbeats.
It reports disconnects and retries with bounded backoff. This transport has
no device authentication, application traffic, or messaging.
