import 'package:flutter/material.dart';

class SubCategories extends StatelessWidget {
  final dynamic cats;
  const SubCategories({super.key, required this.cats});

  @override
  Widget build(BuildContext context) {
    final productCategory = cats['product_categories'];
    return Scaffold(
      backgroundColor:Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:Colors.grey.shade100,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 36.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Sub Category',
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
            Center(
              child: Container(
                height: 57.0 * productCategory.length,
                width: MediaQuery.of(context).size.width*0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: ListView.builder(
                    itemCount: productCategory.length,
                    itemBuilder: (context, index){
                      return ListTile(
                        title: Text(productCategory[index]['name']),
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
