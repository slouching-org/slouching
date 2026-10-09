# Recreating the supplied design in Iced

**Status:** first native implementation covers eleven views in the pinned
Iced 0.14.0 client; exact visual parity remains open. The supplied eleven screens,
artwork, and [visual style](../brand/visual-style.md) remain the reference.

## Assets and native components

The scenery, familiars, portraits, and avatars are part of the product's
visual identity. Reuse the supplied JPEG/PNG sources; preserve their subjects,
crops, texture, and palette. Familiar selection must offer the supplied
characters. A character portrait represents a chosen profile or a clearly
labeled sample, not a live camera or verified identity.

Recreate the outlined microphone, camera, screen, headphone, settings,
chat, attachment, and navigation icons from the board. Preserve their
stroke, proportions, and states instead of substituting emoji. The board
HTML embeds resources; icon paths and licenses must be checked before
extracting production vector assets. The native frontend now enables image, SVG, and canvas rendering. Outline
paths were extracted from the original board and normalized for standalone
SVG use; their source provenance remains documented with the assets.

The pair of walking wizards remains the primary pictorial logo. The hat is
the supplied small mark and placeholder under the existing brand decision.

| Design element | Iced implementation route | Remaining work |
| --- | --- | --- |
| Full-window home scenery | Image with aspect-preserving crop beneath native controls | Match wizard and castle positions at reference and compact sizes |
| Avatars and familiars | Supplied raster images in interactive selection cards | Selection, keyboard focus, and accessible labels |
| Panels, cards, inputs, buttons, dividers | Styled native widgets and reusable layout components | Apply exact palette, spacing, borders, and state styles |
| Titles and interface type | Load Bricolage Grotesque and JetBrains Mono font bytes | Verify font files and licenses; tune weight, sizing, and spacing |
| Outline icons | Source vector paths rendered through SVG or a custom drawing widget | Extract/check assets and preserve visual states |
| Scanlines, vignette, grain | Static image layers or custom drawing | Keep input handling and text contrast intact |
| Animated VHS noise or channel offsets | Custom wgpu shader if needed | Implement, profile, and respect reduced motion |
| Group-call stage, filmstrip, roster, chat | Native layout and scrollable components | Recreate geometry; real video needs a separate media/rendering integration |

The original HTML/CSS cannot be consumed as native Iced widgets. Its visual
rules must be translated into layout, styles, assets, and any required
custom rendering. Image fitting and font loading are supported by Iced;
Canvas supports custom 2D drawing and the shader widget supports custom
wgpu rendering. This makes the supplied appearance feasible, but does not
prove exact output or performance before implementation.

## Implementation and visual acceptance

The first implementation now uses `src/ui.rs` for native screens and shared
styles. Original transparent character cutouts and outline SVG paths were
extracted without raster modification. Official font TTFs and their SIL
licenses are bundled. The app provides all eleven views, a screen gallery,
local preview inputs and selection, and a static texture toggle. Capture
via Iced's window API covers 1280 × 800 and a compact 960 × 640 window.
Exact alignment, effects, accessibility, and live media remain open work.

Start with the home screen at 1280 × 800 logical pixels: scenery crop,
wordmark, primary actions, invitation input, and bottom feature strip.
Build reusable tokens and icon controls, then familiar selection and the
call-preview stage. Continue with the remaining eight reference screens.

Capture the actual running Iced app and compare all eleven screens against
the supplied exports. Repeat at a smaller usable window and desktop DPI
settings. Check character placement, icon geometry, typography, hover,
focus, disabled states, and texture contrast. A matching still image does
not validate animation, capture, encrypted chat, or live media. Capability
claims and device controls must follow implemented runtime state.

## Iced documentation checked

- [Image sizing and ContentFit](https://docs.rs/iced/0.14.0/iced/enum.ContentFit.html)
- [Application font loading](https://docs.rs/iced/0.14.0/iced/application/struct.Application.html#method.font)
- [Canvas custom 2D graphics](https://docs.rs/iced/latest/iced/widget/canvas/index.html)
- [Custom wgpu shader widget](https://docs.rs/iced/latest/iced/widget/shader/index.html)

The last two documentation links report Iced 0.14.0 when checked. Verify
those APIs against the pinned crate when implementation begins.
