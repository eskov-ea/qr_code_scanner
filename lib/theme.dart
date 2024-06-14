import 'dart:ui';
import 'package:flutter/material.dart';

final bool isDark = true;

abstract class LightColors {

}

abstract class DarkColors {
  static const backgroundMain1 = Color(0xFF0E51A7);
  static const backgroundMain2 = Color(0xFF274D7E);
  static const backgroundMain3 = Color(0xFF05326D);
  static const backgroundMain4 = Color(0xFF4282D3);
  static const backgroundMain5 = Color(0xFF6997D3);
  static const backgroundNeutral = Color(0xFFECECEC);
  static const backgroundNeutral2 = Color(0xFFF2F2F2);

  static const secondary1 = Color(0xFF2A17B1);
  static const secondary2 = Color(0xFF392E85);
  static const secondary3 = Color(0xFF150873);
  static const secondary4 = Color(0xFF5D4BD8);
  static const secondary5 = Color(0xFF7D71D8);
  static const secondary6 = Color(0xFFF0EFF8);

  static const accent1 = Color(0xFF00A67C);
  static const accent2 = Color(0xFF1F7C65);
  static const accent3 = Color(0xFF006C51);
  static const accent4 = Color(0xFF35D2AB);
  static const accent5 = Color(0xFF5FD2B5);

  static const textMain = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFD7D7D7);
  static const textFaded = Color(0xFF797979);
  static const textInfo1 = Color(0xFFA66600);
  static const textInfo2 = Color(0xFFBF8830);

  static const errorMain = Color(0xFFC40000);
  static const errorFieldFillColor = Color(0xFFFFEAEA);

  static const suiteAvailableStatus = Color(0xFFDEFFDA);
  static const suiteNotAvailableStatus = Color(0xFFFFCECE);

  static const suiteLuxuryClass = Color(0xFFFF1616);
  static const suiteComfortClass = Color(0xFFFFEE3A);
  static const suiteStandard1stClass = Color(0xFF2FE2FF);
  static const suiteStandard2ndClass = Color(0xFF59FF21);

  static const suiteEmptyState = Color(0xFFDEFFDA);
  static const suiteFullyOccupiedState = Color(0xFFFFDFB0);
  static const suitePartlyOccupiedState = Color(0xFFFFCECE);


  static const cardColor1 = Color(0x80FFE7E7);
  static const cardColor2 = Color(0xBFCFD6FC);
  static const cardColor3 = Color(0xFFFFF7F7);
  static const cardColor4 = Color(0xFFBFC5FF);
  static const cardColor5 = Color(0xFFA4C5EF);
}

abstract class AppColors {
  static Color transparent = const Color(0xFFFFFF);
  static Color backgroundMainCard = const Color(0xED274D7E);

  static Color backgroundMain1 = isDark ? DarkColors.backgroundMain1 : Color(0xFF0E51A7);
  static Color backgroundMain2 = isDark ? DarkColors.backgroundMain2 : Color(0xFF274D7E);
  static Color backgroundMain3 = isDark ? DarkColors.backgroundMain3 : Color(0xFF05326D);
  static Color backgroundMain4 = isDark ? DarkColors.backgroundMain4 : Color(0xFF4282D3);
  static Color backgroundMain5 = isDark ? DarkColors.backgroundMain5 : Color(0xFF6997D3);
  static Color backgroundNeutral = isDark ? DarkColors.backgroundNeutral : Color(0xFFECECEC);
  static Color backgroundNeutral2 = isDark ? DarkColors.backgroundNeutral2 : Color(0xFFF2F2F2);

  static Color secondary1 = isDark ? DarkColors.secondary1 : Color(0xFF2A17B1);
  static Color secondary2 = isDark ? DarkColors.secondary2 : Color(0xFF392E85);
  static Color secondary3 = isDark ? DarkColors.secondary3 : Color(0xFF150873);
  static Color secondary4 = isDark ? DarkColors.secondary4 : Color(0xFF5D4BD8);
  static Color secondary5 = isDark ? DarkColors.secondary5 : Color(0xFF7D71D8);
  static Color secondary6 = isDark ? DarkColors.secondary6 : Color(0xFFECEAFC);

  static Color accent1 = isDark ? DarkColors.accent1 : Color(0xFF00A67C);
  static Color accent2 = isDark ? DarkColors.accent2 : Color(0xFF1F7C65);
  static Color accent3 = isDark ? DarkColors.accent3 : Color(0xFF006C51);
  static Color accent4 = isDark ? DarkColors.accent4 : Color(0xFF35D2AB);
  static Color accent5 = isDark ? DarkColors.accent5 : Color(0xFF5FD2B5);

