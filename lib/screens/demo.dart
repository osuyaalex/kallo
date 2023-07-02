import 'dart:async';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import '../network/json.dart';
import '../network/network.dart';
import '../providers/animated.dart';
import 'offline_items.dart';
import 'online_items.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

enum Shops { shopsNearMe, onlineShops }
class _DemoScreenState extends State<DemoScreen>with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  Shops _selectedShop = Shops.onlineShops;
  late Future<Koye> productName = Network().getProductsName(_name, _code,0,100000000, context);
  late FloatingSearchBarController controller;
  List<String>? _filteredSearchHistory;
  String _name = '';
  late String _code = '';
  bool _firstpage = true;
  List<String> _suggestion = [];
  bool _type = false;
  String? _currentLocale;
  String? _timeTakenText;
  Timer? _timer;
  int _start = 5;
  late double _startValue = 0;
  late double _endValue = 1;
  late double _endPoint;
  bool _hasCalculatedEndPoint = false;
  double _startPoint = 0;
  final startController = TextEditingController();
  final endController = TextEditingController();
  bool _slideInteract = false;

  void _switchToShop(Shops segment) {
    if (_selectedShop == segment) return;

    setState(() {
      _selectedShop = segment;
    });

    if (_selectedShop == Shops.onlineShops) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  Future<List<String>> _getRecentSearchesLike(String query) async {
    if (_filteredSearchHistory == null) {
      final pref = await SharedPreferences.getInstance();
      final allSearches = pref.getStringList("recentSearches");
      return allSearches
          ?.where((search) => search.startsWith(query))
          .toList() ??
          [];
    } else {
      return _filteredSearchHistory!
          .where((search) => search.startsWith(query))
          .toList();
    }
  }

  Future<void> _saveToRecentSearches(String searchText) async {
    final pref = await SharedPreferences.getInstance();

    Set<String> allSearches =
        pref.getStringList("recentSearches")?.toSet() ?? {};

    allSearches = {searchText, ...allSearches};
    pref.setStringList("recentSearches", allSearches.toList());
    _filteredSearchHistory = allSearches.toList();
  }

  Future<List<String>> _getAllRecentSearches() async {
    if (_filteredSearchHistory == null) {
      final pref = await SharedPreferences.getInstance();
      return pref.getStringList("recentSearches") ?? [];
    } else {
      return _filteredSearchHistory!;
    }
  }

  Future<void> putSearchTermFirst(String term) async {
    List<String> searches = await _getAllRecentSearches();
    searches.removeWhere((t) => t == term);
    searches.insert(0, term);
    final pref = await SharedPreferences.getInstance();
    pref.setStringList("recentSearches", searches);
    _filteredSearchHistory = searches;
  }


  @override
  void didChangeDependencies() {
    _getAllRecentSearches().then((value) {
      setState(() {
        _filteredSearchHistory = value;

      });
    });

    super.didChangeDependencies();
  }

  Future<void> _loadCountryCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('countryCode');
    setState(() {
      _code = savedCode??'NG';
    });
  }

  Future<void> _getCurrentLocale() async {
    try {
      final currentLocale = await Devicelocale.currentLocale;
      print((currentLocale != null)
          ? currentLocale
          : "Unable to get currentLocale");
      // Extract the language code
      final languageCode = currentLocale?.substring(0, 2);
      setState(() {
        _currentLocale = languageCode;
      });
      print(_currentLocale);
    } on PlatformException {
      print("Error obtaining current locale");
    }
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

  _fetchSearchSuggestions(String query){
    final stopwatch = Stopwatch();
    stopwatch.start();
    Network().getSearchSuggestions(query, _currentLocale!)
        .then((value){
         if(mounted){
           setState(() {
             _suggestion = value;
           });
           stopwatch.stop();
           final timeTaken = stopwatch.elapsedMilliseconds;
           setState(() {
             _timeTakenText = timeTaken.toString();
           });
         }
    });
  }
  RichText buildSuggestionTile(String suggestion, String query) {
    final lowercaseSuggestion = suggestion.toLowerCase();
    final lowercaseQuery = query.toLowerCase();

    final highlightedLetters = <int>{};
    for (var i = 0; i < lowercaseSuggestion.length; i++) {
      if (i < lowercaseQuery.length && lowercaseSuggestion[i] == lowercaseQuery[i]) {
        highlightedLetters.add(i);
      }
    }

    return RichText(
      text: TextSpan(
        children: [
          for (var i = 0; i < suggestion.length; i++)
            TextSpan(
              text: suggestion[i],
              style: highlightedLetters.contains(i)
                  ? TextStyle(

                color: Colors.black,
              )
                  : TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              )
            ),
        ],
      ),
    );
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
  void initState() {
    // TODO: implement initState
    productName = Network().getProductsName(_name, _code,0,100000000, context);
    controller = FloatingSearchBarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadCountryCode();
    _getCurrentLocale();
    super.initState();
    startController.addListener(_setStartValue);
    endController.addListener(_setEndValue);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    _animationController.dispose();
    startController.dispose();
    endController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final animatedProvider = Provider.of<AnimatedProvider>(context);

    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FloatingSearchBar(
        backgroundColor: Color(0xfff2f2fb),
          elevation: 1,
          borderRadius: BorderRadius.circular(12),
          hint: AppLocalizations.of(context)!.searchForProducts,
          controller: controller,
          openAxisAlignment: 0.0,
          axisAlignment: isPortrait ? 0.0:-1.0,
          scrollPadding: const EdgeInsets.only(top: 12, bottom: 20),
          transitionCurve: Curves.easeInOut,
          transitionDuration: const Duration(milliseconds: 800),
          transition: CircularFloatingSearchBarTransition(),
          debounceDelay: const Duration(milliseconds: 500),
          body:  Padding(
            padding: const EdgeInsets.fromLTRB(0,100,0,10),
            child: FutureBuilder(
                future: productName,
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    return Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Center(
                        child: _firstpage?Text(AppLocalizations.of(context)!.searchItem,
                            style: const TextStyle(
                                color: Color(0xff7F78D8),
                                fontWeight: FontWeight.w800,
                                fontSize: 14
                            )
                        ):Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text(AppLocalizations.of(context)!.somethingWentWrong,
                              style: const TextStyle(
                                  color: Color(0xff7F78D8),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14
                              )
                          ),
                        ),
                      ),
                    );
                  }
                  if(!snapshot.hasData){
                    return Center(
                      child: _firstpage?Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Text(AppLocalizations.of(context)!.processingData,
                            style: const TextStyle(
                                color: Color(0xff7F78D8),
                                fontWeight: FontWeight.w800,
                                fontSize: 14
                            )
                        ),
                      ):Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Text(AppLocalizations.of(context)!.noProductsAvailable,
                            style: const TextStyle(
                                color: Color(0xff7F78D8),
                                fontWeight: FontWeight.w800,
                                fontSize: 14
                            )
                        ),
                      ),
                    );
                  }
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return  Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height*0.83,
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
                        offline!.isNotEmpty && online!.isNotEmpty?AnimatedContainer(
                         curve: Curves.ease,
                         duration: Duration(milliseconds: 400),
                         height: animatedProvider.myVariable ? 105 : 0,
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
                                   automaticallyImplyLeading: false,
                                   backgroundColor: Colors.grey.shade50,
                                   elevation: 0,
                                   title: Center(
                                     child: CustomSlidingSegmentedControl(
                                       //isStretch: true,
                                       initialValue: _selectedShop.index,
                                       children:  {
                                         Shops.onlineShops.index: SizedBox(
                                           child: _selectedShop == Shops.onlineShops?
                                           Row(
                                             children: [
                                               const Icon(Icons.location_on, color: Colors.white, size: 19,),
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
                                         Shops.shopsNearMe.index: SizedBox(
                                           child: _selectedShop == Shops.shopsNearMe?
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
                                               ),                                  Text(
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
                                           _switchToShop(Shops.values[value]);
                                         });
                                       },
                                     ),
                                   ),
                                 ),
                               ),
                             ),
                           ),
                         ),
                       ):Container(),
                        AnimatedContainer(
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
                                  onTap:(){
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
                                        _hasCalculatedEndPoint = true;// Set the flag to true once _endPoint is calculated
                                        _slideInteract = false;
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
                                            topRight: Radius.circular(25),
                                          ),
                                        ),
                                        builder: (context){
                                          return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                String displayValue;
                                                if (_startValue == _startValue.floor()) {
                                                  //.floor is basically used to convert doubles to integers
                                                  displayValue = _startValue.floor().toString();
                                                } else {
                                                  displayValue = _startValue.toString();
                                                }
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
                                                          width: 130,
                                                          padding:EdgeInsets.symmetric(horizontal: 12),
                                                          decoration:BoxDecoration(
                                                              color: Colors.grey.shade400
                                                          ),
                                                          child: Center(child:  snapshot.data!.data!.products!.isNotEmpty?
                                                          TextField(
                                                            enabled: _slideInteract,
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
                                                            enabled: _slideInteract,
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
                                                          width: 130,
                                                          padding:EdgeInsets.symmetric(horizontal: 12),
                                                          decoration:BoxDecoration(
                                                              color: Colors.grey.shade400
                                                          ),
                                                          child: Center(
                                                              child: snapshot.data!.data!.products!.isNotEmpty?
                                                              TextField(
                                                                enabled: _slideInteract,
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
                                                                enabled: _slideInteract,
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
                                                          _slideInteract = true;
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
                                                                  productName = Network().getProductsName(_name, _code, _startValue.toInt(), _endValue.toInt(),context);
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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('Filter',
                                          style: TextStyle(
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
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: offline.isNotEmpty && online!.isNotEmpty?SizedBox(
                            width: double.infinity,
                            child: Stack(
                              children: [
                                SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(1, 0),
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
                          ):Online(snapshot: snapshot),
                        )
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
          physics: const BouncingScrollPhysics(),
          onQueryChanged: (query) async {
            var searches = await _getRecentSearchesLike(query);
            setState(() {
              _hasCalculatedEndPoint = false;
              _filteredSearchHistory = searches;
            });
            _fetchSearchSuggestions(query);
            _startTimer();
            setState(() {
              _type = true;
            });
          },
          onSubmitted: (v){
            _loadCountryCode().then((value){
              _saveToRecentSearches(v);
              setState(() {
                _hasCalculatedEndPoint = false;
                _firstpage = false;
                _name = v;
                productName = Network().getProductsName(v, _code,0, 100000000,context);
              });
              controller.close();
            });
          },
          actions: [
            FloatingSearchBarAction(
              showIfOpened: false,
              child: CircularButton(
                  icon: const Icon(Icons.search),
                  onPressed: (){
                  }
              ),
            ),
            FloatingSearchBarAction.searchToClear(
              showIfClosed: false,
            )
          ],
          builder:(context, transition){
            return _type == true ?ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Material(
                elevation: 4,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.searchSuggestions,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 15),
                            child: _suggestion.length != 0?
                            Text('About ${_suggestion.length.toString()} result(s) in ${_timeTakenText} milliseconds',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500
                              ),
                            ):Text('')
                        ),
                      ],
                    ),
                    _suggestion.length != 0?SizedBox(
                      height: 230,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestion.length,
                        itemBuilder: (context, index) {
                          final suggestion = _suggestion[index];
                          final query = controller.query;
                          final suggestionWithHighlightedLetters =
                          buildSuggestionTile(suggestion, query);

                          return ListTile(
                            leading: const Icon(Icons.search),
                            title: suggestionWithHighlightedLetters,
                            onTap: () {
                              setState(() {
                                _hasCalculatedEndPoint = false;
                                _type = false;
                              });
                              _loadCountryCode().then((value) {
                                _saveToRecentSearches(suggestion);
                                setState(() {
                                  _firstpage = false;
                                  _name = suggestion;
                                  productName = Network().getProductsName(suggestion, _code,0,100000000,context);
                                });
                                controller.close();
                                putSearchTermFirst(suggestion);
                              });
                            },
                            trailing: IconButton(
                              onPressed: () {
                                _loadCountryCode().then((value) {
                                  _saveToRecentSearches(suggestion);
                                  setState(() {
                                    _hasCalculatedEndPoint = false;
                                    _firstpage = false;
                                    _name = suggestion;
                                    productName = Network().getProductsName(suggestion, _code,0,100000000,context);
                                  });
                                  controller.close();
                                  putSearchTermFirst(suggestion);
                                });
                              },
                              icon: const Icon(Icons.north_east),
                            ),
                          );
                        },
                      )
                    ): SizedBox(
                      height: 140,
                      child: Center(child: _start == 0?
                      Text(''):
                      Text(AppLocalizations.of(context)!.pleaseWaitSearching)
                      ),
                    ),
                    Builder(
                      builder: ((context) {
                        if (_filteredSearchHistory == null &&
                            controller.query.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            width: double.infinity,
                            child: Text(
                              AppLocalizations.of(context)!.startSearching,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.caption,
                            ),
                          );
                        } else if (_filteredSearchHistory!.isEmpty) {
                          return ListTile(
                            title: Text(controller.query),
                            leading: const Icon(
                              Icons.search,
                            ),
                            onTap: () {
                              _loadCountryCode().then((value){
                                _saveToRecentSearches(controller.query);
                                setState(() {
                                  _hasCalculatedEndPoint = false;
                                  _firstpage = false;
                                  _name = controller.query;
                                  productName = Network().getProductsName(controller.query, _code,0,100000000,context);
                                });
                                controller.close();
                              });

                            },
                            trailing: IconButton(
                              onPressed: () {

                                _loadCountryCode().then((value){
                                  _saveToRecentSearches(controller.query);
                                  setState(() {
                                    _firstpage = false;
                                    _hasCalculatedEndPoint = false;
                                    _name = controller.query;
                                    productName = Network().getProductsName(controller.query, _code,0,100000000,context);
                                  });
                                  controller.close();
                                  putSearchTermFirst(controller.query);
                                });
                              },
                              icon: const Icon(Icons.north_east),
                            ),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(),
                                child:  Padding(
                                  padding: EdgeInsets.only(
                                      left: 20, bottom: 10, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!.recentSearches,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _filteredSearchHistory!
                                    .map(
                                      (term) => ListTile(
                                    title: Text(
                                      term,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    leading: const Icon(
                                      Icons.update,
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        _loadCountryCode().then((value){
                                          _saveToRecentSearches(term);
                                          setState(() {
                                            _hasCalculatedEndPoint = false;
                                            _firstpage = false;
                                            _name = term;
                                            productName = Network().getProductsName(term, _code,0,100000000,context);
                                          });
                                          controller.close();
                                          putSearchTermFirst(term);
                                        });
                                      },
                                      icon: const Icon(Icons.north_east),
                                    ),
                                    onTap: () {
                                      _loadCountryCode().then((value){
                                        _saveToRecentSearches(term);
                                        setState(() {
                                          _hasCalculatedEndPoint = false;
                                          _firstpage = false;
                                          _name = term;
                                          productName = Network().getProductsName(term, _code,0,100000000,context);
                                        });
                                        controller.close();
                                        putSearchTermFirst(term);
                                      });
                                    },
                                  ),
                                )
                                    .toList(),
                              ),
                            ],
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
            ):Container();
          }
      ),
    );
  }
}
