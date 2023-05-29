import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import '../network/json.dart';
import '../network/network.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final List<String> _lastViewed = [
    'https://images.pexels.com/photos/90946/pexels-photo-90946.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3685523/pexels-photo-3685523.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/364984/pexels-photo-364984.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3735655/pexels-photo-3735655.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/2783873/pexels-photo-2783873.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
  ];
  late Future<Koye> products = Network().getProducts('8717163545652', _code);
  String _scanBarcode = 'Unknown';
  late String _code = '';

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  void _loadCountryCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('countryCode');
    setState(() {
      _code = savedCode??'NG';
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCountryCode();
    products = Network().getProducts('6151100056436',_code);
    products.then((value){
      print('the prducy issssssssssssssss ${value.data}');
    });
  }
  int _activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    List<Widget> images= [
      Stack(
        children: [
          SizedBox(
            //height: MediaQuery.of(context).size.height*0.1,
            width: MediaQuery.of(context).size.width*0.8,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 1,
              shadowColor: Colors.grey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('asset/pexels-godisable-jacob-1191529.jpeg', fit: BoxFit.cover,),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        //height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width*0.8,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
          shadowColor: Colors.grey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('asset/pexels-rachel-claire-5865340.jpeg', fit: BoxFit.cover,),
          ),
        ),
      ),
      SizedBox(
        //height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width*0.8,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
          shadowColor: Colors.grey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('asset/pexels-markus-winkler-12100420.jpeg', fit: BoxFit.cover,),
          ),
        ),
      ),
      SizedBox(
        //height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width*0.8,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
          shadowColor: Colors.grey,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('asset/pexels-mateusz-dach-2547541.jpeg', fit: BoxFit.cover,),
          ),
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfffafafa),
        elevation: 0,
        toolbarHeight:MediaQuery.of(context).size.height*0.19,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7)
                    ),
                    elevation: 1,
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
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height*0.06,
                  width: MediaQuery.of(context).size.width *0.77,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchForProducts,
                      prefixIcon: IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.search)
                      ),
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
                ),
                IconButton(
                    onPressed: (){
                      scanBarcodeNormal().then((value){
                        setState(() {
                          products = Network().getProducts(_scanBarcode,_code);
                        });
                      });
                    },
                    icon: SvgPicture.asset('asset/barcode-scan-svgrepo-com.svg')
                ),
              ],
            ),
          ],
        ) ,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              CarouselSlider.builder(
                options: CarouselOptions(
                  pauseAutoPlayOnManualNavigate: true,
                  autoPlayInterval: Duration(seconds: 8),
                    viewportFraction: 0.85,
                    aspectRatio: 16/9,
                    height: MediaQuery.of(context).size.height*0.2,
                    autoPlay: true,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason){
                      setState(() {
                        _activeIndex = index;
                      });
                    }
                ),
                itemCount: images.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return  images[index];

                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12,right: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                     Text(AppLocalizations.of(context)!.lastViewed,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800
                      ),
                    ),
                    TextButton(
                        onPressed: (){

                        },
                        child:  Text(AppLocalizations.of(context)!.seeMore,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18
                          ),
                        )
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _lastViewed.length,
                    itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 130,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                              image: NetworkImage(_lastViewed[index],
                              ),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                    );
                    }
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
