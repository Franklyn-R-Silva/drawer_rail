# Changelog

<!-- Add upcoming changes under a new "## Unreleased" heading. -->

## 0.7.0

- **New: accordion groups.** `DrawerRailController(accordion: true)` keeps at
  most one group open: expanding a group — by click, by hover or through
  `toggleGroup`/`setGroupExpanded` — collapses the one that was open, in a
  single notification. Off by default, so existing drawers behave as before.
  Apps that wanted this used to subclass the controller and override both
  methods.

## 0.6.1

- **Fix: a rail flyout still overlapped the rail.** 0.5.0 moved it beside the
  button, but measured from the button's slot, which ends inside the rail by
  the theme's `contentPadding`. With the default padding the flyout covered
  the rail's last 4px; on a rail and flyout of the same color it read as glued
  to the rail instead of opening beside it. It now clears the rail's edge by
  the gap, on either side, and follows a custom `contentPadding`. The test
  that let the overlap through (it accepted 8px of it) now asks for none.

## 0.6.0

Fixes for what the apps built on the drawer ran into in production — read off
their workarounds, their tests and their changelogs — plus a fresh bug hunt.
Every fix below is pinned by a regression test, and the crashes and hover bugs
were each reproduced by a failing test before being fixed. The suite grew from
52 tests to 75.

### Breaking-ish

- **`DrawerRailTheme.hoverAdaptive()` no longer opens groups on hover.** Every
  app on the preset switched that back off with a `copyWith`: an inline group
  opening on the way to another item pushes that item down and out from under
  the pointer. Pass `groupTrigger: DrawerActivationMode.hover` to get the old
  behavior back.
- **The rail's search button no longer pins the drawer open.** It opens the
  panel for the search only; picking a result or tapping outside puts back the
  rail. Searching from a rail the user had pinned collapsed used to save
  "expanded" as their preference.
- `ResolvedDrawerRailTheme.surfaceVariantColor` is deprecated in favor of
  `mutedColor`, and the resolved theme's constructor takes `mutedColor`
  instead. Only matters if you build a `ResolvedDrawerRailTheme` by hand.

### Crashes

- **Fix: with reduced motion on, opening a group threw** "RenderAnimatedSize
  was mutated in its own performLayout". `AnimatedCrossFade` cannot run at the
  zero duration reduced motion resolves to; the children are now simply shown
  or not. Measured on 0.4.0 and still present on 0.5.0.
- **Fix: removing the drawer mid-peek broke any shell listening to the
  controller** with "setState() called when widget tree was locked". 0.5.0's
  teardown reset notified from `dispose`; it now runs once the frame is over.
  Swapping the drawer's controller hands the old one back clean the same way.

### Hover

- **Fix: clicking a group hover had already opened shut it.** Hover opens a
  group in 120ms, quicker than anyone clicks, so the click a user aimed at a
  closed group nearly always toggled it closed again. It now pins it open —
  inline and in the rail alike.
- **Fix: a rail flyout opened by click closed as soon as the pointer left
  it,** contradicting `groupTrigger`'s own docs. Only what hover opened closes
  on exit now, as with inline groups.
- **Fix: the panel closed mid-word** when the pointer drifted off while typing
  in the search field, taking the field with it. A focused field now holds the
  panel open; the close runs once it lets go of focus.
- **Fix: a menu opened from the header closed when a hover peek ended.** The
  header was a `Row` in the panel and a `Column` in the rail, so collapsing
  tore it down; it now keeps its place in the tree, and apps no longer need a
  `GlobalKey` to keep header state alive.
- Add `DrawerRailController.setHoverHold` / `hoverHeld`: hold a hover-opened
  drawer open while an overlay of your own is up (a header menu, a footer
  popup). The close is put off, not dropped. `resetHoverState` clears it too.

### Theming

- **Fix: `iconColor` never reached link icons in the panel** — they took
  `labelColor` — while group headers and the rail did use it.
