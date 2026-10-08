# Slouching visual style

**Status:** visual direction approved by the project owner, informed by the
[local source bank](source-bank.md). Use with the
[frontend screen specification](../frontend/screens.md).

## Aesthetic

Slouching evokes **late-1980s / early-1990s VHS fantasy television**: analog
video photography, 4:3 image composition, visible grain, subtle scanlines,
chromatic aberration, tape noise, soft focus, slight color bleed, imperfect
exposure, crushed blacks, dreamy highlights, and occasional tracking artifacts.
The result should feel melancholic, mysterious, cozy, lonely, a little absurd,
quiet, nostalgic, surreal, and strangely comforting.

This is an art direction for imagery and interface treatment, not a command to
blur live controls or falsify video quality. Keep names, button labels, status,
and security information legible. Make the `Filtro VHS na minha câmera` setting
explicit and optional for transmitted live camera video. A local visual overlay
must not change the actual connection, encryption, or capture state.

### Image and light

- Prefer dim moonlight, haze and atmospheric fog, deep shadows, and very little
  frontal/direct illumination. Warm practical lights (lanterns, windows, orb)
  appear sparingly.
- Preserve analog flaws already present in the supplied JPEGs. Added grain,
  channel offset, scanlines, vignette, and tracking noise should remain subtle
  and reproducible. Avoid stacking strong filters until faces, text, or controls
  become unclear.
- Compose image content in a nostalgic **4:3 photographic frame** when the
  source or feature calls for it. The supplied app screens themselves are
  **1280 × 800 CSS pixels (16:10)**; do not force the whole application into
  4:3 or stretch 4:3 media to fill a different ratio.
- Use the actual bank: `bg-home.jpg` for the home landscape,
  `scene-reading.jpg` for reading/lobby preview,
  `scene-orb.jpg` for the orb scene, character scene JPEGs for sample states,
  and their matching avatars where the design shows them. Use real capture in
  functioning call tiles. Sample scene imagery must never masquerade as a
  participant's live camera.

## Color system

Screen `00` defines these source tokens. They are the reference values; small
display/profile differences in the exported PNGs are expected.

| Token in board | Hex | Role |
| --- | --- | --- |
| Noite | `#0D0A1C` | Deep background / crushed black |
| Painel | `#1A1638` | Translucent dark panels |
| Linha | `#2F2858` | Fine borders and dividers |
| Pergaminho | `#ECE6FF` | Main text / pale lavender cream |
| Lanterna | `#F2DF8A` | Warm primary action and highlight |
| Feitiço | `#B48CFF` | Violet secondary accent |
| Musgo · online | `#8FD19E` | Connected/success state |
| Amanita · sair | `#6E2148` | Leave/destructive control |

The imagery adds midnight blue, deep navy, indigo, dark violet, muted lavender,
cold blue-green shadows, and occasional muted pink/magenta clouds. Do not
replace them with flat modern neon or clean digital gradients. Keep yellow
rare enough that a primary action remains prominent. Never use color alone to
communicate security, mute, sharing, or connection state.

## Type and UI texture

- **Bricolage Grotesque 800**: logo wordmark and large screen titles, following
  the identity board.
- **JetBrains Mono 400/500/700**: interface copy, values, controls, and
  spaced-uppercase micro-labels. Keep the real Portuguese/English mixed copy
  shown in the source where it is deliberate; translation strategy can be
  finalized separately.
- Source board calls for scanlines **1 px every 3 px**, dark vignette, mild
  chromatic aberration on titles, nearly square corners (**0–4 px radius**),
  **1 px `#2F2858`** borders, and translucent panels over scenery.
- Controls should retain clean hit areas and predictable hover/focus/pressed
  states. If an overlay changes perceived text contrast, reduce it locally.
  Reduced-motion mode removes animated tracking/glitch effects.

## Brand roles

The pair of wizards walking together in
[the owner-provided logo reference](../../design/references/05-two-wizards-primary-logo.png)
is the **primary pictorial logo**. The lowercase `slouching` typography is the
wordmark. The hat in `appicon.jpg` and the earlier hat sheet is a placeholder
in design screens and the intended favicon/small icon. The source identity
board labels its walking pair as `Os Magos · ícone / splash`; the owner's
later clarification takes precedence for final brand hierarchy.

The walking-wizards reference has a photographic background, and the hat PNGs
are opaque. Preserve these originals. A production transparent/isolated logo
asset must be prepared separately from suitable source material. Its exact
lockup, minimum size, and placement in app chrome await the full application
frontend; do not silently promote the hat to the finished primary logo.

## Visual acceptance

Compare actual running UI captures against **all eleven** numbered PNGs at
1280 × 800 logical size, plus at least one smaller window. Check background
crop, subject positions, panel proportions, typography, palette, texture,
avatar selection, button states, and layout hierarchy. A static screenshot
alone does not demonstrate working capture, P2P networking, MLS verification,
or call controls. Runtime values must be sourced from the client core rather
than copied from the mock screens.
