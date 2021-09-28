import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:multi/providers/auth_provider.dart';
import 'package:multi/providers/cart_provider.dart';
import 'package:multi/providers/coupon_provider.dart';
import 'package:multi/providers/order_provider.dart';
import 'package:multi/providers/store_provider.dart';
import 'package:multi/screens/cart_screen.dart';
import 'package:multi/screens/homescreen.dart';
import 'package:multi/screens/loginscreen.dart';
import 'package:multi/screens/main_screen.dart';
import 'package:multi/screens/mapscreen.dart';
import 'package:multi/screens/my_orders_screen.dart';
import 'package:multi/screens/notification_screen.dart';
import 'package:multi/screens/payment/stripe/create_new_card_screen.dart';
import 'package:multi/screens/payment/stripe/credit_card_list.dart';
import 'package:multi/screens/payment/stripe/existing-cards.dart';
import 'package:multi/screens/payment/stripe/payment_Home.dart';
import 'package:multi/screens/payment/stripe/razorpay/razorpay_payment_screen.dart';
import 'package:multi/screens/product_details_screen.dart';
import 'package:multi/screens/product_list_screen.dart';
import 'package:multi/screens/profile_screen.dart';
import 'package:multi/screens/profile_update.dart';
import 'package:multi/screens/splashscreen.dart';
import 'package:multi/screens/vendor_home_screen.dart';
import 'package:multi/screens/welcomescreen.dart';
import 'package:multi/screens/landing_screen.dart';
import 'package:multi/providers/location.dart';
import 'package:provider/provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => StoreProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CouponProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primaryColor: Color(0xFFFF6E40),

              // 0xFF84c225
              //NEED TO CHANGE
              fontFamily: 'Lato'
          ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        MapScreen.id: (context) => MapScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        LandingScreen.id:(context)=>LandingScreen(),
        MainScreen.id:(context)=>MainScreen(),
        VendorHomeScreen.id:(context)=>VendorHomeScreen(),
        ProductListScreen.id:(context)=>ProductListScreen(),
        ProductDetailsScreen.id:(context)=>ProductDetailsScreen(),
        CartScreen.id:(context)=> CartScreen(),
        ProfileScreen.id:(context)=> ProfileScreen(),
        UpdateProfile.id:(context)=> UpdateProfile(),
        ExistingCardsPage.id:(context)=> ExistingCardsPage(),
        PaymentHome.id:(context)=>PaymentHome(),
        MyOrders.id:(context)=>MyOrders(),
        CreditCardList.id:(context)=>CreditCardList(),
        CreateNewCreditCard.id:(context)=>CreateNewCreditCard(),
        RazorPaymentScreen.id:(context)=>RazorPaymentScreen(),
        NotificationScreen.id:(context)=>NotificationScreen(),

      },
      builder: EasyLoading.init(),
    );
  }
}
