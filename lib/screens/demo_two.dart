
import 'package:camera/camera.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:job/network/image_json.dart';
import 'package:job/network/json.dart';
import 'package:job/network/network.dart';
import 'package:job/screens/demo.dart';
import 'package:job/screens/image_offline.dart';
import 'package:job/screens/image_online.dart';
import 'package:job/screens/offline_items.dart';
import 'package:job/screens/online_items.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'camera.dart';


class Dems extends StatefulWidget {

  const Dems({Key? key}) : super(key: key);

  @override
  State<Dems> createState() => _DemsState();
}

enum Segment { shopsNearMe, onlineShops }
class _DemsState extends State<Dems>with SingleTickerProviderStateMixin{
  late Future<Koye> products = Network().getProducts(_scanBarcode, '');
  late Future<KalloImageSearch> imageSearch = Network().getProductsImage(_image, '');
  late AnimationController _animationController;
  Segment _selectedSegment = Segment.onlineShops;
  String _scanBarcode = 'Unknown';
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  late String _code = '';
  bool _firstOpen = false;
  String _image = '';
  Timer? _timer;
  int _start = 5;
  //RangeValues _selectedValues = RangeValues(0.0, 100000.0);


  //final ImagePicker _picker = ImagePicker();


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
  _pickImage() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    PermissionStatus status = await Permission.camera.request();
    if(status.isGranted){
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => CameraScreen(
            camera: firstCamera,
          ),
        ),
      );

      // Handle the result, such as saving the picture or displaying it in the UI
      if (result != null) {
        setState(() {
          _image = result;
        });
        print('Captured image path: $result');
      } else {
        print('No image selected');
        return null;
      }
    }else if(status.isDenied || status.isPermanentlyDenied){
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: Text('Camera Permissions',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17
                ),
              ),
              content: Text('Please grant camera permissions to use this feature'),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: Text('OK')
                )
              ],
            );
          }
      );
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
          _start = 10;
        });
        _startTimer();
        prefs.setBool(('isLaunchCamera'), false);
      });
    }
  }
  _shiftSearchBar()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isSearch = prefs.getBool('isSearchBar') ?? false;
    if(isSearch == true){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DemoScreen()));
      });
      prefs.setBool(('isSearchBar'), false);
    }
  }
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    _shiftBarCode();
    _shiftCamera();
    _shiftSearchBar();
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
        backgroundColor:Colors.grey.shade100,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey.shade50,
          elevation: 0,
          toolbarHeight:MediaQuery.of(context).size.height*0.13,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
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
                  )
              ),
              const SizedBox(
                height: 3,
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
                      height: MediaQuery.of(context).size.height*0.055,
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
                            _start = 10;
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
                         // Text(snapshot.error.toString()),
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
                                color: Colors.grey.shade600
                            ),
                          ):
                          Text(AppLocalizations.of(context)!.barcodeInfo,
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                color: Colors.grey.shade600
                            ),
                          ):  _firstOpen?
                          Text(AppLocalizations.of(context)!.dataUnavailable,
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                                color: Colors.grey.shade600
                            ),
                          ):
                          Text(AppLocalizations.of(context)!.barcodeInfo,
                            textAlign: TextAlign.center,
                            style:  TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
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
                                    _start = 12;
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
                          Text(AppLocalizations.of(context)!.pictureInfo,
                            textAlign: TextAlign.center,
                            style:TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
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
                                  color: Colors.grey.shade600
                              ),
                            ): Text(AppLocalizations.of(context)!.processingData,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                  color: Colors.grey.shade600
                              ),
                            ),
                          ],
                        )
                    );
                  }
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height*0.8,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Positioned(
                          top:MediaQuery.of(context).size.height*0.4,
                          left:MediaQuery.of(context).size.width*0.45,
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xff7F78D8),),
                          ),
                        ),
                      ],
                    );
                  }else if(snapshot.hasData){
                    return Column(
                      children: [
                        Container(
                          color:Colors.grey.shade50,
                          child: Card(
                            color:Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)
                            ),
                            elevation: 2,
                            shadowColor: Color(0xff7F78D8).withOpacity(0.3),
                            child: ClipRRect(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: AppBar(
                                  elevation: 0,
                                  automaticallyImplyLeading: false,
                                  backgroundColor: Colors.grey.shade50,
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
                                                    fontWeight: FontWeight.w400
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
                                                    fontWeight: FontWeight.w400
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
                                                    fontWeight: FontWeight.w400
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
                                                    fontWeight: FontWeight.w400
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
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height*0.69,
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
                               // fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),

                          //Text(snapshot.error.toString()),
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
                              //  fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ): Text(AppLocalizations.of(context)!.pictureInfo,
                            textAlign: TextAlign.center,
                            style:TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                               // fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ): _firstOpen ?  Text(AppLocalizations.of(context)!.somethingWentWrong,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                              //  fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ): Text(AppLocalizations.of(context)!.pictureInfo,
                            style:TextStyle(
                                wordSpacing: 2,
                                fontSize: 16,
                              //  fontWeight: FontWeight.w800,
                                color: Colors.grey.shade600
                            ),
                          ),
                         // Text('Captured image path: $_image', style: TextStyle(color: Colors.black),)
                        ],
                      ),
                    );
                  }
                  if(!snapshot.hasData){
                    return _start!= 0?Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height*0.8,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Positioned(
                          top:MediaQuery.of(context).size.height*0.4,
                          left:MediaQuery.of(context).size.width*0.45,
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xff7F78D8),),
                          ),
                        ),
                      ],
                    ): Center(
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
                                //  fontWeight: FontWeight.w800,
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
                                 // fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
                              ),
                            ): Text(AppLocalizations.of(context)!.processingData,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  wordSpacing: 2,
                                  fontSize: 16,
                                //  fontWeight: FontWeight.w800,
                                  color: Colors.grey.shade600
                              ),
                            ),
                          ],
                        )
                    );
                  }
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height*0.8,
                          width: MediaQuery.of(context).size.width,
                        ),
                        Positioned(
                          top:MediaQuery.of(context).size.height*0.4,
                          left:MediaQuery.of(context).size.width*0.45,
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xff7F78D8),),
                          ),
                        ),
                      ],
                    );
                  }else if(snapshot.hasData){
                    return Column(
                      children: [
                       Container(
                         color:Colors.grey.shade50,
                          child: Card(
                            color:Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)
                            ),
                            elevation: 2,
                            shadowColor: Color(0xff7F78D8).withOpacity(0.3),
                            child: ClipRRect(
                              child: AppBar(
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
                                                  fontWeight: FontWeight.w400
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
                                                  fontWeight: FontWeight.w400
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
                                                  fontWeight: FontWeight.w400
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
                                                  fontWeight: FontWeight.w400
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
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height*0.69,
                          width: double.infinity,
                          color:Colors.grey.shade100,
                          child: Stack(
                            children: [
                              SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(1, 0),
                                  end: Offset.zero,
                                ).animate(_animationController),
                                child: ImageOffline(snapshot: snapshot,),
                              ),
                              SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset.zero,
                                  end: Offset(-1, 0),
                                ).animate(_animationController),
                                child: ImageOnline(snapshot: snapshot,),
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
