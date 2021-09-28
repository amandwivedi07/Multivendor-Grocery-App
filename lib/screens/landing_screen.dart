import 'package:flutter/material.dart';
import 'package:multi/providers/location.dart';
import 'package:multi/screens/mapscreen.dart';

class LandingScreen extends StatefulWidget {

  static const String id = 'landing-screen';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LocationProvider _locationProvider=LocationProvider();

  bool _loading=false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
              'Delivery Address not set',style: TextStyle(
                fontWeight: FontWeight.bold

              ),),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Please Update your Delivery Location to find nearest stores for you',textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            CircularProgressIndicator(),

            Container(
              width: 600,
                child: Image.asset('images/city.png',fit: BoxFit.fill,color: Colors.black12,),
            ),

            _loading?CircularProgressIndicator():
            TextButton(onPressed: () async {
              setState(() {
                _loading=true;
              });
             await _locationProvider.getCurrentPosition();
             if(_locationProvider.permissionAllowed==true){
               Navigator.pushReplacementNamed(context, MapScreen.id);
             }else{
               Future.delayed(Duration(seconds: 3),(){
                 if(_locationProvider.permissionAllowed==false){
                   print('Permission not allowed');
                   setState(() {
                     _loading=false;
                   });
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                     content:Text('Please allow permission to find nearest stores to you'),

                   ));
               }
               });

             }
            },
              child: Text('Set Your Location'),
              style: TextButton. styleFrom(
                primary: Colors.black,
                backgroundColor: Colors.deepOrangeAccent,
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
