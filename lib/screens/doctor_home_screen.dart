import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/screens/new_prescription_screen.dart';
import 'package:erx/screens/patient_profile_screen.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/widgets/prescription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorHomeScreen extends StatefulWidget {
  final String userId;

  const DoctorHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    final nameStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();

    final prescriptionStream = FirebaseFirestore.instance
        .collection('prescription')
        .where('doctorID', isEqualTo: widget.userId)
        .snapshots();

    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
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

                /// 🔹 TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 25,
                        width: 25,
                        child: SvgPicture.string(SvgStrings.hamburger),
                      ),
                      Row(
                        children: [
                          Transform.rotate(
                            angle: 8 * 22 / 7 / 180,
                            child: SvgPicture.string(
                              SvgStrings.logoE,
                              height: 18,
                            ),
                          ),
                          Text(
                            "prescription",
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

                /// 🔹 DOCTOR NAME
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: nameStream,
                  builder: (context, snapshot) {
                    String firstName = '';

                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      final fullName =
                          snapshot.data!.data()!['fullname']?.toString() ?? '';
                      if (fullName.isNotEmpty) {
                        firstName = fullName.split(' ').first;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 30, left: 25),
                      child: Text(
                        "Hello Dr. $firstName!",
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
                    "Hope you have a great day!",
                    style: GoogleFonts.nunito(
                      color: ColorPalette.honeyDew,
                      fontSize: 16,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔹 BODY
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(34),
                            topRight: Radius.circular(34),
                          ),
                          child: Container(
                            color: ColorPalette.chineseBlack,
                            child: StreamBuilder<
                                QuerySnapshot<Map<String, dynamic>>>(
                              stream: prescriptionStream,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: ColorPalette.malachiteGreen,
                                    ),
                                  );
                                }

                                final filteredDocs =
                                snapshot.data!.docs.where((doc) {
                                  final patientMap =
                                  doc.data()['patient']
                                  as Map<String, dynamic>?;

                                  final String patientName =
                                      patientMap?['name']?.toString() ?? '';

                                  return patientName
                                      .toLowerCase()
                                      .contains(_searchText.toLowerCase());
                                }).toList();

                                return ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 60,
                                    bottom: 140, // ✅ SCROLL FIX
                                  ),
                                  physics:
                                  const AlwaysScrollableScrollPhysics(),
                                  itemCount: filteredDocs.length,
                                  itemBuilder: (context, index) {
                                    final data =
                                    filteredDocs[index].data();

                                    return PrescriptionCard(
                                      prescriptionId:
                                      filteredDocs[index].id,
                                      hospitalName:
                                      data['hospital']?.toString() ?? '',
                                      prescriptionDate: dateFormat.format(
                                        (data['dateTime'] as Timestamp)
                                            .toDate(),
                                      ),
                                      followUpDate:
                                      data['followUp']?.toString(),
                                      patientName:
                                      (data['patient']
                                      as Map<String, dynamic>?)?[
                                      'name']?.toString() ??
                                          '',
                                      doctorName:
                                      data['doctorName']?.toString(),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      /// 🔹 SEARCH BAR
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: ColorPalette.charlestonGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              SvgPicture.string(SvgStrings.search),
                              const SizedBox(width: 15),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchText = val;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText:
                                    "Search your prescription",
                                    hintStyle: GoogleFonts.nunito(
                                      color: ColorPalette.coolGrey,
                                    ),
                                  ),
                                  style: GoogleFonts.nunito(
                                    color: ColorPalette.honeyDew,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /// 🔹 BOTTOM BAR
                      Positioned(
                        bottom: 0,
                        child: Container(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            color: ColorPalette.charlestonGreen,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                        ),
                      ),

                      /// 🔹 FAB
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 35),
                          child: FloatingActionButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const NewPrescriptionScreen(),
                                ),
                              );
                            },
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ],
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
