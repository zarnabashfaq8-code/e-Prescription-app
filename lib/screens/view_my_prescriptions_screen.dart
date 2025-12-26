import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erx/widgets/prescription_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erx/utils/color_palette.dart';

class ViewMyPrescriptionsScreen extends StatelessWidget {
  final String userId;
  ViewMyPrescriptionsScreen({Key? key, required this.userId, required String requestId}) : super(key: key);

  final f = DateFormat('dd-MM-yyyy');

  @override
  Widget build(BuildContext context) {
    final _prescriptionStream = FirebaseFirestore.instance
        .collection("prescriptions")
        .where("patientUid", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions"),
        backgroundColor: ColorPalette.charlestonGreen,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _prescriptionStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: ColorPalette.malachiteGreen));
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("No prescriptions yet."));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index].data();
              return PrescriptionCard(
                prescriptionId: docs[index].id,
                doctorName: doc['doctorName']?.toString() ?? '',
                hospitalName: doc['hospital']?.toString() ?? '',
                prescriptionDate:
                f.format((doc['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now()),
                followUpDate: doc['followUp']?.toString() ?? '',
                patientName: doc['patientName']?.toString() ?? '',
              );
            },
          );
        },
      ),
    );
  }
}
