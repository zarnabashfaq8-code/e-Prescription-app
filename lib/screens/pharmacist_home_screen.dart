import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/screens/patient_profile_screen.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/utils/add_medicines.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PharmacistHomeScreen extends StatefulWidget {
  final String userId;
  const PharmacistHomeScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  State<PharmacistHomeScreen> createState() => _PharmacistHomeScreenState();
}

class _PharmacistHomeScreenState extends State<PharmacistHomeScreen> {
  final _searchController = TextEditingController();
  bool _medicinesAdded = false;

  @override
  void initState() {
    super.initState();
    addMedicinesOnce();
  }

  Future<void> addMedicinesOnce() async {
    final snapshot =
    await FirebaseFirestore.instance.collection('medicines').get();
    if (snapshot.docs.isEmpty) {
      await addMedicinesToFirestore(); // medicines add
    }
    setState(() {
      _medicinesAdded = true; // data ready
    });
  }

  @override
  Widget build(BuildContext context) {
    final _nameStream = FirebaseFirestore.instance
        .collection("pharmacist")
        .doc(widget.userId)
        .snapshots();

    final _medicinesStream =
    FirebaseFirestore.instance.collection("medicines").snapshots();

    if (!_medicinesAdded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.charlestonGreen,
      body: Stack(
        children: [
          SvgPicture.string(
            SvgStrings.homeScreenBackground,
            width: MediaQuery.of(context).size.width,
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: SvgPicture.string(SvgStrings.hamburger),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: 8 * 22 / 7 / 180,
                            child: SvgPicture.string(
                              SvgStrings.logoE,
                              height: 18,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Prescription",
                            style: GoogleFonts.nunito(
                              color: ColorPalette.honeyDew,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PatientProfileScreen(
                                userId: widget.userId,
                                onSignoutAction: () async {
                                  final prefs =
                                  await SharedPreferences.getInstance();
                                  await prefs.remove("userType");
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          height: 35,
                          width: 35,
                          child: SvgPicture.string(SvgStrings.profile),
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _nameStream,
                  builder: (context, snapshot) {
                    String pharmacyName = '';
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      pharmacyName =
                          snapshot.data!.data()!['pharmacyName']?.toString() ?? '';
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 30, left: 25),
                      child: Text(
                        "Hello $pharmacyName!",
                        style: GoogleFonts.nunito(
                          color: ColorPalette.honeyDew,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 25),
                  child: Text(
                    "Here is the list of available medicines",
                    style: GoogleFonts.nunito(
                      color: ColorPalette.honeyDew,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(34),
                      topRight: Radius.circular(34),
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(34),
                          topRight: Radius.circular(34),
                        ),
                        color: ColorPalette.chineseBlack,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Medicines List",
                              style: GoogleFonts.nunito(
                                color: ColorPalette.malachiteGreen,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                              height: 60,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: ColorPalette.charlestonGreen,
                                boxShadow: [
                                  BoxShadow(
                                    color: ColorPalette.coolGrey.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.string(SvgStrings.search),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search medicines",
                                        hintStyle: GoogleFonts.nunito(
                                          fontSize: 16,
                                          color: ColorPalette.coolGrey,
                                        ),
                                      ),
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        color: ColorPalette.honeyDew,
                                      ),
                                      cursorColor: ColorPalette.honeyDew,
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Scrollable Medicines List
                          Expanded(
                            child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: _medicinesStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return const Center(
                                    child: Text(
                                      "No medicines found",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }

                                final medicines =
                                snapshot.data!.docs.where((doc) {
                                  final name =
                                      doc.data()['name']?.toString() ?? '';
                                  return name
                                      .toLowerCase()
                                      .contains(
                                      _searchController.text.toLowerCase());
                                }).toList();

                                return ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  itemCount: medicines.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final data = medicines[index].data();
                                    final name =
                                        data['name']?.toString() ?? '';
                                    final purpose =
                                        data['purpose']?.toString() ?? '';
                                    return Card(
                                      color: ColorPalette.charlestonGreen,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              name,
                                              style: GoogleFonts.nunito(
                                                  color:
                                                  ColorPalette.honeyDew,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              purpose,
                                              style: GoogleFonts.nunito(
                                                  color: ColorPalette.coolGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
