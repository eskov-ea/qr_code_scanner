import 'package:flutter/material.dart';
import 'package:qrs_scaner/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5 - 120 ,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: AppColors.backgroundNeutral2
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/dating-app.png",
                  fit: BoxFit.contain, opacity: const AlwaysStoppedAnimation(.15),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text("Профиль сотрудника",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.5 - 120 ,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: AppColors.backgroundNeutral2
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/confused.png",
                  fit: BoxFit.contain, opacity: const AlwaysStoppedAnimation(.15)
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text("Часто задаваемые вопросы",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
