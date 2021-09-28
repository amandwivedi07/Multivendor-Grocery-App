import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi/services/cart_services.dart';

class CounterForCard extends StatefulWidget {
  final DocumentSnapshot document;
  CounterForCard(this.document);

  @override
  _CounterForCardState createState() => _CounterForCardState();
}

class _CounterForCardState extends State<CounterForCard> {
  User user = FirebaseAuth.instance.currentUser;
  CartServices _cart = CartServices();
  int _qty = 1;
  String _docId;
  bool _exists = false;
  bool _updating = false;

  getCartData() {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document['productId'])
        .get()
        .then((QuerySnapshot querySnapshot) => {
              if (querySnapshot.docs.isNotEmpty)
                {
                  querySnapshot.docs.forEach((doc) {
                    if (doc['productId'] == widget.document['productId']) {
                      setState(() {
                        _qty = doc['qty'];
                        _docId = doc.id;
                        _exists = true;
                      });
                    }
                  }),
                }
              else
                {
                  setState(() {
                    _exists = false;
                  })
                }
            });
  }

  @override
  void initState() {
    getCartData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _exists
        ? StreamBuilder(
            stream: getCartData(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return Container(
                height: 28,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _updating = true;
                        });
                        if (_qty == 1) {
                          _cart.removeFromCart(_docId).then((value) {
                            setState(() {
                              _updating = false;
                              _exists = false;
                            });
                            //  Need to check after Remove
                            _cart.checkData();
                          });
                        }
                        if (_qty > 1) {
                          setState(() {
                            _qty--;
                          });
                          var total = _qty*widget.document['price'];
                          _cart.updateCartQty(_docId, _qty,total).then((value) {
                            setState(() {
                              _updating = false;
                            });
                          });
                        }
                      },
                      child: Container(
                        child: Icon(
                          _qty == 1 ? Icons.delete_outline : Icons.remove,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                    Container(
                        height: double.infinity,
                        width: 30,
                        color: Colors.pink,
                        child: Center(
                            child: FittedBox(
                                child: _updating
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        _qty.toString(),
                                        style: TextStyle(color: Colors.white),
                                      )))),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _updating = true;
                          _qty++;
                        });
                        var total = _qty*widget.document['price'];
                        _cart.updateCartQty(_docId, _qty,total).then((value) {
                          setState(() {
                            _updating = false;
                          });
                        });
                      },
                      child: Container(
                        child: Icon(
                          Icons.add,
                          color: Colors.pink,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
        : StreamBuilder(
            stream: getCartData(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return InkWell(
                onTap: () {
                  EasyLoading.show(status: 'Adding to Cart');
                  _cart.checkSeller().then((shopName) {
                    if (shopName == widget.document['seller']['shopName']) {
                      setState(() {
                        _exists = true;
                      });
                      _cart.addToCart(widget.document).then((value) {
                        EasyLoading.showSuccess('Added To Cart');
                      });
                      return;
                    }
                    if (shopName == null) {
                      setState(() {
                        _exists = true;
                      });
                      _cart.addToCart(widget.document).then((value) {
                        EasyLoading.showSuccess('Added To Cart');
                      });
                      return;
                    }

                    if (shopName != widget.document['seller']['shopName']) {
                      EasyLoading.dismiss();
                      showDialog(shopName);
                    }
                  });
                },
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(4)),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            });
  }

  showDialog(shopName) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('Replace Cart items?'),
            content: Text('Your Cart contains items from $shopName.'
                ' Do you want to discard the selection and add items from ${widget.document['seller']['shopName']}'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'No',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  )),
              TextButton(
                  onPressed: () {
                         _cart.deleteCart().then((value) {
                           _cart.addToCart(widget.document).then((value) {
                             setState(() {
                               _exists = true;
                             });
                             Navigator.pop(context);
                           });
                         });

                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  )),
            ],
          );
        });
  }
}
