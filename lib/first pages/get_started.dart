import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

import 'home.dart';

class GetStarted extends StatefulWidget {
   const GetStarted({Key? key}) : super(key: key);

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Hide the system overlays (buttons)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // Show the system overlays (buttons) when the page is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  int _activeIndex = 0;
  final List<Widget> _screens = [
    Container(
      width: double.infinity,
      color: const Color(0xff090a0c),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 120
            ),
            Image.asset('asset/Kallo logo dark background zoomed in png.png', height: 100,),
            const SizedBox(
              height: 28,
            ),
             Builder(
               builder: (context) {
                 return Text(AppLocalizations.of(context)!.welcome,
            style:const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Colors.white
            ),
            );
               }
             )
          ],
        ),
      ) ,
    ),
    Container(
      width: double.infinity,
      color: Color(0xff090a0c),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
                height: 120
            ),
            Image.asset('asset/Kallo logo dark background zoomed in png.png', height: 100,),
            const SizedBox(
              height: 28,
            ),
             Builder(
                builder: (context) {
                  return Text(AppLocalizations.of(context)!.welcome,
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                    ),
                  );
                }
            )
          ],
        ),
      ) ,
    ),
    Container(
      width: double.infinity,
      color: Color(0xff090a0c),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
                height: 120
            ),
            Image.asset('asset/Kallo logo dark background zoomed in png.png', height: 100,),
            const SizedBox(
              height: 28,
            ),
             Builder(
                builder: (context) {
                  return Text(AppLocalizations.of(context)!.welcome,
                    style:  const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                    ),
                  );
                }
            )
          ],
        ),
      ) ,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider.builder(
            options: CarouselOptions(
                viewportFraction: 1,
                aspectRatio: 16/9,
                height: MediaQuery.of(context).size.height,
                autoPlay: false,
                initialPage: 0,
                enableInfiniteScroll: false,
                enlargeCenterPage: false,
                onPageChanged: (index, reason){
                  setState(() {
                    _activeIndex = index;
                  });
                }
            ),
            itemCount: _screens.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return _screens[index];
            },
          ),
          Positioned(
            left: 16,
            top: MediaQuery.of(context).size.height / 2 - 16,
            child: Opacity(
              opacity: _activeIndex > 0 ? 1.0 : 0.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,color: Colors.white,size: 30,),
                onPressed: _activeIndex > 0
                    ? () {
                  setState(() {
                    _activeIndex--;
                  });
                }
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 16,
            child: Opacity(
              opacity: _activeIndex < _screens.length - 1 ? 1.0 : 0.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white,size: 30,),
                onPressed: _activeIndex < _screens.length - 1
                    ? () {
                  setState(() {
                    _activeIndex++;
                  });
                }
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height*0.2,
            right: MediaQuery.of(context).size.width*0.45,
            child: _buildIndicator(),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height*0.05,
            right: MediaQuery.of(context).size.width*0.208,
            child: GestureDetector(
            onTap: ()async{
              // SharedPreferences prefs = await SharedPreferences.getInstance();
              // prefs.setBool('isFirstLaunch', false);
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home()));
            },
            child: Container(
              height: 60,
              width: MediaQuery.of(context).size.width*0.6,
              decoration: BoxDecoration(
                  color:const Color(0xff7F78D8),
                  borderRadius: BorderRadius.circular(12)
              ),
              child:  Center(
                child: Text(AppLocalizations.of(context)!.getStarted??'',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white
                  ),
                ),
              ),
            ),
          ),)
        ],
      ),
    );
  }
  Widget _buildIndicator(){
    return AnimatedSmoothIndicator(
      activeIndex: _activeIndex,
      count: _screens.length,
      effect: const JumpingDotEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: Colors.white
      ),
    );
  }
}
