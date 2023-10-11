import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../string_consts.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({Key? key}) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(color: ColorManager.darkBlue, width: 1.0)),
          filled: true,
          prefixIcon: const Icon(Icons.search),
          labelText: StringConsts.search,
          labelStyle: TextStyle(color: ColorManager.searchBar)),
      onTap: () {
        setState(() {});
      },
    );
  }
}
