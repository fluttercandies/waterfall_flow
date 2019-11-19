import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart' hide SliverMultiBoxAdaptorParentData;
import 'sliver.dart';
import 'sliver_waterfall_flow.dart';

///
///  create by zmtzawqlp on 2019/11/9
///

/// A sliver that places multiple box children in a two dimensional arrangement.
///
/// [RenderSliverWaterfallFlow] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// See also:
///
///  * [RenderSliverList], which places its children in a linear
///    array.
///  * [RenderSliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
class RenderSliverWaterfallFlow
    extends RenderSliverWaterfallFlowMultiBoxAdaptor {
  /// Creates a sliver that contains multiple box children that whose size and
  /// position are determined by a delegate.
  ///
  /// The [childManager] and [gridDelegate] arguments must not be null.
  RenderSliverWaterfallFlow({
    @required RenderSliverWaterfallFlowBoxChildManager childManager,
    @required SliverWaterfallFlowDelegate gridDelegate,
  })  : assert(gridDelegate != null),
        _gridDelegate = gridDelegate,
        super(childManager: childManager);

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! WaterfallFlowParentData)
      child.parentData = WaterfallFlowParentData();
  }

  /// The delegate that controls the size and position of the children.
  SliverWaterfallFlowDelegate get gridDelegate => _gridDelegate;
  SliverWaterfallFlowDelegate _gridDelegate;
  set gridDelegate(SliverWaterfallFlowDelegate value) {
    assert(value != null);
    if (_gridDelegate == value) return;
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) markNeedsLayout();
    _gridDelegate = value;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final WaterfallFlowParentData childParentData = child.parentData;
    return childParentData.crossAxisOffset;
  }

  CrossAxisItems _preCrossAxisItems;
  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    CrossAxisItems crossAxisItems = CrossAxisItems(
        crossAxisCount: _gridDelegate.crossAxisCount,
        crossAxisExtent: constraints.crossAxisExtent,
        crossAxisDirection: constraints.crossAxisDirection,
        leadingItems: _preCrossAxisItems?.leadingItems);

    BoxConstraints childConstraints = constraints.asBoxConstraints(
        crossAxisExtent:
            constraints.crossAxisExtent / _gridDelegate.crossAxisCount);

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

    //childConstraints = constraints.asBoxConstraints(crossAxisExtent: 180.0);
    int leadingGarbage = 0;
    int trailingGarbage = 0;
    bool reachedEnd = false;

    // This algorithm in principle is straight-forward: find the first child
    // that overlaps the given scrollOffset, creating more children at the top
    // of the list if necessary, then walk down the list updating and laying out
    // each child and adding more at the end if necessary until we have enough
    // children to cover the entire viewport.
    //
    // It is complicated by one minor issue, which is that any time you update
    // or create a child, it's possible that the some of the children that
    // haven't yet been laid out will be removed, leaving the list in an
    // inconsistent state, and requiring that missing nodes be recreated.
    //
    // To keep this mess tractable, this algorithm starts from what is currently
    // the first child, if any, and then walks up and/or down from there, so
    // that the nodes that might get removed are always at the edges of what has
    // already been laid out.

    // Make sure we have at least one child to start from.
    if (firstChild == null) {
      if (!addInitialChild()) {
        // There are no children.
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }

    // We have at least one child.

    // These variables track the range of children that we have laid out. Within
    // this range, the children have consecutive indices. Outside this range,
    // it's possible for a child to get removed without notice.
    RenderBox leadingChildWithLayout, trailingChildWithLayout;

    // Find the last child that is at or before the scrollOffset.
    RenderBox earliestUsefulChild = firstChild;

    while (crossAxisItems.maxLeadingLayoutOffset > scrollOffset) {
      // We have to add children before the earliestUsefulChild.
      earliestUsefulChild =
          insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);

      if (earliestUsefulChild == null) {
        if (scrollOffset == 0.0) {
          // insertAndLayoutLeadingChild only lays out the children before
          // firstChild. In this case, nothing has been laid out. We have
          // to lay out firstChild manually.
          firstChild.layout(childConstraints, parentUsesSize: true);

          earliestUsefulChild = firstChild;
          leadingChildWithLayout = earliestUsefulChild;
          trailingChildWithLayout ??= earliestUsefulChild;

          crossAxisItems.insert(
              child: earliestUsefulChild,
              childTrailingLayoutOffset: childTrailingLayoutOffset);
          break;
        } else {
          // We ran out of children before reaching the scroll offset.
          // We must inform our parent that this sliver cannot fulfill
          // its contract and that we need a scroll offset correction.
          geometry = SliverGeometry(
            scrollOffsetCorrection: -scrollOffset,
          );
          return;
        }
      }

      crossAxisItems.insertLeading(
          child: earliestUsefulChild, paintExtentOf: paintExtentOf);

      final WaterfallFlowParentData data = earliestUsefulChild.parentData;

      // firstChildScrollOffset may contain double precision error
      if (data.layoutOffset < -precisionErrorTolerance) {
        // The first child doesn't fit within the viewport (underflow) and
        // there may be additional children above it. Find the real first child
        // and then correct the scroll position so that there's room for all and
        // so that the trailing edge of the original firstChild appears where it
        // was before the scroll offset correction.
        // TODO(hansmuller): do this work incrementally, instead of all at once,
        // i.e. find a way to avoid visiting ALL of the children whose offset
        // is < 0 before returning for the scroll correction.
        double correction = 0.0;
        while (earliestUsefulChild != null) {
          assert(firstChild == earliestUsefulChild);
          correction += paintExtentOf(firstChild);
          earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints,
              parentUsesSize: true);
          crossAxisItems.insertLeading(
              child: earliestUsefulChild, paintExtentOf: paintExtentOf);
        }
        geometry = SliverGeometry(
          scrollOffsetCorrection: correction - data.layoutOffset,
        );
        return;
      }

      ///todo
