import 'package:actuatorapp2/actuator%20pages/help_page.dart';
import 'package:actuatorapp2/main.dart';
import 'package:flutter/material.dart';

AppBar appBar({required String title, BuildContext? context}) {
  return AppBar(
    title: Text(title),
    actions: context != null
        ? [
            IconButton(
                onPressed: () {
                  routeToPage(context, const HelpPage());
                },
                icon: const Icon(Icons.help))
          ]
        : [],
  );
}
