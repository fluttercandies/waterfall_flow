import 'package:extended_list_library/extended_list_library.dart';
///
///  create by zmtzawqlp on 2019/11/9
///
import 'package:flutter/widgets.dart' hide ViewportBuilder;
import 'package:waterfall_flow/src/rendering/sliver_waterfall_flow.dart';


/// A sliver that places multiple box children in a two dimensional arrangement
/// and masonry layout.
///
/// [SliverWaterfallFlow] places its children in arbitrary positions determined by
/// [gridDelegate]. Each child is forced to have the size specified by the
/// [gridDelegate].
///
/// The main axis direction of a grid is the direction in which it scrolls; the
/// cross axis direction is the orthogonal direction.
///
///
/// This example, which would be inserted into a [CustomScrollView.slivers]
/// list, shows twenty boxes in a pretty teal grid with masonry layout:
///
/// ```dart
/// SliverWaterfallFlow(
///   gridDelegate: SliverWaterfallFlowDelegate(
///     crossAxisCount: 2,
///     mainAxisSpacing: 10.0,
///     crossAxisSpacing: 10.0,
///   ),
///   delegate: SliverChildBuilderDelegate(
///     (BuildContext context, int index) {
///       return Container(
///         alignment: Alignment.center,
///         color: Colors.teal[100 * (index % 9)],
///         child: Text('grid item $index'),
///         height: 50.0 + 100.0 * (index % 9)
///       );
///     },
///     childCount: 20,
///   ),
/// )
/// ```
/// {@end-tool}
///
/// {@macro flutter.widgets.sliverChildDelegate.lifecycle}
///
/// See also:
///
///  * [SliverList], which places its children in a linear array.
///  * [SliverFixedExtentList], which places its children in a linear
///    array with a fixed extent in the main axis.
///  * [SliverPrototypeExtentList], which is similar to [SliverFixedExtentList]
///    except that it uses a prototype list item instead of a pixel value to define
///    the main axis extent of each item.
///  * [SliverGrid], which places its children in arbitrary positions.
class SliverWaterfallFlow extends SliverMultiBoxAdaptorWidget {
  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement and masonry layout.
  const SliverWaterfallFlow({
    Key key,
    @required SliverChildDelegate delegate,
    @required this.gridDelegate,
  }) : super(key: key, delegate: delegate);

  /// Creates a sliver that places multiple box children in a two dimensional
  /// arrangement and masonry layout with a fixed number of tiles in the cross axis.
  ///
  /// Uses a [SliverWaterfallFlowDelegate] as the [gridDelegate],
  /// and a [SliverChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new WaterfallFlow.count], the equivalent constructor for [WaterfallFlow] widgets.
  SliverWaterfallFlow.count({
    Key key,
    @required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    List<Widget> children = const <Widget>[],
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
        super(key: key, delegate: SliverChildListDelegate(children));

  /// Creates a sliver that places multiple box children in masonry layout
  /// with tiles that each have a maximum cross-axis extent.
  ///
  /// Uses a [SliverMasonryGridDelegateWithMaxCrossAxisExtent] as the [gridDelegate],
  /// and a [SliverChildListDelegate] as the [delegate].
  ///
  /// See also:
  ///
  ///  * [new MasonryGridView.extent], the equivalent constructor for [MasonryGridView] widgets.
  SliverWaterfallFlow.extent({
    Key key,
    @required double maxCrossAxisExtent,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    List<Widget> children = const <Widget>[],
    LastChildLayoutTypeBuilder lastChildLayoutTypeBuilder,
    CollectGarbage collectGarbage,
    ViewportBuilder viewportBuilder,
    bool closeToTrailing = false,
  }) : gridDelegate = SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
         maxCrossAxisExtent: maxCrossAxisExtent,
         mainAxisSpacing: mainAxisSpacing,
         crossAxisSpacing: crossAxisSpacing,
         lastChildLayoutTypeBuilder: lastChildLayoutTypeBuilder,
         collectGarbage: collectGarbage,
         viewportBuilder: viewportBuilder,
         closeToTrailing: closeToTrailing,
       ),
       super(key: key, delegate: SliverChildListDelegate(children));

  /// The delegate that controls the size and position of the children.
  final SliverWaterfallFlowDelegate gridDelegate;

  @override
  RenderSliverWaterfallFlow createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element = context as SliverMultiBoxAdaptorElement;
    return RenderSliverWaterfallFlow(
        childManager: element, gridDelegate: gridDelegate);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSliverWaterfallFlow renderObject) {
    renderObject.gridDelegate = gridDelegate;
  }
}

