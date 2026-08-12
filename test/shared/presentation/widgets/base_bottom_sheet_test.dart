import 'package:bcv_tracker_app/core/i18n/app_translations.dart';
import 'package:bcv_tracker_app/shared/presentation/widgets/base_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The shared bottom-sheet container, tested on its own: over a bare `Scaffold`
/// rather than a real page, so nothing but the sheet is under measurement.
///
/// It is shared by the currency detail (#38) and the converter's selector
/// (#40), so a regression here breaks both at once.
const String _label = 'Sheet under test';

/// Twenty rows: more than any extent can show, so the scrolling assertions have
/// something to scroll.
List<Widget> _rows() => <Widget>[
  SliverList.builder(
    itemCount: 20,
    itemBuilder: (BuildContext context, int index) =>
        SizedBox(height: 64, child: Center(child: Text('row $index'))),
  ),
];

Future<void> _pumpHost(WidgetTester tester) async {
  Get.testMode = true;
  await tester.pumpWidget(
    GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('en', 'US'),
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) => Center(
            child: TextButton(
              onPressed: () => showAppBottomSheet<void>(
                context: context,
                sheet: BaseBottomSheet(
                  semanticsLabel: _label,
                  slivers: _rows(),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Distance from the sheet's own top to the close button — the grab bar's
/// position *within* the sheet, which is what "pinned" means. Measuring against
/// the screen would only show the sheet moving up as it expands.
double _grabBarOffset(WidgetTester tester) =>
    tester.getRect(find.byIcon(Icons.close)).top -
    tester.getRect(find.byType(BaseBottomSheet)).top;

void main() {
  tearDown(Get.reset);

  testWidgets('opens anchored to the bottom edge', (tester) async {
    await _pumpHost(tester);
    await _open(tester);

    final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final Rect sheet = tester.getRect(find.byType(BaseBottomSheet));

    expect(sheet.bottom, moreOrLessEquals(screen.height, epsilon: 1));
    expect(
      sheet.height,
      moreOrLessEquals(
        screen.height * BaseBottomSheet.defaultInitialExtent,
        epsilon: 1,
      ),
    );
  });

  testWidgets('drives its content from one scroll view', (tester) async {
    await _pumpHost(tester);
    await _open(tester);

    // One scrollable, not two: the drag that resizes the sheet and the scroll
    // that moves the content have to be the same gesture chain, or dragging on
    // the content fights the sheet.
    expect(
      find.descendant(
        of: find.byType(BaseBottomSheet),
        matching: find.byType(Scrollable),
      ),
      findsOneWidget,
    );
  });

  testWidgets('an upward drag expands first, then scrolls the content', (
    tester,
  ) async {
    await _pumpHost(tester);
    await _open(tester);
    expect(find.text('row 0'), findsOneWidget);
    final double opened = tester.getRect(find.byType(BaseBottomSheet)).height;

    // First drag: the sheet grows to its maximum. The content has not moved —
    // this is the behaviour that makes the panel feel like a sheet and not a
    // list in a box.
    await tester.drag(find.text('row 1'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byType(BaseBottomSheet)).height,
      greaterThan(opened),
    );
    expect(find.text('row 0'), findsOneWidget);

    // Second drag: nothing left to expand, so the same gesture now scrolls.
    await tester.drag(find.text('row 1'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('row 0'), findsNothing);
    expect(find.byType(BaseBottomSheet), findsOneWidget);
  });

  testWidgets('dragging it down far enough closes it', (tester) async {
    await _pumpHost(tester);
    await _open(tester);

    await tester.drag(find.text('row 1'), const Offset(0, 600));
    await tester.pumpAndSettle();

    expect(find.byType(BaseBottomSheet), findsNothing);
  });

  testWidgets('the close button closes it', (tester) async {
    await _pumpHost(tester);
    await _open(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(BaseBottomSheet), findsNothing);
  });

  testWidgets('the grab bar stays pinned while the content scrolls', (
    tester,
  ) async {
    await _pumpHost(tester);
    await _open(tester);
    final double before = _grabBarOffset(tester);

    // Two drags: the first expands the sheet, the second scrolls the rows past
    // the bar. Measured against the sheet's own top, since the first drag moves
    // the whole panel up the screen.
    await tester.drag(find.text('row 1'), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.drag(find.text('row 1'), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('row 0'), findsNothing, reason: 'the content did scroll');
    // ...and the way out is still there, at the top of the sheet.
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(_grabBarOffset(tester), moreOrLessEquals(before, epsilon: 1));
  });

  testWidgets('it rides exactly on top of the keyboard', (tester) async {
    // GetX's route already pads the sheet by `viewInsets.bottom`, so
    // `BaseBottomSheet` must not pad it again: doing so would leave a gap the
    // height of the keyboard. This is the groundwork #40 owes the search field
    // of #41.
    const double keyboard = 300;
    addTearDown(tester.view.resetViewInsets);

    await _pumpHost(tester);
    await _open(tester);

    tester.view.viewInsets = FakeViewPadding(
      bottom: keyboard * tester.view.devicePixelRatio,
    );
    await tester.pumpAndSettle();

    final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final Rect sheet = tester.getRect(find.byType(BaseBottomSheet));

    expect(
      sheet.bottom,
      moreOrLessEquals(screen.height - keyboard, epsilon: 1),
      reason:
          'the sheet must sit on the keyboard: one keyboard height above it '
          'means the padding was applied twice, under it means never',
    );
  });

  testWidgets('gives its content a Material to paint ink on', (tester) async {
    await _pumpHost(tester);
    await _open(tester);

    // Ink is drawn on the nearest `Material` ancestor. If that ancestor sits
    // outside the sheet, the sheet's own background paints over every ripple —
    // which is what happened to the rows of the currency selector, silently,
    // until Flutter 3.39 started asserting on it. Asserting the structure here
    // catches it on any version, including the older one this may build with.
    final Finder material = find.descendant(
      of: find.byType(BaseBottomSheet),
      matching: find.byType(Material),
    );
    expect(material, findsWidgets, reason: 'the sheet must own a Material');

    // And it has to be *inside* the decoration, not around it: no painted box
    // may come between it and the content.
    expect(
      find.descendant(
        of: material.first,
        matching: find.byType(CustomScrollView),
      ),
      findsOneWidget,
    );
  });

  testWidgets('names itself for assistive tech', (tester) async {
    await _pumpHost(tester);
    await _open(tester);

    // Without this a screen reader lands on loose rows with no idea that a
    // panel opened over the page.
    expect(
      find.bySemanticsLabel(_label),
      findsWidgets,
      reason: 'the sheet must announce what it is',
    );
  });
}