//        final WaterfallFlowParentData childParentData =
//            earliestUsefulChild.parentData;
//        childParentData.layoutOffset = firstChildScrollOffset;

      assert(earliestUsefulChild == firstChild);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout ??= earliestUsefulChild;
    }

//    for (double earliestScrollOffset = childScrollOffset(earliestUsefulChild);
//        earliestScrollOffset > scrollOffset;
//        earliestScrollOffset = childScrollOffset(earliestUsefulChild)) {
//      // We have to add children before the earliestUsefulChild.
//      earliestUsefulChild =
//          insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);
//
//      if (earliestUsefulChild == null) {
//        final WaterfallFlowParentData childParentData = firstChild.parentData;
//        childParentData.layoutOffset = 0.0;
//        childParentData.crossAxisOffset = 0.0;
//
//        if (scrollOffset == 0.0) {
//          // insertAndLayoutLeadingChild only lays out the children before
//          // firstChild. In this case, nothing has been laid out. We have
//          // to lay out firstChild manually.
//          firstChild.layout(childConstraints, parentUsesSize: true);
//          earliestUsefulChild = firstChild;
//          leadingChildWithLayout = earliestUsefulChild;
//          trailingChildWithLayout ??= earliestUsefulChild;
//          break;
//        } else {
//          // We ran out of children before reaching the scroll offset.
//          // We must inform our parent that this sliver cannot fulfill
//          // its contract and that we need a scroll offset correction.
//          geometry = SliverGeometry(
//            scrollOffsetCorrection: -scrollOffset,
//          );
//          return;
//        }
//      }
//
//      final double firstChildScrollOffset =
//          earliestScrollOffset - paintExtentOf(firstChild);
//      // firstChildScrollOffset may contain double precision error
//      if (firstChildScrollOffset < -precisionErrorTolerance) {
//        // The first child doesn't fit within the viewport (underflow) and
//        // there may be additional children above it. Find the real first child
//        // and then correct the scroll position so that there's room for all and
//        // so that the trailing edge of the original firstChild appears where it
//        // was before the scroll offset correction.
//        // TODO(hansmuller): do this work incrementally, instead of all at once,
//        // i.e. find a way to avoid visiting ALL of the children whose offset
//        // is < 0 before returning for the scroll correction.
//        double correction = 0.0;
//        while (earliestUsefulChild != null) {
//          assert(firstChild == earliestUsefulChild);
//          correction += paintExtentOf(firstChild);
//          earliestUsefulChild = insertAndLayoutLeadingChild(childConstraints,
//              parentUsesSize: true);
//        }
//        geometry = SliverGeometry(
//          scrollOffsetCorrection: correction - earliestScrollOffset,
//        );
//        final WaterfallFlowParentData childParentData = firstChild.parentData;
//        childParentData.layoutOffset = 0.0;
//        childParentData.crossAxisOffset = 0.0;
//        return;
//      }
//
//      ///todo
//      final WaterfallFlowParentData childParentData =
//          earliestUsefulChild.parentData;
//      childParentData.layoutOffset = firstChildScrollOffset;
//      assert(earliestUsefulChild == firstChild);
//      leadingChildWithLayout = earliestUsefulChild;
//      trailingChildWithLayout ??= earliestUsefulChild;
//    }

    // At this point, earliestUsefulChild is the first child, and is a child
    // whose scrollOffset is at or before the scrollOffset, and
    // leadingChildWithLayout and trailingChildWithLayout are either null or
    // cover a range of render boxes that we have laid out with the first being
    // the same as earliestUsefulChild and the last being either at or after the
    // scroll offset.

    assert(earliestUsefulChild == firstChild);
    //zmt
    //assert(childScrollOffset(earliestUsefulChild) <= scrollOffset);

    // Make sure we've laid out at least one child.
    if (leadingChildWithLayout == null) {
      earliestUsefulChild.layout(childConstraints, parentUsesSize: true);
      leadingChildWithLayout = earliestUsefulChild;
      trailingChildWithLayout = earliestUsefulChild;
    }

    // Here, earliestUsefulChild is still the first child, it's got a
    // scrollOffset that is at or before our actual scrollOffset, and it has
    // been laid out, and is in fact our leadingChildWithLayout. It's possible
    // that some children beyond that one have also been laid out.

    bool inLayoutRange = true;
    RenderBox child = earliestUsefulChild;
    int index = indexOf(child);
    crossAxisItems.insert(
        child: child, childTrailingLayoutOffset: childTrailingLayoutOffset);

    //double endScrollOffset = childTrailingLayoutOffset(child);

    bool advance() {
      // returns true if we advanced, false if we have no more children
      // This function is used in two different places below, to avoid code duplication.
      assert(child != null);
      if (child == trailingChildWithLayout) inLayoutRange = false;
      child = childAfter(child);
      if (child == null) inLayoutRange = false;
      index += 1;
      if (!inLayoutRange) {
        if (child == null || indexOf(child) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.

          child = insertAndLayoutChild(
            childConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: true,
          );
          if (child == null) {
            // We have run out of children.
            return false;
          }
        } else {
          // Lay out the child.

          child.layout(childConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      //zmt
      final WaterfallFlowParentData childParentData = child.parentData;
      //zmt
      crossAxisItems.insert(
          child: child, childTrailingLayoutOffset: childTrailingLayoutOffset);

      assert(childParentData.index == index);
      //endScrollOffset = childScrollOffset(child) + paintExtentOf(child);
      //zmt
      //endScrollOffset = childTrailingLayoutOffset(child);
      return true;
    }

    // Find the first child that ends after the scroll offset.
    while (childTrailingLayoutOffset(child) < scrollOffset) {
      leadingGarbage += 1;
      crossAxisItems.leadingGarbage(index);
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        // we want to make sure we keep the last child around so we know the end scroll offset
        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        final double extent = childTrailingLayoutOffset(lastChild);
        geometry = SliverGeometry(
          scrollExtent: extent,
          paintExtent: 0.0,
          maxPaintExtent: extent,
        );
        return;
      }
    }

    // Now find the first child that ends after our end.
    while (crossAxisItems.minEndScrollOffset < targetEndScrollOffset) {
      if (!advance()) {
        reachedEnd = true;
        break;
      }
    }

    // Finally count up all the remaining children and label them as garbage.
    if (child != null) {
      child = childAfter(child);
      while (child != null) {
        trailingGarbage += 1;
        child = childAfter(child);
      }
    }

    // At this point everything should be good to go, we just have to clean up
    // the garbage and report the geometry.
    //zmt

    collectGarbage(leadingGarbage, trailingGarbage);

    assert(debugAssertChildListIsNonEmptyAndContiguous());
    double estimatedMaxScrollOffset;
    //zmt
    double endScrollOffset = crossAxisItems.maxEndScrollOffset;
    if (reachedEnd) {
      estimatedMaxScrollOffset = endScrollOffset;
    } else {
      estimatedMaxScrollOffset = childManager.estimateMaxScrollOffset(
        constraints,
        firstIndex: indexOf(firstChild),
        lastIndex: indexOf(lastChild),
        leadingScrollOffset: childScrollOffset(firstChild),
        trailingScrollOffset: endScrollOffset,
      );
      //zmt
      assert(estimatedMaxScrollOffset >=
          endScrollOffset - childScrollOffset(firstChild));
    }
    final double paintExtent = calculatePaintOffset(
      constraints,
      from: childScrollOffset(firstChild),
      to: endScrollOffset,
    );
    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: childScrollOffset(firstChild),
      to: endScrollOffset,
    );
    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;
    geometry = SliverGeometry(
      scrollExtent: estimatedMaxScrollOffset,
      paintExtent: paintExtent,
      cacheExtent: cacheExtent,
      maxPaintExtent: estimatedMaxScrollOffset,
      // Conservative to avoid flickering away the clip during scroll.
      hasVisualOverflow: endScrollOffset > targetEndScrollOffsetForPaint ||
          constraints.scrollOffset > 0.0,
    );

    // We may have started the layout while scrolled to the end, which would not
    // expose a new child.
    if (estimatedMaxScrollOffset == endScrollOffset)
      childManager.setDidUnderflow(true);
    childManager.didFinishLayout();

    _preCrossAxisItems = crossAxisItems;
  }

  double childTrailingLayoutOffset(RenderBox child) {
    return childScrollOffset(child) + paintExtentOf(child);
  }
}

