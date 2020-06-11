import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../states.dart';

void main() {
  testWidgets('WaterfallFlows test', (WidgetTester tester) async {
    final WaterfallFlow view = WaterfallFlow.builder(
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 100.0 + index % 5 * 50.0,
          color: const Color(0xFF0000FF),
          child: Text(kStates[index]),
        );
      },
      gridDelegate: const SliverWaterfallFlowDelegate(crossAxisCount: 4),
      itemCount: kStates.length,
    );

    await tester.pumpWidget(materialAppBoilerplate(child: view));

    final Finder finder = find.text('Alabama').first;
    expect(tester.getSize(finder), const Size(200.0, 100.0));
  });

  testWidgets('Vertical WaterfallFlows are primary by default',
      (WidgetTester tester) async {
    final WaterfallFlow view = WaterfallFlow(
      scrollDirection: Axis.vertical,
      gridDelegate: const SliverWaterfallFlowDelegate(crossAxisCount: 3),
    );
    expect(view.primary, isTrue);
  });

  testWidgets('WaterfallFlows with controllers are non-primary by default',
      (WidgetTester tester) async {
    final WaterfallFlow view = WaterfallFlow(
      controller: ScrollController(),
      scrollDirection: Axis.vertical,
      gridDelegate: const SliverWaterfallFlowDelegate(crossAxisCount: 3),
    );
    expect(view.primary, isFalse);
  });

  testWidgets('WaterfallFlow sets PrimaryScrollController when primary',
      (WidgetTester tester) async {
    final ScrollController primaryScrollController = ScrollController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PrimaryScrollController(
          controller: primaryScrollController,
          child: WaterfallFlow(
            primary: true,
            gridDelegate: const SliverWaterfallFlowDelegate(crossAxisCount: 3),
          ),
        ),
      ),
    );
    final Scrollable scrollable = tester.widget(find.byType(Scrollable));
    expect(scrollable.controller, primaryScrollController);
  });
}

Widget materialAppBoilerplate({Widget child}) {
  return MaterialApp(
    home: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800.0, 600.0)),
        child: Material(
          child: child,
        ),
      ),
    ),
  );
}
