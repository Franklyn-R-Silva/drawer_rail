# Changelog

## Unreleased

### Added

- Full theming surface on `DrawerRailTheme`: `iconSize`, `railIconSize`,
  `railItemHeight`, `pressedScale`, `sectionUppercase`, `contentPadding`,
  `itemPadding`, `groupChildIndent`, `groupAnimationDuration`,
  `hoverShadowColor`, `menuBackgroundColor`, `searchFillColor`.
- Customizable text styles: `labelTextStyle`, `selectedLabelTextStyle`,
  `sectionTextStyle`, `badgeTextStyle`.
- Customizable chrome icons: `collapseIcon`, `expandIcon`, `searchIcon`,
  `clearSearchIcon`, `groupTrailingIcon`.
- `DrawerRailPosition` (`left` / `right`) to place the drawer on either side.
- `DrawerRail.searchDecoration` to fully override the search field, and
  `DrawerRail.showFooterDivider`.

## 0.1.0

Initial release.

- `DrawerRail`: collapsible side navigation drawer with an expanded panel and a
  narrow icon rail.
- Built-in diacritic-insensitive search, uppercase section headers, selected
  pill, text/count badges, inline-expandable groups and collapsed flyout menus.
- `DrawerRailController` (`ChangeNotifier`) for collapse, selection and group
  state — no external state-management dependency.
- `DrawerRailTheme` for full visual customization, falling back to the ambient
  `ColorScheme`.
- `DrawerRailLabels` for localizing the built-in chrome.
- Customizable header and footer slots via builders.
