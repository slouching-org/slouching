# Slouching — Design Reference

> **Historical eight-screen guide.** For the current eleven-screen source bank,
> use the [frontend specification](../docs/fichas/frontend/screens.md) and
> [visual style ficha](../docs/fichas/brand/visual-style.md). Transport and
> security labels in this older guide are visual examples, not runtime claims.

> Visual and UX reference for implementing the **slouching** P2P voice/video application.
>
> Source: `slouching-screens.pdf` (8 screen references).
>
> **Important:** This document describes the intended visual language and UI patterns shown in the reference screens. When implementing new screens, preserve the same visual system rather than introducing a generic modern SaaS aesthetic.

---

## 1. Product identity

**Name:** slouching

**Product:** P2P voice & video communication for small private groups.

Core positioning shown in the reference:

- P2P / direct connection
- Private / end-to-end
- For your crew
- Voice, video and screen sharing
- No-server / direct-first feeling
- Informal, nostalgic, slightly mystical atmosphere

The product combines a **late-80s / early-90s VHS fantasy aesthetic** with a functional desktop communication UI.

The mood should feel:

- nostalgic
- mysterious
- cozy
- slightly weird
- magical
- private / intimate
- low-tech in appearance, but technically capable underneath

Avoid making it look like a conventional Discord, Slack, Zoom, Teams, or modern glassmorphism dashboard.

---

## 2. Visual direction

### Overall aesthetic

The interface looks like an old fantasy computer application recorded through VHS equipment.

Use:

- dark navy / indigo backgrounds
- muted purple panels
- warm pale-yellow highlights
- magenta/pink destructive or secondary actions
- low-contrast borders
- subtle glow
- CRT/VHS artifacts
- scanlines
- chromatic aberration
- film/tape noise
- slightly softened imagery
- imperfect exposure
- occasional image bleeding
- pixel/bitmap-inspired typography details

The UI should feel **designed**, not randomly degraded. VHS effects are atmospheric layers, not a replacement for usability.

### Backgrounds

Screens generally use a full-screen fantasy photograph or video still behind the UI.

Typical imagery:

- dark blue night sky
- mountains / forests / castles
- wizards, frogs, gnomes or fantasy characters
- campfires and warm light
- mist and clouds

Overlay the UI with a dark translucent navy layer so text remains readable.

### Image treatment

Reference imagery intentionally has:

- low-resolution / VHS softness
- horizontal scanlines
- slight RGB separation
- crushed shadows
- saturated blues/purples
- warm yellow/orange light sources
- subtle noise/grain

Do not use pristine photographic images without processing.

---

## 3. Reference palette

These are **visual reference values**, not guaranteed source design tokens. If exact existing CSS tokens are discovered in the implementation, prefer those.

| Role | Approx. color | Usage |
|---|---|---|
| Deep navy | `#080B28` | Main application background |
| Midnight blue | `#0D1238` | Large background surfaces |
| Indigo | `#17144A` | Cards / panels |
| Purple | `#33206A` | Selected states / secondary surfaces |
| Violet | `#5140A0` | Accents and active UI |
| Warm yellow | `#F5DF73` | Primary actions / important highlights |
| Pale yellow | `#FFF0A0` | Highlighted text |
| Magenta | `#A92B67` | Destructive / leave / decline actions |
| Soft lavender | `#B7AED2` | Secondary text |
| Off-white | `#E8E3D7` | Primary text |
| Muted text | `#77738E` | Metadata / timestamps |
| Green | `#79C98B` | Connected / verified / positive status |

### Color hierarchy

**Primary action:** warm yellow.

Examples:
- Join a Call
- Create a Call
- Enter the room
- Share screen
- Accept video call

**Danger / leave:** magenta.

Examples:
- Leave
- Decline
- Cancel
- Stop watching

**Informational / selected:** violet / purple.

**Connection status:** muted green or small colored status dot.

---

## 4. Typography

Typography is one of the strongest parts of the visual identity.

Use a combination of:

1. **Bold rounded/display sans** for major headings.
2. **Monospace / terminal-like type** for metadata, status, timestamps and technical information.

### Headings

Large headings are:

- bold
- warm yellow
- slightly soft/glowing
- compact
- highly legible

