

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:job/network/email_json.dart';

class KalloSignUp{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<String> signUpUsers(String email, String password, String gender) async {
    String res = 'something went wrong';

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Verify the email using the MailboxValidator API
        final String apiKey ='at_Rf0ROT7Alq1gPzcdUDW8vA5y1bZBk';
        final response = await http.get(Uri.parse('https://emailverification.whoisxmlapi.com/api/v2?apiKey=$apiKey&emailAddress=$email'));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final emailValidation = EmailValidation.fromJson(data);

          if (emailValidation.smtpCheck == 'true') {
            // Proceed with user sign up
            UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
            await _firebaseFirestore.collection('Users').doc(cred.user!.uid).set({
              'email': email,
              'password': password,
              'gender': gender
            });
            res = 'You\'re successfully signed in';
          } else if(emailValidation.smtpCheck == 'false') {
            res = 'Email does not exist';
          }else{
            res = 'something went wrong';
          }
        } else {
          res = 'Email verification failed';
        }
      }
    } catch (e) {
      res = e.toString();
      print(e.toString());
    }

    return res;
  }


  loginUsers(String email, String password)async{
    String res = 'Something went wrong';
    try{
      if(email.isNotEmpty && password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'You\'re successfully logged in';
      }

    }catch(e){
      res = e.toString();
    }
    return res;
  }
}