import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService auth = AuthService();

  String get userId {
    if (auth.currentUser == null) {
      throw Exception("Utilisateur non connecté");
    }
    return auth.currentUser!.uid;
  }

  // PIN & Semesters methods ...
  Future<String?> getPin() async {
    var doc = await _db.collection("users").doc(userId).get();
    return doc.data()?["pin"];
  }

  Future<void> setPin(String pin) async {
    await _db.collection("users").doc(userId).set({"pin": pin}, SetOptions(merge: true));
  }

  Future<void> updatePin(String newPin) async {
    await _db.collection("users").doc(userId).update({"pin": newPin});
  }

  Future<bool> verifyPin(String pin) async {
    var doc = await _db.collection("users").doc(userId).get();
    return doc.data()?["pin"] == pin;
  }

  Stream<QuerySnapshot> getSemesters() {
    return _db.collection("users").doc(userId).collection("semesters").orderBy("createdAt", descending: true).snapshots();
  }
  
  Future<DocumentSnapshot> getSemesterDoc(String semesterId) async {
    return _db.collection("users").doc(userId).collection("semesters").doc(semesterId).get();
  }

  Future<void> addSemester(String name, String faculty, String department, String level) async {
    await _db.collection("users").doc(userId).collection("semesters").add({
      "name": name, "faculty": faculty, "department": department, "level": level, "createdAt": Timestamp.now(),
    });
  }

  Future<void> deleteSemester(String semesterId) async {
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).delete();
  }

  // Subjects & Notes methods ...
  Stream<QuerySnapshot> getSubjects(String semesterId) {
    return _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").snapshots();
  }

  Future<void> addSubjectWithNotes(String semesterId, String name, double ne, double ndg, double nef, double moyenneMatiere, String mention) async {
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").add({
      'name': name, 'ne': ne, 'ndg': ndg, 'nef': nef, 'moyenneMatiere': moyenneMatiere, 'mention': mention, 'isManual': false, 'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateSubjectWithNotes(String semesterId, String subjectId, String name, double ne, double ndg, double nef, double moyenneMatiere, String mention) async {
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").doc(subjectId).update({
      'name': name, 'ne': ne, 'ndg': ndg, 'nef': nef, 'moyenneMatiere': moyenneMatiere, 'mention': mention, 'isManual': false,
    });
  }

  Future<void> addSubjectManual(String semesterId, String name, double moyenneMatiere, String mention) async {
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").add({
      'name': name, 'moyenneMatiere': moyenneMatiere, 'mention': mention, 'isManual': true, 'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateSubjectManual(String semesterId, String subjectId, String name, double moyenneMatiere, String mention) async {
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").doc(subjectId).update({
      'name': name, 'moyenneMatiere': moyenneMatiere, 'mention': mention, 'isManual': true,
    });
  }

  Future<void> deleteSubject(String semesterId, String subjectId) async {
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").doc(subjectId).delete();
  }

  // ================= STATIC DATA =================

  Stream<QuerySnapshot> getFaculties() {
    return _db.collection('faculties').orderBy('name').snapshots();
  }
}