- **Fix: flyout items ignored the theme.** They now show the selected pill,
  the danger tint, badges, `labelColor` and the label text styles, like their
  counterparts in the panel.
- Add `DrawerRailTheme.mutedColor` for the secondary chrome (collapse/expand
  and search buttons, the search field's icon, hint and clear button, group
  chevrons, "no results"), `dividerColor` and `focusColor`. Apps had to wrap
  the drawer in a `Theme` overriding the whole `ColorScheme` to recolor these.
- The search field's typed text follows `labelColor`, so it no longer comes out
  dark on dark in a dark drawer inside a light app.
- Add `focusColor` to `AnimatedPressCard`.

### Layout and accessibility

- **Fix: the safe-area inset was applied to the drawer's inner edge too,** so a
  landscape notch on the far side knocked the rail icons off centre. Only the
  outer edge honours it now.
- **Fix: keyboard focus on a rail button showed nothing.** The label is only a
  tooltip in the rail; it now appears when the button takes keyboard focus.
- **Fix: under an app-wide `SelectionArea`, dragging across the drawer left a
  selection trail** over the labels. The drawer now opts out of selection.

### Selection

- Add `DrawerRail.selectOnTap` (default `true`). Turn it off when the route
  drives the selection: selecting on tap marked a pushed link in the menu of
  the screen underneath, which then showed the wrong item on the way back.
- Add `selectedIcon` to `DrawerLink` (shown while selected) and `DrawerGroup`
  (shown while one of its children is), and `DrawerGroup.contains`. Apps were
  rebuilding their entries on every selection just to swap icons.

### Housekeeping

- The rail search button's deferred focus request no longer touches a focus
  node the drawer already disposed.
- README: route-driven selection, holding the drawer open for your own
  overlays, the new colors, and the hover preset as it now behaves.

## 0.5.0

A bug-hunting release: everything below except the new API was found by reading
the widget back against what its own comments claimed it did, then written up as
a failing test first. The suite grew from 36 tests to 52.

### Hover, when the pointer keeps moving

- **Fix: sweeping from one group to the next stranded the first one open.** All
  groups shared a single timer, so entering the second group cancelled the
  pending close of the one just left — and it then stayed open for good, since
  the bookkeeping had already moved on. Each group now keeps its own timer.
- **Fix: in the collapsed rail, the same bug meant the next flyout never opened
  at all** — the shared timer resolved to the wrong action. Rail flyouts now
  swap cleanly, and only one is ever open at a time.
- **Fix: a rail flyout opened straight over the buttons below it**, so the group
  underneath an open one could not be reached — fatal with `groupTrigger:
  hover`, where the pointer has to travel through the overlay to get anywhere.
  Flyouts now open *beside* the rail, and mirror correctly with
  `position: right`.
- **Fix: a drawer torn down mid-peek left `hoverPeeking` stuck on**, so a
  controller outliving the drawer reported the wrong `railCollapsed` from then
  on. `DrawerRail` now hands the controller back clean.
- **Fix: a group with no children opened an empty flyout.** It now opens
  nothing.

### Layout

- **Fix: the content slid sideways for the whole collapse/expand animation.**
  The `OverflowBox` meant to lay the content out at its target width inherited
  the animating container's tight `minWidth` as a floor, so it never did — the
  content was laid out at the animating width and centred instead. It is now
  anchored against the edge that does not move, so the rail is *revealed*
  rather than squeezed: no re-wrapping, no mid-animation ellipsis, no drift.
  With `position: right` the anchor flips with it.

### Search

- **Fix: searching a group's name found nothing.** Only children were matched,
  so `Reports` came back empty unless a child happened to carry the word too. A
  group that matches now offers all of its children.
- **Fix: a query left running behind the rail silently filtered the panel the
  next time it opened**, with nothing on screen to explain the missing entries.
  Pinning the drawer collapsed now clears the search. A hover peek or auto-hide
  is transient and deliberately leaves what you typed alone.

