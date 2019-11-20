import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:waterfall_flow/src/rendering/render_sliver_waterfall_flow.dart';
import 'package:waterfall_flow/src/rendering/sliver_waterfall_flow.dart';

import 'sliver.dart';

///
///  create by zmtzawqlp on 2019/11/9
///

/// See also:
///
///  * [SliverList], which places its children in a linear array.
///  * [SliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
class SliverWaterfallFlow extends SliverWaterfallFlowMultiBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement.
  const SliverWaterfallFlow({
    Key key,
    @required SliverChildDelegate delegate,
    @required this.gridDelegate,
  }) : super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverGridDelegateWithFixedCrossAxisCount] as the [gridDelegate],
  /// and a [SliverChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new GridView.count], the equivalent constructor for [GridView] widgets.
  SliverWaterfallFlow.count({
    Key key,
    @required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
  })  : gridDelegate = SliverWaterfallFlowDelegate(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        ),
        super(key: key, delegate: SliverChildListDelegate(children));


  /// The delegate that controls the size and position of the children.
  final SliverWaterfallFlowDelegate gridDelegate;

  @override
  RenderSliverWaterfallFlow createRenderObject(BuildContext context) {
    final SliverWaterfallFlowMultiBoxAdaptorElement element = context;
    return RenderSliverWaterfallFlow(
        childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverWaterfallFlow renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }

  // @override
  // double estimateMaxScrollOffset(
  //   SliverConstraints constraints,
  //   int firstIndex,
  //   int lastIndex,
  //   double leadingScrollOffset,
  //   double trailingScrollOffset,
  // ) {
  //   return super.estimateMaxScrollOffset(
  //         constraints,
  //         firstIndex,
  //         lastIndex,
  //         leadingScrollOffset,
  //         trailingScrollOffset,
  //       ) ??
  //       gridDelegate
  //           .getLayout(constraints)
  //           .computeMaxScrollOffset(delegate.estimatedChildCount);
  // }
}
