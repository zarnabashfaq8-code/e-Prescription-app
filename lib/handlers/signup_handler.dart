import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/screens/assistant_home_screen.dart';
import 'package:erx/screens/doctor_home_screen.dart';
import 'package:erx/screens/error_screen.dart';
import 'package:erx/screens/patient_home_screen.dart';
import 'package:erx/screens/pharmacist_home_screen.dart';
import 'package:erx/screens/signup_screen.dart';
import 'package:erx/widgets/customer_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpHandler extends StatelessWidget {
  const SignUpHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String _userType = Provider.of<SharedPreferences>(
      context,
      listen: false,
    ).getString("userType")!;
    final String _phoneNo = FirebaseAuth.instance.currentUser!.phoneNumber!;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(_userType)
          .doc(_phoneNo)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final userData = snapshot.data!.data();

          if (userData == null) {
            // Not yet signed-up
            return const SignupScreen();
          } else {
            // Signed up
            // Fix dynamic -> String
            String userId = (userData['uid'] ?? _phoneNo).toString();

            switch (_userType) {
              case "patient":
                return PatientHomeScreen(userId: userId);
              case "doctor":
                return DoctorHomeScreen(userId: userId);
              case "assistant":
                return AssistantHomeScreen(userId: userId);
              case "pharmacist":
                return PharmacistHomeScreen(userId: userId);
              default:
                return const ErrorScreen();
            }
          }
        } else {
          // Loading
          return const CustomLoader();
        }
      },
    );
  }
}
