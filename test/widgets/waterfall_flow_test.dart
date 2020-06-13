import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

void main() {
  testWidgets('WaterfallFlow size of children test',
      (WidgetTester tester) async {
    await tester.pumpWidget(materialAppBoilerplate(
        child: waterfallFlowBoilerplate(crossAxisCount: 2),
        textDirection: TextDirection.ltr));

    expect(
        tester.getSize(find.widgetWithText(
            Container, "0.He'd have you all unravel at the")),
        const Size(400.0, 50.0));

    expect(
        tester.getSize(find.widgetWithText(Container, '1.Heed not the rabble')),
        const Size(400.0, 70.0));

    expect(
        tester.getSize(
            find.widgetWithText(Container, '2.Sound of screams but the')),
        const Size(400.0, 90.0));

    expect(tester.getSize(find.widgetWithText(Container, '3.Who scream')),
        const Size(400.0, 60.0));

    expect(
        tester.getSize(
            find.widgetWithText(Container, '4.Revolution is coming...')),
        const Size(400.0, 80.0));

    expect(
        tester.getSize(find.widgetWithText(Container, '5.Revolution, they...')),
        const Size(400.0, 100.0));
  });

  testWidgets('WaterfallFlow position of children when TextDirection.ltr',
      (WidgetTester tester) async {
    await tester.pumpWidget(materialAppBoilerplate(
        child: waterfallFlowBoilerplate(crossAxisCount: 2),
        textDirection: TextDirection.ltr));

    expect(
        tester.getTopLeft(find.widgetWithText(
            Container, "0.He'd have you all unravel at the")),
        const Offset(0.0, 0.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '1.Heed not the rabble')),
        const Offset(400.0, 0.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '2.Sound of screams but the')),
        const Offset(0.0, 50.0));

    expect(tester.getTopLeft(find.widgetWithText(Container, '3.Who scream')),
        const Offset(400.0, 70.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '4.Revolution is coming...')),
        const Offset(400.0, 130.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '5.Revolution, they...')),
        const Offset(0.0, 140.0));
  });

  testWidgets('WaterfallFlow position of children when TextDirection.rtl',
      (WidgetTester tester) async {
    final Widget view = WaterfallFlow.count(
      crossAxisCount: 2,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text("0.He'd have you all unravel at the"),
          color: Colors.teal[100],
          height: 50.0,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text('1.Heed not the rabble'),
          color: Colors.teal[200],
          height: 70.0,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text('2.Sound of screams but the'),
          color: Colors.teal[300],
          height: 90.0,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text('3.Who scream'),
          color: Colors.teal[400],
          height: 60.0,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text('4.Revolution is coming...'),
          color: Colors.teal[500],
          height: 80.0,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          child: const Text('5.Revolution, they...'),
          color: Colors.teal[600],
          height: 100.0,
        ),
      ],
    );

    await tester.pumpWidget(
        materialAppBoilerplate(child: view, textDirection: TextDirection.rtl));

    expect(
        tester.getTopLeft(find.widgetWithText(
            Container, "0.He'd have you all unravel at the")),
        const Offset(400.0, 0.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '1.Heed not the rabble')),
        const Offset(0.0, 0.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '2.Sound of screams but the')),
        const Offset(400.0, 50.0));

    expect(tester.getTopLeft(find.widgetWithText(Container, '3.Who scream')),
        const Offset(0.0, 70.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '4.Revolution is coming...')),
        const Offset(0.0, 130.0));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '5.Revolution, they...')),
        const Offset(400.0, 140.0));
  });

  testWidgets('WaterfallFlow crossAxisCount test', (WidgetTester tester) async {
    await tester.pumpWidget(materialAppBoilerplate(
        child: waterfallFlowBoilerplate(crossAxisCount: 2),
        textDirection: TextDirection.ltr));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '2.Sound of screams but the')),
        const Offset(0.0, 50.0));

    await tester.pumpWidget(materialAppBoilerplate(
        child: waterfallFlowBoilerplate(crossAxisCount: 4),
        textDirection: TextDirection.ltr));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '2.Sound of screams but the')),
        const Offset(400.0, 0.0));
  });

  testWidgets('WaterfallFlow crossAxisSpacing test',
      (WidgetTester tester) async {
    await tester.pumpWidget(materialAppBoilerplate(
        child: waterfallFlowBoilerplate(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
        ),
        textDirection: TextDirection.ltr));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '2.Sound of screams but the')),
        const Offset(0.0, 50.0));

    expect(tester.getTopLeft(find.widgetWithText(Container, '3.Who scream')),
        const Offset(405.0, 70.0));
  });

  testWidgets('WaterfallFlow mainAxisSpacing test',
      (WidgetTester tester) async {
    await tester.pumpWidget(materialAppBoilerplate(
        child: waterfallFlowBoilerplate(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
        ),
        textDirection: TextDirection.ltr));

    expect(
        tester.getTopLeft(
            find.widgetWithText(Container, '2.Sound of screams but the')),
        const Offset(0.0, 60.0));

    expect(tester.getTopLeft(find.widgetWithText(Container, '3.Who scream')),
        const Offset(400.0, 80.0));
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

Widget waterfallFlowBoilerplate({
  int crossAxisCount = 2,
  double crossAxisSpacing = 0.0,
  double mainAxisSpacing = 0.0,
}) {
  return WaterfallFlow.count(
    crossAxisCount: crossAxisCount,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisSpacing: mainAxisSpacing,
    children: <Widget>[
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text("0.He'd have you all unravel at the"),
        color: Colors.teal[100],
        height: 50.0,
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('1.Heed not the rabble'),
        color: Colors.teal[200],
        height: 70.0,
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('2.Sound of screams but the'),
        color: Colors.teal[300],
        height: 90.0,
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('3.Who scream'),
        color: Colors.teal[400],
        height: 60.0,
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('4.Revolution is coming...'),
        color: Colors.teal[500],
        height: 80.0,
      ),
      Container(
        padding: const EdgeInsets.all(8),
        child: const Text('5.Revolution, they...'),
        color: Colors.teal[600],
        height: 100.0,
      ),
    ],
  );
}

Widget materialAppBoilerplate(
    {Widget child, TextDirection textDirection = TextDirection.ltr}) {
  return MaterialApp(
    home: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(800.0, 600.0)),
        child: Material(
          child: child,
        ),
      ),
    ),
  );
}
