import 'package:flutter/material.dart';

AppBar appBar(
    {required String title,
    bool centerTitle = true,
    TabBar? tabBar,
    List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    centerTitle: centerTitle,
    bottom: tabBar,
    actions: actions,
  );
}
