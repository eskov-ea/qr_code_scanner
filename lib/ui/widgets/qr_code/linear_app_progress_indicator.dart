import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:qrs_scaner/services/qr_sending_manager/qr_sending_manager.dart';
import 'package:qrs_scaner/theme.dart';


class AppLinearProgressIndicator extends StatefulWidget {
  const AppLinearProgressIndicator({
    super.key
  });


  @override
  State<AppLinearProgressIndicator> createState() => _AppLinearProgressIndicatorState();
}

class _AppLinearProgressIndicatorState extends State<AppLinearProgressIndicator> with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _animation;
  /// Sending QR codes dialog's variables
  late final StreamSubscription _qrManagerEventSubscription;
  late final StreamSubscription _qrManagerStateSubscription;
  int totalCodeCount = 0;
  int successCodeCount = 0;
  int currentCodeCount = 0;
  bool showSendingDialog = false;


  @override
  void initState() {
    super.initState();
    _qrManagerEventSubscription = GetIt.instance.get<QRCodeSendingManager>().events.listen((event) {
      setState(() {
        totalCodeCount = event.payload.totalCodeCount;
        currentCodeCount = event.payload.currentCodeCount;
        successCodeCount = event.payload.successCodeCount;
      });
    });
    _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600)
    )
    ..addListener(() {
      if (_animationController.isCompleted) {
        _animationController.reverse();
      }
      if(_animationController.isDismissed){
        _animationController.forward();
      }
    });
    _animation = Tween<double>(begin: 0.6, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.fastOutSlowIn)
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _qrManagerEventSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var rW = totalCodeCount == 0 ? 15 : MediaQuery.of(context).size.width / totalCodeCount *  currentCodeCount;
    var cW = totalCodeCount == 0 || successCodeCount == 0 ? 10 : MediaQuery.of(context).size.width / totalCodeCount * successCodeCount;
    var offset = totalCodeCount == 0 ? 0 : MediaQuery.of(context).size.width / totalCodeCount * successCodeCount;
    var isFinished = totalCodeCount == successCodeCount;


    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 10),
            child: Text("Отправка ${successCodeCount + currentCodeCount}/$totalCodeCount QR-кодов")
        ),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 20,
            color: AppColors.cardColor5,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [

                /// Container shows completed progress
                Container(
                  width: cW.toDouble(),
                  decoration: BoxDecoration(
                      color: isFinished ? Colors.green[500] : AppColors.backgroundMain1,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      )
                  ),
                ),

                /// Container shows running progress
                Transform.translate(
                  offset: Offset(offset.toDouble() - 10, 0),
                  child: FadeTransition(
                    opacity: _animation,
                    child: Container(
                      width: rW.toDouble() + 10,
                      decoration: BoxDecoration(
                          color: AppColors.backgroundMain1,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          )
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ] ,
    );
  }
}