class CrossAxisItems {
  final List<WaterfallFlowParentData> trailingItems;
  final List<WaterfallFlowParentData> leadingItems;
  final int crossAxisCount;
  final double crossAxisExtent;
  final AxisDirection crossAxisDirection;
  CrossAxisItems(
      {@required this.crossAxisCount,
      @required this.crossAxisExtent,
      @required this.crossAxisDirection,
      List<WaterfallFlowParentData> leadingItems})
      : leadingItems = leadingItems != null
            ? leadingItems.map((x) => x).toList()
            : List<WaterfallFlowParentData>(),
        trailingItems = leadingItems != null
            ? leadingItems.map((x) => x).toList()
            : List<WaterfallFlowParentData>();

  void insert({
    @required RenderBox child,
    @required ChildTrailingLayoutOffset childTrailingLayoutOffset,
  }) {
    final WaterfallFlowParentData data = child.parentData;
    if (!leadingItems.contains(data)) {
      if (leadingItems.length != crossAxisCount) {
        if (data.crossAxisIndex != null) {
          var same = leadingItems.firstWhere(
              (x) => x.crossAxisIndex == data.crossAxisIndex,
              orElse: () => null);
          if (same != null) {
            leadingItems.remove(same);
            leadingItems.add(data);
            trailingItems.remove(same);
            trailingItems.add(data);
            return;
          }
        }
        data.crossAxisIndex ??= leadingItems.length;

        data.crossAxisOffset = data.crossAxisIndex %
            crossAxisCount *
            (crossAxisExtent / crossAxisCount);

        trailingItems.add(data);
        leadingItems.add(data);
      } else {
        var min = trailingItems.reduce((curr, next) =>
            ((curr.trailingLayoutOffset < next.trailingLayoutOffset) ||
                    (curr.trailingLayoutOffset == next.trailingLayoutOffset &&
                        curr.crossAxisIndex < next.crossAxisIndex)
                ? curr
                : next));

        data.layoutOffset = min.trailingLayoutOffset;
        data.crossAxisIndex = min.crossAxisIndex;
        data.crossAxisOffset = min.crossAxisOffset;
        if (!min.indexs.contains(min.index)) {}

        trailingItems.forEach((f) => f.indexs.remove(min.index));
        min.indexs.add(min.index);

        data.indexs = min.indexs;
        trailingItems.remove(min);
        trailingItems.add(data);
      }
    }

    data.trailingLayoutOffset = childTrailingLayoutOffset(child);
  }

