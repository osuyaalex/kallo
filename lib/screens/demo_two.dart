
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:job/screens/barcode_search.dart';
import 'package:job/screens/demo.dart';
import 'package:job/screens/image_search.dart';
import 'package:job/screens/widgets/category_list.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/animated.dart';



class Dems extends StatefulWidget {

  const Dems({Key? key}) : super(key: key);

  @override
  State<Dems> createState() => _DemsState();
}

class _DemsState extends State<Dems>with SingleTickerProviderStateMixin{
  GlobalKey<FormState> _key = GlobalKey<FormState>();
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
  _shiftBarcode()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLaunch = prefs.getBool('isLaunch') ?? false;
    if(isLaunch == true){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => BarcodeSearch()));
      });
      prefs.setBool(('isLaunch'), false);
    }
  }
  _shiftImageScanner()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLaunchCamera = prefs.getBool('isLaunchCamera') ?? false;
    if(isLaunchCamera == true){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ImageSearch()));
      });
      prefs.setBool(('isLaunchCamera'), false);
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
    _shiftSearchBar();
    _shiftBarcode();
    loadCategoryJson();
    _shiftImageScanner();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
          backgroundColor: Colors.grey.shade100,
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
                    onTap: (){
                      Navigator.of(context).push(PageTransition(
                        child: const DemoScreen(),
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
                        Navigator.of(context).push(PageTransition(
                          child: const BarcodeSearch(),
                          type: PageTransitionType.fade,
                          childCurrent: widget,
                          duration: const Duration(milliseconds: 100),
                          reverseDuration: const Duration(milliseconds: 100),
                        )
                        );
                      },
                      icon: SvgPicture.asset('asset/barcode-scan-svgrepo-com (1).svg')
                  ),
                  InkWell(
                      onTap: (){
                        Navigator.of(context).push(PageTransition(
                          child: const ImageSearch(),
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
        body: Center(
          child:  NotificationListener<ScrollNotification>(
            onNotification: (notification){
              if(notification is ScrollUpdateNotification){
                // Check the direction of scroll and update the visibility of the container
                setState(() {
                  animatedProvider.myVariable = notification.scrollDelta! < 0;
                });
              }
              return false;
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).push(PageTransition(
                        child: const BarcodeSearch(),
                        type: PageTransitionType.fade,
                        childCurrent: widget,
                        duration: const Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                      )
                      );
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
                      Navigator.of(context).push(PageTransition(
                        child: const ImageSearch(),
                        type: PageTransitionType.fade,
                        childCurrent: widget,
                        duration: const Duration(milliseconds: 100),
                        reverseDuration: const Duration(milliseconds: 100),
                      )
                      );
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
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 36.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Category',
                            style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w700
                            ),
                          ),
                        ]
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  FutureBuilder(
                    future: loadCategoryJson(),
                      builder: (context, snapshot){

                      if(snapshot.hasData){
                        return Container(
                          height: 57*19,
                            width: MediaQuery.of(context).size.width*0.8,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)
                            ),
                            child: CategoryList(snapshot:snapshot)
                        );
                      }else{
                        return CircularProgressIndicator();
                      }
                      }
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
