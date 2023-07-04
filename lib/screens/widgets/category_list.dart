import 'package:flutter/material.dart';
import 'package:job/screens/subcategories.dart';

class CategoryList extends StatelessWidget {
 final AsyncSnapshot snapshot;
  const CategoryList({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final category = snapshot.data;
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: category.length,
        itemBuilder: (context, index){
        return GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return SubCategories(cats: category[index]);
            }));
          },
          child: ListTile(
            leading: Image.asset(category[index]['image_string'], height: 30,),
            title: Text(category[index]['master_category']),
          ),
        );
        }
    );
  }
}
