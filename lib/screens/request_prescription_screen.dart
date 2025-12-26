import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/widgets/glass_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PatientPrescriptionScreen extends StatelessWidget {
  const PatientPrescriptionScreen({Key? key, required this.prescriptionId})
      : super(key: key);

  final String prescriptionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("prescriptionRequests")
              .doc(prescriptionId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final patient = data['patient'] as Map<String, dynamic>? ?? {};
            final generalInfo =
                patient['generalInfo'] as Map<String, dynamic>? ?? {};

            final dateTime =
                (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
            final formattedDate =
            DateFormat("dd MMM yyyy, HH:mm").format(dateTime);

            DateTime followUpDateTime;
            if (data['followUp'] != null) {
              if (data['followUp'] is Timestamp) {
                followUpDateTime = (data['followUp'] as Timestamp).toDate();
              } else if (data['followUp'] is String) {
                followUpDateTime =
                    DateTime.tryParse(data['followUp'] as String) ?? DateTime.now();
              } else {
                followUpDateTime = DateTime.now();
              }
            } else {
              followUpDateTime = DateTime.now();
            }
            final formattedFollowUp =
            DateFormat("dd MMM yyyy, HH:mm").format(followUpDateTime);

            return Stack(
              children: [
                Positioned(
                  left: -63,
                  bottom: 35,
                  child: SvgPicture.string(SvgStrings.leftBlob),
                ),
                Positioned(
                  right: -34,
                  top: 100,
                  child: SvgPicture.string(SvgStrings.rightBlob),
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
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: 8 * 22 / 7 / 180,
                              child: SvgPicture.string(
                                SvgStrings.logoE,
                                height: 20,
                              ),
                            ),
                            Text(
                              "prescription",
                              style: GoogleFonts.nunito(
                                color: ColorPalette.honeyDew,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Text(
                          data['hospital']?.toString() ?? '',
                          style: GoogleFonts.nunito(
                            color: ColorPalette.malachiteGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Dr. ${data['doctorName']?.toString() ?? ''}",
                          style: GoogleFonts.nunito(
                            color: ColorPalette.honeyDew,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          children: [
                            Text(
                              "Id: ",
                              style: GoogleFonts.nunito(
                                color: ColorPalette.malachiteGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data['patientID']?.toString() ?? '',
                              style: GoogleFonts.nunito(
                                color: ColorPalette.honeyDew,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            const Icon(
                              Icons.calendar_today,
                              color: ColorPalette.honeyDew,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedDate,
                              style: GoogleFonts.nunito(
                                color: ColorPalette.honeyDew,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "Follow-Up: ",
                              style: GoogleFonts.nunito(
                                color: ColorPalette.malachiteGreen,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formattedFollowUp,
                              style: GoogleFonts.nunito(
                                color: ColorPalette.honeyDew,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "Patient's Details",
                          style: GoogleFonts.nunito(
                            color: ColorPalette.malachiteGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text(
                              "Name: ${patient['name']?.toString() ?? ''}",
                              style: GoogleFonts.nunito(
                                color: ColorPalette.honeyDew,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                            Text(
                              "Age: ${patient['age']?.toString() ?? '-'} years",
                              style: GoogleFonts.nunito(
                                color: ColorPalette.honeyDew,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Wrap(
                            runSpacing: 20,
                            spacing: 30,
                            children: [
                              GlassBox(
                                text: generalInfo['temperature']?.toString() ?? "-",
                                svgString: SvgStrings.temperature,
                              ),
                              GlassBox(
                                text: generalInfo['weight']?.toString() ?? "-",
                                svgString: SvgStrings.weight,
                              ),
                              GlassBox(
                                text: generalInfo['bp']?.toString() ?? "-",
                                svgString: SvgStrings.waterDrop,
                              ),
                              GlassBox(
                                text: "-",
                                svgString: SvgStrings.height,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          "Medical History",
                          style: GoogleFonts.nunito(
                            color: ColorPalette.malachiteGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['medicalHistory']?.toString() ?? '-',
                          style: GoogleFonts.nunito(
                            color: ColorPalette.honeyDew,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Symptoms",
                          style: GoogleFonts.nunito(
                            color: ColorPalette.malachiteGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['symptoms']?.toString() ?? '-',
                          style: GoogleFonts.nunito(
                            color: ColorPalette.honeyDew,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Additional Notes",
                          style: GoogleFonts.nunito(
                            color: ColorPalette.malachiteGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['additionalNotes']?.toString() ?? '-',
                          style: GoogleFonts.nunito(
                            color: ColorPalette.honeyDew,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
