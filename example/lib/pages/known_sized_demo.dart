import 'dart:math';

///
///  create by zmtzawqlp on 2019/11/20
///

import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_candies_demo_library/flutter_candies_demo_library.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: "fluttercandies://known-sized",
  routeName: "known-sized",
  description: "show how to build a known-sized item with waterfall flow list.",
)
class KnownSizedDemo extends StatefulWidget {
  @override
  _KnownSizedDemoState createState() => _KnownSizedDemoState();
}

class _KnownSizedDemoState extends State<KnownSizedDemo> {
  TuChongRepository listSourceRepository = TuChongRepository();

  @override
  void dispose() {
    super.dispose();
    listSourceRepository.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("KnownSized"),
      ),
      body: LayoutBuilder(
        builder: (c, data) {
          final crossAxisCount = max(
              data.maxWidth ~/ (ScreenUtil.instance.screenWidthDp / 2.0), 2);
          return LoadingMoreList(
            ListConfig<TuChongItem>(
              waterfallFlowDelegate: WaterfallFlowDelegate(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: buildWaterfallFlowItem,
              sourceList: listSourceRepository,
              padding: EdgeInsets.all(5.0),
              lastChildLayoutType: LastChildLayoutType.foot,
              // collectGarbage: (List<int> garbages) {
              //   ///collectGarbage
              //   garbages.forEach((index) {
              //     final provider = ExtendedNetworkImageProvider(
              //       listSourceRepository[index].imageUrl,
              //     );
              //     provider.evict();
              //   });
              // },
              // viewportBuilder: (int firstIndex, int lastIndex) {
              //   print("viewport : [$firstIndex,$lastIndex]");
              // },
            ),
          );
        },
      ),
    );
  }
}