Examples from the screens:

- `slouching`
- `Mara está batendo`
- `Chamando Mara...`
- `O que você quer mostrar à roda?`
- `the-mossy-stump`

### Technical / metadata text

Prefer monospace or terminal-inspired typography for:

- P2P status
- latency
- timestamps
- call duration
- room information
- file sizes
- connection state
- small labels
- chat timestamps

Examples:

`P2P direct · 3 peers · 38 ms`

`SP 00:42:17`

`412 MB · 64% · 18 MB/s`

### Text hierarchy

Use approximately:

- Display: 40–64px
- Page/modal heading: 24–32px
- Section title: 14–18px
- Body: 13–16px
- Metadata: 10–13px
- Tiny technical labels: 9–11px

Do not make every piece of text monospace.

---

## 5. Borders, panels and surfaces

Panels are dark and translucent rather than bright solid cards.

Typical treatment:

```css
background: rgba(12, 10, 45, 0.72);
border: 1px solid rgba(140, 120, 210, 0.25);
```

Use thin borders.

Avoid:

- heavy rounded cards
- huge drop shadows
- excessive blur
- white backgrounds
- generic glassmorphism
- excessive border radius

Corners are generally subtle / slightly squared.

A small amount of glow around important elements is acceptable.

---

## 6. Buttons

Buttons are visually important and relatively rectangular.

### Primary

Warm yellow background with dark text.

```text
┌───────────────────────────┐
│      Join a Call          │
└───────────────────────────┘
```

Use for the primary action.

### Secondary

Dark navy/purple surface with a thin border.

### Destructive

Magenta/pink background.

Examples:

- Leave
- Decline
- Cancel
- Stop watching

### Icon buttons

Small square controls are used for:

- microphone
- camera
- screen sharing
- fullscreen
- security
- call controls

They should visually belong to the same system as larger buttons.

---

## 7. VHS / CRT effects

These effects should be implemented as reusable visual layers.

### Scanlines

Very subtle horizontal lines over imagery and, optionally, the whole application.

### Noise

Fine-grained film/VHS noise with low opacity.

### Chromatic aberration

Small red/blue channel offsets around high-contrast areas.

### Bloom / glow

Warm yellow highlights can glow slightly.

### Image degradation

Background/video content can have:

- slight blur
- reduced sharpness
- color bleeding
- mild distortion

### Important implementation rule

Do **not** apply aggressive VHS effects to every text/control element.

The reference remains readable. Effects are strongest on imagery and ambient layers.

---

# 8. Screen-by-screen reference

## Screen 01 — Landing / home

Reference: `screens/screen-01.png`

The landing page is a full-screen fantasy background with a centered product introduction.

Main content:

- slouching logo/title
- `P2P voice & video`
- `for you and your crew`
- primary `Join a Call`
- secondary `Create a Call`
- invite-link input
- bottom feature strip

Feature strip communicates:

- P2P — No servers
- Private — End-to-end
- For your crew — Voice, video, screen
- Just vibes — Always

### Layout

The central content is vertically centered.

The bottom feature strip spans most of the viewport width and uses a translucent dark panel.

### Design principle

The home page should immediately communicate **what slouching is** and provide two obvious entry points:

1. Join
2. Create

---

## Screen 02 — Group call / room

Reference: `screens/screen-02.png`

Room name:

`the-mossy-stump`

Top bar communicates:

`P2P direct · 3 peers · 38 ms`

Main layout:

- large video area
- participant thumbnails along the bottom
- participant/room status panel on the right
- session chat on the right
- call controls at the bottom

Participant states are explicitly visible:

- sharing
- talking
- muted
- here
- camera off

### Important pattern

The participant state should be communicated with small textual labels and subtle color differences rather than relying only on icons.

### Right sidebar

Contains:

1. participants
2. chat
3. message composer

This structure should remain consistent across collaborative/call screens.

---

## Screen 03 — Direct chat

Reference: `screens/screen-03.png`

This is a private conversation UI.

Left side:

- navigation rail
- conversation list
- search
- online/offline indicators
- unread counters

Main area:

- conversation header
- security / connection status
- message timeline
- image/video messages
- audio message
- direct file transfer
- typing state
- composer

The visual language remains dark navy/purple.

