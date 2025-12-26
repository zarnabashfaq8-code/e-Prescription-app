import 'package:flutter/material.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? textController;
  final Widget icon;
  final Color? textColor;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.hint,
    this.textController,
    required this.icon,
    this.textColor,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textController,
      obscureText: obscureText,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: GoogleFonts.nunito(
        fontSize: 16,
        color: textColor ?? ColorPalette.honeyDew,
      ),
      decoration: InputDecoration(
        prefixIcon: icon,
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: ColorPalette.coolGrey,
        ),
        filled: true,
        fillColor: ColorPalette.chineseBlack.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ColorPalette.coolGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColorPalette.coolGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: ColorPalette.malachiteGreen, width: 2),
        ),
      ),
    );
  }
}
