import 'package:example/common/tu_chong_repository.dart';
import 'package:extended_image/extended_image.dart';

///
///  create by zmtzawqlp on 2019/11/20
///
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
    name: "fluttercandies://demo2",
    routeName: "sized item list",
    description: "show how to crop rect image") //
class Demo2 extends StatefulWidget {
  @override
  _Demo2State createState() => _Demo2State();
}

class _Demo2State extends State<Demo2> {
  TuChongRepository _list = TuChongRepository();

  @override
  void dispose() {
    super.dispose();
    _list.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("demo"),
      ),
      body: WaterfallFlow.builder(
        //cacheExtent: 0.0,
        padding: EdgeInsets.all(5.0),
        gridDelegate: SliverWaterfallFlowDelegate(
            crossAxisCount: 2, crossAxisSpacing: 5.0, mainAxisSpacing: 5.0),
        itemBuilder: (c, index) {
          if (index == _list.length) {
            _list.loadMore().whenComplete(() {
              setState(() {});
            });
            return Container(
              child: Text("loading..."),
            );
          }
          final item = _list[index];
          String title = item.title;
          if (title == null || title == "") {
            title = "Image$index";
          }

          final content = item.content ?? (item.excerpt ?? title);

          return Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: item.imageSize.width / item.imageSize.height,
                child: ExtendedImage.network(
                  item.imageUrl,
                  shape: BoxShape.rectangle,
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.4), width: 1.0),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  ExtendedImage.network(
                    item.avatarUrl,
                    width: 30.0,
                    height: 30.0,
                    shape: BoxShape.circle,
                    enableLoadState: false,
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.4), width: 1.0),
                  ),
                  // Container(
                  //   child: Text(content),
                  // ),
                ],
              )
            ],
          );
        },
        itemCount: _list.length + 1,
      ),
    );
  }
}
