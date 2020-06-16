///
///  create by zmtzawqlp on 2019/11/19
///

import 'package:flutter/material.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';

import '../example_route.dart';
import '../example_routes.dart' as example_routes;
@FFRoute(
  name: 'fluttercandies://mainpage',
  routeName: 'MainPage',
)
class MainPage extends StatelessWidget {
 MainPage() {
    final List<String> routeNames = <String>[];
    routeNames.addAll(example_routes.routeNames);
    routeNames.remove('fluttercandies://picswiper');
    routeNames.remove('fluttercandies://mainpage');
    routes.addAll(routeNames
        .map<RouteResult>((String name) => getRouteResult(name: name)));
  }
  final List<RouteResult> routes = <RouteResult>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('MasonryGridView'),
        actions: <Widget>[
          ButtonTheme(
            minWidth: 0.0,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: FlatButton(
              child: const Text(
                'Github',
                style: TextStyle(
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                  color: Colors.white,
                ),
              ),
              onPressed: () {

              },
            ),
          ),
          ButtonTheme(
            padding: const EdgeInsets.only(right: 10.0),
            minWidth: 0.0,
            child: FlatButton(
              child: Container(),
                 // Image.network('https://pub.idqqimg.com/wpa/images/group.png'),
              onPressed: () {

              },
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext c, int index) {
          final RouteResult page = routes[index];
          return Container(
              margin: const EdgeInsets.all(20.0),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      (index + 1).toString() + '.' + page.routeName,
                      //style: TextStyle(inherit: false),
                    ),
                    Text(
                      page.description,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(context, routes[index].name);
                },
              ));
        },
        itemCount: routes.length,
      ),
    );
  }
}
