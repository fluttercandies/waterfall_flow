import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

void main() {
  group('SliverWaterfallFlow relayout', () {
    testWidgets('a width change keeps every child alive',
        (WidgetTester tester) async {
      final Map<int, Rect> expected =
          await _freshLayout(tester, width: 393.0, crossAxisCount: 2);

      final _Lifecycle lifecycle = _Lifecycle();
      await tester.pumpWidget(
          _grid(width: 381.0, crossAxisCount: 2, lifecycle: lifecycle));
      await tester.pumpWidget(
          _grid(width: 393.0, crossAxisCount: 2, lifecycle: lifecycle));

      expect(lifecycle.remounted, isEmpty);
      expect(_rects(tester), expected);
    });

    testWidgets(
        'a column-count change at the top keeps every child alive and re-flows them',
        (WidgetTester tester) async {
      final Map<int, Rect> expectedThree =
          await _freshLayout(tester, width: 393.0, crossAxisCount: 3);
      final Map<int, Rect> expectedTwo =
          await _freshLayout(tester, width: 393.0, crossAxisCount: 2);

      final _Lifecycle lifecycle = _Lifecycle();
      await tester.pumpWidget(
          _grid(width: 393.0, crossAxisCount: 2, lifecycle: lifecycle));
      await tester.pumpWidget(
          _grid(width: 393.0, crossAxisCount: 3, lifecycle: lifecycle));

      expect(lifecycle.remounted, isEmpty);
      expect(_rects(tester), expectedThree);

      await tester.pumpWidget(
          _grid(width: 393.0, crossAxisCount: 2, lifecycle: lifecycle));

      expect(lifecycle.remounted, isEmpty);
      expect(_rects(tester), expectedTwo);
    });

    testWidgets(
        'a column-count change at the top still lays out correctly when scrolled back up',
        (WidgetTester tester) async {
      final List<double> offsets = <double>[
        for (double offset = 1000.0; offset >= 0.0; offset -= 37.0) offset,
      ];
      final Map<double, Map<int, Rect>> expected = <double, Map<int, Rect>>{};
      for (final double offset in offsets) {
        expected[offset] = _visible(
          await _freshLayout(
            tester,
            width: 393.0,
            crossAxisCount: 3,
            scrollOffset: offset,
          ),
        );
      }

      final _Lifecycle lifecycle = _Lifecycle();
      final ScrollController controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _grid(
          width: 393.0,
          crossAxisCount: 2,
          lifecycle: lifecycle,
          controller: controller,
        ),
      );
      await tester.pumpWidget(
        _grid(
          width: 393.0,
          crossAxisCount: 3,
          lifecycle: lifecycle,
          controller: controller,
        ),
      );
      controller.jumpTo(offsets.first);
      await tester.pump();
      expect(_rects(tester).keys, isNot(contains(0)));

      final List<double> mismatches = <double>[];
      for (final double offset in offsets) {
        controller.jumpTo(offset);
        await tester.pump();
        if (!_sameLayout(_visible(_rects(tester)), expected[offset]!)) {
          mismatches.add(offset);
        }
      }
      expect(mismatches, isEmpty);
    });

    testWidgets('a width change while scrolled down still lays out correctly',
        (WidgetTester tester) async {
      final Map<int, Rect> expected = await _freshLayout(tester,
          width: 393.0, crossAxisCount: 2, scrollOffset: 1000.0);

      final _Lifecycle lifecycle = _Lifecycle();
      final ScrollController controller =
          ScrollController(initialScrollOffset: 1000.0);
      addTearDown(controller.dispose);
      await tester.pumpWidget(_grid(
          width: 381.0,
          crossAxisCount: 2,
          lifecycle: lifecycle,
          controller: controller));
      expect(_rects(tester).keys, isNot(contains(0)));

      await tester.pumpWidget(_grid(
          width: 393.0,
          crossAxisCount: 2,
          lifecycle: lifecycle,
          controller: controller));

      expect(controller.offset, 1000.0);
      expect(_rects(tester), expected);
    });
  });
}

const List<double> _aspectRatios = <double>[0.75, 1.0, 1.5, 0.6, 1.25, 0.8];

Future<Map<int, Rect>> _freshLayout(
  WidgetTester tester, {
  required double width,
  required int crossAxisCount,
  double scrollOffset = 0.0,
}) async {
  final ScrollController controller =
      ScrollController(initialScrollOffset: scrollOffset);
  addTearDown(controller.dispose);
  await tester.pumpWidget(_grid(
    key: UniqueKey(),
    width: width,
    crossAxisCount: crossAxisCount,
    lifecycle: _Lifecycle(),
    controller: controller,
  ));
  final Map<int, Rect> rects = _rects(tester);
  await tester.pumpWidget(const SizedBox.shrink());
  return rects;
}

Map<int, Rect> _rects(WidgetTester tester) {
  return <int, Rect>{
    for (final _Tile tile
        in tester.widgetList<_Tile>(find.byType(_Tile, skipOffstage: false)))
      tile.index: tester.getRect(find.byWidget(tile, skipOffstage: false)),
  };
}

Map<int, Rect> _visible(Map<int, Rect> rects) {
  return <int, Rect>{
    for (final MapEntry<int, Rect> entry in rects.entries)
      if (entry.value.bottom > 0.0 && entry.value.top < 600.0)
        entry.key: entry.value,
  };
}

bool _sameLayout(Map<int, Rect> actual, Map<int, Rect> expected) {
  return actual.length == expected.length &&
      expected.keys.every((int index) {
        final Rect? rect = actual[index];
        return rect != null &&
            (rect.topLeft - expected[index]!.topLeft).distance < 1e-6 &&
            (rect.bottomRight - expected[index]!.bottomRight).distance < 1e-6;
      });
}

Widget _grid({
  Key? key,
  required double width,
  required int crossAxisCount,
  required _Lifecycle lifecycle,
  ScrollController? controller,
}) {
  return Directionality(
    key: key,
    textDirection: TextDirection.ltr,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: width,
        height: 600.0,
        child: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverWaterfallFlow(
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) => _Tile(
                  key: ValueKey<int>(index),
                  index: index,
                  lifecycle: lifecycle,
                ),
                childCount: 40,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Lifecycle {
  final Map<int, int> _initStates = <int, int>{};

  List<int> get remounted => <int>[
        for (final MapEntry<int, int> entry in _initStates.entries)
          if (entry.value > 1) entry.key,
      ];

  void initState(int index) =>
      _initStates.update(index, (int count) => count + 1, ifAbsent: () => 1);
}

class _Tile extends StatefulWidget {
  const _Tile({
    Key? key,
    required this.index,
    required this.lifecycle,
  }) : super(key: key);

  final int index;
  final _Lifecycle lifecycle;

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> {
  @override
  void initState() {
    super.initState();
    widget.lifecycle.initState(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _aspectRatios[widget.index % _aspectRatios.length],
    );
  }
}
