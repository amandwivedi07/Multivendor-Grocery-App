import 'package:flutter/material.dart';
import 'package:multi/providers/store_provider.dart';
import 'package:multi/widgets/products/product_filter_widget.dart';
import 'package:multi/widgets/products/product_list.dart';
import 'package:provider/provider.dart';


class ProductListScreen extends StatelessWidget {
  static const String id = 'product-list-screen';
  @override
  Widget build(BuildContext context) {
    var _storeProvider = Provider.of<StoreProvider>(context);
    return Scaffold(
        body: NestedScrollView(
        headerSliverBuilder: (BuildContext context,bool innerBoxIsScrollerd){
      return [
        // MyAppBar()
        SliverAppBar(
          floating: true,
          snap:true,
          title: Text(_storeProvider.selectedProductsCategory,style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(
          color:Colors.white
        ),
          expandedHeight: 120,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top:110),
            child: Container(
              height: 50,
              color: Colors.white,
              child: ProductFilterWidget(),
            ),
          ),
        ),
      ];
    },
    body: ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        ProductListWidget(),
      ],
    ),
        ),
    );
  }
}
