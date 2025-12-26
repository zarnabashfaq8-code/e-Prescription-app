import 'package:flutter/material.dart';
import 'package:erx/utils/color_palette.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 25,
        height: 25,
        child: CircularProgressIndicator(
          color: ColorPalette.malachiteGreen, // ERX theme color
          strokeWidth: 3,
        ),
      ),
    );
  }
}
