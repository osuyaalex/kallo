import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:job/screens/kallo_profile_login.dart';
import 'package:job/screens/settings.dart';
import 'kallo_profile_signup.dart';

class Profile extends StatefulWidget {
  final VoidCallback? onGoogleSignPressed;
  const Profile({Key? key, required this.onGoogleSignPressed}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return FirebaseAuth.instance.currentUser != null?
    FutureBuilder<DocumentSnapshot>(
      future: users.doc(FirebaseAuth.instance.currentUser!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return  Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.grey.shade100,
                toolbarHeight: MediaQuery.of(context).size.height*0.1,
              ),
              body: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.loggedInAs,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16
                          ),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          data['email']!= null?
                          Text( data['email'],
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16
                            ),
                          ):Text('')
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.remove_red_eye_outlined, color: Colors.black,),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(AppLocalizations.of(context)!.pickWatchItems),
                                    ],
                                  ),

                                  Icon(Icons.arrow_forward_ios_sharp, size: 17, color: Colors.black,)
                                ],
                              ),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.phone, color: Colors.black,),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(AppLocalizations.of(context)!.contactAndFeedback),
                                    ],
                                  ),

                                  Icon(Icons.arrow_forward_ios_sharp, size: 17, color: Colors.black,)
                                ],
                              ),
                            ),
                            Divider(),
                            InkWell(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return SettingsScreen();
                                }));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.settings, color: Colors.black,),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Text(AppLocalizations.of(context)!.settings),
                                      ],
                                    ),

                                    Icon(Icons.arrow_forward_ios_sharp, size: 17, color: Colors.black,)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 50,
                    ),

                  ],
                ),
              )
          );
        }

        return Center(
          child: CircularProgressIndicator(color: Color(0xff7F78D8)),
        );
      },
    ):Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.grey.shade100,
          toolbarHeight: MediaQuery.of(context).size.height*0.1,
        ),
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.remove_red_eye_outlined, color: Colors.black,),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(AppLocalizations.of(context)!.pickWatchItems),
                              ],
                            ),

                            Icon(Icons.arrow_forward_ios_sharp, size: 17, color: Colors.black,)
                          ],
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.black,),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(AppLocalizations.of(context)!.contactAndFeedback),
                              ],
                            ),

                            Icon(Icons.arrow_forward_ios_sharp, size: 17, color: Colors.black,)
                          ],
                        ),
                      ),
                      Divider(),
                      InkWell(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return SettingsScreen();
                          }));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.settings, color: Colors.black,),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(AppLocalizations.of(context)!.settings),
                                ],
                              ),

                              Icon(Icons.arrow_forward_ios_sharp, size: 17, color: Colors.black,)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              InkWell(
                onTap: (){
                  widget.onGoogleSignPressed!();
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
                        Text(AppLocalizations.of(context)!.signInWithGoogle,
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
                    child: Text(AppLocalizations.of(context)!.or,
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
                    return KalloProfileSignUpPage();
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
                    child: Text(AppLocalizations.of(context)!.createAnAccount,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 17
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(AppLocalizations.of(context)!.alreadyHaveAnAccount),
                  TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return KalloProfileLoginPage();
                        }));
                      },
                      child: Text(AppLocalizations.of(context)!.logIn)
                  )
                ],
              )
            ],
          ),
        )
    );



  }
}
