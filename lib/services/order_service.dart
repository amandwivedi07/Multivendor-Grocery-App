
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class OrderServices{
    CollectionReference orders = FirebaseFirestore.instance.collection('orders');

    Future<DocumentReference> saveOrder(Map<String,dynamic>data){
      var result = orders.add(
          data
      );
      return result;
    }
    Color statusColor(DocumentSnapshot document){
      if(document['orderStatus']=='Accepted'){
        return Colors.blueGrey[400];
      }
      if(document['orderStatus']=='Rejected'){
        return Colors.red;
      }
      if(document['orderStatus']=='Picked Up'){
        return Colors.pink[900];
      }

      if(document['orderStatus']=='On The way'){
        return Colors.purple[900];
      }
      if(document['orderStatus']=='Delivered'){
        return Colors.green;
      }
      return Colors.orange;

    }

    Icon statusIcon(DocumentSnapshot document){
      if(document['orderStatus']=='Accepted'){
        return Icon(Icons.assignment_turned_in_outlined,color: statusColor(document),);
      }

      if(document['orderStatus']=='Picked Up'){
        return  Icon(Icons.cases,color: statusColor(document),);
      }

      if(document['orderStatus']=='On the way'){
        return Icon(Icons.delivery_dining,color: statusColor(document),);
      }
      if(document['orderStatus']=='Delivered'){
        return Icon(Icons.shopping_bag_outlined,color: statusColor(document),);
      }
      return Icon(Icons.assignment_turned_in_outlined,color: statusColor(document),);

    }

    String statusComment(document){
      if(document['orderStatus']=='Picked Up'){
        return 'Your Order is Picked by ${document['deliveryBoy']['name']}';
      }
      if(document['orderStatus']=='On the way'){
        return 'Your delivery person ${document['deliveryBoy']['name']} is on the way';
      }
      if(document['orderStatus']=='Delivered'){
        return 'Your order is now completed';
      }

      return 'Mr. ${document['deliveryBoy']['name']} is on the way to Pick your Order ';
    }
}