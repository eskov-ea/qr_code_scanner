import 'package:flutter/material.dart';

class CircleProgressWidget extends StatelessWidget {
  const CircleProgressWidget({
    this.message = "Загрузка",
    super.key
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          bottomLeft: Radius.circular(6),
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6)
      ),
      child: Container(
        height: 150,
        width: 150,
        padding: const EdgeInsets.only(left: 5, right: 10),
        decoration: const BoxDecoration(
          color:  Color(0xFFEAEAEA),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Color(0xFF0B17A4),
                strokeWidth: 6.0,
                strokeCap: StrokeCap.round,
              ),
            ),
            SizedBox(height: 15),
            Text(message,
              style: TextStyle(fontSize: 16, color: Color(0xFF0B17A4)),
            )
          ],
        ),
      ),
    );
  }
}
