import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/screens/patient_profile_screen.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssistantHomeScreen extends StatefulWidget {
  final String userId;
  AssistantHomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AssistantHomeScreen> createState() => _AssistantHomeScreenState();
}

class _AssistantHomeScreenState extends State<AssistantHomeScreen> {
  final _searchController = TextEditingController();
  String _searchText = '';
  String _assistantFirstName = '';

  @override
  void initState() {
    super.initState();
    fetchAssistantName();
  }

  // ✅ Fetch assistant name from Firestore like doctor screen
  Future<void> fetchAssistantName() async {
    final doc = await FirebaseFirestore.instance
        .collection('users') // ya 'assistant', jahan name store hai
        .doc(widget.userId)
        .get();

    if (doc.exists && doc.data() != null) {
      final fullName = doc.data()!['fullname']?.toString() ?? '';
      if (fullName.isNotEmpty) {
        setState(() {
          _assistantFirstName = fullName.split(' ').first;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final _patientsStream = FirebaseFirestore.instance
        .collection("users")
        .where('userType', isEqualTo: 'patient')
        .snapshots();

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
                const SizedBox(height: 30),

                // ✅ Show assistant name like doctor screen
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    "Hello $_assistantFirstName!",
                    style: GoogleFonts.nunito(
                      color: ColorPalette.honeyDew,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Search Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            onChanged: (value) {
                              setState(() {
                                _searchText = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search patients",
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Patient List Heading
                Center(
                  child: Text(
                    "Patient List",
                    style: GoogleFonts.nunito(
                      color: ColorPalette.malachiteGreen,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                /// LIST
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _patientsStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final patients = snapshot.data!.docs.where((doc) {
                        final name = doc
                            .data()['fullname']
                            ?.toString()
                            .toLowerCase() ??
                            '';
                        return name.contains(_searchText);
                      }).toList();

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: patients.length,
                        itemBuilder: (context, index) {
                          final patientDoc = patients[index];
                          final patientId = patientDoc.id;

                          final String name =
                              patientDoc.data()['fullname']?.toString() ?? '';
                          final String email =
                              patientDoc.data()['email']?.toString() ?? '';

                          return StreamBuilder<
                              QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('prescriptionRequests')
                                .where('patientID', isEqualTo: patientId)
                                .limit(1)
                                .snapshots(),
                            builder: (context, reqSnap) {
                              String symptoms = '-';
                              String status = 'pending';
                              String? requestId;

                              if (reqSnap.hasData &&
                                  reqSnap.data!.docs.isNotEmpty) {
                                final req = reqSnap.data!.docs.first;
                                symptoms =
                                    req.data()['symptoms']?.toString() ?? '-';
                                status =
                                    req.data()['status']?.toString() ??
                                        'pending';
                                requestId = req.id;
                              }

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: ColorPalette.malachiteGreen,
                                    width: 2,
                                  ),
                                ),
                                color: ColorPalette.charlestonGreen,
                                margin:
                                const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// LEFT
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(name,
                                              style: GoogleFonts.nunito(
                                                  color: ColorPalette.honeyDew,
                                                  fontWeight:
                                                  FontWeight.bold)),
                                          Text(email,
                                              style: GoogleFonts.nunito(
                                                  color:
                                                  ColorPalette.coolGrey)),
                                        ],
                                      ),

                                      /// RIGHT
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        children: [
                                          Text("Symptoms",
                                              style: GoogleFonts.nunito(
                                                  color: ColorPalette
                                                      .malachiteGreen,
                                                  fontSize: 12,
                                                  fontWeight:
                                                  FontWeight.bold)),
                                          Text(symptoms,
                                              style: GoogleFonts.nunito(
                                                  color:
                                                  ColorPalette.coolGrey,
                                                  fontSize: 12)),
                                          Text("Status: $status",
                                              style: GoogleFonts.nunito(
                                                  color: status == 'completed'
                                                      ? Colors.green
                                                      : Colors.orange,
                                                  fontSize: 12)),
                                          if (status != 'completed' &&
                                              requestId != null)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green),
                                              onPressed: () async {
                                                await FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                    'prescriptionRequests')
                                                    .doc(requestId)
                                                    .update({
                                                  'status': 'completed',
                                                });
                                              },
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
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
