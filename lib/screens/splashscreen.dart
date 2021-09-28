import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:multi/screens/landing_screen.dart';
import 'package:multi/screens/main_screen.dart';
import 'package:multi/screens/welcomescreen.dart';
import 'package:multi/services/user.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SplashScreen extends StatefulWidget {
  static const String id = 'Splash-Screen';
  const SplashScreen({key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

User user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {

    Timer(
        Duration(
            seconds: 2
        ),(){
      FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user == null) {
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        } else {
       getUserData();
        }
      });
    }
    );

    super.initState();
  }
  getUserData()async{
    UserServices _userServices=UserServices();
    _userServices.getUserById(user.uid).then((result){
    //  check location details has or not
      if(result['address']!=null){
      //  if address details exists

        updatePrefs(result);
      }
    //  if address details does not exist
      Navigator.pushReplacementNamed(context, LandingScreen.id);
  });
  }

Future <void>updatePrefs(result) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble('latitude', result['latitude']);
  prefs.setDouble('longitude', result['longitude']);
  prefs.setString('address', result['address']);
  prefs.setString('location',result['location']);
//  after update prefs, Navigate to home screen
Navigator.pushReplacementNamed(context, MainScreen.id);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/logo.png',),
            Text('Grocery Store',style: TextStyle(fontSize:15,fontWeight: FontWeight.w700),)
          ],
        ),
      ),
    );
  }
}
