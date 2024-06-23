import 'package:flutter/material.dart';
import 'package:qrs_scaner/navigation/main_navigation.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';

Future<void> SessionExpiredModalWidget(BuildContext context, DBProvider db) {
  const period = Duration(seconds: 10);
  bool stopTask = false;
  Future.delayed(period).then((_) {
    if (!stopTask) {
      db.deleteAuthToken();
      Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.authScreen);
    }
  });
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () { return Future.value(false); },
        child: AlertDialog(
          title: const Text('Авторизация устарела'),
          content: const Text(
            'В целях безопасности необходимо\n'
                'пройти авторизацию снова.\n'
                '\n'
                'Нажмите кнопку "Ок" чтобы перейти на экран авторизации.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ок'),
              onPressed: () {
                stopTask = true;
                db.deleteAuthToken();
                Navigator.of(context).pushReplacementNamed(MainNavigationRouteNames.authScreen);
              },
            ),
          ],
        ),
      );
    },
  );
}