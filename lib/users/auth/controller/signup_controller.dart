import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  // Controllers
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  // Loading state
  var isLoading = false.obs;

  // Form key
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  // Firebase UserCredential
  UserCredential? userCredential;

  /// ✅ Signup function
  Future<void> signupUser(BuildContext context) async {
    if (!formkey.currentState!.validate()) return;

    try {
      isLoading(true);

      // Create new user in FirebaseAuth
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential != null) {
        // Firestore me users collection + document automatically create
        var store = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential!.user!.uid);

        await store.set({
          'uid': userCredential!.user!.uid,
          'fullname': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text.trim(),
          'userType': '', // Will update later on UserTypeSelection page
        }).then((_) {
          isLoading(false);
          // ✅ Navigate to UserTypeScreen only if signup & Firestore save successful
          Get.toNamed('/userTypeSelection', arguments: {
            'name': nameController.text.trim(),
          });
        }).catchError((error) {
          isLoading(false);
          // ❌ No navigation on Firestore error
          Get.snackbar(
            'Error',
            'Failed to save user data: $error',
            snackPosition: SnackPosition.BOTTOM,
          );
          log("Firestore error: $error");
        });
      }
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      String message = e.message ?? 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered';
      } else if (e.code == 'weak-password') {
        message = 'Password is too weak';
      }
      // ❌ No navigation if signup fails
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
      log("FirebaseAuthException: $e");
    } catch (e) {
      isLoading(false);
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      log("Signup error: $e");
    }
  }

  /// ✅ Signout function
  Future<void> signout() async {
    await FirebaseAuth.instance.signOut();
  }

  // -------------------------------
  // ✅ Validators
  // -------------------------------
  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    if (value.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailRegExp =
    RegExp(r'^[\w\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) return 'Please enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    final pattern =
    RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if (!pattern.hasMatch(value)) {
      return 'Password must be at least 8 chars,\ninclude 1 capital, 1 number & 1 special character';
    }
    return null;
  }
}
