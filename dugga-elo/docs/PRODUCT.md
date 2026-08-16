# Product

## Experience

BiKL Sharodotsav is a warm, family-scale Durga Puja album accompanied by a Puja
playlist. It should feel like opening photographs outdoors in a calm Bengali
autumn, not launching a streaming product. The album is the visual focus; music
supports the act of remembering.

The title appears as a rounded, extra-bold “BiKL” above the Bengali
“শারদোৎসব”, directly on a sunlit blue sky with layered ivory, gold, and soft brown
shadows. The header remains a semantic region but has no colored band, border,
strip, or subtitle. Soft cumulus clouds occupy the upper edges without crowding
the title. Layered green grasses and ivory-white kash flowers create a painterly
lower horizon, with the taller flower clusters concentrated at the sides to keep
the center quiet behind the album. Clouds circulate continuously from left to
right, with a new form entering as its matching cloud exits so the sky retains
its density without a visible reset. Nearer forms move more quickly than the
smaller, fainter clouds behind them. The slight, independent kash sway keeps the
lower scene alive without competing with photographs. Reduced-motion users
retain the same complete scene without movement. The book itself has
paired burnished oxblood leather covers with darkened edges, inset highlights,
fine stitching, and visible parchment page layers beneath its light-crema
leaves. Photographs sit in thin ivory mats with a fine edge and a small physical
shadow. The palette uses clear sky blue, natural greens, ivory paper, oxblood
and deep red, antique brass, and charcoal.
Two-page views leave a narrow recessed ridge between the paper leaves, revealing
the oxblood leather beneath while the centered spiral covers most of the gap.
Nunito carries the rounded BiKL wordmark, Tiro Bangla carries the Bengali title
and small editorial details, and Lato and system fallbacks keep controls compact
and legible. Roomy normal layouts expand the title into otherwise unused
headroom while retaining clear separation from the album; compact layouts keep
the baseline title scale.

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

Google Analytics records ordinary visits and a small set of engagement events:
confirmed song starts, music-control requests, album navigation by direction and
input method, automatic photo advances, and clicks on the four header links.
Song starts are counted once per playback occurrence rather than again after a
pause or buffering transition. The application does not collect pointer
coordinates or define its own user identity.

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
receive a brief fade instead of a physical page rotation, the disc does not spin,
and clouds and kash remain still. The decorative scenery is hidden from assistive
technology and cannot receive input or focus. If JavaScript is unavailable, the
first photo, a short explanation, and a direct playlist link remain. If the
embedded player fails, the same direct link is available in normal mode.

## Non-goals

- No backend, accounts, chat, live-listener fiction, or shared state beyond the
  configured Google Analytics collection.
- No local music files, proxying, API keys, or invented track metadata.
- No extracted thumbnails, fake record jackets, or custom controls placed over
  the YouTube surface.
- No neon, glass panels, animated smoke, large clip art, or dense mandala fields.
- No publishing during localhost alpha. Public-use consent for identifiable
  people is a release gate, not an alpha implementation detail.
