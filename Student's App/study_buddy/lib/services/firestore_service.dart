import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_buddy/models/user_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setUserData(UserData data) async {
    await _firestore.collection('users').doc(data.username).set(data.toMap());
  }

  Future<UserData?> getUserData(String username) async {
    final doc = await _firestore.collection('users').doc(username).get();
    if (!doc.exists) return null;
    return UserData.fromMap(username, doc.data()!);
  }

  Stream<UserData> streamUserData(String username) {
    return _firestore.collection('users').doc(username).snapshots().map((snap) {
      return UserData.fromMap(username, snap.data());
    });
  }
}
