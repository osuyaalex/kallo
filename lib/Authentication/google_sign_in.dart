import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job/utils/snackbar.dart';

class GoogleAuthentication{
  static Future<User?> signInWithGoogle(BuildContext context) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? _googleSignInAccount =
    await _googleSignIn.signInSilently();

    if (_googleSignInAccount != null) {
      await _googleSignIn.signOut(); // Sign out to prompt for email selection
    }

    final GoogleSignInAccount? selectedAccount = await _googleSignIn.signIn();

    if (selectedAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await selectedAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
        user = userCredential.user;

        firebaseFirestore.collection('Users').doc(user!.uid).set({
          'email': user.email,
          'Uid': user.uid,
          'phone no': user.phoneNumber,
          'photo url': user.photoURL,
          'display name': user.displayName
        });

        return user;
      } catch (e) {
        // Handle sign-in error
      }
    }

    return null;
  }
}