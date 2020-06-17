# waterfall_flow

[![pub package](https://img.shields.io/pub/v/waterfall_flow.svg)](https://pub.dartlang.org/packages/waterfall_flow) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

A Flutter grid view easy to build waterfall flow layout quickly.

[Web demo for WaterfallFlow](https://fluttercandies.github.io/waterfall_flow/)

Language: English | [中文简体](README-ZH.md)

- [waterfall_flow](#waterfall_flow)
  - [Use](#use)
  - [Easy to use](#easy-to-use)
  - [CollectGarbage](#collectgarbage)
  - [ViewportBuilder](#viewportbuilder)
  - [LastChildLayoutTypeBuilder](#lastchildlayouttypebuilder)
  - [CloseToTrailing](#closetotrailing)

## Use

* add library to your pubspec.yaml

```yaml

dependencies:
  waterfall_flow: any

```
* import library in dart file

```dart

  import 'package:waterfall_flow/waterfall_flow.dart';

```


## Easy to use

| ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/random_sized.gif) | ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/custom_scrollView.gif) |
| --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/known_sized.gif)  | ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/variable_sized.gif)    |

you can define waterfall flow layout within SliverWaterfallFlowDelegate.

* SliverWaterfallFlowDelegateWithFixedCrossAxisCount

| parameter      | description                               | default  |
| -------------- | ----------------------------------------- | -------- |
| crossAxisCount | The number of children in the cross axis. | required |

* SliverWaterfallFlowDelegateWithMaxCrossAxisExtent

| parameter          | description                                    | default  |
| ------------------ | ---------------------------------------------- | -------- |
| maxCrossAxisExtent | The maximum extent of tiles in the cross axis. | required |

* SliverWaterfallFlowDelegate

| mainAxisSpacing            | The number of logical pixels between each child along the main axis.                | 0.0      |
| crossAxisSpacing           | The number of logical pixels between each child along the cross axis.               | 0.0      |
| collectGarbage             | Call when collect garbage, return indexs to collect                                 | -        |
| lastChildLayoutTypeBuilder | The builder to get layout type of last child ,Notice: it should only for last child | -        |
| viewportBuilder            | The builder to get indexs in viewport                                               | -        |
| closeToTrailing            | Whether make layout close to trailing                                               | false    |

```dart
            WaterfallFlow.builder(
              //cacheExtent: 0.0,
              padding: EdgeInsets.all(5.0),
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
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
                  ),

```

## CollectGarbage

track the indexes are collect, you can collect garbage at that monment(for example Image cache)

[more detail](https://github.com/fluttercandies/extended_image/blob/e1577bc4d0b57c725110a9d886703b98a72772b5/example/lib/pages/photo_view_demo.dart#L91)

```dart
        WaterfallFlow.builder(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
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
```

## ViewportBuilder

track the indexes go into the viewport, it's not include cache extent.

```dart
        WaterfallFlow.builder(
            gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                viewportBuilder: (int firstIndex, int lastIndex) {
                print("viewport : [$firstIndex,$lastIndex]");
                }),
```

## LastChildLayoutTypeBuilder

build lastChild as special child in the case that it is loadmore/no more item.

```dart
        enum LastChildLayoutType {
        /// as default child
        none,

        /// follow max child trailing layout offset and layout with full cross axis extend
        /// last child as loadmore item/no more item in [ExtendedGridView] and [WaterfallFlow]
        /// with full cross axis extend
        fullCrossAxisExtend,

        /// as foot at trailing and layout with full cross axis extend
        /// show no more item at trailing when children are not full of viewport
        /// if children is full of viewport, it's the same as fullCrossAxisExtend
        foot,
        }

      WaterfallFlow.builder(
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
            lastChildLayoutTypeBuilder: (index) => index == length
                ? LastChildLayoutType.foot
                : LastChildLayoutType.none,
            ),
```

## CloseToTrailing

when reverse property of List is true, layout is as following.
it likes chat list, and new session will insert to zero index.
but it's not right when items are not full of viewport.

```
     trailing
-----------------
|               |
|               |
|     item2     |
|     item1     |
|     item0     |
-----------------
     leading
```

to solve it, you could set closeToTrailing to true, layout is as following.
support [ExtendedGridView],[ExtendedList],[WaterfallFlow].
and it also works when reverse is flase, layout will close to trailing.

```
     trailing
-----------------
|     item2     |
|     item1     |
|     item0     |
|               |
|               |
-----------------
     leading
```

```dart
      WaterfallFlow.builder(
        reverse: true,
        gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(closeToTrailing: true),
```