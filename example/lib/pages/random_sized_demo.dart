///
///  create by zmtzawqlp on 2019/11/19
///
import 'dart:math';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:masonry_grid_view/masonry_grid_view.dart';

@FFRoute(
  name: 'fluttercandies://random-sized',
  routeName: 'MasonryGridView',
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
  TextDirection textDirection = TextDirection.ltr;
  int length=100;
  ScrollController controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('MasonryGridView'),
      ),
      body: Directionality(
        textDirection: textDirection,
        child: MasonryGridView.builder(
          controller: controller,
          padding: const EdgeInsets.all(5.0),
          gridDelegate: SliverMasonryGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
          itemBuilder: (BuildContext c, int index) {
            final Color color = getRandomColor(index);

            return Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  color: getRandomColor(index)),
              alignment: Alignment.center,
              child: Text(
                '$index ',
                //+ 'TestString' * 10 * (index % 3 + 1),
                style: TextStyle(
                    color: color.computeLuminance() < 0.5
                        ? Colors.white
                        : Colors.black),
              ),
              height: ((index % 3) + 1) * 100.0,
            );
          },
          //itemCount: 19,
          itemCount: length,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // if (textDirection == TextDirection.ltr) {
            //   textDirection = TextDirection.rtl;
            // } else {
            //   textDirection = TextDirection.ltr;
            // }
            //length=0;
            crossAxisCount++;
            //mainAxisSpacing += 5.0;
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
