import 'package:flutter/material.dart';

import '../color_manager.dart';
import '../string_consts.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
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
