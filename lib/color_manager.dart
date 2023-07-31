import 'package:flutter/material.dart';

import 'settings.dart';
import 'theme_manager.dart';

class ColorManager {
  // Old app colors
  static get colorPrimary => const Color.fromARGB(255, 0, 73, 160);
  static get colorPrimaryDark => const Color.fromARGB(255, 0, 56, 123);
  static get colorPrimaryLight => const Color.fromARGB(255, 0, 100, 241);
  static get colorAccent => const Color.fromARGB(255, 255, 172, 19);
  static get yellow1 => const Color.fromARGB(255, 255, 247, 124);
  static get yellow2 => const Color.fromARGB(255, 255, 242, 39);
  static get grey05 => const Color.fromARGB(255, 227, 227, 227);
  static get orange4 => const Color.fromARGB(255, 255, 218, 130);
  static get orange5 => const Color.fromARGB(255, 255, 190, 35);
  static get blue2 => const Color.fromARGB(255, 111, 123, 236);
  static get blue25 => const Color.fromARGB(255, 41, 54, 179);
  static get lightGreen1 => const Color.fromARGB(255, 235, 235, 235);
  static get lightGreen2 => const Color.fromARGB(255, 105, 167, 105);
  static get green1 => const Color.fromARGB(255, 0, 66, 37);
  static get green2 => const Color.fromARGB(255, 0, 217, 0);
  static get lightRed1 => const Color.fromARGB(255, 227, 156, 156);
  static get lightRed2 => const Color.fromARGB(255, 174, 110, 110);
  static get red1 => const Color.fromARGB(255, 255, 0, 0);
  static get red2 => const Color.fromARGB(255, 208, 4, 4);
  static get lightOrange1 => const Color.fromARGB(255, 220, 191, 163);
  static get lightOrange2 => const Color.fromARGB(255, 167, 140, 114);
  static get orange1 => const Color.fromARGB(255, 255, 128, 0);
  static get orange2 => const Color.fromARGB(255, 210, 107, 7);
  static get light => const Color.fromARGB(255, 232, 232, 233);

  static get text => const Color.fromARGB(255, 0, 0, 0);

  static get open => const Color.fromARGB(255, 63, 196, 131);

  static get close => const Color.fromARGB(255, 228, 76, 69);

  static get auto => const Color.fromARGB(255, 87, 201, 243);

  static get manual => const Color.fromARGB(255, 250, 202, 118);

  static get danger => const Color.fromARGB(255, 202, 11, 0);

  static get itemGrey => const Color.fromARGB(255, 255, 255, 255);

  static get shadows => const Color.fromARGB(255, 0, 0, 0);

  static get shadows2 => const Color.fromARGB(255, 0, 0, 0);

  // New app colors
  // App bar
  static get appBarBackground => colorPrimary;

  static get appBarBackgroundDark => colorPrimary;

  // Switch track
  static get switchTrackDisabled => disabled;

  static get switchTrackDisabledDark => Colors.purple.withOpacity(.48);

  static get switchTrackSelected => green2;

  static get switchTrackSelectedDark => Colors.white;

  static get switchTrackUnselected => red1;

  static get switchTrackUnselectedDark => Colors.black12;

  // Switch thumb
  static get switchThumbSelected => green2.withOpacity(.48);
  static get switchThumbSelectedDark => companyYellow;
  static get switchThumbDisabled => disabled.withOpacity(.48);
  static get switchThumbDisabledDark => Colors.purpleAccent.withOpacity(.48);
  static get switchThumb => red1.withOpacity(.48);
  static get switchThumbDark => companyYellow;

  // Navigation drawer
  static get navDrawText => Settings.isDarkMode ? Colors.white : text;
  static get navDrawDiv => companyYellow;
  static get navDrawHead => Settings.isDarkMode
      ? ThemeManager.darkTheme.navigationBarTheme.backgroundColor
      : ThemeManager.lightTheme.navigationBarTheme.backgroundColor;
  static get navDrawHeadText => Colors.white;

  static get navDrawBackground =>
      Settings.isDarkMode ? Colors.black : Colors.white;

  // Navigation bar
  static get navBarBackgroundLight => colorPrimary;

  static get navBarBackgroundDark => colorPrimaryDark;

  // Default button
  static get defaultButtonBackground => colorPrimary;

  // Other colors
  static get companyYellow => const Color.fromARGB(255, 255, 181, 43);

  static get darkBlue => const Color.fromARGB(255, 50, 50, 255);

  static get subtitleLight => Colors.black45;

  static get subtitleDark => Colors.white54;

  static get labelTextDark => Colors.white;

  static get listTileBorder =>
      Settings.isDarkMode ? Colors.deepPurpleAccent : Colors.blue;

  static get tileColor =>
      Settings.isDarkMode ? Colors.purple : Colors.lightBlue;

  static get searchBar => Settings.isDarkMode ? Colors.white70 : Colors.black45;

  static get actuatorOpenButton => Colors.green;
  static get actuatorCloseButton => Colors.red;
  static get rotateLeftOutlinedButton => Colors.green;
  static get rotateRightOutlinedButton => Colors.red;
  static get actuatorIcon => Colors.white;
  static get passwordFieldHoverColor => Colors.transparent;
  static get snackBar => Settings.isDarkMode ? Colors.black : Colors.white;
  static get timePickerRotTextColor => Colors.white.withOpacity(0.8);
  static get checkBoxActiveColor =>
      Settings.isDarkMode ? Colors.purpleAccent : Colors.blue;
  static get divider => Settings.isDarkMode ? Colors.white54 : Colors.black26;
  static get angleRingColor => Settings.isDarkMode ? Colors.white : darkBlue;
  static get angleLineColor => companyYellow;
  static get angleRingBackground => Settings.isDarkMode
      ? const Color.fromARGB(255, 48, 48, 48)
      : const Color.fromARGB(255, 250, 250, 250);
  static get disabledRing => Settings.isDarkMode
      ? Colors.grey.withOpacity(0.7)
      : Colors.black.withOpacity(0.7);
  static get disabled => const Color.fromARGB(255, 125, 25, 25);
}
