# Architecture

BiKL Dugga Elo is a portable static web application. `index.html` owns the
semantic HTML, responsive CSS, frozen media manifest, album controller, and
official YouTube IFrame Player API integration. There is no build step, service
worker, application backend, API key, or locally hosted music.

## Layouts

Normal mode covers portrait phones, tablets in both orientations, and desktop.
The viewport is a three-row grid: a transparent title header, flexible album,
and a transparent music region. Narrow portrait uses one 4:5 page with a left
binding. Wider normal viewports use a centered pair of 4:5 pages with a center
binding. Both sit inside a burnished oxblood leather cover with stitched edges
and a parchment page-stack layer. Antique-brass closure buttons retain the
existing previous/next interfaces at the outer edges in landscape; every
portrait layout hides them and relies on tap halves, horizontal swipes, and
arrow keys. Wider spreads may grow to approximately 1180 px before decoration.
Within the music region, a rounded mini-player floats near the bottom center. It
contains the rotating BiKL disc, a sans-serif current-title/progress block, and
right-aligned transport controls with a dominant play/pause action. Its
translucent surface uses blur and shadow to retain contrast over changing
backgrounds. Factual
playback status is maintained in a screen-reader-only live region instead of a
visible label. An independent, unobstructed 200×200 YouTube surface is anchored
at the bottom right. At widths up to 700 px the mini-player stacks above that
surface and the music row grows to reserve space for both.

Restricted landscape activates only when the media query reports landscape,
width at most 900 px, and height at most 500 px. The content row becomes two
compact 5:4 pages plus a narrow text-only status rail. The leather reveal,
stacked edges, and closure hardware become slimmer, but both album navigation
targets remain available. The iframe is destroyed, not hidden. The music footer,
disc, artwork, and controls are absent from the rendered layout.

A `ResizeObserver` fits the decorated shell to its flexible workspace. Sizing
subtracts workspace padding, leather reveal, stacked-page depth, and any
rendered closure overhang explicitly, then calculates the paper pages. Hidden
portrait closures contribute zero overhang, allowing the pages to use the
recovered width; decoration therefore does not reduce the page dimensions.
Every nested grid allows its children to shrink with `min-width: 0` and
`min-height: 0`; the root uses safe-area padding, dynamic viewport units, and
clipped overflow. Layout
selection comes only from the restricted media query and the normal workspace
width, so ordinary landscape tablets and desktops never enter compact mode.

## Album state and loading

The frozen `ALBUM_IMAGES` array preserves deterministic filename order. Each
entry records a 1600 px display derivative, canonical retry URL, reserved display
dimensions, and descriptive alt text. Two reusable image slots render the
current state. A failed derivative retries the canonical image once and then
becomes a stable paper placeholder. Each light-crema leaf has only a narrow edge
inset. The rendered photograph is contained without cropping inside a 5–8 px
ivory mat (3 px in restricted landscape), selected from its manifest aspect
ratio so the mat follows the photograph rather than filling unused leaf space.
Temporary turn leaves, blank companions, and error placeholders use the same
crema base while the mats remain lighter. Adjacent states are preloaded
transiently; there is no hidden 45-image gallery.

The top-level `--album-leaf-color` and `--portrait-closure-display` custom
properties are the maintainer-facing controls for leaf color and portrait
closure visibility.

Album presentation is `single`, `spread`, or `compact-spread`. Single mode steps
one photograph; both spread modes step two. Spread anchors are even indices, and
the final odd photograph receives an intentional blank companion. Modular index
math wraps in both directions.

The page-turn phases are `idle`, `preparing`, `first-half`, `midpoint`, and
`second-half`. Preparation locks input and preloads the target. A temporary leaf
rotates to the midpoint, the canonical pages switch beneath it, and the leaf
finishes before it is destroyed. A resize cancels the active Web Animation,
commits its selected target, and rebuilds the current presentation. Reduced
motion replaces the 480–680 ms three-dimensional turn with a short 160 ms fade
and slide.

The five-second slideshow runs only while the document is visible, the album is
not held, and animation is idle. Any completed automatic or manual change starts
a fresh interval. Pointer capture distinguishes swipes, below-threshold drags,
short taps, and long holds. Arrow keys navigate globally except from interactive
elements; the shell pointer handler also ignores interactive descendants so a
closure click cannot become a second tap-half action. Space controls music only
in normal mode. Only manual album changes write to the polite live region.

## Player lifecycle

The playlist ID is validated locally before the official IFrame API is loaded.
The player is configured as an embedded playlist with native controls, inline
playback, looping, no autoplay, and the current HTTP origin. Custom controls call
documented player methods and derive their state from player events. The native
surface remains the place for volume and mute control. A one-second poll reads
only factual time, duration, playlist index, playlist length, and current video
title while playback is active and the document is visible. Title state also
syncs on ready and player-state transitions; unavailable metadata falls back to
`Track N of M`, then `Puja playlist` until playlist position is known.

Entering restricted mode snapshots the known playlist index and current time,
pauses playback, stops polling, calls `destroy()`, clears the host, and updates
the text status. Leaving restricted mode creates a new visible player and cues
the snapshot without playing it. The user must explicitly press Play again.

API timeout or creation failure disables supplemental controls and retains a
direct playlist link. Unavailable or embedding-disabled playlist items are
recorded and skipped with exhaustion protection. Request/configuration errors are
terminal. The disc uses one lifetime CSS animation and toggles only
`animation-play-state`, so pausing preserves its angle; reduced motion suppresses
rotation. Disc artwork falls back from the small PNG to the large seal and then
to a CSS disc.

## Portability and performance

All project asset URLs are relative. The directory therefore works at localhost
root and can later move unchanged to a `/dugga-elo/` GitHub Pages subpath. The
canonical high-resolution photos remain intact, while checked-in progressive web
copies cap decode dimensions. The initial photograph is high priority; all other
album decodes are current or adjacent. Timers stop in background tabs, page-turn
nodes are temporary, and the YouTube document is removed completely in compact
mode.
