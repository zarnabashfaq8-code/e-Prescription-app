import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/screens/assistant_home_screen.dart';
import 'package:erx/screens/doctor_qualifications_screen.dart';
import 'package:erx/screens/pharmacy_details_screen.dart';
import 'package:erx/screens/patient_home_screen.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/widgets/background_bubbles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final TextEditingController _pharmacyNameController = TextEditingController();
  final TextEditingController _pharmacyAddressController = TextEditingController();
  final TextEditingController _pharmacyPincodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signupUser(String userType) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create user with email & password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Save user data in Firestore
      if (userType == "patient" || userType == "assistant") {
        await FirebaseFirestore.instance.collection(userType).doc(uid).set({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "uid": uid,
          "userType": userType,
        });

        // Navigate to respective home screen
        Widget nextScreen = userType == "patient"
            ? PatientHomeScreen(userId: uid)
            : AssistantHomeScreen(userId: uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      } else if (userType == "doctor") {
        await FirebaseFirestore.instance.collection("doctor").doc(uid).set({
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "qualification": _qualificationController.text.trim(),
          "uid": uid,
          "userType": userType,
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DoctorQualificationScreen(
              userId: uid,
              name: _nameController.text.trim(),
            ),
          ),
        );
      } else if (userType == "pharmacist") {
        await FirebaseFirestore.instance.collection("pharmacist").doc(uid).set({
          "pharmacyName": _pharmacyNameController.text.trim(),
          "address": _pharmacyAddressController.text.trim(),
          "pincode": _pharmacyPincodeController.text.trim(),
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
          "uid": uid,
          "userType": userType,
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PharmacyDetailsScreen(
              userId: uid,
              name: _pharmacyNameController.text.trim(),
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'weak-password') {
        message = "Password must be at least 8 characters.";
      } else {
        message = "Something went wrong. Try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final prefs = snapshot.data!;
        final String? userType = prefs.getString('userType');

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
                      "Create your account",
                      style: GoogleFonts.nunito(
                        fontSize: 25,
                        color: ColorPalette.honeyDew,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Patient / Assistant
                          if (userType == "patient" || userType == "assistant")
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                            ),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: ColorPalette.honeyDew),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorPalette.honeyDew,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: const TextStyle(color: ColorPalette.honeyDew),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your email";
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // Password Field for all
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: ColorPalette.honeyDew),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorPalette.honeyDew,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: const TextStyle(color: ColorPalette.honeyDew),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter a password";
                              }
                              if (value.trim().length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              return null;
                            },
                          ),

                          // Pharmacy fields for Pharmacist
                          if (userType == "pharmacist") ...[
                            TextFormField(
                              controller: _pharmacyNameController,
                              decoration: const InputDecoration(
                                labelText: "Pharmacy Name",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter pharmacy name";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _pharmacyAddressController,
                              decoration: const InputDecoration(
                                labelText: "Address",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter address";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _pharmacyPincodeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Pincode",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter pincode";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your email";
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            // Password Field for all
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter a password";
                                }
                                if (value.trim().length < 8) {
                                  return "Password must be at least 8 characters";
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 15),


                          // Qualification field for Doctor
                          if (userType == "doctor")
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: "Full Name",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your name";
                                }
                                return null;
                              },
                            ),
                          // Email Field for all
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: "Email",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your email";
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 15),

                          // Password Field for all
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              labelStyle: TextStyle(color: ColorPalette.honeyDew),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: ColorPalette.honeyDew,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: const TextStyle(color: ColorPalette.honeyDew),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter a password";
                              }
                              if (value.trim().length < 8) {
                                return "Password must be at least 8 characters";
                              }
                              return null;
                            },
                          ),

                          TextFormField(
                              controller: _qualificationController,
                              decoration: const InputDecoration(
                                labelText: "Qualification",
                                labelStyle: TextStyle(color: ColorPalette.honeyDew),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ColorPalette.honeyDew,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(color: ColorPalette.honeyDew),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter qualification";
                                }
                                return null;
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.malachiteGreen,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () async {
                        setState(() => _isLoading = true);
                        if (userType != null) {
                          await _signupUser(userType);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User type not selected")),
                          );
                        }
                        setState(() => _isLoading = false);
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                          color: ColorPalette.chineseBlack)
                          : Text(
                        "Next",
                        style: GoogleFonts.nunito(
                          fontSize: 22,
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
      },
    );
  }
}
