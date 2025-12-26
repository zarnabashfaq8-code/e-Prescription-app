import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/screens/patient_home_screen.dart';
import 'package:erx/screens/doctor_home_screen.dart';
import 'package:erx/screens/assistant_home_screen.dart';
import 'package:erx/screens/pharmacist_home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  UserCredential? userCredential;
  var isLoading = false.obs;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // ================= LOGIN FUNCTION =================
  loginUser(BuildContext context) async {
    if (!formkey.currentState!.validate()) return;

    try {
      isLoading(true);

      // 🔐 Firebase Authentication
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential == null) {
        isLoading(false);
        return;
      }

      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // 🔥 Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) {
        isLoading(false);
        Get.snackbar(
          "Login failed",
          "User data not found",
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // ✅ FIXED dynamic → String issue
      String role = userDoc.get('userType')?.toString() ?? '';

      // 🚀 Decide home screen
      Widget nextScreen;

      switch (role) {
        case 'patient':
          nextScreen = PatientHomeScreen(userId: currentUserId);
          break;

        case 'assistant':
          nextScreen = AssistantHomeScreen(userId: currentUserId);
          break;

        case 'doctor':
          nextScreen = DoctorHomeScreen(userId: currentUserId);
          break;

        case 'pharmacist':
          nextScreen = PharmacistHomeScreen(userId: currentUserId);
          break;

        default:
          isLoading(false);
          Get.snackbar(
            "Login failed",
            "Invalid user role",
            snackPosition: SnackPosition.TOP,
          );
          return;
      }

      isLoading(false);
      Get.snackbar(
        "Success",
        "Login Successful",
        snackPosition: SnackPosition.TOP,
      );

      // ✅ Direct Home Navigation
      Get.offAll(nextScreen);

    } on FirebaseAuthException catch (e) {
      isLoading(false);

      String message = "Wrong email or password";
      if (e.code == 'user-not-found') {
        message = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        message = "Wrong password";
      }

      Get.snackbar(
        "Login failed",
        message,
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar(
        "Login failed",
        "Something went wrong",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ================= VALIDATIONS =================
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email';
    }
    RegExp emailRefExp =
    RegExp(r'^[\w\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRefExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePass(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must contain at least 8 characters';
    }
    return null;
  }
}
