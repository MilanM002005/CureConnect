import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ Web detection

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isInitialized = false;

  User? get user => _user;

  AuthService() {
    _initializeFirebase();
  }

  // ✅ Initialize Firebase Authentication
  Future<void> _initializeFirebase() async {
    if (_isInitialized) return;

    try {
      _auth.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });

      _isInitialized = true;
      debugPrint("✅ Firebase Auth Initialized Successfully.");
    } catch (e) {
      debugPrint("❌ Firebase Initialization Failed: $e");
    }
  }

  // ✅ Fetch User Details from Firestore
  Future<Map<String, dynamic>?> getUserDetails() async {
    if (_user == null) return null;
    DocumentSnapshot userDoc =
    await _firestore.collection('users').doc(_user!.uid).get();
    return userDoc.data() as Map<String, dynamic>?;
  }

  // ✅ Register New User with Additional Details
  Future<String?> signUpWithEmail(
      String name, String email, String password, String height, String weight, String diabetes, String bloodRisk) async {
    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Store user details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'height': height,
        'weight': weight,
        'diabetes': diabetes,
        'bloodRisk': bloodRisk,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      debugPrint("Firebase SignUp Error: $e");
      return "An unknown error occurred.";
    }
  }

  // ✅ Update User Profile
  Future<void> updateUserProfile(
      String name, String height, String weight, String diabetes, String bloodRisk) async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        'height': height,
        'weight': weight,
        'diabetes': diabetes,
        'bloodRisk': bloodRisk,
      });
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error updating profile: $e");
    }
  }

  // ✅ Email & Password Sign In
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      debugPrint("Firebase SignIn Error: $e");
      return "An unknown error occurred.";
    }
  }

  // ✅ Google Sign-In (Fixed for Web & Mobile)
  Future<String?> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) return "Google Sign-In Aborted.";

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      await _saveUserToFirestore(userCredential.user);
      return null;
    } on FirebaseAuthException catch (e) {
      return "Google Sign-In Failed: ${e.message}";
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return "An error occurred during Google Sign-In.";
    }
  }

  // ✅ Save Google User Details in Firestore
  Future<void> _saveUserToFirestore(User? user) async {
    if (user == null) return;

    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
    if (!userDoc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName ?? "No Name",
        'email': user.email,
        'height': '',
        'weight': '',
        'diabetes': 'No',
        'bloodRisk': 'No',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ✅ Add Emergency Contact
  Future<String?> addEmergencyContact(String name, String phone) async {
    if (_user == null) return "User not logged in.";

    try {
      await _firestore.collection('users').doc(_user!.uid).collection('contacts').add({
        'name': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      debugPrint("Error adding contact: $e");
      return "Failed to add contact.";
    }
  }

  // ✅ Fetch Emergency Contacts
  Stream<List<Map<String, String>>> getUserEmergencyContacts() {
    if (_user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(_user!.uid)
        .collection('contacts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] as String? ?? '',
          'phone': data['phone'] as String? ?? '',
        };
      }).toList();
    });
  }

  // ✅ Delete Emergency Contact
  Future<void> deleteEmergencyContact(String contactId) async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.uid).collection('contacts').doc(contactId).delete();
      debugPrint("✅ Contact deleted successfully.");
    } catch (e) {
      debugPrint("❌ Error deleting contact: $e");
    }
  }

  // ✅ Reset Password (Fixed)
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      debugPrint("Password Reset Error: $e");
      return "An error occurred. Please try again.";
    }
  }

  // ✅ Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      debugPrint("✅ User signed out successfully.");
    } catch (e) {
      debugPrint("❌ Sign-out error: $e");
    }
  }

  // ✅ Handle Firebase Auth Errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "Invalid email format.";
      case 'user-disabled':
        return "This account has been disabled.";
      case 'user-not-found':
        return "No account found for this email.";
      case 'wrong-password':
        return "Incorrect password.";
      case 'email-already-in-use':
        return "This email is already registered.";
      case 'weak-password':
        return "Password should be at least 6 characters.";
      default:
        return "An error occurred: ${e.message}";
    }
  }
}
