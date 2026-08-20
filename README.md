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
- 🖱️ **Opens and closes by itself on hover** (web/desktop), without ever
  overwriting the state you persist.
- 👆 **Correct cursors**: a hand over anything clickable, an arrow everywhere
  else — and it is themeable.
- 🔎 Built-in, diacritic-insensitive search (`"acao"` matches `"Ação"`).
- 🏷️ Text and count badges (`New`, `4`, `99+`).
- 🎨 Themeable via `DrawerRailTheme`, with automatic `ColorScheme` fallbacks.
- 🎞️ Every duration **and curve** exposed; honours the OS "reduce motion"
  setting automatically.
- 🌍 Localizable chrome via `DrawerRailLabels`.
- 🧱 Custom header and footer slots (avatar, dark-mode toggle, sign out, …).
- 🧪 No runtime dependencies beyond Flutter.

## Installation

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  drawer_rail: ^0.4.0
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

Reading state — the distinction matters once hover is involved:

| Getter | Meaning |
| ------ | ------- |
| `collapsed` | The **pinned** state. This is the one to persist; hover never writes it. |
| `railCollapsed` | What is **on screen right now**. Use it for layout that must line up with the drawer's real width. |
| `hoverPeeking` | A collapsed rail is currently held open by the pointer. Transient. |
| `hoverHidden` | An expanded panel is currently held shut by the pointer having left. Transient. |

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

    // Activation: click (default) or hover, for web/desktop
    railTrigger: DrawerActivationMode.hover,  // pointer peeks the rail open
    groupTrigger: DrawerActivationMode.hover, // pointer opens groups/flyouts
    linkTrigger: DrawerActivationMode.click,  // hover here also navigates
    railAutoCollapse: true,                   // leaving also closes it again
    hoverOpenDelay: Duration(milliseconds: 120),
    hoverCloseDelay: Duration(milliseconds: 220),
    hoverSelectDelay: Duration(milliseconds: 300),
    hoverAutoCollapseDelay: Duration(milliseconds: 450),

    // Cursors
    clickableCursor: SystemMouseCursors.click,
    inertCursor: SystemMouseCursors.basic,

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
    groupAnimationCurve: Curves.easeOutCubic,
    hoverAnimationDuration: Duration(milliseconds: 160),
    hoverAnimationCurve: Curves.easeOut,
    pressedScale: 0.97,
  ),
);
```

Already have a theme and only want to change a few things? Use `copyWith`:

```dart
const brand = DrawerRailTheme(selectedColor: Color(0xFF6366F1));

