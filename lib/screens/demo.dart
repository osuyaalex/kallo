import 'dart:async';

import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import '../network/json.dart';
import '../network/network.dart';
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
  late Future<Koye> productName = Network().getProductsName(_name, _code);
  late FloatingSearchBarController controller;
  List<String>? _filteredSearchHistory;
  String _name = '';
  late String _code = '';
  bool _firstpage = true;
  double _startValue = 0.0;
  double _endValue = 100000.0;
  List<String> _suggestion = [];
  bool _type = false;
  String? _currentLocale;
  String? _timeTakenText;
  Timer? _timer;
  int _start = 5;

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
  @override
  void initState() {
    // TODO: implement initState
    productName = Network().getProductsName(_name, _code);
    controller = FloatingSearchBarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadCountryCode();
    _getCurrentLocale();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          body:  SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0,80,0,10),
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
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30)
                                        ),
                                        builder: (context){
                                          return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {

                                                return Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 50,
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                                onPressed: (){
                                                                  Navigator.pop(context);
                                                                },
                                                                icon: Icon(Icons.close)
                                                            ),

                                                            Text('Sort',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w800,
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
                                    width: 110,
                                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border(
                                          top: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                          left: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                          right: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                          bottom: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                        )
                                    ),
                                    child: Row(
                                      children: [
                                        Text('Sort:',
                                          style: TextStyle(
                                              color: Color(0xff7f78d8),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text('',
                                          style: TextStyle(
                                              color: Color(0xff7f78d8),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 14,
                                ),
                                GestureDetector(
                                  onTap:(){
                                    showModalBottomSheet(
                                        context: context,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30)
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
                                                    SizedBox(
                                                      height: 50,
                                                      width: MediaQuery.of(context).size.width,
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                                onPressed: (){
                                                                  Navigator.pop(context);
                                                                },
                                                                icon: Icon(Icons.close)
                                                            ),

                                                            Text('Filter',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w800,
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
                                                          height: 40,
                                                          width: 90,
                                                          decoration:BoxDecoration(
                                                              color: Colors.grey.shade400
                                                          ),
                                                          child: Center(child: Text("${snapshot.data?.data?.products?[1].currency??''} ${displayValue}",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800
                                                            ),
                                                          )),
                                                        ),
                                                        SizedBox(
                                                          width: 14,
                                                        ),
                                                        Text('to'),
                                                        SizedBox(
                                                          width: 14,
                                                        ),
                                                        Container(
                                                          height: 40,
                                                          width: 90,
                                                          decoration:BoxDecoration(
                                                              color: Colors.grey.shade400
                                                          ),
                                                          child: Center(child: Text("${snapshot.data?.data?.products?[1].currency??''} ${displaySecondValue}",
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w800
                                                            ),
                                                          )),
                                                        ),
                                                      ],
                                                    ),
                                                    RangeSlider(
                                                      values: RangeValues(_startValue, _endValue),
                                                      min: 0.0,
                                                      max: 100000.0,
                                                      activeColor:Color(0xff7f78d8),
                                                      // inactiveColor:Colors.grey.shade500,
                                                      onChanged: ( values) {
                                                        setState(() {
                                                          _startValue = values.start;
                                                          _endValue = values.end;
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
                                                    )
                                                  ],
                                                );
                                              }
                                          );
                                        }
                                    );
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 110,
                                    padding: EdgeInsets.symmetric(horizontal: 14.0),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border(
                                          top: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                          left: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                          right: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                          bottom: BorderSide(
                                              color: Color(0xff7f78d8)
                                          ),
                                        )
                                    ),
                                    child: Row(
                                      children: [
                                        Text('Filter:',
                                          style: TextStyle(
                                              color: Color(0xff7f78d8),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text('',
                                          style: TextStyle(
                                              color: Color(0xff7f78d8),
                                              fontWeight: FontWeight.w500
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height*0.65,
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
          ),
          physics: const BouncingScrollPhysics(),
          onQueryChanged: (query) async {
            var searches = await _getRecentSearchesLike(query);
            setState(() {
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
                _firstpage = false;
                _name = v;
                productName = Network().getProductsName(v, _code);
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
                            child: Text('About ${_suggestion.length.toString()} result(s) in ${_timeTakenText} milliseconds',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500
                              ),
                            )
                        ),
                      ],
                    ),
                    _suggestion.length != 0?SizedBox(
                      height: 230,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _suggestion.length,
                          itemBuilder: (context, index){
                            return ListTile(
                              leading: const Icon(
                                Icons.search,
                              ),
                              title: Text(_suggestion[index]),
                              onTap: (){
                                setState(() {
                                  _type = false;
                                });
                                _loadCountryCode().then((value){
                                  _saveToRecentSearches(_suggestion[index]);
                                  setState(() {
                                    _firstpage = false;
                                    _name = _suggestion[index];
                                    productName = Network().getProductsName(_suggestion[index], _code);
                                  });
                                  controller.close();
                                  putSearchTermFirst(_suggestion[index]);
                                });
                              },
                              trailing: IconButton(
                                onPressed: () {
                                  _firstpage = false;
                                  _loadCountryCode().then((value){
                                    _saveToRecentSearches(_suggestion[index]);
                                    setState(() {
                                      _name = _suggestion[index];
                                      productName = Network().getProductsName(_suggestion[index], _code);
                                    });
                                    controller.close();
                                    putSearchTermFirst(_suggestion[index]);
                                  });
                                },
                                icon: const Icon(Icons.north_east),
                              ),
                            );
                          }
                      ),
                    ): SizedBox(
                      height: 140,
                      child: Center(child: _start == 0?
                      Text(AppLocalizations.of(context)!.noSuggestions):
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
                                  _firstpage = false;
                                  _name = controller.query;
                                  productName = Network().getProductsName(controller.query, _code);
                                });
                                controller.close();
                              });

                            },
                            trailing: IconButton(
                              onPressed: () {
                                _firstpage = false;
                                _loadCountryCode().then((value){
                                  _saveToRecentSearches(controller.query);
                                  setState(() {
                                    _name = controller.query;
                                    productName = Network().getProductsName(controller.query, _code);
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
                                            _firstpage = false;
                                            _name = term;
                                            productName = Network().getProductsName(term, _code);
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
                                          _firstpage = false;
                                          _name = term;
                                          productName = Network().getProductsName(term, _code);
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
