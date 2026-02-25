import 'package:cloud_firestore/cloud_firestore.dart';

class UniversitySetupService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initializeFaculties() async {

    final faculties = {
      "Faculté des Sciences et Techniques (FST)": [
        "MIAGE",
        "Informatique",
        "Mathématiques",
        "Biologie",
        "Chimie environnement"
      ],
      "Faculté des Lettres et Sciences Humaines (FLSH)": [
        "Lettres modernes",
        "Sociologie",
        "Langue Anglaise",
        "Langue Arabe"
      ],
      "Faculté des Sciences Administratives et de Gestion (FSAG)": [
        "Gestion",
        "Economie",
        "Economie Statistique",
        "Economie sociale et solidaire"
      ],
    };

    for (var faculty in faculties.entries) {
      await _firestore.collection("faculties").doc(faculty.key).set({
        "name": faculty.key,
        "departments": faculty.value,
      });
    }
  }
}