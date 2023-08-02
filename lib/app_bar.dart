import 'package:actuatorapp2/help_page.dart';
import 'package:actuatorapp2/main.dart';
import 'package:flutter/material.dart';

AppBar appBar({required String title, BuildContext? context, Key? helpKey}) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    actions: context != null
        ? [
            IconButton(
                onPressed: () {
                  routeToPage(context, const HelpPage());
                },
                icon: Icon(Icons.help, key: helpKey))
          ]
        : [],
  );
}
