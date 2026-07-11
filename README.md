# drawer_rail

A collapsible, themeable **side navigation drawer** for Flutter.

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

## Theming

Everything falls back to the ambient `ColorScheme`. Override only what you need:

```dart
DrawerRail(
  controller: _controller,
  entries: _entries,
  theme: const DrawerRailTheme(
    expandedWidth: 320,
    railWidth: 72,
    borderRadius: 28,
    selectedColor: Color(0xFF6366F1),
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

## License

MIT — see [LICENSE](LICENSE).
