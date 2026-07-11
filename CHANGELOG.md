# Changelog

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
