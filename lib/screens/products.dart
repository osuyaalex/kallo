
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job/network/json.dart';
import 'package:job/network/network.dart';
import 'package:job/screens/demo.dart';
import 'package:job/screens/offline_items.dart';
import 'package:job/screens/online_items.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Products extends StatefulWidget {

  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

enum Segment { shopsNearMe, onlineShops }
class _ProductsState extends State<Products>with SingleTickerProviderStateMixin{
  late Future<Koye> products = Network().getProducts(_scanBarcode, '');
  late AnimationController _animationController;
  Segment _selectedSegment = Segment.onlineShops;
  String _scanBarcode = 'Unknown';
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  late String _code = '';
  bool _firstOpen = false;
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

  void _switchToSegment(Segment segment) {
    if (_selectedSegment == segment) return;

    setState(() {
      _selectedSegment = segment;
    });

    if (_selectedSegment == Segment.onlineShops) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
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
    products = Network().getProducts(_scanBarcode, _code);
    products.then((value){
      print('the prducy issssssssssssssss ${value.data}');
      //snack(context, value.data.)
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Scaffold(
        backgroundColor:  Color(0xfffafafa),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xfffafafa),
          elevation: 0,
          toolbarHeight:MediaQuery.of(context).size.height*0.17,
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
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return const DemoScreen();
                      }));
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.06,
                      width: MediaQuery.of(context).size.width *0.77,
                      child: TextFormField(
                        enabled: false,
                        onChanged: null,
                        decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)?.searchForProducts,
                            prefixIcon: Icon(Icons.search),

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
                  ),
                  IconButton(
                      onPressed: (){
                        _loadCountryCode();

                        scanBarcodeNormal().then((value){
                          setState(() {
                            products = Network().getProducts(_scanBarcode, _code);
                            _firstOpen = true;
                          });
                        });
                      },
                      icon: SvgPicture.asset('asset/barcode-scan-svgrepo-com.svg')
                  ),
                ],
              ),
              // Text(_scanBarcode),

            ],
          ) ,
        ),
        body: FutureBuilder(
            future: products,
            builder: (context, snapshot){
              if(snapshot.hasError){
                return Center(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                      _firstOpen ? const Text('Something went wrong',
                         style: TextStyle(
                             fontSize: 15,
                             fontWeight: FontWeight.w600
                         ),
                       ):const Text('Scan Barcode',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                       const SizedBox(
                         height: 10,
                       ),
                       GestureDetector(
                          onTap: (){
                            _loadCountryCode();
                            scanBarcodeNormal().then((value){
                              setState(() {
                                products = Network().getProducts(_scanBarcode,_code);
                                _firstOpen = true;
                              });
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Container(
                              height: 40,
                              width: 120,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xff7F78D8).withOpacity(0.8),
                              ),
                              child: Text(AppLocalizations.of(context)!.tapToScanItem,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14
                                ),
                              ),
                            ),
                          ),
                        ),
                     ],
                   )
                );
              }
              if(!snapshot.hasData){
                return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No data available currently',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
                          onTap: (){
                            _loadCountryCode();
                            scanBarcodeNormal().then((value){
                              setState(() {
                                products = Network().getProducts(_scanBarcode,_code);
                              });
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Container(
                              height: 40,
                              width: 120,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xff7F78D8),
                              ),
                              child:Center(
                                child: Text(AppLocalizations.of(context)!.tapToScanItem,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                );
              }
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xff7F78D8),),
                );
              }else if(snapshot.hasData){
                return Column(
                  children: [
                    AppBar(
                      automaticallyImplyLeading: false,
                      backgroundColor: const Color(0xfffafafa),
                      elevation: 0,
                      title:  Center(
                        child: CustomSlidingSegmentedControl(
                          //isStretch: true,
                          initialValue: _selectedSegment.index,
                          children:  {
                            Segment.onlineShops.index: SizedBox(
                              child: _selectedSegment == Segment.onlineShops?
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white, size: 19,),
                                  Text(
                                    AppLocalizations.of(context)?.onlineShops??'',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ],
                              ): Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Colors.black,size: 19,),
                                  Text(
                                    AppLocalizations.of(context)?.onlineShops??'',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ],
                              ),

                            ),
                            Segment.shopsNearMe.index: SizedBox(
                              child: _selectedSegment == Segment.shopsNearMe?
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: SvgPicture.asset('asset/shipping-car-svgrepo-com (1).svg',height: 19,),
                                  ),
                                  Text(
                                    AppLocalizations.of(context)?.shopsNearMe??'',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ],
                              ): Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: SvgPicture.asset('asset/shipping-car-svgrepo-com.svg', height: 19,),
                                  ),Text(
                                    AppLocalizations.of(context)?.shopsNearMe??'',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          },
                          decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          thumbDecoration: BoxDecoration(
                              color: const Color(0xff7F78D8),
                              borderRadius: BorderRadius.circular(20)
                          ),
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInToLinear,
                          onValueChanged: (value) {
                            setState(() {
                              _switchToSegment(Segment.values[value]);
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.588,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1, 0),
                              end: Offset.zero,
                            ).animate(_animationController),
                            child: Offline(snapshot: snapshot,),
                          ),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset.zero,
                              end: Offset(-1, 0),
                            ).animate(_animationController),
                            child: Online(snapshot: snapshot,),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }else{
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black,),
                );
              }
            }
        ),
      ),
    );
  }

}
