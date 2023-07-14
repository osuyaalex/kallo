import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:job/screens/similar_images.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../first pages/main_home.dart';
import '../network/json.dart';
import '../network/network.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

import '../providers/products.dart';


class SeeMorePopular extends StatefulWidget {
  const SeeMorePopular({super.key,});

  @override
  State<SeeMorePopular> createState() => _SeeMorePopularState();
}

class _SeeMorePopularState extends State<SeeMorePopular> {
  late Future<Koye> _popularProducts = Network().getMostDisPop( _code, '', context);

  bool _switchLTOG = false;
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

  late String _code = '';


  Future _loadCountryCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('countryCode');
    setState(() {
      _code = savedCode??'NG';
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
    _mostPopular();
  }
  @override
  Widget build(BuildContext context) {
    String breakUnwantedPart(String name) {
      if (name.length > 35) {
        return name.trim().replaceRange(25, null, '...');
      }
      return name;
    }
    String cutUnwantedPart(String name) {
      if (name.length > 50) {
        return name.trim().replaceRange(25, null, '...');
      }
      return name;
    }
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black,)
        ),
        backgroundColor: Colors.grey.shade100,
        shadowColor: Color(0xff7F78D8).withOpacity(0.3),
        elevation: 2,
        toolbarHeight:MediaQuery.of(context).size.height*0.08,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Most Popular',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height*0.0002,
            )
          ],
        ) ,
        actions: [
          IconButton(
              onPressed: ()async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isSearchBar', true);
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: MainHome(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              icon: Icon(Icons.search,color: Color(0xff7F78D8))
          ),
          GestureDetector(
              onTap: ()async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLaunch', true);
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: MainHome(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              child: SvgPicture.asset('asset/barcode-scan-svgrepo-com (1).svg',height: 20,)
          ),

          IconButton(
              onPressed: ()async{
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setBool('isLaunchCamera', true);
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: MainHome(),
                  withNavBar: false, // OPTIONAL VALUE. True by default.
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              icon: Icon(Icons.camera_alt_outlined, color: Color(0xff7F78D8),)
          ),
          SizedBox(width: 10,),
          GestureDetector(
            onTap: (){
              setState(() {
                _switchLTOG = !_switchLTOG;
              });
            },
            child: _switchLTOG == false?Icon(Icons.list, color: Color(0xff7F78D8),)
                :Icon(Icons.grid_view_outlined, color: Color(0xff7F78D8),),
          ),
          SizedBox(width: 15,)
        ],
      ),
      body:Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: FutureBuilder(
            future: _popularProducts,
            builder: (context, snapshot) {
              List<Pproducts>? products = snapshot.data?.data?.products;
              if(snapshot.hasError){
                return Center(
                  child: Text(AppLocalizations.of(context)!.somethingWentWrong),
                );
              }
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if(snapshot.hasData){
                return _switchLTOG == false ?StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    itemCount: products?.length,
                    itemBuilder: (context, index){
                      final item = products?[index].price;
                      String displayValue;
                      if (item is double) {
                        final double number = item;
                        if (number == number.floor()) {
                          displayValue = number.floor().toString();
                        } else {
                          displayValue = number.toString();
                        }
                        if (number >= 1000) {
                          final formatter = NumberFormat("#,###");
                          displayValue = formatter.format(number);
                        }
                      } else if (item is int) {
                        final double number = item.toDouble();
                        final formatter = NumberFormat("#,###");
                        displayValue = formatter.format(number);
                      } else if (item is String) {
                        final double number = double.tryParse(item) ?? 0.0;
                        if (number == number.floor()) {
                          displayValue = number.floor().toString();
                        } else {
                          displayValue = number.toString();
                        }
                        if (number >= 1000) {
                          final formatter = NumberFormat("#,###");
                          displayValue = formatter.format(number);
                        }
                      } else {
                        displayValue = 'N/A'; // Handle the case when item is neither a double, int, nor a string
                      }
                      final listProducts = products?[index];
                      if(listProducts?.productCategory != null){
                        if(_matchingCategories.contains(listProducts?.productCategory)){
                          return  GestureDetector(
                            onTap: (){
                              String url = listProducts?.productLink??'';
                              Uri uri = Uri.parse(url);
                              try{
                                launchUrl(uri);
                              }catch(e){
                                print(e.toString());
                              }
                              Provider.of<ProductProvider>(context, listen: false).addItem(
                                  products?[index].productName??'',
                                  products?[index].imageThumbnailUrl??'',
                                  displayValue,
                                  products?[index].productLink??'',
                                  products?[index].merchantName??'',
                                  products?[index].currency??'',
                                  products?[index].productCategory
                              );
                            },
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 245,
                                  width: 230,
                                  child: Card(
                                    elevation: 1,
                                    shadowColor: Colors.grey.shade300,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13)
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 130,
                                          width: 160,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: NetworkImage(listProducts?.imageThumbnailUrl?.isNotEmpty == true?
                                                  listProducts!.imageThumbnailUrl!:
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
                                            child: Text(breakUnwantedPart(listProducts?.productName??''),
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
                                              Text(listProducts?.merchantName??'',
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
                                                Text(listProducts?.currency??'',
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xff7F78D8)
                                                  ),
                                                ),
                                                Text(displayValue,
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
                                                          return SimilarImagePage(similarSearch: listProducts?.imageThumbnailUrl??'');
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
                          return  GestureDetector(
                            onTap: (){
                              String url = listProducts?.productLink??'';
                              Uri uri = Uri.parse(url);
                              try{
                                launchUrl(uri);
                              }catch(e){
                                print(e.toString());
                              }
                              Provider.of<ProductProvider>(context, listen: false).addItem(
                                  products?[index].productName??'',
                                  products?[index].imageThumbnailUrl??'',
                                  displayValue,
                                  products?[index].productLink??'',
                                  products?[index].merchantName??'',
                                  products?[index].currency??'',
                                  products?[index].productCategory
                              );
                            },
                            child: SizedBox(
                              height: 245,
                              width: 230,
                              child: Card(
                                elevation: 1,
                                shadowColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 130,
                                      width: 160,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          image: DecorationImage(
                                              image: NetworkImage(listProducts?.imageThumbnailUrl?.isNotEmpty == true?
                                              listProducts!.imageThumbnailUrl!:
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
                                        child: Text(breakUnwantedPart(listProducts?.productName??''),
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
                                          Text(listProducts?.merchantName??'',
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
                                            Text(listProducts?.currency??'',
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xff7F78D8)
                                              ),
                                            ),
                                            Text(displayValue,
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
                            String url = listProducts?.productLink??'';
                            Uri uri = Uri.parse(url);
                            try{
                              launchUrl(uri);
                            }catch(e){
                              print(e.toString());
                            }
                            Provider.of<ProductProvider>(context, listen: false).addItem(
                                products?[index].productName??'',
                                products?[index].imageThumbnailUrl??'',
                                displayValue,
                                products?[index].productLink??'',
                                products?[index].merchantName??'',
                                products?[index].currency??'',
                                products?[index].productCategory
                            );
                          },
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 245,
                                width: 230,
                                child: Card(
                                  elevation: 1,
                                  shadowColor: Colors.grey.shade300,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(13)
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 130,
                                        width: 160,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            image: DecorationImage(
                                                image: NetworkImage(listProducts?.imageThumbnailUrl?.isNotEmpty == true?
                                                listProducts!.imageThumbnailUrl!:
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
                                          child: Text(breakUnwantedPart(listProducts?.productName??''),
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
                                            Text(listProducts?.merchantName??'',
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
                                              Text(listProducts?.currency??'',
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xff7F78D8)
                                                ),
                                              ),
                                              Text(displayValue,
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
                                                        return SimilarImagePage(similarSearch: listProducts?.imageThumbnailUrl??'');
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

                      }
                    },
                    staggeredTileBuilder: (context) => const StaggeredTile.fit(1)
                ):
                ListView.builder(
                    itemCount: products?.length,
                    itemBuilder: (context, index){
                      final item = products?[index].price;
                      String displayValue;

                      if (item is double) {
                        final double number = item;
                        if (number == number.floor()) {
                          displayValue = number.floor().toString();
                        } else {
                          displayValue = number.toString();
                        }
                        if (number >= 1000) {
                          final formatter = NumberFormat("#,###");
                          displayValue = formatter.format(number);
                        }
                      } else if (item is int) {
                        final double number = item.toDouble();
                        final formatter = NumberFormat("#,###");
                        displayValue = formatter.format(number);
                      } else if (item is String) {
                        final double number = double.tryParse(item) ?? 0.0;
                        if (number == number.floor()) {
                          displayValue = number.floor().toString();
                        } else {
                          displayValue = number.toString();
                        }
                        if (number >= 1000) {
                          final formatter = NumberFormat("#,###");
                          displayValue = formatter.format(number);
                        }
                      } else {
                        displayValue = 'N/A'; // Handle the case when item is neither a double, int, nor a string
                      }
                      final listProducts = products?[index];
                      if(listProducts?.productCategory != null){
                        if(_matchingCategories.contains(listProducts?.productCategory)){
                          return  Column(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  String url = listProducts?.productLink??'';
                                  Uri uri = Uri.parse(url);
                                  try{
                                    launchUrl(uri);
                                  }catch(e){
                                    print(e.toString());
                                  }
                                },
                                child: ListTile(
                                  leading: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                            image: NetworkImage(listProducts?.imageThumbnailUrl?.isNotEmpty == true?
                                            listProducts!.imageThumbnailUrl!:
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                            ),
                                            fit: BoxFit.fill
                                        )
                                    ),
                                  ),
                                  title: Column(
                                    children: [
                                      SizedBox(
                                        width: 210,
                                        child: Text(cutUnwantedPart(listProducts?.productName??''),
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Row(
                                                children: [
                                                  Text(listProducts?.currency??'',
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xff7F78D8)
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Text(displayValue,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xff7F78D8)
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(listProducts?.merchantName??'',
                                              style: const TextStyle(
                                                  color: Color(0xff161b22),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing:GestureDetector(
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
                                                        return SimilarImagePage(similarSearch: listProducts?.imageThumbnailUrl??'');
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
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Divider()
                            ],
                          );
                        }else{
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  String url = listProducts?.productLink??'';
                                  Uri uri = Uri.parse(url);
                                  try{
                                    launchUrl(uri);
                                  }catch(e){
                                    print(e.toString());
                                  }
                                },
                                child: ListTile(
                                  leading: Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(
                                            image:  NetworkImage(listProducts?.imageThumbnailUrl?.isNotEmpty == true?
                                            listProducts!.imageThumbnailUrl!:
                                            'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                            ),
                                            fit: BoxFit.fill
                                        )
                                    ),
                                  ),
                                  title: Column(
                                    children: [
                                      SizedBox(
                                        width: 210,
                                        child: Text(cutUnwantedPart(listProducts?.productName??''),
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Row(
                                                children: [
                                                  Text(listProducts?.currency??'',
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xff7F78D8)
                                                    ),
                                                  ),
                                                  SizedBox(width: 5,),
                                                  Text(displayValue,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: Color(0xff7F78D8)
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(listProducts?.merchantName??'',
                                              style: const TextStyle(
                                                  color: Color(0xff161b22),
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Divider()
                            ],
                          );
                        }
                      }else{
                        return    Column(
                          children: [
                            GestureDetector(
                              onTap: (){
                                String url = listProducts?.productLink??'';
                                Uri uri = Uri.parse(url);
                                try{
                                  launchUrl(uri);
                                }catch(e){
                                  print(e.toString());
                                }
                              },
                              child: ListTile(
                                leading: Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                          image: NetworkImage(listProducts?.imageThumbnailUrl?.isNotEmpty == true?
                                          listProducts!.imageThumbnailUrl!:
                                          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                          ),
                                          fit: BoxFit.fill
                                      )
                                  ),
                                ),
                                title: Column(
                                  children: [
                                    SizedBox(
                                      width: 210,
                                      child: Text(cutUnwantedPart(listProducts?.productName??''),
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Row(
                                              children: [
                                                Text(listProducts?.currency??'',
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xff7F78D8)
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Text(displayValue,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xff7F78D8)
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(listProducts?.merchantName??'',
                                            style: const TextStyle(
                                                color: Color(0xff161b22),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15
                                            ),
                                          ),

                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing:GestureDetector(
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
                                                      return SimilarImagePage(similarSearch: listProducts?.imageThumbnailUrl??'');
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
                                ),
                              ),
                            ),
                            SizedBox(height: 10,),
                            Divider()
                          ],
                        );

                      }
                    }
                );
              }else{
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
        ),
      ),
    );
  }
}
