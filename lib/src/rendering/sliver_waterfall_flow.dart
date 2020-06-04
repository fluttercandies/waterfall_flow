import 'dart:math';

import 'package:extended_list_library/extended_list_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

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
class RenderSliverWaterfallFlow extends RenderSliverMultiBoxAdaptor
    with ExtendedRenderObjectMixin {
  /// Creates a sliver that contains multiple box children that whose size and
  /// position are determined by a delegate.
  ///
  /// The [childManager] and [gridDelegate] arguments must not be null.
  RenderSliverWaterfallFlow({
    @required RenderSliverBoxChildManager childManager,
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
    if (_gridDelegate == value) {
      return;
    }
    if (value.runtimeType != _gridDelegate.runtimeType ||
        value.shouldRelayout(_gridDelegate)) {
      markNeedsLayout();
    }

    _gridDelegate = value;
  }

  @override
  double childCrossAxisPosition(RenderBox child) {
    final WaterfallFlowParentData childParentData =
        child.parentData as WaterfallFlowParentData;
    return childParentData.crossAxisOffset;
  }

  CrossAxisItems _preCrossAxisItems;
  @override
  void performLayout() {
    childManager.didStartLayout();
    childManager.setDidUnderflow(false);

    final CrossAxisItems crossAxisItems = CrossAxisItems(
        delegate: _gridDelegate,
        constraints: constraints,
        leadingItems: _preCrossAxisItems?.leadingItems);

    if (resetLayout()) {
      crossAxisItems.reset();
    }

    final BoxConstraints childConstraints = constraints.asBoxConstraints(
        crossAxisExtent: _gridDelegate.getChildConstraints(constraints));

    final double scrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    assert(scrollOffset >= 0.0);
    final double remainingExtent = constraints.remainingCacheExtent;
    assert(remainingExtent >= 0.0);
    final double targetEndScrollOffset = scrollOffset + remainingExtent;

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

    // zmt
    handleCloseToTrailingBegin(_gridDelegate?.closeToTrailing ?? false);

    // We have at least one child.

    // These variables track the range of children that we have laid out. Within
    // this range, the children have consecutive indices. Outside this range,
    // it's possible for a child to get removed without notice.
    RenderBox leadingChildWithLayout, trailingChildWithLayout;

    // Find the last child that is at or before the scrollOffset.
    RenderBox earliestUsefulChild = firstChild;

    // A firstChild with null layout offset is likely a result of children
    // reordering.
    //
    // We rely on firstChild to have accurate layout offset. In the case of null
    // layout offset, we have to find the first child that has valid layout
    // offset.
    if (childScrollOffset(firstChild) == null) {
      int leadingChildrenWithoutLayoutOffset = 0;
      while (childScrollOffset(earliestUsefulChild) == null) {
        earliestUsefulChild = childAfter(firstChild);
        leadingChildrenWithoutLayoutOffset += 1;
      }
      // We should be able to destroy children with null layout offset safely,
      // because they are likely outside of viewport
      collectGarbage(leadingChildrenWithoutLayoutOffset, 0);
      assert(firstChild != null);
    }

    // Find the last child that is at or before the scrollOffset.
    earliestUsefulChild = firstChild;

    if (crossAxisItems.maxLeadingLayoutOffset > scrollOffset) {
      RenderBox child = firstChild;
      //move to max index of leading
      final int maxLeadingIndex = crossAxisItems.maxLeadingIndex;
      while (child != null && maxLeadingIndex > indexOf(child)) {
        child = childAfter(child);
      }
      //fill leadings from max index of leading to min index of leading
      while (child != null && crossAxisItems.minLeadingIndex < indexOf(child)) {
        crossAxisItems.insertLeading(
            child: child, paintExtentOf: paintExtentOf);
        child = childBefore(child);
      }
      //collectGarbage(maxLeadingIndex - index, 0);

      while (crossAxisItems.maxLeadingLayoutOffset > scrollOffset) {
        // We have to add children before the earliestUsefulChild.
        earliestUsefulChild =
            insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);

        // earliestUsefulChild = insertAndLayoutLeadingChildWithIndex(
        //     childConstraints, crossAxisItems.maxLeadingIndex,
        //     parentUsesSize: true);

        if (earliestUsefulChild == null) {
          if (scrollOffset == 0.0) {
            // insertAndLayoutLeadingChild only lays out the children before
            // firstChild. In this case, nothing has been laid out. We have
            // to lay out firstChild manually.
            firstChild.layout(childConstraints, parentUsesSize: true);

            earliestUsefulChild = firstChild;
            leadingChildWithLayout = earliestUsefulChild;
            trailingChildWithLayout ??= earliestUsefulChild;
            crossAxisItems.reset();
            crossAxisItems.insert(
              child: earliestUsefulChild,
              childTrailingLayoutOffset: childTrailingLayoutOffset,
              paintExtentOf: paintExtentOf,
            );
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

        final WaterfallFlowParentData data =
            earliestUsefulChild.parentData as WaterfallFlowParentData;

        // firstChildScrollOffset may contain double precision error
        if (data.layoutOffset < -precisionErrorTolerance) {
          // The first child doesn't fit within the viewport (underflow) and
          // there may be additional children above it. Find the real first child
          // and then correct the scroll position so that there's room for all and
          // so that the trailing edge of the original firstChild appears where it
          // was before the scroll offset correction.
          // do this work incrementally, instead of all at once,
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
    }

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
      earliestUsefulChild.layout(
          _gridDelegate.getLastChildLayoutType(indexOf(earliestUsefulChild)) !=
                  LastChildLayoutType.none
              ? constraints.asBoxConstraints()
              : childConstraints,
          parentUsesSize: true);
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
        child: child,
        childTrailingLayoutOffset: childTrailingLayoutOffset,
        paintExtentOf: paintExtentOf);

    bool advance() {
      // returns true if we advanced, false if we have no more children
      // This function is used in two different places below, to avoid code duplication.
      assert(child != null);
      if (child == trailingChildWithLayout) {
        inLayoutRange = false;
      }
      child = childAfter(child);
      if (child == null) {
        inLayoutRange = false;
      }
      index += 1;
      final LastChildLayoutType lastChildLayoutType =
          _gridDelegate.getLastChildLayoutType(index);
      final BoxConstraints currentConstraints =
          lastChildLayoutType != LastChildLayoutType.none
              ? constraints.asBoxConstraints()
              : childConstraints;

      if (!inLayoutRange) {
        if (child == null || indexOf(child) != index) {
          // We are missing a child. Insert it (and lay it out) if possible.

          child = insertAndLayoutChild(
            currentConstraints,
            after: trailingChildWithLayout,
            parentUsesSize: true,
          );
          if (child == null) {
            // We have run out of children.
            return false;
          }
        } else {
          // Lay out the child.
          child.layout(currentConstraints, parentUsesSize: true);
        }
        trailingChildWithLayout = child;
      }
      assert(child != null);
      //zmt
      final WaterfallFlowParentData childParentData =
          child.parentData as WaterfallFlowParentData;
      //zmt

      crossAxisItems.insert(
          child: child,
          childTrailingLayoutOffset: childTrailingLayoutOffset,
          paintExtentOf: paintExtentOf);

      assert(childParentData.index == index);
      return true;
    }

    final List<int> leadingGarbages = <int>[];

    // Find the first child that ends after the scroll offset.
    while (childTrailingLayoutOffset(child) < scrollOffset) {
      leadingGarbage += 1;
      leadingGarbages.add(index);
      //crossAxisItems.leadingGarbage(index);
      if (!advance()) {
        assert(leadingGarbage == childCount);
        assert(child == null);
        // we want to make sure we keep the last child around so we know the end scroll offset
        collectGarbage(leadingGarbage - 1, 0);
        assert(firstChild == lastChild);
        final double extent = crossAxisItems.maxChildTrailingLayoutOffset;
        //childTrailingLayoutOffset(lastChild);
        crossAxisItems.setLeading();
        geometry = SliverGeometry(
          scrollExtent: extent,
          paintExtent: 0.0,
          maxPaintExtent: extent,
        );
        _preCrossAxisItems = crossAxisItems;
        return;
      }
    }

    if (leadingGarbage > 0) {
      ///make sure leadingItems is after the scroll offset
      while (crossAxisItems.minChildTrailingLayoutOffset < scrollOffset) {
        if (!advance()) {
          final int minTrailingIndex = crossAxisItems.minTrailingIndex;
          for (final int index in leadingGarbages) {
            if (index >= minTrailingIndex) {
              leadingGarbage--;
            }
          }

          leadingGarbage = max(0, leadingGarbage);
          break;
        }
      }
      crossAxisItems.setLeading();
    }

    // Now find the first child that ends after our end.
    if (child != null) {
      while (crossAxisItems.minChildTrailingLayoutOffset <
              targetEndScrollOffset ||
          //make sure leading children are painted.
          crossAxisItems.leadingItems.length < _gridDelegate.crossAxisCount ||
          crossAxisItems.leadingItems.length > childCount ||
          (child.parentData as WaterfallFlowParentData).index <
              _gridDelegate.crossAxisCount - 1) {
        if (!advance()) {
          reachedEnd = true;
          break;
        }
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
    //print(leadingGarbages);
    collectGarbage(leadingGarbage, trailingGarbage);
    //zmt
    callCollectGarbage(
      collectGarbage: _gridDelegate?.collectGarbage,
      leadingGarbage: leadingGarbage,
      trailingGarbage: trailingGarbage,
    );

    assert(debugAssertChildListIsNonEmptyAndContiguous());
    double estimatedMaxScrollOffset;
    //zmt
    double endScrollOffset =
        _gridDelegate.getLastChildLayoutType(indexOf(lastChild)) ==
                LastChildLayoutType.none
            ? crossAxisItems.maxChildTrailingLayoutOffset
            : childTrailingLayoutOffset(lastChild);

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

    ///zmt
    final double result = handleCloseToTrailingEnd(
        _gridDelegate?.closeToTrailing ?? false, endScrollOffset);
    if (result != endScrollOffset) {
      endScrollOffset = result;
      estimatedMaxScrollOffset = result;
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
    //zmt
    callViewportBuilder(viewportBuilder: _gridDelegate?.viewportBuilder);

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

  bool resetLayout() {
    if (_preCrossAxisItems != null) {
      if (_preCrossAxisItems.delegate.shouldRelayout(_gridDelegate) ||
          _preCrossAxisItems.constraints.crossAxisExtent !=
              constraints.crossAxisExtent ||
          _preCrossAxisItems.constraints.crossAxisDirection !=
              constraints.crossAxisDirection) {
        _preCrossAxisItems = null;
        //clear all
        collectGarbage(childCount, 0);
        return true;
      }
    }

    return false;
  }

  double childTrailingLayoutOffset(RenderBox child) {
    return childScrollOffset(child) + paintExtentOf(child);
  }
}

class CrossAxisItems {
  CrossAxisItems(
      {@required this.delegate,
      @required this.constraints,
      List<WaterfallFlowParentData> leadingItems})
      : leadingItems = leadingItems != null
            ? leadingItems.map((WaterfallFlowParentData x) => x).toList()
            : <WaterfallFlowParentData>[],
        trailingItems = leadingItems != null
            ? leadingItems.map((WaterfallFlowParentData x) => x).toList()
            : <WaterfallFlowParentData>[];
  final List<WaterfallFlowParentData> trailingItems;
  final List<WaterfallFlowParentData> leadingItems;
  final SliverWaterfallFlowDelegate delegate;
  final SliverConstraints constraints;
  int get crossAxisCount => delegate.crossAxisCount;
  void insert({
    @required RenderBox child,
    @required ChildTrailingLayoutOffset childTrailingLayoutOffset,
    @required PaintExtentOf paintExtentOf,
  }) {
    final WaterfallFlowParentData data =
        child.parentData as WaterfallFlowParentData;
    final LastChildLayoutType lastChildLayoutType =
        delegate.getLastChildLayoutType(data.index);

    switch (lastChildLayoutType) {
      case LastChildLayoutType.fullCrossAxisExtend:
      case LastChildLayoutType.foot:
        data.crossAxisOffset = 0.0;
        data.crossAxisIndex = 0;
        final double size = paintExtentOf(child);
        if (lastChildLayoutType == LastChildLayoutType.fullCrossAxisExtend ||
            maxChildTrailingLayoutOffset + size >
                constraints.remainingPaintExtent) {
          data.layoutOffset = maxChildTrailingLayoutOffset;
        } else {
          data.layoutOffset = constraints.remainingPaintExtent - size;
        }
        data.trailingLayoutOffset = childTrailingLayoutOffset(child);
        return;
      case LastChildLayoutType.none:
        break;
    }

    if (!leadingItems.contains(data)) {
      if (leadingItems.length != crossAxisCount) {
        data.crossAxisIndex ??= leadingItems.length;

        data.crossAxisOffset =
            delegate.getCrossAxisOffset(constraints, data.crossAxisIndex);

        if (data.index < crossAxisCount) {
          data.layoutOffset = 0.0;
          data.indexs.clear();
        }

        trailingItems.add(data);
        leadingItems.add(data);
      } else {
        if (data.crossAxisIndex != null) {
          final WaterfallFlowParentData item = trailingItems.firstWhere(
              (WaterfallFlowParentData x) =>
                  x.index > data.index &&
                  x.crossAxisIndex == data.crossAxisIndex,
              orElse: () => null);

          ///out of viewport
          if (item != null) {
            data.trailingLayoutOffset = childTrailingLayoutOffset(child);
            return;
          }
        }
        final WaterfallFlowParentData min = trailingItems.reduce(
            (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                curr.trailingLayoutOffset < next.trailingLayoutOffset ||
                        (curr.trailingLayoutOffset ==
                                next.trailingLayoutOffset &&
                            curr.crossAxisIndex < next.crossAxisIndex)
                    ? curr
                    : next);

        data.layoutOffset = min.trailingLayoutOffset + delegate.mainAxisSpacing;
        data.crossAxisIndex = min.crossAxisIndex;
        data.crossAxisOffset =
            delegate.getCrossAxisOffset(constraints, data.crossAxisIndex);

        for (final WaterfallFlowParentData parentData in trailingItems) {
          parentData.indexs.remove(min.index);
        }

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
    final WaterfallFlowParentData data =
        child.parentData as WaterfallFlowParentData;
    if (!leadingItems.contains(data)) {
      final WaterfallFlowParentData pre = leadingItems.firstWhere(
          (WaterfallFlowParentData x) => x.indexs.contains(data.index),
          orElse: () => null);

      if (pre == null || pre.index < data.index) {
        return;
      }
      //if (pre == null) {
      // pre = leadingItems.reduce((curr, next) =>
      //     ((curr.layoutOffset > next.layoutOffset) ||
      //             (curr.layoutOffset == next.layoutOffset &&
      //                 curr.crossAxisIndex < next.crossAxisIndex)
      //         ? curr
      //         : next));
      //}

      data.trailingLayoutOffset = pre.layoutOffset - delegate.mainAxisSpacing;
      data.crossAxisIndex = pre.crossAxisIndex;
      data.crossAxisOffset =
          delegate.getCrossAxisOffset(constraints, data.crossAxisIndex);

      leadingItems.remove(pre);
      leadingItems.add(data);
      trailingItems.remove(pre);
      trailingItems.add(data);
      data.indexs = pre.indexs;

      data.layoutOffset = data.trailingLayoutOffset - paintExtentOf(child);
    }
  }

  double get minChildTrailingLayoutOffset {
    try {
      return trailingItems
          .reduce(
              (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                  curr.trailingLayoutOffset <= next.trailingLayoutOffset
                      ? curr
                      : next)
          .trailingLayoutOffset;
    } catch (e) {
      return 0.0;
    }
  }

  double get maxChildTrailingLayoutOffset {
    try {
      return trailingItems
          .reduce(
              (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                  curr.trailingLayoutOffset >= next.trailingLayoutOffset
                      ? curr
                      : next)
          .trailingLayoutOffset;
    } catch (e) {
      return 0.0;
    }
  }

  double get maxLeadingLayoutOffset {
    try {
      return leadingItems
          .reduce(
              (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                  curr.layoutOffset >= next.layoutOffset ? curr : next)
          .layoutOffset;
    } catch (e) {
      return 0.0;
    }
  }

  int get maxLeadingIndex {
    try {
      return leadingItems
          .reduce(
              (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                  curr.index > next.index ? curr : next)
          .index;
    } catch (e) {
      return 0;
    }
  }

  int get minLeadingIndex {
    try {
      return leadingItems
          .reduce(
              (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                  curr.index < next.index ? curr : next)
          .index;
    } catch (e) {
      return 0;
    }
  }

  int get maxTrailingIndex {
    try {
      return trailingItems
          .reduce(
              (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                  curr.index > next.index ? curr : next)
          .index;
    } catch (e) {
      return 0;
    }
  }

  int get minTrailingIndex {
    try {
      return trailingItems
          .reduce(
              (WaterfallFlowParentData curr, WaterfallFlowParentData next) =>
                  curr.index < next.index ? curr : next)
          .index;
    } catch (e) {
      return 0;
    }
  }

  void reset() {
    leadingItems.clear();
    trailingItems.clear();
  }

  void setLeading() {
    leadingItems.clear();
    leadingItems.addAll(trailingItems);
  }
}

typedef ChildTrailingLayoutOffset = double Function(RenderBox child);

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

  /// The idnex of the children in current crossAxis
  List<int> indexs = <int>[];

  @override
  String toString() =>
      'crossAxisIndex=$crossAxisIndex;crossAxisOffset=$crossAxisOffset;trailingLayoutOffset=$trailingLayoutOffset; ${super.toString()}';
}

/// Creates waterfall flow layouts with a fixed number of tiles in the cross axis.
///
class SliverWaterfallFlowDelegate extends ExtendedListDelegate {
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
    LastChildLayoutTypeBuilder lastChildLayoutTypeBuilder,
    CollectGarbage collectGarbage,
    ViewportBuilder viewportBuilder,
    bool closeToTrailing = false,
  })  : assert(crossAxisCount != null && crossAxisCount > 0),
        assert(mainAxisSpacing != null && mainAxisSpacing >= 0),
        assert(crossAxisSpacing != null && crossAxisSpacing >= 0),
        assert(closeToTrailing != null),
        super(
          lastChildLayoutTypeBuilder: lastChildLayoutTypeBuilder,
          collectGarbage: collectGarbage,
          viewportBuilder: viewportBuilder,
          closeToTrailing: closeToTrailing,
        );

  /// The number of children in the cross axis.
  final int crossAxisCount;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

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

  LastChildLayoutType getLastChildLayoutType(int index) {
    if (lastChildLayoutTypeBuilder == null) {
      return LastChildLayoutType.none;
    }

    return lastChildLayoutTypeBuilder(index) ?? LastChildLayoutType.none;
  }
}
