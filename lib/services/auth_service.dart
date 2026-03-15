import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:factify/models/user_category.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email, password, display name, phone, and user category
  Future<UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String phone, {
    UserCategory? userCategory,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.reload();

        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': displayName,
          'email': email,
          'phone': phone,
          'photoUrl': '',
          'userCategory': userCategory?.toFirestoreValue() ?? UserCategory.pelajar.toFirestoreValue(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in signUpWithEmailAndPassword: $e');
      rethrow;
    }
  }


  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in signInWithEmailAndPassword: $e');
      rethrow;
    }
  }

  // Sign in with Google - PERBAIKAN untuk v7.x
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      // Jika user membatalkan login
      if (googleUser == null) {
        return null;
      }

      // Dapatkan auth details - di v7.x ini synchronous
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // idToken wajib ada, tapi accessToken sudah tidak ada di v7.x
      if (googleAuth.idToken == null) {
        throw Exception('Google Sign-In failed: No ID token');
      }

      // Buat credential untuk Firebase (hanya pakai idToken)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken!,
      );

      // Sign in ke Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Cek apakah user baru (untuk simpan ke Firestore)
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        User? user = userCredential.user;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'username': user.displayName ?? 'User Google',
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '',
            'photoUrl': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Get user data stream
  Stream<DocumentSnapshot> getUserDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? username,
    String? phone,
    String? photoUrl,
    UserCategory? userCategory,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (username != null) updates['username'] = username;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (userCategory != null) updates['userCategory'] = userCategory.toFirestoreValue();

      await _firestore.collection('users').doc(uid).update(updates);

      if (username != null) {
        await _auth.currentUser?.updateDisplayName(username);
        await _auth.currentUser?.reload();
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // Coba sign out dari Google (jika pernah login via Google)
      // Wrap dalam try-catch terpisah karena bisa error jika Google Sign In
      // belum pernah diinisialisasi (misalnya user login via email/password)
      try {
        await _googleSignIn.signOut();
      } catch (googleError) {
        // Abaikan error Google Sign In - mungkin user tidak login via Google
        print('Google sign out skipped: $googleError');
      }
      
      // Kemudian sign out dari Firebase
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}