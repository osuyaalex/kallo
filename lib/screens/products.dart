
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:job/network/json.dart';
import 'package:job/network/network.dart';
import 'package:job/screens/demo.dart';
import 'package:job/screens/offline_items.dart';
import 'package:job/screens/online_items.dart';
import 'package:job/screens/search.dart';

class Products extends StatefulWidget {

  const Products({Key? key}) : super(key: key);

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  late Future<Koye> products = Network().getProducts(_scanBarcode);

  String _scanBarcode = 'Unknown';
  bool _showOfflineItems = true;
  GlobalKey<FormState> _key = GlobalKey<FormState>();

  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    products = Network().getProducts(_scanBarcode);
    products.then((value){
      print('the prducy issssssssssssssss ${value.data}');
      //snack(context, value.data.)
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _key,
      child: Scaffold(
        backgroundColor:  Color(0xfffafafa),
        appBar: AppBar(
          backgroundColor: const Color(0xfffafafa),
          elevation: 0,
          toolbarHeight:MediaQuery.of(context).size.height*0.24,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7)
                      ),
                      elevation: 5,
                      shadowColor: Color(0xff7F78D8).withOpacity(0.6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.asset('asset/Kallo logo dark background zoomed in png.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return const DemoScreen();
                      }));
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.06,
                      width: MediaQuery.of(context).size.width *0.77,
                      child: TextFormField(
                        enabled: false,
                        onChanged: null,
                        decoration: InputDecoration(
                            hintText: 'Search Kallo...',
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
                  ),
                  IconButton(
                      onPressed: (){
                        scanBarcodeNormal().then((value){
                          setState(() {
                            products = Network().getProducts(_scanBarcode);
                          });
                        });
                      },
                      icon: SvgPicture.asset('asset/barcode-scan-svgrepo-com.svg')
                  ),
                ],
              ),
              // Text(_scanBarcode),
              const SizedBox(
                height: 10,
              ),
              FlutterToggleTab(
                height: MediaQuery.of(context).size.height*0.055,
                width: 70,
                borderRadius: 30,
                selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600
                ),
                unSelectedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400
                ),
                selectedBackgroundColors: const [
                  Color(0xff7F78D8)
                ],
                labels: const ["Shops near me", "Online shops"],
                icons: [Icons.location_on_outlined, Icons.directions_bus_rounded],
                selectedIndex: _showOfflineItems ? 0 : 1,
                selectedLabelIndex: (index) {
                  setState(() {
                    _showOfflineItems = index == 0;
                  });
                },
              ),
            ],
          ) ,
        ),
        body: FutureBuilder(
            future: products,
            builder: (context, snapshot){
              if(snapshot.hasError){
                return Center(
                    child: GestureDetector(
                      onTap: (){
                        scanBarcodeNormal().then((value){
                          setState(() {
                            products = Network().getProducts(_scanBarcode);
                          });
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          height: 40,
                          width: 120,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                              color: const Color(0xff7F78D8).withOpacity(0.8),
                          ),
                          child: const Text('Tap to scan item',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14
                            ),
                          ),
                        ),
                      ),
                    )
                );
              }
              if(!snapshot.hasData){
                return Center(
                    child: GestureDetector(
                      onTap: (){
                        scanBarcodeNormal().then((value){
                          setState(() {
                            products = Network().getProducts(_scanBarcode);
                          });
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          height: 40,
                          width: 120,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xff7F78D8).withOpacity(0.5),
                          ),
                          child: const Center(
                            child: Text('Tap to scan item',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                );
              }
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xff7F78D8),),
                );
              }else if(snapshot.hasData){
                return _showOfflineItems ?
                Offline(snapshot: snapshot,):Online(snapshot: snapshot,);
              }else{
                return const Center(
                  child: CircularProgressIndicator(color: Colors.black,),
                );
              }
            }
        ),
      ),
    );
  }

}
