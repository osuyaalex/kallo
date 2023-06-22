import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:job/classes/putables.dart';
import 'package:job/network/json.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';


class Offline extends StatefulWidget {
  final AsyncSnapshot<Koye> snapshot;
  const Offline({Key? key, required this.snapshot}) : super(key: key);

  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  String _latitude = '';
  String _longitude = '';
  double _startValue = 0.0;
  double _endValue = 100000.0;
  bool _isContainerVisible = true;

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
    String breakUnwantedPart(String name) {
      if (name.length > 40) {
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
                    _isContainerVisible = notification.scrollDelta! < 0;
                  });
                }
                return false;
              },
              child: StaggeredGridView.countBuilder(
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
                            borderRadius: BorderRadius.circular(17)
                        ),
                        child: Column(
                          children: [
                            Container(
                              height: 160,
                              width: 180,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(17),
                                  image: DecorationImage(
                                      image: NetworkImage(offline?[index].imageThumbnailUrl?.isNotEmpty == true?
                                      offline![index].imageThumbnailUrl!:
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/No-Image-Placeholder.svg/640px-No-Image-Placeholder.svg.png'
                                      ),
                                      fit: BoxFit.fill
                                  )
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(breakUnwantedPart(offline?[index].productName??''),
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(offline?[index].merchantName??'',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:  [
                                  const Icon(Icons.location_on, color: Colors.red, size: 20,),
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
                                          color: Colors.green
                                      ),
                                    ),
                                    Text(displayValue,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green
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
            AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              top: _isContainerVisible ? 0 : -100, // Adjust the value to control the sliding distance
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(5)
                  ),
                  color:Colors.white.withOpacity(0.9),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap:(){
                          showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)
                              ),
                              builder: (context){
                                return StatefulBuilder(
                                    builder: (BuildContext context, StateSetter setState) {

                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(Icons.close)
                                                  ),

                                                  Text('Sort',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 22
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 12.0),
                                                  child: Text('Price:',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 22
                                                    ),
                                                  ),
                                                ),
                                                Text('Low to high',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 22
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 12.0),
                                                  child: Text('Price:',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 22
                                                    ),
                                                  ),
                                                ),
                                                Text('High to low',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 22
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),

                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 12.0),
                                                  child: Text('Distance:',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 22
                                                    ),
                                                  ),
                                                ),
                                                Text('Closest first',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 22
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                );
                              }
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 110,
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border(
                                top: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                                left: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                                right: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                                bottom: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                              )
                          ),
                          child: Row(
                            children: [
                              Text('Sort:',
                                style: TextStyle(
                                    color: Color(0xff7f78d8),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('',
                                style: TextStyle(
                                    color: Color(0xff7f78d8),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      GestureDetector(
                        onTap:(){
                          showModalBottomSheet(
                              context: context,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)
                              ),
                              builder: (context){
                                return StatefulBuilder(
                                    builder: (BuildContext context, StateSetter setState) {
                                      String displayValue;
                                      if (_startValue == _startValue.floor()) {
                                        //.floor is basically used to convert doubles to integers
                                        displayValue = _startValue.floor().toString();
                                      } else {
                                        displayValue = _startValue.toString();
                                      }
                                      if (_startValue >= 1000) {
                                        final formatter = NumberFormat("#,###");
                                        displayValue = formatter.format(_startValue);
                                      }
                                      String displaySecondValue;
                                      if (_endValue == _endValue.floor()) {
                                        //.floor is basically used to convert doubles to integers
                                        displaySecondValue = _endValue.floor().toString();
                                      } else {
                                        displaySecondValue = _endValue.toString();
                                      }
                                      if (_endValue >= 1000) {
                                        final formatter = NumberFormat("#,###");
                                        displaySecondValue = formatter.format(_endValue);
                                      }
                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: 50,
                                            width: MediaQuery.of(context).size.width,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                              child: Row(
                                                children: [
                                                  IconButton(
                                                      onPressed: (){
                                                        Navigator.pop(context);
                                                      },
                                                      icon: Icon(Icons.close)
                                                  ),

                                                  Text('Filter',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.w800,
                                                        fontSize: 22
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Price',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 22
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: 40,
                                                width: 90,
                                                decoration:BoxDecoration(
                                                    color: Colors.grey.shade400
                                                ),
                                                child: Center(child: Text("${offline?[1].currency??''} ${displayValue}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800
                                                  ),
                                                )),
                                              ),
                                              SizedBox(
                                                width: 14,
                                              ),
                                              Text('to'),
                                              SizedBox(
                                                width: 14,
                                              ),
                                              Container(
                                                height: 40,
                                                width: 90,
                                                decoration:BoxDecoration(
                                                    color: Colors.grey.shade400
                                                ),
                                                child: Center(child: Text("${offline?[1].currency??''} ${displaySecondValue}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800
                                                  ),
                                                )),
                                              ),
                                            ],
                                          ),
                                          RangeSlider(
                                            values: RangeValues(_startValue, _endValue),
                                            min: 0.0,
                                            max: 100000.0,
                                            activeColor:Color(0xff7f78d8),
                                            // inactiveColor:Colors.grey.shade500,
                                            onChanged: ( values) {
                                              setState(() {
                                                _startValue = values.start;
                                                _endValue = values.end;
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Select Merchants',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 22
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text('Select Categories',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 22
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      );
                                    }
                                );
                              }
                          );
                        },
                        child: Container(
                          height: 40,
                          width: 110,
                          padding: EdgeInsets.symmetric(horizontal: 14.0),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border(
                                top: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                                left: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                                right: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                                bottom: BorderSide(
                                    color: Color(0xff7f78d8)
                                ),
                              )
                          ),
                          child: Row(
                            children: [
                              Text('Filter:',
                                style: TextStyle(
                                    color: Color(0xff7f78d8),
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text('',
                                style: TextStyle(
                                    color: Color(0xff7f78d8),
                                    fontWeight: FontWeight.w500
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
            ),
          ],
        ),
      ),
    );
  }
}
