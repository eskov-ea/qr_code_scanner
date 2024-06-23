import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:qrs_scaner/services/cache_manager/cache_manager.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/theme.dart';
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
  bool error = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    initializeAppData();
  }

  Future<void> initializeAppData() async {
    try {
      if (error) {
        setState(() {
          error = false;
        });
      }
      await _db.database;
      await _cacheManager.initialize();
      final token = await _cacheManager.getToken();
      if (token == null) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AuthScreen()));
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Home()));
      }
    } on AppException catch (err) {
      setState(() {
        error = true;
        errorMessage = err.message ?? "Ошибка чтения конфигурации приложения с базы данных";
      });
    } catch (err) {
      setState(() {
        error = true;
        errorMessage = "Ошибка загрузки данных при старке приложения. Перезапустите приложение, если это не поможет - свяжитесь с разработчиком.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          color: error ? Colors.orange[50] : Colors.white,
          child: Center(
            child: error
            ? Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(horizontal: 10),
              height: 150,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: Colors.orange[600]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(
                        "assets/icons/popup-warning-icon.png"),
                  ),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(errorMessage,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: Ink(
                                width: MediaQuery.of(context).size.width,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(6)),
                                  color: AppColors.secondary2
                                ),
                                child: InkWell(
                                  onTap: initializeAppData,
                                  customBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                                  child: const Center(
                                    child: Text("Обновить",
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                  ),
                ],
              ),
            )
          : CircleProgressWidget()
          )
      ),
    );
  }
}
