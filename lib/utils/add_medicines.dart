// add_medicines.dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addMedicinesToFirestore() async {
  final medicines = [
    {"name": "Paracetamol", "purpose": "Pain & Fever"},
    {"name": "Amoxicillin", "purpose": "Antibiotic"},
    {"name": "Cetirizine", "purpose": "Allergy"},
    {"name": "Ibuprofen", "purpose": "Pain & Inflammation"},
    {"name": "Metformin", "purpose": "Diabetes"},
    {"name": "Aspirin", "purpose": "Heart & Pain"},
    {"name": "Loratadine", "purpose": "Allergy"},
    {"name": "Omeprazole", "purpose": "Stomach Acid"},
    {"name": "Azithromycin", "purpose": "Antibiotic"},
    {"name": "Diclofenac", "purpose": "Pain & Inflammation"},
    {"name": "Ciprofloxacin", "purpose": "Antibiotic"},
    {"name": "Levothyroxine", "purpose": "Thyroid"},
    {"name": "Atorvastatin", "purpose": "Cholesterol"},
    {"name": "Hydrochlorothiazide", "purpose": "Blood Pressure"},
    {"name": "Salbutamol", "purpose": "Asthma"},
    {"name": "Fexofenadine", "purpose": "Allergy"},
    {"name": "Ranitidine", "purpose": "Stomach Acid"},
    {"name": "Clopidogrel", "purpose": "Heart & Blood Thinner"},
    {"name": "Tramadol", "purpose": "Pain Relief"},
    {"name": "Insulin", "purpose": "Diabetes"},
  ];

  final collection = FirebaseFirestore.instance.collection('medicines');

  for (var med in medicines) {
    await collection.add(med);
  }

  print("Medicines added successfully!");
}
