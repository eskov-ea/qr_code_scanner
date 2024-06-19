import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

@visibleForTesting
class SettingsScreenState extends State<SettingsScreen> {

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _db = GetIt.instance.get<DBProvider>();
  String factoryName = "Test";

  @override
  void initState() {
    super.initState();
    getConfigFromDb();
  }

  @override
  void dispose() {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    super.dispose();
  }

  Future<void> getConfigFromDb() async {
    try {
      final config = await _db.getConfig();
      String name = config?.factoryName == null ? "Гость" : config!.factoryName!;
      factoryName = name;
      setState(() {});
    } catch(err, stack) {
      print("Config: error: $stack");
    }
  }

  Future<void> changeFactoryName() {
    return showDialog(
      barrierDismissible: true,
      barrierColor: const Color(0x73000000),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: EdgeInsets.all(10),
                  height: 160,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text("Название производства:",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 50,
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: (val) {
                            setState(() {});
                          },
                          autofocus: false,
                          decoration: const InputDecoration(
                            disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2.5)
                            ),
                            labelStyle: TextStyle(fontSize: 22),
                            prefixIcon: Icon(Icons.person),
                            prefixIconColor: Colors.blue,
                            focusColor: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.transparent,
                        child: Ink(
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                                color: _controller.text.isEmpty ? Colors.grey[300] : Colors.blue[400]
                            ),
                            child: InkWell(
                              onTap: () async {
                                if (_controller.text.isEmpty) return;

                                try {
                                  await _db.setFactoryName(_controller.text);

                                } catch (err) {

                                }
                              },
                              splashColor: Colors.white24,
                              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
                              child: Center(
                                  child: Text("Сохранить")
                              ),
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundMain3,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5 - 130 ,
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
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text("Профиль сотрудника",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.bottomLeft,
                child: Text("Название производства:",
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                  textAlign: TextAlign.start,
                ),
              ),
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  color: Color(0xFFF0F0F0)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(factoryName,
                        style: const TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Ink(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            color: Colors.blue[300]
                        ),
                        child: InkWell(
                          onTap: () async {
                            await changeFactoryName();
                            _controller.text = "";
                          },
                          splashColor: Colors.white24,
                          customBorder: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6))
                          ),
                          child: const Center(
                            child: Text("Изменить",
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),



              // Container(
              //   height: MediaQuery.of(context).size.height * 0.5 - 130 ,
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.all(Radius.circular(10)),
              //       color: AppColors.backgroundNeutral2
              //   ),
              //   child: Stack(
              //     alignment: Alignment.center,
              //     children: [
              //       Image.asset("assets/images/confused.png",
              //         fit: BoxFit.contain, opacity: const AlwaysStoppedAnimation(.15)
              //       ),
              //       const Align(
              //         alignment: Alignment.bottomCenter,
              //         child: Padding(
              //           padding: EdgeInsets.only(bottom: 20),
              //           child: Text("Часто задаваемые вопросы",
              //             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              //           ),
              //         ),
              //       )
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
