# Changelog

<!-- Add upcoming changes under a new "## Unreleased" heading. -->

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
