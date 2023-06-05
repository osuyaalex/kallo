
import 'dart:convert';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job/network/json.dart';
import 'package:job/network/network.dart';
import 'package:job/screens/demo.dart';
import 'package:job/screens/offline_items.dart';
import 'package:job/screens/online_items.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


class Product extends StatefulWidget {

  const Product({Key? key}) : super(key: key);

  @override
  State<Product> createState() => _ProductState();
}

enum Segment { shopsNearMe, onlineShops }
class _ProductState extends State<Product>with SingleTickerProviderStateMixin{
  late Future<Koye> products = Network().getProducts(_scanBarcode, '');
  late Future<Koye> imageSearch = Network().getProductsImage(_image, '');
  late AnimationController _animationController;
  Segment _selectedSegment = Segment.onlineShops;
  String _scanBarcode = 'Unknown';
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  late String _code = '';
  bool _firstOpen = false;
  String _image = '';
  Timer? _timer;
  int _start = 5;
  final ImagePicker _picker = ImagePicker();


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
  Future<String?> _pickImage() async {
    XFile? file = await _picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      List<int> bytes = await file.readAsBytes();
      Uint8List uint8List = Uint8List.fromList(bytes);
      // Resize the image to the desired dimensions
      List<int> compressedBytes = await FlutterImageCompress.compressWithList(
        uint8List,
        minHeight: 224,
        minWidth: 224,
        quality: 90, // Adjust the quality as needed
      );

      String base64Image = base64Encode(compressedBytes);

      setState(() {
        _image = base64Image;
        print(_image);
      });

      return base64Image;
    } else {
      print('No image selected');
      return null;
    }
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
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
            if (_start == 0) {
              _timer?.cancel();
            }else {
              setState(() {
                _start--;
              });
            }

          },
    );
  }
  _shiftBarCode()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLaunch = prefs.getBool('isLaunch') ?? false;
    if(isLaunch == true){
      setState(() {
        _image = '';
      });
      _loadCountryCode();
      scanBarcodeNormal().then((value)async{
        setState(() {
          products = Network().getProducts(_scanBarcode, _code);
          _firstOpen = true;
          _start = 5;
        });
        _startTimer();
        prefs.setBool(('isLaunch'), false);
      });
    }
  }
  _shiftCamera()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLaunch = prefs.getBool('isLaunchCamera') ?? false;
    if(isLaunch == true){
      setState(() {
        _scanBarcode = '';
      });
      _loadCountryCode();
      _pickImage().then((value){
        setState(() {
          imageSearch = Network().getProductsImage(_image, _code);
          _firstOpen = true;
          _start = 5;
        });
        _startTimer();
        prefs.setBool(('isLaunchCamera'), false);
      });
    }
  }
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    _shiftBarCode();
    _shiftCamera();
    _loadCountryCode();
    imageSearch = Network().getProductsImage(_image, _code);
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
        backgroundColor:Colors.grey.shade50,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey.shade50,
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
                      width: MediaQuery.of(context).size.width *0.7,
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
                        setState(() {
                          _image = '';
                        });
                        _loadCountryCode();
                        scanBarcodeNormal().then((value){
                          setState(() {
                            products = Network().getProducts(_scanBarcode, _code);
                            _firstOpen = true;
                            _start = 5;
                          });
                          _startTimer();
                        });
                      },
                      icon: SvgPicture.asset('asset/barcode-scan-svgrepo-com (1).svg')
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        _scanBarcode = '';
                      });
                      _loadCountryCode();
                      _pickImage().then((value){
                        setState(() {
                          imageSearch = Network().getProductsImage(_image, _code);
                          _firstOpen = true;
                          _start = 5;
                        });
                        _startTimer();
                      });
                    },
                      child: Icon(Icons.camera_alt_outlined, color: Color(0xff7F78D8),size: 25,)
                  )
                ],
              ),
            ],
          ) ,
        ),
        body: Column(
          children: [
            _image == ''?FutureBuilder(
                future: products,
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                             onTap: (){
                               setState(() {
                                 _image = '';
                               });
                               _loadCountryCode();
                               scanBarcodeNormal().then((value){
                                 setState(() {
                                   products = Network().getProducts(_scanBarcode,_code);
                                   _firstOpen = true;
                                   _start = 5;
                                 });
                                 _startTimer();
                               });
                             },
                             child: Padding(
                               padding: const EdgeInsets.only(bottom: 10.0),
                               child: Container(
                                 height: 55,
                                 width: 200,
                                 decoration: BoxDecoration(
                                   borderRadius: BorderRadius.circular(12),
                                     color: const Color(0xff7F78D8).withOpacity(0.8),
                                 ),
                                 child: Center(
                                   child: Text(AppLocalizations.of(context)!.scanBarcode,
                                     textAlign: TextAlign.center,
                                     style: const TextStyle(
                                       color: Colors.white,
                                       fontWeight: FontWeight.w700,
                                       fontSize: 17
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                           ),
                          _start != 0?
                          _firstOpen?
                          Text(AppLocalizations.of(context)!.processingData,
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ):
                          Text(AppLocalizations.of(context)!.barcodeInfo,
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ):  _firstOpen?
                          Text(AppLocalizations.of(context)!.dataUnavailable,
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ):
                          Text(AppLocalizations.of(context)!.barcodeInfo,
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                _scanBarcode = '';
                              });
                              _loadCountryCode();
                              _pickImage().then((value){
                                setState(() {
                                  imageSearch = Network().getProductsImage(_image,_code);
                                //  _start = 5;
                                });
                                //_startTimer();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                height: 55,
                                width: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xff7F78D8).withOpacity(0.8),
                                ),
                                child: Center(
                                  child: Text(AppLocalizations.of(context)!.searchByPicture,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Text(AppLocalizations.of(context)!.pictureInfo,
                            textAlign: TextAlign.center,
                            style:TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if(!snapshot.hasData){
                    return Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap:_firstOpen == false ?null: (){
                                setState(() {
                                  _image = '';
                                });
                                _loadCountryCode();
                                scanBarcodeNormal().then((value){
                                  setState(() {
                                    products = Network().getProducts(_scanBarcode,_code);
                                  });
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Container(
                                  height: 55,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff7F78D8).withOpacity(0.8),
                                  ),
                                  child:Center(
                                    child: Text(AppLocalizations.of(context)!.scanBarcode,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _firstOpen ?  Text(AppLocalizations.of(context)!.dataUnavailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
                              ),
                            ): Container(),
                            const SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap:_firstOpen == false ?null: (){
                                setState(() {
                                  _scanBarcode = '';
                                });
                                _loadCountryCode();
                                _pickImage().then((value){
                                  setState(() {
                                    imageSearch = Network().getProductsImage(_image,_code);
                                    _firstOpen = true;
                                  });
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Container(
                                  height: 55,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff7F78D8).withOpacity(0.8),
                                  ),
                                  child: Center(
                                    child: Text(AppLocalizations.of(context)!.searchByPicture,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _firstOpen ?  Text(AppLocalizations.of(context)!.dataUnavailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
                              ),
                            ): Text(AppLocalizations.of(context)!.processingData,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: AppBar(
                            automaticallyImplyLeading: false,
                            backgroundColor: Colors.grey.shade100,
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
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.65,
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
            ):FutureBuilder(
                future: imageSearch,
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: (){
                              _loadCountryCode();
                              scanBarcodeNormal().then((value){
                                setState(() {
                                  products = Network().getProducts(_scanBarcode,_code);
                                  _image = '';
                                  _start = 5;
                                });
                                _startTimer();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                height: 55,
                                width: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xff7F78D8).withOpacity(0.8),
                                ),
                                child: Center(
                                  child: Text(AppLocalizations.of(context)!.scanBarcode,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                         Text(AppLocalizations.of(context)!.barcodeInfo,
                           textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                _scanBarcode = '';
                              });
                              _loadCountryCode();
                              _pickImage().then((value){
                                setState(() {
                                  imageSearch = Network().getProductsImage(_image,_code);
                                  _firstOpen = true;
                                  _start = 5;
                                });
                                _startTimer();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                height: 55,
                                width: 180,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xff7F78D8).withOpacity(0.8),
                                ),
                                child: Center(
                                  child: Text(AppLocalizations.of(context)!.searchByPicture,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                           _start !=0?
                           _firstOpen ?  Text(AppLocalizations.of(context)!.processingData,
                             textAlign: TextAlign.center,
                            style: TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ): Text(AppLocalizations.of(context)!.pictureInfo,
                             textAlign: TextAlign.center,
                            style:TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ): _firstOpen ?  Text(AppLocalizations.of(context)!.somethingWentWrong,
                             textAlign: TextAlign.center,
                             style: TextStyle(
                                 wordSpacing: 2,
                                 fontSize: 16,
                                 fontWeight: FontWeight.w800,
                                 color: Colors.grey.shade600
                             ),
                           ): Text(AppLocalizations.of(context)!.pictureInfo,
                             style:TextStyle(
                                 wordSpacing: 2,
                                 fontSize: 16,
                                 fontWeight: FontWeight.w800,
                                 color: Colors.grey.shade600
                             ),
                           ),
                        ],
                      ),
                    );
                  }
                  if(!snapshot.hasData){
                    return Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _image = '';
                                });
                                _loadCountryCode();
                                scanBarcodeNormal().then((value){
                                  setState(() {
                                    products = Network().getProducts(_scanBarcode,_code);
                                  });
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Container(
                                  height: 55,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff7F78D8).withOpacity(0.8),
                                  ),
                                  child:Center(
                                    child: Text(AppLocalizations.of(context)!.scanBarcode,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _firstOpen ?  Text(AppLocalizations.of(context)!.dataUnavailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
                              ),
                            ): Container(),
                            const SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  _scanBarcode = '';
                                });
                                _loadCountryCode();
                                _pickImage().then((value){
                                  setState(() {
                                    imageSearch = Network().getProductsImage(_image,_code);
                                    _firstOpen = true;
                                  });
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Container(
                                  height: 55,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xff7F78D8).withOpacity(0.8),
                                  ),
                                  child: Center(
                                    child: Text(AppLocalizations.of(context)!.searchByPicture,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            _firstOpen ?  Text(AppLocalizations.of(context)!.dataUnavailable,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
                              ),
                            ): Text(AppLocalizations.of(context)!.processingData,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
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
                          height: MediaQuery.of(context).size.height*0.65,
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
          ],
        ),
      ),
    );
  }

}
