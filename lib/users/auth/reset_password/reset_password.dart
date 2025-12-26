// ignore_for_file: avoid_print

import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
export 'package:velocity_x/velocity_x.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  get VxToast => null;

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      VxToast.show(context, msg: "Password reset email sent to your email");
      Get.back();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> updatePasswordInFirestore(User user, String newPassword) async {
    try {
      String userId = user.uid;
      CollectionReference users =
      FirebaseFirestore.instance.collection('users');
      await users.doc(userId).update({'password': newPassword});
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> handlePasswordReset() async {
    String email = emailController.text;
    String newPassword = newPasswordController.text;

    try {
      await resetPassword(email);

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await updatePasswordInFirestore(user, newPassword);
      }
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack, // dark background
      appBar: AppBar(
        backgroundColor: ColorPalette.chineseBlack,
        title: const Text(
          'Password Reset',
          style: TextStyle(color: ColorPalette.honeyDew),
        ),
        iconTheme: const IconThemeData(color: ColorPalette.honeyDew),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              style: const TextStyle(color: ColorPalette.honeyDew),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_rounded, color: ColorPalette.honeyDew),
                labelText: 'Enter your Email',
                labelStyle: const TextStyle(color: ColorPalette.honeyDew),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorPalette.honeyDew),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorPalette.malachiteGreen),
                ),
              ),
              cursorColor: ColorPalette.malachiteGreen,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: newPasswordController,
              style: const TextStyle(color: ColorPalette.honeyDew),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.key, color: ColorPalette.honeyDew),
                labelText: 'Enter New Password',
                labelStyle: const TextStyle(color: ColorPalette.honeyDew),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorPalette.honeyDew),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: ColorPalette.malachiteGreen),
                ),
              ),
              cursorColor: ColorPalette.malachiteGreen,
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.malachiteGreen,
                  shape: const StadiumBorder(),
                ),
                onPressed: () => handlePasswordReset(),
                child: const Text(
                  'Reset Password',
                  style: TextStyle(color: ColorPalette.chineseBlack, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
