import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'nationality.dart';

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
  CarouselController _carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Container(
        width: double.infinity,
        color: const Color(0xff161b22),
        child: Center(
          child: Column(
            children: [
               SizedBox(
                  height: MediaQuery.of(context).size.height*0.33
              ),
             SizedBox(
                      width: 272,
                      child: Text(AppLocalizations.of(context)!.getStartedOne,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18,
                            //fontWeight: FontWeight.w600,
                            color: Colors.white
                        ),
                      ),
                    ),
              const SizedBox(
                height: 15,
              ),
              SvgPicture.asset('asset/Best price 1.svg', height: MediaQuery.of(context).size.height*0.36,)
            ],
          ),
        ) ,
      ),
      Container(
        width: double.infinity,
        color: Color(0xff161b22),
        child: Center(
          child: Column(
            children: [
               SizedBox(
                height: MediaQuery.of(context).size.height*0.33,
              ),
              SizedBox(
                      width: 288,
                      child: Text(AppLocalizations.of(context)!.getStartedTwo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18,
                            //fontWeight: FontWeight.w600,
                            color: Colors.white
                        ),
                      ),
                    ),
              const SizedBox(
                height: 15,
              ),
              SvgPicture.asset('asset/Price notifications 1.svg', height: MediaQuery.of(context).size.height*0.36,)
            ],
          ),
        ) ,
      ),
      Container(
        width: double.infinity,
        color: Color(0xff161b22),
        child: Center(
          child: Column(
            children: [
               SizedBox(
                height: MediaQuery.of(context).size.height*0.33,
              ),
              SizedBox(
                      width: 268,
                      child: Text(AppLocalizations.of(context)!.getStartedThree,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                           fontSize: 18,
                           // fontWeight: FontWeight.w600,
                            color: Colors.white
                        ),
                      ),
                    ),
              const SizedBox(
                height: 15,
              ),
              SvgPicture.asset('asset/loyalty 1.svg', height: MediaQuery.of(context).size.height*0.36,)
            ],
          ),
        ) ,
      ),
    ];
    Widget buildIndicator(){
      return AnimatedSmoothIndicator(
        activeIndex: _activeIndex,
        count: screens.length,
        effect: const JumpingDotEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Color(0xff7F78D8),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          CarouselSlider.builder(
            carouselController: _carouselController,
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
            itemCount: screens.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return screens[index];
            },
          ),
          // PageView.builder(
          //   itemCount: screens.length,
          //   onPageChanged: (index) {
          //     setState(() {
          //       _activeIndex = index;
          //     });
          //   },
          //   itemBuilder: (BuildContext context, int index) {
          //     return screens[index];
          //   },
          // ),
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
                  _carouselController.previousPage();
                }
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height / 2 - 16,
            child: Opacity(
              opacity: _activeIndex < screens.length - 1 ? 1.0 : 0.0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white,size: 30,),
                onPressed: _activeIndex < screens.length - 1
                    ? () {
                  setState(() {
                    _activeIndex++;
                  });
                  _carouselController.nextPage();
                }
                    : null,
              ),
            ),
          ),
          Positioned(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height*0.06,
                    ),
                    Image.asset('asset/Kallo logo dark background zoomed in png.png', height: 100,),
                    const SizedBox(
                      height: 28,
                    ),
                    Text(AppLocalizations.of(context)!.welcome,
                      style:const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              )
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height*0.2,
            right: MediaQuery.of(context).size.width*0.45,
            child: buildIndicator(),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height*0.05,
            right: MediaQuery.of(context).size.width*0.206,
            child: GestureDetector(
            onTap: ()async{
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Nationality()));
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

}
