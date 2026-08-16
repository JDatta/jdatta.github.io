# Architecture

BiKL Dugga Elo is a portable static web application. `index.html` owns the
semantic HTML, responsive CSS, frozen media manifest, album controller, and
official YouTube IFrame Player API integration. There is no build step, service
worker, application backend, API key, or locally hosted music.

## Layouts

The first child of the application root is one non-interactive, `aria-hidden`
scenery layer. Its inline SVG definitions are reused by seven logical clouds
across near, middle, and far depth bands and by four kash-flower clusters. Each
moving cloud has a paired SVG copy one viewport behind it, while a CSS sky
gradient and an inline SVG grass horizon cover the viewport beneath every
layout. The artwork has a complete static composition: blue sky, a
restrained warm glow, scattered cumulus clouds, layered green grass, and ivory
kash plumes. The horizon and flowers stay weighted toward the lower and outer
edges so the centered title, album, and music controls remain visually primary.
The body uses a matching sky color before the layer is painted or if it cannot
be rendered.

Normal mode covers portrait phones, tablets in both orientations, and desktop.
The viewport is a three-row grid: a transparent title header, flexible album,
and a transparent music region. Narrow portrait uses one 4:5 page with a left
binding. Wider normal viewports use a centered pair of 4:5 pages with a center
binding. Two-page presentations separate the leaves with a slim recessed gutter
that exposes the oxblood leather beneath the spiral while the coil hardware
covers most of its width. Both sit on distinct left and right panels of a
burnished oxblood leather cover with stitched edges and a parchment page-stack
layer. Antique-brass closure buttons
retain the existing previous/next interfaces at the outer edges in landscape;
every portrait layout hides them and relies on tap halves, horizontal swipes,
and arrow keys. Wider spreads may grow to approximately 1180 px before
decoration.
Within the music region, a rounded mini-player floats near the bottom center. It
contains the rotating BiKL disc, a sans-serif current-title/progress block, and
right-aligned transport controls with a dominant play/pause action. Its
slim translucent surface uses blur, a highlighted border, inset depth, and shadow
to retain contrast over changing backgrounds. A `ResizeObserver` activates a
measured title marquee only when metadata exceeds the available width; reduced
motion leaves the title stationary. Factual playback status is maintained in a
screen-reader-only live region instead of a visible label. The independent
200×200 YouTube iframe remains mounted for API
playback but its surface is clipped, inert, and unfocusable by default. The
startup `show-yt-iframe` feature flag makes the native surface unobstructed at
the bottom right. At widths up to 700 px the mini-player then stacks above that
surface and the music row grows to reserve space for both. With the default flag
the shorter music row centers the mini-player without reserving iframe space.

Restricted landscape activates only when the media query reports landscape,
width at most 900 px, and height at most 500 px. The content row becomes two
compact 5:4 pages plus one prominent play/pause button. The leather reveal,
stacked edges, and closure hardware become slimmer, but both album navigation
targets remain available. The full music footer is clipped and inert while its
iframe stays alive. Disc artwork, track information, progress, time,
previous/next controls, and the native iframe surface are absent visually.

A `ResizeObserver` fits the decorated shell to its flexible workspace. Sizing
subtracts workspace padding, leather reveal, stacked-page depth, and any
rendered closure overhang explicitly, then calculates the paper pages. The
two-page ridge is added to the book and shell only after that calculation, so it
widens the album without reducing either page or photograph. Hidden
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
playback, looping, no autoplay, and the current HTTP origin. It is created at
startup even when the initial viewport is restricted landscape. Custom controls
call documented player methods and derive their state from player events. When
the feature flag exposes it, the native surface remains the place for volume and
mute control. A one-second poll reads
only factual time, duration, playlist index, playlist length, and current video
title while playback is active and the document is visible. Title state also
syncs on ready and player-state transitions; unavailable metadata falls back to
`Track N of M`, then `Puja playlist` until playlist position is known.

Restricted-layout transitions change only presentation state: they do not pause,
snapshot, destroy, clear, or recreate the player. Playback and progress polling
continue uninterrupted. The compact and normal play/pause controls share one
action and receive the same event-derived icon, disabled state, and accessible
label. Returning to normal mode immediately refreshes title, progress, time, and
disc state from the existing player.

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
album decodes are current or adjacent. Timers stop in background tabs and
page-turn nodes are temporary. The YouTube document remains mounted across
responsive layout changes so playback continuity does not depend on
reconstruction.

The scenic illustration adds no runtime or raster request. Transform and CSS
animation support progressively enables staggered cloud drift in three parallax
depth bands and four independent kash sways; all static placement and drawing
remain outside the animation. Every cloud lane contains identical primary and
trailing copies separated by exactly one viewport. Translating the lane one
viewport makes one copy enter from the left as its twin exits right; the end and
start frames are visually identical, keeping seven logical clouds continuously
on screen without a loop jump. Near lanes complete that path more quickly, while
smaller, fainter middle and far lanes move progressively more slowly. Only the
lane wrappers receive narrowly scoped `will-change`, and their animations change
only `transform`. Negative delays distribute clouds across the initial frame
without script-driven setup. Reduced-motion preference disables all scenic
motion, hides the trailing copies, and retains the primary static positions.
The document visibility handler pauses the decorative CSS animations in
background tabs and resumes their same timelines on return, alongside the
existing slideshow and progress-polling management.
