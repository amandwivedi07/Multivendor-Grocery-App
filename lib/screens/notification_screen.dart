import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  static const String id = 'notification-screen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState(){
      super.initState();
      final fbm = FirebaseMessaging.instance;
      fbm.requestPermission();
      FirebaseMessaging.onMessage.listen((message) {
        print(message);
        return;
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        print(message);
        return;
      });
      fbm.subscribeToTopic('chat');
    }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


