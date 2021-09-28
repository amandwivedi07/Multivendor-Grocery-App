import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi/widgets/categories_widget.dart';
import 'package:multi/widgets/products/best_selling.dart';
import 'package:multi/widgets/products/recently_added_products.dart';
import 'package:multi/widgets/products/featured_product.dart';
import 'package:multi/widgets/vendor_appbar.dart';
import 'package:multi/widgets/vendor_banner.dart';

class VendorHomeScreen extends StatelessWidget {
  static const String id = 'vendor-screen';

  @override
  Widget build(BuildContext context) {




    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context,bool innerBoxIsScrollerd){
      return [
        // MyAppBar()
       VendorAppBar()
      ];
    },
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            VendorBanner(),
            VendorCategories(),
          //  Recently Added Products
          //  Best Selling Products
          //  Featured Products
            RecentlyAddedProducts(),
            FeaturedProducts(),
            BestSellingProducts(),

          ],
        )
    )
    );
  }
}
