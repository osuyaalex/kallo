import 'package:flutter/material.dart';
import 'package:job/screens/searched_items.dart';

import '../network/json.dart';
import '../network/network.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<Koye> productName = Network().getProductsName(_name);
  String _name = '';


  @override
  void initState() {
    // TODO: implement initState
    productName = Network().getProductsName(_name);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xfffafafa),
        elevation: 0,
        toolbarHeight:MediaQuery.of(context).size.height*0.12,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height*0.06,
              width: MediaQuery.of(context).size.width *0.65,
              child: TextFormField(
                onChanged: (v){
                  _name = v;
                },
                validator: (v){
                  if(v!.isEmpty){
                    return 'Add a search value';
                  }
                },
                decoration: InputDecoration(
                  hintText: '                 Search Kallo...',
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
            const SizedBox(
              width: 14,
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  productName = Network().getProductsName(_name);
                });
              },
              child: Container(
                height: 40,
                width: MediaQuery.of(context).size.width*0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                    color: const Color(0xff7F78D8),
                ),
                child: const Center(
                  child: Text('Search',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            )
          ],
        ) ,
      ),
      body: FutureBuilder(
        future: productName,
        builder: (context, snapshot){
          if(snapshot.hasError){
            return const Center(
              child: Text('Something went wrong',
                  style: TextStyle(
                      color: Color(0xff7F78D8),
                      fontWeight: FontWeight.w800,
                      fontSize: 14
                  )
              ),
            );
          }
          if(!snapshot.hasData){
            return const Center(
                child: Text('No products available',
                  style: TextStyle(
                      color: Color(0xff7F78D8),
                    fontWeight: FontWeight.w800,
                    fontSize: 14
                  )
                ),
            );
          }
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(color: Color(0xff7F78D8),),
            );
          }else if(snapshot.hasData){
            return SearchedItems(snapshot: snapshot,);
          }else{
            return const Center(
              child: CircularProgressIndicator(color: Colors.black,),
            );
          }
        }
    ),
    );
  }
}
