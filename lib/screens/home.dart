import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job/screens/see_more_discounted.dart';
import 'package:job/screens/see_more_last_view.dart';
import 'package:job/screens/see_more_popular.dart';
import 'package:job/screens/widgets/last_seen.dart';
import 'package:job/screens/widgets/most.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

import '../network/json.dart';
import '../network/network.dart';


class MyHome extends StatefulWidget {
  final VoidCallback? onProductPressed;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onSearchPressed;
  const MyHome({Key? key, required this.onProductPressed, required this.onCameraPressed, required this.onSearchPressed}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  late Future<Koye> _discountedProducts = Network().getMostDisPop( _code, '', context);
  late Future<Koye> _popularProducts = Network().getMostDisPop( _code, '', context);
  late String _code = '';


  Future _loadCountryCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('countryCode');
    setState(() {
      _code = savedCode??'NG';
    });
  }

  _mostDiscounted(){
    _loadCountryCode().then((value){
      _discountedProducts = Network().getMostDisPop(_code, 'most_discounted', context);
    });
  }
  _mostPopular(){
    _loadCountryCode().then((value){
      _popularProducts = Network().getMostDisPop(_code, 'most_popular', context);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mostDiscounted();
    _mostPopular();
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
                child: Image.network('https://images.pexels.com/photos/3735655/pexels-photo-3735655.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', fit: BoxFit.cover,),
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
            child: Image.network('https://images.pexels.com/photos/3685523/pexels-photo-3685523.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', fit: BoxFit.cover,),
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
            child: Image.network('https://images.pexels.com/photos/90946/pexels-photo-90946.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', fit: BoxFit.cover,),
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
            child: Image.network('https://images.pexels.com/photos/2783873/pexels-photo-2783873.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1', fit: BoxFit.cover,),
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade100,
        shadowColor: Color(0xff7F78D8).withOpacity(0.3),
        elevation: 2,
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
                  onTap: widget.onSearchPressed,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.055,
                    width: MediaQuery.of(context).size.width *0.7,
                    child: TextFormField(
                      enabled: false,
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
                ),
                IconButton(
                    onPressed: widget.onProductPressed,
                    icon: SvgPicture.asset('asset/barcode-scan-svgrepo-com (1).svg')
                ),
                InkWell(
                    onTap: widget.onCameraPressed,
                    child: Icon(Icons.camera_alt_outlined, color: Color(0xff7F78D8),size: 25,)
                )
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.0002,
            )
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
                          Navigator.of(context).push(PageTransition(
                            child: const SeeMore(),
                            type: PageTransitionType.rightToLeft,
                            childCurrent: widget,
                            duration: const Duration(milliseconds: 200),
                            reverseDuration: const Duration(milliseconds: 200),
                          )
                          );
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
                height: 10,
              ),
              LastSeen(),
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12,right: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Text('Most Discounted',
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.of(context).push(PageTransition(
                            child: const SeeMoreDiscounted(),
                            type: PageTransitionType.rightToLeft,
                            childCurrent: widget,
                            duration: const Duration(milliseconds: 200),
                            reverseDuration: const Duration(milliseconds: 200),
                          )
                          );
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
              Most(discount: _discountedProducts),
              const SizedBox(height: 15,),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12,right: 11),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    Text('Most Popular',
                      style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800
                      ),
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.of(context).push(PageTransition(
                            child: const SeeMorePopular(),
                            type: PageTransitionType.rightToLeft,
                            childCurrent: widget,
                            duration: const Duration(milliseconds: 200),
                            reverseDuration: const Duration(milliseconds: 200),
                          )
                          );
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
              Most(discount: _popularProducts)
            ],
          ),
        ),
      )
    );
  }
}
