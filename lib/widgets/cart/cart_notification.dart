import 'package:flutter/material.dart';
import 'package:multi/providers/cart_provider.dart';
import 'package:multi/screens/cart_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class CartNotification extends StatefulWidget {
 

  @override
  _CartNotificationState createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {


  @override
  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<CartProvider>(context);
    _cartProvider.getCartTotal();
    _cartProvider.getShopName();

    return Visibility(
      visible: _cartProvider.distance<=10000 ?_cartProvider.cartQty>0 ? true : false : false,
      child: Container(
        height:45,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.deepOrange,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(12),topLeft: Radius.circular(12),
          )
        ),

        child: Padding(
          padding: const EdgeInsets.only(left: 10,right: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_cartProvider.cartQty} ${_cartProvider.cartQty==1
                              ? 'Items'
                              : 'Items' }', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        ),
                        Text(' | ',style: TextStyle(color: Colors.white),),
                        Text('₹ ${_cartProvider.subTotal.toStringAsFixed(0)}',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      ],
                    ),
                    if(_cartProvider.document!=null)
                    Text(
                      'From  ${_cartProvider.document['shopName']}', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),
                    )
                  ],
                ),
              ),
              InkWell(
                onTap: (){
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(name: CartScreen.id),
                    screen: CartScreen(document:_cartProvider.document,),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  child: Row(
                    children: [
                      Text(
                        'View Cart', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5,),
                      Icon(Icons.shopping_bag_outlined,color: Colors.white,)
                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