### Important product concept

The UI emphasizes direct transfer:

`arquivo vai direto pro dispositivo ... sem nuvem`

This reinforces the product's P2P/privacy identity.

### Message styling

Incoming and outgoing messages are visually differentiated.

Outgoing messages use purple/violet surfaces.

Attachments are displayed as integrated cards, not generic browser previews.

---

## Screen 04 — Incoming video call

Reference: `screens/screen-04.png`

A full-screen call invitation.

Centered:

- caller avatar
- subtle concentric rings
- small status label
- large caller name
- connection/security metadata
- action buttons

Actions:

- Decline — magenta
- Voice only — dark secondary
- Accept with video — yellow primary

A secondary notification variant is shown in the bottom-right for when the application is minimized.

### Interaction principle

The primary action must be visually obvious.

The user should understand:

- who is calling
- whether the connection is verified/direct
- what happens when each action is selected

---

## Screen 05 — Outgoing call / connecting

Reference: `screens/screen-05.png`

Centered state:

`Chamando Mara...`

Supporting text:

`P2P · procurando caminho direto · aguardando atender`

Controls:

- microphone
- camera
- cancel

A small local camera preview appears in the bottom-left.

### Important

The connecting state is intentionally calm and sparse.

Do not add a spinner-heavy modern loading UI.

The concentric ring treatment around the avatar is part of the visual language.

---

## Screen 06 — Screen sharing selection modal

Reference: `screens/screen-06.png`

Centered modal over the dark fantasy background.

Title:

`O que você quer mostrar à roda?`

Description:

`Vai direto para os 3 magos da chamada, cifrado.`

Tabs/categories:

- Telas
- Janelas
- Câmera extra

Content is presented as selectable preview tiles.

Options include:

- display 1
- display 2
- individual window

Additional settings:

- system audio
- quality
- optimization target

Quality examples:

- 720p30
- 1080p30
- 1080p60

Optimization:

- Texto nítido
- Movimento

Bottom area contains:

- estimated upload
- P2P status
- Cancel
- primary share action

### Modal design

This is a dense functional UI, but it still follows the visual system:

- dark panel
- thin purple borders
- yellow selected state
- monospace metadata
- yellow primary action

---

## Screen 07 — Watching a shared screen

Reference: `screens/screen-07.png`

Large shared-content viewport with right sidebar.

Top status:

`AO VIVO`

and:

`18 ms`

Right sidebar:

- participants
- transmitting / watching states
- session chat

Bottom controls:

- volume
- quality
- fullscreen
- stop watching

Global call controls remain at the bottom.

### Important

Shared content should dominate the viewport.

The surrounding UI should stay visually quiet.

---

## Screen 08 — Join room / identity selection

Reference: `screens/screen-08.png`

Two-column composition.

Left:

- live camera preview
- preview label
- bottom camera/mic controls

Right:

- `ENTRANDO NA FOGUEIRA`
- room name
- avatar selection
- avatar category filters
- display name
- muted toggle
- primary join button

Avatar categories:

- Todos
- Gnomos
- Sapos
- Magos

### Product personality

This is an important playful moment.

The avatar selection reinforces the identity of the product and should not feel like a generic profile form.

---

# 9. Reusable components

Build the visual system around reusable primitives.

Suggested component vocabulary:

```text
SlouchingShell
BackgroundAtmosphere
VhsOverlay
Scanlines
NoiseOverlay

Logo
StatusPill
ConnectionStatus
LatencyIndicator

Button
PrimaryButton
SecondaryButton
DangerButton
IconButton

Panel
PanelHeader
PanelFooter

Avatar
AvatarPicker
Participant
ParticipantList

VideoTile
VideoGrid
CameraPreview

Chat
ChatMessage
ChatComposer
AttachmentCard
AudioMessage
FileTransferCard
TypingIndicator

CallControls
IncomingCall
OutgoingCall
CallStatus

Modal
Tabs
SelectableTile
Toggle
SegmentedControl

RoomHeader
RoomSidebar
SessionChat
ScreenSharePicker
ScreenShareViewer
JoinRoomForm
```

---

# 10. Interaction states

Every interactive component should have deliberate states.

### Button states

- default
- hover
- active/pressed
- focused
- disabled

