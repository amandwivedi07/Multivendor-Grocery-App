import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi/providers/auth_provider.dart';
import 'package:multi/widgets/near_by_store.dart';
import 'package:multi/widgets/top_pick_store.dart';
import 'package:multi/widgets/image_slider.dart';
import 'package:multi/widgets/my_appbar.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  static const String id = 'Home-Screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {




  @override


  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
     
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context,bool innerBoxIsScrollerd){
          return [
            MyAppBar()
          ];
        },
        body: ListView(
         padding: EdgeInsets.only(top: 0.0),
            children: [
              ImageSlider(),
              Container(
                color: Colors.white,
                  child: TopPickStore(),
              ),
               Padding(
                 padding: const EdgeInsets.only(top: 6),
                 child: NearByStores(),
               )

            ],

        ),
      ),
    );
  }
}
