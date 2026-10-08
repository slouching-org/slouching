# Slouching visual source bank

The project owner supplied `/home/amitis/slouching` on 2026-10-07. Its files are
preserved here as design sources, separate from application code:

- [source/slouching-telas.html](../../design/source/slouching-telas.html): bundled HTML board
  with 11 static design pages. This is a design reference, not a running client.
- [screens](../../design/screens): all 11 PNG exports, numbered 00–10 and renamed only for
  readable paths. Each export is 2560 × 1600 pixels; the HTML board presents
  its pages at 1280 × 800 CSS pixels.
- [source/cenas](../../design/source/cenas): nine original JPEG scene assets, including
  `bg-home.jpg`, `appicon.jpg`, `sky.jpg`, and the character scenes.
- [source/avatares](../../design/source/avatares): twelve original 256 × 256 JPEG avatars.
- [references](references.md): the five earlier PNGs provided in the conversation.

The [visual style specification](visual-style.md) and
[frontend specification](../frontend/screens.md) explain how to use them.

## Source precedence

1. Direct corrections from the owner: the primary pictorial logo is the pair
   of wizards walking side by side; the hat is a placeholder/fav icon. No
   required third-party server.
2. The 11-screen HTML/PNG bank for screen structure, exact palette, typography,
   and component treatment.
3. The five earlier PNGs for additional crop and compact-window reference.

Some mock screens contain illustrative measurements and transport labels. A
working client must show measured values and the actual route. The JPEG scenes
and avatars are source assets; the screenshots are visual targets, not images
to paste over functioning controls.
