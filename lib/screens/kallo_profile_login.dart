import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:job/first%20pages/home.dart';
import 'package:job/utilities/snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Authentication/kallo_sign_up.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';


class KalloProfileLoginPage extends StatefulWidget {
  const KalloProfileLoginPage({super.key});

  @override
  State<KalloProfileLoginPage> createState() => _KalloProfileLoginPageState();
}

class _KalloProfileLoginPageState extends State<KalloProfileLoginPage> {
  final KalloSignUp _kalloSignUp = KalloSignUp();
  late String _email;
  late String _password;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool isInterceptorAdded = false;

  _login()async{
    EasyLoading.show(status: 'please wait');
    if(_globalKey.currentState!.validate()){
      String res = await _kalloSignUp.loginUsers(
          _email,
          _password,
        context
      );
      if(res != AppLocalizations.of(context)!.successfullyLoggedIn){
        EasyLoading.dismiss();
        snack(context, res);
      }else{
        EasyLoading.dismiss();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('isFirstLaunch', false);
        snack(context, res);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
          return Home();
        }));
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
                        Text(AppLocalizations.of(context)!.logIn,
                          style: TextStyle(
                              fontSize: 28,
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
                        return AppLocalizations.of(context)!.fieldMustNotBeEmpty;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterYourEmail,
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
                        return AppLocalizations.of(context)!.fieldMustNotBeEmpty;
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
                      hintText: AppLocalizations.of(context)!.enterYourPassword,
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
                        child: Text(AppLocalizations.of(context)!.logIn,
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