import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/products.dart';
import '../similar_images.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';


class LastSeen extends StatefulWidget {
  const LastSeen({super.key});

  @override
  State<LastSeen> createState() => _LastSeenState();
}

class _LastSeenState extends State<LastSeen> {
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
    return  Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          int? itemCount = productProvider.count;
          int maxItemCount = 20;
          int? displayedItemCount = itemCount! < maxItemCount ? itemCount : maxItemCount;
          return SizedBox(
            height: 200,
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
    );
  }
}
