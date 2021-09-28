import 'package:flutter/material.dart';
import 'package:multi/providers/auth_provider.dart';
import 'package:multi/providers/location.dart';
import 'package:multi/screens/firstlook.dart';
import 'package:multi/screens/mapscreen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'Welcome-Screen';
  const WelcomeScreen({key}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    TextEditingController _phoneNumberController = TextEditingController();
    bool _validPhoneNumber = false;
    void showBottomSheet(context) {
      showModalBottomSheet(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, StateSetter myState) {
            return Container(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: '${auth.error}Please Try Again' == 'Invalid Code'
                          ? true
                          : false,
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              auth.error,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Text(
                      'Enter Your Phone Number',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextField(
                      style: TextStyle(color: Colors.deepOrangeAccent),
                      decoration: InputDecoration(
                        prefixText: '+91',
                        prefixStyle: TextStyle(color: Colors.deepOrangeAccent),
                        labelText: 'Enter Your Mobile Number',
                        labelStyle: TextStyle(color: Colors.deepOrangeAccent),
                      ),
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      controller: _phoneNumberController,
                      onChanged: (value) {
                        if (value.length == 10) {
                          myState(() {
                            _validPhoneNumber = true;
                          });
                        } else {
                          myState(() {
                            _validPhoneNumber = false;
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: _validPhoneNumber ? false : true,
                            // ignore: deprecated_member_use
                            child: FlatButton(
                              onPressed: () {
                                myState(() {
                                  auth.loading = true;
                                });
                                String number =
                                    '+91${_phoneNumberController.text}';
                                auth
                                    .verifyPhone(
                                  context: context,
                                  number: number,
                                )
                                    .then((value) {
                                  _phoneNumberController.clear();
                                  auth.loading = false;
                                });
                              },
                              color: _validPhoneNumber
                                  ? Colors.deepOrangeAccent
                                  : Colors.grey,
                              child: auth.loading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.deepOrangeAccent))
                                  : Text(
                                      _validPhoneNumber
                                          ? 'CONTINUE'
                                          : 'ENTER PHONE NUMBER',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ).whenComplete(() {
        setState(() {
          auth.loading = false;
          _phoneNumberController.clear();
        });
      });
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              right: 0.0,
              top: 10.0,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'SKIP',
                  style: TextStyle(color: Colors.deepOrangeAccent),
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: FirstLook(),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    'Ready to order grocery from Your nearest market..?',
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    backgroundColor: Colors.deepOrangeAccent,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: locationData.loading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Set Your Delivery Location',
                          style: TextStyle(color: Colors.white),
                        ),
                  onPressed: () async {
                    setState(() {
                      locationData.loading = true;
                    });

                    await locationData.getCurrentPosition();
                    if (locationData.permissionAllowed == true) {
                      Navigator.pushReplacementNamed(context, MapScreen.id);

                      setState(() {
                        locationData.loading = false;
                      });
                    } else {
                      print('Permission Not Allowed');
                      setState(() {
                        locationData.loading = false;
                      });
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                // ignore: deprecated_member_use
                TextButton(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already a Customer ? ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: 'Login',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black))
                      ],
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      auth.screen = 'Login';
                    });
                    showBottomSheet(context);
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
