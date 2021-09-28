import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi/providers/order_provider.dart';
import 'package:multi/services/order_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyOrders extends StatefulWidget {
  static const String id = 'my-orders';
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  OrderServices _orderServices = OrderServices();
  User user = FirebaseAuth.instance.currentUser;

  int tag = 0;
  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Picked Up',
    'On the way',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {

    var _orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(
            'My Orders',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  CupertinoIcons.search,
                  color: Colors.white,
                )),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 56,
              width: MediaQuery.of(context).size.width,
              child: ChipsChoice<int>.single(
                choiceStyle: C2ChoiceStyle(
                    borderRadius:
                    BorderRadius.all(Radius.circular(3))),
                value: tag,
                onChanged: (val) {
                  if(val==0){
                    setState(() {
                      _orderProvider.status=null;
                    });
                  }
                  setState(() {
                    tag=val;
                      _orderProvider.status=options[val];
                  });
                },
                choiceItems: C2Choice.listFrom<int, String>(
                  source: options,
                  value: (i, v) => i,
                  label: (i, v) => v,
                ),
              ),
            ),
            Container(
                child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.orders
                  .where('userId', isEqualTo: user.uid)
              .where('orderStatus',isEqualTo: tag>0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.data.size==0) {
                  //TODO : NO ORDERS SCREEN
                  return Center(
                    child: Text(tag>0 ? 'No ${options[tag]} orders': 'No Orders, Continue shopping'),
                  );
                }

                return Expanded(
                  child: ListView(
                    children: snapshot.data.docs
                        .map((DocumentSnapshot document) {
                      return new Container(
                        color: Colors.white,
                        child: Column(
                          children: [
                            ListTile(
                              horizontalTitleGap: 0,
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 14,
                                child: _orderServices.statusIcon(document),
                              ),
                              title: Text(
                                document['orderStatus'],
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _orderServices.statusColor(document),
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'On ${DateFormat.yMMMd().format(DateTime.parse(document['timeStamp']))}',
                                style: TextStyle(fontSize: 12),
                              ),
                              trailing: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Payment Type : ${document['cod'] == true ? 'Cash On delivery' : 'Paid Online'}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Amount : ₹ ${document['total'].toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),

                            //TODO Delivery BOY CONTACT,live location and deivery body
                            if(document['deliveryBoy']['name'].length>2)
                            Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ListTile(
                                  tileColor: Theme.of(context).primaryColor.withOpacity(.3),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Image.network(document['deliveryBoy']['image'],height: 24,),
                                  ),
                                  title: Text(document['deliveryBoy']['name'], style: TextStyle(fontSize: 14),),
                                  subtitle: Text(_orderServices.statusComment(document),
                                     style: TextStyle(fontSize: 12),),
                                ),
                              ),
                            ),

                            ExpansionTile(
                              title: Text(
                                'Order Details',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                              subtitle: Text('View order details',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.network(
                                            document['products'][index]
                                                ['productImage']),
                                      ),
                                      title: Text(document['products']
                                          [index]['productName']),
                                      subtitle: Text(
                                        '${document['products'][index]['qty']} x ${document['products'][index]['price'].toStringAsFixed(0)} = ${document['products'][index]['total'].toStringAsFixed(0)}',
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12),
                                      ),
                                    );
                                  },
                                  itemCount: document['products'].length,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 8,
                                      left: 12,
                                      right: 12),
                                  child: Card(
                                    elevation: 4,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(.7),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Seller :',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                document['seller']
                                                    ['shopName'],
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          if (int.parse(
                                                  document['discount']) >
                                              0)
                                            Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Discount :',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        '${document['discount']}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 12),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Discount Code :',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        '${document['discountCode']}',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 12),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'Delivery Fee :',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12),
                                              ),
                                              Text(
                                                '${document['deliveryFee'].toString()}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 12),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Divider(
                              height: 3,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            )),
          ],
        ));
  }
}
