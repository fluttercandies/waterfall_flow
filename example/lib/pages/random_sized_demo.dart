///
///  create by zmtzawqlp on 2019/11/19
///
import 'dart:math';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';


@FFRoute(
  name: 'fluttercandies://random-sized',
  routeName: 'random-sized',
  description: 'show how to build random-sized item with waterfall flow list.',
)
class RandomSizedDemo extends StatefulWidget {
  @override
  _RandomSizedDemoState createState() => _RandomSizedDemoState();
}

class _RandomSizedDemoState extends State<RandomSizedDemo> {
  List<Color> colors = <Color>[];
  int crossAxisCount = 4;
  double crossAxisSpacing = 5.0;
  double mainAxisSpacing = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('RandomSized'),
      ),
      body: WaterfallFlow.builder(
        //cacheExtent: 0.0,
        //reverse: true,
        padding: const EdgeInsets.all(5.0),
        gridDelegate: SliverWaterfallFlowDelegate(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          collectGarbage: (List<int> garbages) {
            print('collect garbage : $garbages');
          },
          viewportBuilder: (int firstIndex, int lastIndex) {
            print('viewport : [$firstIndex,$lastIndex]');
          },
          //closeToTrailing: true,
        ),
        itemBuilder: (BuildContext c, int index) {
          final Color color = getRandomColor(index);

          return Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: getRandomColor(index)),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: TextStyle(
                  color: color.computeLuminance() < 0.5
                      ? Colors.white
                      : Colors.black),
            ),
            //height: index == 5 ? 1500.0 : 100.0,
            height: ((index % 3) + 1) * 100.0,
          );
        },
        //itemCount: 19,
        itemCount: null,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            crossAxisCount++;
            //mainAxisSpacing+=5.0;
            //crossAxisSpacing+=5.0;
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Color getRandomColor(int index) {
    if (index >= colors.length) {
      colors.add(Color.fromARGB(255, Random.secure().nextInt(255),
          Random.secure().nextInt(255), Random.secure().nextInt(255)));
    }

    return colors[index];
  }
}
