import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String _getInitialCountry = '';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
        toolbarHeight: MediaQuery.of(context).size.height*0.1,
      ),
      body: Center(
        child: Column(
          children: [
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
                    ExpansionTile(
                      textColor: Colors.black,
                        iconColor: Colors.black,
                        leading: const Icon(Icons.remove_red_eye_outlined, color: Colors.black,),
                        title: Text(AppLocalizations.of(context)!.pickWatchItems),
                      shape: Border.all(color: Colors.transparent),
                      children: [],
                    ),
                    ExpansionTile(
                      textColor: Colors.black,
                      iconColor: Colors.black,
                      leading: const Icon(Icons.phone, color: Colors.black,),
                      title: Text(AppLocalizations.of(context)!.contactAndFeedback),
                      shape: Border.all(color: Colors.transparent),
                      children: [],
                    ),
                    ExpansionTile(
                      textColor: Colors.black,
                      iconColor: Colors.black,
                      leading: const Icon(Icons.settings, color: Colors.black,),
                      title: Text(AppLocalizations.of(context)!.settings),
                      shape: Border.all(color: Colors.transparent),
                      children: [],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
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

          ],
        ),
      )
    );
  }
}
