

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KalloSignUp{
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  signUpUsers(String fullName, String email, String password, String confirmPassword,)async{
    String res = 'something went wrong';
    try{
      if(fullName.isNotEmpty && email.isNotEmpty && password.isNotEmpty && confirmPassword.isNotEmpty){
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        await _firebaseFirestore.collection('Users').doc(cred.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'password': password,
          'following':[],

        });
        res = 'success';
      }
    }catch(e){
      res= e.toString();
      print(e.toString());
    }
    return res;
  }
}