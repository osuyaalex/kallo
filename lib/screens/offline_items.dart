import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:job/classes/putables.dart';
import 'package:job/network/json.dart';
import 'package:provider/provider.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../providers/animated.dart';


class Offline extends StatefulWidget {
  final AsyncSnapshot<Koye> snapshot;
  const Offline({Key? key, required this.snapshot}) : super(key: key);

  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  String _latitude = '';
  String _longitude = '';


  Functions _functions = Functions();
  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print(position.latitude);
    print(position.longitude);

    if (!mounted) return;
    setState(() {
      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();
    });
  }
  _requestLocationPermission()async{
    await _functions.requestLocationPermission();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _requestLocationPermission();
    _getCurrentLocation();

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
    List? products = widget.snapshot.data!.data!.products;
    var offline = products?.where((element) => element.merchantType == "offline").toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification){
                if(notification is ScrollUpdateNotification){
                  // Check the direction of scroll and update the visibility of the container
                  setState(() {
                    animatedProvider.myVariable = notification.scrollDelta! < 0;
                  });
                }
                return false;
              },
              child: StaggeredGridView.countBuilder(
                physics: ClampingScrollPhysics(),
                  crossAxisCount: 2,
                  itemCount: offline?.length,
                  itemBuilder: (context, index){
                    // final doubleValue = offline[index]['price'];
                    // // the indexOf() method is to check if there are any digits after the decimal point
                    // // If there is no decimal point, it will be set to -1.
                    // final decimalIndex = doubleValue.toString().indexOf('.');
                    // final textToDisplay = decimalIndex == -1
                    //     ? doubleValue.toStringAsFixed(0)
                    //     : doubleValue.toStringAsFixed(2);
                    final item = offline?[index].price;
                    // final text = item.endsWith('.0') ? item.substring(0, item.length -2) : item;
                    final double number = double.tryParse(item!) ?? 0.0;
                    String displayValue;
                    if (number == number.floor()) {
                      //.floor is basically used to convert doubles to integers
                      displayValue = number.floor().toString();
                    } else {
                      displayValue = number.toString();
                    }
                    if (number >= 1000) {
                      final formatter = NumberFormat("#,###");
                      displayValue = formatter.format(number);
                    }
                    final distance = Functions().calculateDistance(_latitude, _longitude, offline?[index].merchantLongitude??'', offline?[index].merchantLatitude??'');
                    return SizedBox(
                      height: 270,
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
                                  borderRadius: BorderRadius.circular(13),
                                  image: DecorationImage(
                                      image: NetworkImage(offline?[index].imageThumbnailUrl?.isNotEmpty == true?
                                      offline![index].imageThumbnailUrl!:
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                      ),
                                      fit: BoxFit.fill
                                  )
                              ),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SizedBox(
                                width: 180,
                                child: Text(breakUnwantedPart(offline?[index].productName??''),
                                  style: const TextStyle(
                                      fontSize: 15,

                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: SizedBox(
                                width: 180,
                                child: Text(offline?[index].merchantName??'',
                                  style: const TextStyle(
                                      color: Color(0xff161b22),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:  [
                                  const Icon(Icons.location_on, color: Colors.grey, size: 20,),
                                  Text(distance != 0 ?
                                  '${distance.toStringAsFixed(2)} miles':'--',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: SizedBox(
                                height: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(offline?[index].currency??'',
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
                    );
                  },
                  staggeredTileBuilder: (context) => const StaggeredTile.fit(1)
              ),
            ),

          ],
        ),
      ),
    );
  }
}