### Motion and accessibility

- **Fix: `pressedScale` was captured once in `initState`**, so changing it — or
  a theme change that changed it — went unnoticed for the life of the card.
- **Fix: reduced motion did not reach the press micro-scale.** Items went on
  shrinking under the pointer even with `MediaQuery.disableAnimations` set. A
  scale is movement however short its duration, so `DrawerRailTheme.resolve`
  now forces `pressedScale` to `1` under reduced motion rather than merely
  running it faster.
- Add `DrawerRailTheme.pressAnimationDuration` and the matching parameter on
  `AnimatedPressCard` (default 140ms), so the press micro-scale is as tunable
  as every other animation.

### Housekeeping

- Add `DrawerRailController.resetHoverState()`: clears `hoverPeeking` and
  `hoverHidden` without touching the pinned `collapsed`. `DrawerRail` calls it
  on teardown; it is a no-op on an already-disposed controller, so teardown
  order stays the caller's to choose.
- Add `DrawerRailLabels.copyWith`, and value equality on `DrawerRailLabels` and
  `DrawerBadge` — they can now be asserted on directly in tests.
- **Fix: per-group state grew without bound.** Menu controllers and timers for
  groups that no longer exist are now dropped when `entries` changes.
- **Fix: a dartdoc link pointed at `NovaDrawer`**, a type that does not exist —
  a leftover from an old rename.
- README: a section of its own for search, the pub.dev badge now that the
  package is published, and the reduce-motion and flyout behavior documented as
  it now actually is.

## 0.4.0

### Hover: opening *and* closing

- Add `DrawerRailTheme.hoverAdaptive()`, a one-line preset that makes the drawer
  pointer-driven: rail and groups switch to hover, `railAutoCollapse` turns on,
  and `linkTrigger` deliberately stays on `click`. Pass `base:` to layer it over
  your own styling.
- Add `DrawerRailTheme.railAutoCollapse` (default `false`) and
  `hoverAutoCollapseDelay` (default 450ms). With `railTrigger: hover`, leaving
  the drawer now also closes one the user left *expanded*, making hover
  symmetric. Off by default because it takes away a panel someone pinned open.
- Add `DrawerRailController.hoverHidden` and `setHoverHidden`, the mirror of
  `hoverPeeking`. Like a peek, an auto-collapse never writes `collapsed`, so the
  state you persist still survives a passing mouse.
- Fix: a group opened by hover now closes when the panel itself closes, instead
  of still sitting open the next time the drawer is revealed.
- Fix: an explicit collapse/expand now also cancels an auto-hide in flight, not
  just a peek.

### Cursors

- Add `DrawerRailTheme.clickableCursor` (default `SystemMouseCursors.click`) and
  `inertCursor` (default `SystemMouseCursors.basic`), plus matching parameters
  on `AnimatedPressCard`. Every clickable surface now *states* its cursor rather
  than inheriting one, and the drawer's own chrome states the arrow — so the
  pointer reliably reverts when it leaves an item.

### Motion

- Add `groupAnimationCurve`, `hoverAnimationDuration` and `hoverAnimationCurve`.
- Fix: the group unfold used a linear height tween, which read as mechanical
  next to the eased width animation. It and the chevron rotation now follow
  `groupAnimationCurve`.
- Fix: the item hover shadow/tint appeared and vanished in a single frame. It
  now fades over `hoverAnimationDuration`.
- Fix: hovering a **selected** item replaced its pill color with the drawer
  surface. An already-opaque background is now kept as the shadow's backing
  surface, so the pill keeps its color and just lifts.
- Items now spring back from a press with a slight overshoot instead of easing
  flatly back to size.
