# waterfall_flow

能够快速构建瀑布流布局的列表.

[![pub package](https://img.shields.io/pub/v/waterfall_flow.svg)](https://pub.dartlang.org/packages/waterfall_flow) [![GitHub stars](https://img.shields.io/github/stars/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/stargazers) [![GitHub forks](https://img.shields.io/github/forks/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/network)  [![GitHub license](https://img.shields.io/github/license/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/blob/master/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/fluttercandies/waterfall_flow)](https://github.com/fluttercandies/waterfall_flow/issues) <a target="_blank" href="https://jq.qq.com/?_wv=1027&k=5bcc0gy"><img border="0" src="https://pub.idqqimg.com/wpa/images/group.png" alt="flutter-candies" title="flutter-candies"></a>

Language: [English](README.md) | 中文简体

- [waterfall_flow](#waterfallflow)
  - [使用](#%e4%bd%bf%e7%94%a8)
  - [简单使用](#%e7%ae%80%e5%8d%95%e4%bd%bf%e7%94%a8)
  - [列表元素回收](#%e5%88%97%e8%a1%a8%e5%85%83%e7%b4%a0%e5%9b%9e%e6%94%b6)
  - [ViewportBuilder](#viewportbuilder)
  - [LastChildLayoutTypeBuilder](#lastchildlayouttypebuilder)
  - [CloseToTrailing](#closetotrailing)

## 使用

* 在pubspec.yaml中增加库引用
  
```yaml

dependencies:
  waterfall_flow: any

```  
* 导入库
  
```dart

  import 'package:waterfall_flow/waterfall_flow.dart';
  
```


## 简单使用

| ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/random_sized.gif) | ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/custom_scrollView.gif) |
| --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/known_sized.gif)  | ![img](https://github.com/fluttercandies/flutter_candies/tree/master/gif/waterfall_flow/variable_sized.gif)    |

你可以通过设置SliverWaterfallFlowDelegate参数来定义瀑布流

| 参数                       | 描述                                   | 默认  |
| -------------------------- | -------------------------------------- | ----- |
| crossAxisCount             | 横轴的等长度元素数量                   | 必填  |
| mainAxisSpacing            | 主轴元素之间的距离                     | 0.0   |
| crossAxisSpacing           | 横轴元素之间的距离                     | 0.0   |
| collectGarbage             | 元素回收时候的回调                     | -     |
| lastChildLayoutTypeBuilder | 最后一个元素的布局样式(详情请查看后面) | -     |
| viewportBuilder            | 可视区域中元素indexes变化时的回调      | -     |
| closeToTrailing            | 可否让布局紧贴trailing(详情请查看后面) | false |

```dart
            WaterfallFlow.builder(
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
                  ),

```

## 列表元素回收

追踪列表元素回收，你可以在这个时刻回收一些内存，比如图片的内存缓存。

[更多详情](https://github.com/fluttercandies/extended_image/blob/e1577bc4d0b57c725110a9d886703b98a72772b5/example/lib/pages/photo_view_demo.dart#L91)

```dart
        WaterfallFlow.builder(
            extendedListDelegate: SliverWaterfallFlowDelegate(
                collectGarbage: (List<int> garbages) {
                print("collect garbage : $garbages");
                },),
```

## ViewportBuilder

追踪进入Viewport的列表元素的index（即你看到的可视区域，并不包括缓存距离）

```dart
        WaterfallFlow.builder(
            extendedListDelegate: SliverWaterfallFlowDelegate(
                viewportBuilder: (int firstIndex, int lastIndex) {
                print("viewport : [$firstIndex,$lastIndex]");
                }),
```

## LastChildLayoutTypeBuilder

为最后一个元素创建特殊布局，这主要是用在将最后一个元素作为loadmore/no more的时候。

```dart
        enum LastChildLayoutType {
        /// 普通的
        none,

        /// 将最后一个元素绘制在最大主轴Item之后，并且使用横轴大小最为layout size
        /// 主要使用在[ExtendedGridView] and [WaterfallFlow]中，最后一个元素作为loadmore/no more元素的时候。
        fullCrossAxisExtend,

        /// 将最后一个child绘制在trailing of viewport，并且使用横轴大小最为layout size
        /// 这种常用于最后一个元素作为loadmore/no more元素，并且列表元素没有充满整个viewport的时候
        /// 如果列表元素充满viewport，那么效果跟fullCrossAxisExtend一样
        foot,
        }

      WaterfallFlow.builder(
        extendedListDelegate: SliverWaterfallFlowDelegate(
            lastChildLayoutTypeBuilder: (index) => index == length
                ? LastChildLayoutType.foot
                : LastChildLayoutType.none,
            ),
```

## CloseToTrailing

当reverse设置为true的时候，布局会变成如下。常用于聊天列表，新的会话会被插入0的位置，但是当会话没有充满viewport的时候，下面的布局不是我们想要的。

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

为了解决这个问题，你可以设置 closeToTrailing 为true, 布局将变成如下
该属性同时支持[ExtendedGridView],[ExtendedList],[WaterfallFlow]。
当然如果reverse如果不为ture，你设置这个属性依然会生效，没满viewport的时候布局会紧靠trailing

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
        extendedListDelegate: SliverWaterfallFlowDelegate(closeToTrailing: true),
```