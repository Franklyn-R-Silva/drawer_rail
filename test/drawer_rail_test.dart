import 'package:drawer_rail/drawer_rail.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DrawerBadge', () {
    test('text badge exposes its label and is not a count', () {
      const badge = DrawerBadge.text('New');
      expect(badge.label, 'New');
      expect(badge.isCount, isFalse);
    });

    test('count badge hides when zero and clamps above 99', () {
      expect(const DrawerBadge.count(0).label, isNull);
      expect(const DrawerBadge.count(4).label, '4');
      expect(const DrawerBadge.count(150).label, '99+');
      expect(const DrawerBadge.count(4).isCount, isTrue);
    });

    test('badges compare by value', () {
      expect(const DrawerBadge.text('New'), const DrawerBadge.text('New'));
      expect(const DrawerBadge.count(4), const DrawerBadge.count(4));
      expect(
        const DrawerBadge.text('New'),
        isNot(const DrawerBadge.text('Beta')),
      );
      expect(const DrawerBadge.count(4), isNot(const DrawerBadge.text('4')));
      expect(
        const DrawerBadge.count(4).hashCode,
        const DrawerBadge.count(4).hashCode,
      );
    });
  });

  group('DrawerRailLabels', () {
    test('copyWith replaces only what it is given', () {
      const labels = DrawerRailLabels(searchHint: 'Buscar...');
      final translated = labels.copyWith(noResults: 'Nenhum resultado');

      expect(translated.searchHint, 'Buscar...');
      expect(translated.noResults, 'Nenhum resultado');
      expect(translated.expandTooltip, labels.expandTooltip);
    });

    test('labels compare by value', () {
      expect(
        const DrawerRailLabels(searchHint: 'a'),
        const DrawerRailLabels(searchHint: 'a'),
      );
      expect(
        const DrawerRailLabels(searchHint: 'a'),
        isNot(const DrawerRailLabels(searchHint: 'b')),
      );
    });
  });

  group('DrawerRailController', () {
    test('notifies on collapse, selection and group toggles', () {
      final controller = DrawerRailController();
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggleCollapsed();
      expect(controller.collapsed, isTrue);

      controller.select('a');
      expect(controller.selectedId, 'a');

      controller.toggleGroup('g');
      expect(controller.isGroupExpanded('g'), isTrue);

      expect(notifications, 3);
    });

    test('does not notify when setting the same value', () {
      final controller = DrawerRailController(collapsed: true);
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.setCollapsed(true);

      expect(notifications, 0);
    });

    test('hover peek widens the rail without touching collapsed', () {
      final controller = DrawerRailController(collapsed: true);
      addTearDown(controller.dispose);

      controller.setHoverPeek(true);
      expect(controller.hoverPeeking, isTrue);
      expect(controller.railCollapsed, isFalse, reason: 'peeked open');
      expect(
        controller.collapsed,
        isTrue,
        reason: 'the persisted preference must survive a peek',
      );

      controller.setHoverPeek(false);
      expect(controller.railCollapsed, isTrue);
    });

    test('an explicit collapse drops a peek in flight', () {
      final controller = DrawerRailController(collapsed: true);
      addTearDown(controller.dispose);
      controller.setHoverPeek(true);

      controller.setCollapsed(true);

      expect(controller.hoverPeeking, isFalse);
      expect(controller.railCollapsed, isTrue);
    });

    test('hover hide narrows the panel without touching collapsed', () {
      final controller = DrawerRailController();
      addTearDown(controller.dispose);

      controller.setHoverHidden(true);
      expect(controller.hoverHidden, isTrue);
      expect(controller.railCollapsed, isTrue, reason: 'hidden by hover');
      expect(
        controller.collapsed,
        isFalse,
        reason: 'the persisted preference must survive an auto-hide',
      );

      controller.setHoverHidden(false);
      expect(controller.railCollapsed, isFalse);
    });

    test('an explicit expand drops an auto-hide in flight', () {
      final controller = DrawerRailController();
      addTearDown(controller.dispose);
      controller.setHoverHidden(true);

      controller.setCollapsed(false);

      expect(controller.hoverHidden, isFalse);
      expect(controller.railCollapsed, isFalse);
    });

    test('setGroupExpanded is idempotent', () {
      final controller = DrawerRailController();
      addTearDown(controller.dispose);

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.setGroupExpanded('g', true);
      controller.setGroupExpanded('g', true);
      expect(controller.isGroupExpanded('g'), isTrue);
      expect(notifications, 1, reason: 'the second call changed nothing');

      controller.setGroupExpanded('g', false);
      expect(controller.isGroupExpanded('g'), isFalse);
      expect(notifications, 2);
    });
  });

  group('DrawerRailController.resetHoverState', () {
    test('clears both hover flags without touching the pinned state', () {
      final controller = DrawerRailController(collapsed: true);
      addTearDown(controller.dispose);
      controller.setHoverPeek(true);

      var notifications = 0;
      controller.addListener(() => notifications++);
      controller.resetHoverState();

      expect(controller.hoverPeeking, isFalse);
      expect(controller.collapsed, isTrue);
      expect(notifications, 1);

      controller.resetHoverState();
      expect(notifications, 1, reason: 'nothing left to clear');
    });

    test('is a no-op once the controller is disposed', () {
      final controller = DrawerRailController();
      controller.setHoverHidden(true);
      controller.dispose();

      // Teardown order is the caller's to choose, so this must not throw.
      expect(controller.resetHoverState, returnsNormally);
    });
  });

  group('DrawerRailTheme', () {
    test('copyWith replaces only what it is given', () {
      const base = DrawerRailTheme(expandedWidth: 400, railWidth: 60);
      final copy = base.copyWith(railWidth: 90);

      expect(copy.railWidth, 90);
      expect(copy.expandedWidth, 400, reason: 'untouched fields carry over');
    });

    test('hoverAdaptive turns on rail and group hover but never links', () {
      final theme = DrawerRailTheme.hoverAdaptive();

      expect(theme.railTrigger, DrawerActivationMode.hover);
      expect(theme.groupTrigger, DrawerActivationMode.hover);
      expect(theme.railAutoCollapse, isTrue);
      expect(
        theme.linkTrigger,
        DrawerActivationMode.click,
        reason: 'navigating on dwell is opt-in only — it is an a11y hazard',
      );
    });

    test('hoverAdaptive layers over a base theme', () {
      final theme = DrawerRailTheme.hoverAdaptive(
        base: const DrawerRailTheme(hoverEffect: DrawerHoverEffect.highlight),
        autoCollapse: false,
      );

      expect(theme.hoverEffect, DrawerHoverEffect.highlight);
      expect(theme.railTrigger, DrawerActivationMode.hover);
      expect(theme.railAutoCollapse, isFalse);
    });

    test('reduceMotion zeroes durations but keeps hover dwell delays', () {
      const theme = DrawerRailTheme();
      final resolved = theme.resolve(
        const ColorScheme.light(),
        reduceMotion: true,
      );

      expect(resolved.animationDuration, Duration.zero);
      expect(resolved.groupAnimationDuration, Duration.zero);
      expect(resolved.hoverAnimationDuration, Duration.zero);
      expect(
        resolved.hoverOpenDelay,
        const Duration(milliseconds: 120),
        reason: 'a dwell delay gates an interaction, not a motion effect',
      );
    });
  });

  group('DrawerRail widget', () {
    late DrawerRailController controller;

    setUp(() => controller = DrawerRailController());
    tearDown(() => controller.dispose());

    List<DrawerEntry> entries() => [
          const DrawerSection('Main'),
          DrawerLink(
            id: 'home',
            icon: Icons.home,
            label: 'Home',
            onTap: (_) {},
          ),
          DrawerLink(
            id: 'settings',
            icon: Icons.settings,
            label: 'Settings',
            onTap: (_) {},
          ),
        ];

    testWidgets('renders entries and selects on tap', (tester) async {
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: entries())),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(controller.selectedId, 'settings');
    });

    testWidgets('collapses to the rail and hides labels', (tester) async {
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: entries())),
      );

      controller.setCollapsed(true);
      await tester.pumpAndSettle();

      // Labels are replaced by tooltips in the rail.
      expect(find.text('Home'), findsNothing);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('search filters entries', (tester) async {
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: entries())),
      );

      await tester.enterText(find.byType(TextField), 'sett');
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('showSearch:false hides the search field and rail button',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            showSearch: false,
          ),
        ),
      );

      // No search field in the expanded panel.
      expect(find.byType(TextField), findsNothing);

      // No search button in the collapsed rail either.
      controller.setCollapsed(true);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search_rounded), findsNothing);
    });

    // The unhovered card must never paint a shadow, whichever effect is set —
    // this guards against a shadow bleeding through as a colored haze.
    // AnimatedPressCard fades its hover decoration in, so that decoration lives
    // on an AnimatedContainer; matching a plain Container here would find only
    // the inner padding box and pass vacuously.
    bool anyPressCardHasShadow(WidgetTester tester) {
      final containers = find.descendant(
        of: find.byType(AnimatedPressCard),
        matching: find.byType(AnimatedContainer),
      );
      expect(
        containers,
        findsWidgets,
        reason: 'no AnimatedContainer under AnimatedPressCard — the check '
            'would be vacuously true',
      );
      for (final c in tester.widgetList<AnimatedContainer>(containers)) {
        final deco = c.decoration;
        if (deco is BoxDecoration && (deco.boxShadow?.isNotEmpty ?? false)) {
          return true;
        }
      }
      return false;
    }

    testWidgets('hoverEffect.none never paints a hover shadow', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(hoverEffect: DrawerHoverEffect.none),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(anyPressCardHasShadow(tester), isFalse);
    });

    testWidgets('hoverEffect.highlight never paints a hover shadow',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              hoverEffect: DrawerHoverEffect.highlight,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(anyPressCardHasShadow(tester), isFalse);
    });

    testWidgets('applies custom theme icons and section casing',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              expandIcon: Icons.arrow_forward,
              sectionUppercase: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Custom expand icon is used in the collapsed rail header.
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
    });

    testWidgets('keeps original section casing when uppercase is off',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(sectionUppercase: false),
          ),
        ),
      );

      expect(find.text('Main'), findsOneWidget);
      expect(find.text('MAIN'), findsNothing);
    });

    // Finds the drawer's own outer container: the one whose border radius has
    // a single rounded side (the AnimatedPressCard containers round all sides).
    BorderRadius drawerEdgeRadius(WidgetTester tester) {
      for (final c in tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      )) {
        final deco = c.decoration;
        if (deco is BoxDecoration && deco.borderRadius is BorderRadius) {
          final br = deco.borderRadius! as BorderRadius;
          if (br.topLeft != br.topRight) return br;
        }
      }
      fail('drawer outer container not found');
    }

    testWidgets('rounds the right edge when positioned left', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(borderRadius: 24),
          ),
        ),
      );

      final br = drawerEdgeRadius(tester);
      expect(br.topRight, const Radius.circular(24));
      expect(br.bottomRight, const Radius.circular(24));
      expect(br.topLeft, Radius.zero);
      expect(br.bottomLeft, Radius.zero);
    });

    // ---- Hover activation (DrawerActivationMode) --------------------------

    List<DrawerEntry> groupedEntries() => [
          DrawerGroup(
            id: 'reports',
            icon: Icons.bar_chart,
            label: 'Reports',
            children: [
              DrawerLink(
                id: 'sales',
                icon: Icons.attach_money,
                label: 'Sales',
                onTap: (_) {},
              ),
            ],
          ),
        ];

    /// Two groups, for the cases where the pointer moves from one to the next.
    List<DrawerEntry> twoGroups() => [
          ...groupedEntries(),
          DrawerGroup(
            id: 'admin',
            icon: Icons.security,
            label: 'Admin',
            children: [
              DrawerLink(
                id: 'users',
                icon: Icons.person,
                label: 'Users',
                onTap: (_) {},
              ),
            ],
          ),
        ];

    double drawerWidth(WidgetTester tester) =>
        tester.getSize(find.byType(DrawerRail)).width;

    /// Parks a mouse pointer on [target]. Returns the gesture so the caller can
    /// move it away again.
    Future<TestGesture> hoverOver(WidgetTester tester, Finder target) async {
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);
      await tester.pump();
      await gesture.moveTo(tester.getCenter(target));
      await tester.pump();
      return gesture;
    }

    testWidgets('railTrigger.hover peeks the rail open, then closes on exit',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              railTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(drawerWidth(tester), 76);

      final gesture = await hoverOver(tester, find.byType(DrawerRail));
      await tester.pump(const Duration(milliseconds: 200)); // > openDelay 120
      await tester.pumpAndSettle();

      expect(drawerWidth(tester), 300);
      expect(
        controller.collapsed,
        isTrue,
        reason: 'a peek must not rewrite the pinned state',
      );

      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 300)); // > closeDelay 220
      await tester.pumpAndSettle();

      expect(drawerWidth(tester), 76);
    });

    testWidgets('railTrigger defaults to click and ignores hover',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: entries())),
      );
      await tester.pumpAndSettle();

      await hoverOver(tester, find.byType(DrawerRail));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(drawerWidth(tester), 76);
      expect(controller.hoverPeeking, isFalse);
    });

    testWidgets('groupTrigger.hover opens an inline group', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: groupedEntries(),
            theme: const DrawerRailTheme(
              groupTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.isGroupExpanded('reports'), isFalse);

      final gesture = await hoverOver(tester, find.text('Reports'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(controller.isGroupExpanded('reports'), isTrue);

      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(
        controller.isGroupExpanded('reports'),
        isFalse,
        reason: 'hover opened it, so leaving closes it',
      );
    });

    testWidgets('groupTrigger.hover opens the rail flyout', (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: groupedEntries(),
            theme: const DrawerRailTheme(
              groupTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sales'), findsNothing);

      final gesture = await hoverOver(tester, find.byIcon(Icons.bar_chart));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Sales'), findsOneWidget, reason: 'flyout is open');

      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();
      expect(find.text('Sales'), findsNothing);
    });

    testWidgets('a group opened by clicking survives the pointer leaving',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: groupedEntries(),
            theme: const DrawerRailTheme(
              groupTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reports'));
      await tester.pumpAndSettle();
      expect(controller.isGroupExpanded('reports'), isTrue);

      final gesture = await hoverOver(tester, find.text('Reports'));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(controller.isGroupExpanded('reports'), isTrue);
    });

    testWidgets('linkTrigger.hover activates only after the dwell delay',
        (tester) async {
      var opened = 0;
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: [
              DrawerLink(
                id: 'home',
                icon: Icons.home,
                label: 'Home',
                onTap: (_) => opened++,
              ),
            ],
            theme: const DrawerRailTheme(
              linkTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );

      // Passing through: nowhere near the 300ms dwell.
      final gesture = await hoverOver(tester, find.text('Home'));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 400));
      expect(controller.selectedId, isNull);
      expect(opened, 0);

      // Resting on it: fires once, navigation included.
      await gesture.moveTo(tester.getCenter(find.text('Home')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(controller.selectedId, 'home');
      expect(opened, 1);
    });

    testWidgets('linkTrigger defaults to click and ignores hover',
        (tester) async {
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: entries())),
      );

      await hoverOver(tester, find.text('Settings'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(controller.selectedId, isNull);
    });

    testWidgets('railAutoCollapse hides a drawer the user left expanded',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: DrawerRailTheme.hoverAdaptive(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(drawerWidth(tester), 300, reason: 'starts pinned open');

      final gesture = await hoverOver(tester, find.byType(DrawerRail));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(drawerWidth(tester), 300, reason: 'entering keeps it open');

      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 600)); // > 450ms
      await tester.pumpAndSettle();

      expect(drawerWidth(tester), 76, reason: 'leaving auto-collapses it');
      expect(
        controller.collapsed,
        isFalse,
        reason: 'an auto-hide must not rewrite the pinned state',
      );
      expect(controller.hoverHidden, isTrue);

      // Coming back reveals it again, symmetrically.
      await gesture.moveTo(tester.getCenter(find.byType(DrawerRail)));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(drawerWidth(tester), 300);
    });

    testWidgets('railAutoCollapse is off by default, so hover never closes it',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              railTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await hoverOver(tester, find.byType(DrawerRail));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      expect(drawerWidth(tester), 300);
      expect(controller.hoverHidden, isFalse);
    });

    testWidgets('a group hover opened closes again when the peek ends',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: groupedEntries(),
            theme: DrawerRailTheme.hoverAdaptive(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Peek the rail open, then hover the group inside it.
      final gesture = await hoverOver(tester, find.byType(DrawerRail));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      await gesture.moveTo(tester.getCenter(find.text('Reports')));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(controller.isGroupExpanded('reports'), isTrue);

      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(drawerWidth(tester), 76);
      expect(
        controller.isGroupExpanded('reports'),
        isFalse,
        reason: 'it must not still be open the next time the panel is shown',
      );
    });

    // ---- Cursors ----------------------------------------------------------

    testWidgets('clickable items get the click cursor, chrome gets basic',
        (tester) async {
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: entries())),
      );
      await tester.pumpAndSettle();

      final inkWells = tester.widgetList<InkWell>(
        find.descendant(
          of: find.byType(AnimatedPressCard),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWells, isNotEmpty);
      for (final ink in inkWells) {
        expect(ink.mouseCursor, SystemMouseCursors.click);
      }

      // The drawer's own background states the arrow, so the pointer reverts
      // instead of carrying the hand cursor off an item.
      final region = tester.widget<MouseRegion>(
        find
            .descendant(
              of: find.byType(DrawerRail),
              matching: find.byType(MouseRegion),
            )
            .first,
      );
      expect(region.cursor, SystemMouseCursors.basic);
    });

    testWidgets('the cursor pair is themeable', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              clickableCursor: SystemMouseCursors.grab,
              inertCursor: SystemMouseCursors.forbidden,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ink = tester
          .widgetList<InkWell>(
            find.descendant(
              of: find.byType(AnimatedPressCard),
              matching: find.byType(InkWell),
            ),
          )
          .first;
      expect(ink.mouseCursor, SystemMouseCursors.grab);
    });

    // ---- Motion -----------------------------------------------------------

    testWidgets('reduced motion zeroes animation durations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: DrawerRail(controller: controller, entries: entries()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final drawer = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .firstWhere((c) {
        final deco = c.decoration;
        return deco is BoxDecoration &&
            deco.borderRadius is BorderRadius &&
            (deco.borderRadius! as BorderRadius).topLeft !=
                (deco.borderRadius! as BorderRadius).topRight;
      });
      expect(drawer.duration, Duration.zero);

      // The collapse is then instant rather than a 240ms slide.
      controller.setCollapsed(true);
      await tester.pump();
      expect(drawerWidth(tester), 76);
    });

    // ---- Sweeping from one group to the next ------------------------------

    testWidgets('leaving one inline group for the next closes the first',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: twoGroups(),
            theme: const DrawerRailTheme(
              groupTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await hoverOver(tester, find.text('Reports'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(controller.isGroupExpanded('reports'), isTrue);

      await gesture.moveTo(tester.getCenter(find.text('Admin')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(controller.isGroupExpanded('admin'), isTrue);
      expect(
        controller.isGroupExpanded('reports'),
        isFalse,
        reason: 'one shared timer used to drop the pending close of the group '
            'the pointer had just left, stranding it open',
      );
    });

    testWidgets('moving down the rail swaps the flyout instead of stacking one',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: twoGroups(),
            theme: const DrawerRailTheme(
              groupTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await hoverOver(tester, find.byIcon(Icons.bar_chart));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Sales'), findsOneWidget);

      await gesture.moveTo(tester.getCenter(find.byIcon(Icons.security)));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(find.text('Users'), findsOneWidget);
      expect(
        find.text('Sales'),
        findsNothing,
        reason: 'only one flyout at a time',
      );
    });

    testWidgets('a rail flyout opens clear of the buttons below it',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: twoGroups())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      final flyout = tester.getRect(
        find
            .ancestor(
              of: find.text('Sales'),
              matching: find.byType(MenuItemButton),
            )
            .first,
      );
      final railRight = tester.getRect(find.byType(DrawerRail)).right;

      expect(
        flyout.left,
        greaterThanOrEqualTo(railRight - 8),
        reason: 'the flyout used to drop straight over the next rail button, '
            'putting the group underneath out of reach',
      );
    });

    testWidgets('a group with no children opens no empty flyout',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: const [
              DrawerGroup(
                id: 'empty',
                icon: Icons.folder,
                label: 'Empty',
                children: [],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.folder));
      await tester.pumpAndSettle();

      expect(find.byType(MenuItemButton), findsNothing);
    });

    // ---- Layout -----------------------------------------------------------

    testWidgets('content stays anchored to the fixed edge while animating',
        (tester) async {
      for (final position in DrawerRailPosition.values) {
        final onRight = position == DrawerRailPosition.right;
        final local = DrawerRailController();
        addTearDown(local.dispose);

        await tester.pumpWidget(
          _wrap(
            Row(
              children: [
                if (onRight) const Expanded(child: SizedBox.expand()),
                DrawerRail(
                  controller: local,
                  entries: entries(),
                  theme: DrawerRailTheme(position: position),
                ),
                if (!onRight) const Expanded(child: SizedBox.expand()),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        local.setCollapsed(true);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));

        final drawer = tester.getRect(find.byType(DrawerRail));
        final icon = tester.getRect(find.byIcon(Icons.home));
        final fixedEdgeGap =
            onRight ? drawer.right - icon.right : icon.left - drawer.left;
        final movingEdgeGap =
            onRight ? icon.left - drawer.left : drawer.right - icon.right;
        await tester.pumpAndSettle();

        expect(
          fixedEdgeGap,
          lessThan(movingEdgeGap),
          reason: 'with $position the rail must be revealed against the edge '
              'that does not move; the content used to be laid out at the '
              'animating width and centred, so every item slid sideways',
        );
      }
    });

    // ---- Search -----------------------------------------------------------

    testWidgets('searching a group name offers all of its children',
        (tester) async {
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: groupedEntries())),
      );

      await tester.enterText(find.byType(TextField), 'repo');
      await tester.pumpAndSettle();

      expect(
        find.text('Sales'),
        findsOneWidget,
        reason: 'a group used to be searchable only through its children',
      );
    });

    testWidgets('pinning the drawer collapsed drops a running search',
        (tester) async {
      await tester.pumpWidget(
        _wrap(DrawerRail(controller: controller, entries: entries())),
      );

      await tester.enterText(find.byType(TextField), 'sett');
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsNothing);

      controller.setCollapsed(true);
      await tester.pumpAndSettle();
      controller.setCollapsed(false);
      await tester.pumpAndSettle();

      expect(
        find.text('Home'),
        findsOneWidget,
        reason: 'a query left running behind the rail silently filtered the '
            'panel the next time it opened',
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty,
      );
    });

    testWidgets('a hover peek does not throw away what was typed',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              railTrigger: DrawerActivationMode.hover,
              railAutoCollapse: true,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'sett');
      await tester.pumpAndSettle();

      final gesture = await hoverOver(tester, find.byType(DrawerRail));
      await gesture.moveTo(const Offset(2000, 2000));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(controller.hoverHidden, isTrue, reason: 'auto-hidden to the rail');

      // Back in: the panel returns, and so should the query.
      await gesture.moveTo(tester.getCenter(find.byType(DrawerRail)));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        'sett',
        reason: 'an auto-hide is transient and must not clear the field',
      );
      expect(find.text('Home'), findsNothing, reason: 'still filtered');
    });

    // ---- Press feedback ---------------------------------------------------

    /// The on-screen width of [finder], transforms included. [getSize] reports
    /// layout size and so is blind to a [Transform.scale].
    double renderedWidth(WidgetTester tester, Finder finder) =>
        tester.getRect(finder).width;

    testWidgets('a changed pressedScale takes effect on the next press',
        (tester) async {
      Widget build(double scale) => _wrap(
            Center(
              child: AnimatedPressCard(
                pressedScale: scale,
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.zero,
                  child: SizedBox(width: 100, height: 40),
                ),
              ),
            ),
          );

      await tester.pumpWidget(build(0.97));
      await tester.pumpWidget(build(0.5));
      await tester.pump();

      final inner = find
          .descendant(
            of: find.byType(AnimatedPressCard),
            matching: find.byType(Padding),
          )
          .last;
      final restWidth = renderedWidth(tester, inner);

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(SizedBox)));
      // The first pump fires the tap-down deadline; the ticker advances after.
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 200));
      final pressedWidth = renderedWidth(tester, inner);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        pressedWidth / restWidth,
        closeTo(0.5, 0.02),
        reason: 'the tween used to be built once in initState, so a theme '
            'change went unnoticed for the life of the card',
      );
    });

    testWidgets('reduced motion stops items shrinking under the pointer',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: DrawerRail(controller: controller, entries: entries()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final card = find.byType(AnimatedPressCard).first;
      final inner =
          find.descendant(of: card, matching: find.byType(Container)).first;
      final restWidth = renderedWidth(tester, inner);

      final gesture = await tester.startGesture(tester.getCenter(card));
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 200));
      final pressedWidth = renderedWidth(tester, inner);
      await gesture.up();
      await tester.pumpAndSettle();

      expect(
        pressedWidth,
        restWidth,
        reason: 'a scale is movement, so reduced motion switches it off '
            'outright rather than merely running it faster',
      );
    });

    // ---- Teardown ---------------------------------------------------------

    testWidgets('disposing mid-peek hands the controller back unpeeked',
        (tester) async {
      controller.setCollapsed(true);
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              railTrigger: DrawerActivationMode.hover,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await hoverOver(tester, find.byType(DrawerRail));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(controller.hoverPeeking, isTrue);

      // Navigate away while the peek is live.
      await tester.pumpWidget(_wrap(const Text('somewhere else')));
      await tester.pumpAndSettle();

      expect(controller.hoverPeeking, isFalse);
      expect(
        controller.railCollapsed,
        isTrue,
        reason: 'a controller outliving the drawer used to report the wrong '
            'rail state for good',
      );
      await gesture.moveTo(const Offset(2000, 2000));
    });

    testWidgets('rounds the left edge when positioned right', (tester) async {
      await tester.pumpWidget(
        _wrap(
          DrawerRail(
            controller: controller,
            entries: entries(),
            theme: const DrawerRailTheme(
              borderRadius: 24,
              position: DrawerRailPosition.right,
            ),
          ),
        ),
      );

      final br = drawerEdgeRadius(tester);
      expect(br.topLeft, const Radius.circular(24));
      expect(br.bottomLeft, const Radius.circular(24));
      expect(br.topRight, Radius.zero);
      expect(br.bottomRight, Radius.zero);
    });
  });
}
