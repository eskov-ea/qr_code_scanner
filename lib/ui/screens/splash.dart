import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrs_scaner/theme.dart';
import 'package:qrs_scaner/ui/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(const Duration(seconds: 2)).then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Home())
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain3,
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Image.asset(
                "assets/icons/qr-scan.gif",
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text("MCFEF QR-код\r\n сканер",
              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600, height: 0.9),
              textAlign: TextAlign.center,

            )
          ],
        ),
      ),
    );
  }
}