### Connection states

- connecting
- connected
- degraded
- disconnected
- verified

### Participant states

- idle
- talking
- muted
- camera off
- sharing
- reconnecting

### Call states

- incoming
- outgoing
- connecting
- connected
- ended
- declined

### File transfer states

- queued
- transferring
- paused
- completed
- failed

---

# 11. Iconography

Icons should be simple and functional.

Common icons:

- microphone
- microphone muted
- camera
- camera off
- screen
- phone
- video
- lock
- users
- lightning/P2P
- paperclip
- send
- play
- pause
- fullscreen
- close
- settings/security

Prefer thin or medium-weight icons.

Icons should generally be pale yellow, lavender, or off-white depending on context.

Avoid highly colorful icon sets.

---

# 12. Layout principles

### Desktop-first

The references are desktop application screens.

Use:

- generous viewport usage
- fixed sidebars where appropriate
- large video/content regions
- compact utility controls

### Spacing

Use a consistent spacing scale, approximately:

```text
4
8
12
16
24
32
48
64
```

### Borders

Prefer 1px borders with low-opacity violet/blue.

### Radius

Keep radius small.

Suggested:

```text
0–4px
```

Some controls may use slightly larger rounding, but the overall product is not heavily rounded.

---

# 13. Accessibility

The visual style must not compromise usability.

Maintain:

- readable contrast
- visible keyboard focus
- clear hover/active states
- labels for icon-only controls
- non-color indicators for important states
- sufficiently large click targets
- captions / text alternatives where appropriate

VHS effects must never make important text unreadable.

---

# 14. Design rules for new screens

When creating a screen that is not present in the references:

### DO

- Start from the deep navy/indigo foundation.
- Use fantasy/VHS imagery when an atmospheric background is appropriate.
- Use warm yellow for the primary action.
- Use magenta for destructive actions.
- Use monospace for technical metadata.
- Use thin purple borders.
- Keep UI compact and slightly retro.
- Preserve the P2P/private language.
- Use subtle CRT/VHS treatment.
- Make the application feel like one coherent desktop product.

### DON'T

- Introduce white/light dashboards.
- Use standard SaaS gradients.
- Use excessive rounded cards.
- Use generic glassmorphism.
- Make everything neon.
- Add excessive blur.
- Replace the fantasy/VHS identity with generic cyberpunk.
- Use huge modern shadows.
- Turn every status into a colored pill.
- Make VHS distortion so strong that text becomes difficult to read.

---

# 15. Voice / copy style

Product copy is casual, intimate and slightly magical.

Examples:

- `for you and your crew`
- `Just vibes`
- `the-mossy-stump`
- `campfire chat`
- `saving both to the tape`
- `Mara está conjurando uma resposta…`
- `Entrando na fogueira`

The language can mix normal communication terminology with fantasy metaphors.

Avoid corporate/productivity language such as:

- Workspace
- Enterprise
- Organization
- Meeting room
- Collaboration hub
- Productivity

Prefer:

- room
- crew
- call
- circle
- campfire
- direct
- tape
- spell / conjure (sparingly)

---

# 16. Reference screenshots

The `screens/` directory contains the eight original reference pages exported from the provided PDF.

```text
screens/
├── screen-01.png  # Landing
├── screen-02.png  # Group call
├── screen-03.png  # Direct chat
├── screen-04.png  # Incoming call
├── screen-05.png  # Outgoing call
├── screen-06.png  # Screen sharing picker
├── screen-07.png  # Screen sharing viewer
└── screen-08.png  # Join room
```

When implementing a component, inspect the relevant screenshot before inventing a new visual treatment.

---

# 17. Implementation priority

If there is a conflict between a generic UI convention and this document, prefer the Slouching visual language.

Priority order:

1. Usability and accessibility
2. Product interaction semantics
3. Consistency with existing Slouching screens
4. Visual identity
5. Decorative VHS effects

Decorative effects should never override usability.

---

## Quick visual summary

**Slouching =**

`dark fantasy + VHS/CRT + cozy private P2P + retro desktop UI + warm yellow actions + purple/navy surfaces + magenta destructive actions`

The result should feel like a mysterious old computer application that somehow became the perfect private place for your friends to hang out.