  void insertLeading({
    @required RenderBox child,
    @required PaintExtentOf paintExtentOf,
  }) {
    final WaterfallFlowParentData data = child.parentData;

    var pre = leadingItems.firstWhere((x) => x.indexs.contains(data.index),
        orElse: () => null);

    if (pre == null) {
      pre = leadingItems.reduce((curr, next) =>
          ((curr.layoutOffset > next.layoutOffset) ||
                  (curr.layoutOffset == next.layoutOffset &&
                      curr.crossAxisIndex < next.crossAxisIndex)
              ? curr
              : next));
    }

    data.trailingLayoutOffset = pre.layoutOffset;
    data.crossAxisIndex = pre.crossAxisIndex;
    data.crossAxisOffset = pre.crossAxisOffset;

    leadingItems.remove(pre);
    leadingItems.add(data);
    trailingItems.remove(pre);
    trailingItems.add(data);
    data.indexs = pre.indexs;
    data.layoutOffset = data.trailingLayoutOffset - paintExtentOf(child);
  }

  double get minEndScrollOffset {
    try {
      return trailingItems
          .reduce((curr, next) =>
              ((curr.trailingLayoutOffset <= next.trailingLayoutOffset)
                  ? curr
                  : next))
          .trailingLayoutOffset;
    } catch (e) {
      return 0.0;
    }
  }

