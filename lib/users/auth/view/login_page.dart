// Fixed LoginView
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/widgets/coustom_textfield.dart';
import 'package:erx/widgets/loading_indicator.dart';
import 'package:erx/users/auth/controller/login_controller.dart';
import 'package:erx/users/auth/reset_password/reset_password.dart';
import 'package:erx/screens/signup_screen.dart';
import 'package:erx/screens/doctor_home_screen.dart';
import 'package:erx/screens/pharmacist_home_screen.dart';
import 'package:erx/screens/patient_home_screen.dart';
import 'package:erx/screens/assistant_home_screen.dart';
import 'package:erx/users/auth/view/signup_page.dart';
import 'package:erx/general/consts/consts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack,
      body: Container(
        margin: const EdgeInsets.only(top: 35),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // ================= LOGO & TEXT =================
            Column(
              children: [
                Image.asset(
                  'assets/logo/foreground.png',
                  width: MediaQuery.of(context).size.height * .23,
                ),
                const SizedBox(height: 5),
                AppString.welcome.text
                    .size(AppFontSize.size18)
                    .bold
                    .color(ColorPalette.honeyDew)
                    .make(),
                const SizedBox(height: 8),
                AppString.weAreExcuited.text
                    .size(AppFontSize.size18)
                    .semiBold
                    .color(ColorPalette.coolGrey)
                    .make(),
              ],
            ),

            const SizedBox(height: 15),

            // ================= FORM =================
            Expanded(
              flex: 2,
              child: Form(
                key: controller.formkey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // -------- Email --------
                      CustomTextField(
                        validator: controller.validateEmail,
                        textController: controller.emailController,
                        icon: const Icon(
                          Icons.email_outlined,
                          color: ColorPalette.malachiteGreenLight,
                        ),
                        hint: AppString.emailHint,
                      ),

                      const SizedBox(height: 18),

                      // -------- Password --------
                      CustomTextField(
                        validator: controller.validatePass,
                        textController: controller.passwordController,
                        icon: const Icon(
                          Icons.key,
                          color: ColorPalette.malachiteGreenLight,
                        ),
                        hint: AppString.passwordHint,
                      ),

                      const SizedBox(height: 20),

                      // -------- Forget Password --------
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () {
                            Get.to(() => const PasswordResetPage());
                          },
                          child: const Text(
                            "Forget Password?",
                            style: TextStyle(
                              color: ColorPalette.malachiteGreen,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= LOGIN BUTTON =================
                      SizedBox(
                        width: MediaQuery.of(context).size.width * .7,
                        height: 44,
                        child: Obx(
                              () => ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorPalette.malachiteGreen,
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () async {
                              if (!controller.formkey.currentState!.validate())
                                return;

                              controller.isLoading(true);

                              try {
                                // Firebase Auth login
                                UserCredential userCredential =
                                await FirebaseAuth.instance
                                    .signInWithEmailAndPassword(
                                  email: controller.emailController.text.trim(),
                                  password:
                                  controller.passwordController.text.trim(),
                                );

                                String uid = userCredential.user!.uid;

                                // Firestore se user record uthao
                                DocumentSnapshot userDoc =
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .get();

                                if (!userDoc.exists) {
                                  Get.snackbar(
                                    'Error',
                                    'User record not found',
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  controller.isLoading(false);
                                  return;
                                }

                                // userType check karo
                                String userType =
                                    (userDoc.get('userType') as String?) ?? '';

                                // respective home screen open
                                switch (userType) {
                                  case 'doctor':
                                    Get.offAll(() =>
                                        DoctorHomeScreen(userId: uid));
                                    break;
                                  case 'pharmacist':
                                    Get.offAll(() =>
                                        PharmacistHomeScreen(userId: uid));
                                    break;
                                  case 'patient':
                                    Get.offAll(
                                            () => PatientHomeScreen(userId: uid));
                                    break;
                                  case 'assistant':
                                    Get.offAll(
                                            () => AssistantHomeScreen(userId: uid));
                                    break;
                                  default:
                                    Get.snackbar(
                                      'Error',
                                      'User type not assigned',
                                      snackPosition: SnackPosition.TOP,
                                    );
                                }
                              } on FirebaseAuthException catch (e) {
                                Get.snackbar(
                                  'Error',
                                  e.message ?? 'Login failed',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Something went wrong',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } finally {
                                controller.isLoading(false);
                              }
                            },
                            child: controller.isLoading.value
                                ? const LoadingIndicator()
                                : AppString.login.text.white.make(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ================= SIGN UP =================
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppString.dontHaveAccount.text
                              .color(ColorPalette.coolGrey)
                              .make(),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              Get.to(() => SignupView());
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: ColorPalette.malachiteGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
