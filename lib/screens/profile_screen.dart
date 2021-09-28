import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi/providers/auth_provider.dart';
import 'package:multi/providers/location.dart';
import 'package:multi/screens/homescreen.dart';
import 'package:multi/screens/mapscreen.dart';
import 'package:multi/screens/my_orders_screen.dart';
import 'package:multi/screens/payment/stripe/credit_card_list.dart';
import 'package:multi/screens/profile_update.dart';
import 'package:multi/screens/welcomescreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  static const String id = 'profile-screen';

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    var locationData = Provider.of<LocationProvider>(context);
    User user = FirebaseAuth.instance.currentUser;
    userDetails.getUserDetails();

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Grocery Store',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon:Icon(Icons.arrow_back_ios,color: Colors.white,),onPressed: (){
          pushNewScreenWithRouteSettings(
            context,
            settings: RouteSettings(
                name: HomeScreen.id),
            screen: HomeScreen(),
            withNavBar: true,
            pageTransitionAnimation:
            PageTransitionAnimation
                .cupertino,
          );

        },
        ),
      ),
      body: userDetails.snapshot == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'MY ACCOUNT',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: Text(
                                      userDetails.snapshot['firstName'] != null ? '${userDetails.snapshot['firstName'][0]}':'P',
                                      style: TextStyle(
                                          fontSize: 50, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 70,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          userDetails.snapshot['firstName'] != null ? '${userDetails.snapshot['firstName']} ${userDetails.snapshot['lastName']}': 'Update You Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white),
                                        ),
                                          if(userDetails.snapshot['email']!=null)
                                          Text('${userDetails.snapshot['email']}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        Text(
                                          user.phoneNumber,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              if (userDetails.snapshot != null)
                                ListTile(
                                  tileColor: Colors.white,
                                  leading: Icon(Icons.location_on,
                                      color: Colors.green),
                                  title: Text(userDetails.snapshot['location'],style: TextStyle(color: Colors.white),),
                                  subtitle: Text(
                                    userDetails.snapshot['address'],
                                    maxLines: 1,style: TextStyle(color: Colors.white),
                                  ),
                                  trailing: SizedBox(
                                    width: 80,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                          side:
                                              BorderSide(color: Colors.white)),
                                      child: Text(
                                        'Change',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        EasyLoading.show(
                                            status: 'Please Wait...');
                                        locationData
                                            .getCurrentPosition()
                                            .then((value) {
                                          if (value != null) {
                                            EasyLoading.dismiss();
                                            pushNewScreenWithRouteSettings(
                                              context,
                                              settings: RouteSettings(
                                                  name: MapScreen.id),
                                              screen: MapScreen(),
                                              withNavBar: false,
                                              pageTransitionAnimation:
                                                  PageTransitionAnimation
                                                      .cupertino,
                                            );
                                          } else {
                                            EasyLoading.dismiss();
                                            print('Permission not allowed');
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 10.0,
                        child: IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            pushNewScreenWithRouteSettings(
                              context,
                              settings: RouteSettings(name: UpdateProfile.id),
                              screen: UpdateProfile(),
                              withNavBar: false,
                              pageTransitionAnimation:
                                  PageTransitionAnimation.cupertino,
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  ListTile(
                    onTap: () {
                      pushNewScreenWithRouteSettings(context,
                          screen: MyOrders(),
                          settings: RouteSettings(name: MyOrders.id),
                          withNavBar: true,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino);
                    },
                    leading: Icon(Icons.history),
                    title: Text('My Orders'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    onTap: () {
                      pushNewScreenWithRouteSettings(context,
                          screen: CreditCardList(),
                          settings: RouteSettings(name: CreditCardList.id),
                          withNavBar: true,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino);
                    },
                    leading: Icon(Icons.credit_card),
                    title: Text('Manage Credit Cards'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.comment_outlined),
                    title: Text('My Rating & Reviews'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.notifications_none),
                    title: Text('Notifications'),
                    horizontalTitleGap: 2,
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.power_settings_new),
                    title: Text('Log Out'),
                    horizontalTitleGap: 2,
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      pushNewScreenWithRouteSettings(
                        context,
                        settings: RouteSettings(name: WelcomeScreen.id),
                        screen: WelcomeScreen(),
                        withNavBar: false,
                        pageTransitionAnimation:
                            PageTransitionAnimation.cupertino,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
