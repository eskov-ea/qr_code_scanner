import 'package:flutter/material.dart';
import 'package:qrs_scaner/factories/screen_factory.dart';

abstract class MainNavigationRouteNames {
  static const initialScreen = 'initialScreen';
  static const authScreen = 'auth_screen';
  static const homeScreen = 'home_screen';
}

class MainNavigation {

  static final _screenFactory = ScreenFactory();

  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.initialScreen: (_) => _screenFactory.makeInitialScreen(),
    MainNavigationRouteNames.authScreen: (_) => _screenFactory.makeAuthScreen(),
    MainNavigationRouteNames.homeScreen: (_) => _screenFactory.makeHomeScreen(),
  };

}