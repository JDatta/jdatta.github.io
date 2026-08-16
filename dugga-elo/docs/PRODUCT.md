# Product

## Experience

BiKL Dugga Elo is a warm, family-scale Durga Puja album accompanied by a Puja
playlist. It should feel like opening photographs on sari cloth, not launching a
streaming product. The album is the visual focus; music supports the act of
remembering.

The exact title appears at an emphatic scale above the album, directly on the
cloth with layered ivory, gold, and soft brown shadows. The header remains a
semantic region but has no colored band, border, strip, or subtitle. Paper
grain, a bronze and charcoal spiral, a restrained lal-paar edge, and faint
alpana linework provide material character. The book itself has a burnished
oxblood leather cover with darkened edges, inset highlights, fine stitching,
and visible parchment page layers beneath its light-crema leaves. Photographs
sit in thin ivory mats with a fine edge and a small physical shadow. The palette
uses warm cloth and paper, oxblood and deep red, antique brass, and charcoal.
Tiro Bangla carries the title and small editorial details; Lato and system
fallbacks keep controls compact and legible.

## Audience and use

The alpha is intended for family and community members viewing the photographs
on phones, tablets, and desktop browsers. Photographs advance every five seconds
but remain directly controllable with click/tap halves, horizontal swipes, and
arrow keys. In landscape, previous and next are also available as leather tabs
ending in raised magnetic plates: large antique-brass touch targets that double
as the album's closures. Portrait layouts hide both closures, leaving the album
gestures and arrow keys unchanged. Images are always contained without cropping
or distortion. The last unpaired photograph appears beside an intentional
light-crema blank page.

Normal layouts keep the title above, the album in all available middle space,
and a visually transparent music region below. A rounded floating mini-player
contains the BiKL disc, current track title, previous/play/next controls,
progress, and elapsed/total time in a three-part disc–information–controls
layout. Its translucent, shadowed pill keeps the controls legible over future
background treatments, its fine highlighted edge suggests physical thickness,
and its play/pause control is intentionally dominant. Previous and next retain
44 px touch targets even in the narrow layout. Long titles scroll within their
available space while titles that fit remain still; reduced-motion users receive
no marquee. Playback state remains available to assistive technology
without adding a visible status label. A separate official YouTube iframe stays
alive for music but is visually clipped and unfocusable by default, keeping the
album and compact mini-player primary. A source feature flag can expose its
200×200 native surface
at the bottom right with identity, volume, controls, keyboard behavior, and
fullscreen action; custom controls remain a supplement. When exposed, narrow
portrait screens stack the mini-player above it so neither overlaps the album.
Music never autoplays audibly.

Very short mobile landscape viewports prioritize photographs. They show two
compact album pages, slim leather and page-edge decoration, both magnetic
closure controls, and one prominent play/pause button. The existing player and
music continue uninterrupted through rotation, while disc artwork, track
information, progress, time, previous/next controls, and the native YouTube
surface stay out of view. Returning to normal immediately presents the current
track state in the full mini-player.

## Accessibility and resilience

Controls have visible focus, accessible names, and factual status. Manual photo
turns are announced politely; automatic changes are quiet. Reduced-motion users
receive a brief fade instead of a physical page rotation, and the disc does not
spin. If JavaScript is unavailable, the first photo, a short explanation, and a
direct playlist link remain. If the embedded player fails, the same direct link
is available in normal mode.

## Non-goals

- No backend, accounts, chat, live-listener fiction, analytics, or shared state.
- No local music files, proxying, API keys, or invented track metadata.
- No extracted thumbnails, fake record jackets, or custom controls placed over
  the YouTube surface.
- No neon, glass panels, animated smoke, large clip art, or dense mandala fields.
- No publishing during localhost alpha. Public-use consent for identifiable
  people is a release gate, not an alpha implementation detail.
