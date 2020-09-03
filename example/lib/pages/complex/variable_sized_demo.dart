///
///  create by zmtzawqlp on 2019/11/21
///
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';
import 'package:waterfall_flow/waterfall_flow.dart';

import '../../common/data/tu_chong_repository.dart';
import '../../common/data/tu_chong_source.dart';
import '../../common/widget/item_builder.dart';
import '../../common/widget/push_to_refresh_header.dart';

@FFRoute(
  name: 'fluttercandies://variable-sized',
  routeName: 'variable-sized',
  description:
      'show how to build a variable-sized item with waterfall flow list.',
  exts: <String, dynamic>{
    'group': 'Complex',
    'order': 1,
  },
)
class VariableSizedDemo extends StatefulWidget {
  @override
  _VariableSizedDemoState createState() => _VariableSizedDemoState();
}

class _VariableSizedDemoState extends State<VariableSizedDemo> {
  TuChongRepository listSourceRepository = TuChongRepository();
  DateTime dateTimeNow;
  @override
  void dispose() {
    super.dispose();
    listSourceRepository.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefreshNotification(
      pullBackOnRefresh: false,
      maxDragOffset: maxDragOffset,
      armedDragUpCancel: false,
      onRefresh: onRefresh,
      child: LoadingMoreCustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: PullToRefreshContainer(
                (PullToRefreshScrollNotificationInfo info) {
              return PullToRefreshHeader(info, dateTimeNow);
            }),
          ),
          LoadingMoreSliverList<TuChongItem>(
            SliverListConfig<TuChongItem>(
              extendedListDelegate:
                  const SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: buildItem,
              sourceList: listSourceRepository,
              padding: const EdgeInsets.all(5.0),
              lastChildLayoutType: LastChildLayoutType.foot,
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(
    BuildContext c,
    TuChongItem item,
    int index,
  ) {
    return buildWaterfallFlowItem(c, item, index, konwSized: false);
  }

  Future<bool> onRefresh() {
    return listSourceRepository.refresh().whenComplete(() {
      dateTimeNow = DateTime.now();
    });
  }
}
