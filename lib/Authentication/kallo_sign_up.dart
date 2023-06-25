import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';


class KalloSignUp{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<String> signUpUsers(String email, String password, String gender, BuildContext context) async {
    String res = AppLocalizations.of(context)!.somethingWentWrong;

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        await _firebaseFirestore.collection('Users').doc(cred.user!.uid).set({
          'email': email,
          'password': password,
          'gender': gender
        });
        res = AppLocalizations.of(context)!.successfullySignedIn;
      }
    } catch (e) {
      String errorMessage = e.toString();
      print(errorMessage);

      if (errorMessage.contains('email address is already in use')) {
        res = AppLocalizations.of(context)!.accountAlreadyExists;
      } else if (errorMessage.contains('A network error')) {
        res = AppLocalizations.of(context)!.connectionIsDown;
      } else {
        res = errorMessage;
      }
    }

    return res;
  }


  loginUsers(String email, String password, BuildContext context)async{
    String res = AppLocalizations.of(context)!.somethingWentWrong;
    try{
      if(email.isNotEmpty && password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = AppLocalizations.of(context)!.successfullyLoggedIn;
      }

    }catch (e) {
      String errorMessage = e.toString();
      print(errorMessage);

      if (errorMessage.contains('no user record')) {
        res = AppLocalizations.of(context)!.invalidEmailOrPassword;
      } else if (errorMessage.contains('A network error')) {
        res = AppLocalizations.of(context)!.connectionIsDown;
      }else if(errorMessage.contains('password is invalid')){
        res = AppLocalizations.of(context)!.invalidEmailOrPassword;
      } else {
        res = errorMessage;
      }
    }
    return res;
  }
}