  double get maxEndScrollOffset {
    try {
      return trailingItems
          .reduce((curr, next) =>
              ((curr.trailingLayoutOffset >= next.trailingLayoutOffset)
                  ? curr
                  : next))
          .trailingLayoutOffset;
    } catch (e) {
      return 0.0;
    }
  }

  double get maxLeadingLayoutOffset {
    try {
      return leadingItems
          .reduce((curr, next) =>
              ((curr.layoutOffset >= next.layoutOffset) ? curr : next))
          .layoutOffset;
    } catch (e) {
      return 0.0;
    }
  }

  void leadingGarbage(int index) {
    leadingItems.remove(
        leadingItems.firstWhere((x) => x.index == index, orElse: () => null));
    trailingItems.remove(
        trailingItems.firstWhere((x) => x.index == index, orElse: () => null));
  }
}

typedef ChildTrailingLayoutOffset = double Function(RenderBox child);
typedef PaintExtentOf = double Function(RenderBox child);

class WaterfallFlowParentData extends SliverMultiBoxAdaptorParentData {
  /// The trailing position of the child relative to the zero scroll offset.
  ///
  /// The number of pixels from from the zero scroll offset of the parent sliver
  /// (the line at which its [SliverConstraints.scrollOffset] is zero) to the
  /// side of the child closest to that offset.
  ///
  /// In a typical list, this does not change as the parent is scrolled.
  double trailingLayoutOffset;

  /// The index of crossAxis
  int crossAxisIndex;

  /// The offset of the child in the non-scrolling axis.
  ///
  /// If the scroll axis is vertical, this offset is from the left-most edge of
  /// the parent to the left-most edge of the child. If the scroll axis is
  /// horizontal, this offset is from the top-most edge of the parent to the
  /// top-most edge of the child.
  double crossAxisOffset;

  /// previ
  List<int> indexs = List<int>();
  @override
  String toString() =>
      'crossAxisIndex=$crossAxisIndex;crossAxisOffset=$crossAxisOffset;trailingLayoutOffset=$trailingLayoutOffset; ${super.toString()}';
}
