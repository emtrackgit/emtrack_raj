import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // 👈 NO background
      alignment: Alignment.center,
      child: IgnorePointer(
        // 👈 block touch
        child: Image.asset(
          'assets/images/emtrack_loader.gif',
          width: 120,
          height: 120,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
