import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class Nationality extends StatefulWidget {
  const Nationality({Key? key}) : super(key: key);

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
  String _code = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight:MediaQuery.of(context).size.height*0.3,
        elevation: 0,
        backgroundColor: Colors.white,
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
            const Text('Select a Country',
            style: TextStyle(
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
                onChanged: (code){
                  setState(() {
                    _code = code.code!;
                  });
                },
                showFlagMain: true,
                showFlag: true,
                favorite: _allowedCountryCodes,
                countryFilter: _allowedCountryCodes,
                initialSelection: 'OM',
                hideSearch: false,
                showOnlyCountryWhenClosed: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
