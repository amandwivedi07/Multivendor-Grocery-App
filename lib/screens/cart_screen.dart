import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi/providers/auth_provider.dart';
import 'package:multi/providers/cart_provider.dart';
import 'package:multi/providers/coupon_provider.dart';
import 'package:multi/providers/location.dart';
import 'package:multi/providers/order_provider.dart';
import 'package:multi/screens/mapscreen.dart';
import 'package:multi/screens/payment/stripe/payment_Home.dart';
import 'package:multi/screens/profile_screen.dart';
import 'package:multi/services/cart_services.dart';
import 'package:multi/services/order_service.dart';
import 'package:multi/services/store_services.dart';
import 'package:multi/services/user.dart';
import 'package:multi/widgets/cart/cart_list.dart';
import 'package:multi/widgets/cart/cod_toggle.dart';
import 'package:multi/widgets/cart/coupon_widget.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  static const String id = 'cart-screen';
  final DocumentSnapshot document;
  CartScreen({this.document});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  StoreServices _store = StoreServices();
  UserServices _userServices = UserServices();
  OrderServices _orderServices = OrderServices();
  CartServices _cartServices = CartServices();

  User user =  FirebaseAuth.instance.currentUser;
  DocumentSnapshot doc;
  var textStyle = TextStyle(color: Colors.grey);
  int deliveryFee=50;
  String _location= '';
  String _address= '';
  bool _loading=false;
  bool _checkingUser = false;
  double discount = 0;

  @override
  void initState() {
    getPrefs();
    _store.getShopDetails(widget.document['sellerUid']).then((value){
      setState(() {
        doc = value;

      });
    });
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
    var _cartProvider = Provider.of<CartProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);
    var userDetails = Provider.of<AuthProvider>(context);
    userDetails.getUserDetails();
    var _coupon = Provider.of<CouponProvider>(context);
    userDetails.getUserDetails().then((value) {
      double subTotal = _cartProvider.subTotal;
      double discountRate = _coupon.discountRate/100;

      setState(() {
        discount = subTotal*discountRate;
      });
    });
    

    var _payable = _cartProvider.subTotal+deliveryFee-discount;
    final orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[200],
      bottomSheet: userDetails.snapshot ==null ? Container() : Container(
        height:140,
        color: Colors.blueGrey[900],
        child: Column(
          children: [
            Container(
              height: 80,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Deliver to this address: ',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),)),
                        InkWell(
                            onTap: (){
                              setState(() {
                                _loading=true;
                              });
                              locationData.getCurrentPosition().then((value) {
                                setState(() {
                                  _loading=false;
                                });
                                if(value!=null){
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: RouteSettings(name: MapScreen.id),
                                    screen: MapScreen(),
                                    withNavBar: false,
                                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                                  );
                                }else{
                                  setState(() {
                                    _loading=false;
                                  });
                                  print('Permission not allowed');
                                }
                              });
                            },
                            child: _loading? CircularProgressIndicator(): Text('Change',style: TextStyle(color: Colors.red,fontSize: 12),))
                      ],
                    ),
                    Text(userDetails.snapshot['firstName']!=null ? '${userDetails.snapshot['firstName']} ${userDetails.snapshot['lastName']}  $_location,$_address'  : '$_location,$_address',style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.bold),),

                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 20,right: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹ ${_payable.toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                        Text('(Including Taxes)',style: TextStyle(color: Colors.grey,fontSize: 10),)
                      ],
                    ),


                    //Checkout



                    ElevatedButton(
                        style:ElevatedButton.styleFrom(
                          primary: Colors.deepOrangeAccent,
                          onPrimary: Colors.white,
                          onSurface: Colors.grey,
                        ),
                        onPressed: (){
                          EasyLoading.show(status: 'Please Wait...');
                          _userServices.getUserById(user.uid).then((value) {
                            if(value['firstName']==null){
                              EasyLoading.dismiss();
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(name: ProfileScreen.id),
                                screen: ProfileScreen(),
                                pageTransitionAnimation: PageTransitionAnimation.cupertino,
                              );
                            }else {
                              EasyLoading.dismiss();
                              /*EasyLoading.show(status: 'Please Wait...');*/
                              if(_cartProvider.cod==false){

                                orderProvider.totalAmount(_payable,widget.document['shopName']
                                ,userDetails.snapshot['email']
                                );
                                Navigator.pushNamed(context, PaymentHome.id).whenComplete((){
                                  if(orderProvider.success==true){
                                    _saveOrder(_cartProvider,_payable,_coupon);
                                  }
                                } );
                                //pay online

                              }else{
                                _saveOrder(_cartProvider,_payable,_coupon);
                              }



                            }
                          });
                        },
                        child: _checkingUser ? CircularProgressIndicator() : Text('Checkout',style: TextStyle(fontWeight: FontWeight.bold),)
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context,bool innerBoxIsScrollerd){
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              iconTheme: IconThemeData(
                  color: Colors.black
              ),
              backgroundColor: Colors.white,

              elevation: 0.0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.document['shopName'],style: TextStyle(fontSize: 16,color: Colors.black),
                  ),
                  Row(
                    children: [
                      Text('${_cartProvider.cartQty}'
                          ' ${_cartProvider.cartQty >1 ? 'Items, ' : 'Item, '} '
                        ,style: TextStyle(fontSize: 10,color: Colors.grey),
                      ),
                      Text('To pay : ${_payable
                          .toStringAsFixed(0)}'
                        ,style: TextStyle(fontSize: 10,color: Colors.grey),
                      ),
                    ],
                  )

                ],
              ),
            )
          ];
        },
        body: doc==null ? Center(child: CircularProgressIndicator()) : _cartProvider.cartQty>0
            ? SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 80),
          child: Container(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        tileColor: Colors.white,
                        leading: Container(
                          height: 60, width: 60,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(doc['imageUrl'],fit: BoxFit.cover,)),
                        ),
                        title: Text(doc['shopName']),
                        subtitle: Text(doc['address'],maxLines: 1,style: TextStyle(
                          fontSize: 12,color: Colors.grey
                        ),
                        ),
                      ),
                      CodToggleSwitch(),
                      Divider(color: Colors.grey[300],),
                    ],
                  ),
                ),


                        CartList(document: widget.document,),



                //Coupon

                CouponWidget(doc['uid']),



                //Bill Details Card
                Padding(
                  padding: const EdgeInsets.only(right: 4.0,left: 4,top: 4,bottom: 80),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Bill Details',style: TextStyle(fontWeight: FontWeight.bold),),
                         SizedBox(height: 10,),
                            Row(children: [
                              Expanded(child: Text('Basket Value',style: textStyle,)),
                              Text('₹ ${_cartProvider.subTotal.toStringAsFixed(0)}',style: textStyle,),

                            ],),
                            SizedBox(height: 10,),
                            if(discount>0)
                            Row(children: [
                              Expanded(child: Text('Discount',style: textStyle,)),
                              Text('₹ ${discount.toStringAsFixed(0)}',style: textStyle,),

                            ],),
                            SizedBox(height: 10,),
                            Row(children: [
                              Expanded(child: Text('Delivery Fee',style: textStyle,)),
                              Text('₹  $deliveryFee',style: textStyle,),

                            ],),
                            Divider(color: Colors.grey,),
                            Row(children: [
                              Expanded(child: Text('Total amount payable',style: TextStyle(fontWeight: FontWeight.bold),)),
                              Text('₹  ${_payable.toStringAsFixed(0)}',style: TextStyle(fontWeight: FontWeight.bold)),

                            ],
                            ),
                            SizedBox(height: 10,),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).primaryColor.withOpacity(.3)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(child: Text('Total Saving',style: TextStyle(color: Colors.green),)),
                                    Text('₹ ${_cartProvider.saving.toStringAsFixed(0)}', style: TextStyle(color: Colors.green))

                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
      ),
        ): Center(child: Text('Cart Empty, Continue shopping'),),
    ),
    );
  }
    _saveOrder(CartProvider cartProvider,payable,CouponProvider coupon){
    _orderServices.saveOrder({
        'products': cartProvider.cartList,
      'userId': user.uid,
      'deliveryFee': deliveryFee,
      'total': payable,
      'discount': discount.toStringAsFixed(0),
      'cod': cartProvider.cod,
      'discountCode': coupon.document==null ? null : coupon.document['title'],
      'seller':{
          'shopName': widget.document['shopName'],
            'sellerId': widget.document['sellerUid'],
      },
      'timeStamp': DateTime.now().toString(),
      'orderStatus': 'Ordered',
      'deliveryBoy': {
          'name': '',
        'phone': '',
        'location': '',
      },

    }).then((value) {
      _cartServices.deleteCart().then((value) {
        _cartServices.checkData().then((value) {
          EasyLoading.showSuccess('Your Order is submitted');
          Navigator.pop(context);
        });
      });

    });

    }
}
