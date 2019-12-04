///
///  create by zmtzawqlp on 2019/11/20
///
import 'package:example/common/tu_chong_repository.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:example/common/widget_builder.dart';

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
  TuChongRepository _list = TuChongRepository();

  @override
  void initState() {
    super.initState();
    _list.loadMore().whenComplete(() {
      setState(() {});
    });
  }

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
        title: Text("KnownSized"),
      ),
      body: _list.length == 0
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            )
          : WaterfallFlow.builder(
              //cacheExtent: 0.0,
              padding: EdgeInsets.all(5.0),
              gridDelegate: SliverWaterfallFlowDelegate(
                crossAxisCount: 2,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,

                /// follow max child trailing layout offset and layout with full cross axis extend
                /// last child as loadmore item/no more item in [GridView] and [WaterfallFlow]
                /// with full cross axis extend
                //  LastChildLayoutType.fullCrossAxisExtend,

                /// as foot at trailing and layout with full cross axis extend
                /// show no more item at trailing when children are not full of viewport
                /// if children is full of viewport, it's the same as fullCrossAxisExtend
                //  LastChildLayoutType.foot,
                lastChildLayoutTypeBuilder: (index) => index == _list.length
                    ? LastChildLayoutType.foot
                    : LastChildLayoutType.none,
                collectGarbage: (List<int> garbages) {
                  ///collectGarbage
                  garbages.forEach((index) {
                    final provider = ExtendedNetworkImageProvider(
                      _list[index].imageUrl,
                    );
                    provider.evict();
                  });
                },
              ),
              itemBuilder: (c, index) {
                if (index == _list.length) {
                  _list.loadMore().whenComplete(() {
                    setState(() {});
                  });
                  return buildLastWidget(
                    context: context,
                    hasMore: _list.hasMore,
                  );
                }
                final item = _list[index];
                final double fontSize = 12.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: item.imageSize.width / item.imageSize.height,
                      child: Stack(
                        children: <Widget>[
                          ExtendedImage.network(
                            item.imageUrl,
                            shape: BoxShape.rectangle,
                            border: Border.all(
                                color: Colors.grey.withOpacity(0.4),
                                width: 1.0),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                            loadStateChanged: (value) {
                              if (value.extendedImageLoadState ==
                                  LoadState.loading) {
                                return Container(
                                  alignment: Alignment.center,
                                  color: Colors.grey.withOpacity(0.8),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation(
                                        Theme.of(context).primaryColor),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                          Positioned(
                            top: 5.0,
                            right: 5.0,
                            child: Container(
                              padding: EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.6),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.4),
                                    width: 1.0),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              child: Text(
                                "${index + 1}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: fontSize, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Wrap(
                        runSpacing: 5.0,
                        spacing: 5.0,
                        children: item.tags.map<Widget>((tag) {
                          final color = item.tagColors[item.tags.indexOf(tag)];
                          return Container(
                            padding: EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 1.0),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.0),
                              ),
                            ),
                            child: Text(
                              tag,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: fontSize,
                                  color: color.computeLuminance() < 0.5
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          );
                        }).toList()),
                    SizedBox(
                      height: 5.0,
                    ),
                    buildBottomWidget(item),
                  ],
                );
              },
              itemCount: _list.length + 1,
            ),
    );
  }
}
