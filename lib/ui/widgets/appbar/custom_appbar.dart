import 'package:flutter/material.dart';
import 'package:qrs_scaner/theme.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget{
  const CustomAppBar({
    this.height = 120,
    this.leadingWidth = 50,
    Key? key
  }) : super(key: key);

  final double height;
  final double leadingWidth;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppBarState extends State<CustomAppBar> {



  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
        leadingWidth: widget.leadingWidth,
        backgroundColor: AppColors.backgroundMain3,
        foregroundColor: Colors.white,
        actions: [],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("MCFEF сканер",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, letterSpacing: 1.0, textBaseline: TextBaseline.alphabetic, height: 1, color: Colors.white),
              ),
              SizedBox(height: 20),
              SizedBox(height: 5),
            ],
          ),
        )
    );
  }
}
