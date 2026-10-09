# Slouching frontend specification

**Status:** design and interaction specification; the Rust/Iced client has eleven screens, including direct-LAN text sessions with manually pinned device keys and per-peer SQLCipher history. Direct MLS group chat over the pinned LAN session is implemented after manual group provisioning; synchronized history and broader product flows remain open.
**Revision:** 0.4, 2026-10-09; reconciled with ADRs 0003–0006
**Sources:** the [11-screen design bank](../brand/source-bank.md), [five earlier references](../brand/references.md), [visual style](../brand/visual-style.md), and [Rust-client/Elixir-backend decision](../architecture/adr-0005-elixir-server-core.md).

## 1. Authority and scope

The bundled `slouching-telas.html` and its PNG exports are a **static design board**, not evidence that controls, video, or cryptography work. The 11 screens establish structure, copy, palette, type, component style, and artwork. The five earlier references add compact home/call compositions. The owner's correction is authoritative: **two wizards walking side by side are the primary pictorial logo**; the hat is a temporary screen mark and favicon/small icon. The complete frontend the owner will provide may settle implementation details; deliberate changes should be recorded against these references.

Each board page is 1280 × 800 CSS pixels, exported at 2560 × 1600. Treat this as the principal comparison viewport, not a fixed window size. Earlier composite reference 01 adds compact targets around 756 × 800 for home and 795 × 498 for call. Its outer labels and comparison canvas are not app chrome.

