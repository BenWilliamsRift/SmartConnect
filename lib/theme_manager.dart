import 'package:flutter/material.dart';

import 'color_manager.dart';

class ThemeManager {
  static ThemeData lightTheme = ThemeData.light().copyWith(
    navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorManager.navBarBackgroundLight,
        labelTextStyle: MaterialStateTextStyle.resolveWith((states) {
          return const TextStyle(color: Colors.white);
        })),
    appBarTheme: AppBarTheme(backgroundColor: ColorManager.appBarBackground),
    switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return ColorManager.switchTrackDisabled;
      }
      if (states.contains(MaterialState.selected)) {
        return ColorManager.switchTrackSelected;
      }
      return ColorManager.switchTrackUnselected;
    }), thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.disabled)) {
        return ColorManager.switchThumbDisabled;
      }
      if (states.contains(MaterialState.selected)) {
        return ColorManager.switchThumbSelected;
      }
      return ColorManager.switchThumb;
    })),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return ColorManager.disabled;
        } else if (states.contains(MaterialState.pressed)) {
          return ColorManager.colorPrimaryDark;
        }
        return ColorManager.colorPrimary;
      }),
    )),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: MaterialStateColor.resolveWith((states) {
        return ColorManager.colorPrimary;
      }),
    ),
  );

  static ThemeData darkTheme = ThemeData.dark().copyWith(
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: ColorManager.navBarBackgroundDark,
          labelTextStyle: MaterialStateTextStyle.resolveWith((states) {
            return TextStyle(color: ColorManager.labelTextDark);
          })),
      appBarTheme: AppBarTheme(backgroundColor: ColorManager.appBarBackgroundDark),
      switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return ColorManager.switchTrackDisabledDark;
          }
          if (states.contains(MaterialState.selected)) {
            return ColorManager.switchTrackSelectedDark;
          }
          return ColorManager.switchTrackUnselectedDark;
        }),
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return ColorManager.switchThumbDisabledDark;
          }
          return ColorManager.switchThumbDark;
        }),
      ));
}
