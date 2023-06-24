import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:job/Authentication/google_sign_in.dart';
import 'package:job/first%20pages/home.dart';
import 'package:job/first%20pages/kallo_login_page.dart';
import 'package:job/first%20pages/kallo_signup_page.dart';
import 'package:job/utils/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        automaticallyImplyLeading: false,
        title:  Center(
            child: SizedBox(
              height: 40,
              width: 40,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7)
                ),
                elevation: 5,
                shadowColor: Color(0xff7F78D8).withOpacity(0.6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset('asset/Kallo logo dark background zoomed in png.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 27.0),
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.45,
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
             SizedBox(
              height: MediaQuery.of(context).size.height*0.05,
            ),
            InkWell(
              onTap: ()async{
                EasyLoading.show(status: 'Please wait');
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isFirstLaunch', false);
                User? user = await GoogleAuthentication.signInWithGoogle(context);
                EasyLoading.dismiss();
                if(user != null){
                  showCupertinoSnackBar(context: context, message: 'You are successfully signed in');
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
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Container(
                 height: 1,
                 width: MediaQuery.of(context).size.width*0.35,
                 color: Colors.grey,
               ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('or',
                    style: TextStyle(
                      color: Colors.grey
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width*0.35,
                  color: Colors.grey,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return KalloSignUpPage();
                }));
              },
              child: Container(
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
            ),
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 45.0),
        child: Container(
          height: MediaQuery.of(context).size.height*0.08,
          padding: EdgeInsets.only(bottom: 20),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return KalloLoginPage();
                  }));
                },
                child: Text('Log in',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff7F78D8),
                  ),
                ),
              ),
              TextButton(
                onPressed: ()async{
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isFirstLaunch', false);
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const Home()));
                },
                child: Text('No Thanks',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xff7F78D8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
