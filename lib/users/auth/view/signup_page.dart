import 'package:erx/general/consts/consts.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/widgets/coustom_textfield.dart';
import 'package:erx/users/auth/controller/signup_controller.dart';
import 'package:erx/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:erx/screens/user_type_screen.dart'; // ✅ Import UserTypeScreen

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(SignupController());
    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 35),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/logo/foreground.png',
                    width: context.screenHeight * .23,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Sign Up Now",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorPalette.honeyDew,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create your account",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorPalette.coolGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                flex: 2,
                child: Form(
                  key: controller.formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CustomTextField(
                          textController: controller.nameController,
                          hint: "Full Name",
                          icon: const Icon(
                            Icons.person,
                            color: ColorPalette.malachiteGreenLight,
                          ),
                          validator: controller.validateName,
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          textController: controller.emailController,
                          icon: const Icon(
                            Icons.email_outlined,
                            color: ColorPalette.malachiteGreenLight,
                          ),
                          hint: "Email",
                          validator: controller.validateEmail,
                        ),
                        const SizedBox(height: 18),
                        CustomTextField(
                          textController: controller.passwordController,
                          icon: const Icon(
                            Icons.key,
                            color: ColorPalette.malachiteGreenLight,
                          ),
                          hint: "Password",
                          validator: controller.validatePassword,
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: context.screenWidth * .7,
                          height: 44,
                          child: Obx(
                                () => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorPalette.malachiteGreen,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () async {
                                await controller.signupUser(context);

                                // ✅ Navigate to UserTypeScreen only if signup successful
                                if (controller.userCredential != null) {
                                  Get.to(() => UserTypeScreen(
                                    onComplete: () {
                                      // User type select karne ke baad home screen navigate
                                      Get.offAllNamed('/home');
                                    },
                                  ));
                                }
                              },
                              child: controller.isLoading.value
                                  ? const LoadingIndicator()
                                  : const Text(
                                "Sign Up",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: ColorPalette.coolGrey),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: ColorPalette.malachiteGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
      ),
    );
  }
}
