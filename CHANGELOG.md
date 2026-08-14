# Changelog

<!-- Add upcoming changes under a new "## Unreleased" heading. -->

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
