import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/exceptions/exceptions.dart';
import 'package:qrs_scaner/extentions/date_extension.dart';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/services/database/database_provider.dart';
import 'package:qrs_scaner/services/error_handlers/error_handler_manager.dart';
import 'package:qrs_scaner/services/log_manager/log_manager.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/theme.dart';
import 'package:qrs_scaner/ui/widgets/circle_progress_widget.dart';
import 'package:qrs_scaner/ui/widgets/qr_code/qr_code_item.dart';
import 'package:qrs_scaner/ui/widgets/qr_code/qr_code_list_date.dart';

class QRAnalyticScreen extends StatefulWidget {
  const QRAnalyticScreen({
    super.key
  });

  @override
  State<QRAnalyticScreen> createState() => QRAnalyticScreenState();
}

class QRAnalyticScreenState extends State<QRAnalyticScreen> {

  final ScrollController _controller = ScrollController();
  final db = GetIt.instance.get<DBProvider>();
  final _logManager = GetIt.instance.get<LogManager>();
  final _errorManager = GetIt.instance.get<ErrorHandlerManager>();
  late final StreamSubscription<QRStreamState> _qrManagerStateSubscription;
  late final StreamSubscription<QRCode> _qrManagerCodesSubscription;
  final String defaultErrorMessage = "Что-то пошло не так. Попробуйте еще раз.";
  final QRCodeSendingManager _qrCodeSendingManager = GetIt.instance.get<QRCodeSendingManager>();
  List<QRCode>? qrcodes;
  final List<String> menuList = ['Активные', 'Проведенные'];
  String? dropdownValue;
  ValueNotifier<List<QRCode>> selectedCodes = ValueNotifier<List<QRCode>>([]);
  bool selectedMode = false;
  bool loading = false;
  bool error = false;
  bool disableSending = false;
  String? errorMessage;
  int selectedCodesCount = 0;
  final _gradient = const LinearGradient(
    colors: [
      Color(0xFFE3E3E3),
      Color(0xFFD3D3D3),
      Color(0xFFE3E3E3),
    ],
    begin: FractionalOffset(0.0, 0.0),
    end: FractionalOffset(1.0, 0.0),
    stops: [0.0, 0.5, 1.0],
  );

