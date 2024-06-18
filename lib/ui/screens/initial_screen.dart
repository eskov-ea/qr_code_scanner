import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/ui/screens/auth_screen.dart';
import 'package:qrs_scaner/ui/screens/home.dart';
import 'package:qrs_scaner/ui/widgets/circle_progress_widget.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen> {

  final _db = GetIt.instance.get<DBProvider>();
  final _cacheManager = GetIt.instance.get<CacheManager>();

  @override
  void initState() {
    super.initState();
    initializeAppData();
  }

  Future<void> initializeAppData() async {
    await _db.database;
    await _cacheManager.initialize();
    final token = await _cacheManager.getToken();
    print("Token is: $token");
    if (token == null) {
      print("We should navigate");
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AuthScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Home()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          color: Colors.white,
          child: const Center(
            child: CircleProgressWidget()
          )
      ),
    );
  }
}
