import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/utils/color_palette.dart';
import 'package:erx/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewPrescriptionScreen extends StatefulWidget {
  const NewPrescriptionScreen({Key? key}) : super(key: key);

  @override
  State<NewPrescriptionScreen> createState() => _NewPrescriptionScreenState();
}

class _NewPrescriptionScreenState extends State<NewPrescriptionScreen> {
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _hospitalNameController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientNumberController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController(); // ✅ ADDED
  final TextEditingController _bpController = TextEditingController();
  final TextEditingController _knownHistoryController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _adviceController = TextEditingController();
  final TextEditingController _followUpController = TextEditingController();

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
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
      appBar: AppBar(title: const Text("New Prescription")),
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
                  _buildTextField(_patientNumberController, "Patient Number"),
                  _buildTextField(_ageController, "Age"),
                  _buildTextField(_genderController, "Gender"),
                  _buildTextField(_temperatureController, "Temperature"),
                  _buildTextField(_weightController, "Weight"),
                  _buildTextField(_heightController, "Height"), // ✅ ADDED
                  _buildTextField(_bpController, "BP"),
                  _buildTextField(_knownHistoryController, "Known History"),
                  _buildTextField(_diagnosisController, "Diagnosis"),
                  _buildTextField(_adviceController, "Advice"),
                  _buildTextField(
                      _followUpController, "Follow Up (dd/MM/yyyy)"),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: FloatingActionButton(
                  child: const Icon(Icons.done),
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    await FirebaseFirestore.instance
                        .collection("prescription")
                        .add({
                      "doctorID": user.uid,
                      "doctorName": _doctorNameController.text,
                      "hospital": _hospitalNameController.text,
                      "dateTime": Timestamp.now(),
                      "patientID": _patientNumberController.text,
                      "patient": {
                        "name": _patientNameController.text,
                        "age": _ageController.text,
                        "gender": _genderController.text,
                        "generalInfo": {
                          "temperature": _temperatureController.text,
                          "weight": _weightController.text,
                          "height": _heightController.text, // ✅ SAVED
                          "bp": _bpController.text,
                        },
                      },
                      "knownHistory": _knownHistoryController.text,
                      "diagnosis": _diagnosisController.text,
                      "advice": _adviceController.text,
                      "followUp": _followUpController.text, // ✅ USER DATE
                    });

                    showTextToast("Prescription added successfully");
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
