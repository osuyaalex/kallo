import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../network/json.dart';
import '../../providers/products.dart';
import '../similar_images.dart';

class Most extends StatefulWidget {
  final Future<Koye> discount;
  const Most({super.key,required this.discount});

  @override
  State<Most> createState() => _MostState();
}

class _MostState extends State<Most> {
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
  @override
  Widget build(BuildContext context) {
    String breakUnwantedPart(String name) {
      if (name.length > 35) {
        return name.trim().replaceRange(25, null, '...');
      }
      return name;
    }
    return FutureBuilder(
      future:widget.discount ,
        builder: (context, snapshot){
        List<Pproducts>? products = snapshot.data?.data?.products;
        if(snapshot.hasError){
          return Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(AppLocalizations.of(context)!.somethingWentWrong),
            ),
          );
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xff7F78D8),)
            ),
          );
        }
        if(snapshot.hasData){
          return SizedBox(
            height: 200,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 20,
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
                  final change = listProducts?.priceChange;
                   String percentages;

                   if(listProducts?.priceChange != null){
                     double percent = (1-change!)*100;
                     int percentage = percent.toInt();
                      percentages = percentage.toString();
                   }else{
                     percentages  = '';
                   }


                  if(listProducts?.productCategory != null){
                    if(_matchingCategories.contains(listProducts?.productCategory)){
                      return  GestureDetector(
                        onTap: (){
                          String url = listProducts.productLink??'';
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
                              width: 140,
                              child: Card(
                                elevation: 1,
                                shadowColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 80,
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
                            ),
                            listProducts!.priceChange != null?
                             Positioned(
                               top: 12,
                                 left: 7,
                                 child: Container(
                                   height: 28,
                                   width: 40,
                                   color: Color(0xff161b22),
                                   child: Center(
                                     child: Text('-$percentages%',
                                       style: TextStyle(
                                         color: Colors.white,
                                         fontWeight: FontWeight.w500
                                       ),
                                     ),
                                   ),
                                 )
                             ):Container()
                          ],
                        ),
                      );
                    }else{
                      return GestureDetector(
                        onTap: (){
                          String url = listProducts.productLink??'';
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
                              width: 140,
                              child: Card(
                                elevation: 1,
                                shadowColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13)
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 80,
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
                            listProducts!.priceChange != null?
                            Positioned(
                                top: 12,
                                left: 7,
                                child: Container(
                                  height: 28,
                                  width: 40,
                                  color: Color(0xff161b22),
                                  child: Center(
                                    child: Text('-$percentages%',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ),
                                )
                            ):Container()
                          ],
                        ),
                      );
                    }
                  }else{
                    return  GestureDetector(
                      onTap: (){
                        String url = listProducts.productLink??'';
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
                            width: 140,
                            child: Card(
                              elevation: 1,
                              shadowColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 90,
                                    width: 80,
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
                          ),
                          listProducts!.priceChange != null?
                          Positioned(
                              top: 12,
                              left: 7,
                              child: Container(
                                height: 28,
                                width: 40,
                                color: Color(0xff161b22),
                                child: Center(
                                  child: Text('-$percentages%',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                              )
                          ):Container()
                        ],
                      ),
                    );

                  }
                }
            ),
          );
        }else{
          return Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: CircularProgressIndicator(color: Color(0xff7F78D8),)
            ),
          );
        }
        }

    );
  }
}
