import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi/providers/location.dart';
import 'package:multi/screens/landing_screen.dart';
import 'package:multi/screens/main_screen.dart';
import 'package:multi/services/user.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  String smsOtp;
  String verificationId;
  String error = '';
  UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();
  String screen;
  double latitude;
  double longitude;
  String address;
  String location;
  DocumentSnapshot snapshot;

  Future<void> verifyPhone({
    BuildContext context,
    String number,
  }) async {
    this.loading = true;
    notifyListeners();
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = false;
      notifyListeners();
      await _auth.signInWithCredential(credential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = false;
      print(e.code);
      this.error = e.toString();
      notifyListeners();
    };

    final PhoneCodeSent smsOtpSend = (String verId, int resendToken) async {
      this.verificationId = verId;
      smsOtpDialog(context, number);

      //  smsOtpDialog(context, number);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      this.error = e.toString();
      this.loading = false;
      notifyListeners();
      print(e);
    }
  }

  Future<bool> smsOtpDialog(
    BuildContext context,
    String number,
  ) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('Verification Code'),
                SizedBox(
                  height: 6,
                ),
                Text(
                  'Enter 6 digit Code received by SMS',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                )
              ],
            ),
            content: Container(
              height: 85,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  this.smsOtp = value;
                },
              ),
            ),
            actions: [
              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: smsOtp);

                    final User user =
                        (await _auth.signInWithCredential(phoneAuthCredential))
                            .user;
                    if (user != null) {
                      this.loading = false;
                      notifyListeners();
                      _userServices.getUserById(user.uid).then((snapShot) {
                        if (snapShot.exists) {
                          // user already exists
                          if (this.screen == 'Login') {
                   // NEed to check user data already exist in db or not:
                     // if its 'login. no new data so no need to update
                            if(snapShot['address']!=null){
                            Navigator.pushReplacementNamed(
                            context, MainScreen.id);
                            }
                            Navigator.pushReplacementNamed(
                                context, LandingScreen.id);
                          } else {
                            // need to update new selected address
                            print(
                                '${locationData.longitude}:${locationData.latitude}');
                            updateUser(id: user.uid, number: user.phoneNumber);
                            Navigator.pushReplacementNamed(
                                context, MainScreen.id);
                          }
                        } else {
                          // user data does not exists
                          // will create new data in db
                          _createUser(id: user.uid, number: user.phoneNumber);
                          Navigator.pushReplacementNamed(
                              context, LandingScreen.id);
                        }
                      });
                    } else {
                      print('Login Failed');
                    }
                  } catch (e) {
                    this.error = 'Invalid Code';
                    notifyListeners();
                    print(e.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Done',
                    style: TextStyle(color: Colors.deepOrangeAccent)),
              ),
            ],
          );
        }).whenComplete(() {
      this.loading = false;
      notifyListeners();
    });
  }

  void _createUser({String id, String number}) {
    _userServices.createUserData({
      'id': id,
      'firstName': null,
      'lastName': null,
      'email': null,
      'number': number,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'address': this.address,
      'location': this.location,
    });
    this.loading = false;
    notifyListeners();
  }

  void updateUser({
    String id,
    String number,
  }) async {
    try {
      _userServices.updateUserData({
        'id': id,
        'firstName': null,
        'lastName': null,
        'email': null,
        'number': number,
        'latitude': this.latitude,
        'longitude': this.longitude,
        'address': this.address,
        'location': this.location,
      });
      this.loading = false;
      notifyListeners();
      // return true;
    } catch (e) {
      print('Error $e');
      // return false;
    }
  }

  Future<DocumentSnapshot>getUserDetails()async{
    DocumentSnapshot result = await FirebaseFirestore.instance.
    collection('users').doc(_auth.currentUser.uid).get();
    if(result!=null){
      this.snapshot=result;
      notifyListeners();
    }else{
      this.snapshot=null;
      notifyListeners();
    }
    return result;
  }
}
