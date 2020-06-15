///
///  create by zmtzawqlp on 2019/11/19
///
import 'dart:math';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:masonry_grid_view/masonry_grid_view.dart';

@FFRoute(
  name: 'fluttercandies://custom_scrollview',
  routeName: 'SliverMasonryGrid',
  description: 'show how to build waterfall flow in CustomScrollview.',
)
class CustomScrollviewDemo extends StatefulWidget {
  @override
  _CustomScrollviewDemoState createState() => _CustomScrollviewDemoState();
}

class _CustomScrollviewDemoState extends State<CustomScrollviewDemo> {
  List<Color> colors = <Color>[];
  int crossAxisCount = 2;
  double crossAxisSpacing = 5.0;
  double mainAxisSpacing = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('SliverMasonryGrid'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              color: Colors.red,
              alignment: Alignment.center,
              child: const Text(
                'Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SliverMasonryGrid(
            gridDelegate: SliverMasonryGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext c, int index) {
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
                  height: ((index % 3) + 1) * 100.0,
                );
              },
              childCount: 50,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              color: Colors.red,
              alignment: Alignment.center,
              child: const Text(
                'Footer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            crossAxisCount++;
            //mainAxisSpacing+=5.0;
            //crossAxisSpacing+=5.0;
          });
        },
        child: const Icon(Icons.add),
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
