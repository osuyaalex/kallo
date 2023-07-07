import 'dart:convert';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:job/network/json.dart';
import 'package:job/network/network.dart';
import 'package:job/providers/animated.dart';
import 'package:job/screens/demo_two.dart';
import 'package:job/screens/offline_items.dart';
import 'package:job/screens/online_items.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';




class BarcodeSearch extends StatefulWidget {

  const BarcodeSearch({Key? key}) : super(key: key);

  @override
  State<BarcodeSearch> createState() => _BarcodeSearchState();
}

enum Segment { shopsNearMe, onlineShops }
class _BarcodeSearchState extends State<BarcodeSearch>with SingleTickerProviderStateMixin{
  late Future<Koye> products = Network().getProducts(_scanBarcode, '',0,100000000, null,context);
  late AnimationController _animationController;
  Segment _selectedSegment = Segment.onlineShops;
  String _scanBarcode = 'Unknown';
  GlobalKey<FormState> _key = GlobalKey<FormState>();
  late String _code = '';

  Timer? _timer;
  int _start = 0;
  late double _startValue = 0;
  late double _endValue = 1;
  late double _endPoint;
  bool _hasCalculatedEndPoint = false;
  double _startPoint = 0;
  final startController = TextEditingController();
  final endController = TextEditingController();
  bool _isSliderInteracted = false;
  int _selectedContainerIndex = -1;
  bool _seeMainCategory = false;
  bool _seeProductCategory = false;
  late AsyncSnapshot _seeSnapshot;
  List _category= [];
  dynamic _productCat;
  int _selectedIndex = -1;
  String? _catName;
  int _selectedMainIndex = -1;
  String? _magnitude;
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
    setState(() {
      _hasCalculatedEndPoint = false;
    });
      _loadCountryCode();
      scanBarcodeNormal().then((value)async{
        setState(() {
          products = Network().getProducts(_scanBarcode, _code,0,100000000,null,context);
          _start = 7;
        });
        _startTimer();
      });
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
  loadCategoryJson() async {
    String data = await DefaultAssetBundle.of(context).loadString(
        "asset/model/categories.json"); //for calling local json
    final jsonCategoryResult = jsonDecode(data);
    //print(jsonCategoryResult);
    return jsonCategoryResult;
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    _shiftBarCode();
    _loadCountryCode();
    loadCategoryJson();
    products = Network().getProducts(_scanBarcode, _code,0,100000000, null,context);
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
                height: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: ()async{
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setBool('isSearchBar', true);
                      Navigator.of(context).pushReplacement(PageTransition(
                        child: const Dems(),
                        type: PageTransitionType.fade,
                        childCurrent: widget,
                        duration: const Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                      )
                      );
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
                          _selectedContainerIndex = -1;
                          _selectedMainIndex = -1;
                          _selectedIndex = -1;
                        });
                        _loadCountryCode();
                        scanBarcodeNormal().then((value){
                          setState(() {
                            products = Network().getProducts(_scanBarcode, _code,0,100000000,null,context);
                            _start = 7;
                          });
                          _startTimer();
                        });
                      },
                      icon: SvgPicture.asset('asset/barcode-scan-svgrepo-com (1).svg')
                  ),
                  InkWell(
                      onTap: ()async{
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        prefs.setBool('isLaunchCamera', true);
                        Navigator.of(context).pushReplacement(PageTransition(
                          child: const Dems(),
                          type: PageTransitionType.fade,
                          childCurrent: widget,
                          duration: const Duration(milliseconds: 100),
                          reverseDuration: const Duration(milliseconds: 100),
                        )
                        );
                      },
                      child: Icon(Icons.camera_alt_outlined, color: Color(0xff7F78D8),size: 25,)
                  )
                ],
              ),
            ],
          ) ,
        ),
        body: FutureBuilder(
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
                  ):Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.1,
                      ),
                      Text(AppLocalizations.of(context)!.noProductsAvailable,
                      style: TextStyle(
                        fontSize: 16
                      ),
                      ),
                      SvgPicture.asset('asset/No Results Found.svg')
                    ],
                  )
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
                List<Pproducts>? offline = snapshot.data!.data!.products?.where((element) => element.merchantType == "offline").toList();
                List<Pproducts>? online = snapshot.data!.data!.products?.where((element) => element.merchantType == "online").toList();

                return Column(
                  children: [
                    online!.isNotEmpty && offline!.isNotEmpty? AnimatedContainer(
                        curve: Curves.ease,
                        duration: Duration(milliseconds: 400),
                        height: animatedProvider.myVariable ? 70 : 0,
                        child: Container(
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
                        )
                    ):Container(),
                    AnimatedBuilder(
                        animation: animatedProvider,
                        builder: (context, child) {
                          return AnimatedContainer(
                            curve: Curves.ease,
                            duration: Duration(milliseconds: 400),
                            height: animatedProvider.myVariable ? 50 : 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap:(){
                                      showModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(25),
                                              topRight: Radius.circular(25),
                                            ),
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
                                                        height: 25,
                                                      ),
                                                      GestureDetector(
                                                        onTap:(){
                                                          setState((){
                                                            _selectedContainerIndex =0;
                                                            _magnitude = null;
                                                          });
                                                        },
                                                        child: Container(
                                                          height:50,
                                                          width:MediaQuery.of(context).size.width*0.85,
                                                          decoration:BoxDecoration(
                                                              color: _selectedContainerIndex == 0? Color(0xff161b22):Colors.grey.shade300,
                                                              borderRadius: BorderRadius.circular(18)
                                                          ),
                                                          child: Padding(
                                                              padding: const EdgeInsets.only(left: 20.0),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Text('Most Relevant',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 17,
                                                                      color: _selectedContainerIndex == 0?Colors.white:Colors.black,
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(height: 18,),
                                                      GestureDetector(
                                                        onTap:(){
                                                          setState((){
                                                            _selectedContainerIndex = 1;
                                                            _magnitude = 'asc';
                                                          });
                                                        },
                                                        child: Container(
                                                          height:50,
                                                          width:MediaQuery.of(context).size.width*0.85,
                                                          decoration:BoxDecoration(
                                                              color: _selectedContainerIndex == 1 ?Color(0xff161b22):Colors.grey.shade300,
                                                              borderRadius: BorderRadius.circular(18)
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 20.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 12.0),
                                                                  child: Text('Price:',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 17,
                                                                      color: _selectedContainerIndex == 1?Colors.white:Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Text('Low to high',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 17,
                                                                    color: _selectedContainerIndex == 1?Colors.white:Colors.black,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 18,
                                                      ),
                                                      GestureDetector(
                                                        onTap:(){
                                                          setState((){
                                                            _selectedContainerIndex = 2;
                                                            _magnitude = 'desc';
                                                          });

                                                        },
                                                        child: Container(
                                                          height:50,
                                                          width:MediaQuery.of(context).size.width*0.85,
                                                          decoration:BoxDecoration(
                                                              color: _selectedContainerIndex == 2?Color(0xff161b22):Colors.grey.shade300,
                                                              borderRadius: BorderRadius.circular(18)
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 20.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(right: 12.0),
                                                                  child: Text('Price:',
                                                                    style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 17,
                                                                      color: _selectedContainerIndex == 2?Colors.white:Colors.black,

                                                                    ),
                                                                  ),
                                                                ),
                                                                Text('High to low',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 17,
                                                                    color: _selectedContainerIndex == 2?Colors.white:Colors.black,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 18,
                                                      ),
                                                      Container(
                                                        height:45,
                                                        width:MediaQuery.of(context).size.width*0.85,
                                                        decoration:BoxDecoration(
                                                            color: Colors.grey.shade300,
                                                            borderRadius: BorderRadius.circular(18)
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 20.0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.only(right: 12.0),
                                                                child: Text('Distance:',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight.w600,
                                                                      fontSize: 17
                                                                  ),
                                                                ),
                                                              ),
                                                              Text('Closest first',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 17
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 30,
                                                      ),
                                                      Container(
                                                        height: 40,
                                                        width:MediaQuery.of(context).size.width * 0.5,
                                                        child: FloatingActionButton(
                                                            onPressed: (){
                                                              _loadCountryCode().then((value){
                                                                products = Network().getSortedProducts(_scanBarcode, _code, _magnitude,null,null,_catName, context);
                                                              });
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8.0), // Adjust the border radius as needed
                                                            ),
                                                            backgroundColor:Color(0xff7F78D8),
                                                            child: Text('Show Results',
                                                              style: TextStyle(
                                                                  fontSize: 18
                                                              ),
                                                            )
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
                                          color: Colors.grey.shade200
                                      ),
                                      child: Center(
                                        child: Text('Sort',
                                          style: TextStyle(
                                              fontSize: 16.5,
                                              color: Color(0xff7f78d8),
                                              fontWeight: FontWeight.w400
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
                                        _isSliderInteracted = false;
                                        _seeMainCategory = false;
                                        _seeProductCategory = false;
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
                                                  return Stack(
                                                    children: [
                                                      _seeMainCategory == false?Column(
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
                                                                      fontWeight: FontWeight.w600,
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
                                                                    color: Colors.grey.shade400,
                                                                    borderRadius: BorderRadius.circular(12)
                                                                ),
                                                                child: Center(child:  snapshot.data!.data!.products!.isNotEmpty?
                                                                TextField(
                                                                  enabled: _isSliderInteracted,
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
                                                                  enabled: _isSliderInteracted,
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
                                                                    color: Colors.grey.shade400,
                                                                    borderRadius: BorderRadius.circular(12)
                                                                ),
                                                                child: Center(
                                                                    child: snapshot.data!.data!.products!.isNotEmpty?
                                                                    TextField(
                                                                      enabled: _isSliderInteracted,
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
                                                                      enabled: _isSliderInteracted,
                                                                      decoration: InputDecoration(
                                                                          border: InputBorder.none, hintText: displaySecondValue
                                                                      ),
                                                                      controller: endController,
                                                                      keyboardType: TextInputType.number,
                                                                    )),
                                                              ),
                                                            ],
                                                          ),
                                                          SliderTheme(
                                                            data: SliderThemeData(
                                                                trackHeight: 1.5
                                                            ),
                                                            child: RangeSlider(
                                                              values: RangeValues(_startValue, _endValue),
                                                              min: _startPoint,
                                                              max: _endPoint,
                                                              activeColor:Color(0xff7f78d8),
                                                              // inactiveColor:Colors.grey.shade500,
                                                              onChanged: ( values) {
                                                                setState(() {
                                                                  _startValue = values.start;
                                                                  _endValue = values.end;
                                                                  _isSliderInteracted = true;
                                                                  startController.text = NumberFormat.decimalPattern().format(values.start.floor());
                                                                  endController.text = NumberFormat.decimalPattern().format(values.end.floor());

                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          GestureDetector(
                                                            onTap:(){
                                                              setState((){
                                                                _seeMainCategory = true;
                                                              });
                                                            },
                                                            child: Container(
                                                              height:50,
                                                              width: MediaQuery.of(context).size.width*0.95,
                                                              decoration:BoxDecoration(
                                                                borderRadius: BorderRadius.circular(24),
                                                                color: Color(0xff161b22),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:MainAxisAlignment.spaceAround,
                                                                children: [
                                                                  Row(
                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                    children: [
                                                                      Text('Select Categories',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.w600,
                                                                            color: Colors.white,
                                                                            fontSize: 22
                                                                        ),
                                                                      ),
                                                                      SizedBox(width: 15,),
                                                                      _catName == null ?
                                                                      Text('All categories',
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.white
                                                                        ),
                                                                      ):Text(_catName!,
                                                                        style: TextStyle(
                                                                            fontSize: 13,
                                                                            color: Colors.white
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                  Icon(Icons.arrow_forward_ios_sharp, color: Colors.white,)
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              child: Container()
                                                          ),

                                                        ],
                                                      ):_seeProductCategory== false?Column(
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
                                                                        setState((){
                                                                          _seeMainCategory = false;
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.arrow_back)
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text('Categories',
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
                                                            height: 10,
                                                          ),
                                                          FutureBuilder(
                                                              future: loadCategoryJson(),
                                                              builder: (context, snapshot){
                                                                if(snapshot.hasData){
                                                                  _seeSnapshot = snapshot;
                                                                  _category = _seeSnapshot.data;
                                                                  return Expanded(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(bottom: 70.0),
                                                                      child: ListView.builder(
                                                                        itemCount: _category.length + 1,
                                                                        itemBuilder: (context, index) {
                                                                          if (index == 0) {
                                                                            // Render the extra widget as the first item
                                                                            return Column(
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap:(){
                                                                                    setState((){
                                                                                      _selectedMainIndex = 0;
                                                                                      _catName = null;
                                                                                    });
                                                                                  },
                                                                                  child: Container(
                                                                                    height: 40,
                                                                                    width: MediaQuery.of(context).size.width * 0.8,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(19),
                                                                                      color: _selectedMainIndex == 0 ? Color(0xff161b22) : Colors.grey.shade200,
                                                                                    ),
                                                                                    child: Center(child: Text('All Categories',
                                                                                      style: TextStyle(
                                                                                        color:_selectedMainIndex == 0 ? Colors.white : Colors.black,
                                                                                      ),
                                                                                    )
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12,)
                                                                              ],
                                                                            );
                                                                          } else {
                                                                            // Render the regular items from the category list, subtract 1 from index
                                                                            return Column(
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      _seeProductCategory = true;
                                                                                      _productCat = _category[index - 1];
                                                                                      _selectedMainIndex = index;
                                                                                    });
                                                                                  },
                                                                                  child: Container(
                                                                                    height: 40,
                                                                                    width: MediaQuery.of(context).size.width * 0.8,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(19),
                                                                                      color: _selectedMainIndex == index ? Color(0xff161b22) : Colors.grey.shade200,
                                                                                    ),
                                                                                    child: Center(child: Text(_category[index - 1]['master_category'],
                                                                                      style: TextStyle(
                                                                                        color: _selectedMainIndex == index ? Colors.white : Colors.black,
                                                                                      ),
                                                                                    )
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 12,)
                                                                              ],
                                                                            );
                                                                          }
                                                                        },
                                                                      )
                                                                    ),
                                                                  );
                                                                }else{
                                                                  return CircularProgressIndicator();
                                                                }
                                                              }
                                                          ),
                                                        ],
                                                      ):Column(
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
                                                                        setState((){
                                                                          _seeProductCategory = false;
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.arrow_back)
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text('Product Category',
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
                                                            height: 10,
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 70.0),
                                                              child: ListView.builder(
                                                                  itemCount: _productCat['product_categories'].length,
                                                                  itemBuilder: (context, index){
                                                                    return  Column(
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:(){
                                                                            setState(() {
                                                                              // Toggle the selected state
                                                                              _selectedIndex = (_selectedIndex == index) ? -1 : index;
                                                                              _catName = _productCat['product_categories'][index]['name'];
                                                                            });
                                                                          },
                                                                          child: Container(
                                                                              height: 40,
                                                                              width: MediaQuery.of(context).size.width*0.8,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(19),
                                                                                  color: (_selectedIndex == index) ? Color(0xff161b22) : Colors.grey.shade200
                                                                              ),
                                                                              child: Center(
                                                                                  child: Text(_productCat['product_categories'][index]['name'],
                                                                                    style: TextStyle(
                                                                                        color: (_selectedIndex == index) ? Colors.white : Colors.black
                                                                                    ),
                                                                                  )
                                                                              )
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8,)
                                                                      ],
                                                                    );

                                                                  }
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Positioned(
                                                        bottom: 10,
                                                        left:70,
                                                        right: 70,
                                                        child: SizedBox(
                                                          height: 40,
                                                          width: MediaQuery.of(context).size.width*0.5,
                                                          child: FloatingActionButton(
                                                              onPressed: (){
                                                                setState(() {
                                                                  _selectedContainerIndex = -1;
                                                                });
                                                                _loadCountryCode().then((value){
                                                                  products = Network().getProducts(_scanBarcode, _code, _startValue.toInt(), _endValue.toInt(),_catName,context);

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
                                      width: 90,
                                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          color: Colors.grey.shade200
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Filter',
                                            style: TextStyle(
                                                fontSize: 16.5,
                                                color: Color(0xff7f78d8),
                                                fontWeight: FontWeight.w400
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 6.0),
                                            child: SvgPicture.asset('asset/filter-svgrepo-com.svg', height: 18,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14,),
                                  GestureDetector(
                                    onTap:(){

                                      setState((){
                                        _seeProductCategory = false;
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
                                                  return  Stack(
                                                    children: [
                                                      _seeProductCategory== false?Column(
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
                                                                        setState((){
                                                                          _seeMainCategory = false;
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.arrow_back)
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text('Categories',
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
                                                            height: 10,
                                                          ),
                                                          FutureBuilder(
                                                              future: loadCategoryJson(),
                                                              builder: (context, snapshot){
                                                                if(snapshot.hasData){
                                                                  _seeSnapshot = snapshot;
                                                                  _category = _seeSnapshot.data;
                                                                  return Expanded(
                                                                    child: Padding(
                                                                        padding: const EdgeInsets.only(bottom: 70.0),
                                                                        child: ListView.builder(
                                                                          itemCount: _category.length + 1,
                                                                          itemBuilder: (context, index) {
                                                                            if (index == 0) {
                                                                              // Render the extra widget as the first item
                                                                              return Column(
                                                                                children: [
                                                                                  GestureDetector(
                                                                                    onTap:(){
                                                                                      setState((){
                                                                                        _selectedMainIndex = 0;
                                                                                        _catName = null;
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 40,
                                                                                      width: MediaQuery.of(context).size.width * 0.8,
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(19),
                                                                                        color: _selectedMainIndex == 0 ? Color(0xff161b22) : Colors.grey.shade200,
                                                                                      ),
                                                                                      child: Center(child: Text('All Categories',
                                                                                        style: TextStyle(
                                                                                          color:_selectedMainIndex == 0 ? Colors.white : Colors.black,
                                                                                        ),
                                                                                      )
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 12,)
                                                                                ],
                                                                              );
                                                                            } else {
                                                                              // Render the regular items from the category list, subtract 1 from index
                                                                              return Column(
                                                                                children: [
                                                                                  GestureDetector(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        _seeProductCategory = true;
                                                                                        _productCat = _category[index - 1];
                                                                                        _selectedMainIndex = index;
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 40,
                                                                                      width: MediaQuery.of(context).size.width * 0.8,
                                                                                      decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius.circular(19),
                                                                                        color: _selectedMainIndex == index ? Color(0xff161b22) : Colors.grey.shade200,
                                                                                      ),
                                                                                      child: Center(child: Text(_category[index - 1]['master_category'],
                                                                                        style: TextStyle(
                                                                                          color: _selectedMainIndex == index ? Colors.white : Colors.black,
                                                                                        ),
                                                                                      )
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 12,)
                                                                                ],
                                                                              );
                                                                            }
                                                                          },
                                                                        )
                                                                    ),
                                                                  );
                                                                }else{
                                                                  return CircularProgressIndicator();
                                                                }
                                                              }
                                                          ),
                                                        ],
                                                      ):Column(
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
                                                                        setState((){
                                                                          _seeProductCategory = false;
                                                                        });
                                                                      },
                                                                      icon: Icon(Icons.arrow_back)
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text('Product Category',
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
                                                            height: 10,
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(bottom: 70.0),
                                                              child: ListView.builder(
                                                                  itemCount: _productCat['product_categories'].length,
                                                                  itemBuilder: (context, index){
                                                                    return  Column(
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:(){
                                                                            setState(() {
                                                                              // Toggle the selected state
                                                                              _selectedIndex = (_selectedIndex == index) ? -1 : index;
                                                                              _catName = _productCat['product_categories'][index]['name'];
                                                                            });
                                                                          },
                                                                          child: Container(
                                                                              height: 40,
                                                                              width: MediaQuery.of(context).size.width*0.8,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(19),
                                                                                  color: (_selectedIndex == index) ? Color(0xff161b22) : Colors.grey.shade200
                                                                              ),
                                                                              child: Center(
                                                                                  child: Text(_productCat['product_categories'][index]['name'],
                                                                                    style: TextStyle(
                                                                                        color: (_selectedIndex == index) ? Colors.white : Colors.black
                                                                                    ),
                                                                                  )
                                                                              )
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8,)
                                                                      ],
                                                                    );

                                                                  }
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Positioned(
                                                        bottom: 10,
                                                        left:70,
                                                        right: 70,
                                                        child: SizedBox(
                                                          height: 40,
                                                          width: MediaQuery.of(context).size.width*0.5,
                                                          child: FloatingActionButton(
                                                              onPressed: (){
                                                                _loadCountryCode().then((value){
                                                                  products = Network().getProducts(_scanBarcode, _code, null, null,_catName,context);

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
                                      width: 90,
                                      padding: EdgeInsets.symmetric(horizontal: 14.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          color: Colors.grey.shade200
                                      ),
                                      child: Center(
                                        child: Text('Category',
                                          style: TextStyle(
                                              fontSize: 16.5,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w400
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
                    Expanded(
                      child:online.isNotEmpty && offline!.isNotEmpty? SizedBox(
                          width: double.infinity,
                          child:Stack(
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
                          )
                      ):Online(snapshot: snapshot),
                    ),
                  ],
                );
              }else{
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black,),
                );
              }
            }
        )
      ),
    );
  }

}
