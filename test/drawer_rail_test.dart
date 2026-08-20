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
