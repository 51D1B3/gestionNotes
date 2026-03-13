import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService auth = AuthService();

  String? get userId => auth.currentUser?.uid;

  // ================= PROFILE =================

  Future<Map<String, String>?> getProfile() async {
    if (userId == null) return null;
    try {
      var doc = await _db.collection("users").doc(userId).get(
        const GetOptions(source: Source.serverAndCache)
      ).timeout(const Duration(seconds: 3));
      
      if (doc.exists && doc.data()?.containsKey('lastName') == true) {
        return {
          'lastName': doc.data()?['lastName'] ?? '',
          'firstName': doc.data()?['firstName'] ?? '',
          'gender': doc.data()?['gender'] ?? 'Homme',
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setProfile(String lastName, String firstName, String gender) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).set({
      "lastName": lastName,
      "firstName": firstName,
      "gender": gender,
    }, SetOptions(merge: true));
  }

  // ================= PIN =================

  Future<String?> getPin() async {
    if (userId == null) return null;
    try {
      var doc = await _db.collection("users").doc(userId).get(
        const GetOptions(source: Source.serverAndCache)
      ).timeout(const Duration(seconds: 3));
      
      return doc.data()?["pin"];
    } catch (e) {
      return null;
    }
  }

  Future<void> setPin(String pin) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).set({"pin": pin}, SetOptions(merge: true));
  }

  Future<void> updatePin(String newPin) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).update({"pin": newPin});
  }

  Future<bool> verifyPin(String pin) async {
    String? saved = await getPin();
    return saved == pin;
  }

  // ================= SEMESTERS =================

  Stream<QuerySnapshot> getSemesters() {
    if (userId == null) return const Stream.empty();
    return _db.collection("users").doc(userId).collection("semesters").orderBy("createdAt", descending: true).snapshots();
  }
  
  Future<DocumentSnapshot> getSemesterDoc(String semesterId) async {
    return _db.collection("users").doc(userId).collection("semesters").doc(semesterId).get();
  }

  Future<void> addSemester(String name, String faculty, String department, String level) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).collection("semesters").add({
      "name": name,
      "faculty": faculty,
      "department": department,
      "level": level,
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> deleteSemester(String semesterId) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).delete();
  }

  // ================= SUBJECTS & NOTES =================

  Stream<QuerySnapshot> getSubjects(String semesterId) {
    if (userId == null) return const Stream.empty();
    return _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").snapshots();
  }

  Future<void> addSubjectWithNotes(String semesterId, String name, double ne, double ndg, double nef, double moyenneMatiere, String mention) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").add({
      'name': name,
      'ne': ne,
      'ndg': ndg,
      'nef': nef,
      'moyenneMatiere': moyenneMatiere,
      'mention': mention,
      'isManual': false,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateSubjectWithNotes(String semesterId, String subjectId, String name, double ne, double ndg, double nef, double moyenneMatiere, String mention) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").doc(subjectId).update({
      'name': name,
      'ne': ne,
      'ndg': ndg,
      'nef': nef,
      'moyenneMatiere': moyenneMatiere,
      'mention': mention,
      'isManual': false,
    });
  }

  Future<void> addSubjectManual(String semesterId, String name, double moyenneMatiere, String mention) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").add({
      'name': name,
      'moyenneMatiere': moyenneMatiere,
      'mention': mention,
      'isManual': true,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateSubjectManual(String semesterId, String subjectId, String name, double moyenneMatiere, String mention) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").doc(subjectId).update({
      'name': name,
      'moyenneMatiere': moyenneMatiere,
      'mention': mention,
      'isManual': true,
    });
  }

  Future<void> deleteSubject(String semesterId, String subjectId) async {
    if (userId == null) return;
    await _db.collection("users").doc(userId).collection("semesters").doc(semesterId).collection("subjects").doc(subjectId).delete();
  }

  Stream<QuerySnapshot> getFaculties() {
    return _db.collection('faculties').orderBy('name').snapshots();
  }
}
