///
///  create by zmtzawqlp on 2019/11/21
///
import 'package:example/common/tu_chong_repository.dart';
import 'package:example/common/tu_chong_source.dart';
import 'package:extended_image/extended_image.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

@FFRoute(
  name: "fluttercandies://demo3",
  routeName: "demo3",
  description:
      "show how to build a variable-sized item with waterfall flow list.",
)
class Demo3 extends StatefulWidget {
  @override
  _Demo3State createState() => _Demo3State();
}

class _Demo3State extends State<Demo3> {
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
        title: Text("variable-sized"),
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
              // width: 20,
              // height: 20,
              alignment: Alignment.center,
              color: Colors.grey.withOpacity(0.8),
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              ),
            );
          }
          final item = _list[index];
          final double fontSize = 12.0;

          Widget imageWidget = Stack(
            children: <Widget>[
              ExtendedImage.network(
                item.imageUrl,
                shape: BoxShape.rectangle,
                border:
                    Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                loadStateChanged: (value) {
                  if (value.extendedImageLoadState == LoadState.loading) {
                    return AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        alignment: Alignment.center,
                        color: Colors.grey.withOpacity(0.8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    );
                  } else if (value.extendedImageLoadState ==
                      LoadState.completed) {
                    item.imageRawSize = Size(
                        value.extendedImageInfo.image.width.toDouble(),
                        value.extendedImageInfo.image.height.toDouble());
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
                        color: Colors.grey.withOpacity(0.4), width: 1.0),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: Text(
                    "${index + 1}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: fontSize, color: Colors.white),
                  ),
                ),
              )
            ],
          );
          if (item.imageRawSize != null) {
            imageWidget = AspectRatio(
              child: imageWidget,
              aspectRatio: item.imageRawSize.width / item.imageRawSize.height,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              imageWidget,
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
                            color: Colors.grey.withOpacity(0.4), width: 1.0),
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
              Row(
                children: <Widget>[
                  ExtendedImage.network(
                    item.avatarUrl,
                    width: 25.0,
                    height: 25.0,
                    shape: BoxShape.circle,
                    //enableLoadState: false,
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.4), width: 1.0),
                    loadStateChanged: (state) {
                      if (state.extendedImageLoadState == LoadState.completed) {
                        return null;
                      }

                      return Image.asset("assets/avatar.jpg");
                    },
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.comment,
                        color: Colors.amberAccent,
                        size: 18.0,
                      ),
                      SizedBox(
                        width: 3.0,
                      ),
                      Text(
                        item.comments.toString(),
                        style:
                            TextStyle(color: Colors.black, fontSize: fontSize),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 3.0,
                  ),
                  LikeButton(
                    size: 18.0,
                    isLiked: item.isFavorite,
                    likeCount: item.favorites,
                    countBuilder: (int count, bool isLiked, String text) {
                      var color = isLiked ? Colors.pinkAccent : Colors.grey;
                      Widget result;
                      if (count == 0) {
                        result = Text(
                          "love",
                          style: TextStyle(color: color, fontSize: fontSize),
                        );
                      } else
                        result = Text(
                          count >= 1000
                              ? (count / 1000.0).toStringAsFixed(1) + "k"
                              : text,
                          style: TextStyle(color: color, fontSize: fontSize),
                        );
                      return result;
                    },
                    likeCountAnimationType: item.favorites < 1000
                        ? LikeCountAnimationType.part
                        : LikeCountAnimationType.none,
                    onTap: (bool isLiked) {
                      return onLikeButtonTap(isLiked, item);
                    },
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

  static Future<bool> onLikeButtonTap(bool isLiked, TuChongItem item) {
    ///send your request here
    return Future<bool>.delayed(const Duration(milliseconds: 50), () {
      item.isFavorite = !item.isFavorite;
      item.favorites =
          item.isFavorite ? item.favorites + 1 : item.favorites - 1;
      return item.isFavorite;
    });
  }
}
