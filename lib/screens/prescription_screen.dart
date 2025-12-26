import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/svg_strings.dart';
import 'package:erx/widgets/glass_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({
    Key? key,
    required this.prescriptionId,
  }) : super(key: key);

  final String prescriptionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.chineseBlack,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("prescription")
              .doc(prescriptionId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;

            final Map<String, dynamic> patient =
            (data['patient'] ?? {}) as Map<String, dynamic>;

            final Map<String, dynamic> generalInfo =
            (patient['generalInfo'] ?? {}) as Map<String, dynamic>;

            final DateTime dateTime =
                (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();

            final String formattedDate =
            DateFormat("dd MMM yyyy, HH:mm").format(dateTime);

            /// ✅ Follow-up safe formatting
            String formattedFollowUp = "-";
            if (data['followUp'] != null &&
                data['followUp'].toString().isNotEmpty) {
              try {
                final parsed =
                DateFormat("dd/MM/yyyy").parse(data['followUp'].toString());
                formattedFollowUp =
                    DateFormat("dd MMM yyyy").format(parsed);
              } catch (_) {
                formattedFollowUp = data['followUp'].toString();
              }
            }

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
                  color: const Color.fromARGB(255, 15, 18, 24)
                      .withOpacity(0.7),
                ),

                /// ================= CONTENT =================
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
                            const Spacer(),
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
                            const Spacer(),
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

                        /// ✅ FIXED GlassBox STRINGS
                        Center(
                          child: Wrap(
                            runSpacing: 20,
                            spacing: 30,
                            children: [
                              GlassBox(
                                text: generalInfo['temperature']
                                    ?.toString() ??
                                    "-",
                                svgString: SvgStrings.temperature,
                              ),
                              GlassBox(
                                text:
                                generalInfo['weight']?.toString() ?? "-",
                                svgString: SvgStrings.weight,
                              ),
                              GlassBox(
                                text: generalInfo['bp']?.toString() ?? "-",
                                svgString: SvgStrings.waterDrop,
                              ),
                              GlassBox(
                                text:
                                generalInfo['height']?.toString() ?? "-",
                                svgString: SvgStrings.height,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          "Known History",
                          style: GoogleFonts.nunito(
                            color: ColorPalette.malachiteGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['knownHistory']?.toString() ?? '-',
                          style: GoogleFonts.nunito(
                            color: ColorPalette.honeyDew,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          "Diagnosis",
                          style: GoogleFonts.nunito(
                            color: ColorPalette.malachiteGreen,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['diagnosis']?.toString() ?? '-',
                          style: GoogleFonts.nunito(
                            color: ColorPalette.honeyDew,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 40),
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
