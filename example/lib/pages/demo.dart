import 'dart:math';

///
///  create by zmtzawqlp on 2019/11/19
///
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
    name: "fluttercandies://demo",
    routeName: "image crop rect",
    description: "show how to crop rect image") //
class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  List<Color> colors = List<Color>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("demo"),
      ),
      body: WaterfallFlow.builder(
        cacheExtent: 0.0,
        gridDelegate: SliverWaterfallFlowDelegate(crossAxisCount: 2),
        itemBuilder: (c, index) {
          Color color = getRandomColor(index);

          return Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: getRandomColor(index)),
            alignment: Alignment.center,
            child: Text(
              "$index",
              style: TextStyle(
                  color: color.computeLuminance() < 0.5
                      ? Colors.white
                      : Colors.black),
            ),
            height: ((index % 3) + 1) * 100.0,
          );
        },
        itemCount: null,
      ),
    );
  }

  getRandomColor(int index) {
    if (index >= colors.length) {
      colors.add(Color.fromARGB(255, Random.secure().nextInt(255),
          Random.secure().nextInt(255), Random.secure().nextInt(255)));
    }

    return colors[index];
  }
}
