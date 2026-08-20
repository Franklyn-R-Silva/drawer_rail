import 'package:drawer_rail/drawer_rail.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// Root of the example app. Owns the theme mode so the drawer's footer toggle
/// can flip the whole app between light and dark.
class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() => setState(
        () =>
            _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
      );

  @override
  Widget build(BuildContext context) {
    final seed = const Color(0xFF6366F1);
    return MaterialApp(
      title: 'drawer_rail example',
      debugShowCheckedModeBanner: false,
      themeMode: _mode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: HomePage(
        isDark: _mode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

/// A page with the drawer on the left and a content area that changes with the
/// selected entry.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = DrawerRailController(selectedId: 'dashboard');
  String _title = 'Dashboard';

  /// Toggles between the default left drawer and a fully custom right one.
  bool _customRight = false;

  /// Whether the pointer drives the drawer: hovering the rail expands it and
  /// hovering a group opens it, with no click needed.
  bool _hoverDriven = true;

  /// Whether leaving the drawer with the pointer also closes a drawer that was
  /// left expanded — the other half of "opens and closes by itself".
  bool _autoCollapse = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Simulate navigation by just updating the content area title.
  void _go(String title) => setState(() => _title = title);

  /// A fully customized theme placing the drawer on the right, with a green
  /// accent, wider layout, custom chrome icons and non-uppercase sections.
  static const _rightTheme = DrawerRailTheme(
    position: DrawerRailPosition.right,
    expandedWidth: 320,
    railWidth: 84,
    borderRadius: 32,
    itemBorderRadius: 12,
    railItemHeight: 48,
    iconSize: 22,
    railIconSize: 24,
    pressedScale: 0.95,
    // Use a flat background highlight on hover instead of the default shadow.
    hoverEffect: DrawerHoverEffect.highlight,
    // Snappier hover feedback than the 160ms default.
    hoverAnimationDuration: Duration(milliseconds: 120),
    sectionUppercase: false,
    selectedColor: Color(0xFF10B981),
    onSelectedColor: Colors.white,
    sectionColor: Color(0xFF10B981),
    badgeCountColor: Color(0xFFF43F5E),
    sectionTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    labelTextStyle: TextStyle(fontWeight: FontWeight.w600),
    // On a right-side drawer, flip the chevrons to point toward the edge.
    collapseIcon: Icons.chevron_right_rounded,
    expandIcon: Icons.chevron_left_rounded,
    groupTrailingIcon: Icons.expand_more_rounded,
    groupAnimationDuration: Duration(milliseconds: 260),
    // A little overshoot as a group unfolds, instead of the default ease-out.
    groupAnimationCurve: Curves.easeOutBack,
  );

  /// Layers the pointer behavior on top of whichever look is selected.
  ///
  /// `hoverAdaptive` is the one-line way to make the drawer pointer-driven:
  /// it switches the rail and groups to hover and leaves links on click, since
  /// navigating because the pointer paused somewhere is hostile. `copyWith`
  /// keeps everything else from the base theme untouched.
  DrawerRailTheme get _theme {
    final base = _customRight ? _rightTheme : const DrawerRailTheme();
    if (!_hoverDriven) return base;
    return DrawerRailTheme.hoverAdaptive(
      base: base,
      autoCollapse: _autoCollapse,
    );
  }

  List<DrawerEntry> get _entries => [
        const DrawerSection('Main'),
        DrawerLink(
          id: 'dashboard',
          icon: Icons.dashboard_outlined,
          label: 'Dashboard',
          onTap: (_) => _go('Dashboard'),
        ),
        DrawerLink(
          id: 'analytics',
          icon: Icons.bar_chart_rounded,
          label: 'Analytics',
          badge: const DrawerBadge.text('New'),
          onTap: (_) => _go('Analytics'),
        ),
        DrawerLink(
          id: 'notifications',
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: (_) => _go('Notifications'),
        ),
        DrawerLink(
          id: 'favourites',
          icon: Icons.star_outline_rounded,
          label: 'Favourites',
          onTap: (_) => _go('Favourites'),
        ),
        DrawerLink(
          id: 'payments',
          icon: Icons.account_balance_wallet_outlined,
          label: 'Payments',
          badge: const DrawerBadge.count(4),
          onTap: (_) => _go('Payments'),
        ),
        const DrawerSection('Workspace'),
        DrawerGroup(
          id: 'services',
          icon: Icons.apps_rounded,
          label: 'Services',
          children: [
            DrawerLink(
              id: 'it_consulting',
              icon: Icons.computer_rounded,
              label: 'IT Consulting',
              onTap: (_) => _go('IT Consulting'),
            ),
            DrawerLink(
              id: 'cloud',
              icon: Icons.cloud_outlined,
              label: 'Cloud Solutions',
              onTap: (_) => _go('Cloud Solutions'),
            ),
            DrawerLink(
              id: 'mobile',
              icon: Icons.phone_android_rounded,
              label: 'Mobile Apps',
              onTap: (_) => _go('Mobile Apps'),
            ),
          ],
        ),
        DrawerLink(
          id: 'settings',
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: (_) => _go('Settings'),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final drawer = DrawerRail(
      controller: _controller,
      entries: _entries,
      theme: _theme,
      headerBuilder: (context, collapsed) {
        final logo = CircleAvatar(
          radius: 20,
          backgroundColor: scheme.primary,
          child: Text(
            'DR',
            style: TextStyle(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
        if (collapsed) return logo;
        return Row(
          children: [
            logo,
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'drawer_rail',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
      footerBuilder: (context, collapsed) {
        if (collapsed) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: IconButton(
              tooltip: 'Dark mode',
              icon: Icon(
                widget.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
              ),
              onPressed: widget.onToggleTheme,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                widget.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Dark mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Switch(
                value: widget.isDark,
                onChanged: (_) => widget.onToggleTheme(),
              ),
            ],
          ),
        );
      },
    );

    final content = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                // Scale the button down if the content area is too narrow (e.g.
                // on a phone where the expanded drawer leaves little room), so
                // it never overflows.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: FilledButton.tonalIcon(
                    onPressed: () =>
                        setState(() => _customRight = !_customRight),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: Text(
                      _customRight
                          ? 'Default drawer (left)'
                          : 'Custom drawer (right)',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Flip the pointer behavior live, so the difference between
                // click-driven and hover-driven is something you can feel
                // rather than read about.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _hoverDriven,
                          onChanged: (v) => setState(() => _hoverDriven = v),
                          title: const Text('Open on hover'),
                          subtitle: const Text(
                            'The rail expands and groups open when the pointer '
                            'rests on them. Clicking still works.',
                          ),
                        ),
                        SwitchListTile(
                          value: _autoCollapse,
                          // Only meaningful while hover drives the drawer.
                          onChanged: _hoverDriven
                              ? (v) => setState(() => _autoCollapse = v)
                              : null,
                          title: const Text('Close on exit'),
                          subtitle: const Text(
                            'Leaving the drawer also collapses one you left '
                            'expanded, without rewriting the pinned state.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tip: the collapse button always wins — click it and the '
                  'drawer stays where you put it until you hover away again.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Order the row so the drawer sits on the side its theme declares.
    final onRight = _theme.position == DrawerRailPosition.right;
    return Scaffold(
      body: Row(
        children: onRight ? [content, drawer] : [drawer, content],
      ),
    );
  }
}
