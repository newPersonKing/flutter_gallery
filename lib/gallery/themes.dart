
import 'package:flutter/material.dart';

class GalleryTheme {

  final String name;
  final ThemeData data;

  const GalleryTheme(this.name,this.data);
}

final GalleryTheme kDarkGalleryTheme = GalleryTheme('Dark', _buildDarkTheme());
final GalleryTheme kLightGalleryTheme = GalleryTheme('Light', _buildLightTheme());

TextTheme _buildTextTheme(TextTheme base){
  return base.copyWith(
      title: base.title.copyWith(
          fontFamily: 'GoogleSans'
      )
  );
}

ThemeData _buildDarkTheme(){
  const Color primaryColor = Color(0xFF0175c2);
  const Color secondaryColor = Color(0xFF13B9FD);

  final ThemeData base = ThemeData.dark();
  /*todo 这个类暂时没找到*/
//  final ColorScheme colorScheme = const ColorScheme.dark().copyWith(
//    primary: primaryColor,
//    secondary: secondaryColor,
//  );
  return base.copyWith(
    primaryColor: primaryColor,
    secondaryHeaderColor: secondaryColor,
    indicatorColor: Colors.white,
    accentColor: secondaryColor,
    canvasColor: const Color(0xFF202124),
    scaffoldBackgroundColor: const Color(0xFF202124),
    backgroundColor: const Color(0xFF202124),
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary
    ),
    textTheme:_buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme)
  );
}

ThemeData _buildLightTheme(){
  const Color primaryColor = Color(0xFF0175c2);
  const Color secondaryColor = Color(0xFF13B9FD);
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    primaryColor: primaryColor,
    buttonColor: primaryColor,
    indicatorColor: Colors.white,
    splashColor: Colors.white24,
    splashFactory: InkRipple.splashFactory,
    accentColor: secondaryColor,
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    backgroundColor: Colors.white,
    errorColor: const Color(0xFFB00020),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: _buildTextTheme(base.textTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
  );
}


