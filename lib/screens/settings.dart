import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:job/first%20pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _getInitialCountry = '';
  User? user = FirebaseAuth.instance.currentUser;
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
  ];
  // Add the country codes you want to allow

  void _loadCountryCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('countryCode');
    setState(() {
      _getInitialCountry = savedCode??'NG';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCountryCode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
            icon: Icon(Icons.arrow_back, color: Colors.black,)),
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
      ),
      body:  Center(
        child: Column(
          children: [
            Container(
              height: 55,
              width: MediaQuery.of(context).size.width*0.8,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(AppLocalizations.of(context)!.region,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17
                    ),
                  ),
                  CountryCodePicker(
                    onChanged: (code)async{
                      setState(() {
                        _getInitialCountry = code.code!;
                      });
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('countryCode', _getInitialCountry);
                    },
                    showCountryOnly: true,
                    showFlagMain: true,
                    showFlag: true,
                    countryFilter: _allowedCountryCodes,
                    initialSelection:_getInitialCountry,
                    hideSearch: false,
                    showOnlyCountryWhenClosed: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            user != null? GestureDetector(
              onTap: (){
                showDialog(
                    context: context,
                    builder: (context){
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)
                        ),
                        title: Text(AppLocalizations.of(context)!.signingOut,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        content: Text(AppLocalizations.of(context)!.areYouSure,
                        ),
                        actions: [
                          TextButton(
                              onPressed: ()async{
                                EasyLoading.show();
                                await FirebaseAuth.instance.signOut()
                                    .then(
                                        (value){
                                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                                           return Home();
                                         })) ;
                                        }
                                );
                                EasyLoading.dismiss();
                              },
                              child: Text(AppLocalizations.of(context)!.yes,
                          style: TextStyle(
                            color:  Color(0xff7F78D8),
                          ),
                          )
                          ),
                          TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              }, child: Text(AppLocalizations.of(context)!.no,
                            style: TextStyle(
                              color:  Colors.red,
                            ),
                          )
                          )
                        ],
                      );
                    }
                );
              },
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width*0.8,
                decoration: BoxDecoration(
                  color: Color(0xff7F78D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(AppLocalizations.of(context)!.signOut,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16
                    ),
                  ),
                ),
              ),
            ): Container()
          ],
        ),
      ),
    );
  }
}
