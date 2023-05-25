import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/json.dart';
import '../network/network.dart';
import 'offline_items.dart';
import 'online_items.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({Key? key}) : super(key: key);

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  late Future<Koye> productName = Network().getProductsName(_name);
  late FloatingSearchBarController controller;
  List<String>? _filteredSearchHistory;
  String _name = '';
  bool _showOfflineItems = true;

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

  @override
  void initState() {
    // TODO: implement initState
    productName = Network().getProductsName(_name);
    controller = FloatingSearchBarController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
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
            hint: 'Search kallo ...',
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
                        return const Center(
                          child: Text('Search item',
                              style: TextStyle(
                                  color: Color(0xff7F78D8),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14
                              )
                          ),
                        );
                      }
                      if(!snapshot.hasData){
                        return const Center(
                          child: Text('No products available',
                              style: TextStyle(
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
                             elevation: 1,
                             title: Center(
                               child: FlutterToggleTab(
                                 height: MediaQuery.of(context).size.height*0.055,
                                 width: 70,
                                 borderRadius: 30,
                                 selectedTextStyle: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 12,
                                     fontWeight: FontWeight.w600
                                 ),
                                 unSelectedTextStyle: const TextStyle(
                                     color: Colors.black,
                                     fontSize: 12,
                                     fontWeight: FontWeight.w400
                                 ),
                                 selectedBackgroundColors: const [
                                   Color(0xff7F78D8)
                                 ],
                                 labels: const ["Shops near me", "Online shops"],
                                 icons: [Icons.location_on_outlined, Icons.directions_bus_rounded],
                                 selectedIndex: _showOfflineItems ? 0 : 1,
                                 selectedLabelIndex: (index) {
                                   setState(() {
                                     _showOfflineItems = index == 0;
                                   });
                                 },
                               ),
                             ),
                           ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height*0.629,
                              width: double.infinity,
                              child: _showOfflineItems ?
                                  Offline(snapshot: snapshot,):Online(snapshot: snapshot,)
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
              _saveToRecentSearches(v);
              setState(() {
                _name = v;
                productName = Network().getProductsName(v);
              });
             controller.close();
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
                      if (_filteredSearchHistory!.isEmpty &&
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
                            setState(() {
                              _name = controller.query;
                              productName = Network().getProductsName(controller.query);
                            });

                            controller.close();
                          },
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                _name = controller.query;
                               productName = Network().getProductsName(controller.query);
                              });

                              controller.close();
                              putSearchTermFirst(controller.query);
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
                                      setState(() {
                                        _name = term;
                                        productName = Network().getProductsName(term);
                                      });
                                      controller.close();
                                      putSearchTermFirst(term);
                                    },
                                    icon: const Icon(Icons.north_west),
                                  ),
                                  onTap: () {
                                    setState(() {
                                     _name = term;
                                     productName = Network().getProductsName(term);
                                    });
                                    controller.close();
                                    putSearchTermFirst(term);
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
