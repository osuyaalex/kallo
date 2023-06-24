import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:job/utilities/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Authentication/kallo_sign_up.dart';
import 'home.dart';

class KalloLoginPage extends StatefulWidget {
  const KalloLoginPage({super.key});

  @override
  State<KalloLoginPage> createState() => _KalloLoginPageState();
}

class _KalloLoginPageState extends State<KalloLoginPage> {
  final KalloSignUp _kalloSignUp = KalloSignUp();
  late String _email;
  late String _password;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool _obscureText = true;

  _login()async{
    EasyLoading.show(status: 'please wait');
    if(_globalKey.currentState!.validate()){
     String res = await _kalloSignUp.loginUsers(
          _email,
          _password
      );
     if(res != 'You\'re successfully logged in'){
       EasyLoading.dismiss();
       snack(context, res);
     }else{
       EasyLoading.dismiss();
       SharedPreferences prefs = await SharedPreferences.getInstance();
       prefs.setBool('isFirstLaunch', false);
       snack(context, res);
       Navigator.pushReplacement(context, MaterialPageRoute(
           builder: (context) => const Home()));
     }
    }else{
      EasyLoading.dismiss();
    }
  }
  @override
  Widget build(BuildContext context) {
    return  Form(
      key: _globalKey,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey.shade50,
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
            ),
          ),
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width*0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Log in',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    onChanged: (v){
                      _email = v;
                    },
                    validator: (v){
                      if(v!.isEmpty){
                        return 'field must not be empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xff7F78D8)
                          )
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xff7F78D8)
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xff7F78D8)
                          )
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    obscureText: _obscureText,
                    onChanged: (v){
                      _password = v;
                    },
                    validator: (v){
                      if (v!.isEmpty) {
                        return 'Field must not be empty';
                      }
                      return null; // Return null if validation passes
                    },
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                          onPressed: (){
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: _obscureText?Icon(Icons.visibility):Icon(Icons.visibility_off)
                      ),
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xff7F78D8)
                          )
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xff7F78D8)
                          )
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xff7F78D8)
                          )
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.1,
                  ),
                  InkWell(
                    onTap: (){
                     _login();
                    },
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width*0.5,
                      decoration: BoxDecoration(
                        color: Color(0xff7F78D8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('Log in',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
