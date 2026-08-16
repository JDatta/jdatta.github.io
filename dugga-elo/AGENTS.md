# BiKL Dugga Elo working notes

## File map

- `index.html` is the complete application: markup, styles, frozen album manifest,
  interaction controller, and YouTube IFrame API integration.
- `server.py` is the unchanged localhost alpha server. Run `python3 server.py`
  and open `http://127.0.0.1:8080/`.
- `resources/album/image-*.jpg` are the 45 canonical source photographs.
- `resources/album/web/image-*.jpg` are the checked-in web display derivatives.
- `resources/cd-art.png` is the preferred disc artwork;
  `resources/bikl-large.png` is its runtime fallback.
- `docs/ARCHITECTURE.md` and `docs/PRODUCT.md` describe the implementation and
  intended experience.

## Project rules

- Keep this a no-build, one-page static application unless a later task
  explicitly changes the architecture. Do not add a package manager for routine
  edits.
- The literal `ALBUM_IMAGES` array in `index.html` is the browser manifest. The
  browser must never enumerate the album directory. Keep it in natural numeric
  filename order and include display URL, canonical fallback URL, display
  dimensions, and useful alt text for every image.
- All local asset URLs must remain relative so the directory can later move to a
  GitHub Pages `/dugga-elo/` subpath unchanged.
- Preserve canonical photos. Regenerate only `resources/album/web/` according to
  `resources/album/AGENTS.md`.
- Normal layouts keep a transparent, title-only semantic header above the album
  and a transparent semantic music footer below it. Do not restore colored
  header or footer bands or a header subtitle.
- The normal music footer always contains a translucent, shadowed mini-player.
  The 200 by 200 pixel native YouTube iframe remains alive but is visually clipped
  and unfocusable by default. The startup `show-yt-iframe` feature flag restores
  its unobscured bottom-right surface; at widths up to 700 px, stack the
  mini-player above it, otherwise keep them side by side without overlap.
- Preserve the mini-player's disc–track information–controls order. Track text
  is sans-serif and title-only; do not add an artist/uploader line or a visible
  playback-status label. Marquee the title only when it exceeds its available
  width, and keep it still for reduced-motion users. Keep factual player messages
  in the screen-reader live region. The custom controls are previous, dominant
  play/pause, and next; volume and mute remain on the native YouTube surface.
- Restricted landscape is exactly `(orientation: landscape) and
  (max-width: 900px) and (max-height: 500px)`. It shows a two-page album plus one
  compact play/pause button. Keep the YouTube iframe and playback alive across
  entry and exit, but show no disc, artwork, metadata, progress, previous/next
  controls, or native iframe surface there.
- `server.py`, `image-compressor.sh`, and source photographs are outside routine
  UI edits. Files outside this project are out of scope.

## Testing gotchas

- Test both direct localhost root serving and subpath serving from the parent
  `jdatta.github.io` directory.
- Exercise 390×844, 844×390, 768×1024, 1024×768, and 1440×900.
- In every normal viewport, confirm the mini-player and album do not overlap;
  when `show-yt-iframe` is true, also confirm the native surface does not overlap
  either. The document must not overflow, and the primary play/pause control is
  substantially larger than previous/next.
- Confirm one real `<iframe>` exists in normal and restricted landscape modes.
  With `show-yt-iframe` false it is visually clipped and unfocusable; with the
  flag true it is visible only in normal layouts.
- Verify current-title metadata after previous/next and automatic playlist
  transitions. If metadata is temporarily unavailable, show `Track N of M`, then
  `Puja playlist` until playlist position is known.
- Playback, track, and time must continue uninterrupted while rotating into and
  out of restricted mode. Both play/pause controls must remain synchronized.
- Resizing during a page turn commits the selected target and removes temporary
  turn layers.
- Keep automated album changes silent to screen readers; manual changes use the
  polite live region.
- A blocked display derivative must try its canonical source once, then retain a
  paper placeholder without reordering the album.
