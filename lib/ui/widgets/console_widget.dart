import 'package:flutter/material.dart';

class Console extends StatefulWidget {
  const Console({super.key});

  @override
  State<Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<Console> {

  final ScrollController _controller = ScrollController();
  List<String> _logs = ["История событий!"];

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
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(_logs[index],
                  style: TextStyle(fontSize: 12, color: Colors.white),
                )
              );
            }
          )
        ),
      ),
    );
  }
}
