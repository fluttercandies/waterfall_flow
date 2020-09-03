import 'package:extended_list_library/extended_list_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart' hide ViewportBuilder;
import 'package:waterfall_flow/src/rendering/sliver_waterfall_flow.dart';
import 'sliver.dart';

///
///  create by zmtzawqlp on 2019/11/9
///

/// A scrollable, 2D array of widgets whose size is variable in the main axis.
///
/// The main axis direction of a grid is the direction in which it scrolls (the
/// [scrollDirection]).
///
/// The most commonly used waterfall layouts are [WaterfallFlow.count], which creates a
/// layout with a fixed number of tiles in the cross axis.
///
/// To create a grid with a large (or infinite) number of children, use the
/// [WaterfallFlow.builder] constructor with a [SliverWaterfallFlowDelegate]
/// for the [gridDelegate].
///
/// To use a custom [SliverWaterfallFlowDelegate], use [WaterfallFlow.custom].
///
/// To create a linear array of children, use a [ListView].
///
/// To control the initial scroll offset of the scroll view, provide a
/// [controller] with its [ScrollController.initialScrollOffset] property set.
///
/// ## Transitioning to [CustomScrollView]
///
/// A [WaterfallFlow] is basically a [CustomScrollView] with a single [SliverWaterfallFlow] in
/// its [CustomScrollView.slivers] property.
///
/// If [WaterfallFlow] is no longer sufficient, for example because the scroll view
/// is to have both a grid and a list, or because the grid is to be combined
/// with a [SliverAppBar], etc, it is straight-forward to port code from using
/// [WaterfallFlow] to using [CustomScrollView] directly.
///
/// The [key], [scrollDirection], [reverse], [controller], [primary], [physics],
/// and [shrinkWrap] properties on [WaterfallFlow] map directly to the identically
/// named properties on [CustomScrollView].
///
/// The [CustomScrollView.slivers] property should be a list containing just a
/// [SliverWaterfallFlow].
///
/// The [childrenDelegate] property on [WaterfallFlow] corresponds to the
/// [SliverWaterfallFlow.gridDelegate] property, and the [gridDelegate] property on the
/// [WaterfallFlow] corresponds to the [SliverWaterfallFlow.gridDelegate] property.
///
/// The [WaterfallFlow] and [WaterfallFlow.count] constructors' `children` arguments
/// correspond to the [childrenDelegate] being a [SliverChildListDelegate]
/// with that same argument.
/// The [WaterfallFlow.builder] constructor's `itemBuilder` and `childCount` arguments
/// correspond to the [childrenDelegate] being a [SliverChildBuilderDelegate]
/// with the matching arguments.
///
/// The [WaterfallFlow.count] constructors create custom grid delegates,
/// and have equivalently named constructor on [SliverWaterfallFlow] to
/// ease the transition: [SliverWaterfallFlow.count] respectively.
///
/// The [padding] property corresponds to having a [SliverPadding] in the
/// [CustomScrollView.slivers] property instead of the grid itself, and having
/// the [SliverWaterfallFlow] instead be a child of the [SliverPadding].
///
/// By default, [ListView] will automatically pad the list's scrollable
/// extremities to avoid partial obstructions indicated by [MediaQuery]'s
/// padding. To avoid this behavior, override with a zero [padding] property.
///
/// Once code has been ported to use [CustomScrollView], other slivers, such as
/// [SliverList] or [SliverAppBar], can be put in the [CustomScrollView.slivers]
/// list.
///
/// {@tool snippet}
/// This example demonstrates how to create a [WaterfallFlow] with two columns. The
/// children are spaced apart using the [crossAxisSpacing] and [mainAxisSpacing]
/// properties.
///
/// ![The WaterfallFlow displays six children with different background colors and heights arranged in two columns](https://flutter.github.io/assets-for-api-docs/assets/widgets/grid_view.png)
///
/// ```dart
/// WaterfallFlow.count(
///   primary: false,
///   padding: const EdgeInsets.all(20),
///   crossAxisSpacing: 10,
///   mainAxisSpacing: 10,
///   crossAxisCount: 2,
///   children: <Widget>[
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text("0.He'd have you all unravel at the"),
///       color: Colors.teal[100],
///       height: 50.0,
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('1.Heed not the rabble'),
///       color: Colors.teal[200],
///       height: 70.0,
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('2.Sound of screams but the'),
///       color: Colors.teal[300],
///       height: 90.0,
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('3.Who scream'),
///       color: Colors.teal[400],
///       height: 60.0,
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('4.Revolution is coming...'),
///       color: Colors.teal[500],
///       height: 80.0,
///     ),
///     Container(
///       padding: const EdgeInsets.all(8),
///       child: const Text('5.Revolution, they...'),
///       color: Colors.teal[600],
///       height: 100.0,
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// This example shows how to create the same grid as the previous example
/// using a [CustomScrollView] and a [SliverWaterfallFlow].
///
/// ![The CustomScrollView contains a SliverWaterfallFlow that displays six children with different background colors and heights arranged in two columns](https://flutter.github.io/assets-for-api-docs/assets/widgets/grid_view_custom_scroll.png)
///
/// ```dart
/// CustomScrollView(
///   primary: false,
///   slivers: <Widget>[
///     SliverPadding(
///       padding: const EdgeInsets.all(20),
///       sliver: SliverWaterfallFlow.count(
///         crossAxisSpacing: 10,
///         mainAxisSpacing: 10,
///         crossAxisCount: 2,
///         children: <Widget>[
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text("0.He'd have you all unravel at the"),
///             color: Colors.green[100],
///             height: 50.0,
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('1.Heed not the rabble'),
///             color: Colors.green[200],
///             height: 70.0,
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('2.Sound of screams but the'),
///             color: Colors.green[300],
///             height: 90.0,
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('3.Who scream'),
///             color: Colors.green[400],
///             height: 60.0,
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('4.Revolution is coming...'),
///             color: Colors.green[500],
///             height: 80.0,
///           ),
///           Container(
///             padding: const EdgeInsets.all(8),
///             child: const Text('5.Revolution, they...'),
///             color: Colors.green[600],
///             height: 100.0,
///           ),
///         ],
///       ),
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [SingleChildScrollView], which is a scrollable widget that has a single
///    child.
///  * [ListView], which is scrollable, linear list of widgets.
///  * [GridView], which is scrollable, 2D array of widgets.
///  * [PageView], which is a scrolling list of child widgets that are each the
///    size of the viewport.
///  * [CustomScrollView], which is a scrollable widget that creates custom
///    scroll effects using slivers.
///  * [SliverGridDelegateWithFixedCrossAxisCount], which creates a layout with
///    a fixed number of tiles in the cross axis.
///  * [SliverGridDelegateWithMaxCrossAxisExtent], which creates a layout with
///    tiles that have a maximum cross-axis extent.
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
class WaterfallFlow extends BoxScrollView {
  /// Creates a scrollable, 2D array of widgets whose size is variable in the main axis
  /// with a custom [SliverWaterfallFlowDelegate].
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  WaterfallFlow({
    Key key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    @required this.gridDelegate,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double cacheExtent,
    List<Widget> children = const <Widget>[],
    int semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
  })  : assert(gridDelegate != null),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount ?? children.length,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
        );

  /// Creates a scrollable, 2D array of widgets whose size is variable in the main axis
  /// that are created on demand.
  ///
  /// This constructor is appropriate for grid views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null `itemCount` improves the ability of the [WaterfallFlow] to
  /// estimate the maximum scroll extent.
  ///
  /// `itemBuilder` will be called only with indices greater than or equal to
  /// zero and less than `itemCount`.
  ///
  /// The [gridDelegate] argument must not be null.
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildBuilderDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildBuilderDelegate.addRepaintBoundaries] property. Both must not
  /// be null.
  WaterfallFlow.builder({
    Key key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    @required this.gridDelegate,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double cacheExtent,
    int semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
  })  : assert(gridDelegate != null),
        childrenDelegate = SliverChildBuilderDelegate(
          itemBuilder,
          childCount: itemCount,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount ?? itemCount,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
        );

  /// Creates a scrollable, 2D array of widgets whose size is variable in the main axis
  /// with both a custom [SliverGridDelegate] and a custom [SliverChildDelegate].
  ///
  /// To use an [IndexedWidgetBuilder] callback to build children, either use
  /// a [SliverChildBuilderDelegate] or use the [WaterfallFlow.builder] constructor.
  ///
  /// The [gridDelegate] and [childrenDelegate] arguments must not be null.
  const WaterfallFlow.custom({
    Key key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    @required this.gridDelegate,
    @required this.childrenDelegate,
    double cacheExtent,
    int semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
  })  : assert(gridDelegate != null),
        assert(childrenDelegate != null),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
        );

  /// Creates a scrollable, 2D array of widgets whose size is variable in the main axis
  /// with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverWaterfallFlowDelegate] as the [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [new SliverWaterfallFlow.count], the equivalent constructor for [SliverWaterfallFlow].
  WaterfallFlow.count({
    Key key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    @required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double cacheExtent,
    List<Widget> children = const <Widget>[],
    int semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    LastChildLayoutTypeBuilder lastChildLayoutTypeBuilder,
    CollectGarbage collectGarbage,
    ViewportBuilder viewportBuilder,
    bool closeToTrailing = false,
  })  : gridDelegate = SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          lastChildLayoutTypeBuilder: lastChildLayoutTypeBuilder,
          collectGarbage: collectGarbage,
          viewportBuilder: viewportBuilder,
          closeToTrailing: closeToTrailing,
        ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          cacheExtent: cacheExtent,
          semanticChildCount: semanticChildCount ?? children.length,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
        );

  /// Creates a scrollable, 2D array of widgets in masonry layout with tiles
  /// that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverMasonryGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate].
  ///
  /// The `addAutomaticKeepAlives` argument corresponds to the
  /// [SliverChildListDelegate.addAutomaticKeepAlives] property. The
  /// `addRepaintBoundaries` argument corresponds to the
  /// [SliverChildListDelegate.addRepaintBoundaries] property. Both must not be
  /// null.
  ///
  /// See also:
  ///
  ///  * [SliverGrid.extent], the equivalent constructor for [SliverGrid].
  WaterfallFlow.extent({
    Key key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    ScrollController controller,
    bool primary,
    ScrollPhysics physics,
    bool shrinkWrap = false,
    EdgeInsetsGeometry padding,
    @required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    List<Widget> children = const <Widget>[],
    int semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    LastChildLayoutTypeBuilder lastChildLayoutTypeBuilder,
    CollectGarbage collectGarbage,
    ViewportBuilder viewportBuilder,
    bool closeToTrailing = false,
  })  : gridDelegate = SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          lastChildLayoutTypeBuilder: lastChildLayoutTypeBuilder,
          collectGarbage: collectGarbage,
          viewportBuilder: viewportBuilder,
          closeToTrailing: closeToTrailing,
        ),
        childrenDelegate = SliverChildListDelegate(
          children,
          addAutomaticKeepAlives: addAutomaticKeepAlives,
          addRepaintBoundaries: addRepaintBoundaries,
          addSemanticIndexes: addSemanticIndexes,
        ),
        super(
          key: key,
          scrollDirection: scrollDirection,
          reverse: reverse,
          controller: controller,
          primary: primary,
          physics: physics,
          shrinkWrap: shrinkWrap,
          padding: padding,
          semanticChildCount: semanticChildCount ?? children.length,
          dragStartBehavior: dragStartBehavior,
          keyboardDismissBehavior: keyboardDismissBehavior,
        );

  /// A delegate that controls the masonry layout of the children within the [WaterfallFlow].
  ///
  /// The [WaterfallFlow], [WaterfallFlow.builder], and [WaterfallFlow.custom] constructors let you specify this
  /// delegate explicitly. The other constructors create a [gridDelegate]
  /// implicitly.
  final SliverWaterfallFlowDelegate gridDelegate;

  /// A delegate that provides the children for the [WaterfallFlow].
  ///
  /// The [WaterfallFlow.custom] constructor lets you specify this delegate
  /// explicitly. The other constructors create a [childrenDelegate] that wraps
  /// the given child list.
  final SliverChildDelegate childrenDelegate;

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverWaterfallFlow(
      delegate: childrenDelegate,
      gridDelegate: gridDelegate,
    );
  }
}
