import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/extentions/date_extension.dart';
import 'package:qrs_scaner/models/log.dart';
import 'package:qrs_scaner/services/log_manager/log_manager.dart';

class Console extends StatefulWidget {
  const Console({super.key});

  @override
  State<Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {

  final ScrollController _controller = ScrollController();
  final _logManager = GetIt.instance.get<LogManager>();
  late final StreamSubscription<Log> _logSubscription;
  final List<Log> _logs = [];
  // final List<Log> _logs = [
  //   Log(id: 6, name: "Log 16", description: null, createdAt: DateTime.now().add(const Duration(hours: 15))),
  //   Log(id: 6, name: "Log 15", description: null, createdAt: DateTime.now().add(const Duration(hours: 14))),
  //   Log(id: 6, name: "Log 14, Моя рабочая машина имеет именно такой конфиг, только это макмини", description: null, createdAt: DateTime.now().add(const Duration(hours: 13))),
  //   Log(id: 6, name: "Log 13", description: null, createdAt: DateTime.now().add(const Duration(hours: 12))),
  //   Log(id: 6, name: "Log 12", description: null, createdAt: DateTime.now().add(const Duration(hours: 11))),
  //   Log(id: 6, name: "Log 11", description: null, createdAt: DateTime.now().add(const Duration(hours: 10))),
  //   Log(id: 6, name: "Log 10", description: null, createdAt: DateTime.now().add(const Duration(hours: 9))),
  //   Log(id: 6, name: "Log 9", description: null, createdAt: DateTime.now().add(const Duration(hours: 8))),
  //   Log(id: 6, name: "Log 8", description: null, createdAt: DateTime.now().add(const Duration(hours: 7))),
  //   Log(id: 6, name: "Log 7", description: null, createdAt: DateTime.now().add(const Duration(hours: 6))),
  //   Log(id: 5, name: "Log 5", description: null, createdAt: DateTime.now().add(const Duration(hours: 5))),
  //   Log(id: 4, name: "Log 4", description: null, createdAt: DateTime.now().add(const Duration(hours: 4))),
  //   Log(id: 3, name: "Log 3", description: null, createdAt: DateTime.now().add(const Duration(hours: 3))),
  //   Log(id: 2, name: "Log 2", description: null, createdAt: DateTime.now().add(const Duration(hours: 2))),
  //   Log(id: 1, name: "Log 1", description: null, createdAt: DateTime.now().add(const Duration(hours: 1))),
  // ];

  @override
  void initState() {
    super.initState();
    initialize();
    _logSubscription = _logManager.event.listen(_onLogEvent);
  }

  Future<void> initialize() async {
    await _logManager.initialize();
    setState(() {
      _logs.addAll(_logManager.state);
    });
  }

  void _onLogEvent(Log log) {
    setState(() {
      _logs.insert(0, log);
    });
  }

  @override
  void dispose() {
    _logManager.saveCodesToDb();
    _logSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          top: 10,
          bottom: 10,
          right: 10
        ),
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Scrollbar(
          controller: _controller,
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            reverse: true,
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: Text("${DateTimeExtension.getDate(_logs[index].createdAt)} ${DateTimeExtension.getTime(_logs[index].createdAt)} : ${_logs[index].name}",
                  style: TextStyle(fontSize: 12, color: Color(0xFFE7E7E7), height: 1),
                  textAlign: TextAlign.left,
                )
              );
            }
          )
        ),
      ),
    );
  }
}
