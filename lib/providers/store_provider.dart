import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:multi/screens/welcomescreen.dart';
import 'package:multi/services/store_services.dart';
import 'package:multi/services/user.dart';

class StoreProvider with ChangeNotifier{

  StoreServices _storeServices=StoreServices();
  UserServices _userServices=UserServices();
  User user = FirebaseAuth.instance.currentUser;
  var userLatitude=0.0;
  var userLongitude=0.0;
  String selectedStore;
  String selectedStoreId;
  DocumentSnapshot storeDetails;
  String distance;
  String selectedProductsCategory;
  String selectedSubCategory;

  getSelectedStore(storeDetails,distance){
    this.storeDetails=storeDetails;
    this.distance=distance;
    notifyListeners();
  }

  selectedCategory(category){
    this.selectedProductsCategory=category;
    notifyListeners();
  }
  selectedCategorySub(subCategory){
    this.selectedSubCategory=subCategory;
    notifyListeners();
  }



  Future<void>getUserLocationData(context)async{
    _userServices.getUserById(user.uid).then((result){
      if(user!=null){

           this.userLatitude = result['latitude'];
            this.userLongitude = result['longitude'];
            notifyListeners();

        
      }else{

        Navigator.pushReplacementNamed(context, WelcomeScreen.id);
      }
    });
  }
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {

      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}