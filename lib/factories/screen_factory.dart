import 'package:flutter/material.dart';
import 'package:qrs_scaner/ui/screens/auth_screen.dart';
import 'package:qrs_scaner/ui/screens/home.dart';
import 'package:qrs_scaner/ui/screens/initial_screen.dart';
import 'package:qrs_scaner/ui/screens/qr_analytic.dart';
import 'package:qrs_scaner/ui/screens/scanner.dart';
import 'package:qrs_scaner/ui/screens/settings.dart';

class ScreenFactory {
  Widget makeScannerScreen(ValueNotifier<int> selectedTab) {
    return ScannerScreen(selectedTab: selectedTab);
  }

  Widget makeQRAnalyticScreen() {
    return QRAnalyticScreen();
  }

  Widget makeSettingsScreen() {
    return const SettingsScreen();
  }

  Widget makeHomeScreen() {
    return const Home();
  }

  Widget makeAuthScreen() {
    return const AuthScreen();
  }

  Widget makeInitialScreen() {
    return const InitialScreen();
  }
}