- Honour `MediaQuery.disableAnimations`: every animation duration collapses to
  zero when the platform asks for reduced motion. Hover *delays* are kept — they
  gate an interaction, not a motion effect. `DrawerRailTheme.resolve` takes a
  new optional `reduceMotion` flag.

### Other

- Add `DrawerRailTheme.copyWith`.
- The hover-shadow regression helper moved back to matching `AnimatedContainer`,
  because the card genuinely renders one now. The 0.3.0 note below was correct
  at the time and is simply no longer true.
- Rewrite the README: every theme field now documents what it turns on and what
  visibly moves, and the example app got live switches for **Open on hover** and
  **Close on exit**.

## 0.3.0

- Add `DrawerActivationMode` (`click` / `hover`) and three theme fields that
  choose how each interaction is triggered on web and desktop:
  `DrawerRailTheme.railTrigger` (pointer peeks the collapsed rail open),
  `groupTrigger` (pointer opens groups inline and as rail flyouts) and
  `linkTrigger` (pointer activates a link after a dwell). All default to
  `click`, so existing behavior is unchanged.
- Add `hoverOpenDelay`, `hoverCloseDelay` and `hoverSelectDelay` to tune the
  hover timings. The close delay is what lets the pointer travel from a rail
  button to its flyout without the menu snapping shut.
- Add `DrawerRailController.hoverPeeking`, `railCollapsed` and
  `setGroupExpanded`. A hover peek widens the rail *without* changing
  `collapsed`, so the state you persist survives a passing mouse; read
  `railCollapsed` for the width actually on screen.
- Hover never replaces tap: every item stays clickable in every mode, so touch
  platforms — where hover events never fire — are unaffected.
- Fix two hover regression tests that were passing vacuously: the helper looked
  for an `AnimatedContainer` under `AnimatedPressCard`, which renders a plain
  `Container`, so it never inspected anything.

## 0.2.1

- Fix visual bug where hover effect was applied as an overlay affecting foreground legibility. Hover now strictly alters the background color using InkWell, keeping text and icons at 100% opacity.

## 0.2.0

- Add `DrawerRailTheme.hoverEffect` (`DrawerHoverEffect.shadow` / `.highlight` /
  `.none`) so the item hover feedback can be switched or turned off, plus
  `hoverHighlightColor` for the highlight variant.
- Fix the murky/cloudy look of the hover shadow: in `shadow` mode an opaque
  surface is now painted behind the card, so the shadow reads as a lift instead
  of a colored haze bleeding through transparent items.

## 0.1.0

Initial release.

- `DrawerRail`: collapsible side navigation drawer with an expanded panel and a
  narrow icon rail.
- Built-in diacritic-insensitive search, uppercase section headers, selected
  pill, text/count badges, inline-expandable groups and collapsed flyout menus.
- `DrawerRailController` (`ChangeNotifier`) for collapse, selection and group
  state — no external state-management dependency.
- `DrawerRailLabels` for localizing the built-in chrome.
- Customizable header and footer slots via builders.
- Fully customizable `DrawerRailTheme`, falling back to the ambient
  `ColorScheme`:
  - Sizing/spacing: `expandedWidth`, `railWidth`, `iconSize`, `railIconSize`,
    `railItemHeight`, `borderRadius`, `itemBorderRadius`, `contentPadding`,
    `itemPadding`, `groupChildIndent`.
  - Text styles: `labelTextStyle`, `selectedLabelTextStyle`, `sectionTextStyle`,
    `badgeTextStyle`, plus `sectionUppercase`.
  - Chrome icons: `collapseIcon`, `expandIcon`, `searchIcon`, `clearSearchIcon`,
    `groupTrailingIcon`.
  - Motion: `animationDuration`, `animationCurve`, `groupAnimationDuration`,
    `pressedScale`.
  - Layout: `DrawerRailPosition` (`left` / `right`).
- `DrawerRail.searchDecoration` to fully override the search field, and
  `DrawerRail.showFooterDivider`.
