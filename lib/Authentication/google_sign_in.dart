import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job/utils/snackbar.dart';

class GoogleAuthentication{
  static Future<User?> signInWithGoogle(BuildContext context)async{
    FirebaseAuth _auth = FirebaseAuth.instance;
    User? user;
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? _googleSignInAccount = await _googleSignIn.signIn();

    if(_googleSignInAccount != null){
      final GoogleSignInAuthentication googleSignInAuthentication = await _googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken:  googleSignInAuthentication.idToken
      );

      try{
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        user = userCredential.user;
        firebaseFirestore.collection('Users').doc(user!.uid).set({
          'email':user.email,
          'Uid':user.uid,
          'phone no':user.phoneNumber,
          'photo url':user.photoURL,
          'display name':user.displayName
        });
        return user;
      }on FirebaseAuthException catch(e){
        if(e.code == 'account-exists-with-different-credential'){
          snack(context, 'Account already exists');
        }else if (e.code == 'invalid-credential'){
          snack(context, 'invalid Credentials');
        }
      }catch(e){
        return snack(context, 'something went wrong');
      }
    }
    return user;
  }
}