Build real components in the [Rust/Iced frontend](https://github.com/slouching-org/slouching-frontend) using the original scene and avatar JPEGs in [design/source](../../design/source); do not paste screen PNGs into the application. Follow the [visual style ficha](../brand/visual-style.md): nostalgic VHS fantasy imagery, restrained analog texture, exact board palette, Bricolage Grotesque and JetBrains Mono, dim moonlight and sparse warm highlights. The app viewport stays responsive; the 4:3 photographic direction does not force a 4:3 window.

## 2. Screen map and behavior

| Screen | Visual role | Required behavior |
| --- | --- | --- |
| [00 · Identity and components](../../design/screens/00-identity-components.png) | Color, type, marks, cards, controls, status pills and sample characters | Implement reusable tokens and components. Apply the owner's logo correction. Runtime badges such as P2P direct, SFU relay and MLS epoch must be truthful. |
| [01 · Onboarding and familiar](../../design/screens/01-onboarding-familiar.png) | “Quem senta na fogueira?”, name, familiar selection, fingerprint | Create a local device identity with no required account or email. Offer supplied familiars or a custom image. Show where the key stays and a verifiable fingerprint. Resume interrupted setup safely; do not claim completion before the key is durable. |
| [02 · Settings](../../design/screens/02-settings-audio-video-network.png) | Profile, audio/video, network/P2P, keys/MLS, devices, notifications, appearance, shortcuts | Show real device selectors, mic meter, capture permission, suppression, echo cancellation, push to talk, optional VHS camera filter, IP privacy and relay policy. Report actual STUN/TURN/SFU setup. The visual six-peer mesh threshold is a design example until measured. |
| [03 · Pre-join lobby](../../design/screens/03-lobby.png) | Local preview, room summary, participants, invite link, Join | Show real mic/camera state; enter-muted applies before media starts. Parse and validate the invite; show authenticated group/call identity and terms before joining. An invitation carrying key material is a bearer secret: avoid leaking it to logs, previews, or an unauthenticated flow. |
| [04 · Connecting and fallback](../../design/screens/04-connecting-fallback.png) | “Acendendo a fogueira...”, route progress and retry | Distinguish discovery, authentication, direct ICE/QUIC, TURN relay, SFU and unreachable. Offer only crew-authorized routes. TURN and SFU have different roles. Show measured values and actual failures; mock milliseconds are not production data. |
| [05 · Screen-share picker](../../design/screens/05-screen-share-picker.png) | Screen/window/extra-camera tabs, source previews and quality options | Enumerate OS-permitted sources. Show source, capture permission, system-audio availability, text/motion optimization and bandwidth estimate with uncertainty. Starting share needs explicit confirmation and a persistent in-call sharing indicator. Stop if permission is revoked. |
| [06 · Personal P2P chat](../../design/screens/06-personal-chat.png) | Conversation rail, messages, attachments, presence, call actions | Send encrypted text, media, audio and files via the peer core. Distinguish local, held by peer, received, read, expired and failed receipts. Online presence is not proof of a direct route. Surface identity changes. “No cloud” copy is conditional when a helper stores ciphertext. |
| [07 · Incoming call](../../design/screens/07-incoming-call.png) | Caller portrait, voice/video accept, reject, quick reply, compact notification | Authenticate the caller and invitation before claiming verified/P2P status. Respect privacy settings in notifications. Accept voice/video only with working devices and permissions; reject without joining. |
| [08 · MLS seal verification](../../design/screens/08-verify-mls-seal.png) | Six words/QR, fingerprint, epoch, cipher and peer devices | Derive comparisons from actual authenticated identities and group state; specify the exact derivation before release. Mark verified/new/changed devices distinctly; mismatches cannot be marked verified. Explain the need for an independent comparison channel. Epoch belongs here as advanced security data, not decorative copy. |
| [09 · Home](../../design/screens/09-home.png) | `bg-home.jpg` scene, central wordmark/actions and feature strip | Join opens/focuses invite entry. Create persists a call group and designated committer before sharing an invite. Preserve wizards and castle in the crop. Revise/qualify “P2P / No servers” if a crew-owned helper or relay is used. |
| [10 · Group call](../../design/screens/10-group-call.png) | Stage, filmstrip, roster, campfire chat, Invite, toolbar and route badge | Show real participant media and actual mute/camera/share state. Character scenes are mock/sample art, never fake live feeds. Room chat follows temporary retention. Badge reflects direct mesh, authorized relay or SFU with real measurements only. |

The numbering follows the exported design board, not a forced journey. Common paths are onboarding → home → invite/lobby → connecting → call; home → create → lobby/call; home → personal chat → incoming/outgoing call. Settings and verification are reachable where relevant. The static board does not settle every dialog, focus order, navigation transition or compact layout.

## 3. Shared rules

### Brand and visual assets

- [The two walking wizards](../../design/references/05-two-wizards-primary-logo.png) are the primary pictorial logo; lowercase `slouching` is the wordmark. The reference PNG has an opaque background, so prepare a separate production asset before placing it as a transparent mark. Preserve originals.
- [The hat sheet](../../design/references/02-hat-marks.png) and `appicon.jpg` can serve as favicon, small icon or provisional camera-off/familiar placeholder. Never promote the hat to the final primary logo.
- Use `bg-home.jpg` for home, `scene-orb.jpg` for the group-call concept, `scene-reading.jpg` for reading/lobby atmosphere, and matching character scenes/avatars where the board shows them. Avatar art is not proof of a real participant or active camera.

### Runtime truth and trust

- Derive transport badges from the peer core: direct, participant-operated TURN/relay, participant-operated SFU, or disconnected. A relay route is not “P2P direct.” Identify an enabled VPS helper accurately.
- Source counts, latency, bandwidth, encryption state, fingerprints, epochs, presence and capture state from the runtime. Mock values appear only in an explicitly labeled design/demo mode.
- Direct LAN use has no required third-party server. Across restrictive networks, a participant-owned public endpoint or relay may be required. If no approved route works, show unreachable and allow retry or manual endpoint exchange.
- An invitation does not automatically establish trust. Show its group, call and verified identities. Distinguish invalid, expired, revoked, already-used and untrusted invites where protocol evidence permits.
- The designated MLS committer is a specific member device. Changes may queue while it is away. A removal or suspected compromise pauses protected sending until a valid new epoch is adopted. Permanent committer loss requires an explicit new group; never silently elect a replacement.
- Onboarding and local conversation use require no PostgreSQL setup or mandatory remote enrollment. Local profile choices remain distinct from device identity.
- Persistent personal chat and temporary call-room chat have different retention. Leaving a call must not erase a persistent conversation. Room chat may vanish after all in-memory holders leave.

### Capture and media

- Microphone, camera, speaker and screen controls follow OS permissions and actual capture/track states. A camera-off tile is a labeled placeholder; stale frames never masquerade as live video.
- Call media keys belong to the separate call MLS group. A conversation member who never joined cannot derive media keys. If the call committer is unavailable, new membership changes pause visibly.
- The VHS camera filter is explicitly optional. Static interface texture must leave controls, names and security details legible.
- Sharing has an unmistakable ongoing indicator and a reachable Stop action, including when the picker closes and where the platform permits it.

## 4. Exceptional states

| Situation | User-visible treatment |
| --- | --- |
| Identity missing, changed or unverified | Setup/verification path; do not assert an authenticated peer |
| Unknown identity in invitation | Display identity and verification choices before join |
| Direct route fails without approved fallback | Explain reachability; retry or manual endpoint exchange |
| Crew helper disappears | Show degraded reachability/storage; preserve existing direct links |
| Device or OS capture permission denied | Name affected source; preserve text or audio-only use where possible |
| Media reconnects, changes topology or loses SFU | Show transition and actual route; no fake live tile |
| Stored ciphertext is unavailable or expires | Show last known receipt and unconfirmed final delivery |
| MLS proposal waits for committer | Show pending change and current valid membership |
| MLS fork/checkpoint mismatch or compromise | Quarantine affected group and explain recovery path |
| Temporary room history vanishes | Explain retention rather than imply a sync failure |

## 5. Accessibility and implementation boundary

Make every control keyboard-operable, with visible focus, screen-reader names for icons, discoverable shortcuts and non-color status cues. Keep text readable over dark art. Respect reduced motion; animated scanlines or glitches must not intercept input. On smaller windows, keep Join, Leave, security warnings and Stop sharing reachable; collapse side panels before shrinking text or stage tiles beyond usefulness. Respect platform capture permissions, notifications, DPI scaling and font fallback. On a large desktop, the default window should remain deliberate and compact.

The view sends intents and renders authoritative state. Key custody, MLS cryptography, capture, and direct peer transport belong to the Rust client core; Elixir supplies backend services for optional helper delivery, directory, and group-call coordination. Local history, inbox, and outbox use encrypted SQLite; PostgreSQL and hosted helpers are optional under [ADR 0006](../architecture/adr-0006-local-storage-optional-helper.md). Rust/Iced is the accepted product client under [ADR 0003](../architecture/adr-0003-rust-iced-client.md). The [Iced design plan](iced-design.md) maps the supplied characters, icons, scenery, and effects to native components. Implementing screens is distinct from passing the [product verification gates](../architecture/backend.md#9-verification-gates).

## 6. Acceptance and pending inputs

Compare running captures against **all eleven** screens at 1280 × 800 logical pixels and one smaller practical window. Inspect scene crop, subject positions, palette, type, panel geometry, labels, texture, focus/hover/disabled states, and wizard-pair/hat roles. Review the earlier compact home/call composite separately. Keep supplied originals byte-for-byte unchanged and trace derived assets to them.

For behavior acceptance, run at least two clean peers through identity setup and verification, invitation, direct connection, encrypted chat, call join/leave, permission denial, route failure and screen sharing. Test an authorized helper path separately. A seeded screenshot serves visual review, not proof of functioning P2P, MLS or media.

Pending: licensed font/icon files or approved package sources, production logo exports if available, exact navigation and localization decisions, animation preferences and platform-specific capture behavior. Mock protocol values and security copy require review before release. The current [native scaffold](current-slice.md) has eleven screens; Chat supports persistent direct-LAN text sessions with manually pinned device keys, while the remaining product behavior and full acceptance flow are open.
