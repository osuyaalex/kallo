import 'package:flutter/material.dart';
import 'package:job/screens/sub_category_results.dart';
import 'package:provider/provider.dart';

import '../providers/animated.dart';

class SubCategories extends StatefulWidget {
  final dynamic cats;
  const SubCategories({super.key, required this.cats});

  @override
  State<SubCategories> createState() => _SubCategoriesState();
}

class _SubCategoriesState extends State<SubCategories> {
  @override
  Widget build(BuildContext context) {
    final animatedProvider = Provider.of<AnimatedProvider>(context);
    final productCategory = widget.cats['product_categories'];
    return Scaffold(
      backgroundColor:Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black,)
        ),
        elevation: 0,
        backgroundColor:Colors.grey.shade100,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 36.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(widget.cats['master_category'],
                      style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width*0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: ListView.builder(
                    itemCount: productCategory.length,
                    itemBuilder: (context, index){
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                return SubCategoryResults(productCategory: productCategory[index]['name']);
                              }));
                            },
                            child: ListTile(
                              title: Text(productCategory[index]['name']),
                              trailing: Icon(Icons.arrow_forward_ios_sharp),

                            ),
                          ),
                          Divider()
                        ],
                      );
                    }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
