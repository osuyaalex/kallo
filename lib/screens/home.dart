import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';


class MyHome extends StatefulWidget {
  final VoidCallback? onProductPressed;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onSearchPressed;
  const MyHome({Key? key, required this.onProductPressed, required this.onCameraPressed, required this.onSearchPressed}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final List<String> _lastViewed = [
    'https://images.pexels.com/photos/90946/pexels-photo-90946.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3685523/pexels-photo-3685523.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/364984/pexels-photo-364984.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/3735655/pexels-photo-3735655.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/2783873/pexels-photo-2783873.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
  ];
  late String _code = '';


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
        backgroundColor: Colors.grey.shade100,
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
                  onTap: widget.onSearchPressed,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.06,
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
                height: 12,
              ),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _lastViewed.length,
                    itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 130,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          image: DecorationImage(
                              image: NetworkImage(_lastViewed[index],
                              ),
                            fit: BoxFit.cover
                          )
                        ),
                      ),
                    );
                    }
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}
