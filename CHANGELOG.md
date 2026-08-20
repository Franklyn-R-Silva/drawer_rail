# Changelog

<!-- Add upcoming changes under a new "## Unreleased" heading. -->

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
