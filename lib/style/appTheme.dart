import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:melodihub/style/appColors.dart';

ColorScheme accent = ColorScheme.fromSwatch(
  primarySwatch: getMaterialColorFromColor(
    Color(Hive.box('settings').get('accentColor', defaultValue: 0xFFF08080)),
  ),
  accentColor:
      Color(Hive.box('settings').get('accentColor', defaultValue: 0xFFF08080)),
);

ThemeData getAppDarkTheme() {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFF111c2d),
    canvasColor: const Color(0xFF111c2d),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF111c2d)),
    bottomAppBarColor: const Color.fromARGB(73, 77, 77, 77),
    colorScheme: accent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: 'MouldyCheeseRegular',
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF151515),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2.3,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF151515),
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(textColor: Colors.white),
    iconTheme: const IconThemeData(color: Colors.white),
    hintColor: Colors.white,
    textTheme: const TextTheme(
      bodyText2: TextStyle(color: Colors.white),
    ),
  );
}

ThemeData getAppLightTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Colors.white,
    canvasColor: Colors.white,
    colorScheme: accent,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    bottomAppBarColor: const Color.fromARGB(75, 21, 21, 21),
    fontFamily: 'MouldyCheeseRegular',
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2.3,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      selectedColor: accent.primary.withOpacity(0.4),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF151515)),
    hintColor: const Color(0xFF151515),
  );
}
