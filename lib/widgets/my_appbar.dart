import 'package:flutter/material.dart';
import 'package:multi/providers/location.dart';
import 'package:multi/screens/mapscreen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatefulWidget {


  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  String _location= '';
  String _address= '';
  @override
  void initState() {
    getPrefs();
    super.initState();
  }
  getPrefs() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String location=prefs.getString('location');
    String address =prefs.getString('address');
    setState(() {
      _location=location;
      _address=address;
    });
  }
  @override
  Widget build(BuildContext context) {
    final locationData = Provider.of<LocationProvider>(context);
    return SliverAppBar(
      //now App Bar is scrollable
      automaticallyImplyLeading: false,
      elevation: 0.0,
      floating: true,
      snap: true,
      title: TextButton(
        onPressed: () {
          locationData.getCurrentPosition().then((value) {
            if(value!=null){
              pushNewScreenWithRouteSettings(
                context,
                settings: RouteSettings(name: MapScreen.id),
                screen: MapScreen(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );
            }else{
              print('Permission not allowed');
            }
          });

        }, 
        child: Column(

          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(

              children: [
                Flexible(
                  child: Text(
                    _address==null?'Press Here to set Delivery Location':_address,
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                    overflow:TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                )
              ],
            ),
            Flexible(child: Text(_address,overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white,fontSize: 12),
            )),
          ],
        ),
      ),
       bottom: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.all(10.0),  //16
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide: BorderSide.none),
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
