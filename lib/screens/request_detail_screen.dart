import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientNewPrescriptionScreen extends StatefulWidget {
  const PatientNewPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<PatientNewPrescriptionScreen> createState() =>
      _PatientNewPrescriptionScreenState();
}

class _PatientNewPrescriptionScreenState
    extends State<PatientNewPrescriptionScreen> {
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientNumberController =
  TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _medicalHistoryController =
  TextEditingController(); // ✅ Old Known History
  final TextEditingController _symptomsController =
  TextEditingController(); // ✅ Old Diagnosis
  final TextEditingController _additionalNotesController =
  TextEditingController(); // ✅ Old Advice
  final TextEditingController _followUpController = TextEditingController();

  Widget _buildTextField(
      TextEditingController controller, String hint, {
        TextInputType type = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: GoogleFonts.nunito(
        fontSize: 20,
        color: ColorPalette.honeyDew,
      ),
      decoration: InputDecoration(
        helperText: hint,
        helperStyle: GoogleFonts.nunito(
          fontSize: 18,
          color: ColorPalette.malachiteGreen,
        ),
      ),
      cursorColor: ColorPalette.honeyDew,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Prescription")),
      backgroundColor: ColorPalette.chineseBlack,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(_doctorNameController, "Doctor Name"),
                  _buildTextField(_hospitalNameController, "Hospital Name"),
                  _buildTextField(_patientNameController, "Patient Name"),
                  _buildTextField(
                    _patientNumberController,
                    "Patient Number",
                    type: TextInputType.number,
                  ),
                  _buildTextField(
                    _ageController,
                    "Age",
                    type: TextInputType.number,
                  ),
                  _buildTextField(_genderController, "Gender"),
                  _buildTextField(_temperatureController, "Temperature"),
                  _buildTextField(_weightController, "Weight"),
                  _buildTextField(_bpController, "BP"),
                  _buildTextField(_medicalHistoryController, "Medical History"),
                  _buildTextField(_symptomsController, "Symptoms"),
                  _buildTextField(_additionalNotesController, "Additional Notes"),
                  _buildTextField(_followUpController, "Follow Up"),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: FloatingActionButton(
                  child: const Icon(Icons.done),
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final patientId = user.uid;

                    await FirebaseFirestore.instance
                        .collection("prescriptionRequests")
                        .add({
                      "patientID": patientId,
                      "doctorName": _doctorNameController.text,
                      "hospital": _hospitalNameController.text,
                      "dateTime": Timestamp.now(),
                      "patient": {
                        "name": _patientNameController.text,
                        "age": _ageController.text,
                        "gender": _genderController.text,
                        "generalInfo": {
                          "temperature": _temperatureController.text,
                          "bp": _bpController.text,
                          "weight": _weightController.text,
                        },
                      },
                      "medicalHistory": _medicalHistoryController.text,
                      "symptoms": _symptomsController.text,
                      "additionalNotes": _additionalNotesController.text,
                      "followUp": _followUpController.text,
                    });

                    showTextToast("Prescription request sent successfully");
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