DrawerRail(
  theme: brand.copyWith(railWidth: 88, position: DrawerRailPosition.right),
  // ...
);
```

### What each field actually does

Every row says **what the option turns on and what visibly moves** when you
change it. Defaults in parentheses.

#### Sizing & layout

| Field | What it changes |
| ----- | --------------- |
| `expandedWidth` (`300`) | Width of the full panel. The drawer animates *to* this number when expanded. |
| `railWidth` (`76`) | Width of the icon rail. The collapse animation runs between these two numbers. |
| `railItemHeight` (`44`) | Height of each rail icon button — the rail's vertical density. |
| `iconSize` (`20`) / `railIconSize` (`22`) | Icon size in the panel / in the rail. They differ because rail icons carry the meaning alone. |
| `borderRadius` (`24`) | Rounds the drawer's **inner** edge only — the side facing your content. The outer edge stays square against the window. |
| `itemBorderRadius` (`14`) | Rounds each item's hover/selected background, the search field and flyout menus. |
| `contentPadding` | Padding around the scrolling list as a whole. |
| `itemPadding` | Padding *inside* each item — the main lever for row height in the panel. |
| `groupChildIndent` (`24`) | How far a group's children are pushed right, so the hierarchy reads. |
| `position` (`left`) | Which side the drawer sits on. Flips which edge is rounded **and** which way the default shadow falls. It does **not** reorder your `Row` — do that yourself. |

#### Colors

| Field | What it changes |
| ----- | --------------- |
| `backgroundColor` (`surface`) | The drawer surface. Also used as the opaque backing behind a lifted item, so hover shadows read as elevation instead of haze. |
| `selectedColor` (`primary`) | Fill of the selected pill, and the badge dot in the rail. |
| `onSelectedColor` (`onPrimary`) | Icon and label color *on top of* the selected pill. |
| `iconColor` / `labelColor` (`onSurface`) | Unselected icon / label color. Overridden by the error color on `danger: true` links. |
| `sectionColor` (`primary`) | Section header color. Ignored if `sectionTextStyle` already sets a color. |
| `badgeTextColor` / `badgeCountColor` | Background of a `DrawerBadge.text` pill / a `DrawerBadge.count` pill. Foregrounds are derived automatically. |
| `menuBackgroundColor` | Background of the flyout menu a group opens in the collapsed rail. |
| `searchFillColor` | Fill of the built-in search field. Ignored if you pass your own `searchDecoration`. |
| `shadow` | The drawer's own drop shadow. Defaults to a soft shadow on the outer edge; pass `[]` for a flat look. |

#### Hover feedback (how an item reacts under the pointer)

| Field | What it changes |
| ----- | --------------- |
| `hoverEffect` (`shadow`) | `shadow` lifts the item on an opaque surface, `highlight` tints its background flat, `none` disables both. The press micro-scale still runs in all three. |
| `hoverShadowColor` | Color of the lift shadow. Only read in `shadow` mode. |
| `hoverHighlightColor` | The background tint. Only read in `highlight` mode. |
| `hoverAnimationDuration` (`160ms`) | How long that shadow/tint takes to fade **in and out**. Set to `Duration.zero` to snap. |
| `hoverAnimationCurve` (`easeOut`) | The curve of that fade. |
| `pressedScale` (`0.97`) | How far an item shrinks while held. It springs back with a slight overshoot on release. |

#### Activation (what opens things — click or pointer)

| Field | What it turns on |
| ----- | ---------------- |
| `railTrigger` (`click`) | Set to `hover` and the collapsed rail **expands when the pointer enters it** and collapses again when it leaves. A temporary peek — it never writes `controller.collapsed`. |
| `groupTrigger` (`click`) | Set to `hover` and groups open under the pointer: inline in the panel, as a flyout in the rail. |
| `linkTrigger` (`click`) | Set to `hover` and resting on a link **runs its `onTap`** — navigation included. See the warning below. |
| `railAutoCollapse` (`false`) | Only with `railTrigger: hover`. Also closes a drawer the user left **expanded** when the pointer leaves, making hover fully symmetric. Off by default because it takes away a panel someone deliberately pinned. |
| `hoverOpenDelay` (`120ms`) | How long the pointer must rest before a hover-open fires. Raise it if the drawer feels twitchy. |
| `hoverCloseDelay` (`220ms`) | Grace period after the pointer leaves. Long enough to cross the gap from a rail button to its flyout without the menu slamming shut. |
| `hoverSelectDelay` (`300ms`) | Dwell required before `linkTrigger: hover` navigates. Longer on purpose — the action is not undoable. |
| `hoverAutoCollapseDelay` (`450ms`) | Grace period before `railAutoCollapse` closes a pinned-open drawer. Longest of the four, because most is at stake. |

#### Cursors

| Field | What it changes |
| ----- | --------------- |
| `clickableCursor` (`click`) | The cursor over every link, group header, rail button and flyout item. |
| `inertCursor` (`basic`) | The cursor over the drawer's non-interactive chrome — background, section headers, dividers. This is what makes the pointer **revert** when it leaves an item instead of dragging the hand cursor around. |

#### Text & icons

| Field | What it changes |
| ----- | --------------- |
| `labelTextStyle` / `selectedLabelTextStyle` | Item label style, unselected / selected. Colors are applied per state on top, so setting a color here is usually pointless. |
| `sectionTextStyle` | Section header style. Unlike the others, a color set here **is** respected. |
| `badgeTextStyle` | Badge label style. |
| `sectionUppercase` (`true`) | Uppercases section labels for display. Your string is untouched — search still matches the original. |
| `collapseIcon` / `expandIcon` | The chrome toggle in each state. Flip them for a right-side drawer, or they point the wrong way. |
| `searchIcon` / `clearSearchIcon` | Search field leading icon / the clear button that appears once you type. |
| `groupTrailingIcon` | The chevron on a group header. It rotates 180° when the group opens. |

#### Motion

| Field | What it changes |
| ----- | --------------- |
| `animationDuration` (`240ms`) / `animationCurve` (`easeOutCubic`) | The panel ↔ rail width animation. |
| `groupAnimationDuration` (`200ms`) / `groupAnimationCurve` (`easeOutCubic`) | The group unfold **and** its chevron rotation. Try `Curves.easeOutBack` for a little overshoot. |

> **Reduce motion is automatic.** When the OS asks for reduced animations
> (`MediaQuery.disableAnimations`), every duration above collapses to zero and
> the drawer snaps between states. The hover *delays* are deliberately kept —
> they gate an interaction, not a motion effect, and zeroing them would make the
> drawer fire on the slightest twitch.

## Opening and closing on hover (web & desktop)

By default everything is driven by clicks. To make the drawer open and close by
itself under the mouse, use the preset:

```dart
DrawerRail(
  controller: _controller,
  entries: _entries,
  theme: DrawerRailTheme.hoverAdaptive(),
);
```

That single line switches the rail and groups to hover and turns on
`railAutoCollapse`, so:

| You do this | The drawer does this |
| ----------- | -------------------- |
| Move the pointer onto the rail | Expands to the full panel after `hoverOpenDelay` |
| Move the pointer away | Collapses back after `hoverCloseDelay` (or `hoverAutoCollapseDelay` if it was pinned open) |
| Rest on a group | Opens it inline, or as a flyout in the rail |
| Click the collapse button | **Pins** that state — hover stops fighting you until you move away and back |
| Tap anything on a touch device | Works exactly as before; hover events never fire there |

Layer it on top of your own styling with `base`, and turn the closing half off
if you only want hover to *open*:

```dart
DrawerRailTheme.hoverAdaptive(
  base: const DrawerRailTheme(hoverEffect: DrawerHoverEffect.highlight),
  autoCollapse: false,
  openDelay: const Duration(milliseconds: 80),
)
```

Or wire the three triggers by hand for full control:

```dart
const DrawerRailTheme(
  railTrigger: DrawerActivationMode.hover,   // rail expands while hovered
  groupTrigger: DrawerActivationMode.hover,  // groups & flyouts open on hover
  railAutoCollapse: true,                    // and closes again on exit
)
```

### Rules worth knowing

- **Hover never replaces the click.** Every item stays tappable in every mode,
  so touch users — where hover events simply never fire — are never locked out.
- **Hover never writes `controller.collapsed`.** A peek widens the drawer and an
  auto-collapse narrows it, both temporarily. The pinned state you persist stays
  untouched, so someone brushing past the drawer never rewrites their saved
  preference. Read `controller.railCollapsed` for the width actually on screen,
  and keep persisting `collapsed`.
- **An explicit click always wins.** Hitting collapse/expand cancels any hover
  timer in flight, so a pending peek cannot undo your click a frame later.
- **A group you opened by clicking stays open** when the pointer leaves. Only
  groups that hover itself opened are closed again — including when the whole
  panel closes, so nothing is left hanging open for next time.

### The one to be careful with

`linkTrigger: DrawerActivationMode.hover` resting on a link for
`hoverSelectDelay` runs its `onTap`, navigation included. On a dense menu that
can move the user somewhere they only meant to pass over, and there is no
keyboard equivalent to undo it. The dwell delay makes it unlikely, not
impossible. `hoverAdaptive` deliberately leaves this on `click` — only turn it
on if pointer-driven navigation is genuinely what you want.

## Cursors

The pointer becomes a hand over anything clickable and reverts to an arrow over
the drawer's own chrome. That is on by default and needs no configuration, but
both halves are themeable:

```dart
const DrawerRailTheme(
  clickableCursor: SystemMouseCursors.click, // links, groups, rail buttons
  inertCursor: SystemMouseCursors.basic,     // background, sections, dividers
)
```

`AnimatedPressCard` is exported, so custom header/footer content can get the
same cursor and press behavior as the built-in items.

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

A complete, runnable example lives in [`example/`](example/lib/main.dart): a
header logo, a dark-mode footer toggle, badges, a group, and switches that flip
**Open on hover** and **Close on exit** live, so you can feel the difference
between click-driven and pointer-driven rather than guess at it. There is also a
button that swaps to a fully custom right-side theme.

```bash
cd example
flutter run -d chrome   # hover behavior needs a pointer device
```

## Contributing

Contributions are welcome from everyone! Fork the repo, create a branch, and
open a pull request. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first and
follow the [Code of Conduct](CODE_OF_CONDUCT.md).

Good first steps: open an issue for bugs or ideas, improve the docs, or add
tests.

## License

MIT — see [LICENSE](LICENSE).
