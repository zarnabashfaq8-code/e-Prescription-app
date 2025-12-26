import 'package:flutter/material.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/widgets/background_bubbles.dart';
import 'package:erx/widgets/user_type_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import respective screens
import 'package:erx/screens/patient_home_screen.dart';
import 'package:erx/screens/assistant_home_screen.dart';
import 'package:erx/screens/doctor_qualifications_screen.dart';
import 'package:erx/screens/pharmacy_details_screen.dart';

class UserTypeScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const UserTypeScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  int _userType = 0;
  final List<String> _userTypes = [
    'patient',
    'pharmacist',
    'doctor',
    'assistant',
  ];

  void _navigateNext() async {
    final String selectedType = _userTypes[_userType];

    // 1️⃣ Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userType", selectedType);

    // 2️⃣ Get current user and name from Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    String userName = '';
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        userName = (data['name'] ?? '') as String; // ✅ Cast to String
      }

      // Update userType in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'userType': selectedType});
    }

    // 3️⃣ Navigate to respective screen
    switch (selectedType) {
      case 'patient':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PatientHomeScreen(userId: currentUser!.uid),
          ),
        );
        break;
      case 'assistant':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AssistantHomeScreen(userId: currentUser!.uid),
          ),
        );
        break;
      case 'doctor':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorQualificationScreen(
              userId: currentUser!.uid,
              name: userName,
            ),
          ),
        );
        break;
      case 'pharmacist':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PharmacyDetailsScreen(
              userId: currentUser!.uid,
              name: userName,
            ),
          ),
        );
        break;
    }

    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const BackgroundBubbles(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      "You are a",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ColorPalette.honeyDew,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _userType = 0),
                          child: UserTypeTile(
                            svgString: SvgStrings.patient,
                            userType: "Patient",
                            isSelected: _userType == 0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _userType = 1),
                          child: UserTypeTile(
                            svgString: SvgStrings.pharmacist,
                            userType: "Pharmacist",
                            isSelected: _userType == 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _userType = 2),
                          child: UserTypeTile(
                            svgString: SvgStrings.doctor,
                            userType: "Doctor",
                            isSelected: _userType == 2,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _userType = 3),
                          child: UserTypeTile(
                            svgString: SvgStrings.assistant,
                            userType: "Assistant",
                            isSelected: _userType == 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    MaterialButton(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      color: ColorPalette.malachiteGreen,
                      onPressed: _navigateNext,
                      child: const Text(
                        "Next",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
