import 'dart:math';

///
///  create by zmtzawqlp on 2019/11/19
///
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
    name: "fluttercandies://demo1",
    routeName: "image crop rect",
    description: "show how to crop rect image") //
class Demo1 extends StatefulWidget {
  @override
  _Demo1State createState() => _Demo1State();
}

class _Demo1State extends State<Demo1> {
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
        gridDelegate: SliverWaterfallFlowDelegate(
            crossAxisCount: 4, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
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
            //height: index == 5 ? 1000.0 : 100.0,
            height:   ((index % 3) + 1) * 100.0,
          );
        },
        //itemCount: 7,
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
