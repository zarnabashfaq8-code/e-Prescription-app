import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/widgets/background_bubbles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pharmacist_home_screen.dart'; // ✅ Import the home screen

class PharmacyDetailsScreen extends StatelessWidget {
  final String name;
  final String userId;

  PharmacyDetailsScreen({Key? key, required this.name, required this.userId}) : super(key: key);

  final TextEditingController _pharmacyNameController = TextEditingController();
  final TextEditingController _pharmacyAddressController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();

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
                  "Pharmacy Name",
                  style: GoogleFonts.nunito(fontSize: 25, color: ColorPalette.honeyDew),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorPalette.coolGrey, width: 2),
                  ),
                  height: 60,
                  child: TextField(
                    controller: _pharmacyNameController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: GoogleFonts.nunito(fontSize: 20, color: ColorPalette.honeyDew),
                    cursorColor: ColorPalette.honeyDew,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Address",
                  style: GoogleFonts.nunito(fontSize: 25, color: ColorPalette.honeyDew),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorPalette.coolGrey, width: 2),
                  ),
                  height: 100,
                  child: TextField(
                    controller: _pharmacyAddressController,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: GoogleFonts.nunito(fontSize: 20, color: ColorPalette.honeyDew),
                    cursorColor: ColorPalette.honeyDew,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  "Pincode",
                  style: GoogleFonts.nunito(fontSize: 25, color: ColorPalette.honeyDew),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorPalette.coolGrey, width: 2),
                  ),
                  height: 60,
                  child: TextField(
                    controller: _pinCodeController,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: GoogleFonts.nunito(fontSize: 20, color: ColorPalette.honeyDew),
                    cursorColor: ColorPalette.honeyDew,
                  ),
                ),
              ),

              const Expanded(child: SizedBox()),

              Center(
                child: MaterialButton(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  color: ColorPalette.malachiteGreen,
                  onPressed: () async {
                    if (_pharmacyNameController.text.isEmpty ||
                        _pharmacyAddressController.text.isEmpty ||
                        _pinCodeController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all fields")),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance
                          .collection("pharmacist")
                          .doc(userId)
                          .set({
                        "name": name,
                        "uid": userId,
                        "pharmacyName": _pharmacyNameController.text,
                        "address": _pharmacyAddressController.text,
                        "pincode": _pinCodeController.text,
                        "createdAt": FieldValue.serverTimestamp(),
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pharmacy details saved successfully")),
                      );

                      // ✅ Navigate to PharmacistHomeScreen and remove this screen from stack
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PharmacistHomeScreen(userId: userId),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error saving data: $e")),
                      );
                    }
                  },
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
