import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/users/auth/view/login_page.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/widgets/glass_button.dart';
import 'package:erx/widgets/profile_action_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PatientProfileScreen extends StatefulWidget {
  final String userId;
  final VoidCallback onSignoutAction;

  const PatientProfileScreen({
    Key? key,
    required this.userId,
    required this.onSignoutAction,
  }) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // ---------- PICK IMAGE ----------
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      final fileName = 'profile_${widget.userId}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      await ref.putFile(_profileImage!);
      final downloadURL = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update({'profileImage': downloadURL});
    }
  }

  // ---------- SIGN OUT ----------
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logout successful")),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userStream = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .snapshots();

    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: -63,
              bottom: 35,
              child: SvgPicture.string('<your_leftBlob_svg_here>'),
            ),
            Positioned(
              right: -34,
              top: 100,
              child: SvgPicture.string('<your_rightBlob_svg_here>'),
            ),

            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: ColorPalette.charlestonGreen.withOpacity(0.3),
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 15, 18, 24).withOpacity(0.7),
            ),

            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userStream,
              builder: (context, snapshot) {
                String fullName = 'My Name';
                String email = 'email@example.com';
                String? profileUrl;

                if (snapshot.hasData && snapshot.data!.data() != null) {
                  final data = snapshot.data!.data()!;
                  fullName = data['fullname']?.toString() ?? fullName;
                  email = data['email']?.toString() ?? email;
                  profileUrl = data['profileImage']?.toString();
                }

                // -------- IMAGE PROVIDER FIX --------
                ImageProvider<Object>? imageProvider;
                if (_profileImage != null) {
                  imageProvider = FileImage(_profileImage!);
                } else if (profileUrl != null) {
                  imageProvider = NetworkImage(profileUrl);
                }

                return Column(
                  children: [
                    const SizedBox(height: 25),
                    Text(
                      "Profile",
                      style: GoogleFonts.nunito(
                        color: ColorPalette.honeyDew,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor:
                          ColorPalette.malachiteGreen.withOpacity(0.9),
                          backgroundImage: imageProvider,
                          child: imageProvider == null
                              ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 22,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Text(
                      fullName,
                      style: GoogleFonts.nunito(
                        color: ColorPalette.honeyDew,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      email,
                      style: GoogleFonts.nunito(
                        color: ColorPalette.coolGrey,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 30),

                    ProfileActionButton(
                      icon: Icons.lock_outline_rounded,
                      label: "Privacy & Settings",
                      onTap: () {},
                    ),
                    ProfileActionButton(
                      icon: Icons.notifications_none_rounded,
                      label: "Notifications",
                      onTap: () {},
                    ),
                    ProfileActionButton(
                      icon: Icons.access_time,
                      label: "Medical History",
                      onTap: () {},
                    ),
                    ProfileActionButton(
                      icon: Icons.accessibility_new_rounded,
                      label: "Accessibility Options",
                      onTap: () {},
                    ),
                  ],
                );
              },
            ),

            Positioned(
              left: 34,
              bottom: 72,
              child: GlassButton(
                icon: Icons.exit_to_app_rounded,
                text: "Sign Out",
                onTap: _signOut,
              ),
            ),

            Positioned(
              left: 15,
              top: 15,
              child: IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: ColorPalette.honeyDew,
                  size: 30,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
