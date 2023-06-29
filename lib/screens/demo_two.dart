
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
import 'package:job/providers/animated.dart';
import 'package:job/screens/demo.dart';
import 'package:job/screens/image_offline.dart';
import 'package:job/screens/image_online.dart';
import 'package:job/screens/offline_items.dart';
import 'package:job/screens/online_items.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
  late Future<Koye> products = Network().getProducts(_scanBarcode, '',0,100000000,context);
  late Future<KalloImageSearch> imageSearch = Network().getProductsImage(_image, '', 0, 1000000, context);
  late AnimationController _animationController;
  Segment _selectedSegment = Segment.onlineShops;
  String _scanBarcode = 'Unknown';
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  late String _code = '';
  bool _firstOpen = false;
  String _image = '';
  Timer? _timer;
  int _start = 0;
  late double _startValue = 0;
  late double _endValue = 1;
  late double _endPoint;
  bool _hasCalculatedEndPoint = false;
  double _startPoint = 0;
  final startController = TextEditingController();
  final endController = TextEditingController();
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

  Future<void> _loadCountryCode() async {
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
          products = Network().getProducts(_scanBarcode, _code,0,100000000,context);
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
          imageSearch = Network().getProductsImage(_image, _code, 0, 100000000, context);
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

  _setStartValue() {
    try {
      String startValueText = startController.text.replaceAll(',', ''); // Remove commas from the text

      if (startValueText.isNotEmpty) {
        double startValue = double.parse(startValueText).roundToDouble();

        if (startValue <= double.parse(endController.text.replaceAll(',', '')).roundToDouble() &&
            startValue >= _startPoint &&
            double.parse(endController.text.replaceAll(',', '')).roundToDouble() >= _startPoint &&
            startValue <= _endPoint &&
            double.parse(endController.text.replaceAll(',', '')).roundToDouble() <= _endPoint) {
          setState(() {
            _startValue = startValue;
          });
        }
      }
      print("first text field: ${startController.text}");
    } catch (e) {
      print(e.toString());
    }
  }

  _setEndValue() {
    try {
      String endValueText = endController.text.replaceAll(',', ''); // Remove commas from the text

      if (endValueText.isNotEmpty) {
        double endValue = double.parse(endValueText).roundToDouble();

        if (double.parse(startController.text.replaceAll(',', '')).roundToDouble() <= endValue &&
            double.parse(startController.text.replaceAll(',', '')).roundToDouble() >= _startPoint &&
            endValue >= _startPoint &&
            double.parse(startController.text.replaceAll(',', '')).roundToDouble() <= _endPoint &&
            endValue <= _endPoint) {
          setState(() {
            _endValue = endValue;
          });
        }
      }
      print("Second text field: ${endController.text}");
    } catch (e) {
      print(e.toString());
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
    imageSearch = Network().getProductsImage(_image, _code, 0,  100000000, context);
    products = Network().getProducts(_scanBarcode, _code,0,100000000,context);
    products.then((value){
      print('the prducy issssssssssssssss ${value.data}');
      //snack(context, value.data.)
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    startController.addListener(_setStartValue);
    endController.addListener(_setEndValue);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
    startController.dispose();
    endController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final animatedProvider = Provider.of<AnimatedProvider>(context);
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
                          _hasCalculatedEndPoint = false;
                          _image = '';
                        });
                        _loadCountryCode();
                        scanBarcodeNormal().then((value){
                          setState(() {
                            products = Network().getProducts(_scanBarcode, _code,0,100000000,context);
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
                          _hasCalculatedEndPoint = false;
                        });
                        _loadCountryCode();
                        _pickImage().then((value){
                          setState(() {
                            imageSearch = Network().getProductsImage(_image, _code, 0, 100000000, context);
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
        body: _image == ''?FutureBuilder(
            future: products,
            builder: (context, snapshot){
              if(snapshot.hasError){
                return Center(
                  child:_start != 0?Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height*0.686,
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
                  ): Column(
                    children: [
                     // Text(snapshot.error.toString()),
                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            _hasCalculatedEndPoint = false;
                            _image = '';
                          });
                          _loadCountryCode();
                          scanBarcodeNormal().then((value){
                            setState(() {
                              products = Network().getProducts(_scanBarcode,_code,0,100000000,context);
                              _firstOpen = true;
                              _start = 7;
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

                      _firstOpen?
                      Text(AppLocalizations.of(context)!.noProductsAvailable,
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
                            _hasCalculatedEndPoint == false;
                          });
                          _loadCountryCode();
                          _pickImage().then((value){
                            setState(() {
                              imageSearch = Network().getProductsImage(_image,_code, 0, 100000000, context);
                              _firstOpen = true;
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
              if(snapshot.connectionState == ConnectionState.waiting){
                return Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height*0.685,
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

                    Expanded(
                      child: SizedBox(
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
                            AnimatedBuilder(
                              animation: animatedProvider,
                              builder: (context, child) {
                                return AnimatedPositioned(
                                  duration: Duration(milliseconds: 400),
                                  top: animatedProvider.myVariable ? 0 : -100, // Adjust the value to control the sliding distance
                                  left: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap:(){
                                            showModalBottomSheet(
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                ),
                                                builder: (context){
                                                  return StatefulBuilder(
                                                      builder: (BuildContext context, StateSetter setState) {

                                                        return Column(
                                                          children: [
                                                            Container(
                                                              height: 50,
                                                              // color: Colors.grey,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.only(
                                                                    topLeft: Radius.circular(25),
                                                                    topRight: Radius.circular(25),
                                                                  ),
                                                                  color: Colors.grey.shade200
                                                              ),
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                child: Row(
                                                                  children: [
                                                                    IconButton(
                                                                        onPressed: (){
                                                                          Navigator.pop(context);
                                                                          // setState((){
                                                                          //   _startValue = 0.0;
                                                                          //   _endValue = _endPoint;
                                                                          // });
                                                                        },
                                                                        icon: Icon(Icons.close)
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text('Sort',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 22
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 12.0),
                                                                    child: Text('Price:',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.w800,
                                                                          fontSize: 22
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text('Low to high',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 22
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 20,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 12.0),
                                                                    child: Text('Price:',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.w800,
                                                                          fontSize: 22
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text('High to low',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 22
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),

                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(right: 12.0),
                                                                    child: Text('Distance:',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.w800,
                                                                          fontSize: 22
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Text('Closest first',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 22
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                  );
                                                }
                                            );
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 80,
                                            padding: EdgeInsets.symmetric(horizontal: 14.0),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                color: Colors.grey.shade300
                                            ),
                                            child: Center(
                                              child: Text('Sort',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 14,
                                        ),
                                        GestureDetector(
                                          onTap:()async{
                                            if (!_hasCalculatedEndPoint) {
                                              List<Pproducts>? listProducts = snapshot.data!.data!.products;
                                              double totalPrices = 0;
                                              if (listProducts != null) {
                                                for (Pproducts product in listProducts) {
                                                  if (product.price != null) {
                                                    if (product.price is String) {
                                                      double? parsedPrice = double.tryParse(product.price as String);
                                                      if (parsedPrice != null) {
                                                        totalPrices += parsedPrice;
                                                      }
                                                    } else if (product.price is num) {
                                                      totalPrices += product.price as num;
                                                    }
                                                  }
                                                }
                                              }

                                              setState(() {
                                                _endPoint = totalPrices * 3;
                                                _hasCalculatedEndPoint = true; // Set the flag to true once _endPoint is calculated
                                              });
                                            }

                                            setState((){
                                              _startValue = 0.0;
                                              _endValue = _endPoint;
                                              startController.clear();
                                              endController.clear();
                                            });
                                            showModalBottomSheet(
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(25),
                                                    topRight: Radius.circular(25)
                                                  )
                                                ),
                                                builder: (context){
                                                  return StatefulBuilder(
                                                      builder: (BuildContext context, StateSetter setState) {

                                                        String displayValue;
                                                          //.floor is basically used to convert doubles to integers
                                                          displayValue = _startValue.floor().toString();
                                                        if (_startValue >= 1000) {
                                                          final formatter = NumberFormat("#,###");
                                                          displayValue = formatter.format(_startValue);
                                                        }
                                                        String displaySecondValue;
                                                        if (_endValue == _endValue.floor()) {
                                                          //.floor is basically used to convert doubles to integers
                                                          displaySecondValue = _endValue.floor().toString();
                                                        } else {
                                                          displaySecondValue = _endValue.toString();
                                                        }
                                                        if (_endValue >= 1000) {
                                                          final formatter = NumberFormat("#,###");
                                                          displaySecondValue = formatter.format(_endValue);
                                                        }


                                                        return Column(
                                                          children: [
                                                            Container(
                                                              height: 50,
                                                             // color: Colors.grey,
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(25),
                                                                  topRight: Radius.circular(25),
                                                                ),
                                                                color: Colors.grey.shade200
                                                              ),
                                                              width: MediaQuery.of(context).size.width,
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                                child: Row(
                                                                  children: [
                                                                    IconButton(
                                                                        onPressed: (){
                                                                          Navigator.pop(context);
                                                                          // setState((){
                                                                          //   _startValue = 0.0;
                                                                          //   _endValue = _endPoint;
                                                                          // });
                                                                        },
                                                                        icon: Icon(Icons.close)
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Text('Filter',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight.w600,
                                                                          fontSize: 22
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Text('Price',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 22
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 12,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  height: 60,
                                                                  width: 100,
                                                                  padding:EdgeInsets.symmetric(horizontal: 12),
                                                                  decoration:BoxDecoration(
                                                                      color: Colors.grey.shade400
                                                                  ),
                                                                  child: Center(child:  snapshot.data!.data!.products!.isNotEmpty?
                                                                            TextField(
                                                                            decoration: InputDecoration(
                                                                              prefix: Text("${snapshot.data!.data!.products![1].currency??''}  ",
                                                                                style: TextStyle(
                                                                                  fontSize: 18
                                                                                ),
                                                                              ),
                                                                            border: InputBorder.none,
                                                                                hintText: displayValue
                                                                            ),
                                                                            controller: startController,
                                                                              keyboardType: TextInputType.number,
                                                                            )
                                                                      : TextField(
                                                                    decoration: InputDecoration(
                                                                        border: InputBorder.none, hintText: displayValue
                                                                    ),
                                                                    controller: startController,
                                                                    keyboardType: TextInputType.number,
                                                                  )
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 14,
                                                                ),
                                                                Text('to'),
                                                                SizedBox(
                                                                  width: 14,
                                                                ),
                                                                Container(
                                                                  height: 60,
                                                                  width: 100,
                                                                  padding:EdgeInsets.symmetric(horizontal: 12),
                                                                  decoration:BoxDecoration(
                                                                      color: Colors.grey.shade400
                                                                  ),
                                                                  child: Center(
                                                                      child: snapshot.data!.data!.products!.isNotEmpty?
                                                                              TextField(
                                                                              decoration: InputDecoration(
                                                                                  prefix: Text("${snapshot.data!.data!.products![1].currency??''}  ",
                                                                                    style: TextStyle(
                                                                                      fontSize: 18
                                                                                    ),
                                                                                  ),
                                                                              border: InputBorder.none, hintText: displaySecondValue
                                                                              ),
                                                                              controller: endController,
                                                                                keyboardType: TextInputType.number,
                                                                              )
                                                                      : TextField(
                                                                    decoration: InputDecoration(
                                                                        border: InputBorder.none, hintText: displaySecondValue
                                                                    ),
                                                                    controller: endController,
                                                                        keyboardType: TextInputType.number,
                                                                  )),
                                                                ),
                                                              ],
                                                            ),
                                                            RangeSlider(
                                                              values: RangeValues(_startValue, _endValue),
                                                              min: _startPoint,
                                                              max: _endPoint,
                                                              activeColor:Color(0xff7f78d8),
                                                              // inactiveColor:Colors.grey.shade500,
                                                              onChanged: ( values) {
                                                                setState(() {
                                                                  _startValue = values.start;
                                                                  _endValue = values.end;
                                                                  startController.text = NumberFormat.decimalPattern().format(values.start.floor());
                                                                  endController.text = NumberFormat.decimalPattern().format(values.end.floor());

                                                                });
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Text('Select Merchants',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 22
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(left: 20.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Text('Select Categories',
                                                                    style: TextStyle(
                                                                        fontWeight: FontWeight.w800,
                                                                        fontSize: 22
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Container()
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 15.0),
                                                              child: SizedBox(
                                                                height: 40,
                                                                width: MediaQuery.of(context).size.width*0.5,
                                                                child: FloatingActionButton(
                                                                    onPressed: (){
                                                                      _loadCountryCode().then((value){
                                                                          products = Network().getProducts(_scanBarcode, _code, _startValue.toInt(), _endValue.toInt(),context);

                                                                      });
                                                                    },
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                                                                    ),
                                                                    backgroundColor:Color(0xff7F78D8),
                                                                    child: Text('Show Results')
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                  );
                                                }
                                            );
                                          },
                                          child: Container(
                                            height: 40,
                                            width: 80,
                                            padding: EdgeInsets.symmetric(horizontal: 14.0),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(25),
                                                color: Colors.grey.shade300
                                            ),
                                            child: Center(
                                              child: Text('Filter',
                                                style: TextStyle(

                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
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
                return _start != 0?Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height*0.686,
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
                ):Center(
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
                              products = Network().getProducts(_scanBarcode,_code, 0, 100000000,context);
                              _image = '';
                              _hasCalculatedEndPoint = false;
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
                            _hasCalculatedEndPoint = false;
                          });
                          _loadCountryCode();
                          _pickImage().then((value){
                            setState(() {
                              imageSearch = Network().getProductsImage(_image,_code, 0, 100000000, context);
                              _firstOpen = true;
                              _start = 10;
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

                      _firstOpen ?  Text(AppLocalizations.of(context)!.noProductsAvailable,
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
                      )
                     // Text('Captured image path: $_image', style: TextStyle(color: Colors.black),)
                    ],
                  ),
                );
              }
              if(snapshot.connectionState == ConnectionState.waiting){
                return Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height*0.686,
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
                    Expanded(
                      child: Container(
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
                            AnimatedPositioned(
                              duration: Duration(milliseconds: 400),
                              top: animatedProvider.myVariable ? 0 : -100, // Adjust the value to control the sliding distance
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap:(){
                                        showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                            ),
                                            builder: (context){
                                              return StatefulBuilder(
                                                  builder: (BuildContext context, StateSetter setState) {

                                                    return Column(
                                                      children: [
                                                        Container(
                                                          height: 50,
                                                          // color: Colors.grey,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(25),
                                                                topRight: Radius.circular(25),
                                                              ),
                                                              color: Colors.grey.shade200
                                                          ),
                                                          width: MediaQuery.of(context).size.width,
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                            child: Row(
                                                              children: [
                                                                IconButton(
                                                                    onPressed: (){
                                                                      Navigator.pop(context);
                                                                      // setState((){
                                                                      //   _startValue = 0.0;
                                                                      //   _endValue = _endPoint;
                                                                      // });
                                                                    },
                                                                    icon: Icon(Icons.close)
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text('Sort',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 22
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 20.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(right: 12.0),
                                                                child: Text('Price:',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w800,
                                                                      fontSize: 22
                                                                  ),
                                                                ),
                                                              ),
                                                              Text('Low to high',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w800,
                                                                    fontSize: 22
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 20.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(right: 12.0),
                                                                child: Text('Price:',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w800,
                                                                      fontSize: 22
                                                                  ),
                                                                ),
                                                              ),
                                                              Text('High to low',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w800,
                                                                    fontSize: 22
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),

                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 20.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(right: 12.0),
                                                                child: Text('Distance:',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w800,
                                                                      fontSize: 22
                                                                  ),
                                                                ),
                                                              ),
                                                              Text('Closest first',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w800,
                                                                    fontSize: 22
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              );
                                            }
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 80,
                                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25),
                                            color: Colors.grey.shade300
                                        ),
                                        child: Center(
                                          child: Text('Sort',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 14,
                                    ),
                                    GestureDetector(
                                      onTap:(){
                                        if (!_hasCalculatedEndPoint) {
                                          List<Products>? listProducts = snapshot.data!.data!.products;
                                          double totalPrices = 0;
                                          if (listProducts != null) {
                                            for (Products product in listProducts) {
                                              if (product.price != null) {
                                                if (product.price is String) {
                                                  double? parsedPrice = double.tryParse(product.price as String);
                                                  if (parsedPrice != null) {
                                                    totalPrices += parsedPrice;
                                                  }
                                                } else if (product.price is num) {
                                                  totalPrices += product.price as num;
                                                }
                                              }
                                            }
                                          }

                                          setState(() {
                                            _endPoint = totalPrices * 3;
                                            _hasCalculatedEndPoint = true; // Set the flag to true once _endPoint is calculated
                                          });
                                        }

                                        setState((){
                                          _startValue = 0.0;
                                          _endValue = _endPoint;
                                          startController.clear();
                                          endController.clear();
                                        });
                                        showModalBottomSheet(
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                topLeft: Radius.circular(20)
                                              )
                                            ),
                                            builder: (context){
                                              return StatefulBuilder(
                                                  builder: (BuildContext context, StateSetter setState) {
                                                    String displayValue;
                                                      //.floor is basically used to convert doubles to integers
                                                      displayValue = _startValue.floor().toString();
                                                    if (_startValue >= 1000) {
                                                      final formatter = NumberFormat("#,###");
                                                      displayValue = formatter.format(_startValue);
                                                    }
                                                    String displaySecondValue;
                                                    if (_endValue == _endValue.floor()) {
                                                      //.floor is basically used to convert doubles to integers
                                                      displaySecondValue = _endValue.floor().toString();
                                                    } else {
                                                      displaySecondValue = _endValue.toString();
                                                    }
                                                    if (_endValue >= 1000) {
                                                      final formatter = NumberFormat("#,###");
                                                      displaySecondValue = formatter.format(_endValue);
                                                    }
                                                    return Column(
                                                      children: [
                                                        Container(
                                                          height: 50,
                                                          // color: Colors.grey,
                                                          decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.only(
                                                                topLeft: Radius.circular(25),
                                                                topRight: Radius.circular(25),
                                                              ),
                                                              color: Colors.grey.shade200
                                                          ),
                                                          width: MediaQuery.of(context).size.width,
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                            child: Row(
                                                              children: [
                                                                IconButton(
                                                                    onPressed: (){
                                                                      Navigator.pop(context);
                                                                      // setState((){
                                                                      //   _startValue = 0.0;
                                                                      //   _endValue = _endPoint;
                                                                      // });
                                                                    },
                                                                    icon: Icon(Icons.close)
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text('Filter',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 22
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 20.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text('Price',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w800,
                                                                    fontSize: 22
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                              height: 70,
                                                              width: 130,
                                                              padding:EdgeInsets.symmetric(horizontal: 12),
                                                              decoration:BoxDecoration(
                                                                  color: Colors.grey.shade400
                                                              ),
                                                              child: Center(child:  snapshot.data!.data!.products!.isNotEmpty?
                                                              TextField(
                                                                decoration: InputDecoration(
                                                                    prefix: Text("${snapshot.data!.data!.products![0].currency??''}  ",
                                                                      style: TextStyle(
                                                                          fontSize: 18
                                                                      ),
                                                                    ),
                                                                    border: InputBorder.none,
                                                                    hintText: displayValue
                                                                ),
                                                                controller: startController,
                                                                keyboardType: TextInputType.number,
                                                              )
                                                                  : TextField(
                                                                decoration: InputDecoration(
                                                                    border: InputBorder.none, hintText: displayValue
                                                                ),
                                                                controller: startController,
                                                                keyboardType: TextInputType.number,
                                                              )
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 14,
                                                            ),
                                                            Text('to'),
                                                            SizedBox(
                                                              width: 14,
                                                            ),
                                                            Container(
                                                              height: 70,
                                                              width: 130,
                                                              padding:EdgeInsets.symmetric(horizontal: 12),
                                                              decoration:BoxDecoration(
                                                                  color: Colors.grey.shade400
                                                              ),
                                                              child: Center(
                                                                  child: snapshot.data!.data!.products!.isNotEmpty?
                                                                  TextField(
                                                                    decoration: InputDecoration(
                                                                        prefix: Text("${snapshot.data!.data!.products![0].currency??''}  ",
                                                                          style: TextStyle(
                                                                              fontSize: 18
                                                                          ),
                                                                        ),
                                                                        border: InputBorder.none, hintText: displaySecondValue
                                                                    ),
                                                                    controller: endController,
                                                                    keyboardType: TextInputType.number,
                                                                  )
                                                                      : TextField(
                                                                    decoration: InputDecoration(
                                                                        border: InputBorder.none, hintText: displaySecondValue
                                                                    ),
                                                                    controller: endController,
                                                                    keyboardType: TextInputType.number,
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                        RangeSlider(
                                                          values: RangeValues(_startValue, _endValue),
                                                          min: _startPoint,
                                                          max: _endPoint,
                                                          activeColor:Color(0xff7f78d8),
                                                          // inactiveColor:Colors.grey.shade500,
                                                          onChanged: ( values) {
                                                            setState(() {
                                                              _startValue = values.start;
                                                              _endValue = values.end;
                                                              startController.text = NumberFormat.decimalPattern().format(values.start.floor());
                                                              endController.text = NumberFormat.decimalPattern().format(values.end.floor());

                                                            });
                                                          },
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 20.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text('Select Merchants',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w800,
                                                                    fontSize: 22
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 20.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text('Select Categories',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w800,
                                                                    fontSize: 22
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                            child: Container()
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 15.0),
                                                          child: SizedBox(
                                                            height: 40,
                                                            width: MediaQuery.of(context).size.width*0.5,
                                                            child: FloatingActionButton(
                                                                onPressed: (){
                                                                  _loadCountryCode().then((value){
                                                                    setState((){
                                                                      imageSearch = Network().getProductsImage(_image, _code, _startValue.toInt(), _endValue.toInt(), context);
                                                                    });
                                                                  });
                                                                },
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                                                                ),
                                                                backgroundColor:Color(0xff7F78D8),
                                                                child: Text('Show Results')
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              );
                                            }
                                        );
                                      },
                                      child: Container(
                                        height: 40,
                                        width: 80,
                                        padding: EdgeInsets.symmetric(horizontal: 14.0),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(25),
                                            color: Colors.grey.shade300
                                        ),
                                        child: Center(
                                          child: Text('Filter',
                                            style: TextStyle(

                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
