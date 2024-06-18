import 'package:flutter/src/foundation/change_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qrs_scaner/extentions/date_extension.dart';
import 'package:qrs_scaner/models/qr_code.dart';
import 'package:qrs_scaner/theme.dart';

class QRCodeItem extends StatefulWidget {
  const QRCodeItem({
    required this.qr,
    required this.lastIndex,
    required this.selectedMode,
    required this.selectedCodes,
    required this.setSelected,
    required this.disableSending,
    super.key
  });

  final QRCode qr;
  final bool lastIndex;
  final bool selectedMode;
  final bool disableSending;
  final Function(bool) setSelected;
  final ValueNotifier<List<QRCode>> selectedCodes;

  @override
  State<QRCodeItem> createState() => _QRCodeItemState();
}

class _QRCodeItemState extends State<QRCodeItem> {
  bool selected = false;

  void _onSelectedChange() {
    setState(() {
      selected = widget.selectedCodes.value.contains(widget.qr);
    });
  }

  @override
  void initState() {
    widget.selectedCodes.addListener(_onSelectedChange);
    selected = widget.selectedCodes.value.contains(widget.qr);
    super.initState();
  }

  @override
  void dispose() {
    widget.selectedCodes.removeListener(_onSelectedChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        if (widget.disableSending) return;
        widget.setSelected(true);

        if ( !widget.selectedCodes.value.contains(widget.qr) ) {
          widget.selectedCodes.value.add(widget.qr);
          widget.selectedCodes.notifyListeners();
        }
      },
      onTap: () {
        if (widget.selectedCodes.value.contains(widget.qr)) {
          widget.selectedCodes.value.remove(widget.qr);
        } else {
          widget.selectedCodes.value.add(widget.qr);
        }
        widget.selectedCodes.notifyListeners();
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: widget.lastIndex ? 10 : 5
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6)),
          color: AppColors.backgroundMain2
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                const SizedBox(width: 20),
                widget.selectedMode ? SizedBox(
                  width: 30,
                  height: 50,
                  child: Checkbox(
                    fillColor: MaterialStateProperty.all(Colors.white24),
                    value: selected,
                    shape: const CircleBorder(
                        side: BorderSide(width: 1)
                    ),
                    side: MaterialStateBorderSide.resolveWith(
                          (states) => const BorderSide(color: Colors.transparent),
                    ),
                    checkColor: Colors.white,
                    onChanged: (_) {},
                  ),
                ) : const Icon(CupertinoIcons.qrcode, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(widget.qr.value,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    overflow: TextOverflow.ellipsis,

                  ),
                ),
                const SizedBox(width: 20),
                Text(DateTimeExtension.getTime(widget.qr.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
                const SizedBox(width: 20)
              ],
            ),
            if (widget.selectedMode && selected) Container(
              color: Colors.white24,
              width: double.infinity,
              alignment: Alignment.centerLeft
            )
          ],
        )
      ),
    );
  }
}
