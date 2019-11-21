import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

typedef LastOneBuilder = bool Function(int index);

/// Creates grid layouts with a fixed number of tiles in the cross axis.
///
/// For example, if the grid is vertical, this delegate will create a layout
/// with a fixed number of columns. If the grid is horizontal, this delegate
/// will create a layout with a fixed number of rows.
///
/// This delegate creates grids with equally sized and spaced tiles.
///
/// See also:
///
///  * [SliverGridDelegateWithMaxCrossAxisExtent], which creates a layout with
///    tiles that have a maximum cross-axis extent.
///  * [SliverGridDelegate], which creates arbitrary layouts.
///  * [GridView], which can use this delegate to control the layout of its
///    tiles.
///  * [SliverGrid], which can use this delegate to control the layout of its
///    tiles.
///  * [RenderSliverGrid], which can use this delegate to control the layout of
///    its tiles.
class SliverWaterfallFlowDelegate {
  /// Creates a delegate that makes grid layouts with a fixed number of tiles in
  /// the cross axis.
  ///
  /// All of the arguments must not be null. The `mainAxisSpacing` and
  /// `crossAxisSpacing` arguments must not be negative. The `crossAxisCount`
  /// and `childAspectRatio` arguments must be greater than zero.
  const SliverWaterfallFlowDelegate({
    @required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.lastOneBuilder,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0);

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  final LastOneBuilder lastOneBuilder;

  bool shouldRelayout(SliverWaterfallFlowDelegate oldDelegate) {
    return oldDelegate.crossAxisCount != crossAxisCount ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing;
  }

  double getCrossAxisOffset(SliverConstraints constraints, int crossAxisIndex) {
    final bool reverseCrossAxis =
        axisDirectionIsReversed(constraints.crossAxisDirection);

    final double usableCrossAxisExtent = getUsableCrossAxisExtent(constraints);

    return (reverseCrossAxis
            ? crossAxisCount - 1 - crossAxisIndex
            : crossAxisIndex) %
        crossAxisCount *
        (usableCrossAxisExtent / crossAxisCount + crossAxisSpacing);
  }

  double getUsableCrossAxisExtent(SliverConstraints constraints) =>
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1);

  double getChildConstraints(SliverConstraints constraints) =>
      getUsableCrossAxisExtent(constraints) / crossAxisCount;
}