  static Color textMain = isDark ? DarkColors.textMain : Color(0xFFFFFFFF);
  static Color textSecondary = isDark ? DarkColors.textSecondary : Color(0xFFD7D7D7);
  static Color textFaded = isDark ? DarkColors.textFaded : Color(0xFFD7D7D7);
  static Color textInfo1 = isDark ? DarkColors.textInfo1 : Color(0xFFA66600);
  static Color textInfo2 = isDark ? DarkColors.textInfo2 : Color(0xFFBF8830);

  static Color errorMain = isDark ? DarkColors.errorMain : Color(0xFFC40000);
  static Color errorFieldFillColor = isDark ? DarkColors.errorFieldFillColor : Color(0xFFFFEAEA);

  static Color suiteAvailableStatus = isDark ? DarkColors.suiteAvailableStatus : Color(0xFFDEFFDA);
  static Color suiteNotAvailableStatus = isDark ? DarkColors.suiteNotAvailableStatus : Color(0xFFFFCECE);

  static Color suiteLuxuryClass = isDark ? DarkColors.suiteLuxuryClass : Color(0xFFFF1616);
  static Color suiteComfortClass = isDark ? DarkColors.suiteComfortClass : Color(0xFFFFEE3A);
  static Color suiteStandard1stClass = isDark ? DarkColors.suiteStandard1stClass : Color(0xFF2FE2FF);
  static Color suiteStandard2ndClass = isDark ? DarkColors.suiteStandard2ndClass : Color(0xFF59FF21);

  static Color suiteEmptyState = isDark ? DarkColors.suiteEmptyState : Color(0xFFDEFFDA);
  static Color suiteFullyOccupiedState = isDark ? DarkColors.suiteFullyOccupiedState : Color(0xFFFFDFB0);
  static Color suitePartlyOccupiedState = isDark ? DarkColors.suitePartlyOccupiedState : Color(0xFFFFCECE);


  static Color cardColor1 = isDark ? DarkColors.cardColor1 : Color(0x80FFE7E7);
  static Color cardColor2 = isDark ? DarkColors.cardColor2 : Color(0x80CFD6FC);
  static Color cardColor3 = isDark ? DarkColors.cardColor3 : Color(0xFFFFF7F7);
  static Color cardColor4 = isDark ? DarkColors.cardColor4 : Color(0xFFEAEDFF);
  static Color cardColor5 = isDark ? DarkColors.cardColor5 : Color(0xFFA4C5EF);

  static Color labelColor1 = const Color(0xB3000000);
}


abstract class AppStyles {

  static const mainTitleTextStyle = TextStyle(fontSize: 28, color: Color(0xFF000000), fontWeight: FontWeight.w600);
  static final submainTitleTextStyle = TextStyle(fontSize: 20, color: AppColors.backgroundMain2, height: 1);

  static const secondaryTextStyle = TextStyle(fontSize: 16, color: Color(0xFF242424));
  static const secondaryHalfTextStyle = TextStyle(fontSize: 12, color: Color(0xFF242424));

}



/// Reference to the application theme.
abstract class AppTheme {
  static final visualDensity = VisualDensity.adaptivePlatformDensity;

  /// Light theme and its settings.
  static ThemeData light() => ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      hintColor: DarkColors.textMain,
      visualDensity: visualDensity,
      scaffoldBackgroundColor: DarkColors.backgroundMain1,
      cardColor: DarkColors.backgroundMain4,
      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.red,
        shadowColor: Colors.grey,
        modalBackgroundColor: Colors.red

      ),
      primaryTextTheme: const TextTheme(
        titleLarge: TextStyle(color: DarkColors.textMain),
        titleMedium: TextStyle(color: DarkColors.textMain),
        titleSmall: TextStyle(color: DarkColors.textSecondary),
      ),
      iconTheme: const IconThemeData(color: DarkColors.textSecondary)
  );

  /// Dark theme and its settings.
  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    hintColor: DarkColors.textMain,
    visualDensity: visualDensity,
    scaffoldBackgroundColor: DarkColors.backgroundMain1,
    cardColor: DarkColors.backgroundMain4,
    primaryTextTheme: const TextTheme(
      titleLarge: TextStyle(color: DarkColors.textMain),
      titleMedium: TextStyle(color: DarkColors.textMain),
      titleSmall: TextStyle(color: DarkColors.textMain),
    ),
    iconTheme: const IconThemeData(color: DarkColors.textSecondary)
  );
}