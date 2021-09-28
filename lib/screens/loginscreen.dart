import 'package:flutter/material.dart';
import 'package:multi/providers/auth_provider.dart';
import 'package:multi/providers/location.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'Login-Screen';
  const LoginScreen({key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _phoneNumberController = TextEditingController();
  bool _validPhoneNumber = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Container(
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
                      setState(() {
                        _validPhoneNumber = true;
                      });
                    } else {
                      setState(() {
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
                            setState(() {
                              auth.loading = true;
                              auth.screen = 'MapScreen';
                              auth.latitude = locationData.latitude;
                              auth.longitude = locationData.longitude;
                              auth.address =
                                  locationData.selectedAddress.addressLine;
                            });
                            String number = '+91${_phoneNumberController.text}';
                            auth
                                .verifyPhone(
                              context: context,
                              number: number,
                            )
                                .then((value) {
                              _phoneNumberController.clear();
                              setState(() {
                                auth.loading = false;
                              });
                            });
                          },
                          color: _validPhoneNumber
                              ? Colors.deepOrangeAccent
                              : Colors.grey,
                          child: auth.loading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white))
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
        ),
      ),
    );
  }
}
