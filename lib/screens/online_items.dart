import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job/network/json.dart';
import 'package:job/providers/animated.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';
import 'package:url_launcher/url_launcher.dart';


class Online extends StatefulWidget {
  final AsyncSnapshot<Koye> snapshot;
  const Online({Key? key, required this.snapshot}) : super(key: key);

  @override
  State<Online> createState() => _OnlineState();
}

class _OnlineState extends State<Online> {

  String _latitude = '';
  String _longitude = '';
  // void _getCurrentLocation() async {
  //   final position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //   print(position.latitude);
  //   print(position.longitude);
  //
  //   setState(() {
  //     _latitude = position.latitude.toString();
  //     _longitude = position.longitude.toString();
  //   });
  // }
  // _requestLocationPermission()async{
  //   await _functions.requestLocationPermission();
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _requestLocationPermission();
    // _getCurrentLocation();
  }
  
  @override
  Widget build(BuildContext context) {
    final animatedProvider = Provider.of<AnimatedProvider>(context);
    String breakUnwantedPart(String name) {
      if (name.length > 35) {
        return name.trim().replaceRange(25, null, '...');
      }
      return name;
    }
    List<Pproducts>? products = widget.snapshot.data!.data!.products;
    var online = products?.where((element) => element.merchantType == "online").toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification){
          if(notification is ScrollUpdateNotification){
            // Check the direction of scroll and update the visibility of the container
              if(online!.isNotEmpty){
                animatedProvider.myVariable = notification.scrollDelta! < 0;
              }else{
                animatedProvider.myVariable = notification.scrollDelta! > 0;
              }
          }
          return false;
        },
        child: StaggeredGridView.countBuilder(
          physics: ClampingScrollPhysics(),
            crossAxisCount: 2,
            itemCount: online?.length,
            itemBuilder: (context, index){
              // final doubleValue = offline[index]['price'];
              // // the indexOf() method is to check if there are any digits after the decimal point
              // // If there is no decimal point, it will be set to -1.
              // final decimalIndex = doubleValue.toString().indexOf('.');
              // final textToDisplay = decimalIndex == -1
              //     ? doubleValue.toStringAsFixed(0)
              //     : doubleValue.toStringAsFixed(2);
              final item = online?[index].price;
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
                displayValue = 'N/A'; // Handle the case when item is neither a double nor a string
              }
              final addRow = online?[index];
              return GestureDetector(
                onTap: (){
                  String url = addRow?.productLink??'';
                  Uri uri = Uri.parse(url);
                  try{
                    launchUrl(uri);
                  }catch(e){
                    print(e.toString());
                  }
                },
                child: SizedBox(
                  height: 310,
                  width: 250,
                  child: Card(
                    elevation: 1,
                    shadowColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 160,
                          width: 180,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: NetworkImage(addRow?.imageThumbnailUrl?.isNotEmpty == true?
                                  online![index].imageThumbnailUrl!:
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
                            child: Text(breakUnwantedPart(addRow?.productName??''),
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
                              Text(addRow?.merchantName??'',
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
                                Text(addRow?.currency??'',
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
            },
            staggeredTileBuilder: (context) => const StaggeredTile.fit(1)
        ),
      ),
    );
  }
}
