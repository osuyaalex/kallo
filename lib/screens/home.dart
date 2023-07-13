import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:job/providers/products.dart';
import 'package:job/screens/see_more.dart';
import 'package:job/screens/similar_images.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:url_launcher/url_launcher.dart';


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
  Set<String> _matchingCategories = {
    "Women's Clothing",
    "Men's Clothing",
    "Women's Shoes",
    "Men's Shoes",
    "Shoe Accessories",
    "Watches",
    "Sportswear",
    "Clothing Accessories",
    "Costumes & Accessories",
    "Handbags",
    "Jewelry",
    "Luggage & Suitcases",
    "Wallets & Cases",
    "Backpacks",
    "Baby Bathing",
    "Baby Gift Sets",
    "Baby Health",
    "Baby Toys & Activity Equipment",
    "Baby Safety",
    "Baby Transport",
    "Baby Transport Accessories",
    "Diapering",
    "Nursing & Feeding",
    "Potty Training",
    "Swaddling & Receiving Blankets",
    "Baby & Toddler Furniture",
    "Beds & Accessories",
    "Benches",
    "Cabinets & Storage",
    "Chairs",
    "Entertainment Centers & TV Stands",
    "Furniture Sets",
    "Office Furniture",
    "Outdoor Furniture",
    "Shelving",
    "Sofas",
    "Tables",
    "Building Materials",
    "Fencing & Barriers",
    "Fuel Containers & Tanks",
    "Hardware Pumps",
    "Heating, Ventilation & Air Conditioning",
    "Locks & Keys",
    "Plumbing",
    "Power & Electrical Supplies",
    "Small Engines & Generators",
    "Storage Tanks",
    "Hardware Tools & DIY",
    "Book Accessories",
    "Office Desk Pads & Blotters",
    "Filing & Organization",
    "General Office Supplies",
    "Office & Chair Mats",
    "Office Equipment",
    "Paper Handling",
    "Kids Fun Games",
    "Outdoor Play Equipment",
    "Puzzles",
    "Kids Toys",
  };

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
    String breakUnwantedPart(String name) {
      if (name.length > 35) {
        return name.trim().replaceRange(25, null, '...');
      }
      return name;
    }
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
                            duration: const Duration(milliseconds: 300),
                            reverseDuration: const Duration(milliseconds: 300),
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
                height: 12,
              ),
              Consumer<ProductProvider>(
                builder: (context, productProvider, child) {
                  int? itemCount = productProvider.count;
                  int maxItemCount = 4;
                  int? displayedItemCount = itemCount! < maxItemCount ? itemCount : maxItemCount;
                  return SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: displayedItemCount,
                        itemBuilder: (context, index){
                          if(productProvider.getItems[index].productCategory != null){
                            if(_matchingCategories.contains(productProvider.getItems[index].productCategory)){
                              return  GestureDetector(
                                onTap: (){
                                  String url = productProvider.getItems[index].url;
                                  Uri uri = Uri.parse(url);
                                  try{
                                    launchUrl(uri);
                                  }catch(e){
                                    print(e.toString());
                                  }
                                },
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 180,
                                      child: Card(
                                        elevation: 1,
                                        shadowColor: Colors.grey.shade300,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(13)
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 120,
                                              width: 140,
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  image: DecorationImage(
                                                      image: NetworkImage(productProvider.getItems[index].imageUrl.isNotEmpty == true?
                                                      productProvider.getItems[index].imageUrl:
                                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                                      ),
                                                      fit: BoxFit.fill
                                                  )
                                              ),
                                            ),
                                            SizedBox(
                                              height: 7,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: SizedBox(
                                                width: 180,
                                                child: Text(breakUnwantedPart(productProvider.getItems[index].name),
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 7,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(productProvider.getItems[index].merchantName,
                                                    style: const TextStyle(
                                                        color: Color(0xff161b22),
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 15
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 7,
                                            ),
                                            SizedBox(
                                              height: 20,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(productProvider.getItems[index].currency,
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xff7F78D8)
                                                      ),
                                                    ),
                                                    Text(productProvider.getItems[index].price,
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w600,
                                                          color: Color(0xff7F78D8)
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        top: 10,
                                        right: 10,
                                        child: GestureDetector(
                                            onTap: (){
                                              showDialog(
                                                context: context,
                                                builder: (context){
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12)
                                                    ),
                                                    content: Text('Search for images similar to this item?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                          onPressed: (){
                                                            Navigator.of(context).pop();
                                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                                              return SimilarImagePage(similarSearch: productProvider.getItems[index].imageUrl);
                                                            }));
                                                          },
                                                          child: Text(AppLocalizations.of(context)!.yes,
                                                            style: TextStyle(
                                                              color:  Colors.black,
                                                            ),
                                                          )
                                                      ),
                                                      TextButton(
                                                          onPressed: (){
                                                            Navigator.pop(context);
                                                          }, child: Text(AppLocalizations.of(context)!.no,
                                                        style: TextStyle(
                                                          color:  Colors.black,
                                                        ),
                                                      )
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: Opacity(
                                                opacity: 0.5,
                                                child: SvgPicture.asset('asset/search with image icon.svg')
                                            )
                                        )
                                    )
                                  ],
                                ),
                              );
                            }else{
                              return GestureDetector(
                                onTap: (){
                                  String url = productProvider.getItems[index].url;
                                  Uri uri = Uri.parse(url);
                                  try{
                                    launchUrl(uri);
                                  }catch(e){
                                    print(e.toString());
                                  }
                                },
                                child: SizedBox(
                                  width: 180,
                                  child: Card(
                                    elevation: 1,
                                    shadowColor: Colors.grey.shade300,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13)
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 140,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: NetworkImage(productProvider.getItems[index].imageUrl.isNotEmpty == true?
                                                  productProvider.getItems[index].imageUrl:
                                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                                  ),
                                                  fit: BoxFit.fill
                                              )
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: SizedBox(
                                            width: 180,
                                            child: Text(breakUnwantedPart(productProvider.getItems[index].name),
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(productProvider.getItems[index].merchantName,
                                                style: const TextStyle(
                                                    color: Color(0xff161b22),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 7,
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(productProvider.getItems[index].currency,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xff7F78D8)
                                                  ),
                                                ),
                                                Text(productProvider.getItems[index].price,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xff7F78D8)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }else{
                            return  GestureDetector(
                              onTap: (){
                                String url = productProvider.getItems[index].url;
                                Uri uri = Uri.parse(url);
                                try{
                                  launchUrl(uri);
                                }catch(e){
                                  print(e.toString());
                                }
                              },
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: Card(
                                      elevation: 1,
                                      shadowColor: Colors.grey.shade300,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(13)
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 140,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                image: DecorationImage(
                                                    image: NetworkImage(productProvider.getItems[index].imageUrl.isNotEmpty == true?
                                                    productProvider.getItems[index].imageUrl:
                                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                                    ),
                                                    fit: BoxFit.fill
                                                )
                                            ),
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: SizedBox(
                                              width: 180,
                                              child: Text(breakUnwantedPart(productProvider.getItems[index].name),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(productProvider.getItems[index].merchantName,
                                                  style: const TextStyle(
                                                      color: Color(0xff161b22),
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 15
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 7,
                                          ),
                                          SizedBox(
                                            height: 20,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Text(productProvider.getItems[index].currency,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xff7F78D8)
                                                    ),
                                                  ),
                                                  Text(productProvider.getItems[index].price,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xff7F78D8)
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 10,
                                      right: 10,
                                      child: GestureDetector(
                                          onTap: (){
                                            showDialog(
                                              context: context,
                                              builder: (context){
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12)
                                                  ),
                                                  content: Text('Search for images similar to this item?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: (){
                                                          Navigator.of(context).pop();
                                                          Navigator.push(context, MaterialPageRoute(builder: (context){
                                                            return SimilarImagePage(similarSearch: productProvider.getItems[index].imageUrl);
                                                          }));
                                                        },
                                                        child: Text(AppLocalizations.of(context)!.yes,
                                                          style: TextStyle(
                                                              color: Colors.black
                                                          ),
                                                        )
                                                    ),
                                                    TextButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                        }, child: Text(AppLocalizations.of(context)!.no,
                                                      style: TextStyle(
                                                          color: Colors.black
                                                      ),
                                                    )
                                                    )
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: Opacity(
                                              opacity: 0.5,
                                              child: SvgPicture.asset('asset/search with image icon.svg')
                                          )
                                      )
                                  )
                                ],
                              ),
                            );

                          }
                        }
                    ),
                  );
                }
              )
            ],
          ),
        ),
      )
    );
  }
}
