import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/widgets/background_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erx/screens/doctor_home_screen.dart';

class DoctorQualificationScreen extends StatefulWidget {
  final String name;
  final String userId;

  const DoctorQualificationScreen({
    Key? key,
    required this.name,
    required this.userId,
  }) : super(key: key);

  @override
  State<DoctorQualificationScreen> createState() =>
      _DoctorQualificationScreenState();
}

class _DoctorQualificationScreenState
    extends State<DoctorQualificationScreen> {
  final TextEditingController _qualificationController =
  TextEditingController();

  Future<void> _saveQualification() async {
    final qualification = _qualificationController.text.trim();

    if (qualification.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your qualification"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({
        "qualification": qualification, // ✅ only this
      });

      // ✅ Safe navigation
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorHomeScreen(userId: widget.userId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.chineseBlack,
      body: Stack(
        children: [
          const BackgroundBubbles(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 75),
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Tell us your qualifications",
                  style: GoogleFonts.nunito(
                    fontSize: 25,
                    color: ColorPalette.honeyDew,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _qualificationController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: ColorPalette.honeyDew,
                        width: 2,
                      ),
                    ),
                    hintText: "Enter your qualification",
                    hintStyle: TextStyle(color: ColorPalette.coolGrey),
                  ),
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    color: ColorPalette.honeyDew,
                  ),
                  cursorColor: ColorPalette.honeyDew,
                ),
              ),
              const Expanded(child: SizedBox()),
              Center(
                child: MaterialButton(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  color: ColorPalette.malachiteGreen,
                  onPressed: _saveQualification,
                  child: Text(
                    "Next",
                    style: GoogleFonts.nunito(
                      fontSize: 25,
                      color: ColorPalette.chineseBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 75),
            ],
          ),
        ],
      ),
    );
  }
}
