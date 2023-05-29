import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios, size: 23, color: Colors.black,)
          ),
          actions: [
            IconButton(
                onPressed: (){},
                icon: const Icon(Icons.menu, size: 23, color: Colors.black,)
            ),
          ],

        ),
        backgroundColor: Colors.white,
        body: FloatingSearchBar(
            borderRadius: BorderRadius.circular(12),
            hint: AppLocalizations.of(context)!.searchForProducts,
            controller: controller,
            openAxisAlignment: 0.0,
            axisAlignment: isPortrait ? 0.0:-1.0,
            scrollPadding: const EdgeInsets.only(top: 12, bottom: 20),
            elevation: 1,
            transitionCurve: Curves.easeInOut,
            transitionDuration: const Duration(seconds: 1),
            transition: CircularFloatingSearchBarTransition(),
            debounceDelay: const Duration(milliseconds: 500),
            body:  SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,80,0,10),
                child: FutureBuilder(
                    future: productName,
                    builder: (context, snapshot){
                      if(snapshot.hasError){
                        return Center(
                          child: Text(AppLocalizations.of(context)!.searchItem,
                              style: const TextStyle(
                                  color: Color(0xff7F78D8),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14
                              )
                          ),
                        );
                      }
                      if(!snapshot.hasData){
                        return Center(
                          child: Text(AppLocalizations.of(context)!.noProductsAvailable,
                              style: const TextStyle(
                                  color: Color(0xff7F78D8),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14
                              )
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
                           AppBar(
                             automaticallyImplyLeading: false,
                             backgroundColor: Colors.white,
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
                            SizedBox(
                              height: MediaQuery.of(context).size.height*0.601,
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
            },
            onSubmitted: (v){
              _loadCountryCode().then((value){
                _saveToRecentSearches(v);
                setState(() {
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
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  elevation: 4,
                  child: Builder(
                    builder: ((context) {
                      if (_filteredSearchHistory == null &&
                          controller.query.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          height: 50,
                          width: double.infinity,
                          child: Text(
                            'Start Searching',
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
                              setState(() {
                                _name = controller.query;
                                productName = Network().getProductsName(controller.query, _code);
                              });
                              controller.close();
                            });

                          },
                          trailing: IconButton(
                            onPressed: () {
                              _loadCountryCode().then((value){
                                setState(() {
                                  _name = controller.query;
                                  productName = Network().getProductsName(controller.query, _code);
                                });
                                controller.close();
                                putSearchTermFirst(controller.query);
                              });
                            },
                            icon: const Icon(Icons.north_west),
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(),
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    left: 20, bottom: 10, top: 10),
                                child: Text(
                                  'Recent Searches',
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
                                        setState(() {
                                          _name = term;
                                          productName = Network().getProductsName(term, _code);
                                        });
                                        controller.close();
                                        putSearchTermFirst(term);
                                      });
                                    },
                                    icon: const Icon(Icons.north_west),
                                  ),
                                  onTap: () {
                                    _loadCountryCode().then((value){
                                      setState(() {
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
                ),
              );
            }
        ),
      ),
    );
  }
}