  void setSelectedMode(bool value) {
    setState(() {
      selectedMode = value;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeQRCodes();
    dropdownValue = menuList.first;
    _qrManagerStateSubscription = GetIt.instance.get<QRCodeSendingManager>().state.listen((QRStreamState state) {
      if (state == QRStreamState.updated) {
        initializeQRCodes();
      } else if (state == QRStreamState.atoned) {
        _logManager.addLogEntity(Log.fromEvent("Успешно погашено $selectedCodesCount кодов."));
        setState(() {
          qrcodes = null;
          selectedCodes.value = [];
          selectedMode = false;
        });
      }
    });
    _qrManagerCodesSubscription = GetIt.instance.get<QRCodeSendingManager>().codes.listen((qr) {
      setState(() {
        qrcodes!.add(qr);
      });
    });
    selectedCodes.addListener(_onSelectedCodesChange);
  }

  void _onSelectedCodesChange() {
    setState(() {
      selectedCodesCount = selectedCodes.value.length;
    });
  }

  @override
  void dispose() {
    _qrManagerStateSubscription.cancel();
    _qrManagerCodesSubscription.cancel();
    super.dispose();
  }


  Future<void> initializeQRCodes() async {
    if (error) {
      setState(() {
        error = false;
        errorMessage = null;
        loading = true;
      });
    }
    try {
      //TODO: create loader widget while initializing DB
      await db.database;
      final codes = await db.getActiveQRCodes();
      setState(() {
        qrcodes = codes;
        loading = false;
      });
    } catch(err) {
      setState(() {
        error = true;
        loading = false;
      });
    }
  }
  Future<void> getQRCodesByQuery(String? value) async {
    try {
      if (error) {
        setState(() {
          error = false;
        });
      }
      if (value == menuList[0]) {
        final codes = await db.getActiveQRCodes();
        setState(() {
          qrcodes = codes;
          disableSending = false;
          selectedMode = false;
        });
      } else if (value == menuList[1]) {
        final codes = await db.getAtonedQRCodes();
        setState(() {
          qrcodes = codes;
          disableSending = true;
          selectedMode = false;
        });
      }
    } catch (err) {
      _errorManager.sinkEvent(AppException(type: AppExceptionType.db));
      setState(() {
        error = true;
        qrcodes = [];
      });
    }
  }

  bool shouldRenderDateWidget(int index) {
    return index == 0 || !DateTimeExtension.isSameDateWithTimeZone(qrcodes![index].createdAt, qrcodes![index - 1].createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundMain3,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _mapStateToWidget(),
              if (selectedMode) _controlPanel()
            ],
          )
        ),
      )
    );
  }

  Widget _mapStateToWidget() {
    if (error) {
      return Container(
        key: const Key("qr_analytics_screen_error_widget"),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 50
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: 50,
                          child: Image.asset("assets/icons/popup-warning-icon.png"),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(errorMessage ?? defaultErrorMessage,
                              style: TextStyle(),
                              softWrap: true
                          ),
                        ),
                      )
                    ],
                  ),
                )
            ),
            const SizedBox(height: 20),
            const SizedBox(
              child: Text("Попробовать\r\nеще раз?",
                style: TextStyle(fontSize: 36, height: 1, fontWeight: FontWeight.bold),
              )
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(bottom: 70),
                    child: Image.asset("assets/images/inspiration.png",
                      fit: BoxFit.fill,
                      opacity: const AlwaysStoppedAnimation(.15)
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: ElevatedButton(
                      onPressed: initializeQRCodes,
                      style: ElevatedButton.styleFrom(
                        maximumSize: Size(MediaQuery.of(context).size.width, 50),
                        minimumSize: Size(MediaQuery.of(context).size.width, 50),
                        surfaceTintColor: Colors.white,
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.backgroundMain3
                      ),
                      child: Text("Обновить"),
                    ),
                  ),
                ],
              )
            )
          ],
        ),
      );
    }
    if (qrcodes != null) {
      return Column(
        children: [
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: AppColors.backgroundNeutral,
            child: _sortControls(),
          ),
          qrcodes!.isNotEmpty ? Expanded(
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: false,
              thickness: 5,
              trackVisibility: false,
              radius: const Radius.circular(7),
              scrollbarOrientation: ScrollbarOrientation.right,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: qrcodes!.length,
                        (context, index) {
                          return Column(
                            children: [
                              if (shouldRenderDateWidget(index)) QRCodeListDate(qrcodes![index].createdAt),
                              QRCodeItem(
                                qr: qrcodes![index],
                                lastIndex: index == qrcodes!.length - 1,
                                selectedMode: selectedMode,
                                selectedCodes: selectedCodes,
                                setSelected: setSelectedMode,
                                disableSending: disableSending
                              )
                            ],
                          );
                        }
                    )
                  )
                ],
              ),
            ),
          ) : const Expanded(
            child: Center(
              key: Key("qr_analytics_screen_empty_list_widget"),
              child: Text('Нет сохраненных QR-кодов'),
            ),
          ),
          if (selectedMode)  const SizedBox(height: 60)
        ],
      );
    } else {
      return const Center(
        key: Key("qr_analytics_screen_progress_widget"),child: CircleProgressWidget(),
      );
    }
  }
  Widget _controlPanel() {
    return Container(
      key: const Key("qr_analytics_selected_codes_control_panel"),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10)
        ),
        color: AppColors.secondary3
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Material(
            color: Colors.transparent,
            child: Ink(
              key: const Key("qr_analytics_selected_codes_control_panel_dismiss"),
              width: 120,
              child: InkWell(
                onTap: () {
                  setSelectedMode(false);
                  selectedCodes.value = <QRCode>[];
                },
                splashColor: Colors.white12,
                child: Container(
                  padding: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: const Text("Отменить",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: Ink(
              key: const Key("qr_analytics_selected_codes_control_panel_atone"),
              width: 120,
              child: InkWell(
                onTap: () {
                  if (selectedCodes.value.isEmpty) return;

                  _qrCodeSendingManager.sendQRCodesToServer(selectedCodes.value);
                },
                splashColor: Colors.white24,
                child: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: Text("Погасить",
                    style: TextStyle(fontSize: 16, color: selectedCodesCount > 0 ? Colors.white : Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _sortControls() {
    return Container(
      key: const Key("qr_selection_control_panel"),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          selectedMode ? SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Ink(
                    key: const Key("qr_selection_control_panel_unselect_all_button"),
                    decoration: BoxDecoration(
                      gradient: _gradient,
                      borderRadius: const BorderRadius.all(Radius.circular(6))
                    ),
                    child: InkWell(
                      onTap: () {
                        selectedCodes.value.clear();
                        selectedCodes.notifyListeners();
                      },
                      splashColor: Colors.white24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerLeft,
                        child: const Text("Снять выделение",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: Ink(
                    key: const Key("qr_selection_control_panel_select_all_button"),
                    decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: const BorderRadius.all(Radius.circular(6))
                    ),
                    child: InkWell(
                      onTap: () {
                        selectedCodes.value.clear();
                        selectedCodes.value.addAll(qrcodes!);
                        selectedCodes.notifyListeners();
                      },
                      splashColor: Colors.white24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerRight,
                        child: const Text("Выделить все",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ) : Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 40,
              width: 100,
              child: qrcodes!.isNotEmpty ? Material(
                color: Colors.transparent,
                child: Ink(
                  key: const Key("activate_selection_mode_btn"),
                  decoration: BoxDecoration(
                      gradient: _gradient,
                      borderRadius: const BorderRadius.all(Radius.circular(6))
                  ),
                  child: InkWell(
                    onTap: () {
                      if (disableSending) return;
                      setSelectedMode(true);
                    },
                    splashColor: Colors.white24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.centerLeft,
                      child: const Text("Выбрать",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ) : const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Показать: ",
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Expanded(
                    child: DropdownMenu<String>(
                      menuHeight: 200,
                      width: MediaQuery.of(context).size.width - 100 - 20,
                      initialSelection: menuList.first,
                      onSelected: (String? value) async {
                        if (dropdownValue == value) return;
                        await getQRCodesByQuery(value);
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      menuStyle: MenuStyle(
                        maximumSize: MaterialStateProperty.all(const Size(double.infinity, 40)),
                        surfaceTintColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor: MaterialStateProperty.all(Colors.white),
                      ),
                      dropdownMenuEntries: menuList.map<DropdownMenuEntry<String>>((String value) {
                        return DropdownMenuEntry<String>(value: value, label: value,);
                      }).toList(),
                      trailingIcon: const Icon(Icons.arrow_drop_down_outlined, size: 20),
                      selectedTrailingIcon: const Icon(Icons.arrow_drop_up_outlined, size: 20),
                      inputDecorationTheme: const InputDecorationTheme(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        constraints: BoxConstraints(
                            maxHeight: 40,
                            minHeight: 0
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(width: 1, color: Colors.black38)
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
