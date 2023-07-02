import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:job/first%20pages/home.dart';
import 'package:job/first%20pages/kallo_login_page.dart';
import 'package:job/first%20pages/signin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Nationality extends StatefulWidget {

  const Nationality({Key? key,}) : super(key: key);

  @override
  State<Nationality> createState() => _NationalityState();
}

class _NationalityState extends State<Nationality> {
  final List<String> _allowedCountryCodes = [
    'US',
    'GB',
    'NG',
    'BR',
    'IN',
    'ZA',
    'TR',
    'RU',
    'PL',
    'JP',
    'AR',
    'DE',
    'EG',
    'FR',
    'VN',
    'IT',
    'ID',
    'MX',
    'KR',
    'ES',
    'CA'
  ]; // Add the country codes you want to allow


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white, // Set your desired color here
      ),
    );
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight:MediaQuery.of(context).size.height*0.28,
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        title: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('asset/Kallo logo dark background zoomed in png.png')
              )
            ),
          )
        ),
      ),
      body:  Center(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.1,
            ),
             Text(AppLocalizations.of(context)!.selectCountry,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21
            ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width *0.8,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: const Border(
                    top: BorderSide(
                        color: Colors.grey
                    ),
                    bottom: BorderSide(
                        color: Colors.grey
                    ),
                    left: BorderSide(
                        color: Colors.grey
                    ),
                    right: BorderSide(
                        color: Colors.grey
                    ),
                  )
              ),
              padding: const EdgeInsets.all(3),
              child: CountryCodePicker(
                onChanged: (code)async{
                  if(code.code != null){
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('countryCode', code.code!);
                  }else{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('countryCode', 'NG');
                  }
                },
                showCountryOnly: true,
                showFlagMain: true,
                showFlag: true,
                countryFilter: _allowedCountryCodes,
                initialSelection: 'NG',
                hideSearch: false,
                showOnlyCountryWhenClosed: true,

              ),
            ),
            const SizedBox(
              height: 30,
            ),
             Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 Icon(Icons.play_arrow_sharp, size: 24, color: Colors.grey.shade400,),
                SizedBox(
                  width: 250,
                    child: Text(AppLocalizations.of(context)!.nationalityDes,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        //fontWeight: FontWeight.w500,
                        letterSpacing: 0.5
                      ),
                    )
                ),
              ],
            ),
            const SizedBox(
              height: 35
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.play_arrow_sharp, size: 24, color: Colors.grey.shade400,),
                SizedBox(
                    width: 250,
                    child: Text(AppLocalizations.of(context)!.nationalityDesTwo,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          //fontWeight: FontWeight.w500,
                        letterSpacing: 0.5
                      ),
                ),
                )
              ],
            )
          ],
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.only(bottom: 45.0),
        child: Container(
          height: MediaQuery.of(context).size.height*0.14,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 60,
                    width: MediaQuery.of(context).size.width*0.45,
                    child: InkWell(
                      onTap: ()async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool('isFirstLaunch', false);
                        Navigator.pushReplacement(context, MaterialPageRoute(
                            builder: (context) => const Home()));
                      },
                      child: Card(
                        color: const Color(0xff7F78D8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child:  Center(
                          child: Text(AppLocalizations.of(context)!.letsGo,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16
                            ),
                          )
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return KalloLoginPage();
                            }));
                          },
                          child: Text(AppLocalizations.of(context)!.logIn,
                          style: TextStyle(
                            color: Color(0xff7F78D8)
                          ),
                          )
                      ),
                      TextButton(
                          onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return SignUp();
                            }));
                          },
                          child: Text(AppLocalizations.of(context)!.signUp,
                          style: TextStyle(
                            color: Color(0xff7F78D8)
                          ),
                          )
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
