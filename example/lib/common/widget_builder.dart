import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

import 'tu_chong_repository.dart';
import 'tu_chong_source.dart';

Widget buildBottomWidget(TuChongItem item) {
  final fontSize = 12.0;
  return Row(
    children: <Widget>[
      ExtendedImage.network(
        item.avatarUrl,
        width: 25.0,
        height: 25.0,
        shape: BoxShape.circle,
        //enableLoadState: false,
        border: Border.all(color: Colors.grey.withOpacity(0.4), width: 1.0),
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
            style: TextStyle(color: Colors.black, fontSize: fontSize),
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
              count >= 1000 ? (count / 1000.0).toStringAsFixed(1) + "k" : text,
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
  );
}

Widget buildLastWidget(
    {BuildContext context, bool hasMore}) {
  return Container(
      alignment: Alignment.center,
      color: Colors.grey.withOpacity(0.2),
      margin: EdgeInsets.only(top: 5.0),
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        hasMore ? "loading..." : "no more",
        style: TextStyle(color: Theme.of(context).primaryColor),
      ));
}
