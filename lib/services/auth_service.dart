import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> login(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register dengan Email & Password
  Future<UserCredential?> register(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Buat data Hero awal
      final initialHero = HeroModel(
        name: name,
        heroClass: HeroClass.warrior, // Kelas default
      );

      // Simpan data user dan hero ke Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(),
        ...initialHero.toJson(), // Menyimpan semua data hero
      });

      return userCredential;
    } catch (e) {
      print('Firebase Error: $e'); // Menambahkan print untuk debug
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Cek apakah user saat ini adalah admin
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['role'] == 'admin';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
