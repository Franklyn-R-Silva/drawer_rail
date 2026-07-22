# drawer_rail

[![CI](https://github.com/Franklyn-R-Silva/drawer_rail/actions/workflows/ci.yaml/badge.svg)](https://github.com/Franklyn-R-Silva/drawer_rail/actions/workflows/ci.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<!-- After the first `flutter pub publish`, add the pub badge:
[![pub package](https://img.shields.io/pub/v/drawer_rail.svg)](https://pub.dev/packages/drawer_rail)
-->

A collapsible, themeable **side navigation drawer** for Flutter.

<p align="center">
  <img
    src="https://raw.githubusercontent.com/Franklyn-R-Silva/drawer_rail/main/screenshots/drawer_rail.gif"
    alt="drawer_rail demo — collapsing rail, flyout groups, search and dark mode"
    width="300"
  />
  <br /><br />
  <img
    src="https://raw.githubusercontent.com/Franklyn-R-Silva/drawer_rail/main/screenshots/drawer_rail.png"
    alt="drawer_rail expanded panel on a wide screen"
    width="720"
  />
</p>

`DrawerRail` has two states, both driven by your app's `ColorScheme`:

- an **expanded panel** — optional search, uppercase section labels, a selected
  pill, text/count badges and inline-expandable groups; and
- a narrow **icon rail** — where groups open as flyout menus.

State lives in a plain `ChangeNotifier` (`DrawerRailController`), so there is
**no dependency on any state-management package**.

## Features

- 🧩 Declarative content: `DrawerSection`, `DrawerLink`, `DrawerGroup`.
- ↔️ Animated collapse between a full panel and an icon rail.
- 🔎 Built-in, diacritic-insensitive search (`"acao"` matches `"Ação"`).
- 🏷️ Text and count badges (`New`, `4`, `99+`).
- 🎨 Themeable via `DrawerRailTheme`, with automatic `ColorScheme` fallbacks.
- 🌍 Localizable chrome via `DrawerRailLabels`.
- 🧱 Custom header and footer slots (avatar, dark-mode toggle, sign out, …).
- 🧪 No runtime dependencies beyond Flutter.

## Installation

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  drawer_rail: ^0.1.0
```

Then import it:

```dart
import 'package:drawer_rail/drawer_rail.dart';
```

## Quick start

Keep a `DrawerRailController` in your `State`, pass it and a list of entries to
`DrawerRail`, and place the drawer in a `Row` beside your content:

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = DrawerRailController(selectedId: 'dashboard');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DrawerRail(
            controller: _controller,
            entries: [
              const DrawerSection('Main'),
              DrawerLink(
                id: 'dashboard',
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                onTap: (context) => _open(context, const DashboardPage()),
              ),
              DrawerLink(
                id: 'payments',
                icon: Icons.account_balance_wallet_outlined,
                label: 'Payments',
                badge: const DrawerBadge.count(4),
                onTap: (context) => _open(context, const PaymentsPage()),
              ),
              const DrawerSection('Workspace'),
              DrawerGroup(
                id: 'services',
                icon: Icons.apps_rounded,
                label: 'Services',
                children: [
                  DrawerLink(
                    id: 'cloud',
                    icon: Icons.cloud_outlined,
                    label: 'Cloud Solutions',
                    onTap: (context) => _open(context, const CloudPage()),
                  ),
                ],
              ),
            ],
          ),
          const Expanded(child: Center(child: Text('Content'))),
        ],
      ),
    );
  }
}
```

> `DrawerRail` renders at a fixed width and animates it. Place it in a `Row`
> (or any layout that gives it an unbounded cross axis), **not** in the
> `Scaffold.drawer` slot.

## Entries

| Type            | Purpose                                                        |
| --------------- | ------------------------------------------------------------- |
| `DrawerSection` | A non-interactive header; a divider in the collapsed rail.    |
| `DrawerLink`    | A tappable destination with `id`, `icon`, `label`, `onTap`.   |
| `DrawerGroup`   | A group of links; expands inline, or opens a flyout collapsed.|

`DrawerLink.onTap` receives the drawer's `BuildContext`, so you can navigate
from it directly. Set `danger: true` for destructive items (e.g. sign out) to
tint them with the error color.

### Badges

```dart
DrawerBadge.text('New');  // pill with text
DrawerBadge.count(4);     // numeric; hidden at 0, shown as "99+" above 99
```

## The controller

`DrawerRailController` is a `ChangeNotifier`:

```dart
final controller = DrawerRailController(
  collapsed: false,
  selectedId: 'dashboard',
  initiallyExpanded: {'services'},
);

controller.toggleCollapsed();   // panel <-> rail
controller.setCollapsed(true);
controller.select('payments');  // highlight an entry
controller.toggleGroup('services');
```

### Persisting state

The controller does not persist anything itself. To remember, say, the collapse
state, listen and save it wherever you like:

```dart
controller.addListener(() {
  prefs.setBool('drawer_collapsed', controller.collapsed);
});
```

## Theming — fully customizable

Everything falls back to the ambient `ColorScheme`, so the drawer looks right
with zero configuration. When you want control, **every** size, spacing, color,
text style, icon and animation is exposed on `DrawerRailTheme` — override only
what you need:

```dart
DrawerRail(
  controller: _controller,
  entries: _entries,
  theme: const DrawerRailTheme(
    // Sizing & layout
    expandedWidth: 320,
    railWidth: 72,
    borderRadius: 28,
    itemBorderRadius: 12,
    iconSize: 22,
    railIconSize: 24,
    railItemHeight: 48,
    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    groupChildIndent: 28,
    position: DrawerRailPosition.left, // or .right

    // Colors
    selectedColor: Color(0xFF6366F1),
    onSelectedColor: Colors.white,
    iconColor: Color(0xFF334155),
    labelColor: Color(0xFF0F172A),
    sectionColor: Color(0xFF6366F1),
    badgeCountColor: Color(0xFFEF4444),

    // Hover feedback: shadow (default), highlight or none
    hoverEffect: DrawerHoverEffect.shadow,
    hoverShadowColor: Color(0x1F6366F1),    // used in shadow mode
    hoverHighlightColor: Color(0x146366F1), // used in highlight mode

    // Text styles (label color is applied automatically per state)
    labelTextStyle: TextStyle(fontWeight: FontWeight.w600),
    sectionTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
    badgeTextStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
    sectionUppercase: true,

    // Icons for the built-in chrome
    collapseIcon: Icons.chevron_left_rounded,
    expandIcon: Icons.chevron_right_rounded,
    searchIcon: Icons.search_rounded,
    clearSearchIcon: Icons.close_rounded,
    groupTrailingIcon: Icons.keyboard_arrow_down_rounded,

    // Animation
    animationDuration: Duration(milliseconds: 240),
    animationCurve: Curves.easeOutCubic,
    groupAnimationDuration: Duration(milliseconds: 200),
    pressedScale: 0.97,
  ),
);
```

### What each field controls

| Group      | Fields |
| ---------- | ------ |
| **Sizing** | `expandedWidth`, `railWidth`, `railItemHeight`, `iconSize`, `railIconSize`, `borderRadius`, `itemBorderRadius` |
| **Spacing**| `contentPadding`, `itemPadding`, `groupChildIndent` |
| **Colors** | `backgroundColor`, `selectedColor`, `onSelectedColor`, `iconColor`, `labelColor`, `sectionColor`, `badgeTextColor`, `badgeCountColor`, `menuBackgroundColor`, `searchFillColor`, `shadow` |
| **Hover**  | `hoverEffect` (`shadow` / `highlight` / `none`), `hoverShadowColor`, `hoverHighlightColor` |
| **Text**   | `labelTextStyle`, `selectedLabelTextStyle`, `sectionTextStyle`, `badgeTextStyle`, `sectionUppercase` |
| **Icons**  | `collapseIcon`, `expandIcon`, `searchIcon`, `clearSearchIcon`, `groupTrailingIcon` |
| **Motion** | `animationDuration`, `animationCurve`, `groupAnimationDuration`, `pressedScale` |
| **Layout** | `position` (`left` / `right`) |

### Widget-level customization

Beyond the theme, `DrawerRail` itself exposes toggles and slots:

| Field | Purpose |
| ----- | ------- |
| `showSearch` | Show/hide the built-in search. |
| `showCollapseButton` | Show/hide the collapse/expand toggle. |
| `showFooterDivider` | Draw a divider above the footer. |
| `headerBuilder` / `footerBuilder` | Fully custom header/footer per state. |
| `searchDecoration` | Replace the search field's `InputDecoration`. |
| `labels` | Localize every built-in string (see below). |

Full control of the search field:

```dart
DrawerRail(
  controller: _controller,
  entries: _entries,
  searchDecoration: InputDecoration(
    hintText: 'Type to filter…',
    prefixIcon: const Icon(Icons.filter_list_rounded),
    filled: true,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
  ),
);
```

## Header & footer

Provide custom slots. Both builders receive the current `collapsed` state so
you can return a compact variant on the rail:

```dart
DrawerRail(
  controller: _controller,
  entries: _entries,
  headerBuilder: (context, collapsed) =>
      collapsed ? const _Logo() : const _LogoWithName(),
  footerBuilder: (context, collapsed) => DarkModeToggle(collapsed: collapsed),
);
```

## Localization

```dart
DrawerRail(
  controller: _controller,
  entries: _entries,
  labels: const DrawerRailLabels(
    searchHint: 'Buscar...',
    noResults: 'Nenhum resultado',
    expandTooltip: 'Expandir',
    collapseTooltip: 'Recolher',
  ),
);
```

## Example

A complete, runnable example lives in [`example/`](example/lib/main.dart),
including a header logo, a dark-mode footer toggle, badges and a group.

## Contributing

Contributions are welcome from everyone! Fork the repo, create a branch, and
open a pull request. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first and
follow the [Code of Conduct](CODE_OF_CONDUCT.md).

Good first steps: open an issue for bugs or ideas, improve the docs, or add
tests.

## License

MIT — see [LICENSE](LICENSE).
