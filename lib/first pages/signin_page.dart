import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:job/Authentication/google_sign_in.dart';
import 'package:job/first%20pages/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 27.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Kallo Account',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('shopping made easier',
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.7,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xff7F78D8),
              ),
              child: Center(
                child: Text('Create an account',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: ()async{
                EasyLoading.show(status: 'Please wait');
                User? user = await GoogleAuthentication.signInWithGoogle(context);
                EasyLoading.dismiss();
                if(user != null){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                    return Home();
                  }));
                }

              },
              child: Container(
                width: MediaQuery.of(context).size.width*0.7,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    top: BorderSide(
                      color: Colors.black
                    ),
                    bottom: BorderSide(
                        color: Colors.black
                    ),
                    left: BorderSide(
                        color: Colors.black
                    ),
                    right: BorderSide(
                        color: Colors.black
                    ),
                  )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('asset/google_logo.png', height: 35,),
                      Text('Sign in with Google',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 17
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
